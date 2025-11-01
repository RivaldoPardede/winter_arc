import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    debugPrint('✅ Notification service initialized');
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Notification tapped: ${response.payload}');
    // You can navigate to specific screens here based on payload
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android 13+ requires notification permission
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final granted = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    }
    return true;
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await Permission.notification.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final granted = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return granted != null;
    }
    return true;
  }

  /// Schedule daily workout reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    debugPrint('📅 Scheduling daily reminder for $hour:${minute.toString().padLeft(2, '0')}');
    
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminders',
      channelDescription: 'Daily workout reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      channelShowBadge: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule for today or tomorrow if time has passed
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    // Add 1-minute buffer to ensure notification isn't missed
    // If scheduled time is in the past or less than 1 minute away, schedule for tomorrow
    if (scheduledDate.isBefore(now.add(const Duration(minutes: 1)))) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      debugPrint('⏰ Scheduled time is too soon or passed, scheduling for tomorrow');
    } else {
      debugPrint('⏰ Scheduling for today');
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    debugPrint('📅 Notification will fire at: $scheduledDate');
    debugPrint('🕐 Current time: $now');
    debugPrint('🌍 Timezone: ${tz.local.name}');
    debugPrint('⏱️ Minutes until notification: ${scheduledDate.difference(now).inMinutes}');

    try {
      await _notifications.zonedSchedule(
        0, // Notification ID
        title,
        body,
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // Repeats daily
      );

      // Save reminder settings
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('reminder_enabled', true);
      await prefs.setInt('reminder_hour', hour);
      await prefs.setInt('reminder_minute', minute);

      debugPrint('✅ Daily reminder scheduled successfully');
      
      // Verify pending notifications
      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('📋 Total pending notifications: ${pending.length}');
      for (var notif in pending) {
        debugPrint('   - ID ${notif.id}: ${notif.title}');
      }
    } catch (e) {
      debugPrint('❌ Error scheduling daily reminder: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    
    // Clear reminder settings
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_enabled', false);
    
    debugPrint('🔕 All notifications cancelled');
  }

  /// Get saved reminder settings
  Future<Map<String, dynamic>> getReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool('reminder_enabled') ?? false,
      'hour': prefs.getInt('reminder_hour') ?? 18, // Default 6 PM
      'minute': prefs.getInt('reminder_minute') ?? 0,
    };
  }

  /// Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant',
      'Instant Notifications',
      channelDescription: 'Instant test notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond, // Unique ID
      title,
      body,
      details,
    );

    debugPrint('📬 Immediate notification sent');
  }

  /// Schedule a test notification for 1 minute from now
  Future<void> scheduleTestNotification() async {
    debugPrint('🧪 Starting test notification scheduling...');
    debugPrint('📅 Current timezone: ${tz.local.name}');
    
    const androidDetails = AndroidNotificationDetails(
      'test_reminder',
      'Test Reminders',
      channelDescription: 'Test scheduled notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      channelShowBadge: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = DateTime.now();
    final scheduledDate = now.add(const Duration(minutes: 1));
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    debugPrint('🕐 Now: $now');
    debugPrint('⏰ Scheduled for: $scheduledDate');
    debugPrint('🌍 TZ Scheduled: $tzScheduledDate');
    debugPrint('⏱️ Difference: ${scheduledDate.difference(now).inSeconds} seconds');

    try {
      await _notifications.zonedSchedule(
        999, // Different ID for test
        '🧪 Test Notification',
        'If you see this in 1 minute, scheduled notifications work!',
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      
      debugPrint('✅ Test notification scheduled successfully');
      debugPrint('💡 Make sure battery optimization is disabled for Winter Arc!');
      
      // Get pending notifications to verify
      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('📋 Pending notifications: ${pending.length}');
      for (var notif in pending) {
        debugPrint('   - ID ${notif.id}: ${notif.title}');
      }
    } catch (e) {
      debugPrint('❌ Error scheduling test notification: $e');
    }
  }

  /// Motivational messages for Winter Arc
  static final List<String> motivationalMessages = [
    "Time to dominate! 💪 Winter Arc Day awaits!",
    "Your future self will thank you! Let's workout! 🔥",
    "The only bad workout is the one that didn't happen! ❄️",
    "Winter Arc warriors never skip! Time to train! 💯",
    "Success is built daily! Let's go! 🏆",
    "Your squad is counting on you! Crush it today! 🚀",
    "Champions are made in the winter! Let's train! ⚡",
    "90 days to greatness! Make today count! 💪",
    "No excuses, just results! Time to workout! 🔥",
    "The grind never stops! Winter Arc time! ❄️",
  ];

  /// Get a random motivational message
  static String getMotivationalMessage() {
    return motivationalMessages[
        DateTime.now().millisecond % motivationalMessages.length];
  }
}
