#!/bin/bash

# iOS Memory Leak Pattern Detector
# Scans Swift code for common memory leak patterns

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="${1:-.}"

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}              iOS Memory Leak Pattern Detector              ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Scanning: ${YELLOW}$PROJECT_DIR${NC}"
echo ""

critical_count=0
warning_count=0

# Function to report issues
report_issue() {
    local severity=$1
    local title=$2
    local pattern=$3
    local fix=$4

    results=$(grep -rn "$pattern" --include="*.swift" "$PROJECT_DIR" 2>/dev/null) || true

    if [ -n "$results" ]; then
        count=$(echo "$results" | wc -l | tr -d ' ')

        if [ "$severity" = "CRITICAL" ]; then
            echo -e "${RED}🔴 $severity: $title ($count found)${NC}"
            critical_count=$((critical_count + count))
        else
            echo -e "${YELLOW}🟡 $severity: $title ($count found)${NC}"
            warning_count=$((warning_count + count))
        fi

        echo "$results" | head -5 | while read -r line; do
            echo -e "   ${line}"
        done
        [ "$count" -gt 5 ] && echo -e "   ... and $((count - 5)) more"
        echo -e "   ${GREEN}Fix: $fix${NC}"
        echo ""
    fi
}

echo -e "${BLUE}Checking for memory leak patterns...${NC}\n"

# 1. Strong delegates
report_issue "CRITICAL" "Strong delegate references" \
    "var delegate.*[^?]$" \
    "Use 'weak var delegate: DelegateProtocol?'"

# 2. Timer without weak self
report_issue "CRITICAL" "Timer retaining self" \
    "Timer.*target.*self" \
    "Use Timer(withTimeInterval:repeats:block:) with [weak self]"

# 3. Closures capturing self without weak
report_issue "WARNING" "Closures potentially capturing self strongly" \
    "{ [^[]*self\." \
    "Add [weak self] or [unowned self] capture list"

# 4. NotificationCenter without removal
echo -e "${BLUE}Checking NotificationCenter observers...${NC}"
observers=$(grep -rn "addObserver" --include="*.swift" "$PROJECT_DIR" 2>/dev/null | wc -l | tr -d ' ')
removals=$(grep -rn "removeObserver" --include="*.swift" "$PROJECT_DIR" 2>/dev/null | wc -l | tr -d ' ')
deinits=$(grep -rn "deinit" --include="*.swift" "$PROJECT_DIR" 2>/dev/null | wc -l | tr -d ' ')

if [ "$observers" -gt "$removals" ]; then
    diff=$((observers - removals))
    echo -e "${YELLOW}🟡 WARNING: NotificationCenter imbalance${NC}"
    echo -e "   addObserver calls: $observers"
    echo -e "   removeObserver calls: $removals"
    echo -e "   Potential missing removals: $diff"
    echo -e "   ${GREEN}Fix: Remove observers in deinit or use Combine${NC}"
    echo ""
    warning_count=$((warning_count + diff))
fi

# 5. DispatchWorkItem capturing self
report_issue "WARNING" "DispatchWorkItem potentially capturing self" \
    "DispatchWorkItem.*{[^}]*self" \
    "Add [weak self] to DispatchWorkItem closure"

# 6. URLSession completion without weak
report_issue "WARNING" "URLSession task with potential strong capture" \
    "dataTask.*completionHandler.*{[^}]*self\." \
    "Add [weak self] to completion handler"

# 7. Combine sink without weak
report_issue "WARNING" "Combine sink potentially capturing self" \
    "\.sink.*{[^}]*self\." \
    "Add [weak self] to sink closure"

# 8. Animation with completion capturing self
report_issue "WARNING" "Animation completion capturing self" \
    "UIView.animate.*completion.*{[^}]*self\." \
    "Add [weak self] to animation completion"

# 9. Check for missing deinit in ViewControllers
echo -e "${BLUE}Checking for deinit in ViewControllers...${NC}"
vcs=$(grep -rl "UIViewController" --include="*.swift" "$PROJECT_DIR" 2>/dev/null | wc -l | tr -d ' ')
if [ "$vcs" -gt "$deinits" ]; then
    echo -e "${YELLOW}🟡 INFO: Some ViewControllers may be missing deinit${NC}"
    echo -e "   ViewControllers: ~$vcs"
    echo -e "   deinit methods: $deinits"
    echo -e "   ${GREEN}Tip: Add deinit with print to verify deallocation${NC}"
    echo ""
fi

# 10. Escaping closures stored as properties
report_issue "WARNING" "Stored closures (check for weak capture)" \
    "var.*: .*->.*Void" \
    "Ensure closure properties use [weak self] when set"

# Summary
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "                         Summary                              "
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${RED}Critical issues: $critical_count${NC}"
echo -e "  ${YELLOW}Warnings: $warning_count${NC}"
echo ""

total=$((critical_count + warning_count))
if [ "$total" -eq 0 ]; then
    echo -e "  ${GREEN}✅ No memory leak patterns detected!${NC}"
elif [ "$critical_count" -eq 0 ]; then
    echo -e "  ${YELLOW}⚠️  Review warnings for potential issues${NC}"
else
    echo -e "  ${RED}❌ Critical issues require immediate attention${NC}"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "Tip: Run Instruments with Leaks template for runtime analysis"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
