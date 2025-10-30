class AppConstants {
  // Winter Arc Period
  // TODO: Change back to Nov 1 before production release!
  static final DateTime winterArcStart = DateTime(2025, 10, 30); // Temporarily Oct 30 for testing
  static final DateTime winterArcEnd = DateTime(2026, 2, 28);

  // App Info
  static const String appName = 'Winter Arc';
  static const String appVersion = '1.0.0';

  // Group Info
  static const int maxGroupMembers = 4;

  // Storage Keys
  static const String currentUserKey = 'current_user';
  static const String workoutLogsKey = 'workout_logs';
  static const String groupMembersKey = 'group_members';

  // Calculate days remaining in winter arc
  static int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(winterArcEnd)) return 0;
    if (now.isBefore(winterArcStart)) {
      return winterArcEnd.difference(winterArcStart).inDays;
    }
    return winterArcEnd.difference(now).inDays;
  }

  // Calculate progress percentage
  static double get winterArcProgress {
    final now = DateTime.now();
    if (now.isAfter(winterArcEnd)) return 1.0;
    if (now.isBefore(winterArcStart)) return 0.0;

    final totalDays = winterArcEnd.difference(winterArcStart).inDays;
    final daysPassed = now.difference(winterArcStart).inDays;
    return daysPassed / totalDays;
  }

  // Check if currently in Winter Arc period
  static bool get isWinterArcActive {
    final now = DateTime.now();
    return now.isAfter(winterArcStart) && now.isBefore(winterArcEnd);
  }
}
