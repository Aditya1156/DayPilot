# Building APK for Android

This guide will help you build an APK file for testing DayPilot on your Android phone.

## Prerequisites

1. Flutter SDK installed
2. Android SDK installed (comes with Android Studio)
3. Android device or emulator

## Build Methods

### Method 1: Debug APK (Quick Testing)

This is the fastest way to build an APK for testing:

```bash
flutter build apk --debug
```

The APK will be located at:
```
build/app/outputs/flutter-apk/app-debug.apk
```

### Method 2: Release APK (Optimized)

For better performance (smaller size, faster):

```bash
flutter build apk --release
```

The APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Method 3: Split APKs (Smallest Size)

Build separate APKs for different architectures:

```bash
flutter build apk --split-per-abi
```

This creates multiple APKs:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM - most modern phones)
- `app-x86_64-release.apk` (64-bit Intel)

Located at: `build/app/outputs/flutter-apk/`

## Installation on Phone

### Option 1: USB Cable

1. Enable Developer Options on your phone:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   
2. Enable USB Debugging:
   - Go to Settings > Developer Options
   - Turn on "USB Debugging"

3. Connect phone via USB

4. Install the APK:
```bash
flutter install
```

Or manually:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Option 2: Transfer File

1. Build the APK using one of the methods above
2. Transfer the APK file to your phone via:
   - Email
   - Google Drive
   - USB cable (copy file)
   - Cloud storage
   
3. On your phone:
   - Open the APK file
   - Tap "Install"
   - You may need to allow "Install from Unknown Sources"

## File Sizes (Approximate)

- Debug APK: ~40-50 MB
- Release APK: ~20-25 MB
- Split APK (arm64): ~15-18 MB

## Troubleshooting

### "App not installed" error
- Make sure you've uninstalled any previous version
- Enable "Install from Unknown Sources" in Settings

### APK too large
- Use `flutter build apk --split-per-abi` for smaller files
- Or build a bundle: `flutter build appbundle`

### Performance issues
- Always use `--release` for testing performance
- Debug builds are intentionally slower

## Quick Command Reference

```bash
# Check connected devices
flutter devices

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build and install directly
flutter run --release

# Clean build (if having issues)
flutter clean
flutter pub get
flutter build apk --release
```

## App Bundle (For Play Store)

If you want to publish to Google Play Store later:

```bash
flutter build appbundle --release
```

The bundle will be at: `build/app/outputs/bundle/release/app-release.aab`

## Current App Details

- **Package Name**: com.example.daypilot
- **Version**: 1.0.0
- **Min SDK**: Android 5.0 (API 21)
- **Target SDK**: Latest

## Next Steps After Building

1. Transfer APK to your phone
2. Install and test all features
3. Check performance and battery usage
4. Test on different screen sizes
5. Collect feedback for improvements

## Notes

- Debug APKs include extra debugging tools (larger size)
- Release APKs are optimized for performance
- Always test on real devices for accurate performance
- The app uses local storage (Hive) so no internet required for core features
