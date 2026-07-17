import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itctc/features/home/data/form_catalog.dart';
import 'package:itctc/features/home/providers/home_provider.dart';

void main() {
  test('filteredFormsProvider shows only ready forms', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final forms = container.read(filteredFormsProvider);

    expect(forms, isNotEmpty);
    expect(forms.every((form) => form.isImplemented), isTrue);
    expect(forms.length, FormCatalog.readyCount);
  });
}
