import '../models/form_info.dart';

/// Collapses spacing, punctuation, and casing so queries like `t8` match `T-8`.
String normalizeForFormSearch(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

bool formMatchesSearchQuery(FormInfo form, String query) {
  final normalizedQuery = normalizeForFormSearch(query.trim());
  if (normalizedQuery.isEmpty) return true;

  final haystacks = [
    form.id,
    form.code,
    form.title,
    form.formatName,
    form.category.label,
  ];

  return haystacks.any(
    (field) => normalizeForFormSearch(field).contains(normalizedQuery),
  );
}
