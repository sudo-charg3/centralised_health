import 'package:flutter/material.dart';
import 'package:centralised_health/services/api_service.dart';
import 'package:centralised_health/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  bool _isLoggedIn = false;
  String? _userId;
  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;

  Future<void> login(String abhaId, String password) async {
    try {
      final data = await _apiService.loginUser(abhaId, password);
      await _storageService.saveToken(data['access_token']);
      _userId = data['user_id']; // Assuming the response contains the user ID
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      print('Login error: $e');
      _isLoggedIn = false;
      notifyListeners();
      throw Exception('Login failed');
    }
  }

  Future<void> register(String abhaId, String password) async {
    try {
      final data = await _apiService.registerUser(abhaId, password);
      await _storageService.saveToken(data['access_token']);
      _userId = data['user_id']; // Assuming the response contains the user ID
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      print('Registration error: $e');
      _isLoggedIn = false;
      notifyListeners();
      throw Exception('Registration failed');
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
    _userId = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    String? token = await _storageService.getToken();
    _isLoggedIn = token != null;
    notifyListeners();
  }

  Future<String?> getToken() async {
    return await _storageService.getToken();
  }
}