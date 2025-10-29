class WorkoutSet {
  final int reps;
  final int? duration; // For time-based exercises like plank (in seconds)
  final String? notes;

  WorkoutSet({
    required this.reps,
    this.duration,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'duration': duration,
      'notes': notes,
    };
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      reps: json['reps'] as int,
      duration: json['duration'] as int?,
      notes: json['notes'] as String?,
    );
  }

  WorkoutSet copyWith({
    int? reps,
    int? duration,
    String? notes,
  }) {
    return WorkoutSet(
      reps: reps ?? this.reps,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
    );
  }
}
