# Test Credentials for DayPilot App

## Important: Email Must Match Exactly!

Firebase authentication is **case-sensitive** and requires **exact email match**.

---

## Your Current Test Account

Based on the signup logs, here are your credentials:

### Account Created:
- **Email:** `adityaissc7@gmail.com` ✅
- **Password:** (the password you entered during signup)
- **Username:** (the name you entered during signup)
- **User ID:** `04TNnVEYayQJW8w2Ukh3qFcn01E3`

---

## How to Log In

1. **Open the app**
2. **Tap "Log In"** (make sure you're in login mode, not signup)
3. **Enter credentials EXACTLY:**
   - Email: `adityaissc7@gmail.com` (must match exactly)
   - Password: (same password from signup)
4. **Tap "Sign In"**

---

## Common Login Errors

### ❌ Error: "Invalid credential" or "Auth credential incorrect"
**Cause:** Email doesn't match exactly or wrong password

**Examples of mismatches:**
- Signup: `adityaissc7@gmail.com` ❌ Login: `aditya@gmail.com` 
- Signup: `user@gmail.com` ❌ Login: `User@gmail.com` (case matters!)
- Signup: `test@gmail.com` ❌ Login: `test @gmail.com` (extra space)

**Solution:** 
- Use the **exact same email** you used during signup
- Check for typos, extra spaces, or case differences
- Verify your password is correct

### ❌ Error: "No user found with this email"
**Cause:** The email hasn't been registered yet

**Solution:**
- Sign up first with that email
- Or use the correct email from your existing account

### ❌ Error: "Wrong password"
**Cause:** Password is incorrect

**Solution:**
- Try again carefully
- Use password reset if you forgot it

---

## Testing Different Scenarios

### Test Scenario 1: New User Signup
1. Switch to **Sign Up** mode
2. Enter:
   - Name: Test User
   - Email: test123@example.com
   - Password: Test123456
3. Tap "Create Account"
4. Should auto-navigate to dashboard

### Test Scenario 2: Existing User Login
1. Switch to **Log In** mode
2. Enter:
   - Email: adityaissc7@gmail.com (your signup email)
   - Password: (your signup password)
3. Tap "Sign In"
4. Should auto-navigate to dashboard

### Test Scenario 3: Wrong Email (Should Fail)
1. Try logging in with: `aditya@gmail.com`
2. Should show error: "Invalid credential"

### Test Scenario 4: Wrong Password (Should Fail)
1. Try logging in with correct email but wrong password
2. Should show error: "Incorrect password"

---

## Troubleshooting

### Can't Remember Which Email You Used?

**Check Firebase Console:**
1. Go to https://console.firebase.google.com
2. Select your project
3. Go to **Authentication** → **Users**
4. You'll see all registered emails

**Check App Logs:**
Look for this line in your terminal:
```
I/FirebaseAuth(xxxx): Creating user with [YOUR_EMAIL]
```

### Can't Remember Password?

Currently no password reset implemented. Options:
1. Delete the user from Firebase Console and sign up again
2. Remember the password you used
3. Implement password reset feature (future enhancement)

---

## For Development/Testing

If you want to test with fresh accounts:

1. **Delete test user from Firebase Console:**
   - Authentication → Users → Find user → Delete

2. **Sign up again** with new credentials

3. **Document your test credentials** somewhere safe

---

## Security Best Practices

⚠️ **Never commit real passwords to Git!**

For testing:
- Use fake emails like `test@example.com`
- Use simple passwords like `Test123456`
- Don't use your real personal email/password

For production:
- Use real, unique emails
- Use strong passwords (8+ characters, mixed case, numbers, symbols)
- Enable 2FA in Firebase (coming soon)

---

**Last Updated:** October 19, 2025
**Current User:** adityaissc7@gmail.com
