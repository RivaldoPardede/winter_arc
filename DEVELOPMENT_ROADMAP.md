# 🎯 Winter Arc MVP - Development Roadmap

## ✅ Phase 1: Project Foundation (COMPLETED)

### Structure Created
- ✅ Clean folder architecture (models, screens, services, utils, widgets)
- ✅ 4 data models (User, Exercise, WorkoutSet, WorkoutLog)
- ✅ 4 main screens with bottom navigation
- ✅ Winter Arc themed design system
- ✅ Constants and utilities

### Current State
You can now run the app and see:
- Home screen with Winter Arc countdown timer
- Bottom navigation between 4 tabs
- Placeholder screens for Log, Progress, and Group
- Beautiful winter-themed UI

---

## 🚀 Phase 2: Core Functionality (NEXT)

### Priority 1: Workout Logging
**Goal:** Users can log their daily calisthenics workouts

**Tasks:**
1. Create workout logging form in `log_workout_screen.dart`
   - Exercise selection (dropdown or list)
   - Set/rep entry (simple number inputs)
   - Save button
   
2. Implement local storage in `storage_service.dart`
   - Add `shared_preferences` package
   - Save workout logs to device
   - Load workout history

3. Update Home screen to show real data
   - Display today's workout count
   - Show total reps
   - Calculate and display streak

**Estimated Time:** 4-6 hours

---

### Priority 2: Progress Tracking
**Goal:** Users can see their improvement over time

**Tasks:**
1. Display workout history in `progress_screen.dart`
   - List of past workouts (by date)
   - Expandable cards showing details
   
2. Add basic statistics
   - Total workouts this Winter Arc
   - Favorite exercises
   - Personal records

3. Simple progress visualization
   - Weekly workout frequency
   - Exercise volume trends

**Estimated Time:** 3-4 hours

---

### Priority 3: Group Features
**Goal:** 4 friends can see each other's activity

**Tasks:**
1. Create member profiles
   - Add all 4 members manually
   - Simple avatars (initials or icons)

2. Build activity feed in `group_screen.dart`
   - Show recent workouts from all members
   - Format: "John logged 100 push-ups - 2h ago"

3. Data sharing (choose one):
   - **Simple:** Manual export/import JSON files
   - **Better:** Firebase Realtime Database (free tier)
   - **Future:** Custom backend

**Estimated Time:** 4-6 hours

---

## 📦 Required Packages

Add these to `pubspec.yaml` as you implement features:

```yaml
dependencies:
  # For local storage
  shared_preferences: ^2.2.2
  
  # For date formatting
  intl: ^0.19.0
  
  # For charts (optional - Phase 2)
  fl_chart: ^0.66.0
  
  # For Firebase (optional - Phase 3)
  firebase_core: ^2.24.0
  firebase_database: ^10.4.0
  
  # For UUID generation
  uuid: ^4.3.3
```

---

## 💡 Implementation Tips

### Starting with Workout Logging

1. **Simple First Approach:**
```dart
// In log_workout_screen.dart
- Show list of exercises (use Exercise.defaultExercises)
- Tap exercise → Show dialog for sets/reps
- Each entry adds to a list
- "Save Workout" button → Store in SharedPreferences
```

2. **Data Flow:**
```
User Input → WorkoutLog Model → StorageService → SharedPreferences
```

3. **Storage Format:**
```dart
// Store as JSON list
List<Map<String, dynamic>> workoutJsons = 
  logs.map((log) => log.toJson()).toList();
  
prefs.setString('workout_logs', jsonEncode(workoutJsons));
```

### Adding Real Stats

1. **Update Home Screen:**
```dart
// Load today's workouts
final logs = await StorageService().getTodayWorkouts();

// Calculate totals
int totalReps = logs.fold(0, (sum, log) => sum + log.totalReps);
int streak = StatsService.calculateStreak(allLogs);
```

### Group Feed Implementation

**Option A - Local Sharing:**
- Export your data as JSON
- Share file with friends
- Each person imports others' data
- Simple but manual

**Option B - Firebase (Recommended):**
- Free real-time sync
- Each user has a node
- All 4 can read each other's data
- Automatic updates

---

## 🎨 UI Enhancement Ideas

### Quick Wins:
- Add exercise icons (use `Icons` from Material)
- Animated progress bars
- Confetti on workout completion
- Daily motivational quotes

### Polish:
- Pull-to-refresh on screens
- Swipe gestures for quick logging
- Dark mode toggle
- Custom exercise images

---

## 🧪 Testing Strategy

1. **Manual Testing Checklist:**
   - [ ] Can log a workout
   - [ ] Workout appears in history
   - [ ] Stats update correctly
   - [ ] App works offline
   - [ ] Data persists after app restart

2. **Unit Tests:**
   - Test model toJson/fromJson
   - Test stats calculations
   - Test date utilities

3. **Widget Tests:**
   - Test navigation
   - Test form validation
   - Test empty states

---

## 📱 Launch Checklist

Before sharing with your crew:

- [ ] All 4 members can create profiles
- [ ] Workout logging works smoothly
- [ ] Data doesn't get lost
- [ ] App looks good on different screen sizes
- [ ] Basic error handling (empty states, etc.)
- [ ] Clear instructions for first-time users

---

## 🔥 Motivation

Remember: The goal isn't perfection, it's **consistency**. 

Start simple:
1. Get workout logging working (even if ugly)
2. See your data grow each day
3. Iterate and improve

**Winter Arc 2024-2025 - Let's build together!** 💪

---

## 📞 Need Help?

Common issues and solutions:

**Q: Where do I start coding?**
A: Start with `log_workout_screen.dart` - build the form first

**Q: How do I store data?**
A: Use `shared_preferences` package, see `storage_service.dart`

**Q: How to share data with the group?**
A: Start with Firebase Realtime Database (easiest for 4 people)

**Q: App not running?**
A: Run `flutter pub get` then `flutter run`
