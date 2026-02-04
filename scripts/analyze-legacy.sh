#!/bin/bash

# iOS Legacy Code Analyzer
# Identifies ViewControllers that need migration to VIP+W

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

PROJECT_DIR="${1:-.}"
REPORT_FILE="${2:-legacy-migration-report.md}"

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}           iOS Legacy Code Migration Analyzer               ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Scanning: ${YELLOW}$PROJECT_DIR${NC}"
echo ""

# Initialize arrays
declare -a critical_files
declare -a high_priority_files
declare -a medium_priority_files
declare -a low_priority_files

# Find all ViewControllers
echo -e "${BLUE}Finding ViewControllers...${NC}"
vc_files=$(find "$PROJECT_DIR" -name "*ViewController.swift" -o -name "*VC.swift" 2>/dev/null | grep -v "Pods" | grep -v ".build" | grep -v "DerivedData") || true

total_vcs=0
needs_migration=0

# Create report header
cat > "$REPORT_FILE" << EOF
# Legacy Code Migration Analysis

**Generated:** $(date)
**Directory:** $PROJECT_DIR

## Executive Summary

EOF

echo -e "${BLUE}Analyzing files for legacy patterns...${NC}\n"

# Analyze each ViewController
while IFS= read -r file; do
    [ -z "$file" ] && continue
    total_vcs=$((total_vcs + 1))

    filename=$(basename "$file")
    lines=$(wc -l < "$file" | tr -d ' ')

    # Count issues
    api_calls=$(grep -c "URLSession\|Alamofire\|\.dataTask\|\.request(" "$file" 2>/dev/null || echo "0")
    direct_nav=$(grep -c "pushViewController\|popViewController\|present(" "$file" 2>/dev/null || echo "0")
    business_logic=$(grep -c "if.*==\|guard.*else\|switch.*case" "$file" 2>/dev/null || echo "0")
    formatting=$(grep -c "String(format:\|NumberFormatter\|DateFormatter" "$file" 2>/dev/null || echo "0")
    singletons=$(grep -c "\.shared\|\.default\|\.standard" "$file" 2>/dev/null || echo "0")

    # Calculate priority score
    score=0
    [ "$lines" -gt 500 ] && score=$((score + 50))
    [ "$lines" -gt 300 ] && score=$((score + 30))
    [ "$lines" -gt 200 ] && score=$((score + 20))
    [ "$api_calls" -gt 0 ] && score=$((score + api_calls * 10))
    [ "$direct_nav" -gt 2 ] && score=$((score + direct_nav * 5))
    [ "$business_logic" -gt 10 ] && score=$((score + 15))
    [ "$singletons" -gt 3 ] && score=$((score + 10))

    # Categorize
    if [ "$score" -gt 80 ]; then
        critical_files+=("$file|$lines|$api_calls|$direct_nav|$score")
        needs_migration=$((needs_migration + 1))
        echo -e "  ${RED}🔴 CRITICAL:${NC} $filename ($lines lines, score: $score)"
    elif [ "$score" -gt 50 ]; then
        high_priority_files+=("$file|$lines|$api_calls|$direct_nav|$score")
        needs_migration=$((needs_migration + 1))
        echo -e "  ${YELLOW}🟡 HIGH:${NC} $filename ($lines lines, score: $score)"
    elif [ "$score" -gt 25 ]; then
        medium_priority_files+=("$file|$lines|$api_calls|$direct_nav|$score")
        needs_migration=$((needs_migration + 1))
        echo -e "  ${BLUE}🔵 MEDIUM:${NC} $filename ($lines lines, score: $score)"
    else
        low_priority_files+=("$file|$lines|$api_calls|$direct_nav|$score")
        echo -e "  ${GREEN}🟢 OK:${NC} $filename ($lines lines)"
    fi

done <<< "$vc_files"

# Write summary to report
cat >> "$REPORT_FILE" << EOF
| Metric | Count |
|--------|-------|
| Total ViewControllers | $total_vcs |
| Need Migration | $needs_migration |
| Critical Priority | ${#critical_files[@]} |
| High Priority | ${#high_priority_files[@]} |
| Medium Priority | ${#medium_priority_files[@]} |
| Already Clean | ${#low_priority_files[@]} |

---

## Critical Priority (Migrate First)

These files have severe issues and should be migrated immediately.

EOF

# Write critical files
if [ ${#critical_files[@]} -gt 0 ]; then
    echo "| File | Lines | API Calls | Navigation | Score |" >> "$REPORT_FILE"
    echo "|------|-------|-----------|------------|-------|" >> "$REPORT_FILE"
    for entry in "${critical_files[@]}"; do
        IFS='|' read -r file lines api nav score <<< "$entry"
        filename=$(basename "$file")
        echo "| $filename | $lines | $api | $nav | $score |" >> "$REPORT_FILE"
    done
else
    echo "No critical files found." >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

---

## High Priority

These files have significant issues and should be migrated soon.

EOF

# Write high priority files
if [ ${#high_priority_files[@]} -gt 0 ]; then
    echo "| File | Lines | API Calls | Navigation | Score |" >> "$REPORT_FILE"
    echo "|------|-------|-----------|------------|-------|" >> "$REPORT_FILE"
    for entry in "${high_priority_files[@]}"; do
        IFS='|' read -r file lines api nav score <<< "$entry"
        filename=$(basename "$file")
        echo "| $filename | $lines | $api | $nav | $score |" >> "$REPORT_FILE"
    done
else
    echo "No high priority files found." >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

---

## Medium Priority

These files have some issues but can be migrated later.

EOF

# Write medium priority files
if [ ${#medium_priority_files[@]} -gt 0 ]; then
    echo "| File | Lines | API Calls | Navigation | Score |" >> "$REPORT_FILE"
    echo "|------|-------|-----------|------------|-------|" >> "$REPORT_FILE"
    for entry in "${medium_priority_files[@]}"; do
        IFS='|' read -r file lines api nav score <<< "$entry"
        filename=$(basename "$file")
        echo "| $filename | $lines | $api | $nav | $score |" >> "$REPORT_FILE"
    done
else
    echo "No medium priority files found." >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

---

## Recommended Migration Order

Based on the analysis, here's the recommended order for migration:

EOF

# Create ordered list
order=1
for entry in "${critical_files[@]}"; do
    IFS='|' read -r file lines api nav score <<< "$entry"
    filename=$(basename "$file")
    echo "$order. **$filename** - Critical priority, $lines lines" >> "$REPORT_FILE"
    order=$((order + 1))
done
for entry in "${high_priority_files[@]}"; do
    IFS='|' read -r file lines api nav score <<< "$entry"
    filename=$(basename "$file")
    echo "$order. **$filename** - High priority, $lines lines" >> "$REPORT_FILE"
    order=$((order + 1))
done

cat >> "$REPORT_FILE" << EOF

---

## Next Steps

1. Start with the first critical file
2. Follow the migration guide: \`skills/legacy-migration/SKILL.md\`
3. Write characterization tests before refactoring
4. Extract Worker → Presenter → Interactor → Router
5. Verify with tests after each extraction

---

## Migration Checklist Template

For each file, use this checklist:

- [ ] Document current behavior
- [ ] Write characterization tests
- [ ] Create VIP+W file structure
- [ ] Extract Worker (API calls)
- [ ] Extract Presenter (formatting)
- [ ] Extract Interactor (business logic)
- [ ] Create Router (navigation)
- [ ] Create Configurator
- [ ] Clean ViewController
- [ ] Verify all tests pass
- [ ] Code review
- [ ] Delete legacy code

EOF

# Print summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "                         Summary                              "
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Total ViewControllers: ${YELLOW}$total_vcs${NC}"
echo -e "  Need Migration:        ${RED}$needs_migration${NC}"
echo ""
echo -e "  ${RED}🔴 Critical: ${#critical_files[@]}${NC}"
echo -e "  ${YELLOW}🟡 High:     ${#high_priority_files[@]}${NC}"
echo -e "  ${BLUE}🔵 Medium:   ${#medium_priority_files[@]}${NC}"
echo -e "  ${GREEN}🟢 Clean:    ${#low_priority_files[@]}${NC}"
echo ""
echo -e "Report saved to: ${GREEN}$REPORT_FILE${NC}"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
