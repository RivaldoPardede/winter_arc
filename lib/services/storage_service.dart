// TODO: Implement local storage service
// This will handle saving and loading workout data
// Options: SharedPreferences for simple data, SQLite for complex queries

class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Future methods:
  // - saveWorkoutLog(WorkoutLog log)
  // - getWorkoutLogs(String userId)
  // - saveUser(User user)
  // - getUser(String userId)
  // - etc.
}
