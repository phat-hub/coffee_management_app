import '../model/user.dart';
import '../service/auth_service.dart';
import 'package:flutter/material.dart';

class AuthManager with ChangeNotifier {
  late final AuthService _service;

  User? _user;
  List<User> _staffs = [];

  AuthManager() {
    _service = AuthService(
      onAuthChange: (user) {
        _user = user;
        notifyListeners();
      },
    );
  }

  User? get user => _user;
  bool get isAuth => _user != null;
  bool get isOwner => _user?.role == 'owner';
  List<User> get staffs => _staffs;

  Future<void> login(String email, String password) async {
    _user = await _service.login(email, password);
    notifyListeners();
  }

  Future<void> fetchStaff() async {
    _staffs = await _service.fetchStaff();
    notifyListeners();
  }

  Future<void> createStaff(User user, String password) async {
    await _service.createStaff(user, password);
    await fetchStaff();
  }

  Future<void> tryAutoLogin() async {
    _user = await _service.tryAutoLogin();
    notifyListeners();
  }

  Future<void> updateStaff(User user) async {
    await _service.updateStaff(user);
    await fetchStaff();
  }

  Future<void> toggleLock(User user) async {
    await _service.toggleLock(user);
    await fetchStaff();
  }

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    notifyListeners();
  }
}
