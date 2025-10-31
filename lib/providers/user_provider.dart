import 'package:flutter/foundation.dart';
import 'package:winter_arc/models/user.dart';
import 'package:winter_arc/services/auth_service.dart';
import 'package:winter_arc/services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  User? _currentUser;
  bool _isLoading = false;

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
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
}
