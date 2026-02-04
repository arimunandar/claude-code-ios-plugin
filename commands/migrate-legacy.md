---
name: migrate-legacy
description: Analyze legacy iOS code and create a migration plan to VIP+W Clean Architecture
---

# Migrate Legacy Command

Analyzes legacy/spaghetti iOS code and creates a comprehensive migration plan to VIP+W Clean Architecture.

## Usage

```
/migrate-legacy [path]
```

**Arguments:**
- `path` (optional): Path to analyze. Defaults to current directory.

## What It Does

1. **Scans for Legacy Patterns**
   - Massive ViewControllers (>200 lines)
   - API calls in ViewControllers
   - Business logic in ViewControllers
   - Mixed responsibilities

2. **Generates Analysis Report**
   - Files that need migration
   - Priority ranking
   - Complexity assessment

3. **Creates Migration Plan**
   - Step-by-step migration guide
   - Per-screen breakdown
   - Recommended order

## Example Output

```markdown
# Legacy Code Migration Analysis

## Summary
- Total ViewControllers: 15
- Need Migration: 8
- Critical (>500 lines): 2
- High Priority: 3
- Medium Priority: 3

## Critical Files

### 1. HomeViewController.swift (847 lines)
**Issues:**
- 12 API calls directly in VC
- Business logic for cart management
- 5 navigation points
- No separation of concerns

**Migration Complexity:** High
**Estimated Effort:** 2-3 days

### 2. ProductDetailViewController.swift (523 lines)
...

## Recommended Migration Order

1. HomeViewController - Core flow, highest impact
2. ProductDetailViewController - Frequently changed
3. CartViewController - Bug-prone area
...

## Next Steps

1. Run `/migrate-legacy HomeViewController.swift` for detailed plan
2. Review the migration guide in skills/legacy-migration
3. Start with characterization tests
```

## Detailed Analysis

For a specific file:

```
/migrate-legacy Features/Home/HomeViewController.swift
```

Outputs:
- Current responsibilities breakdown
- Identified code smells
- Proposed VIP+W structure
- Step-by-step migration checklist
- Code transformation examples

## Integration with Agents

This command automatically invokes the `legacy-migrator` agent for comprehensive analysis.
