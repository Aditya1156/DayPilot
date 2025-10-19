# 🎯 QUICK FIX: 3 Steps to Sync Firestore

## Problem
```
Firebase Auth:  ✅ 4 users
Firestore DB:   ❌ EMPTY
```

## Solution (5 minutes)

### 1️⃣ Update Firestore Rules
**Firebase Console → Firestore Database → Rules**

Replace with:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```
**Click "Publish"** ✅

---

### 2️⃣ Hot Restart App
**In VS Code Terminal:**
- Press `R` (capital R)
- OR: `q` then `flutter run`

---

### 3️⃣ Login with Each User
**For each of 4 users:**
1. Enter email + password
2. Click "Login"
3. Watch terminal logs:
   ```
   ✅ Firestore profile created successfully!
   ```
4. Check Firebase Console → See new document
5. Logout
6. Repeat for next user

---

## Result
```
Firebase Auth:  ✅ 4 users
Firestore DB:   ✅ 4 documents
```

✅ **FIXED!**

---

## What You'll See in Terminal

**GOOD (Success):**
```
🔑 Attempting login...
✅ Login successful!
⚠️ Firestore profile missing! Creating now...
✅ Firestore profile created successfully!
```

**BAD (Rules not updated):**
```
⚠️ Firestore sync failed: [permission-denied]
```
→ Go back to Step 1

---

## What You'll See in Firebase Console

**Before Fix:**
```
users/
  (empty - no documents)
```

**After Fix:**
```
users/
  ├─ 8JfBzDjrx... (adaityaissc7@gmail.com)
  ├─ cNgcJopSTv... (alok1@gmail.com)
  ├─ DW975iRR8Z... (alok@gmail.com)
  └─ 04TNnrVEYa... (adityaisac7@gmail.com)
```

---

**START NOW! → Step 1 in Firebase Console**
