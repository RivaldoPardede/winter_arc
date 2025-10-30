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
      
      // Create user profile if doesn't exist
      if (_currentUser == null) {
        _currentUser = User(
          id: userId,
          name: _authService.getUserDisplayName(),
          joinedDate: DateTime.now(),
        );
        await _firestoreService.saveUser(_currentUser!);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
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
