# Firebase Setup Guide for Winter Arc

This guide will help you set up Firebase for your Winter Arc app with 4 users.

## Prerequisites

✅ Firebase project created: `winter-arc`  
✅ Email/Password authentication enabled  
✅ Cloud Firestore in test mode enabled  
✅ FlutterFire CLI configured (`firebase_options.dart` generated)  
✅ Dependencies added to `pubspec.yaml`

## Step 1: Create User Accounts

Since this is a private app for 4 people, you'll create users manually in the Firebase Console.

### 1.1 Open Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your `winter-arc` project
3. Navigate to **Authentication** > **Users** tab

### 1.2 Add 4 Users

Click **Add user** for each person and enter their:
- **Email**: Their actual email address
- **Password**: A temporary password (they can't change it in the app yet)

Example users:
```
User 1: alex@example.com (password: WinterArc2025!)
User 2: jamie@example.com (password: WinterArc2025!)
User 3: sam@example.com (password: WinterArc2025!)
User 4: you@example.com (password: WinterArc2025!)
```

**Important:** Copy the User IDs (UIDs) after creating each user. You'll need them in the next step.

## Step 2: Create User Profiles in Firestore

Each user needs a profile document in the `users` collection.

### 2.1 Open Firestore

1. In Firebase Console, navigate to **Firestore Database**
2. Click **Start collection**

### 2.2 Create `users` Collection

For each user you created, add a document:

1. **Collection ID**: `users`
2. **Document ID**: Use the User ID (UID) from Authentication
3. **Fields**:
   ```
   id: <USER_ID> (string)
   name: "Alex" (string)
   joinedDate: <SELECT_TIMESTAMP> (timestamp)
   ```

Repeat for all 4 users with different names.

Example structure:
```
users/
  ├── abc123def456 (User ID from Auth)
  │   ├── id: "abc123def456"
  │   ├── name: "Alex"
  │   └── joinedDate: November 1, 2024
  ├── ghi789jkl012
  │   ├── id: "ghi789jkl012"
  │   ├── name: "Jamie"
  │   └── joinedDate: November 1, 2024
  ├── mno345pqr678
  │   ├── id: "mno345pqr678"
  │   ├── name: "Sam"
  │   └── joinedDate: November 1, 2024
  └── stu901vwx234
      ├── id: "stu901vwx234"
      ├── name: "You"
      └── joinedDate: November 1, 2024
```

## Step 3: Create the Winter Arc Squad Group

Create a group document to link all 4 users together.

### 3.1 Create `groups` Collection

1. **Collection ID**: `groups`
2. **Document ID**: `winter-arc-squad-2025` (hardcoded in the app)
3. **Fields**:
   ```
   id: "winter-arc-squad-2025" (string)
   name: "Winter Arc Squad" (string)
   memberIds: [array of User IDs] (array)
   createdDate: <SELECT_TIMESTAMP> (timestamp)
   ```

Example:
```
groups/
  └── winter-arc-squad-2025
      ├── id: "winter-arc-squad-2025"
      ├── name: "Winter Arc Squad"
      ├── memberIds: ["abc123def456", "ghi789jkl012", "mno345pqr678", "stu901vwx234"]
      └── createdDate: November 1, 2024
```

**Important:** The `memberIds` array must contain all 4 User IDs from Step 1.

## Step 4: Firestore Security Rules (Optional for MVP)

Your Firestore is currently in **test mode**, which allows all reads/writes. This is fine for MVP testing with just 4 people.

For production (after Winter Arc ends), update security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User can read/write their own profile
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Anyone authenticated can read workouts (for group features)
    // Only owner can write their workouts
    match /workouts/{workoutId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
    
    // Anyone in the group can read group data
    match /groups/{groupId} {
      allow read: if request.auth != null;
      allow write: if false; // Groups managed manually
    }
  }
}
```

## Step 5: Test the App

### 5.1 Run the App

```bash
flutter run
```

### 5.2 Test Login

1. You should see the login screen
2. Enter one of the email/password combinations
3. You should be redirected to the home screen

### 5.3 Verify Data

1. **Home Screen**: Check that workout stats load
2. **Group Screen**: Check that all 4 members appear
3. **Add Workout**: Add a workout and verify it appears in:
   - Home screen stats
   - Progress screen
   - Group screen activity feed

### 5.4 Test Real-Time Sync

1. Log in on 2 different devices (or emulators) with different users
2. Add a workout on Device 1
3. Switch to **Group** tab on Device 2
4. The new workout should appear in the activity feed automatically! 🎉

## Troubleshooting

### "No users found" or empty group screen

**Problem**: The group document doesn't exist or memberIds array is empty.

**Solution**:
1. Check Firestore Console → `groups/winter-arc-squad-2025`
2. Verify `memberIds` array contains all 4 User IDs
3. Verify each User ID exists in `users` collection

### Login fails with "invalid-credential"

**Problem**: Email/password doesn't match what's in Firebase Auth.

**Solution**:
1. Check Firebase Console → Authentication → Users
2. Verify the email exists
3. Try resetting the password in Firebase Console

### Workouts not syncing in real-time

**Problem**: StreamSubscription might not be active.

**Solution**:
1. Check Flutter logs for errors
2. Verify Firestore rules allow reads
3. Try hot restart (not just hot reload)

### "Permission denied" errors

**Problem**: Firestore security rules are blocking access.

**Solution**:
1. For MVP, keep test mode enabled (expires in 30 days)
2. Extend test mode deadline or implement proper rules
3. Check Console → Firestore → Rules tab

## Data Structure Reference

### Firestore Collections

```
firestore/
├── users/                  # User profiles
│   └── {userId}/
│       ├── id: string
│       ├── name: string
│       └── joinedDate: timestamp
│
├── workouts/              # All workout logs
│   └── {workoutId}/
│       ├── id: string
│       ├── userId: string
│       ├── date: timestamp
│       └── exercises: array
│           └── {
│               exercise: {
│                 id: string
│                 type: string
│                 name: string
│               }
│               sets: array
│                 └── {
│                     reps: number
│                     weight: number (optional)
│                   }
│             }
│
└── groups/                # Group configurations
    └── {groupId}/
        ├── id: string
        ├── name: string
        ├── memberIds: array<string>
        └── createdDate: timestamp
```

### Authentication

- **Provider**: Email/Password only
- **No self-registration**: Users created manually by admin
- **Password reset**: Not implemented (share new password manually)

## Next Steps

After Firebase is set up and tested:

1. ✅ Add logout button to UI
2. ✅ Test with all 4 users
3. ✅ Monitor Firestore usage in Console
4. ✅ Update security rules before Winter Arc ends (Feb 2025)
5. ✅ Consider adding password reset flow
6. ✅ Consider adding user profile editing

## Support

If you encounter issues:

1. Check Flutter console logs for errors
2. Check Firebase Console → Firestore → Usage tab for errors
3. Verify all User IDs match between Auth and Firestore
4. Try clearing app data and logging in again

---

**Happy Winter Arc! 💪❄️**
