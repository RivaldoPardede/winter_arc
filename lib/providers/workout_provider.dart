import 'package:flutter/foundation.dart';
import 'package:winter_arc/models/workout_log.dart';
import 'package:winter_arc/services/storage_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  List<WorkoutLog> _allWorkouts = [];
  List<WorkoutLog> _todayWorkouts = [];
  int _streak = 0;
  int _totalWinterArcWorkouts = 0;
  bool _isLoading = false;

  List<WorkoutLog> get allWorkouts => _allWorkouts;
  List<WorkoutLog> get todayWorkouts => _todayWorkouts;
  int get streak => _streak;
  int get totalWinterArcWorkouts => _totalWinterArcWorkouts;
  bool get isLoading => _isLoading;

  // Calculated stats
  int get todayTotalReps {
    return _todayWorkouts.fold<int>(0, (sum, workout) => sum + workout.totalReps);
  }

  int get todayTotalSets {
    return _todayWorkouts.fold<int>(0, (sum, workout) => sum + workout.totalSets);
  }

  Future<void> loadWorkouts(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _allWorkouts = await _storageService.getWorkoutLogs(userId);
      _todayWorkouts = await _storageService.getTodayWorkouts(userId);
      _streak = await _storageService.getWorkoutStreak(userId);
      _totalWinterArcWorkouts = await _storageService.getTotalWorkoutsInWinterArc(userId);
    } catch (e) {
      debugPrint('Error loading workouts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWorkout(WorkoutLog workout) async {
    try {
      await _storageService.saveWorkoutLog(workout);
      
      // Reload all data
      await loadWorkouts(workout.userId);
    } catch (e) {
      debugPrint('Error adding workout: $e');
      rethrow;
    }
  }

  Future<void> updateWorkout(WorkoutLog workout) async {
    try {
      await _storageService.updateWorkoutLog(workout);
      
      // Reload all data
      await loadWorkouts(workout.userId);
    } catch (e) {
      debugPrint('Error updating workout: $e');
      rethrow;
    }
  }

  Future<void> deleteWorkout(String logId, String userId) async {
    try {
      await _storageService.deleteWorkoutLog(logId, userId);
      
      // Reload all data
      await loadWorkouts(userId);
    } catch (e) {
      debugPrint('Error deleting workout: $e');
      rethrow;
    }
  }

  Future<void> refresh(String userId) async {
    await loadWorkouts(userId);
  }

  // Get workouts for a specific date range
  List<WorkoutLog> getWorkoutsInRange(DateTime start, DateTime end) {
    return _allWorkouts.where((workout) {
      return workout.date.isAfter(start.subtract(const Duration(days: 1))) &&
          workout.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get workouts grouped by exercise type
  Map<String, List<WorkoutLog>> getWorkoutsByExercise() {
    final Map<String, List<WorkoutLog>> grouped = {};
    
    for (var workout in _allWorkouts) {
      for (var exercise in workout.exercises) {
        final exerciseName = exercise.exercise.name;
        if (!grouped.containsKey(exerciseName)) {
          grouped[exerciseName] = [];
        }
        grouped[exerciseName]!.add(workout);
      }
    }
    
    return grouped;
  }

  // Get workouts sorted by date (newest first)
  List<WorkoutLog> getWorkoutsByDateDesc() {
    final sorted = List<WorkoutLog>.from(_allWorkouts);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  // Get progress data for a specific exercise
  List<Map<String, dynamic>> getExerciseProgress(String exerciseName) {
    final workoutsWithExercise = _allWorkouts.where((workout) {
      return workout.exercises.any((ex) => ex.exercise.name == exerciseName);
    }).toList();

    // Sort by date
    workoutsWithExercise.sort((a, b) => a.date.compareTo(b.date));

    return workoutsWithExercise.map((workout) {
      final exerciseData = workout.exercises.firstWhere(
        (ex) => ex.exercise.name == exerciseName,
      );

      final totalReps = exerciseData.sets.fold<int>(
        0,
        (sum, set) => sum + set.reps,
      );

      final maxReps = exerciseData.sets.fold<int>(
        0,
        (max, set) => set.reps > max ? set.reps : max,
      );

      return {
        'date': workout.date,
        'totalReps': totalReps,
        'totalSets': exerciseData.sets.length,
        'maxReps': maxReps,
        'avgReps': (totalReps / exerciseData.sets.length).round(),
      };
    }).toList();
  }

  // Get personal records for each exercise
  Map<String, Map<String, dynamic>> getPersonalRecords() {
    final records = <String, Map<String, dynamic>>{};

    for (var workout in _allWorkouts) {
      for (var exercise in workout.exercises) {
        final exerciseName = exercise.exercise.name;
        
        final totalReps = exercise.sets.fold<int>(
          0,
          (sum, set) => sum + set.reps,
        );

        final maxReps = exercise.sets.fold<int>(
          0,
          (max, set) => set.reps > max ? set.reps : max,
        );

        if (!records.containsKey(exerciseName)) {
          records[exerciseName] = {
            'maxRepsInSet': maxReps,
            'maxRepsInWorkout': totalReps,
            'maxSets': exercise.sets.length,
            'dateMaxReps': workout.date,
            'dateMaxWorkout': workout.date,
          };
        } else {
          if (maxReps > records[exerciseName]!['maxRepsInSet']) {
            records[exerciseName]!['maxRepsInSet'] = maxReps;
            records[exerciseName]!['dateMaxReps'] = workout.date;
          }
          if (totalReps > records[exerciseName]!['maxRepsInWorkout']) {
            records[exerciseName]!['maxRepsInWorkout'] = totalReps;
            records[exerciseName]!['dateMaxWorkout'] = workout.date;
          }
          if (exercise.sets.length > records[exerciseName]!['maxSets']) {
            records[exerciseName]!['maxSets'] = exercise.sets.length;
          }
        }
      }
    }

    return records;
  }

  // Get total volume (sets × reps) for a workout
  int getWorkoutVolume(WorkoutLog workout) {
    return workout.exercises.fold<int>(0, (sum, exercise) {
      final exerciseVolume = exercise.sets.fold<int>(
        0,
        (exSum, set) => exSum + set.reps,
      );
      return sum + exerciseVolume;
    });
  }

  // Get unique exercises performed
  List<String> getUniqueExercises() {
    final exercises = <String>{};
    for (var workout in _allWorkouts) {
      for (var exercise in workout.exercises) {
        exercises.add(exercise.exercise.name);
      }
    }
    return exercises.toList()..sort();
  }
}
