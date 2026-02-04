#!/bin/bash

# iOS Code Quality Analyzer
# Analyzes Swift code for potential issues, complexity, and best practices

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="${1:-.}"
REPORT_FILE="${2:-code-quality-report.md}"

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}              iOS Code Quality Analyzer                     ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Scanning: ${YELLOW}$PROJECT_DIR${NC}"
echo ""

# Initialize counters
total_files=0
total_lines=0
force_unwraps=0
force_tries=0
todos=0
weak_delegates=0
strong_delegates=0
large_files=0
large_functions=0

# Create report header
cat > "$REPORT_FILE" << EOF
# Code Quality Report

**Generated:** $(date)
**Directory:** $PROJECT_DIR

## Summary

EOF

echo -e "${BLUE}Analyzing Swift files...${NC}"

# Count files and lines
total_files=$(find "$PROJECT_DIR" -name "*.swift" -type f | wc -l | tr -d ' ')
total_lines=$(find "$PROJECT_DIR" -name "*.swift" -type f -exec cat {} \; | wc -l | tr -d ' ')

echo "  Files: $total_files"
echo "  Lines: $total_lines"

# Check for force unwraps
echo -e "\n${BLUE}Checking for force unwraps...${NC}"
force_unwrap_results=$(grep -rn '![^=]' --include="*.swift" "$PROJECT_DIR" 2>/dev/null | grep -v "//.*!" | grep -v "IBOutlet" | grep -v "!=") || true
force_unwraps=$(echo "$force_unwrap_results" | grep -c "." || echo "0")
echo "  Force unwraps: $force_unwraps"

# Check for force try
echo -e "${BLUE}Checking for force try...${NC}"
force_try_results=$(grep -rn 'try!' --include="*.swift" "$PROJECT_DIR" 2>/dev/null) || true
force_tries=$(echo "$force_try_results" | grep -c "." || echo "0")
echo "  Force try: $force_tries"

# Check for TODOs
echo -e "${BLUE}Checking for TODOs/FIXMEs...${NC}"
todo_results=$(grep -rn -E '(TODO|FIXME|HACK|XXX):' --include="*.swift" "$PROJECT_DIR" 2>/dev/null) || true
todos=$(echo "$todo_results" | grep -c "." || echo "0")
echo "  TODOs/FIXMEs: $todos"

# Check delegates
echo -e "${BLUE}Checking delegate patterns...${NC}"
all_delegates=$(grep -rn 'var delegate' --include="*.swift" "$PROJECT_DIR" 2>/dev/null || true)
weak_delegates=$(echo "$all_delegates" | grep -c "weak" || echo "0")
strong_delegates=$(echo "$all_delegates" | grep -v "weak" | grep -c "." || echo "0")
echo "  Weak delegates: $weak_delegates"
echo "  Strong delegates (potential leaks): $strong_delegates"

# Check for large files (>300 lines)
echo -e "${BLUE}Checking file sizes...${NC}"
while IFS= read -r file; do
    lines=$(wc -l < "$file" | tr -d ' ')
    if [ "$lines" -gt 300 ]; then
        ((large_files++)) || true
    fi
done < <(find "$PROJECT_DIR" -name "*.swift" -type f 2>/dev/null)
echo "  Large files (>300 lines): $large_files"

# Check for potential memory leaks (closures without weak self)
echo -e "${BLUE}Checking for potential retain cycles...${NC}"
potential_leaks=$(grep -rn '{ [^[]' --include="*.swift" "$PROJECT_DIR" 2>/dev/null | grep 'self\.' | grep -v "weak" | grep -v "unowned") || true
leak_count=$(echo "$potential_leaks" | grep -c "." || echo "0")
echo "  Potential retain cycles: $leak_count"

# Calculate score
score=100
[ "$force_unwraps" -gt 0 ] && score=$((score - force_unwraps * 2))
[ "$force_tries" -gt 0 ] && score=$((score - force_tries * 5))
[ "$strong_delegates" -gt 0 ] && score=$((score - strong_delegates * 10))
[ "$large_files" -gt 0 ] && score=$((score - large_files * 3))
[ "$leak_count" -gt 0 ] && score=$((score - leak_count * 5))
[ $score -lt 0 ] && score=0

# Determine grade
if [ $score -ge 90 ]; then
    grade="A"
    grade_color=$GREEN
elif [ $score -ge 80 ]; then
    grade="B"
    grade_color=$GREEN
elif [ $score -ge 70 ]; then
    grade="C"
    grade_color=$YELLOW
elif [ $score -ge 60 ]; then
    grade="D"
    grade_color=$YELLOW
else
    grade="F"
    grade_color=$RED
fi

# Write report
cat >> "$REPORT_FILE" << EOF
| Metric | Count |
|--------|-------|
| Total Swift Files | $total_files |
| Total Lines | $total_lines |
| Force Unwraps | $force_unwraps |
| Force Try | $force_tries |
| TODOs/FIXMEs | $todos |
| Weak Delegates | $weak_delegates |
| Strong Delegates | $strong_delegates |
| Large Files (>300 lines) | $large_files |
| Potential Retain Cycles | $leak_count |

**Quality Score:** $score/100 (Grade: $grade)

## Issues Found

### Force Unwraps
EOF

if [ -n "$force_unwrap_results" ] && [ "$force_unwraps" -gt 0 ]; then
    echo '```' >> "$REPORT_FILE"
    echo "$force_unwrap_results" | head -20 >> "$REPORT_FILE"
    [ "$force_unwraps" -gt 20 ] && echo "... and $((force_unwraps - 20)) more" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
else
    echo "None found." >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

### Force Try
EOF

if [ -n "$force_try_results" ] && [ "$force_tries" -gt 0 ]; then
    echo '```' >> "$REPORT_FILE"
    echo "$force_try_results" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
else
    echo "None found." >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

### Strong Delegates (Potential Memory Leaks)
EOF

strong_delegate_results=$(echo "$all_delegates" | grep -v "weak") || true
if [ -n "$strong_delegate_results" ] && [ "$strong_delegates" -gt 0 ]; then
    echo '```' >> "$REPORT_FILE"
    echo "$strong_delegate_results" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
else
    echo "None found." >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

### Potential Retain Cycles
EOF

if [ -n "$potential_leaks" ] && [ "$leak_count" -gt 0 ]; then
    echo '```' >> "$REPORT_FILE"
    echo "$potential_leaks" | head -20 >> "$REPORT_FILE"
    [ "$leak_count" -gt 20 ] && echo "... and $((leak_count - 20)) more" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
else
    echo "None found." >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

## Recommendations

EOF

[ "$force_unwraps" -gt 0 ] && echo "- Replace force unwraps with optional binding or nil coalescing" >> "$REPORT_FILE"
[ "$force_tries" -gt 0 ] && echo "- Replace \`try!\` with proper error handling" >> "$REPORT_FILE"
[ "$strong_delegates" -gt 0 ] && echo "- Mark delegates as \`weak\` to prevent retain cycles" >> "$REPORT_FILE"
[ "$large_files" -gt 0 ] && echo "- Consider splitting large files (>300 lines) into smaller components" >> "$REPORT_FILE"
[ "$leak_count" -gt 0 ] && echo "- Add \`[weak self]\` to closures that capture self" >> "$REPORT_FILE"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "Quality Score: ${grade_color}$score/100 (Grade: $grade)${NC}"
echo -e "Report saved to: ${YELLOW}$REPORT_FILE${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
