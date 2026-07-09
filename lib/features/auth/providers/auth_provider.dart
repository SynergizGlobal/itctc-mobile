import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../data/auth_credentials.dart';
import '../models/auth_state.dart';
import '../models/auth_user.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(AppConstants.prefRememberMe) ?? false;
    final loggedIn = prefs.getBool(AppConstants.prefLoggedIn) ?? false;
    final savedUsername = prefs.getString(AppConstants.prefSavedUsername);

    if (rememberMe && loggedIn && savedUsername != null) {
      final user = AuthCredentials.userFor(savedUsername);
      if (user != null) {
        state = AuthState(
          isBootstrapped: true,
          isAuthenticated: true,
          user: user,
          rememberMe: true,
          savedUsername: savedUsername,
        );
        return;
      }
    }

    state = AuthState(
      isBootstrapped: true,
      rememberMe: rememberMe,
      savedUsername: savedUsername,
    );
  }

  Future<String?> login({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    final user = AuthCredentials.validate(username, password);
    if (user == null) {
      return 'Invalid username or password';
    }

    final prefs = await SharedPreferences.getInstance();
    final trimmed = username.trim();

    await prefs.setBool(AppConstants.prefRememberMe, rememberMe);
    await prefs.setString(AppConstants.prefSavedUsername, trimmed);
    await prefs.setBool(AppConstants.prefLoggedIn, rememberMe);

    state = AuthState(
      isBootstrapped: true,
      isAuthenticated: true,
      user: user,
      rememberMe: rememberMe,
      savedUsername: trimmed,
    );
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefLoggedIn, false);

    state = state.copyWith(
      isAuthenticated: false,
      clearUser: true,
    );
  }

  /// Test helper to skip login in widget tests.
  void authenticateForTesting([AuthUser user = AuthCredentials.demoUser]) {
    state = AuthState(
      isBootstrapped: true,
      isAuthenticated: true,
      user: user,
    );
  }
}
