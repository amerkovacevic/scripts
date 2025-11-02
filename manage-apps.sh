#!/bin/bash

# Unified script to push to GitHub and/or deploy to Firebase for all apps
# Usage: ./manage-apps.sh [OPTIONS]

# Default values
PUSH=false
DEPLOY=false
COMMIT_MESSAGE="Update application"
SINGLE_APP=""
SKIP_BUILD=false

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

# Help function
show_help() {
    cat << EOF
Usage: ./manage-apps.sh [OPTIONS]

This script allows you to push changes to GitHub and/or deploy to Firebase
for one or all of your applications.

OPTIONS:
    --push              Push changes to GitHub
    --deploy            Deploy to Firebase
    -m, --message TEXT  Custom commit message (default: "Update application")
    -s, --single NAME   Process only the specified app
    --skip-build        Skip build step when deploying (use pre-built files)
    -h, --help          Show this help message

EXAMPLES:
    # Push all apps to GitHub
    ./manage-apps.sh --push

    # Deploy all apps to Firebase
    ./manage-apps.sh --deploy

    # Push and deploy all apps
    ./manage-apps.sh --push --deploy

    # Push single app with custom message
    ./manage-apps.sh --push -s pickup-soccer -m "Fix authentication bug"

    # Deploy single app
    ./manage-apps.sh --deploy -s secret-santa

    # Deploy single app without building
    ./manage-apps.sh --deploy -s ak-dashboard --skip-build

    # Push and deploy single app
    ./manage-apps.sh --push --deploy -s personal-portfolio -m "Update styling"

AVAILABLE APPS:
    - ak-dashboard
    - secret-santa
    - pickup-soccer
    - personal-portfolio
    - fm-team-draw
    - color-crafter
    - amer-gauntlet

NOTES:
    - At least one of --push or --deploy must be specified
    - For --push, you must have git configured and be in a git repository
    - For --deploy, you must have Firebase CLI installed and be logged in
    - Build step runs automatically before deploy unless --skip-build is used
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --push)
            PUSH=true
            shift
            ;;
        --deploy)
            DEPLOY=true
            shift
            ;;
        -m|--message)
            COMMIT_MESSAGE="$2"
            if [ -z "$COMMIT_MESSAGE" ]; then
                echo "Error: -m/--message requires a commit message"
                echo "Usage: ./manage-apps.sh -m \"Your message\""
                exit 1
            fi
            shift 2
            ;;
        -s|--single)
            SINGLE_APP="$2"
            if [ -z "$SINGLE_APP" ]; then
                echo "Error: -s/--single requires an app name"
                echo "Available apps: ${APP_DIRS[*]}"
                exit 1
            fi
            shift 2
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help to see available options"
            exit 1
            ;;
    esac
done

# Validate that at least one action is specified
if [ "$PUSH" = false ] && [ "$DEPLOY" = false ]; then
    echo "Error: At least one action must be specified (--push or --deploy)"
    echo ""
    show_help
    exit 1
fi

# If -s option is used, validate app name
if [ -n "$SINGLE_APP" ]; then
    if [[ ! " ${APP_DIRS[@]} " =~ " ${SINGLE_APP} " ]]; then
        echo "Error: Unknown app name '$SINGLE_APP'"
        echo "Available apps: ${APP_DIRS[*]}"
        exit 1
    fi
    APP_DIRS=("$SINGLE_APP")
fi

# Display what will be done
echo "========================================="
if [ -n "$SINGLE_APP" ]; then
    echo "Processing single app: $SINGLE_APP"
else
    echo "Processing all apps"
fi

if [ "$PUSH" = true ] && [ "$DEPLOY" = true ]; then
    echo "Actions: Push to GitHub + Deploy to Firebase"
elif [ "$PUSH" = true ]; then
    echo "Action: Push to GitHub"
elif [ "$DEPLOY" = true ]; then
    echo "Action: Deploy to Firebase"
fi

if [ "$PUSH" = true ]; then
    echo "Commit message: $COMMIT_MESSAGE"
fi

if [ "$DEPLOY" = true ] && [ "$SKIP_BUILD" = true ]; then
    echo "Build step: SKIPPED"
fi

echo "========================================="
echo ""

# Counters
TOTAL_PUSHED=0
TOTAL_DEPLOYED=0
TOTAL_BUILT=0
TOTAL_SKIPPED=0
TOTAL_ERRORS=0

# Process each app
for APP_DIR in "${APP_DIRS[@]}"; do
    APP_PATH="$SCRIPT_DIR/$APP_DIR"
    
    if [ ! -d "$APP_PATH" ]; then
        echo "[SKIP] $APP_DIR - Directory not found"
        ((TOTAL_SKIPPED++))
        continue
    fi
    
    echo "[PROCESSING] $APP_DIR..."
    
    cd "$APP_PATH" || continue
    
    # Step 1: Push to GitHub (if requested)
    if [ "$PUSH" = true ]; then
        if [ ! -d "$APP_PATH/.git" ]; then
            echo "  [SKIP] Not a git repository"
        else
            # Check if there are any changes
            if ! git status --porcelain > /dev/null 2>&1; then
                echo "  [ERROR] Git status failed"
                ((TOTAL_ERRORS++))
            elif [ -z "$(git status --porcelain)" ]; then
                echo "  [SKIP] No changes to commit"
            else
                # Show what will be committed
                echo "  Changes detected:"
                git status --short | sed 's/^/    /'
                
                # Add all changes
                echo "  Adding changes..."
                if ! git add -A > /dev/null 2>&1; then
                    echo "  [ERROR] Failed to add changes"
                    ((TOTAL_ERRORS++))
                else
                    # Commit
                    echo "  Committing..."
                    if ! git commit -m "$COMMIT_MESSAGE" > /dev/null 2>&1; then
                        echo "  [ERROR] Failed to commit"
                        ((TOTAL_ERRORS++))
                    else
                        # Push
                        echo "  Pushing to GitHub..."
                        if git push > /dev/null 2>&1; then
                            echo "  [SUCCESS] Pushed to GitHub"
                            ((TOTAL_PUSHED++))
                        else
                            echo "  [ERROR] Failed to push"
                            ((TOTAL_ERRORS++))
                        fi
                    fi
                fi
            fi
        fi
    fi
    
    # Step 2: Deploy to Firebase (if requested)
    if [ "$DEPLOY" = true ]; then
        if [ ! -f "$APP_PATH/firebase.json" ]; then
            echo "  [SKIP] No firebase.json found"
        else
            # Build (unless skipped)
            if [ "$SKIP_BUILD" = false ]; then
                echo "  Building..."
                if npm run build > /dev/null 2>&1; then
                    echo "  [SUCCESS] Build completed"
                    ((TOTAL_BUILT++))
                else
                    echo "  [ERROR] Build failed"
                    ((TOTAL_ERRORS++))
                    echo ""
                    continue
                fi
            else
                echo "  [SKIP] Build step skipped"
            fi
            
            # Deploy
            echo "  Deploying to Firebase..."
            if firebase deploy --non-interactive > /dev/null 2>&1; then
                echo "  [SUCCESS] Deployed to Firebase"
                ((TOTAL_DEPLOYED++))
            else
                echo "  [ERROR] Firebase deploy failed"
                ((TOTAL_ERRORS++))
            fi
        fi
    fi
    
    echo ""
done

# Summary
echo "========================================="
echo "Summary:"
if [ "$PUSH" = true ]; then
    echo "  Pushed to GitHub: $TOTAL_PUSHED"
fi
if [ "$DEPLOY" = true ]; then
    if [ "$SKIP_BUILD" = false ]; then
        echo "  Built: $TOTAL_BUILT"
    fi
    echo "  Deployed to Firebase: $TOTAL_DEPLOYED"
fi
echo "  Skipped: $TOTAL_SKIPPED"
echo "  Errors: $TOTAL_ERRORS"
echo "========================================="

if [ $TOTAL_ERRORS -gt 0 ]; then
    exit 1
else
    exit 0
fi

