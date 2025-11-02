# Manage Apps Script Documentation

## Overview

The `manage-apps.sh` script is a unified tool that allows you to push changes to GitHub and/or deploy applications to Firebase for one or all of your apps. This replaces the need to use separate scripts for pushing and deploying.

## Quick Start

```bash
cd scripts
chmod +x manage-apps.sh
./manage-apps.sh --help
```

Or from the parent directory:
```bash
./scripts/manage-apps.sh --help
```

## Prerequisites

### For Pushing to GitHub (`--push`):
- Bash shell (Linux/Mac/Git Bash on Windows)
- Git must be installed and configured
- You must have write access to all repositories
- Your git credentials must be configured

### For Deploying to Firebase (`--deploy`):
- Bash shell (Linux/Mac/Git Bash on Windows)
- Node.js and npm must be installed
- Firebase CLI must be installed (`npm install -g firebase-tools`)
- You must be logged into Firebase CLI (`firebase login`)
- Each app must have a `firebase.json` configuration file
- You must have deployment permissions for all Firebase projects

## Options Reference

### Required Actions

At least one of these must be specified:

| Option | Description |
|--------|-------------|
| `--push` | Push changes to GitHub for the selected app(s) |
| `--deploy` | Deploy app(s) to Firebase |

**Note:** You can use both `--push` and `--deploy` together to push and deploy in a single command.

### Optional Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--message` | `-m` | Custom commit message for git commits | `"Update application"` |
| `--single` | `-s` | Process only the specified app | All apps |
| `--skip-build` | - | Skip build step when deploying (use pre-built files) | Build runs automatically |
| `--help` | `-h` | Show help message and exit | - |

## Available Apps

When using the `-s` or `--single` option, you can specify any of these app names:

- `ak-dashboard`
- `secret-santa`
- `pickup-soccer`
- `personal-portfolio`
- `fm-team-draw`
- `color-crafter`
- `amer-gauntlet`

## Usage Examples

### Basic Operations

#### Push all apps to GitHub
```bash
./manage-apps.sh --push
```
- Commits all changes with default message "Update application"
- Pushes to GitHub for all apps

#### Deploy all apps to Firebase
```bash
./manage-apps.sh --deploy
```
- Builds each app
- Deploys to Firebase for all apps

#### Push and deploy all apps
```bash
./manage-apps.sh --push --deploy
```
- First pushes changes to GitHub
- Then builds and deploys to Firebase

### Single App Operations

#### Push single app with default message
```bash
./manage-apps.sh --push -s pickup-soccer
```

#### Push single app with custom message
```bash
./manage-apps.sh --push -s pickup-soccer -m "Fix authentication bug"
```
or
```bash
./manage-apps.sh --push -s pickup-soccer --message "Fix authentication bug"
```

#### Deploy single app
```bash
./manage-apps.sh --deploy -s secret-santa
```

#### Deploy single app without building
```bash
./manage-apps.sh --deploy -s ak-dashboard --skip-build
```
**Use this when:** You've already built the app and just want to deploy the existing build files.

#### Push and deploy single app
```bash
./manage-apps.sh --push --deploy -s personal-portfolio -m "Update styling"
```

### Advanced Scenarios

#### Push all apps with descriptive commit message
```bash
./manage-apps.sh --push -m "Implement new color palette across all apps"
```

#### Deploy all apps without rebuilding
```bash
./manage-apps.sh --deploy --skip-build
```
**Use this when:** You've already built all apps and just want to deploy.

#### Full workflow for single app (push + deploy)
```bash
./manage-apps.sh --push --deploy -s fm-team-draw -m "Add game deletion feature"
```

## What Each Action Does

### Push Action (`--push`)

For each selected app:
1. **Checks for git repository:** Skips if not a git repository
2. **Checks for changes:** Skips if no changes detected
3. **Shows changes:** Displays what files will be committed
4. **Stages changes:** Runs `git add -A`
5. **Commits changes:** Creates commit with specified message
6. **Pushes to GitHub:** Runs `git push`

### Deploy Action (`--deploy`)

For each selected app:
1. **Checks for Firebase config:** Skips if no `firebase.json` found
2. **Builds app:** Runs `npm run build` (unless `--skip-build` is used)
3. **Deploys to Firebase:** Runs `firebase deploy --non-interactive`

**Note:** If build fails, deployment is skipped for that app.

## Understanding the Output

### Processing Messages

```
[PROCESSING] pickup-soccer...
  Changes detected:
    M src/App.jsx
    M tailwind.config.js
  Adding changes...
  Committing...
  Pushing to GitHub...
  [SUCCESS] Pushed to GitHub
  Building...
  [SUCCESS] Build completed
  Deploying to Firebase...
  [SUCCESS] Deployed to Firebase
```

### Status Messages

- `[SUCCESS]` - Action completed successfully
- `[SKIP]` - Action was skipped (no changes, not a git repo, etc.)
- `[ERROR]` - Action failed (will be counted in summary)

### Summary Report

After processing all apps, you'll see a summary:

```
=========================================
Summary:
  Pushed to GitHub: 5
  Built: 7
  Deployed to Firebase: 7
  Skipped: 2
  Errors: 0
=========================================
```

## Common Workflows

### Workflow 1: Daily Development
```bash
# Make changes to code
# Push changes to GitHub
./manage-apps.sh --push -m "Daily updates"
```

### Workflow 2: Quick Deployment
```bash
# Deploy single app that's already built
./manage-apps.sh --deploy -s pickup-soccer --skip-build
```

### Workflow 3: Full Release
```bash
# Push and deploy all apps
./manage-apps.sh --push --deploy -m "Release v1.2.0"
```

### Workflow 4: Fix and Deploy
```bash
# Fix a bug in one app, push and deploy
./manage-apps.sh --push --deploy -s secret-santa -m "Fix login bug"
```

### Workflow 5: Feature Branch Deployment
```bash
# Push feature work
./manage-apps.sh --push -s personal-portfolio -m "Add new portfolio section"

# Later, deploy when ready
./manage-apps.sh --deploy -s personal-portfolio
```

## Error Handling

The script handles errors gracefully:

1. **If git push fails:** Error is reported, script continues with next app
2. **If build fails:** Deployment is skipped for that app, script continues
3. **If deploy fails:** Error is reported, script continues with next app

All errors are counted and displayed in the summary at the end.

## Tips and Best Practices

1. **Use descriptive commit messages:** Always use `-m` with meaningful messages
   ```bash
   # Good
   ./manage-apps.sh --push -m "Add delete game functionality"
   
   # Bad
   ./manage-apps.sh --push
   ```

2. **Test before deploying:** Make sure your code works locally before deploying
   ```bash
   # Test locally first, then:
   ./manage-apps.sh --push --deploy -s my-app -m "Fix bug"
   ```

3. **Use --skip-build sparingly:** Only skip builds when you're certain the build files are up to date
   ```bash
   # Build once, deploy multiple times
   npm run build  # In the app directory
   ./manage-apps.sh --deploy -s my-app --skip-build
   ```

4. **Single app for testing:** Test deployments on one app before deploying all
   ```bash
   # Test on one app first
   ./manage-apps.sh --push --deploy -s pickup-soccer -m "Test deployment"
   
   # Then deploy all if successful
   ./manage-apps.sh --push --deploy -m "Release update"
   ```

5. **Check git status first:** If unsure about changes, check before pushing
   ```bash
   cd pickup-soccer
   git status
   cd ../scripts
   ./manage-apps.sh --push -s pickup-soccer -m "My changes"
   ```

## Troubleshooting

### "Error: At least one action must be specified"
**Solution:** You must specify either `--push` or `--deploy` (or both)

### "Error: Unknown app name"
**Solution:** Check the app name spelling. Use `--help` to see available apps.

### "Failed to push" errors
**Possible causes:**
- Git credentials not configured
- No network connection
- No write access to repository

**Solution:** 
- Check `git config --list` for your credentials
- Test with `git push` manually in one app directory

### "Build failed" errors
**Possible causes:**
- Missing dependencies (`node_modules`)
- Code errors
- Missing environment variables

**Solution:**
- Run `npm install` in the app directory
- Check for TypeScript/ESLint errors
- Review build output (remove `> /dev/null 2>&1` from script temporarily)

### "Firebase deploy failed"
**Possible causes:**
- Not logged into Firebase
- No deployment permissions
- Invalid `firebase.json`

**Solution:**
- Run `firebase login`
- Verify `firebase.json` exists and is valid
- Check Firebase project permissions

## Migration from Old Scripts

If you were using the separate `push-all-apps.sh` and `deploy-all-apps.sh` scripts:

### Old way:
```bash
# Push
./push-all-apps.sh "My message"

# Deploy
./deploy-all-apps.sh -s pickup-soccer
```

### New way:
```bash
# Push
./manage-apps.sh --push -m "My message"

# Deploy
./manage-apps.sh --deploy -s pickup-soccer
```

The old scripts are still available if needed, but `manage-apps.sh` provides a unified interface.

## See Also

- `README-PUSH-SCRIPT.md` - Documentation for the separate push script
- `push-all-apps.sh` - Standalone push script (if needed)
- `deploy-all-apps.sh` - Standalone deploy script (if needed)

