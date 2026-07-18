import 'package:flutter_test/flutter_test.dart';
import 'package:itctc/core/preferences/inspection_list_view_mode.dart';
import 'package:itctc/features/forms/shared/models/form_table_column.dart';
import 'package:itctc/features/forms/shared/utils/inspection_list_highlights.dart';
import 'package:itctc/features/forms/t2/data/t2_table_columns.dart';

void main() {
  test('InspectionListViewMode defaults to cards', () {
    expect(
      InspectionListViewMode.fromStorage(null),
      InspectionListViewMode.cards,
    );
    expect(
      InspectionListViewMode.fromStorage('table'),
      InspectionListViewMode.table,
    );
  });

  test('buildInspectionHighlights prefers irregularity fields', () {
    final row = {
      'chainageKm': 12,
      'chainageM': 345,
      'downLine': {
        'twist': {
          'design': 0,
          'measured': 1,
          'irregularity': 1.2,
        },
        'gauge': {
          'design': 1435,
          'measured': 1435.5,
          'irregularity': 0.5,
        },
      },
      'upLine': {
        'twist': {
          'design': 0,
          'measured': 0.5,
          'irregularity': 0.8,
        },
        'gauge': {
          'design': 1435,
          'measured': 1435.3,
          'irregularity': 0.3,
        },
      },
      'attachments': [
        {'id': 'a'},
      ],
    };

    final highlights = buildInspectionHighlights(
      columns: t2TableDefinition.columns,
      row: row,
    );

    expect(highlights, isNotEmpty);
    expect(highlights.length, lessThanOrEqualTo(6));
    expect(
      highlights.any((e) => e.key.toLowerCase().contains('twist') || e.key.endsWith('I')),
      isTrue,
    );
  });

  test('buildInspectionHighlights skips empty values', () {
    final highlights = buildInspectionHighlights(
      columns: [
        FormTableColumn(title: 'Empty', value: (_, __) => '—'),
        FormTableColumn(title: 'Filled', value: (_, __) => 'OK'),
      ],
      row: const {},
    );
    expect(highlights, hasLength(1));
    expect(highlights.first.key, 'Filled');
    expect(highlights.first.value, 'OK');
  });
}
