# Firebase Setup Guide for DayPilot

## Overview
This guide will help you integrate Firebase into your DayPilot app for authentication, database, and storage.

---

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Project name: `DayPilot` (or your preferred name)
4. Click **Continue**
5. Enable Google Analytics (optional but recommended)
6. Click **Create project**
7. Wait for project to be ready, then click **Continue**

---

## Step 2: Add Android App to Firebase

### 2.1 Register Your Android App

1. In Firebase Console, click the **Android icon** to add Android app
2. Fill in the required fields:
   - **Android package name**: `com.daypilot.app` 
     - ⚠️ This must match your `android/app/build.gradle.kts` applicationId
     - Find it in: `android/app/build.gradle.kts` → `applicationId = "com.daypilot.app"`
   - **App nickname** (optional): `DayPilot Android`
   - **Debug signing certificate SHA-1** (optional for now, required later for Google Sign-In)

3. Click **"Register app"**

### 2.2 Download Configuration File

1. Download `google-services.json` file
2. Place it in: `android/app/google-services.json`
   - ⚠️ This is CRITICAL - file must be in `android/app/` directory
3. Click **"Next"**

### 2.3 Add Firebase SDK

The `build.gradle.kts` files should already be configured. Verify these lines exist:

**android/build.gradle.kts**:
```kotlin
dependencies {
    classpath("com.google.gms:google-services:4.4.0")
}
```

**android/app/build.gradle.kts** (at the bottom):
```kotlin
apply(plugin = "com.google.gms.google-services")
```

4. Click **"Next"**, then **"Continue to console"**

---

## Step 3: Enable Firebase Services

### 3.1 Enable Authentication

1. In Firebase Console, go to **Build** → **Authentication**
2. Click **"Get started"**
3. Click on **"Email/Password"** provider
4. Toggle **"Enable"** to ON
5. Click **"Save"**

### 3.2 Enable Cloud Firestore

1. Go to **Build** → **Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in production mode"** (we'll add security rules next)
4. Select a location closest to your users (e.g., `us-central1`)
5. Click **"Enable"**

### 3.3 Set Up Firestore Security Rules

After database is created, go to **Rules** tab and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // User's tasks
      match /tasks/{taskId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // User's routines
      match /routines/{routineId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // User's analytics
      match /analytics/{analyticsId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

Click **"Publish"**

### 3.4 Enable Cloud Storage (Optional - for profile pictures)

1. Go to **Build** → **Storage**
2. Click **"Get started"**
3. Choose **"Start in production mode"**
4. Select same location as Firestore
5. Click **"Done"**

### 3.5 Set Up Storage Security Rules

Go to **Rules** tab and replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Click **"Publish"**

---

## Step 4: Verify Configuration

### 4.1 Check File Structure

Ensure your file structure looks like this:

```
flutterapp/
├── android/
│   ├── app/
│   │   ├── google-services.json  ← THIS FILE IS CRITICAL
│   │   └── build.gradle.kts
│   └── build.gradle.kts
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── user_profile.dart
│   └── services/
│       └── firebase_service.dart
└── pubspec.yaml
```

### 4.2 Verify google-services.json Content

Your `google-services.json` should look like this (values will be different):

```json
{
  "project_info": {
    "project_number": "123456789",
    "project_id": "daypilot-xxxxx",
    "storage_bucket": "daypilot-xxxxx.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789:android:xxxxx",
        "android_client_info": {
          "package_name": "com.daypilot.app"
        }
      }
    }
  ]
}
```

---

## Step 5: Build and Test

### 5.1 Clean and Rebuild

```powershell
flutter clean
flutter pub get
flutter build apk --release
```

### 5.2 Test Firebase Connection

After installing the app:
1. App should launch without crashes
2. Create a new account with email/password
3. Check Firebase Console → Authentication → Users
4. You should see the new user listed

### 5.3 Test Firestore Data

1. Complete a task in the app
2. Go to Firebase Console → Firestore Database
3. You should see:
   ```
   users (collection)
   └── {userId} (document)
       └── tasks (subcollection)
           └── {taskId} (document with task data)
   ```

---

## Troubleshooting

### Error: "No Firebase App"
- ✅ Verify `google-services.json` is in `android/app/` directory
- ✅ Verify package name matches in both files
- ✅ Run `flutter clean` and rebuild

### Error: "Default Firebase App has not been initialized"
- ✅ Check `main.dart` has `await Firebase.initializeApp()`
- ✅ Verify `google-services.json` is properly formatted
- ✅ Check internet connection

### Authentication Not Working
- ✅ Verify Email/Password is enabled in Firebase Console
- ✅ Check Firestore security rules allow authenticated users
- ✅ Test with a valid email format

### Data Not Syncing to Firestore
- ✅ Check Firestore security rules
- ✅ Verify user is authenticated before saving data
- ✅ Check Firebase Console for error logs

---

## Features Enabled with Firebase

### ✅ User Authentication
- Email/password signup and login
- Secure user sessions
- Automatic token refresh

### ✅ Cloud Database (Firestore)
- Real-time data sync across devices
- Offline support with local cache
- Automatic conflict resolution

### ✅ Data Persistence
- Tasks sync across devices
- Routines saved to cloud
- Analytics data stored securely
- User preferences synced

### ✅ Profile Storage
- Username saved to Firestore
- Email stored securely
- Profile pictures (when Storage enabled)
- User preferences and settings

---

## What Gets Synced?

### Automatically Synced to Firebase:
1. **User Profile**
   - Username
   - Email
   - Creation date
   - Last active timestamp
   - User preferences

2. **Tasks**
   - All task details
   - Completion status
   - Categories and times
   - Real-time updates

3. **Routines**
   - Custom routines
   - Routine schedules
   - Routine templates

4. **Analytics**
   - Task completion stats
   - Productivity metrics
   - Usage patterns

---

## Local vs Cloud Data

### Without Firebase (Guest Mode):
- All data stored locally with Hive
- No sync across devices
- Data lost if app uninstalled
- Username stored in SharedPreferences

### With Firebase (Authenticated):
- Data synced to cloud
- Access from any device
- Data persists even after uninstall
- Offline mode with automatic sync when online

---

## Security Best Practices

### ✅ Already Implemented:
- Authentication required for all operations
- Users can only access their own data
- Secure token-based authentication
- Data encrypted in transit

### ⚠️ Important Notes:
- Never commit `google-services.json` to public repositories
- Add to `.gitignore`: `android/app/google-services.json`
- Use different Firebase projects for development and production
- Review security rules before launching

---

## Next Steps

After Firebase is set up:

1. ✅ Test user registration
2. ✅ Test login/logout
3. ✅ Create and sync tasks
4. ✅ Verify data appears in Firestore
5. ✅ Test on multiple devices
6. ✅ Test offline mode
7. ✅ Build release APK

---

## Quick Reference

### Firebase Console Links:
- **Project Overview**: https://console.firebase.google.com/project/YOUR_PROJECT_ID
- **Authentication**: .../authentication/users
- **Firestore**: .../firestore/data
- **Storage**: .../storage/files

### Important Files:
- `android/app/google-services.json` - Firebase config
- `lib/services/firebase_service.dart` - Firebase operations
- `lib/models/user_profile.dart` - User data model

### Commands:
```powershell
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Install on device
flutter install
```

---

## Support

If you encounter issues:
1. Check Firebase Console for error logs
2. Review this guide's troubleshooting section
3. Verify all configuration files are correct
4. Test with a fresh `flutter clean` and rebuild

---

**Last Updated**: October 19, 2025
**Version**: 1.0.0
**Firebase SDK**: Latest stable
