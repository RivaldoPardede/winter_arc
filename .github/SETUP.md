# GitHub Actions Setup Guide

This guide will help you configure GitHub Secrets for automated builds and deployments.

## 🔑 Required Secrets

### 1. GOOGLE_SERVICES_JSON (for Android builds)

**What:** Your Firebase Android configuration file encoded as base64

**How to create:**
```bash
# On Windows PowerShell:
cd android/app
$content = Get-Content -Path google-services.json -Raw
$bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
$base64 = [Convert]::ToBase64String($bytes)
$base64 | Set-Clipboard
```

**How to add:**
1. Go to your repo: Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `GOOGLE_SERVICES_JSON`
4. Value: Paste the base64 string from your clipboard
5. Click "Add secret"

### 2. FIREBASE_SERVICE_ACCOUNT (for web deployment)

**What:** Firebase service account JSON for deploying to Firebase Hosting

**How to create:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (winter-arc-ea2c3)
3. Click ⚙️ (Settings) → Project settings
4. Go to "Service accounts" tab
5. Click "Generate new private key"
6. Download the JSON file
7. Copy the entire contents of the JSON file

**How to add:**
1. Go to your repo: Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `FIREBASE_SERVICE_ACCOUNT`
4. Value: Paste the entire JSON content
5. Click "Add secret"

## 📋 Verification

After adding the secrets, you should see:
- ✅ GOOGLE_SERVICES_JSON
- ✅ FIREBASE_SERVICE_ACCOUNT
- ✅ GITHUB_TOKEN (automatically provided by GitHub)

## 🚀 How to Use

### Automatic Builds (on every push to main)
- Push to `main` branch → Builds Android + Web
- Web automatically deploys to Firebase Hosting
- Artifacts available in Actions tab for 30 days

### Release Builds (create a new release)
```bash
# Tag your commit
git tag v1.0.0
git push origin v1.0.0
```
- Creates a GitHub Release with:
  - ✅ Android APK file
  - ✅ Web build ZIP file
  - ✅ Release notes

### Manual Builds
1. Go to Actions tab
2. Select "Build and Release" workflow
3. Click "Run workflow"
4. Select branch
5. Click "Run workflow"

## 🔍 Pull Request Checks

Every PR will automatically:
- ✅ Run `flutter analyze`
- ✅ Check code formatting
- ✅ Run tests
- ✅ Verify Android builds
- ✅ Verify Web builds

## 📱 Testing Builds

### Android APK
1. Go to Actions tab
2. Click on the latest successful workflow
3. Download "winter-arc-android" artifact
4. Unzip and install APK on your device

### Web Build
1. Go to Actions tab
2. Click on the latest successful workflow
3. Download "winter-arc-web" artifact
4. Unzip and deploy:
   ```bash
   unzip winter-arc-web.zip -d build/web
   firebase deploy --only hosting
   ```

## 🛠️ Troubleshooting

### Build fails with "google-services.json not found"
- Check GOOGLE_SERVICES_JSON secret is set correctly
- Make sure it's base64 encoded

### Web deployment fails
- Check FIREBASE_SERVICE_ACCOUNT secret is set
- Verify Firebase project ID in workflow file matches your project

### Wrong Flutter version
- Update `flutter-version` in workflow files to match your local version
- Run `flutter --version` locally to check

## 🔐 Security Notes

- ⚠️ Never commit service account JSON files
- ⚠️ Never commit google-services.json
- ✅ These files are automatically excluded by .gitignore
- ✅ GitHub Secrets are encrypted and only accessible during workflow runs
- ✅ Secrets are never exposed in logs

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [Firebase Hosting GitHub Action](https://github.com/FirebaseExtended/action-hosting-deploy)
