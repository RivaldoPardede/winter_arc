class WorkoutSet {
  final int reps;
  final double? weight; // in kg
  final int? duration; // in seconds
  final double? distance; // in km
  final String? notes;

  WorkoutSet({
    required this.reps,
    this.weight,
    this.duration,
    this.distance,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'distance': distance,
      'notes': notes,
    };
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      reps: json['reps'] as int,
      weight: (json['weight'] as num?)?.toDouble(),
      duration: json['duration'] as int?,
      distance: (json['distance'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  WorkoutSet copyWith({
    int? reps,
    double? weight,
    int? duration,
    double? distance,
    String? notes,
  }) {
    return WorkoutSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      notes: notes ?? this.notes,
    );
  }
}
