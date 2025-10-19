# 🚀 Quick Command Reference

## Build Commands

### Test APK (for testing on devices)
```powershell
flutter clean
flutter pub get
flutter build apk --release
```
**Output:** `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle (for Google Play Store)
```powershell
flutter clean
flutter pub get
flutter build appbundle --release
```
**Output:** `build/app/outputs/bundle/release/app-release.aab`

---

## Run & Test Commands

### Run in debug mode
```powershell
flutter run
```

### Run specific screen
```powershell
flutter run lib/screens/today_screen_enhanced.dart
```

### Check for errors
```powershell
flutter analyze
```

### Format code
```powershell
flutter format .
```

---

## Firebase Commands

### Check Firebase status
```powershell
firebase login
firebase projects:list
```

### Deploy hosting (for privacy policy)
```powershell
firebase init hosting
firebase deploy --only hosting
```

---

## Dependency Management

### Add dependency
```powershell
flutter pub add package_name
```

### Update all dependencies
```powershell
flutter pub upgrade
```

### Get dependencies
```powershell
flutter pub get
```

---

## App Icon Setup

### 1. Add package
```powershell
flutter pub add dev:flutter_launcher_icons
```

### 2. Add to pubspec.yaml
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
```

### 3. Generate icons
```powershell
flutter pub run flutter_launcher_icons
```

---

## Testing Commands

### Run all tests
```powershell
flutter test
```

### Run specific test
```powershell
flutter test test/widget_test.dart
```

### Test coverage
```powershell
flutter test --coverage
```

---

## Debugging

### Check connected devices
```powershell
flutter devices
```

### Doctor (check Flutter installation)
```powershell
flutter doctor -v
```

### Clear cache
```powershell
flutter clean
flutter pub get
```

---

## APK Installation

### Install on connected device
```powershell
flutter install
```

### Manual install
```powershell
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Version Management

### Update version in pubspec.yaml
```yaml
version: 1.0.1+2  # 1.0.1 is version name, 2 is version code
```

### Update Android version
Edit `android/app/build.gradle`:
```gradle
versionCode 2
versionName "1.0.1"
```

---

## Performance

### Build size analysis
```powershell
flutter build apk --analyze-size
```

### Build with obfuscation
```powershell
flutter build apk --obfuscate --split-debug-info=build/debug-info
```

---

## Useful Shortcuts

### Hot reload (during flutter run)
Press `r` in terminal

### Hot restart (during flutter run)
Press `R` in terminal

### Open DevTools
Press `d` in terminal during flutter run

### Quit app
Press `q` in terminal

---

## Screenshots

### Take screenshot (during flutter run)
Press `s` in terminal

---

## Git Commands (if using version control)

### Initial commit
```powershell
git init
git add .
git commit -m "Initial commit - DayPilot v1.0.0"
```

### Create tag for release
```powershell
git tag v1.0.0
git push origin v1.0.0
```

---

## Privacy Policy Hosting (GitHub Pages)

### 1. Create docs folder
```powershell
mkdir docs
# Add privacy-policy.html to docs/
```

### 2. Push to GitHub
```powershell
git add docs/privacy-policy.html
git commit -m "Add privacy policy"
git push
```

### 3. Enable GitHub Pages
- Go to repository Settings
- Pages section
- Source: docs folder
- URL will be: `https://username.github.io/daypilot/privacy-policy`

---

## Firebase Console URLs

- **Console:** https://console.firebase.google.com
- **Authentication:** https://console.firebase.google.com/project/pesitm-connect/authentication
- **Firestore:** https://console.firebase.google.com/project/pesitm-connect/firestore
- **Storage:** https://console.firebase.google.com/project/pesitm-connect/storage

---

## Store URLs

- **Google Play Console:** https://play.google.com/console
- **Apple App Store Connect:** https://appstoreconnect.apple.com
- **Apple Developer:** https://developer.apple.com

---

## Troubleshooting

### Build fails
```powershell
flutter clean
flutter pub get
flutter build apk --release
```

### Gradle issues
```powershell
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Firebase issues
1. Check google-services.json exists in `android/app/`
2. Check values.xml exists in `android/app/src/main/res/values/`
3. Verify package name matches in all files

### Hive issues
```dart
// Clear Hive box if data structure changed
await Hive.deleteBoxFromDisk('tasks');
```

---

## Quick Build & Test Cycle

```powershell
# 1. Make changes to code

# 2. Format & analyze
flutter format .
flutter analyze

# 3. Test
flutter run

# 4. Build release
flutter clean
flutter build apk --release

# 5. Install on device
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Publishing Checklist Commands

```powershell
# 1. Update version
# Edit pubspec.yaml: version: 1.0.0+1

# 2. Generate app icon
flutter pub run flutter_launcher_icons

# 3. Build app bundle
flutter build appbundle --release

# 4. Verify build
ls build/app/outputs/bundle/release/

# 5. Test on device first
flutter install

# 6. If all good, upload to Play Console!
```

---

## Environment Variables (if needed)

### Set Android SDK path
```powershell
$env:ANDROID_HOME = "C:\Users\YourName\AppData\Local\Android\Sdk"
```

### Set Flutter path
```powershell
$env:PATH += ";C:\flutter\bin"
```

---

## Useful VS Code Commands

- `Ctrl+Shift+P` → "Flutter: New Project"
- `Ctrl+Shift+P` → "Flutter: Run Flutter Doctor"
- `Ctrl+Shift+P` → "Flutter: Clean Project"
- `F5` → Start debugging
- `Shift+F5` → Stop debugging

---

## Pro Tips

### Fast rebuild
```powershell
flutter run --fast-start
```

### Verbose output
```powershell
flutter build apk --release -v
```

### Build for specific ABI
```powershell
flutter build apk --target-platform android-arm64 --release
```

### Generate separate APKs per ABI (smaller size)
```powershell
flutter build apk --split-per-abi --release
```

---

## Need Help?

### Flutter documentation
```powershell
flutter help
flutter build --help
```

### Check logs
```powershell
flutter logs
```

### Run doctor
```powershell
flutter doctor -v
```

---

**Save this file for quick reference! 📚**
