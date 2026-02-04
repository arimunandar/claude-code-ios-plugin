---
allowed-tools:
  - Bash(swiftlint:*)
  - Bash(which swiftlint)
  - Read
  - Glob
  - Edit
description: Run SwiftLint and fix violations
---

# iOS Lint Command

Run SwiftLint on the project and optionally auto-fix violations.

## Context

SwiftLint installation:
```
!which swiftlint && swiftlint version
```

SwiftLint config:
```
!ls -la .swiftlint.yml .swiftlint.yaml 2>/dev/null || echo "No SwiftLint config found"
```

## Your Task

Run SwiftLint following these steps:

1. **Check SwiftLint installation**:
   - Verify SwiftLint is installed
   - If not, suggest: `brew install swiftlint`

2. **Check for config file**:
   - Look for `.swiftlint.yml` or `.swiftlint.yaml`
   - If missing, offer to create a sensible default

3. **Run SwiftLint**:
   ```bash
   swiftlint lint --reporter json
   ```
   Or for specific files:
   ```bash
   swiftlint lint --path Sources/
   ```

4. **Parse results**:
   - Count violations by severity (error, warning)
   - Group by rule
   - Identify most common issues

5. **Auto-fix option**:
   If user requested fixes:
   ```bash
   swiftlint lint --fix
   ```
   Then re-run to show remaining issues

6. **Generate report**:
   ```markdown
   ## SwiftLint Report

   **Errors**: X
   **Warnings**: X

   ### Top Violations

   | Rule | Count | Severity |
   |------|-------|----------|
   | line_length | 15 | warning |
   | force_cast | 3 | error |

   ### Files with Most Issues
   1. UserViewModel.swift (12 violations)
   2. NetworkService.swift (8 violations)

   ### Suggested Fixes
   [Auto-fixable violations with commands]
   ```

## Recommended SwiftLint Config

If no config exists, suggest creating `.swiftlint.yml`:

```yaml
# .swiftlint.yml
disabled_rules:
  - trailing_whitespace

opt_in_rules:
  - empty_count
  - empty_string
  - fatal_error_message
  - first_where
  - force_unwrapping
  - implicitly_unwrapped_optional
  - last_where
  - modifier_order
  - overridden_super_call
  - private_action
  - private_outlet
  - prohibited_super_call
  - redundant_nil_coalescing
  - sorted_imports
  - toggle_bool
  - unneeded_parentheses_in_closure_argument
  - vertical_parameter_alignment_on_call
  - yoda_condition

excluded:
  - Pods
  - .build
  - DerivedData
  - "*.generated.swift"

line_length:
  warning: 120
  error: 200
  ignores_comments: true

type_body_length:
  warning: 300
  error: 500

file_length:
  warning: 500
  error: 1000

function_body_length:
  warning: 50
  error: 100

cyclomatic_complexity:
  warning: 10
  error: 20

nesting:
  type_level: 2
  function_level: 3

identifier_name:
  min_length: 2
  max_length: 50
  excluded:
    - id
    - x
    - y
    - i
    - j
    - k

reporter: "xcode"
```

## Tips

- Run lint before commits using pre-commit hooks
- Use `--fix` for auto-fixable rules
- Configure CI to fail on errors
- Customize rules to match team preferences
