import 'form_table_column.dart';

/// A cell in a multi-row table header.
class FormTableHeaderCell {
  const FormTableHeaderCell({
    required this.label,
    this.colSpan = 1,
    this.rowSpan = 1,
  });

  final String label;
  final int colSpan;
  final int rowSpan;
}

/// Full table definition: multi-row headers + leaf data columns.
class FormTableDefinition {
  const FormTableDefinition({
    required this.headerRows,
    required this.columns,
  });

  final List<List<FormTableHeaderCell>> headerRows;
  final List<FormTableColumn> columns;

  double get totalWidth =>
      columns.fold<double>(0, (sum, column) => sum + column.minWidth);
}

class PlacedHeaderCell {
  const PlacedHeaderCell({
    required this.row,
    required this.col,
    required this.colSpan,
    required this.rowSpan,
    required this.label,
  });

  final int row;
  final int col;
  final int colSpan;
  final int rowSpan;
  final String label;

  double width(List<FormTableColumn> columns) {
    var total = 0.0;
    for (var i = col; i < col + colSpan && i < columns.length; i++) {
      total += columns[i].minWidth;
    }
    return total;
  }
}

List<PlacedHeaderCell> buildPlacedHeaderCells(FormTableDefinition definition) {
  final columnCount = definition.columns.length;
  final rowCount = definition.headerRows.length;
  final occupied = List.generate(
    rowCount,
    (_) => List.filled(columnCount, false),
  );
  final placed = <PlacedHeaderCell>[];

  for (var row = 0; row < rowCount; row++) {
    var col = 0;
    for (final cell in definition.headerRows[row]) {
      while (col < columnCount && occupied[row][col]) {
        col++;
      }
      if (col >= columnCount) break;

      placed.add(
        PlacedHeaderCell(
          row: row,
          col: col,
          colSpan: cell.colSpan,
          rowSpan: cell.rowSpan,
          label: cell.label,
        ),
      );

      for (var r = row; r < row + cell.rowSpan && r < rowCount; r++) {
        for (var c = col; c < col + cell.colSpan && c < columnCount; c++) {
          occupied[r][c] = true;
        }
      }
      col += cell.colSpan;
    }
  }

  return placed;
}

/// Whether a vertical divider may be drawn between [boundaryAfterCol] and the next
/// column on header [row]. Returns false when a merged parent cell spans both sides.
bool headerColumnBoundaryVisibleInRow({
  required List<PlacedHeaderCell> placed,
  required int boundaryAfterCol,
  required int row,
}) {
  for (final cell in placed) {
    if (row < cell.row || row >= cell.row + cell.rowSpan) continue;
    if (cell.col <= boundaryAfterCol &&
        cell.col + cell.colSpan > boundaryAfterCol + 1) {
      return false;
    }
  }
  return true;
}
