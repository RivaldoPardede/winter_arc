import 'package:winter_arc/models/exercise.dart';

class WorkoutTemplate {
  final String id;
  final String userId;
  final String name;
  final List<ExerciseTemplate> exercises;
  final DateTime createdAt;

  WorkoutTemplate({
    required this.id,
    required this.userId,
    required this.name,
    required this.exercises,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class ExerciseTemplate {
  final Exercise exercise;
  final int numberOfSets;
  final int targetReps; // Suggested reps per set

  ExerciseTemplate({
    required this.exercise,
    required this.numberOfSets,
    required this.targetReps,
  });

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'numberOfSets': numberOfSets,
      'targetReps': targetReps,
    };
  }

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) {
    return ExerciseTemplate(
      exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
      numberOfSets: json['numberOfSets'] as int,
      targetReps: json['targetReps'] as int,
    );
  }
}
