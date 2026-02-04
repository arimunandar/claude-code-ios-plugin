---
allowed-tools:
  - Task
  - Read
  - Glob
  - Grep
description: Comprehensive code review using specialized iOS agents
---

# iOS Code Review Command

Perform a comprehensive code review of the iOS project using specialized agents.

## Context

Swift files in project:
```
!find . -name "*.swift" -not -path "*/.*" 2>/dev/null | wc -l
```

Recent git changes:
```
!git diff --name-only HEAD~5 2>/dev/null | grep ".swift$" | head -20
```

## Your Task

Orchestrate a comprehensive code review:

1. **Determine scope**:
   - If user specified files/paths, review those
   - If user mentioned "recent" or "changes", review git diff
   - Otherwise, review key project files (ViewModels, Services, etc.)

2. **Launch review agents** (use Task tool with appropriate agents):

   **iOS Code Reviewer** (always run):
   - Focus: SOLID principles, memory management, Swift concurrency
   - Priority: High - catches bugs and architectural issues

   **SwiftUI Architect** (for SwiftUI projects):
   - Focus: State management, navigation, view composition
   - Priority: Medium - ensures SwiftUI best practices

   **iOS Security Auditor** (for sensitive code):
   - Focus: Keychain usage, network security, data protection
   - Priority: High for auth/payment code, Medium otherwise

   **Test Coverage Analyzer** (if tests exist):
   - Focus: Test gaps, test quality
   - Priority: Medium - ensures code is testable

   **App Store Reviewer** (before release):
   - Focus: Compliance, privacy manifest, Info.plist
   - Priority: High before submission

3. **Aggregate findings**:
   - Collect issues from all agents
   - Deduplicate similar findings
   - Sort by severity (Critical > High > Medium > Low)

4. **Generate report**:
   ```markdown
   ## Code Review Summary

   **Files Reviewed**: X
   **Critical Issues**: X
   **High Priority**: X
   **Medium Priority**: X
   **Low Priority**: X

   ### Critical Issues
   [List with file:line references]

   ### Recommendations
   [Prioritized action items]
   ```

## Review Focus Areas

Based on file types, focus reviews appropriately:

| File Pattern | Primary Agent | Focus |
|--------------|---------------|-------|
| `*ViewModel.swift` | ios-code-reviewer | State management, async |
| `*View.swift` | swiftui-architect | View composition, performance |
| `*Service.swift` | ios-code-reviewer | Error handling, DIP |
| `*Repository.swift` | ios-code-reviewer | Data layer, caching |
| `*Auth*.swift` | ios-security-auditor | Authentication security |
| `*Payment*.swift` | ios-security-auditor | Financial security |
| `*Tests.swift` | test-coverage-analyzer | Test quality |
| `Info.plist` | appstore-reviewer | Compliance |

## Tips

- For large projects, review in batches
- Focus on changed files for incremental reviews
- Run security auditor on any auth/payment code
- Use App Store reviewer before each submission
