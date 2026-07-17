import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/form_catalog.dart';
import '../models/form_info.dart';
import '../utils/form_search.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredFormsProvider = Provider<List<FormInfo>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final catalogOrder = {
    for (var i = 0; i < FormCatalog.allForms.length; i++)
      FormCatalog.allForms[i].id: i,
  };

  final forms = FormCatalog.allForms
      .where((form) => form.isImplemented)
      .where((form) => formMatchesSearchQuery(form, query))
      .toList()
    ..sort((a, b) => catalogOrder[a.id]!.compareTo(catalogOrder[b.id]!));

  return forms;
});
