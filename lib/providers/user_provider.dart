import 'package:flutter/foundation.dart';
import 'package:winter_arc/models/user.dart';
import 'package:winter_arc/services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  
  // Get user ID, create default if needed
  String get userId => _currentUser?.id ?? 'default_user';

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _storageService.getCurrentUser();
      
      // Create default user if none exists
      if (_currentUser == null) {
        _currentUser = User(
          id: 'default_user',
          name: 'Winter Warrior',
          joinedDate: DateTime.now(),
        );
        await _storageService.saveCurrentUser(_currentUser!);
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
      await _storageService.saveCurrentUser(user);
      _currentUser = user;
    } catch (e) {
      debugPrint('Error updating user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
