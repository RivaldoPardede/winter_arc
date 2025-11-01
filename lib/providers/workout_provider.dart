import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:winter_arc/models/workout_log.dart';
import 'package:winter_arc/services/firestore_service.dart';
import 'package:winter_arc/services/fcm_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FCMService _fcmService = FCMService();
  
  List<WorkoutLog> _allWorkouts = [];
  List<WorkoutLog> _todayWorkouts = [];
  int _streak = 0;
  int _totalWinterArcWorkouts = 0;
  bool _isLoading = false;

  StreamSubscription<List<WorkoutLog>>? _workoutsSubscription;
  String? _currentUserId;

  // Cached computed values for performance
  int _cachedTodayTotalReps = 0;
  int _cachedTodayTotalSets = 0;
  final Map<String, Map<String, dynamic>> _cachedPersonalRecords = {};

  List<WorkoutLog> get allWorkouts => _allWorkouts;
  List<WorkoutLog> get todayWorkouts => _todayWorkouts;
  int get streak => _streak;
  int get totalWinterArcWorkouts => _totalWinterArcWorkouts;
  bool get isLoading => _isLoading;

  // Calculated stats - now using cached values
  int get todayTotalReps => _cachedTodayTotalReps;
  int get todayTotalSets => _cachedTodayTotalSets;

  /// Start listening to real-time workout updates
  Future<void> loadWorkouts(String userId) async {
    if (_currentUserId == userId && _workoutsSubscription != null) {
      // Already listening to this user's workouts
      return;
    }

    _isLoading = true;
    _currentUserId = userId;
    notifyListeners();

    // Cancel previous subscription if exists
    await _workoutsSubscription?.cancel();

    try {
      // Subscribe to real-time updates
      _workoutsSubscription = _firestoreService.workoutsStream(userId).listen(
        (workouts) async {
          _allWorkouts = workouts;
          
          // Calculate today's workouts
          final now = DateTime.now();
          _todayWorkouts = workouts.where((workout) {
            return workout.date.year == now.year &&
                workout.date.month == now.month &&
                workout.date.day == now.day;
          }).toList();

          // Update cached stats
          _updateCachedStats();

          // Calculate streak and winter arc stats
          _streak = await _firestoreService.getWorkoutStreak(userId);
          _totalWinterArcWorkouts =
              await _firestoreService.getTotalWorkoutsInWinterArc(userId);

          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Error in workouts stream: $error');
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error loading workouts: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWorkout(WorkoutLog workout) async {
    try {
      await _firestoreService.saveWorkoutLog(workout);
      
      // Send squad notification
      await _notifySquadWorkoutCompleted(workout);
      
      // Real-time listener will automatically update the UI
    } catch (e) {
      debugPrint('Error adding workout: $e');
      rethrow;
    }
  }

  /// Notify squad members when workout is completed
  Future<void> _notifySquadWorkoutCompleted(WorkoutLog workout) async {
    try {
      // Get user info for the notification
      final user = await _firestoreService.getUser(workout.userId);
      if (user == null) return;

      // Calculate workout summary
      final totalExercises = workout.exercises.length;
      final totalSets = workout.exercises.fold<int>(
        0,
        (sum, ex) => sum + ex.sets.length,
      );
      final totalReps = workout.exercises.fold<int>(
        0,
        (sum, ex) => sum + ex.sets.fold<int>(0, (s, set) => s + set.reps),
      );

      final workoutSummary = '$totalExercises exercises, $totalSets sets, $totalReps reps';

      // Send notification to squad (hardcoded group for now)
      const defaultGroupId = 'winter-arc-squad-2025';
      
      await _fcmService.notifySquadWorkoutCompleted(
        groupId: defaultGroupId,
        userId: workout.userId,
        userName: user.name,
        workoutSummary: workoutSummary,
      );

      debugPrint('✅ Squad notification sent for ${user.name}\'s workout');
    } catch (e) {
      debugPrint('❌ Error notifying squad: $e');
      // Don't rethrow - notification failure shouldn't block workout logging
    }
  }

  Future<void> updateWorkout(WorkoutLog workout) async {
    try {
      await _firestoreService.updateWorkoutLog(workout);
      // Real-time listener will automatically update the UI
    } catch (e) {
      debugPrint('Error updating workout: $e');
      rethrow;
    }
  }

  Future<void> deleteWorkout(String logId, String userId) async {
    try {
      await _firestoreService.deleteWorkoutLog(logId);
      // Real-time listener will automatically update the UI
    } catch (e) {
      debugPrint('Error deleting workout: $e');
      rethrow;
    }
  }

  Future<void> refresh(String userId) async {
    // With real-time listeners, manual refresh is not needed
    // But we can recalculate stats if needed
    if (_currentUserId == userId) {
      _streak = await _firestoreService.getWorkoutStreak(userId);
      _totalWinterArcWorkouts =
          await _firestoreService.getTotalWorkoutsInWinterArc(userId);
      notifyListeners();
    }
  }

  /// Stop listening to real-time updates
  void stopListening() {
    _workoutsSubscription?.cancel();
    _workoutsSubscription = null;
    _currentUserId = null;
  }

  @override
  void dispose() {
    _workoutsSubscription?.cancel();
    super.dispose();
  }
  
  /// Update cached computed values for better performance
  void _updateCachedStats() {
    // Cache today's totals
    _cachedTodayTotalReps = _todayWorkouts.fold<int>(
      0, (sum, workout) => sum + workout.totalReps
    );
    _cachedTodayTotalSets = _todayWorkouts.fold<int>(
      0, (sum, workout) => sum + workout.totalSets
    );
    
    // Update personal records cache
    _updatePersonalRecordsCache();
  }
  
  /// Update personal records cache incrementally
  void _updatePersonalRecordsCache() {
    _cachedPersonalRecords.clear();
    
    for (var workout in _allWorkouts) {
      for (var exercise in workout.exercises) {
        final exerciseName = exercise.exercise.name;
        final totalReps = exercise.sets.fold<int>(0, (sum, set) => sum + set.reps);
        final maxReps = exercise.sets.fold<int>(0, (max, set) => 
          set.reps > max ? set.reps : max
        );
        
        if (!_cachedPersonalRecords.containsKey(exerciseName)) {
          _cachedPersonalRecords[exerciseName] = {
            'maxRepsInSet': maxReps,
            'maxRepsInWorkout': totalReps,
            'maxSets': exercise.sets.length,
            'dateMaxReps': workout.date,
            'dateMaxWorkout': workout.date,
          };
        } else {
          final current = _cachedPersonalRecords[exerciseName]!;
          if (maxReps > current['maxRepsInSet']) {
            current['maxRepsInSet'] = maxReps;
            current['dateMaxReps'] = workout.date;
          }
          if (totalReps > current['maxRepsInWorkout']) {
            current['maxRepsInWorkout'] = totalReps;
            current['dateMaxWorkout'] = workout.date;
          }
          if (exercise.sets.length > current['maxSets']) {
            current['maxSets'] = exercise.sets.length;
          }
        }
      }
    }
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

      // Calculate average reps, avoiding division by zero
      final avgReps = exerciseData.sets.isEmpty 
          ? 0 
          : (totalReps / exerciseData.sets.length).round();

      return {
        'date': workout.date,
        'totalReps': totalReps,
        'totalSets': exerciseData.sets.length,
        'maxReps': maxReps,
        'avgReps': avgReps,
      };
    }).toList();
  }

  // Get personal records for each exercise - now returns cached value
  Map<String, Map<String, dynamic>> getPersonalRecords() {
    return _cachedPersonalRecords;
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
