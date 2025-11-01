# ❄️ Winter Arc

[![Build and Release](https://github.com/RivaldoPardede/winter_arc/workflows/Build%20and%20Release/badge.svg)](https://github.com/RivaldoPardede/winter_arc/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.35.1-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)

> **Transform your winter into your strongest season.** A comprehensive fitness tracking app designed to help you and your squad crush goals during the Winter Arc challenge — **120 days of discipline and growth** (November 1 - February 28).

> **🔒 Private App:** This app is exclusively for Winter Arc squad members. To join and get access, please [contact Rivaldo](#-support).

---

## 🌟 Features

### 💪 Core Workout Tracking
- **Customizable Exercises** - Create and manage your own exercise library
- **Workout Logging** - Track sets, reps, and weights with ease
- **Progress Analytics** - Visualize your strength gains over time
- **Workout History** - Never lose track of your training journey

### 👥 Squad System
- **Create or Join Squads** - Train together, grow together
- **Real-time Notifications** - Get notified when squad members complete workouts
- **Squad Leaderboards** - Friendly competition to keep you motivated

### 🔔 Smart Notifications
- **Daily Reminders** - Never miss a workout with customizable notifications
- **Squad Activity Alerts** - Stay motivated when your teammates crush it
- **One notification per day per user** - No spam, just motivation

### 📊 Progress Tracking
- **Visual Analytics** - Charts and graphs to see your improvements
- **Personal Records** - Track your best lifts and achievements
- **120-Day Challenge** - Dedicated Winter Arc challenge tracking (Nov 1 - Feb 28)
- **Export Data** - Download your workout history anytime

### 🔐 Security & Privacy
- **Firebase Authentication** - Secure email/password login
- **Cloud Sync** - Your data safe across all devices
- **Privacy First** - Your workout data is yours alone
- **Offline Support** - Log workouts without internet

---

## 🚀 Quick Start

### 📱 For Users

#### Android
1. Download the latest APK from [Releases](https://github.com/RivaldoPardede/winter_arc/releases)
2. Install on your Android device (Android 10+)
3. **Contact Rivaldo to create your account** - This app is for Winter Arc members only
4. Log in with your credentials and start tracking!

#### Web
1. Visit: **[winter-arc-e143c.web.app](https://winter-arc-e143c.web.app)**
2. **Contact Rivaldo to create your account** - This app is for Winter Arc members only
3. Log in and start your journey!

#### Web
Visit the live app: **[winter-arc-e143c.web.app](https://winter-arc-e143c.web.app)**

#### iOS
Coming soon! Web version works great on mobile Safari in the meantime.

### 👨‍💻 For Developers

#### Prerequisites
- Flutter SDK 3.35.1 or higher
- Dart SDK 3.5.0 or higher
- Firebase account (for backend services)
- Android Studio / Xcode (for mobile development)

#### Installation

```bash
# Clone the repository
git clone https://github.com/RivaldoPardede/winter_arc.git
cd winter_arc

# Install dependencies
flutter pub get

# Configure Firebase
# 1. Download google-services.json from Firebase Console
# 2. Place in android/app/google-services.json
# 3. Download GoogleService-Info.plist for iOS (if needed)

# Run the app
flutter run
```

#### Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Authentication (Email/Password)
3. Enable Firestore Database
4. Enable Firebase Cloud Messaging (FCM)
5. Download configuration files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/` (iOS only)

**Important:** Never commit these files! They're in `.gitignore`.

#### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# Web (with WebAssembly)
flutter build web --release --wasm

# iOS (requires macOS)
flutter build ios --release
```

---

## 🏗️ Tech Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **Go Router** - Navigation and deep linking
- **Flutter Local Notifications** - Push notifications

### Backend
- **Firebase Authentication** - User management
- **Cloud Firestore** - Real-time database
- **Firebase Cloud Messaging** - Push notifications
- **Firebase Hosting** - Web deployment

### DevOps
- **GitHub Actions** - CI/CD automation
- **Firebase CLI** - Deployment automation
- **Automated Builds** - Android & Web on every push
- **Automated Releases** - APK distribution on tags

---

## 📁 Project Structure

```
winter_arc/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   ├── user_model.dart
│   │   ├── workout_model.dart
│   │   └── exercise_model.dart
│   ├── providers/                # State management
│   │   ├── user_provider.dart
│   │   ├── workout_provider.dart
│   │   └── exercise_provider.dart
│   ├── screens/                  # UI screens
│   │   ├── auth/
│   │   ├── home/
│   │   ├── workout/
│   │   └── profile/
│   ├── services/                 # Business logic
│   │   ├── firebase_service.dart
│   │   ├── fcm_service.dart
│   │   └── notification_service.dart
│   └── widgets/                  # Reusable components
├── android/                      # Android platform code
├── ios/                          # iOS platform code
├── web/                          # Web platform code
├── .github/
│   └── workflows/               # CI/CD pipelines
├── firebase.json                 # Firebase config
└── pubspec.yaml                 # Dependencies
```

---

## 🔧 Configuration

### Environment Variables

Create `.env` file in the root (never commit this!):

```env
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=winter-arc-e143c
```

### Notification Settings

Configure in `lib/services/notification_service.dart`:
- Daily reminder time
- Notification channels
- Sound and vibration preferences

---

## 🤝 Contributing

We welcome contributions! Here's how:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Commit** your changes: `git commit -m 'Add amazing feature'`
4. **Push** to branch: `git push origin feature/amazing-feature`
5. **Open** a Pull Request

### Development Workflow

- All PRs must pass CI checks (analyze, format, tests)
- Follow Flutter style guide
- Write meaningful commit messages
- Update documentation for new features

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Authors

**Rivaldo Pardede** - *Initial work* - [@RivaldoPardede](https://github.com/RivaldoPardede)

See also the list of [contributors](https://github.com/RivaldoPardede/winter_arc/contributors) who participated in this project.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- The fitness community for inspiration
- Everyone participating in the Winter Arc challenge

---

## 📞 Support

### 🔒 Want to Join Winter Arc?

This app is **exclusively for Winter Arc squad members**. If you want to join the challenge and get access:

- **Contact Rivaldo Pardede** to create your account
- **Email:** rivaldopardede@example.com *(replace with your actual email)*
- **GitHub:** [@RivaldoPardede](https://github.com/RivaldoPardede)

### 💬 For Existing Members

- **Issues:** [GitHub Issues](https://github.com/RivaldoPardede/winter_arc/issues)
- **Discussions:** [GitHub Discussions](https://github.com/RivaldoPardede/winter_arc/discussions)

---

## 🗺️ Roadmap

- [x] Basic workout logging
- [x] Squad system
- [x] Real-time notifications
- [x] Daily reminders
- [x] Web deployment
- [ ] iOS release
- [ ] Google Play Store release
- [ ] Workout templates
- [ ] Social sharing
- [ ] Exercise video tutorials
- [ ] Advanced analytics

---


## ⚡ Performance

- **App Size:** ~15MB (APK)
- **Cold Start:** <2 seconds
- **Hot Reload:** <1 second
- **Web Load:** <3 seconds (with caching)
- **Offline Support:** ✅ Full functionality

---

## 🔐 Security

- All sensitive files are in `.gitignore`
- Firebase security rules properly configured
- User data encrypted in transit
- No API keys exposed in client code
- Regular dependency updates

---

<div align="center">

**Built with ❤️ for the Winter Arc community**

*Transform your winter. Transform yourself.*

[Download APK](https://github.com/RivaldoPardede/winter_arc/releases) • [Try Web App](https://winter-arc-e143c.web.app) • [Report Bug](https://github.com/RivaldoPardede/winter_arc/issues)

</div>
