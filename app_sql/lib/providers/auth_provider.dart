import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  int? _userId;
  bool _isLoading = false;

  String? get token => _token;
  int? get userId => _userId;
  bool get isLoading => _isLoading;
  bool get isAuth => _token != null;

  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(
          const Duration(seconds: 1)); // simulate network delay

      // 🔥 Fake manual check instead of calling DummyJSON
      if (username.trim() == 'kminchelle' && password.trim() == '0lelplR') {
        _token = 'fakeToken_123456';
        _userId = 5; // any dummy user id

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setInt('userId', _userId!);

        notifyListeners();
      } else {
        throw Exception('Invalid username or password');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
