import 'package:flutter_test/flutter_test.dart';
import 'package:itctc/features/auth/models/user_role.dart';

void main() {
  group('UserRole', () {
    test('ITC role label is ITC Engineer everywhere', () {
      expect(UserRole.itcEngineer.label, 'ITC Engineer');
      expect(UserRole.itcEngineer.shortLabel, 'ITC Engineer');
      expect(UserRole.itcEngineer.label, isNot(contains('Preconfirmation')));
    });

    test('displayLabel maps api codes and legacy names', () {
      expect(UserRole.displayLabel('ITC_ENGINEER'), 'ITC Engineer');
      expect(UserRole.displayLabel('ITC Engineer'), 'ITC Engineer');
      expect(
        UserRole.displayLabel('ITC Preconfirmation Engineer'),
        'ITC Engineer',
      );
      expect(UserRole.displayLabel('PMC'), 'PMC');
      expect(UserRole.displayLabel('INSPECTOR'), 'Inspector');
    });
  });
}
