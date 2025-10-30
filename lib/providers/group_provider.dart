import 'package:flutter/foundation.dart';
import 'package:winter_arc/models/group_member.dart';
import 'package:winter_arc/models/user.dart';
import 'package:winter_arc/models/workout_log.dart';
import 'package:winter_arc/models/exercise.dart';
import 'package:winter_arc/models/workout_set.dart';
import 'package:uuid/uuid.dart';

class GroupProvider extends ChangeNotifier {
  final List<GroupMember> _members = [];
  bool _isLoading = false;

  List<GroupMember> get members => _members;
  bool get isLoading => _isLoading;

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
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _members.clear();

    // Create 4 mock members with diverse data
    final mockMembers = _generateMockMembers(currentUserId);
    _members.addAll(mockMembers);

    _isLoading = false;
    notifyListeners();
  }

  List<GroupMember> _generateMockMembers(String currentUserId) {
    final now = DateTime.now();

    // Member 1: You (Current user) - Will be replaced with real data
    final member1 = GroupMember(
      user: User(
        id: currentUserId,
        name: 'You',
        joinedDate: DateTime(2025, 10, 25),
      ),
      workouts: [], // Will show real workouts
      currentStreak: 0,
      totalWinterArcWorkouts: 0,
      avatarEmoji: '💪',
    );

    // Member 2: Alex - The Consistent One
    final member2Workouts = <WorkoutLog>[
      _createMockWorkout(
        'user-alex',
        now.subtract(const Duration(days: 0)),
        ['Pull-ups', 'Push-ups'],
        [[12, 10, 8], [20, 18, 15]],
      ),
      _createMockWorkout(
        'user-alex',
        now.subtract(const Duration(days: 1)),
        ['Dips', 'Squats'],
        [[15, 12, 10], [25, 20, 20]],
      ),
      _createMockWorkout(
        'user-alex',
        now.subtract(const Duration(days: 2)),
        ['Pull-ups', 'Handstand Push-ups'],
        [[10, 9, 8], [12, 10, 10]],
      ),
      _createMockWorkout(
        'user-alex',
        now.subtract(const Duration(days: 3)),
        ['Push-ups', 'Squats', 'Plank'],
        [[25, 22, 20], [30, 28, 25], [60, 50, 45]],
      ),
      _createMockWorkout(
        'user-alex',
        now.subtract(const Duration(days: 5)),
        ['Pull-ups', 'Dips'],
        [[11, 10, 9], [14, 13, 12]],
      ),
    ];

    final member2 = GroupMember(
      user: User(
        id: 'user-alex',
        name: 'Alex',
        joinedDate: DateTime(2025, 10, 20),
      ),
      workouts: member2Workouts,
      currentStreak: 4,
      totalWinterArcWorkouts: 5,
      avatarEmoji: '🔥',
    );

    // Member 3: Jamie - The Power Lifter
    final member3Workouts = <WorkoutLog>[
      _createMockWorkout(
        'user-jamie',
        now.subtract(const Duration(days: 1)),
        ['Pull-ups', 'Dips', 'L-Sit'],
        [[15, 14, 13], [18, 16, 15], [30, 25, 20]],
      ),
      _createMockWorkout(
        'user-jamie',
        now.subtract(const Duration(days: 3)),
        ['Push-ups', 'Pistol Squats'],
        [[30, 28, 25], [10, 9, 8]],
      ),
      _createMockWorkout(
        'user-jamie',
        now.subtract(const Duration(days: 4)),
        ['Muscle-ups', 'Plank'],
        [[5, 4, 3], [80, 70, 60]],
      ),
    ];

    final member3 = GroupMember(
      user: User(
        id: 'user-jamie',
        name: 'Jamie',
        joinedDate: DateTime(2025, 10, 22),
      ),
      workouts: member3Workouts,
      currentStreak: 2,
      totalWinterArcWorkouts: 3,
      avatarEmoji: '⚡',
    );

    // Member 4: Sam - The Beginner
    final member4Workouts = <WorkoutLog>[
      _createMockWorkout(
        'user-sam',
        now.subtract(const Duration(days: 0)),
        ['Push-ups', 'Squats'],
        [[10, 8, 7], [15, 12, 10]],
      ),
      _createMockWorkout(
        'user-sam',
        now.subtract(const Duration(days: 2)),
        ['Push-ups', 'Pull-ups'],
        [[15, 12, 10], [5, 4, 3]],
      ),
    ];

    final member4 = GroupMember(
      user: User(
        id: 'user-sam',
        name: 'Sam',
        joinedDate: DateTime(2025, 10, 28),
      ),
      workouts: member4Workouts,
      currentStreak: 1,
      totalWinterArcWorkouts: 2,
      avatarEmoji: '🌟',
    );

    return [member1, member2, member3, member4];
  }

  WorkoutLog _createMockWorkout(
    String userId,
    DateTime date,
    List<String> exerciseNames,
    List<List<int>> repsList,
  ) {
    const uuid = Uuid();
    final exerciseLogs = <ExerciseLog>[];

    // Map of exercise names to their types
    final exerciseMap = {
      'Push-ups': ExerciseType.pushUps,
      'Pull-ups': ExerciseType.pullUps,
      'Squats': ExerciseType.squats,
      'Dips': ExerciseType.dips,
      'Lunges': ExerciseType.lunges,
      'Plank': ExerciseType.plank,
      'Handstand Push-ups': ExerciseType.handstandPushUps,
      'Muscle-ups': ExerciseType.muscleUps,
      'Pistol Squats': ExerciseType.pistolSquats,
      'L-Sit': ExerciseType.lSit,
    };

    for (int i = 0; i < exerciseNames.length; i++) {
      final sets = repsList[i].map((reps) {
        return WorkoutSet(reps: reps);
      }).toList();

      final exerciseName = exerciseNames[i];
      final exerciseType = exerciseMap[exerciseName] ?? ExerciseType.other;

      final exercise = Exercise(
        id: uuid.v4(),
        type: exerciseType,
        name: exerciseName,
      );

      exerciseLogs.add(ExerciseLog(
        exercise: exercise,
        sets: sets,
      ));
    }

    return WorkoutLog(
      id: uuid.v4(),
      userId: userId,
      date: date,
      exercises: exerciseLogs,
    );
  }

  // Update current user's data from WorkoutProvider
  void updateCurrentUserData(
    String userId,
    List<WorkoutLog> workouts,
    int streak,
    int winterArcWorkouts,
  ) {
    final index = _members.indexWhere((m) => m.user.id == userId);
    if (index != -1) {
      _members[index] = GroupMember(
        user: _members[index].user,
        workouts: workouts,
        currentStreak: streak,
        totalWinterArcWorkouts: winterArcWorkouts,
        avatarEmoji: _members[index].avatarEmoji,
      );
      notifyListeners();
    }
  }

  // Refresh group data
  Future<void> refresh(String currentUserId) async {
    await loadMockData(currentUserId);
  }
}
