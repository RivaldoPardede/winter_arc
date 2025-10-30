import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:winter_arc/models/group_member.dart';
import 'package:winter_arc/models/workout_log.dart';
import 'package:winter_arc/services/firestore_service.dart';

class GroupProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  final List<GroupMember> _members = [];
  bool _isLoading = false;
  
  StreamSubscription<List<WorkoutLog>>? _groupWorkoutsSubscription;
  StreamSubscription<List<String>>? _groupMembersSubscription;
  String? _groupId;

  List<GroupMember> get members => _members;
  bool get isLoading => _isLoading;
  String? get groupId => _groupId;

  // Get all group workouts sorted by date
  List<WorkoutLog> get allGroupWorkouts {
    final allWorkouts = <WorkoutLog>[];
    for (var member in _members) {
      allWorkouts.addAll(member.workouts);
    }
    allWorkouts.sort((a, b) => b.date.compareTo(a.date));
    return allWorkouts;
  }

  // Get group stats
  int get totalGroupWorkouts {
    return _members.fold<int>(
      0,
      (sum, member) => sum + member.totalWorkouts,
    );
  }

  int get totalGroupReps {
    return _members.fold<int>(
      0,
      (sum, member) => sum + member.totalReps,
    );
  }

  int get totalGroupSets {
    return _members.fold<int>(
      0,
      (sum, member) => sum + member.totalSets,
    );
  }

  // Get members who worked out today
  List<GroupMember> get activeMembersToday {
    return _members.where((m) => m.workedOutToday).toList();
  }

  // Get leaderboard by total workouts
  List<GroupMember> get leaderboardByWorkouts {
    final sorted = List<GroupMember>.from(_members);
    sorted.sort((a, b) => b.totalWorkouts.compareTo(a.totalWorkouts));
    return sorted;
  }

  // Get leaderboard by current streak
  List<GroupMember> get leaderboardByStreak {
    final sorted = List<GroupMember>.from(_members);
    sorted.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
    return sorted;
  }

  // Get leaderboard by total reps
  List<GroupMember> get leaderboardByReps {
    final sorted = List<GroupMember>.from(_members);
    sorted.sort((a, b) => b.totalReps.compareTo(a.totalReps));
    return sorted;
  }

  // Calculate group streak (consecutive days at least one person worked out)
  int get groupStreak {
    if (allGroupWorkouts.isEmpty) return 0;

    final workoutDates = allGroupWorkouts.map((w) {
      final date = w.date;
      return DateTime(date.year, date.month, date.day);
    }).toSet().toList();

    workoutDates.sort((a, b) => b.compareTo(a));

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
  }

  // Get most popular exercise in group
  String? get mostPopularExercise {
    final exerciseCounts = <String, int>{};
    
    for (var member in _members) {
      for (var workout in member.workouts) {
        for (var exercise in workout.exercises) {
          final name = exercise.exercise.name;
          exerciseCounts[name] = (exerciseCounts[name] ?? 0) + 1;
        }
      }
    }

    if (exerciseCounts.isEmpty) return null;

    return exerciseCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Load mock data
  Future<void> loadMockData(String currentUserId) async {
    // For now, we'll use a hardcoded group ID
    // In production, you'd fetch this from user's profile or group management
    const groupId = 'winter-arc-squad-2025';
    await loadGroupData(groupId, currentUserId);
  }

  /// Load real group data from Firestore with real-time sync
  Future<void> loadGroupData(String groupId, String currentUserId) async {
    _isLoading = true;
    _groupId = groupId;
    notifyListeners();

    // Cancel previous subscriptions
    await _groupWorkoutsSubscription?.cancel();
    await _groupMembersSubscription?.cancel();

    try {
      // For MVP: Use hardcoded member IDs (you + 3 friends)
      // In production: Fetch from groups/{groupId}/memberIds
      final memberIds = await _getGroupMemberIds(groupId, currentUserId);

      // Load member profiles
      final users = await _firestoreService.getUsersByIds(memberIds);

      // Subscribe to all members' workouts in real-time
      _groupWorkoutsSubscription = _firestoreService
          .groupWorkoutsStream(memberIds)
          .listen((allWorkouts) async {
        // Group workouts by user ID
        final workoutsByUser = <String, List<WorkoutLog>>{};
        for (var workout in allWorkouts) {
          workoutsByUser.putIfAbsent(workout.userId, () => []).add(workout);
        }

        // Build group members with their workouts
        _members.clear();
        for (var user in users) {
          final userWorkouts = workoutsByUser[user.id] ?? [];
          
          // Calculate stats
          final streak = await _firestoreService.getWorkoutStreak(user.id);
          final winterArcWorkouts =
              await _firestoreService.getTotalWorkoutsInWinterArc(user.id);

          // Get avatar emoji (for MVP, assign based on user ID)
          final avatarEmoji = _getAvatarEmoji(user.id, currentUserId);

          _members.add(GroupMember(
            user: user,
            workouts: userWorkouts,
            currentStreak: streak,
            totalWinterArcWorkouts: winterArcWorkouts,
            avatarEmoji: avatarEmoji,
          ));
        }

        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error loading group data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get group member IDs (MVP: hardcoded, Production: from Firestore)
  Future<List<String>> _getGroupMemberIds(String groupId, String currentUserId) async {
    // Try to fetch from Firestore first
    final memberIds = await _firestoreService.getGroupMembers(groupId);
    
    if (memberIds.isNotEmpty) {
      return memberIds;
    }

    // For MVP: Return just the current user
    // You'll manually add other user IDs in Firebase Console
    return [currentUserId];
  }

  /// Get avatar emoji for a user (MVP: simple assignment)
  String _getAvatarEmoji(String userId, String currentUserId) {
    if (userId == currentUserId) return '💪';
    
    // For other users, you can set this in their profile
    // For MVP, assign based on hash
    final hash = userId.hashCode % 4;
    const emojis = ['🔥', '⚡', '🌟', '🏆'];
    return emojis[hash];
  }

  // Refresh group data
  Future<void> refresh(String currentUserId) async {
    await loadMockData(currentUserId);
  }

  @override
  void dispose() {
    _groupWorkoutsSubscription?.cancel();
    _groupMembersSubscription?.cancel();
    super.dispose();
  }
}
