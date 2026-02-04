#!/bin/bash

# iOS Accessibility Checker
# Scans Swift code for common accessibility issues

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="${1:-.}"

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}              iOS Accessibility Checker                     ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Scanning: ${YELLOW}$PROJECT_DIR${NC}"
echo ""

critical=0
warnings=0
suggestions=0

check_pattern() {
    local severity=$1
    local title=$2
    local pattern=$3
    local recommendation=$4

    results=$(grep -rn "$pattern" --include="*.swift" "$PROJECT_DIR" 2>/dev/null) || true

    if [ -n "$results" ]; then
        count=$(echo "$results" | wc -l | tr -d ' ')

        case $severity in
            "CRITICAL")
                echo -e "${RED}🔴 $title ($count found)${NC}"
                critical=$((critical + count))
                ;;
            "WARNING")
                echo -e "${YELLOW}🟡 $title ($count found)${NC}"
                warnings=$((warnings + count))
                ;;
            "SUGGESTION")
                echo -e "${BLUE}🔵 $title ($count found)${NC}"
                suggestions=$((suggestions + count))
                ;;
        esac

        echo "$results" | head -3 | while read -r line; do
            echo -e "   ${line}"
        done
        [ "$count" -gt 3 ] && echo -e "   ... and $((count - 3)) more"
        echo -e "   ${GREEN}→ $recommendation${NC}"
        echo ""
    fi
}

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "                    VoiceOver Support                         "
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Check for UIImageView without accessibility
echo -e "${BLUE}Checking image accessibility...${NC}"
image_views=$(grep -rn "UIImageView()" --include="*.swift" "$PROJECT_DIR" 2>/dev/null | wc -l | tr -d ' ')
image_labels=$(grep -rn "accessibilityLabel.*=.*\"" --include="*.swift" "$PROJECT_DIR" 2>/dev/null | wc -l | tr -d ' ')

if [ "$image_views" -gt "$image_labels" ]; then
    diff=$((image_views - image_labels))
    echo -e "${YELLOW}🟡 Images may be missing accessibility labels${NC}"
    echo -e "   UIImageViews: $image_views"
    echo -e "   accessibilityLabel assignments: $image_labels"
    echo -e "   ${GREEN}→ Add accessibilityLabel to meaningful images${NC}"
    echo ""
    warnings=$((warnings + diff))
fi

# Check for buttons with only images
check_pattern "WARNING" "Image buttons may need accessibility labels" \
    "setImage.*for:.*\.normal" \
    "Add accessibilityLabel describing the button's action"

# Check for custom controls without accessibility
check_pattern "SUGGESTION" "Custom UIView subclasses (verify accessibility)" \
    "class.*: UIView" \
    "Ensure isAccessibilityElement and accessibilityLabel are set"

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "                    Dynamic Type Support                       "
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Check for hardcoded font sizes
check_pattern "WARNING" "Hardcoded font sizes (use Dynamic Type)" \
    "UIFont.*ofSize:" \
    "Use UIFont.preferredFont(forTextStyle:) instead"

check_pattern "WARNING" "System fonts with fixed size" \
    "\.systemFont(ofSize:" \
    "Use UIFont.preferredFont(forTextStyle:) for Dynamic Type"

# Check for adjustsFontForContentSizeCategory
echo -e "${BLUE}Checking Dynamic Type configuration...${NC}"
labels=$(grep -rn "UILabel()" --include="*.swift" "$PROJECT_DIR" 2>/dev/null | wc -l | tr -d ' ')
adjusts=$(grep -rn "adjustsFontForContentSizeCategory.*=.*true" --include="*.swift" "$PROJECT_DIR" 2>/dev/null | wc -l | tr -d ' ')

if [ "$labels" -gt 0 ] && [ "$adjusts" -lt "$labels" ]; then
    echo -e "${YELLOW}🟡 Labels may not scale with Dynamic Type${NC}"
    echo -e "   UILabels: ~$labels"
    echo -e "   adjustsFontForContentSizeCategory = true: $adjusts"
    echo -e "   ${GREEN}→ Set adjustsFontForContentSizeCategory = true on labels${NC}"
    echo ""
    warnings=$((warnings + 1))
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "                    Color Accessibility                        "
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Check for hardcoded colors
check_pattern "SUGGESTION" "Hardcoded RGB colors (consider system colors)" \
    "UIColor(red:" \
    "Use system colors (.label, .systemBackground) for dark mode"

check_pattern "SUGGESTION" "Color literals (consider system colors)" \
    "#colorLiteral" \
    "Use system colors for automatic dark mode support"

# Check for system colors usage (positive)
system_colors=$(grep -rn "\.system" --include="*.swift" "$PROJECT_DIR" 2>/dev/null | grep -E "\.(label|systemBackground|secondaryLabel)" | wc -l | tr -d ' ')
if [ "$system_colors" -gt 0 ]; then
    echo -e "${GREEN}✅ Using system colors: $system_colors occurrences${NC}\n"
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "                    Touch Targets                              "
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

# Check for small fixed sizes
check_pattern "WARNING" "Small fixed dimensions (tap target < 44pt)" \
    "constraint.*equalToConstant.*[0-3][0-9])" \
    "Ensure tap targets are at least 44x44 points"

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "                         Summary                               "
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${RED}Critical: $critical${NC}"
echo -e "  ${YELLOW}Warnings: $warnings${NC}"
echo -e "  ${BLUE}Suggestions: $suggestions${NC}"
echo ""

total=$((critical + warnings))
if [ "$total" -eq 0 ]; then
    echo -e "  ${GREEN}✅ No major accessibility issues detected!${NC}"
else
    echo -e "  ${YELLOW}⚠️  Review issues for better accessibility${NC}"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "Tips:"
echo -e "  • Test with VoiceOver enabled"
echo -e "  • Test with largest Dynamic Type size"
echo -e "  • Use Accessibility Inspector in Xcode"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
