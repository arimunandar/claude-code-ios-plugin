---
allowed-tools:
  - mcp__XcodeBuildMCP__discover_projs
  - mcp__XcodeBuildMCP__list_schemes
  - mcp__XcodeBuildMCP__session-set-defaults
  - mcp__XcodeBuildMCP__session-show-defaults
  - mcp__XcodeBuildMCP__test_sim
  - mcp__XcodeBuildMCP__test_device
  - mcp__XcodeBuildMCP__test_macos
  - mcp__XcodeBuildMCP__list_sims
  - mcp__XcodeBuildMCP__list_devices
  - mcp__XcodeBuildMCP__boot_sim
  - Read
  - Glob
  - Grep
description: Run unit and UI tests for iOS/macOS projects
---

# iOS Test Command

Run tests for iOS or macOS projects using Xcode MCP tools.

## Context

Current directory contents:
```
!ls -la
```

Test files in project:
```
!find . -name "*Tests.swift" -o -name "*Spec.swift" 2>/dev/null | head -20
```

## Your Task

Run tests following these steps:

1. **Discover project** - Use `discover_projs` to find Xcode project/workspace files

2. **List schemes** - Use `list_schemes` to identify test schemes (usually ending in "Tests" or the main scheme)

3. **Determine test target**:
   - If user specified "device", run on connected device
   - If user specified "macos", run macOS tests
   - Otherwise, default to iOS Simulator

4. **For Simulator tests**:
   - Use `list_sims` to find available simulators
   - Boot simulator if needed with `boot_sim`
   - Set session defaults (scheme, simulatorId, useLatestOS: true)
   - Run `test_sim`

5. **For Device tests**:
   - Use `list_devices` to find connected devices
   - Set session defaults (scheme, deviceId)
   - Run `test_device`

6. **For macOS tests**:
   - Set session defaults
   - Run `test_macos`

7. **Analyze results**:
   - Parse test output for pass/fail counts
   - Identify failing tests
   - Show test duration

8. **For failing tests**:
   - Read the test file to understand what failed
   - Provide suggestions for fixing failures
   - Offer to re-run specific tests if possible

## Test Execution Options

You can pass additional arguments via `extraArgs`:
- Filter tests: `["-only-testing:MyAppTests/UserViewModelTests"]`
- Skip tests: `["-skip-testing:MyAppUITests"]`
- Parallel testing: `["-parallel-testing-enabled", "YES"]`

## Environment Variables

Use `testRunnerEnv` to pass environment variables:
```json
{
  "API_URL": "https://test.example.com",
  "MOCK_NETWORK": "true"
}
```

## Tips

- Unit tests should run fast (<1s each ideally)
- UI tests require the simulator to be visible
- Use `-parallel-testing-enabled YES` for faster test runs
- Check for flaky tests if results are inconsistent
