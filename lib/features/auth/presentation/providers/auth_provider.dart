import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/auth_repository.dart';
import '../../../../core/di/service_locator.dart';

class AuthProvider with ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _authRepository = getIt<AuthRepository>();
  bool isLoading = false;
  User? currentUser;

  bool get isAuthenticated => currentUser != null;

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      final userCred = await _authRepository.loginUser(email, password);
      currentUser = userCred.user;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      final userCred = await _authRepository.registerUser(email, password);
      currentUser = userCred.user;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    currentUser = null;
    notifyListeners();
  }
}
