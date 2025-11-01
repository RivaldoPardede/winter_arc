# Security Best Practices - Winter Arc

## 🔒 **Sensitive Files (Never Commit These!)**

The following files contain API keys, credentials, and secrets. **They are gitignored for security:**

### **Firebase Configuration Files:**
- `android/app/google-services.json` - Android Firebase config with API keys
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase config
- `.firebaserc` - ✅ Safe to commit (only contains project ID)
- `firebase.json` - ✅ Safe to commit (hosting/deployment config)

### **How to Set Up Firebase Config (For Team Members):**

1. **Download from Firebase Console:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select project: `winter-arc-e143c`
   - Project Settings → General → Your apps

2. **For Android:**
   - Download `google-services.json`
   - Place in: `android/app/google-services.json`

3. **For iOS:**
   - Download `GoogleService-Info.plist`
   - Place in: `ios/Runner/GoogleService-Info.plist`

## 📝 **What's Safe to Commit:**

✅ **Safe Files:**
- All source code in `lib/`
- `pubspec.yaml` (dependencies)
- `firebase.json` (deployment config)
- `.firebaserc` (project ID only)
- `firestore.rules` (security rules)
- `firestore.indexes.json` (database indexes)

❌ **NEVER Commit:**
- `google-services.json`
- `GoogleService-Info.plist`
- Any `.env` files
- `*.keystore`, `*.jks` (signing keys)
- Service account JSON files
- API keys or secrets

## 🚨 **If You Accidentally Committed Secrets:**

1. **Immediately rotate the keys** in Firebase Console
2. **Remove from git history:**
   ```bash
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch android/app/google-services.json" \
     --prune-empty --tag-name-filter cat -- --all
   ```
3. **Force push** (if working alone) or contact team

## 📚 **Documentation:**

Internal development docs are in `docs/` directory and are gitignored.
Only `README.md` (main project readme) is committed to the repository.
