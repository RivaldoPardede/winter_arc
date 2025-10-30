# Quick Start: Firebase Setup

This is a quick reference guide to get your Winter Arc app up and running with Firebase.

## Step 1: Create Users (5 minutes)

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Go to **Authentication** > **Users**
3. Click **Add user** for each person

**Example users:**
```
alex@example.com    → Password: WinterArc2025!
jamie@example.com   → Password: WinterArc2025!
sam@example.com     → Password: WinterArc2025!
you@example.com     → Password: WinterArc2025!
```

📝 **Copy each User ID (UID) - you'll need them next!**

## Step 2: Create User Profiles (5 minutes)

1. Go to **Firestore Database**
2. Click **Start collection** → Collection ID: `users`

For each user:
- **Document ID**: Paste the User ID from Step 1
- Add fields:
  ```
  id: <paste User ID>
  name: "Alex"
  joinedDate: <click calendar icon, select today>
  ```

## Step 3: Create Group (2 minutes)

1. In Firestore, click **Start collection** → Collection ID: `groups`
2. **Document ID**: `winter-arc-squad-2025`
3. Add fields:
   ```
   id: "winter-arc-squad-2025"
   name: "Winter Arc Squad"
   memberIds: [array - paste all 4 User IDs]
   createdDate: <click calendar icon, select today>
   ```

**memberIds array example:**
```
[
  "abc123def456",
  "ghi789jkl012", 
  "mno345pqr678",
  "stu901vwx234"
]
```

## Step 4: Test the App

```bash
flutter run
```

1. Login with one of the emails
2. Add a workout
3. Check it appears in:
   - Home screen
   - Progress screen
   - Group screen

## Step 5: Test Real-Time Sync

1. Login on 2 devices with different users
2. Add workout on Device 1
3. Switch to Group tab on Device 2
4. Workout should appear automatically! 🎉

## Troubleshooting

### "No users found" in group screen

**Fix**: Check `groups/winter-arc-squad-2025` → `memberIds` array contains all User IDs

### Login fails

**Fix**: Check email/password in Firebase Console → Authentication → Users

### Permission denied

**Fix**: Check Firestore → Rules → Ensure test mode is enabled

## That's it!

For detailed setup, see **FIREBASE_SETUP.md**

For migration details, see **FIREBASE_MIGRATION_SUMMARY.md**

---

**Happy Winter Arc! 💪❄️**
