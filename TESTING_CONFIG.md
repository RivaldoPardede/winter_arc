# Testing Configuration

## ⚠️ IMPORTANT: Temporary Testing Settings

This file tracks temporary configuration changes made for testing and feedback gathering.

### Current Temporary Changes

#### 1. Winter Arc Start Date
- **File**: `lib/utils/constants.dart`
- **Current Value**: `DateTime(2025, 10, 30)` (Oct 30)
- **Production Value**: `DateTime(2025, 11, 1)` (Nov 1)
- **Reason**: Enable testing of all features before official start
- **Status**: ⚠️ **NEEDS TO BE CHANGED BEFORE NOV 1**

## 📅 Pre-Launch Checklist (Before Nov 1, 2025)

- [ ] Change `winterArcStart` back to `DateTime(2025, 11, 1)` in `lib/utils/constants.dart`
- [ ] Verify all test data is cleared from Firestore
- [ ] Test with actual Nov 1 start date
- [ ] Ensure "Not started yet" message appears correctly before Nov 1
- [ ] Verify progress calculations work correctly after Nov 1
- [ ] Check that all 4 users are created in Firebase
- [ ] Verify group setup in Firestore
- [ ] Test on all team members' devices

## 🧪 Testing Period

**Start**: October 30, 2025  
**End**: October 31, 2025  
**Official Launch**: November 1, 2025

## 📝 What This Enables

With the start date set to Oct 30:

✅ **Workout Logging**: Can add workouts immediately  
✅ **Progress Tracking**: Charts and stats will populate  
✅ **Streak Tracking**: Can build streaks for testing  
✅ **Group Features**: Activity feed, leaderboards work  
✅ **Winter Arc Stats**: "Total Winter Arc Workouts" counts  
✅ **Progress Bars**: Show actual progress instead of "Not started"  

## 🎯 Testing Goals

Use this testing period to:

1. **Test Workout Logging**
   - Add various exercises
   - Test different rep/set combinations
   - Verify data saves to Firestore

2. **Test Real-Time Sync**
   - Log workout on Device 1
   - Check if appears on Device 2's group screen
   - Verify streak updates across devices

3. **Test Profile Features**
   - Change display name
   - Change avatar emoji
   - Verify changes appear everywhere

4. **Test Group Features**
   - Check activity feed updates
   - Verify leaderboards rank correctly
   - Test member cards display properly

5. **Gather Feedback**
   - UI/UX feedback from squad
   - Feature requests
   - Bug reports

## 🚨 Before Official Launch (Nov 1)

**CRITICAL STEPS:**

1. **Reset the date in constants.dart:**
   ```dart
   static final DateTime winterArcStart = DateTime(2025, 11, 1);
   ```

2. **Optional: Clear test data** (if you want a fresh start)
   - Delete test workouts from Firestore `workouts/` collection
   - Or keep them if they're from Oct 30-31 as "practice"

3. **Rebuild and redistribute app** with corrected date

4. **Notify your squad** that official tracking starts Nov 1

## 📱 Distribution for Testing

Share the app with your 3 squad members:

1. Build APK: `flutter build apk --release`
2. Share APK file via Google Drive/WhatsApp
3. Each member installs and logs in with their credentials
4. Test real-time sync across all 4 devices

## 🔧 Quick Date Change Reference

**To test as if Winter Arc has started:**
```dart
// lib/utils/constants.dart
static final DateTime winterArcStart = DateTime(2025, 10, 30); // Today
```

**To set back to production:**
```dart
// lib/utils/constants.dart
static final DateTime winterArcStart = DateTime(2025, 11, 1); // Nov 1
```

---

**Last Updated**: October 30, 2025  
**Next Action**: Change start date back on October 31, 2025
