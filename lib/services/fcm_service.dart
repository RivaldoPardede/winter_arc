import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to handle Firebase Cloud Messaging for squad notifications
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;

  /// Initialize FCM service
  Future<void> initialize(String userId) async {
    if (_initialized) return;

    try {
      // Request permission for notifications
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('📱 FCM Permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        final token = await _messaging.getToken();
        if (token != null) {
          debugPrint('🔑 FCM Token: ${token.substring(0, 20)}...');
          // Save token to Firestore for this user
          await _saveTokenToFirestore(userId, token);
        }

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          debugPrint('🔄 FCM Token refreshed');
          _saveTokenToFirestore(userId, newToken);
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages (when app is in background but not terminated)
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

        // Initialize local notifications for foreground display
        await _initializeLocalNotifications();

        _initialized = true;
        debugPrint('✅ FCM Service initialized');
      } else {
        debugPrint('⚠️ FCM Permission denied');
      }
    } catch (e) {
      debugPrint('❌ Error initializing FCM: $e');
    }
  }

  /// Save FCM token to Firestore
  Future<void> _saveTokenToFirestore(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('💾 FCM token saved to Firestore');
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(settings);
  }

  /// Handle foreground messages (when app is open)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📬 Foreground message: ${message.notification?.title}');

    // Show notification using local notifications
    if (message.notification != null) {
      await _showLocalNotification(
        title: message.notification!.title ?? 'Winter Arc',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle notification tap (when app is in background)
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('🔔 Notification tapped: ${message.data}');
    // TODO: Navigate to specific screen based on message.data
    // For now, just log it
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'squad_activity',
      'Squad Activity',
      channelDescription: 'Notifications when squad members complete workouts',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
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

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Subscribe to squad topic (for group notifications)
  Future<void> subscribeToSquadTopic(String groupId) async {
    try {
      await _messaging.subscribeToTopic('squad_$groupId');
      debugPrint('📢 Subscribed to squad_$groupId topic');
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from squad topic
  Future<void> unsubscribeFromSquadTopic(String groupId) async {
    try {
      await _messaging.unsubscribeFromTopic('squad_$groupId');
      debugPrint('🔕 Unsubscribed from squad_$groupId topic');
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Send workout completion notification to squad
  /// This will be called when a user completes a workout
  Future<void> notifySquadWorkoutCompleted({
    required String groupId,
    required String userId,
    required String userName,
    required String workoutSummary,
  }) async {
    try {
      // Check if this user already sent a notification today
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final lastNotificationSent = (userDoc.data()?['lastSquadNotificationSent'] as Timestamp?)?.toDate();
      
      if (lastNotificationSent != null && lastNotificationSent.isAfter(todayStart)) {
        debugPrint('⏭️ User already sent squad notification today, skipping');
        return;
      }

      debugPrint('📤 Creating squad notification for other members');

      // Create notification data that will be picked up by other clients
      final notificationData = {
        'title': '💪 Squad Activity!',
        'body': '$userName just crushed a workout! $workoutSummary',
        'type': 'workout_completed',
        'userId': userId,
        'userName': userName,
        'groupId': groupId,
        'workoutSummary': workoutSummary,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      };

      // Save notification to Firestore
      // Other squad members will listen to this collection in real-time
      await _firestore.collection('squadNotifications').add(notificationData);

      // Update user's last notification sent time
      await _firestore.collection('users').doc(userId).update({
        'lastSquadNotificationSent': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Squad notification created - other members will be notified via listeners');
    } catch (e) {
      debugPrint('❌ Error sending squad notification: $e');
    }
  }

  /// Listen to squad notifications in real-time
  /// Call this when user logs in to receive notifications from other members
  Stream<List<Map<String, dynamic>>> listenToSquadNotifications(
    String userId,
    String groupId,
  ) {
    return _firestore
        .collection('squadNotifications')
        .where('groupId', isEqualTo: groupId)
        .where('userId', isNotEqualTo: userId) // Don't show own notifications
        .orderBy('userId') // Required for inequality filter
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('squadNotifications').doc(notificationId).update({
        'read': true,
      });
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }

  /// Show notification from Firestore data
  Future<void> showNotificationFromData(Map<String, dynamic> data) async {
    final title = data['title'] as String? ?? '💪 Squad Activity!';
    final body = data['body'] as String? ?? 'A squad member completed a workout!';
    
    await _showLocalNotification(
      title: title,
      body: body,
      payload: data['id'] as String?,
    );
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🌙 Background message: ${message.notification?.title}');
  // Handle background message
}
