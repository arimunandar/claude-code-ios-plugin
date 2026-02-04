---
allowed-tools:
  - mcp__XcodeBuildMCP__discover_projs
  - mcp__XcodeBuildMCP__list_schemes
  - mcp__XcodeBuildMCP__session-set-defaults
  - mcp__XcodeBuildMCP__show_build_settings
  - mcp__XcodeBuildMCP__clean
  - Bash(xcodebuild archive:*)
  - Bash(xcodebuild -exportArchive:*)
  - Bash(xcrun altool:*)
  - Bash(xcrun notarytool:*)
  - Read
  - Glob
  - Write
description: Archive iOS app for App Store or Ad Hoc distribution
---

# iOS Archive Command

Create an archive of the iOS app for App Store submission or Ad Hoc distribution.

## Context

Current project:
```
!ls -la *.xcodeproj *.xcworkspace 2>/dev/null
```

Build settings:
```
!xcodebuild -showBuildSettings 2>/dev/null | grep -E "(PRODUCT_BUNDLE_IDENTIFIER|MARKETING_VERSION|CURRENT_PROJECT_VERSION)" | head -10
```

## Your Task

Create an archive following these steps:

1. **Discover project** - Use `discover_projs` to find Xcode project/workspace

2. **List schemes** - Use `list_schemes` to find the main app scheme

3. **Verify configuration**:
   - Check `show_build_settings` for bundle ID, version
   - Verify code signing configuration
   - Check for Release configuration

4. **Clean build** (recommended):
   ```bash
   xcodebuild clean -scheme "AppScheme" -configuration Release
   ```

5. **Create archive**:
   ```bash
   xcodebuild archive \
       -workspace MyApp.xcworkspace \
       -scheme "MyApp" \
       -configuration Release \
       -archivePath ./build/MyApp.xcarchive \
       -destination "generic/platform=iOS"
   ```

6. **Export IPA** (if requested):

   **For App Store**:
   ```bash
   xcodebuild -exportArchive \
       -archivePath ./build/MyApp.xcarchive \
       -exportPath ./build/AppStore \
       -exportOptionsPlist ExportOptions.plist
   ```

   **ExportOptions.plist for App Store**:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>method</key>
       <string>app-store-connect</string>
       <key>destination</key>
       <string>upload</string>
       <key>signingStyle</key>
       <string>automatic</string>
       <key>uploadSymbols</key>
       <true/>
   </dict>
   </plist>
   ```

   **ExportOptions.plist for Ad Hoc**:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>method</key>
       <string>ad-hoc</string>
       <key>signingStyle</key>
       <string>automatic</string>
       <key>thinning</key>
       <string>&lt;none&gt;</string>
   </dict>
   </plist>
   ```

7. **Upload to App Store Connect** (if requested):
   ```bash
   xcrun altool --upload-app \
       -f ./build/AppStore/MyApp.ipa \
       -t ios \
       --apiKey YOUR_API_KEY \
       --apiIssuer YOUR_ISSUER_ID
   ```

8. **Generate report**:
   ```markdown
   ## Archive Summary

   **App**: MyApp
   **Version**: 1.0.0 (1)
   **Bundle ID**: com.example.myapp
   **Archive Path**: ./build/MyApp.xcarchive
   **IPA Path**: ./build/AppStore/MyApp.ipa (if exported)

   ### Next Steps
   1. Open Xcode Organizer to view archive
   2. Upload to App Store Connect
   3. Submit for review

   ### Checklist Before Submission
   - [ ] Privacy manifest included
   - [ ] App icons complete
   - [ ] Screenshots prepared
   - [ ] Release notes written
   ```

## Archive Types

| Method | Use Case |
|--------|----------|
| `app-store-connect` | App Store submission |
| `ad-hoc` | Testing on registered devices |
| `enterprise` | Internal distribution (requires enterprise account) |
| `development` | Development testing |

## Common Issues

**Code Signing**:
- Ensure certificates are installed
- Check provisioning profile is valid
- Verify team ID in build settings

**Version Numbers**:
- Increment `CURRENT_PROJECT_VERSION` for each upload
- `MARKETING_VERSION` must be unique per submission

## Tips

- Always clean before archiving for release
- Use automatic signing for simplicity
- Test the exported IPA on a device before uploading
- Keep archives for symbolication of crash reports
