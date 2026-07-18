import '../models/auth_user.dart';
import '../models/user_role.dart';

/// Local demo credentials until backend auth is connected.
///
/// Password for all demo accounts: `1234`
class AuthCredentials {
  AuthCredentials._();

  static const demoPassword = '1234';

  static const inspector = AuthUser(
    username: 'itctc_in_001',
    displayName: 'Field Inspector',
    role: UserRole.inspector,
  );

  static const pmc = AuthUser(
    username: 'itctc_pmc_001',
    displayName: 'PMC Reviewer',
    role: UserRole.pmc,
  );

  static const itcEngineer = AuthUser(
    username: 'itctc_itc_001',
    displayName: 'ITC Preconfirmation Engineer',
    role: UserRole.itcEngineer,
  );

  /// Default test / fallback user (Inspector).
  static const demoUser = inspector;

  static const List<AuthUser> allUsers = [
    inspector,
    pmc,
    itcEngineer,
  ];

  static AuthUser? validate(String username, String password) {
    if (password != demoPassword) return null;
    return userFor(username);
  }

  static AuthUser? userFor(String username) {
    final key = username.trim().toLowerCase();
    for (final user in allUsers) {
      if (user.username.toLowerCase() == key) return user;
    }
    return null;
  }
}
