import 'package:winter_arc/models/user.dart';
import 'package:winter_arc/models/workout_log.dart';

class GroupMember {
  final User user;
  final List<WorkoutLog> workouts;
  final int currentStreak;
  final int totalWinterArcWorkouts;
  final String? avatarEmoji;

  GroupMember({
    required this.user,
    required this.workouts,
    required this.currentStreak,
    required this.totalWinterArcWorkouts,
    this.avatarEmoji,
  });

  // Computed properties
  int get totalReps {
    return workouts.fold<int>(0, (sum, workout) {
      return sum + workout.totalReps;
    });
  }

  int get totalSets {
    return workouts.fold<int>(0, (sum, workout) {
      return sum + workout.totalSets;
    });
  }

  int get totalWorkouts => workouts.length;

  // Get favorite exercise (most performed)
  String? get favoriteExercise {
    if (workouts.isEmpty) return null;

    final exerciseCounts = <String, int>{};
    for (var workout in workouts) {
      for (var exercise in workout.exercises) {
        final name = exercise.exercise.name;
        exerciseCounts[name] = (exerciseCounts[name] ?? 0) + 1;
      }
    }

    if (exerciseCounts.isEmpty) return null;

    return exerciseCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Get recent workouts (last 5)
  List<WorkoutLog> get recentWorkouts {
    final sorted = List<WorkoutLog>.from(workouts);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  // Get last workout date
  DateTime? get lastWorkoutDate {
    if (workouts.isEmpty) return null;
    return workouts
        .map((w) => w.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  // Check if worked out today
  bool get workedOutToday {
    if (workouts.isEmpty) return false;
    final today = DateTime.now();
    return workouts.any((workout) =>
        workout.date.year == today.year &&
        workout.date.month == today.month &&
        workout.date.day == today.day);
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'workouts': workouts.map((w) => w.toJson()).toList(),
      'currentStreak': currentStreak,
      'totalWinterArcWorkouts': totalWinterArcWorkouts,
      'avatarEmoji': avatarEmoji,
    };
  }

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      user: User.fromJson(json['user']),
      workouts: (json['workouts'] as List)
          .map((w) => WorkoutLog.fromJson(w))
          .toList(),
      currentStreak: json['currentStreak'] ?? 0,
      totalWinterArcWorkouts: json['totalWinterArcWorkouts'] ?? 0,
      avatarEmoji: json['avatarEmoji'],
    );
  }
}
