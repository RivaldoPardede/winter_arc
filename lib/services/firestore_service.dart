import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:winter_arc/models/user.dart';
import 'package:winter_arc/models/workout_log.dart';
import 'package:winter_arc/utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _workoutsCollection => _firestore.collection('workouts');
  CollectionReference get _groupsCollection => _firestore.collection('groups');

  // ==================== USER OPERATIONS ====================

  /// Create or update user profile
  Future<void> saveUser(User user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toJson());
    } catch (e) {
      debugPrint('Error saving user: $e');
      rethrow;
    }
  }

  /// Get user by ID
  Future<User?> getUser(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return User.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      rethrow;
    }
  }

  /// Stream user data (real-time)
  Stream<User?> userStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return User.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // ==================== WORKOUT OPERATIONS ====================

  /// Save workout log
  Future<void> saveWorkoutLog(WorkoutLog workout) async {
    try {
      await _workoutsCollection.doc(workout.id).set(workout.toJson());
    } catch (e) {
      debugPrint('Error saving workout: $e');
      rethrow;
    }
  }

  /// Get all workouts for a user
  Future<List<WorkoutLog>> getWorkoutLogs(String userId) async {
    try {
      final querySnapshot = await _workoutsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => WorkoutLog.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting workouts: $e');
      return [];
    }
  }

  /// Stream all workouts for a user (real-time)
  Stream<List<WorkoutLog>> workoutsStream(String userId) {
    return _workoutsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkoutLog.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get today's workouts
  Future<List<WorkoutLog>> getTodayWorkouts(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _workoutsCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .get();

      return querySnapshot.docs
          .map((doc) => WorkoutLog.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting today workouts: $e');
      return [];
    }
  }

  /// Update workout log
  Future<void> updateWorkoutLog(WorkoutLog workout) async {
    try {
      await _workoutsCollection.doc(workout.id).update(workout.toJson());
    } catch (e) {
      debugPrint('Error updating workout: $e');
      rethrow;
    }
  }

  /// Delete workout log
  Future<void> deleteWorkoutLog(String workoutId) async {
    try {
      await _workoutsCollection.doc(workoutId).delete();
    } catch (e) {
      debugPrint('Error deleting workout: $e');
      rethrow;
    }
  }

  /// Calculate workout streak
  Future<int> getWorkoutStreak(String userId) async {
    try {
      final workouts = await getWorkoutLogs(userId);
      if (workouts.isEmpty) return 0;

      // Get unique workout dates
      final workoutDates = workouts.map((w) {
        final date = w.date;
        return DateTime(date.year, date.month, date.day);
      }).toSet().toList();

      workoutDates.sort((a, b) => b.compareTo(a)); // Sort descending

      int streak = 0;
      var currentDate = DateTime.now();
      currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

      for (var date in workoutDates) {
        if (date.isAtSameMomentAs(currentDate) ||
            date.isAtSameMomentAs(currentDate.subtract(Duration(days: streak)))) {
          streak++;
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      debugPrint('Error calculating streak: $e');
      return 0;
    }
  }

  /// Get total workouts in Winter Arc period
  Future<int> getTotalWorkoutsInWinterArc(String userId) async {
    try {
      final querySnapshot = await _workoutsCollection
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: AppConstants.winterArcStart.toIso8601String())
          .where('date', isLessThanOrEqualTo: AppConstants.winterArcEnd.toIso8601String())
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting Winter Arc workouts: $e');
      return 0;
    }
  }

  // ==================== GROUP OPERATIONS ====================

  /// Get all members of a group
  Future<List<String>> getGroupMembers(String groupId) async {
    try {
      final doc = await _groupsCollection.doc(groupId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['memberIds'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting group members: $e');
      return [];
    }
  }

  /// Stream group members (real-time)
  Stream<List<String>> groupMembersStream(String groupId) {
    return _groupsCollection.doc(groupId).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['memberIds'] ?? []);
      }
      return [];
    });
  }

  /// Get all workouts from group members
  Stream<List<WorkoutLog>> groupWorkoutsStream(List<String> memberIds) {
    if (memberIds.isEmpty) {
      return Stream.value([]);
    }

    return _workoutsCollection
        .where('userId', whereIn: memberIds)
        .orderBy('date', descending: true)
        .limit(50) // Limit to recent 50 workouts
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkoutLog.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Get multiple users by IDs
  Future<List<User>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    try {
      final users = <User>[];
      
      // Firestore 'in' query limit is 10, so batch if needed
      for (int i = 0; i < userIds.length; i += 10) {
        final batch = userIds.skip(i).take(10).toList();
        final querySnapshot = await _usersCollection
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        users.addAll(
          querySnapshot.docs.map(
            (doc) => User.fromJson(doc.data() as Map<String, dynamic>),
          ),
        );
      }

      return users;
    } catch (e) {
      debugPrint('Error getting users: $e');
      return [];
    }
  }

  /// Stream multiple users (real-time)
  Stream<List<User>> usersStream(List<String> userIds) {
    if (userIds.isEmpty) {
      return Stream.value([]);
    }

    // For simplicity with small groups, query all at once
    // For groups > 10, you'd need to batch this
    return _usersCollection
        .where(FieldPath.documentId, whereIn: userIds.take(10).toList())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => User.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Create a group (for future use)
  Future<void> createGroup(String groupId, String groupName, List<String> memberIds) async {
    try {
      await _groupsCollection.doc(groupId).set({
        'name': groupName,
        'memberIds': memberIds,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating group: $e');
      rethrow;
    }
  }

  /// Add member to group (for future use)
  Future<void> addMemberToGroup(String groupId, String userId) async {
    try {
      await _groupsCollection.doc(groupId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      debugPrint('Error adding member to group: $e');
      rethrow;
    }
  }
}
