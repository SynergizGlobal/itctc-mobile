import 'package:flutter_test/flutter_test.dart';
import 'package:itctc/features/home/data/form_catalog.dart';
import 'package:itctc/features/home/models/form_info.dart';
import 'package:itctc/features/home/utils/form_search.dart';

void main() {
  FormInfo formById(String id) => FormCatalog.getById(id)!;

  group('formMatchesSearchQuery', () {
    test('matches form code without hyphen', () {
      final t8 = formById('t8');

      expect(formMatchesSearchQuery(t8, 't8'), isTrue);
      expect(formMatchesSearchQuery(t8, 'T8'), isTrue);
      expect(formMatchesSearchQuery(t8, 't-8'), isTrue);
      expect(formMatchesSearchQuery(t8, 'form t8'), isTrue);
    });

    test('matches multi-part form codes', () {
      final t72 = formById('t7-2');

      expect(formMatchesSearchQuery(t72, 't72'), isTrue);
      expect(formMatchesSearchQuery(t72, 't7-2'), isTrue);
      expect(formMatchesSearchQuery(t72, 't7 2'), isTrue);
    });

    test('matches title text without punctuation', () {
      final t8 = formById('t8');

      expect(formMatchesSearchQuery(t8, 'sleeper spacing'), isTrue);
      expect(formMatchesSearchQuery(t8, 'squareness'), isTrue);
    });

    test('does not match unrelated queries', () {
      final t8 = formById('t8');

      expect(formMatchesSearchQuery(t8, 't10'), isFalse);
      expect(formMatchesSearchQuery(t8, 'noise'), isFalse);
    });
  });
}
