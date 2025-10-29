import 'package:winter_arc/models/exercise.dart';
import 'package:winter_arc/models/workout_set.dart';

class WorkoutLog {
  final String id;
  final String userId;
  final DateTime date;
  final List<ExerciseLog> exercises;
  final String? notes;
  final int? duration; // Total workout duration in minutes

  WorkoutLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.exercises,
    this.notes,
    this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
      'duration': duration,
    };
  }

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      duration: json['duration'] as int?,
    );
  }

  WorkoutLog copyWith({
    String? id,
    String? userId,
    DateTime? date,
    List<ExerciseLog>? exercises,
    String? notes,
    int? duration,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      duration: duration ?? this.duration,
    );
  }

  // Calculate total reps across all exercises
  int get totalReps {
    return exercises.fold(0, (sum, exercise) {
      return sum + exercise.sets.fold(0, (setSum, set) => setSum + set.reps);
    });
  }

  // Calculate total sets across all exercises
  int get totalSets {
    return exercises.fold(0, (sum, exercise) => sum + exercise.sets.length);
  }
}

class ExerciseLog {
  final Exercise exercise;
  final List<WorkoutSet> sets;

  ExerciseLog({
    required this.exercise,
    required this.sets,
  });

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'sets': sets.map((s) => s.toJson()).toList(),
    };
  }

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    return ExerciseLog(
      exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
      sets: (json['sets'] as List)
          .map((s) => WorkoutSet.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  // Calculate total reps for this exercise
  int get totalReps {
    return sets.fold(0, (sum, set) => sum + set.reps);
  }
}
