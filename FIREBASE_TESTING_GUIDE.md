# 🔥 Firebase Authentication & Database Testing Guide

## Current Status
✅ **Firebase Connected**: Yes  
❌ **Database Empty**: No users exist yet  
⚠️ **Login Failed**: Invalid credentials (user doesn't exist)

---

## 📋 Step-by-Step Testing Instructions

### Step 1: Deploy Firestore Security Rules

The Firestore security rules have been created in `firestore.rules`. You need to deploy them:

1. **Open Firebase Console**: https://console.firebase.google.com
2. **Select your project**: PESITM Connect
3. **Go to Firestore Database** → **Rules** tab
4. **Copy and paste** the rules from `firestore.rules`
5. **Click "Publish"**

**Or use Firebase CLI:**
```bash
firebase deploy --only firestore:rules
```

---

### Step 2: Test Signup Flow

#### In Your Running App:

1. **Click "Sign Up" tab** on the login screen
2. **Fill in the form:**
   - **Name**: TestUser
   - **Email**: test@example.com  
   - **Password**: test123456 (min 6 characters)
3. **Click "Sign Up"**

#### What Should Happen:
- ✅ Account created in Firebase Auth
- ✅ User profile saved to Firestore `users/{userId}` collection
- ✅ Username saved to SharedPreferences (offline backup)
- ✅ Automatic redirect to Dashboard

#### Check Logs in Terminal:
Look for these messages:
```
🔐 Auth attempt: SIGNUP
📧 Email: test@example.com
📝 Attempting signup...
✅ Signup successful! UID: {userId}
✅ User data saved to local storage
👤 Updating Firebase Auth display name to: TestUser
✅ Firebase Auth display name updated (or warning if it fails)
💾 Saving user profile to Firestore...
✅ User profile saved to Firestore
🎉 Authentication completed successfully!
```

---

### Step 3: Verify Data in Firebase Console

#### Check Authentication:
1. Go to **Firebase Console** → **Authentication** → **Users** tab
2. You should see: `test@example.com` with UID

#### Check Firestore Database:
1. Go to **Firebase Console** → **Firestore Database** → **Data** tab
2. Navigate to `users` collection
3. You should see a document with UID as the ID
4. Document should contain:
   ```
   {
     uid: "...",
     email: "test@example.com",
     username: "TestUser",
     createdAt: Timestamp,
     lastActive: Timestamp
   }
   ```

---

### Step 4: Test Logout

1. **Click profile icon** in app bar (top right)
2. **Click "Logout"**
3. **Confirm** in the dialog
4. Should return to login screen

---

### Step 5: Test Login

1. **Stay on "Login" tab**
2. **Enter credentials:**
   - **Email**: test@example.com
   - **Password**: test123456
3. **Click "Login"**

#### Check Logs:
```
🔐 Auth attempt: LOGIN
📧 Email: test@example.com
🔑 Attempting login...
✅ Login successful! UID: {userId}
✅ Last active timestamp updated
🎉 Authentication completed successfully!
```

---

### Step 6: Test Password Reset

1. **On login screen**, click **"Forgot Password?"**
2. **Enter email**: test@example.com
3. **Click "Send Reset Link"**
4. **Check your email** (test@example.com) for password reset link
5. **Click link** in email to reset password

---

### Step 7: Test Profile Edit

1. **After logging in**, click **profile icon** in app bar
2. **Click "Edit Profile"**
3. **Change username** to something new
4. **Click "Save"**

#### What Should Happen:
- ✅ Username updated in Firestore
- ✅ Username updated in Firebase Auth
- ✅ Username updated in SharedPreferences
- ✅ Username updated everywhere in UI (app bar, drawer, etc.)

---

## 🐛 Common Issues & Solutions

### Issue 1: "Invalid Credentials" Error
**Cause**: User doesn't exist in Firebase Auth  
**Solution**: Do **Step 2** first (Sign up before login)

### Issue 2: Database Still Empty After Signup
**Cause**: Firestore security rules blocking writes  
**Solution**: Deploy the rules from `firestore.rules` (Step 1)

### Issue 3: "Permission Denied" Error
**Cause**: Firestore rules not deployed or incorrect  
**Solution**:
1. Check rules in Firebase Console → Firestore Database → Rules
2. Make sure they match `firestore.rules` file
3. Click "Publish" to deploy

### Issue 4: Firebase Auth Display Name Not Updating
**Cause**: Known issue with firebase_auth 4.16.0  
**Solution**: This is already handled - username is saved to Firestore and SharedPreferences as backup

---

## 🔍 Debugging Commands

### View Live Logs:
```bash
# In VS Code terminal
flutter logs

# Or with ADB directly
adb logcat -s flutter
```

### Filter for Auth Logs Only:
```bash
flutter logs | Select-String -Pattern "🔐|📧|✅|❌|💾"
```

### Clear App Data (Fresh Start):
```bash
adb shell pm clear com.daypilot.app
```

### Hot Restart App:
In the Flutter terminal, press **`R`** (capital R)

---

## ✅ Expected Test Results

After completing all steps, you should have:

### Firebase Authentication:
- ✅ 1 user registered (test@example.com)
- ✅ User can login successfully
- ✅ User can logout
- ✅ User can reset password

### Firestore Database:
```
users/
  ├─ {userId}/
      ├─ uid: "..."
      ├─ email: "test@example.com"
      ├─ username: "TestUser" (or updated name)
      ├─ createdAt: Timestamp
      └─ lastActive: Timestamp
```

### App Functionality:
- ✅ Login screen shows/hides correctly
- ✅ Dashboard shows after login
- ✅ Username displays in app bar
- ✅ Profile menu works
- ✅ Edit profile updates everywhere
- ✅ Logout returns to login screen

---

## 🚨 Critical Firestore Rules

Your database was empty because **Firestore security rules** might be blocking writes. 

### Current Rules (Deploy These):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Allow authenticated users to read/write their own data
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Allow subcollections (tasks, routines, etc.)
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### How to Deploy:
1. **Firebase Console** → **Firestore Database** → **Rules** tab
2. **Paste the rules** above
3. **Click "Publish"**

---

## 📊 Monitoring in Real-Time

### Firebase Console Tabs to Watch:

1. **Authentication → Users**
   - New users appear here immediately after signup

2. **Firestore Database → Data**
   - User profile documents appear here after signup
   - Watch for the `users` collection to populate

3. **Firestore Database → Usage**
   - Monitor read/write operations

---

## 🎯 Quick Test Checklist

- [ ] Deploy Firestore rules
- [ ] Sign up new test account
- [ ] Verify user in Firebase Auth console
- [ ] Verify user document in Firestore console
- [ ] Logout from app
- [ ] Login with test account
- [ ] Check logs for success messages
- [ ] Edit profile and verify updates
- [ ] Test password reset (optional)

---

## 📞 If Still Not Working

1. **Check Firebase Console** → **Authentication**
   - Is authentication enabled for Email/Password?
   
2. **Check Firebase Console** → **Firestore Database**
   - Is Firestore database created?
   - Are rules deployed?

3. **Check App Logs**
   - Run `flutter logs` in terminal
   - Look for error messages (❌ or E/...)

4. **Check Internet Connection**
   - Firebase needs internet to connect

5. **Clear App Data**
   ```bash
   adb shell pm clear com.daypilot.app
   flutter run
   ```

---

*Generated: January 2025*  
*App: DayPilot*  
*Package: com.daypilot.app*
