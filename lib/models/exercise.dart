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
  other,
}

class Exercise {
  final String id;
  final ExerciseType type;
  final String name;
  final String? customName; // For 'other' type
  final String? description;

  Exercise({
    required this.id,
    required this.type,
    required this.name,
    this.customName,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'customName': customName,
      'description': description,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      type: ExerciseType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ExerciseType.other,
      ),
      name: json['name'] as String,
      customName: json['customName'] as String?,
      description: json['description'] as String?,
    );
  }

  // Predefined exercises
  static List<Exercise> get defaultExercises => [
        Exercise(
          id: 'push_ups',
          type: ExerciseType.pushUps,
          name: 'Push-ups',
          description: 'Standard push-ups',
        ),
        Exercise(
          id: 'pull_ups',
          type: ExerciseType.pullUps,
          name: 'Pull-ups',
          description: 'Standard pull-ups',
        ),
        Exercise(
          id: 'squats',
          type: ExerciseType.squats,
          name: 'Squats',
          description: 'Bodyweight squats',
        ),
        Exercise(
          id: 'dips',
          type: ExerciseType.dips,
          name: 'Dips',
          description: 'Parallel bar dips',
        ),
        Exercise(
          id: 'lunges',
          type: ExerciseType.lunges,
          name: 'Lunges',
          description: 'Walking or stationary lunges',
        ),
        Exercise(
          id: 'plank',
          type: ExerciseType.plank,
          name: 'Plank',
          description: 'Plank hold',
        ),
        Exercise(
          id: 'handstand_pushups',
          type: ExerciseType.handstandPushUps,
          name: 'Handstand Push-ups',
          description: 'Wall-assisted or freestanding',
        ),
        Exercise(
          id: 'muscle_ups',
          type: ExerciseType.muscleUps,
          name: 'Muscle-ups',
          description: 'Bar or ring muscle-ups',
        ),
        Exercise(
          id: 'pistol_squats',
          type: ExerciseType.pistolSquats,
          name: 'Pistol Squats',
          description: 'Single-leg squats',
        ),
        Exercise(
          id: 'l_sit',
          type: ExerciseType.lSit,
          name: 'L-Sit',
          description: 'L-sit hold',
        ),
      ];
}
