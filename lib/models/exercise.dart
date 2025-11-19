enum ExerciseType {
  pushUps,
  pullUps,
  squats,
  dips,
  lunges,
  plank,
  handstandPushUps,
  muscleUps,
  pistolSquats,
  lSit,
  cardio,
  other,
}

// Exercise categories for better organization
enum ExerciseCategory {
  push,   // Push-ups, Dips, Handstand Push-ups
  pull,   // Pull-ups, Muscle-ups, Rows
  legs,   // Squats, Lunges, Pistol Squats
  core,   // Plank, L-sits, Leg Raises
  cardio, // Running, Cycling
}

// Extension to add helper methods to ExerciseCategory
extension ExerciseCategoryExtension on ExerciseCategory {
  String get displayName {
    switch (this) {
      case ExerciseCategory.push:
        return 'PUSH';
      case ExerciseCategory.pull:
        return 'PULL';
      case ExerciseCategory.legs:
        return 'LEGS';
      case ExerciseCategory.core:
        return 'CORE';
      case ExerciseCategory.cardio:
        return 'CARDIO';
    }
  }

  String get icon {
    switch (this) {
      case ExerciseCategory.push:
        return '💪';  // Flexed bicep
      case ExerciseCategory.pull:
        return '🦾';  // Mechanical arm
      case ExerciseCategory.legs:
        return '🦵';  // Leg
      case ExerciseCategory.core:
        return '🔥';  // Fire (core burn!)
      case ExerciseCategory.cardio:
        return '🏃';  // Runner
    }
  }

  String get description {
    switch (this) {
      case ExerciseCategory.push:
        return 'Pushing movements';
      case ExerciseCategory.pull:
        return 'Pulling movements';
      case ExerciseCategory.legs:
        return 'Lower body';
      case ExerciseCategory.core:
        return 'Core & stability';
      case ExerciseCategory.cardio:
        return 'Cardiovascular endurance';
    }
  }
}

class Exercise {
  final String id;
  final ExerciseType type;
  final String name;
  final String description;
  final ExerciseCategory category;
  final List<String> requiredFields; // 'reps', 'weight', 'duration', 'distance'

  const Exercise({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.category,
    this.requiredFields = const ['reps'],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'name': name,
      'description': description,
      'category': category.toString().split('.').last,
      'requiredFields': requiredFields,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      type: ExerciseType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ExerciseType.other,
      ),
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: ExerciseCategory.values.firstWhere(
        (e) => e.toString().split('.').last == (json['category'] as String?),
        orElse: () => ExerciseCategory.push,
      ),
      requiredFields: (json['requiredFields'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['reps'],
    );
  }

  static List<Exercise> get defaultExercises => [
        Exercise(
          id: 'push_ups',
          type: ExerciseType.pushUps,
          name: 'Push-ups',
          description: 'Standard push-ups',
          category: ExerciseCategory.push,
        ),
        Exercise(
          id: 'pull_ups',
          type: ExerciseType.pullUps,
          name: 'Pull-ups',
          description: 'Standard pull-ups',
          category: ExerciseCategory.pull,
        ),
        Exercise(
          id: 'squats',
          type: ExerciseType.squats,
          name: 'Squats',
          description: 'Bodyweight squats',
          category: ExerciseCategory.legs,
        ),
        Exercise(
          id: 'dips',
          type: ExerciseType.dips,
          name: 'Dips',
          description: 'Parallel bar dips',
          category: ExerciseCategory.push,
        ),
        Exercise(
          id: 'lunges',
          type: ExerciseType.lunges,
          name: 'Lunges',
          description: 'Walking or static lunges',
          category: ExerciseCategory.legs,
        ),
        Exercise(
          id: 'plank',
          type: ExerciseType.plank,
          name: 'Plank',
          description: 'Core stability hold',
          category: ExerciseCategory.core,
          requiredFields: ['duration'],
        ),
        Exercise(
          id: 'handstand_pushups',
          type: ExerciseType.handstandPushUps,
          name: 'Handstand Push-ups',
          description: 'Advanced vertical push',
          category: ExerciseCategory.push,
        ),
        Exercise(
          id: 'muscle_ups',
          type: ExerciseType.muscleUps,
          name: 'Muscle-ups',
          description: 'Pull-up to dip transition',
          category: ExerciseCategory.pull,
        ),
        Exercise(
          id: 'pistol_squats',
          type: ExerciseType.pistolSquats,
          name: 'Pistol Squats',
          description: 'Single-leg squats',
          category: ExerciseCategory.legs,
        ),
        Exercise(
          id: 'l_sits',
          type: ExerciseType.lSit,
          name: 'L-sits',
          description: 'Core and hip flexor strength',
          category: ExerciseCategory.core,
          requiredFields: ['duration'],
        ),
        Exercise(
          id: 'jogging',
          type: ExerciseType.cardio,
          name: 'Jogging',
          description: 'Steady state running',
          category: ExerciseCategory.cardio,
          requiredFields: ['duration', 'distance'],
        ),
      ];
}
