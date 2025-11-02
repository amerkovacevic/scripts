#!/bin/bash

# Script to push all changes to GitHub for each app repository
# Usage: ./push-all-apps.sh [commit-message] [-s <app-name>]

COMMIT_MESSAGE="Update design tokens and improve contrast"
SINGLE_APP=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--single)
            SINGLE_APP="$2"
            if [ -z "$SINGLE_APP" ]; then
                echo "Error: -s requires an app name"
                echo "Usage: ./push-all-apps.sh [commit-message] [-s <app-name>]"
                exit 1
            fi
            shift 2
            ;;
        *)
            # If it's not a flag and starts with -, it's unknown
            if [[ "$1" == -* ]]; then
                echo "Unknown option: $1"
                echo "Usage: ./push-all-apps.sh [commit-message] [-s <app-name>]"
                echo "Available apps: ak-dashboard, secret-santa, pickup-soccer, personal-portfolio, fm-team-draw, color-crafter, amer-gauntlet"
                exit 1
            else
                # It's the commit message
                COMMIT_MESSAGE="$1"
                shift
            fi
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
    echo "Pushing changes to single repository: $SINGLE_APP"
else
    echo "Pushing changes to all app repositories"
fi
echo "Commit message: $COMMIT_MESSAGE"
echo "========================================="
echo ""

TOTAL_PUSHED=0
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
    
    if [ ! -d "$APP_PATH/.git" ]; then
        echo "[SKIP] $APP_DIR - Not a git repository"
        ((TOTAL_SKIPPED++))
        continue
    fi
    
    echo "[PROCESSING] $APP_DIR..."
    cd "$APP_PATH" || continue
    
    # Check if there are any changes
    if ! git status --porcelain > /dev/null 2>&1; then
        echo "  [ERROR] Git status failed"
        ((TOTAL_ERRORS++))
        continue
    fi
    
    if [ -z "$(git status --porcelain)" ]; then
        echo "  [SKIP] No changes to commit"
        ((TOTAL_SKIPPED++))
        continue
    fi
    
    # Show what will be committed
    echo "  Changes detected:"
    git status --short | sed 's/^/    /'
    
    # Add all changes
    echo "  Adding changes..."
    if ! git add -A > /dev/null 2>&1; then
        echo "  [ERROR] Failed to add changes"
        ((TOTAL_ERRORS++))
        continue
    fi
    
    # Commit
    echo "  Committing..."
    if ! git commit -m "$COMMIT_MESSAGE" > /dev/null 2>&1; then
        # Check if commit failed because there's nothing to commit
        if [ -z "$(git status --porcelain)" ]; then
            echo "  [SKIP] No changes to commit (already committed)"
            ((TOTAL_SKIPPED++))
        else
            echo "  [ERROR] Failed to commit"
            ((TOTAL_ERRORS++))
        fi
        continue
    fi
    
    # Push
    echo "  Pushing to GitHub..."
    if git push > /dev/null 2>&1; then
        echo "  [SUCCESS] Pushed to GitHub"
        ((TOTAL_PUSHED++))
    else
        echo "  [ERROR] Failed to push"
        ((TOTAL_ERRORS++))
    fi
    
    echo ""
done

# Summary
echo "========================================="
echo "Summary:"
echo "  Pushed: $TOTAL_PUSHED"
echo "  Skipped: $TOTAL_SKIPPED"
echo "  Errors: $TOTAL_ERRORS"
echo "========================================="

if [ $TOTAL_ERRORS -gt 0 ]; then
    exit 1
else
    exit 0
fi

