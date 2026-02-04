#!/bin/bash
#
# PostToolUse hook to run SwiftLint after Swift file edits.
# Provides immediate feedback on style violations.
#

set -e

# Read the hook input from stdin
INPUT=$(cat)

# Extract file path from the tool input
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('tool_input', {}).get('file_path', ''))" 2>/dev/null || echo "")

# Only process Swift files
if [[ ! "$FILE_PATH" == *.swift ]]; then
    exit 0
fi

# Check if the file exists
if [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    # SwiftLint not installed, skip silently
    exit 0
fi

# Run SwiftLint on the specific file
echo "🔍 Running SwiftLint on $(basename "$FILE_PATH")..."

# Run SwiftLint and capture output
LINT_OUTPUT=$(swiftlint lint --path "$FILE_PATH" --quiet 2>&1 || true)

if [ -z "$LINT_OUTPUT" ]; then
    echo "✅ No SwiftLint violations"
    exit 0
fi

# Count violations
ERROR_COUNT=$(echo "$LINT_OUTPUT" | grep -c ": error:" || echo "0")
WARNING_COUNT=$(echo "$LINT_OUTPUT" | grep -c ": warning:" || echo "0")

# Display summary
if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "⛔ SwiftLint: $ERROR_COUNT error(s), $WARNING_COUNT warning(s)"
else
    echo "⚠️  SwiftLint: $WARNING_COUNT warning(s)"
fi

# Show violations (limit to first 5)
echo "$LINT_OUTPUT" | head -5

TOTAL=$((ERROR_COUNT + WARNING_COUNT))
if [ "$TOTAL" -gt 5 ]; then
    REMAINING=$((TOTAL - 5))
    echo "... and $REMAINING more violation(s)"
fi

# Suggest auto-fix if available
if [ "$TOTAL" -gt 0 ]; then
    echo ""
    echo "💡 Run 'swiftlint lint --fix --path $FILE_PATH' to auto-fix some violations"
fi

exit 0
