class FormTableColumn {
  const FormTableColumn({
    required this.title,
    required this.value,
    this.minWidth = 100,
  });

  final String title;
  final String Function(Map<String, dynamic> row, int rowIndex) value;
  final double minWidth;
}

String tableCell(dynamic value) {
  if (value == null) return '—';
  final text = value.toString().trim();
  return text.isEmpty ? '—' : text;
}

String chainageDisplay(Map<String, dynamic> row, {required String kmKey, required String mKey}) {
  final km = tableCell(row[kmKey]);
  final m = tableCell(row[mKey]);
  if (km == '—' && m == '—') return '—';
  return '$km+$m';
}

String attachmentsTableCell(dynamic value) {
  if (value is! List || value.isEmpty) return '—';
  final count = value.length;
  if (count == 1) {
    final first = value.first;
    if (first is Map && first['name'] != null) {
      final name = first['name'].toString().trim();
      if (name.isNotEmpty) return name;
    }
  }
  return '$count file${count == 1 ? '' : 's'}';
}
