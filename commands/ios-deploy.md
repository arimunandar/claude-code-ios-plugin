---
allowed-tools:
  - mcp__XcodeBuildMCP__discover_projs
  - mcp__XcodeBuildMCP__list_schemes
  - mcp__XcodeBuildMCP__session-set-defaults
  - mcp__XcodeBuildMCP__build_sim
  - mcp__XcodeBuildMCP__build_device
  - mcp__XcodeBuildMCP__build_run_sim
  - mcp__XcodeBuildMCP__list_sims
  - mcp__XcodeBuildMCP__list_devices
  - mcp__XcodeBuildMCP__boot_sim
  - mcp__XcodeBuildMCP__open_sim
  - mcp__XcodeBuildMCP__get_sim_app_path
  - mcp__XcodeBuildMCP__get_device_app_path
  - mcp__XcodeBuildMCP__get_app_bundle_id
  - mcp__XcodeBuildMCP__install_app_sim
  - mcp__XcodeBuildMCP__install_app_device
  - mcp__XcodeBuildMCP__launch_app_sim
  - mcp__XcodeBuildMCP__launch_app_device
  - mcp__XcodeBuildMCP__stop_app_sim
  - mcp__XcodeBuildMCP__screenshot
  - Read
  - Glob
description: Deploy and run iOS app on simulator or device
---

# iOS Deploy Command

Build, install, and launch the iOS app on a simulator or connected device.

## Context

Current directory:
```
!ls -la
```

Available simulators:
```
!xcrun simctl list devices available | head -20
```

## Your Task

Deploy the app following these steps:

1. **Discover project** - Use `discover_projs` to find Xcode project/workspace

2. **List schemes** - Use `list_schemes` to find the main app scheme

3. **Determine target**:
   - If user specified "device" or a device name, deploy to device
   - Otherwise, deploy to iOS Simulator

4. **For Simulator deployment**:
   a. List available simulators with `list_sims`
   b. Open Simulator app with `open_sim`
   c. Boot the target simulator with `boot_sim`
   d. Set session defaults (scheme, simulatorId)
   e. Build and run with `build_run_sim`

5. **For Device deployment**:
   a. List connected devices with `list_devices`
   b. Verify device is connected and trusted
   c. Set session defaults (scheme, deviceId)
   d. Build for device with `build_device`
   e. Get app path with `get_device_app_path`
   f. Install with `install_app_device`
   g. Get bundle ID with `get_app_bundle_id`
   h. Launch with `launch_app_device`

6. **Verify deployment**:
   - For simulator: Take a screenshot with `screenshot`
   - Confirm app is running

7. **Handle errors**:
   - Code signing issues: Check provisioning profiles
   - Device not found: Verify connection and trust
   - Build failures: Show error and suggest fixes

## Quick Deploy Options

**Simulator (default)**:
```
/ios-deploy
```

**Specific simulator**:
```
/ios-deploy iPhone 16 Pro
```

**Physical device**:
```
/ios-deploy device
```

**Named device**:
```
/ios-deploy "John's iPhone"
```

## Tips

- Ensure the simulator is booted before installing
- For device deployment, the device must be connected and trusted
- Use `screenshot` to verify the app launched correctly
- Check Console.app for device logs if the app crashes
