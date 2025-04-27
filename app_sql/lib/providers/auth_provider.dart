import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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

    final url = Uri.parse('https://dummyjson.com/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _userId = data['id'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setInt('userId', _userId!);

        notifyListeners();
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Authentication failed');
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
