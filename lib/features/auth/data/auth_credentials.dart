import '../models/auth_user.dart';

/// Temporary local credentials until PMIS API integration.
class AuthCredentials {
  AuthCredentials._();

  static const demoUsername = 'pmis_it_001';
  static const demoPassword = '1234';

  static const demoUser = AuthUser(
    username: demoUsername,
    displayName: 'Nihal - IT admin',
    role: 'IT Admin',
  );

  static AuthUser? validate(String username, String password) {
    if (username.trim().toLowerCase() == demoUsername &&
        password == demoPassword) {
      return demoUser;
    }
    return null;
  }

  static AuthUser? userFor(String username) {
    if (username.trim().toLowerCase() == demoUsername) {
      return demoUser;
    }
    return null;
  }
}
