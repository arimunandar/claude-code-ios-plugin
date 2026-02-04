#!/bin/bash
#
# Utility script to detect Xcode project information.
# Used by various plugin components to discover project structure.
#

set -e

# Find Xcode workspace or project
find_project() {
    local workspace=$(find . -maxdepth 3 -name "*.xcworkspace" -not -path "*/.*" -not -name "*.xcodeproj/*.xcworkspace" 2>/dev/null | head -1)
    local project=$(find . -maxdepth 3 -name "*.xcodeproj" -not -path "*/.*" 2>/dev/null | head -1)

    if [ -n "$workspace" ]; then
        echo "workspace:$workspace"
    elif [ -n "$project" ]; then
        echo "project:$project"
    else
        echo "none"
    fi
}

# Get available schemes
get_schemes() {
    local project_info=$(find_project)
    local type=$(echo "$project_info" | cut -d: -f1)
    local path=$(echo "$project_info" | cut -d: -f2-)

    if [ "$type" = "workspace" ]; then
        xcodebuild -workspace "$path" -list 2>/dev/null | grep -A 100 "Schemes:" | tail -n +2 | sed 's/^[[:space:]]*//' | grep -v "^$"
    elif [ "$type" = "project" ]; then
        xcodebuild -project "$path" -list 2>/dev/null | grep -A 100 "Schemes:" | tail -n +2 | sed 's/^[[:space:]]*//' | grep -v "^$"
    fi
}

# Get deployment target from project
get_deployment_target() {
    local project=$(find . -maxdepth 3 -name "*.xcodeproj" -not -path "*/.*" 2>/dev/null | head -1)
    if [ -n "$project" ]; then
        xcodebuild -project "$project" -showBuildSettings 2>/dev/null | grep "IPHONEOS_DEPLOYMENT_TARGET" | head -1 | awk '{print $3}'
    fi
}

# Get bundle identifier
get_bundle_id() {
    local project=$(find . -maxdepth 3 -name "*.xcodeproj" -not -path "*/.*" 2>/dev/null | head -1)
    if [ -n "$project" ]; then
        xcodebuild -project "$project" -showBuildSettings 2>/dev/null | grep "PRODUCT_BUNDLE_IDENTIFIER" | head -1 | awk '{print $3}'
    fi
}

# Main command dispatch
case "${1:-info}" in
    project)
        find_project
        ;;
    schemes)
        get_schemes
        ;;
    deployment-target)
        get_deployment_target
        ;;
    bundle-id)
        get_bundle_id
        ;;
    info|*)
        echo "Xcode Project Detection"
        echo "======================="
        echo ""
        echo "Project: $(find_project)"
        echo ""
        echo "Schemes:"
        get_schemes | head -10
        echo ""
        echo "Deployment Target: $(get_deployment_target)"
        echo "Bundle ID: $(get_bundle_id)"
        ;;
esac
