import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winter_arc/models/workout_log.dart';
import 'package:winter_arc/models/user.dart';
import 'package:winter_arc/utils/constants.dart';

class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ===== USER METHODS =====

  Future<void> saveCurrentUser(User user) async {
    await init();
    final userJson = jsonEncode(user.toJson());
    await _prefs!.setString(AppConstants.currentUserKey, userJson);
  }

  Future<User?> getCurrentUser() async {
    await init();
    final userJson = _prefs!.getString(AppConstants.currentUserKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  // ===== WORKOUT LOG METHODS =====

  Future<void> saveWorkoutLog(WorkoutLog log) async {
    await init();
    final logs = await getWorkoutLogs(log.userId);
    logs.add(log);
    await _saveWorkoutLogs(logs);
  }

  Future<void> updateWorkoutLog(WorkoutLog log) async {
    await init();
    final logs = await getWorkoutLogs(log.userId);
    final index = logs.indexWhere((l) => l.id == log.id);
    if (index != -1) {
      logs[index] = log;
      await _saveWorkoutLogs(logs);
    }
  }

  Future<void> deleteWorkoutLog(String logId, String userId) async {
    await init();
    final logs = await getWorkoutLogs(userId);
    logs.removeWhere((log) => log.id == logId);
    await _saveWorkoutLogs(logs);
  }

  Future<List<WorkoutLog>> getWorkoutLogs(String userId) async {
    await init();
    final logsJson = _prefs!.getString(AppConstants.workoutLogsKey);
    if (logsJson == null) return [];

    final List<dynamic> logsList = jsonDecode(logsJson);
    final allLogs = logsList
        .map((json) => WorkoutLog.fromJson(json as Map<String, dynamic>))
        .toList();

    // Filter by user ID
    return allLogs.where((log) => log.userId == userId).toList();
  }

  Future<List<WorkoutLog>> getTodayWorkouts(String userId) async {
    final logs = await getWorkoutLogs(userId);
    final today = DateTime.now();
    return logs.where((log) {
      return log.date.year == today.year &&
          log.date.month == today.month &&
          log.date.day == today.day;
    }).toList();
  }

  Future<List<WorkoutLog>> getWorkoutsInDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final logs = await getWorkoutLogs(userId);
    return logs.where((log) {
      return log.date.isAfter(start.subtract(const Duration(days: 1))) &&
          log.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> _saveWorkoutLogs(List<WorkoutLog> logs) async {
    final logsJson = jsonEncode(logs.map((log) => log.toJson()).toList());
    await _prefs!.setString(AppConstants.workoutLogsKey, logsJson);
  }

  // ===== STATS HELPERS =====

  Future<int> getWorkoutStreak(String userId) async {
    final logs = await getWorkoutLogs(userId);
    if (logs.isEmpty) return 0;

    // Sort logs by date (newest first)
    logs.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime checkDate = DateTime.now();

    // Check if there's a workout today or yesterday
    final mostRecent = logs.first.date;
    final daysSinceLastWorkout = DateTime.now().difference(mostRecent).inDays;
    
    if (daysSinceLastWorkout > 1) return 0;

    // Count consecutive days with workouts
    for (int i = 0; i < 365; i++) {
      final hasWorkout = logs.any((log) =>
          log.date.year == checkDate.year &&
          log.date.month == checkDate.month &&
          log.date.day == checkDate.day);

      if (hasWorkout) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  Future<int> getTotalWorkoutsInWinterArc(String userId) async {
    final logs = await getWorkoutsInDateRange(
      userId,
      AppConstants.winterArcStart,
      AppConstants.winterArcEnd,
    );
    return logs.length;
  }

  // ===== UTILITY METHODS =====

  Future<void> clearAllData() async {
    await init();
    await _prefs!.clear();
  }

  Future<void> clearWorkoutLogs() async {
    await init();
    await _prefs!.remove(AppConstants.workoutLogsKey);
  }
}
