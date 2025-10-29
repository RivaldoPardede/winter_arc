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
}
