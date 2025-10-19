# App Icon Setup Instructions

## Option 1: Use Online Icon Generator (Easiest - 5 minutes)

### Step 1: Generate Icon
1. Go to **https://www.canva.com** (Free, no subscription)
2. Create New Design → Custom Size → 1024x1024px
3. Add Elements:
   - Background: Gradient (Blue #6366F1 to Purple #8B5CF6)
   - Icon: Search "calendar check" or "task" in elements
   - Or use a simple checkmark ✓ with white circle background
4. Download as PNG (1024x1024)
5. Save as `assets/icons/app_icon.png`

**Alternative Tool:** https://icon.kitchen (Free online icon maker)

---

## Option 2: Use Python Script (If you have Python)

### Prerequisites
```powershell
pip install pillow
```

### Generate Icon
```powershell
python generate_icon.py
```

This creates:
- `assets/icons/app_icon.png` - Main icon
- `assets/icons/app_icon_foreground.png` - Foreground for adaptive icon

---

## Option 3: Use Existing Flutter Package (Simplest)

### If you just want a basic icon quickly:

1. **Add flutter_launcher_icons package**
```powershell
flutter pub add dev:flutter_launcher_icons
```

2. **Add this to your `pubspec.yaml`** (below `dev_dependencies:`):
```yaml
flutter_launcher_icons:
  android: true
  ios: false  # Set to true if targeting iOS
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#6366F1"
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"
  min_sdk_android: 21
```

3. **Create a simple 1024x1024 PNG icon** (any of the above methods)

4. **Generate launcher icons**
```powershell
flutter pub run flutter_launcher_icons
```

---

## Quick Icon Design Ideas (No Design Skills Needed)

### Design 1: Calendar + Checkmark
- Background: Gradient (Blue → Purple)
- Icon: White calendar outline with checkmark inside

### Design 2: Circle + Letter
- Background: Solid gradient
- Icon: White circle with "D" or "DP" letter

### Design 3: Minimalist
- Background: Solid color (#6366F1)
- Icon: Simple white checkmark or task icon

---

## Free Design Tools

1. **Canva** - https://canva.com (Easiest, drag & drop)
2. **Figma** - https://figma.com (Professional, free for personal)
3. **Icon Kitchen** - https://icon.kitchen (Specialized for app icons)
4. **App Icon Generator** - https://appicon.co (Quick online generator)

---

## After Creating Icon

### Test the icon:
```powershell
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons
flutter run
```

### Build APK with new icon:
```powershell
flutter build apk --release
```

---

## Current App Colors (for reference)

- **Primary:** #6366F1 (Indigo blue)
- **Secondary:** #8B5CF6 (Purple)
- **Accent:** #10B981 (Green for success)

Use these in your icon design to match the app theme!

---

## Icon Checklist

- [ ] 1024x1024px size
- [ ] PNG format
- [ ] Saved to `assets/icons/app_icon.png`
- [ ] Simple, recognizable design
- [ ] Works on both light and dark backgrounds
- [ ] Matches app colors (#6366F1, #8B5CF6)
- [ ] No text (icons work better without text)
- [ ] Tested on device

---

## Example: 2-Minute Icon with Canva

1. Open Canva → Custom Size 1024x1024
2. Add gradient background (blue to purple)
3. Add white circle (Elements → Shapes)
4. Add checkmark icon (Elements → Search "check")
5. Download PNG
6. Done! 🎉

**Time:** 2-5 minutes  
**Cost:** $0 (free tier)  
**Result:** Professional-looking icon
