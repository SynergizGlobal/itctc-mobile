import '../models/form_table_column.dart';

/// Picks a few useful paper-table fields for inspection list cards.
List<MapEntry<String, String>> buildInspectionHighlights({
  required List<FormTableColumn> columns,
  required Map<String, dynamic> row,
  int max = 6,
}) {
  if (columns.isEmpty || max <= 0) return const [];

  final candidates = <({int score, String title, String value})>[];

  for (final column in columns) {
    final value = column.value(row, 0).trim();
    if (value.isEmpty || value == '—') continue;

    final title = column.title.replaceAll('\n', ' ').trim();
    if (title.isEmpty) continue;

    final lower = title.toLowerCase();
    var score = 1;
    if (lower.endsWith(' i') || lower.contains('irregularity')) {
      score += 40;
    } else if (lower.contains('measured') || lower.endsWith(' m')) {
      score += 20;
    } else if (lower == 'km' || lower == 'm' || lower.contains('chainage')) {
      score += 15;
    } else if (lower.contains('attach') || lower.contains('file')) {
      score += 12;
    } else if (lower.contains('gauge') ||
        lower.contains('twist') ||
        lower.contains('cant') ||
        lower.contains('width')) {
      score += 10;
    }

    candidates.add((score: score, title: title, value: value));
  }

  candidates.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    return a.title.compareTo(b.title);
  });

  final seen = <String>{};
  final highlights = <MapEntry<String, String>>[];
  for (final item in candidates) {
    if (highlights.length >= max) break;
    if (!seen.add(item.title)) continue;
    highlights.add(MapEntry(item.title, item.value));
  }
  return highlights;
}
