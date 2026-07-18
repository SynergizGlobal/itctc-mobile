import '../models/auth_user.dart';
import '../models/user_role.dart';

/// Local demo credentials until backend auth is connected.
///
/// Short usernames for quick typing. Password for all: `1234`
class AuthCredentials {
  AuthCredentials._();

  static const demoPassword = '1234';

  static const inspector = AuthUser(
    username: 'in',
    displayName: 'Field Inspector',
    role: UserRole.inspector,
  );

  static const pmc = AuthUser(
    username: 'pmc',
    displayName: 'PMC Reviewer',
    role: UserRole.pmc,
  );

  static const itcEngineer = AuthUser(
    username: 'itc',
    displayName: 'ITC Engineer',
    role: UserRole.itcEngineer,
  );

  /// Default test / fallback user (Inspector).
  static const demoUser = inspector;

  static const List<AuthUser> allUsers = [
    inspector,
    pmc,
    itcEngineer,
  ];

  /// Older demo usernames still accepted so remembered sessions keep working.
  static const Map<String, String> _aliases = {
    'itctc_in_001': 'in',
    'itctc_pmc_001': 'pmc',
    'itctc_itc_001': 'itc',
    'inspector': 'in',
  };

  static AuthUser? validate(String username, String password) {
    if (password != demoPassword) return null;
    return userFor(username);
  }

  static AuthUser? userFor(String username) {
    var key = username.trim().toLowerCase();
    key = _aliases[key] ?? key;
    for (final user in allUsers) {
      if (user.username.toLowerCase() == key) return user;
    }
    return null;
  }
}
