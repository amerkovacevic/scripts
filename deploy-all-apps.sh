#!/bin/bash

# Script to build and deploy all apps to Firebase
# Usage: ./deploy-all-apps.sh [--skip-build] [-s <app-name>]

SKIP_BUILD=false
SINGLE_APP=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--single)
            SINGLE_APP="$2"
            if [ -z "$SINGLE_APP" ]; then
                echo "Error: -s requires an app name"
                echo "Usage: ./deploy-all-apps.sh -s <app-name>"
                exit 1
            fi
            shift 2
            ;;
            --skip-build)
                SKIP_BUILD=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                echo "Usage: ./deploy-all-apps.sh [--skip-build] [-s <app-name>]"
                echo "Available apps: ak-dashboard, secret-santa, pickup-soccer, personal-portfolio, fm-team-draw, color-crafter, amer-gauntlet"
                exit 1
                ;;
    esac
done

# Get the parent directory (amerkovacevic folder) - scripts are in scripts/ subdirectory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# List of app directories to process
APP_DIRS=(
    "ak-dashboard"
    "secret-santa"
    "pickup-soccer"
    "personal-portfolio"
    "fm-team-draw"
    "color-crafter"
    "amer-gauntlet"
)

echo "========================================="
if [ -n "$SINGLE_APP" ]; then
    echo "Deploying single app to Firebase: $SINGLE_APP"
else
    echo "Building and deploying all apps to Firebase"
fi
echo "========================================="
if [ "$SKIP_BUILD" = true ]; then
    echo "  [SKIP BUILD] Build step will be skipped"
fi
echo ""

TOTAL_BUILT=0
TOTAL_DEPLOYED=0
TOTAL_SKIPPED=0
TOTAL_ERRORS=0

# If -s option is used, only process that app
if [ -n "$SINGLE_APP" ]; then
    # Validate app name
    if [[ ! " ${APP_DIRS[@]} " =~ " ${SINGLE_APP} " ]]; then
        echo "Error: Unknown app name '$SINGLE_APP'"
        echo "Available apps: ${APP_DIRS[*]}"
        exit 1
    fi
    APP_DIRS=("$SINGLE_APP")
fi

for APP_DIR in "${APP_DIRS[@]}"; do
    APP_PATH="$SCRIPT_DIR/$APP_DIR"
    
    if [ ! -d "$APP_PATH" ]; then
        echo "[SKIP] $APP_DIR - Directory not found"
        ((TOTAL_SKIPPED++))
        continue
    fi
    
    if [ ! -f "$APP_PATH/firebase.json" ]; then
        echo "[SKIP] $APP_DIR - No firebase.json found"
        ((TOTAL_SKIPPED++))
        continue
    fi
    
    echo "[PROCESSING] $APP_DIR..."
    cd "$APP_PATH" || continue
    
    # Step 1: Build
    if [ "$SKIP_BUILD" = false ]; then
        echo "  [1/2] Building..."
        if npm run build > /dev/null 2>&1; then
            echo "  [SUCCESS] Build completed"
            ((TOTAL_BUILT++))
        else
            echo "  [ERROR] Build failed"
            ((TOTAL_ERRORS++))
            continue
        fi
    else
        echo "  [SKIP] Build step skipped"
    fi
    
    # Step 2: Firebase Deploy
    echo "  [2/2] Deploying to Firebase..."
    if firebase deploy --non-interactive > /dev/null 2>&1; then
        echo "  [SUCCESS] Deployed to Firebase"
        ((TOTAL_DEPLOYED++))
    else
        echo "  [ERROR] Firebase deploy failed"
        ((TOTAL_ERRORS++))
        continue
    fi
    
    echo ""
done

# Summary
echo "========================================="
echo "Summary:"
echo "  Built: $TOTAL_BUILT"
echo "  Deployed: $TOTAL_DEPLOYED"
echo "  Skipped: $TOTAL_SKIPPED"
echo "  Errors: $TOTAL_ERRORS"
echo "========================================="

if [ $TOTAL_ERRORS -gt 0 ]; then
    exit 1
else
    exit 0
fi

