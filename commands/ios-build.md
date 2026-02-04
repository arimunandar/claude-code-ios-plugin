---
allowed-tools:
  - mcp__XcodeBuildMCP__discover_projs
  - mcp__XcodeBuildMCP__list_schemes
  - mcp__XcodeBuildMCP__session-set-defaults
  - mcp__XcodeBuildMCP__session-show-defaults
  - mcp__XcodeBuildMCP__build_sim
  - mcp__XcodeBuildMCP__build_device
  - mcp__XcodeBuildMCP__build_macos
  - mcp__XcodeBuildMCP__list_sims
  - mcp__XcodeBuildMCP__list_devices
  - mcp__XcodeBuildMCP__clean
  - Read
  - Glob
description: Build iOS/macOS project for simulator, device, or macOS
---

# iOS Build Command

Build the iOS or macOS project using Xcode MCP tools.

## Context

Current directory contents:
```
!ls -la
```

Xcode projects found:
```
!find . -name "*.xcodeproj" -o -name "*.xcworkspace" 2>/dev/null | head -20
```

## Your Task

Build the project following these steps:

1. **Discover project** - Use `discover_projs` to find Xcode project/workspace files

2. **List schemes** - Use `list_schemes` to see available build schemes

3. **Determine target**:
   - If user specified "device" or "physical", target a connected device
   - If user specified "macos" or "mac", build for macOS
   - Otherwise, default to iOS Simulator

4. **For Simulator builds**:
   - Use `list_sims` to find available simulators
   - Set session defaults with `session-set-defaults` (scheme, simulatorId, useLatestOS: true)
   - Run `build_sim`

5. **For Device builds**:
   - Use `list_devices` to find connected devices
   - Set session defaults with `session-set-defaults` (scheme, deviceId)
   - Run `build_device`

6. **For macOS builds**:
   - Set session defaults with appropriate scheme
   - Run `build_macos`

7. **Handle errors**:
   - If build fails, analyze the error output
   - Suggest fixes for common issues (missing provisioning profiles, code signing, etc.)
   - Offer to run `clean` and retry if appropriate

8. **Report results**:
   - Show build success/failure status
   - Display build time if available
   - Show path to built product

## Tips

- Always set session defaults before building
- Use `useLatestOS: true` for simulators to auto-select OS version
- For device builds, ensure the device is connected and trusted
- Check for provisioning profile issues on device builds
