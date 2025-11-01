import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:winter_arc/models/user.dart';
import 'package:winter_arc/services/auth_service.dart';
import 'package:winter_arc/services/firestore_service.dart';
import 'package:winter_arc/services/fcm_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final FCMService _fcmService = FCMService();
  
  User? _currentUser;
  bool _isLoading = false;
  StreamSubscription<List<Map<String, dynamic>>>? _notificationSubscription;
  final Set<String> _shownNotificationIds = {};

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  
  // Get user ID from Firebase Auth
  String get userId => _authService.currentUserId ?? '';
  
  // Check if user is authenticated
  bool get isAuthenticated => _authService.isLoggedIn;
  
  // Check if user has a profile (for welcome screen redirect)
  bool get hasProfile => _currentUser != null;

  Future<void> loadUser() async {
    if (!_authService.isLoggedIn) {
      _currentUser = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userId = _authService.currentUserId!;
      _currentUser = await _firestoreService.getUser(userId);
      
      // If user exists, ensure they're in the default group
      if (_currentUser != null) {
        const defaultGroupId = 'winter-arc-squad-2025';
        final members = await _firestoreService.getGroupMembers(defaultGroupId);
        if (!members.contains(userId)) {
          debugPrint('🔄 Adding existing user to group...');
          await _firestoreService.addMemberToGroup(defaultGroupId, userId);
        }
        
        // Initialize FCM for push notifications
        await _fcmService.initialize(userId);
        await _fcmService.subscribeToSquadTopic(defaultGroupId);
        
        // Listen to squad notifications
        _listenToSquadNotifications(userId, defaultGroupId);
      }
      
      // Don't auto-create profile - let welcome screen handle it
      // This allows us to detect first-time users
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Listen to squad notifications in real-time
  void _listenToSquadNotifications(String userId, String groupId) {
    _notificationSubscription?.cancel();
    _notificationSubscription = _fcmService
        .listenToSquadNotifications(userId, groupId)
        .listen((notifications) {
      // Show notifications that haven't been shown yet
      for (final notification in notifications) {
        final notificationId = notification['id'] as String;
        final timestamp = notification['timestamp'];
        
        // Only show recent notifications (within last 5 minutes)
        if (timestamp != null) {
          final notificationTime = timestamp.toDate();
          final now = DateTime.now();
          final difference = now.difference(notificationTime);
          
          if (difference.inMinutes <= 5 && !_shownNotificationIds.contains(notificationId)) {
            _shownNotificationIds.add(notificationId);
            _fcmService.showNotificationFromData(notification);
            debugPrint('🔔 Showing squad notification: ${notification['userName']} worked out!');
          }
        }
      }
    });
    
    debugPrint('👂 Listening for squad notifications...');
  }

  /// Create user profile (called from welcome screen)
  Future<void> createUserProfile(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.saveUser(user);
      _currentUser = user;
      
      // Also set display name in Firebase Auth
      await _authService.updateDisplayName(user.name);
      
      // Add user to the default Winter Arc group
      const defaultGroupId = 'winter-arc-squad-2025';
      await _firestoreService.addMemberToGroup(defaultGroupId, user.id);
      debugPrint('✅ Added new user ${user.name} to group $defaultGroupId');
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.saveUser(user);
      _currentUser = user;
      
      // Also update display name in Firebase Auth if changed
      if (user.name != _authService.getUserDisplayName()) {
        await _authService.updateDisplayName(user.name);
      }
    } catch (e) {
      debugPrint('Error updating user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _notificationSubscription?.cancel();
      _shownNotificationIds.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
