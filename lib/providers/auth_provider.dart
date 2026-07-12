import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _adminEmail = '';
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  String get adminEmail => _adminEmail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Demo credentials
  static const String _demoEmail = 'admin@admin.com';
  static const String _demoPassword = 'admin123';

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.trim().toLowerCase() == _demoEmail &&
        password == _demoPassword) {
      _isLoggedIn = true;
      _adminEmail = email.trim().toLowerCase();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    _errorMessage = 'Credenciais inválidas. Use admin@admin.com / admin123';
    notifyListeners();
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _adminEmail = '';
    _errorMessage = null;
    notifyListeners();
  }
}
