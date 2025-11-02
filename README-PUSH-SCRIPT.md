# Automated Scripts for All Apps

This directory contains bash scripts to automatically manage commits, builds, and deployments for all app repositories.

## Available Scripts

### 1. Push Script - Commit and push changes to GitHub

```bash
cd scripts
chmod +x push-all-apps.sh
./push-all-apps.sh
```

### 2. Deploy Script - Build and deploy all apps to Firebase

```bash
cd scripts
chmod +x deploy-all-apps.sh
./deploy-all-apps.sh
```

**Note:** Scripts are located in the `scripts/` directory. Navigate to the scripts directory before running, or use `./scripts/push-all-apps.sh` from the parent directory.

## Usage

### Push Script Usage

#### Default commit message (all apps)
```bash
cd scripts
./push-all-apps.sh
```

Or from the parent directory:
```bash
./scripts/push-all-apps.sh
```

#### Custom commit message (all apps)
```bash
cd scripts
./push-all-apps.sh "Your custom commit message here"
```

#### Push single app with default message
```bash
cd scripts
./push-all-apps.sh -s pickup-soccer
```

#### Push single app with custom message
```bash
cd scripts
./push-all-apps.sh -s secret-santa "Update font configuration"
```

#### Available apps for -s option:
- `ak-dashboard`
- `secret-santa`
- `pickup-soccer`
- `personal-portfolio`
- `fm-team-draw`
- `color-crafter`
- `amer-gauntlet`

### Deploy Script Usage

#### Full deployment for all apps (build + deploy + push)
```bash
cd scripts
./deploy-all-apps.sh
```

Or from the parent directory:
```bash
./scripts/deploy-all-apps.sh
```

#### Deploy a single app
```bash
cd scripts
./deploy-all-apps.sh -s pickup-soccer
```

#### Skip build step (if already built)
```bash
cd scripts
./deploy-all-apps.sh --skip-build
```

#### Skip git push (deploy only)
```bash
cd scripts
./deploy-all-apps.sh --skip-push
```

#### Deploy single app without building
```bash
cd scripts
./deploy-all-apps.sh -s secret-santa --skip-build
```

#### Skip both build and push
```bash
cd scripts
./deploy-all-apps.sh --skip-build --skip-push
```

## What Each Script Does

### Push Script

1. **Iterates through app directories:**
   - By default: Processes all apps
   - With `-s <app-name>`: Processes only the specified app

2. **For each repository:**
   - Checks if it's a git repository
   - Checks if there are uncommitted changes
   - Adds all changes (`git add -A`)
   - Commits with the provided message
   - Pushes to GitHub (`git push`)

3. **Provides feedback:**
   - Shows which apps are being processed
   - Displays what files changed
   - Reports success/failure for each app
   - Shows summary at the end

### Deploy Script

1. **Iterates through app directories with Firebase configuration**
   - By default: Processes all apps
   - With `-s <app-name>`: Processes only the specified app

2. **For each app (in order):**
   - **[1/3] Build:** Runs `npm run build` to create production build (unless `--skip-build`)
   - **[2/3] Deploy:** Runs `firebase deploy --non-interactive` to deploy to Firebase
   - **[3/3] Push:** Commits and pushes deployment to GitHub (optional, unless `--skip-push`)

3. **Provides feedback:**
   - Shows progress for each step
   - Reports success/failure for each app
   - Shows summary with totals for builds, deployments, and pushes

## Example Output

### Push Script Output
```
=========================================
Pushing changes to all app repositories
Commit message: Update design tokens and improve contrast
=========================================

[PROCESSING] ak-dashboard...
  Changes detected:
    M src/App.jsx
    M tailwind.config.js
  Adding changes...
  Committing...
  Pushing to GitHub...
  [SUCCESS] Pushed to GitHub

[PROCESSING] secret-santa...
  [SKIP] No changes to commit

=========================================
Summary:
  Pushed: 5
  Skipped: 2
  Errors: 0
=========================================
```

### Push Single App Output
```
=========================================
Pushing changes to single repository: pickup-soccer
Commit message: Update design tokens and improve contrast
=========================================

[PROCESSING] pickup-soccer...
  Changes detected:
    M src/styles/index.css
    M tailwind.config.js
  Adding changes...
  Committing...
  Pushing to GitHub...
  [SUCCESS] Pushed to GitHub

=========================================
Summary:
  Pushed: 1
  Skipped: 0
  Errors: 0
=========================================
```

### Deploy Script Output
```
=========================================
Building and deploying all apps to Firebase
=========================================

[PROCESSING] ak-dashboard...
  [1/3] Building...
  [SUCCESS] Build completed
  [2/3] Deploying to Firebase...
  [SUCCESS] Deployed to Firebase
  [3/3] Pushing to GitHub...
  [SUCCESS] Pushed to GitHub

[PROCESSING] secret-santa...
  [1/3] Building...
  [SUCCESS] Build completed
  [2/3] Deploying to Firebase...
  [SUCCESS] Deployed to Firebase
  [3/3] Pushing to GitHub...
  [SKIP] No changes to commit

=========================================
Summary:
  Built: 7
  Deployed: 7
  Pushed: 3
  Skipped: 0
  Errors: 0
=========================================
```

### Deploy Single App Output
```
=========================================
Deploying single app to Firebase: pickup-soccer
=========================================

[PROCESSING] pickup-soccer...
  [1/3] Building...
  [SUCCESS] Build completed
  [2/3] Deploying to Firebase...
  [SUCCESS] Deployed to Firebase
  [3/3] Pushing to GitHub...
  [SUCCESS] Pushed to GitHub

=========================================
Summary:
  Built: 1
  Deployed: 1
  Pushed: 1
  Skipped: 0
  Errors: 0
=========================================
```

## Safety Features

### Push Script
- Only processes directories that are git repositories
- Skips directories with no changes
- Shows what will be committed before committing
- Handles errors gracefully
- Provides clear feedback for each step

### Deploy Script
- Only processes directories with `firebase.json`
- Continues to next app if one fails
- Shows build and deploy output for debugging
- Optionally skips build or push steps
- Handles errors gracefully

## Prerequisites

### For Push Script
- Bash shell (Linux/Mac/Git Bash on Windows)
- Git must be installed and configured
- You must have write access to all repositories
- Your git credentials must be configured

### For Deploy Script
- Bash shell (Linux/Mac/Git Bash on Windows)
- Node.js and npm must be installed
- Firebase CLI must be installed (`npm install -g firebase-tools`)
- You must be logged into Firebase CLI (`firebase login`)
- Each app must have a `firebase.json` configuration file
- You must have deployment permissions for all Firebase projects

## Notes

### Push Script
- The script will commit ALL changes in each directory (uses `git add -A`)
- If you want to review changes before pushing, use `git status` in each directory first

### Deploy Script
- Deployment uses `--non-interactive` flag to prevent prompts
- Build artifacts are created in each app's `dist` folder
- Each app deploys to its own Firebase project (configured in `firebase.json`)
- If a build fails, deployment for that app is skipped
- Git push only happens if there are uncommitted changes after deployment

