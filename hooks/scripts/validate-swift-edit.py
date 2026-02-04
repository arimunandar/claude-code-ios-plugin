#!/usr/bin/env python3
"""
PreToolUse hook to validate Swift code edits for dangerous patterns.
Checks for common security issues and anti-patterns before applying changes.
"""

import json
import sys
import re

# Patterns to check for dangerous code
DANGEROUS_PATTERNS = [
    {
        "pattern": r"NSAllowsArbitraryLoads\s*</key>\s*<true/>",
        "message": "Disabling App Transport Security allows insecure HTTP connections",
        "severity": "error",
        "category": "security"
    },
    {
        "pattern": r"force_cast|as!",
        "message": "Force cast (as!) can crash at runtime. Consider using 'as?' with proper error handling",
        "severity": "warning",
        "category": "safety"
    },
    {
        "pattern": r"try!",
        "message": "Force try (try!) can crash at runtime. Consider using 'try?' or 'do-catch'",
        "severity": "warning",
        "category": "safety"
    },
    {
        "pattern": r"implicitly unwrapped optional|!:",
        "message": "Implicitly unwrapped optionals can cause crashes. Consider using regular optionals",
        "severity": "warning",
        "category": "safety"
    },
    {
        "pattern": r"UserDefaults\.standard\.set\([^,]+,\s*forKey:\s*[\"'](?:password|token|secret|api_?key|credential)",
        "message": "Storing sensitive data in UserDefaults is insecure. Use Keychain instead",
        "severity": "error",
        "category": "security"
    },
    {
        "pattern": r"print\([^)]*(?:password|token|secret|apiKey|credential)",
        "message": "Logging sensitive data can expose credentials. Remove before production",
        "severity": "warning",
        "category": "security"
    },
    {
        "pattern": r"MD5|SHA1(?!28|256|384|512)",
        "message": "MD5 and SHA1 are cryptographically weak. Use SHA256 or higher",
        "severity": "error",
        "category": "cryptography"
    },
    {
        "pattern": r"ECB",
        "message": "ECB mode is insecure. Use GCM or CBC with proper IV",
        "severity": "error",
        "category": "cryptography"
    },
    {
        "pattern": r"\.allowsArbitraryLoadsForMedia\s*=\s*true",
        "message": "Allowing arbitrary loads for media bypasses ATS security",
        "severity": "warning",
        "category": "security"
    },
    {
        "pattern": r"javaScriptEnabled\s*=\s*true",
        "message": "Enabling JavaScript in WebViews can introduce XSS vulnerabilities. Ensure proper validation",
        "severity": "warning",
        "category": "security"
    },
    {
        "pattern": r"DispatchQueue\.main\.sync",
        "message": "sync on main queue from main thread will deadlock. Use async instead",
        "severity": "error",
        "category": "concurrency"
    },
    {
        "pattern": r"Thread\.sleep|sleep\(",
        "message": "Blocking sleep calls can freeze the UI. Use Task.sleep for async code",
        "severity": "warning",
        "category": "performance"
    },
    {
        "pattern": r"\[weak self\].*self\?\..*self\!",
        "message": "Force unwrapping self after weak capture can crash. Use guard let or optional chaining",
        "severity": "warning",
        "category": "safety"
    },
    {
        "pattern": r"#if\s+DEBUG[\s\S]*?(?:API_KEY|SECRET|PASSWORD|TOKEN)",
        "message": "Hardcoded credentials in DEBUG blocks still ship in source. Use environment variables",
        "severity": "warning",
        "category": "security"
    }
]

# Patterns that are acceptable in certain contexts
CONTEXT_EXCEPTIONS = {
    "force_cast|as!": ["XCTest", "Tests.swift", "Spec.swift"],
    "try!": ["XCTest", "Tests.swift", "Spec.swift", "Preview"],
}


def check_content(content: str, file_path: str) -> list:
    """Check content for dangerous patterns."""
    issues = []

    for check in DANGEROUS_PATTERNS:
        pattern = check["pattern"]
        matches = re.finditer(pattern, content, re.IGNORECASE)

        for match in matches:
            # Check for context exceptions
            exception_patterns = CONTEXT_EXCEPTIONS.get(pattern, [])
            if any(exc in file_path or exc in content[:500] for exc in exception_patterns):
                continue

            # Find line number
            line_num = content[:match.start()].count('\n') + 1

            issues.append({
                "line": line_num,
                "message": check["message"],
                "severity": check["severity"],
                "category": check["category"],
                "matched": match.group()[:50]  # First 50 chars of match
            })

    return issues


def main():
    # Read hook input from stdin
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit(0)  # Allow if can't parse input

    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})

    # Only check Edit and Write tools
    if tool_name not in ["Edit", "Write"]:
        sys.exit(0)

    file_path = tool_input.get("file_path", "")

    # Only check Swift files
    if not file_path.endswith(".swift"):
        sys.exit(0)

    # Get content to check
    content = ""
    if tool_name == "Write":
        content = tool_input.get("content", "")
    elif tool_name == "Edit":
        content = tool_input.get("new_string", "")

    if not content:
        sys.exit(0)

    # Check for issues
    issues = check_content(content, file_path)

    if not issues:
        sys.exit(0)

    # Report issues
    errors = [i for i in issues if i["severity"] == "error"]
    warnings = [i for i in issues if i["severity"] == "warning"]

    output = []

    if errors:
        output.append(f"⛔ {len(errors)} security/safety error(s) detected:")
        for issue in errors:
            output.append(f"  Line {issue['line']}: [{issue['category']}] {issue['message']}")

    if warnings:
        output.append(f"⚠️  {len(warnings)} warning(s) detected:")
        for issue in warnings:
            output.append(f"  Line {issue['line']}: [{issue['category']}] {issue['message']}")

    # Print to stderr for visibility
    print("\n".join(output), file=sys.stderr)

    # Block on errors, allow warnings
    if errors:
        sys.exit(2)  # Block the edit
    else:
        sys.exit(0)  # Allow with warnings


if __name__ == "__main__":
    main()
