# Winter Arc 🏔️💪

A mobile app for tracking calisthenics progress during the Winter Arc period (November - February). Built with Flutter for a small group of 4 friends committed to self-improvement through fitness.

## 📱 About

Winter Arc is inspired by the social media movement encouraging men to focus on self-improvement during winter months. This app helps our 4-person calisthenics crew track workouts, monitor progress, and stay motivated together.

**Winter Arc Period:** November 1, 2024 - February 28, 2025

## 🎯 MVP Features

### ✅ Implemented
- **Project Structure** - Clean architecture with organized folders
- **Data Models** - User, Exercise, WorkoutLog, WorkoutSet
- **Navigation** - Bottom navigation with 4 main screens
- **Theme** - Winter-themed color palette (deep blues, ice accents)
- **Home Screen** - Winter Arc countdown timer and daily summary
- **Placeholder Screens** - Log, Progress, and Group views

### 🚧 Coming Soon
- Workout logging functionality
- Progress tracking and charts
- Group activity feed
- Streak tracking
- Personal statistics
- Local data persistence

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point with navigation
├── models/                   # Data models
│   ├── user.dart            # User profile model
│   ├── exercise.dart        # Exercise types and definitions
│   ├── workout_set.dart     # Individual set data (reps, duration)
│   └── workout_log.dart     # Complete workout with exercises
├── screens/                  # UI screens
│   ├── home/                # Home screen with Winter Arc timer
│   ├── log_workout/         # Workout logging interface
│   ├── progress/            # Personal progress & stats
│   └── group/               # Group activity feed
├── widgets/                  # Reusable UI components
├── services/                 # Business logic & data services
└── utils/                    # Utilities & constants
    ├── constants.dart       # App constants & Winter Arc dates
    └── theme.dart           # App theme (light & dark mode)
```

## 🎨 Design Philosophy

- **Winter-themed colors** - Deep blues, ice accents, snow white
- **Clean & minimal** - Focus on quick workout logging
- **Offline-first** - Works without internet connection
- **Group accountability** - See what your squad is doing

## 🏋️ Supported Exercises

The app comes with 10 pre-defined calisthenics exercises:
- Push-ups
- Pull-ups
- Squats
- Dips
- Lunges
- Plank
- Handstand Push-ups
- Muscle-ups
- Pistol Squats
- L-Sit

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.0 or higher
- Dart 3.0 or higher

### Installation

1. Clone the repository
```bash
git clone <your-repo-url>
cd winter_arc
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## 📊 Data Models

### User
- ID, name, avatar, join date

### Exercise
- Predefined types + custom exercises
- Name, description, category

### WorkoutSet
- Reps, duration (for time-based exercises)
- Optional notes

### WorkoutLog
- Date, user, list of exercises
- Total duration, notes
- Calculated stats (total reps, total sets)

## 🎯 Next Steps

1. **Implement Workout Logging**
   - Add exercise selection UI
   - Set/rep entry interface
   - Save to local storage

2. **Build Progress Tracking**
   - Display workout history
   - Charts for exercise progress
   - Streak calculation

3. **Create Group Features**
   - Activity feed
   - Simple data sharing
   - Member profiles

4. **Add Persistence**
   - Local storage (SharedPreferences/SQLite)
   - Optional Firebase sync

## 🤝 Team

4-person calisthenics crew committed to the Winter Arc journey.

## 📝 License

Private project for personal use.

---

**Stay Strong. Stay Consistent. Winter Arc 2024-2025** 🔥
