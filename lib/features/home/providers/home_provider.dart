import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/form_catalog.dart';
import '../models/form_info.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredFormsProvider = Provider<List<FormInfo>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  if (query.isEmpty) return FormCatalog.allForms;

  return FormCatalog.allForms.where((form) {
    return form.code.toLowerCase().contains(query) ||
        form.title.toLowerCase().contains(query) ||
        form.description.toLowerCase().contains(query) ||
        form.category.label.toLowerCase().contains(query);
  }).toList();
});
