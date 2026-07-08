import 'package:flutter_test/flutter_test.dart';
import 'package:itctc/features/forms/shared/models/form_table_header.dart';
import 'package:itctc/features/forms/t8/data/t8_table_columns.dart';

void main() {
  group('headerColumnBoundaryVisibleInRow', () {
    test('hides divider inside colspan parent row for Chainage', () {
      final placed = buildPlacedHeaderCells(t8TableDefinition);

      // Chainage spans columns 1-3 (km, m, cm). Divider between km|m is boundary 1.
      expect(
        headerColumnBoundaryVisibleInRow(
          placed: placed,
          boundaryAfterCol: 1,
          row: 0,
        ),
        isFalse,
      );
      expect(
        headerColumnBoundaryVisibleInRow(
          placed: placed,
          boundaryAfterCol: 2,
          row: 0,
        ),
        isFalse,
      );

      // Sub-header row should show km|m and m|cm dividers.
      expect(
        headerColumnBoundaryVisibleInRow(
          placed: placed,
          boundaryAfterCol: 1,
          row: 1,
        ),
        isTrue,
      );
      expect(
        headerColumnBoundaryVisibleInRow(
          placed: placed,
          boundaryAfterCol: 2,
          row: 1,
        ),
        isTrue,
      );
    });

    test('shows divider beside rowspan cells on every row', () {
      final placed = buildPlacedHeaderCells(t8TableDefinition);

      // Up/Down (col 0) | Chainage (cols 1-3): boundary after col 0.
      expect(
        headerColumnBoundaryVisibleInRow(
          placed: placed,
          boundaryAfterCol: 0,
          row: 0,
        ),
        isTrue,
      );
      expect(
        headerColumnBoundaryVisibleInRow(
          placed: placed,
          boundaryAfterCol: 0,
          row: 1,
        ),
        isTrue,
      );
    });
  });
}
