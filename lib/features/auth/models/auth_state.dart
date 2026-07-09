import 'auth_user.dart';

class AuthState {
  const AuthState({
    this.isBootstrapped = false,
    this.isAuthenticated = false,
    this.user,
    this.rememberMe = false,
    this.savedUsername,
  });

  final bool isBootstrapped;
  final bool isAuthenticated;
  final AuthUser? user;
  final bool rememberMe;
  final String? savedUsername;

  AuthState copyWith({
    bool? isBootstrapped,
    bool? isAuthenticated,
    AuthUser? user,
    bool clearUser = false,
    bool? rememberMe,
    String? savedUsername,
    bool clearSavedUsername = false,
  }) {
    return AuthState(
      isBootstrapped: isBootstrapped ?? this.isBootstrapped,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: clearUser ? null : (user ?? this.user),
      rememberMe: rememberMe ?? this.rememberMe,
      savedUsername:
          clearSavedUsername ? null : (savedUsername ?? this.savedUsername),
    );
  }
}
