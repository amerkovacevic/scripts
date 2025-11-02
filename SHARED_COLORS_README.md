# Shared Color Palette Setup Guide

This guide shows you how to use the shared 5-color palette across all your apps.

## 📍 Location
The shared color file is located at: `shared-design-tokens.js` in the root of your github folder.

## 🎨 Your 5 Core Colors

Currently defined as:
- **Primary**: `#0ea5e9` (Blue)
- **Secondary**: `#a855f7` (Purple)
- **Neutral**: `#171717` (Dark/Black)
- **Success**: `#22c55e` (Green)
- **Warning**: `#f59e0b` (Orange)

## 📦 How to Use in Each App

### For Tailwind CSS Projects (Most of your apps)

1. **Update your `tailwind.config.js`:**

```javascript
import { tailwindColors } from '../shared-design-tokens.js';

/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {
      colors: tailwindColors,
      // Keep your existing custom colors if needed
      // They will merge with the shared colors
    },
  },
  plugins: [],
};
```

2. **Use in your components:**
```jsx
// Use the colors with Tailwind classes
<div className="bg-primary-500 text-white">
<div className="border-secondary-600">
<div className="text-success-500">
```

### For CSS/Non-Tailwind Projects

1. **Add CSS variables to your main CSS file:**

```css
:root {
  --color-primary: #0ea5e9;
  --color-primary-light: #38bdf8;
  --color-primary-dark: #0284c7;
  
  --color-secondary: #a855f7;
  --color-secondary-light: #c084fc;
  --color-secondary-dark: #9333ea;
  
  --color-neutral: #737373;
  --color-neutral-light: #d4d4d4;
  --color-neutral-dark: #404040;
  --color-neutral-darker: #171717;
  
  --color-success: #22c55e;
  --color-success-light: #4ade80;
  --color-success-dark: #16a34a;
  
  --color-warning: #f59e0b;
  --color-warning-light: #fbbf24;
  --color-warning-dark: #d97706;
}

/* Then use them */
.button-primary {
  background-color: var(--color-primary);
}
```

### For JavaScript/TypeScript Projects

```javascript
import { mainColors, colors } from '../shared-design-tokens.js';

// Use directly
const buttonStyle = {
  backgroundColor: mainColors.primary,
  color: mainColors.neutral,
};
```

## 🔄 Updating Colors

**To change the colors across ALL apps:**

1. Edit `shared-design-tokens.js`
2. Update the `mainColors` object at the top of the file
3. Run your build commands in each app to rebuild with new colors

## 📝 Apps That Need Updates

Based on your folder structure, these apps use Tailwind and should be updated:

- ✅ `ak-dashboard` - Already has custom colors, needs update
- ✅ `color-crafter` - Needs colors added
- ✅ `secret-santa` - Uses default Tailwind, needs colors added
- ✅ `pickup-soccer` - Has custom colors, needs update
- ✅ `fm-team-draw` - Has custom colors, needs update
- ✅ `amer-gauntlet` - Has custom colors, needs update
- ✅ `personal-portfolio` - Needs colors added
- ✅ `AlensGeneralConstruction` - Has custom colors, needs update

## 🚀 Quick Start

1. Copy the `shared-design-tokens.js` file to each app's root (or reference it relatively)
2. Update each app's `tailwind.config.js` to import and use `tailwindColors`
3. Rebuild each app

## 💡 Pro Tip

If you want to keep app-specific colors alongside shared colors, you can merge them:

```javascript
import { tailwindColors } from '../shared-design-tokens.js';

export default {
  theme: {
    extend: {
      colors: {
        ...tailwindColors,  // Shared colors
        // App-specific colors (optional)
        brand: {
          DEFAULT: '#your-color',
        },
      },
    },
  },
};
```

