import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/form_catalog.dart';
import '../models/form_info.dart';
import '../utils/form_search.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredFormsProvider = Provider<List<FormInfo>>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return FormCatalog.allForms;

  return FormCatalog.allForms
      .where((form) => formMatchesSearchQuery(form, query))
      .toList();
});
