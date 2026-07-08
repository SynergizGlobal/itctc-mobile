import 'package:flutter/material.dart';

import '../models/form_table_column.dart';
import '../models/form_table_header.dart';
import '../utils/form_table_responsive.dart';
import '../utils/form_table_theme.dart';

/// Horizontally scrollable form table matching paper form layout.
/// Adapts column sizing, typography, and scroll affordances to screen width.
class FormDataTable extends StatefulWidget {
  const FormDataTable({
    super.key,
    this.definition,
    this.columns,
    required this.rows,
    this.onRowTap,
    this.emptyMessage = 'No records yet.\nTap Add to enter data.',
  }) : assert(definition != null || columns != null);

  final FormTableDefinition? definition;
  final List<FormTableColumn>? columns;
  final List<Map<String, dynamic>> rows;
  final void Function(int index)? onRowTap;
  final String emptyMessage;

  @override
  State<FormDataTable> createState() => _FormDataTableState();
}

class _FormDataTableState extends State<FormDataTable> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  List<FormTableColumn> get _columns =>
      widget.definition?.columns ?? widget.columns!;

  ScrollPhysics get _scrollPhysics {
    final platform = Theme.of(context).platform;
    return switch (platform) {
      TargetPlatform.iOS || TargetPlatform.macOS => const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
      _ => const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = FormTableMetrics.fromConstraints(constraints);
        final scaledColumns = buildScaledColumns(_columns, metrics);
        final tableWidth = scaledColumns.fold<double>(
          0,
          (sum, c) => sum + c.width,
        );
        final theme = Theme.of(context);
        final borderColor = FormTableTheme.border(context);
        final headerBg = FormTableTheme.headerBackground(context);
        final bodyBg = FormTableTheme.bodyBackground(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: widget.rows.isEmpty
                  ? _EmptyTableFrame(
                      definition: widget.definition,
                      scaledColumns: scaledColumns,
                      metrics: metrics,
                      borderColor: borderColor,
                      headerBg: headerBg,
                      bodyBg: bodyBg,
                      message: widget.emptyMessage,
                      tableWidth: tableWidth,
                      horizontalController: _horizontalController,
                      scrollPhysics: _scrollPhysics,
                    )
                  : Scrollbar(
                      controller: _verticalController,
                      thumbVisibility: metrics.isTablet,
                      child: SingleChildScrollView(
                        controller: _verticalController,
                        physics: _scrollPhysics,
                        child: Scrollbar(
                          controller: _horizontalController,
                          thumbVisibility: true,
                          notificationPredicate: (notification) =>
                              notification.depth == 1,
                          child: SingleChildScrollView(
                            controller: _horizontalController,
                            scrollDirection: Axis.horizontal,
                            physics: _scrollPhysics,
                            child: SizedBox(
                              width: tableWidth,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _MultiRowHeader(
                                    definition: widget.definition,
                                    scaledColumns: scaledColumns,
                                    metrics: metrics,
                                    borderColor: borderColor,
                                    headerBg: headerBg,
                                    tableWidth: tableWidth,
                                  ),
                                  _DataTableBody(
                                    scaledColumns: scaledColumns,
                                    metrics: metrics,
                                    rows: widget.rows,
                                    borderColor: borderColor,
                                    bodyBg: bodyBg,
                                    onRowTap: widget.onRowTap,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            if (widget.rows.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Text(
                  '${widget.rows.length} ${widget.rows.length == 1 ? 'record' : 'records'}',
                  style: theme.textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MultiRowHeader extends StatelessWidget {
  const _MultiRowHeader({
    required this.definition,
    required this.scaledColumns,
    required this.metrics,
    required this.borderColor,
    required this.headerBg,
    required this.tableWidth,
  });

  final FormTableDefinition? definition;
  final List<ScaledFormTableColumn> scaledColumns;
  final FormTableMetrics metrics;
  final Color borderColor;
  final Color headerBg;
  final double tableWidth;

  List<FormTableColumn> get _baseColumns =>
      scaledColumns.map((c) => c.column).toList();

  List<double> get _widths => scaledColumns.map((c) => c.width).toList();

  TableBorder get _headerBorder => TableBorder.all(
        color: borderColor,
        width: 1,
      );

  Map<int, TableColumnWidth> get _columnWidths => {
        for (var i = 0; i < scaledColumns.length; i++)
          i: FixedColumnWidth(_widths[i]),
      };

  PlacedHeaderCell? _cellAt(List<PlacedHeaderCell> placed, int row, int col) {
    for (final cell in placed) {
      if (row >= cell.row &&
          row < cell.row + cell.rowSpan &&
          col >= cell.col &&
          col < cell.col + cell.colSpan) {
        return cell;
      }
    }
    return null;
  }

  double _cellWidth(PlacedHeaderCell cell) {
    var total = 0.0;
    for (var i = cell.col; i < cell.col + cell.colSpan; i++) {
      total += _widths[i];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (definition == null || definition!.headerRows.isEmpty) {
      return Table(
        border: _headerBorder,
        columnWidths: _columnWidths,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            decoration: BoxDecoration(color: headerBg),
            children: scaledColumns
                .map(
                  (c) => _HeaderCell(
                    title: c.column.title,
                    metrics: metrics,
                  ),
                )
                .toList(),
          ),
        ],
      );
    }

    final placed = buildPlacedHeaderCells(definition!);
    final rowCount = definition!.headerRows.length;
    final columnCount = _baseColumns.length;
    final rowHeight = metrics.minRowHeight * 0.75;
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

    return SizedBox(
      width: tableWidth,
      child: ColoredBox(
        color: headerBg,
        child: CustomPaint(
          foregroundPainter: _HeaderGridPainter(
            columnWidths: _widths,
            rowCount: rowCount,
            rowHeight: rowHeight,
            borderColor: borderColor,
            placed: placed,
            devicePixelRatio: devicePixelRatio,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(rowCount, (rowIndex) {
              final children = <Widget>[];
              var col = 0;

              while (col < columnCount) {
                final owner = _cellAt(placed, rowIndex, col);
                final isAnchor = owner != null &&
                    owner.row == rowIndex &&
                    owner.col == col;

                if (isAnchor) {
                  children.add(
                    SizedBox(
                      width: _cellWidth(owner),
                      height: rowHeight,
                      child: _HeaderCell(
                        title: owner.label,
                        metrics: metrics,
                      ),
                    ),
                  );
                  col += owner.colSpan;
                } else {
                  children.add(
                    SizedBox(
                      width: _widths[col],
                      height: rowHeight,
                    ),
                  );
                  col++;
                }
              }

              return SizedBox(
                width: tableWidth,
                height: rowHeight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _HeaderGridPainter extends CustomPainter {
  const _HeaderGridPainter({
    required this.columnWidths,
    required this.rowCount,
    required this.rowHeight,
    required this.borderColor,
    required this.placed,
    required this.devicePixelRatio,
  });

  final List<double> columnWidths;
  final int rowCount;
  final double rowHeight;
  final Color borderColor;
  final List<PlacedHeaderCell> placed;
  final double devicePixelRatio;

  double get _strokeWidth => 1 / devicePixelRatio;

  double _snap(double value) {
    final step = _strokeWidth;
    return (value / step).round() * step;
  }

  bool _spansAcrossRowBoundary(int boundaryRow, int col) {
    for (final cell in placed) {
      if (col >= cell.col &&
          col < cell.col + cell.colSpan &&
          cell.row < boundaryRow &&
          boundaryRow < cell.row + cell.rowSpan) {
        return true;
      }
    }
    return false;
  }

  bool _columnBoundarySpannedInRow(int boundaryAfterCol, int row) {
    return !headerColumnBoundaryVisibleInRow(
      placed: placed,
      boundaryAfterCol: boundaryAfterCol,
      row: row,
    );
  }

  double _columnOffset(int col) {
    var x = 0.0;
    for (var i = 0; i < col; i++) {
      x += columnWidths[i];
    }
    return x;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = _strokeWidth
      ..isAntiAlias = false
      ..style = PaintingStyle.stroke;

    final half = _strokeWidth / 2;
    final tableWidth = size.width;
    final tableHeight = size.height;

    // Outer border
    canvas.drawRect(
      Rect.fromLTWH(half, half, tableWidth - _strokeWidth, tableHeight - _strokeWidth),
      paint,
    );

    // Vertical column dividers — skip rows where a colspan parent spans the boundary.
    for (var boundaryAfterCol = 0;
        boundaryAfterCol < columnWidths.length - 1;
        boundaryAfterCol++) {
      final lineX = _snap(_columnOffset(boundaryAfterCol + 1));

      for (var row = 0; row < rowCount; row++) {
        if (_columnBoundarySpannedInRow(boundaryAfterCol, row)) continue;

        final yTop = _snap(row * rowHeight);
        final yBottom = _snap((row + 1) * rowHeight);
        canvas.drawLine(
          Offset(lineX, yTop),
          Offset(lineX, yBottom),
          paint,
        );
      }
    }

    // Horizontal row dividers — skip segments inside row-span merged cells
    for (var boundary = 1; boundary < rowCount; boundary++) {
      final y = _snap(boundary * rowHeight);
      var segmentStart = 0.0;
      var col = 0;

      while (col < columnWidths.length) {
        if (_spansAcrossRowBoundary(boundary, col)) {
          final segmentEnd = _columnOffset(col);
          if (segmentEnd > segmentStart + half) {
            canvas.drawLine(
              Offset(segmentStart, y),
              Offset(segmentEnd, y),
              paint,
            );
          }
          segmentStart = _columnOffset(col + 1);
          col++;
        } else {
          col++;
        }
      }

      if (tableWidth > segmentStart + half) {
        canvas.drawLine(
          Offset(segmentStart, y),
          Offset(tableWidth, y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeaderGridPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.rowCount != rowCount ||
        oldDelegate.rowHeight != rowHeight ||
        oldDelegate.columnWidths != columnWidths ||
        oldDelegate.placed != placed ||
        oldDelegate.devicePixelRatio != devicePixelRatio;
  }
}

class _DataTableBody extends StatelessWidget {
  const _DataTableBody({
    required this.scaledColumns,
    required this.metrics,
    required this.rows,
    required this.borderColor,
    required this.bodyBg,
    this.onRowTap,
  });

  final List<ScaledFormTableColumn> scaledColumns;
  final FormTableMetrics metrics;
  final List<Map<String, dynamic>> rows;
  final Color borderColor;
  final Color bodyBg;
  final void Function(int index)? onRowTap;

  BorderSide get _borderSide => BorderSide(color: borderColor, width: 1);

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder(
        left: _borderSide,
        right: _borderSide,
        bottom: _borderSide,
        horizontalInside: _borderSide,
        verticalInside: _borderSide,
      ),
      columnWidths: {
        for (var i = 0; i < scaledColumns.length; i++)
          i: FixedColumnWidth(scaledColumns[i].width),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows.asMap().entries.map((entry) {
        final index = entry.key;
        final row = entry.value;
        return TableRow(
          decoration: BoxDecoration(color: bodyBg),
          children: scaledColumns
              .map(
                (c) => _DataCell(
                  text: c.column.value(row, index),
                  metrics: metrics,
                  onTap: onRowTap != null ? () => onRowTap!(index) : null,
                ),
              )
              .toList(),
        );
      }).toList(),
    );
  }
}

class _EmptyTableFrame extends StatelessWidget {
  const _EmptyTableFrame({
    required this.definition,
    required this.scaledColumns,
    required this.metrics,
    required this.borderColor,
    required this.headerBg,
    required this.bodyBg,
    required this.message,
    required this.tableWidth,
    required this.horizontalController,
    required this.scrollPhysics,
  });

  final FormTableDefinition? definition;
  final List<ScaledFormTableColumn> scaledColumns;
  final FormTableMetrics metrics;
  final Color borderColor;
  final Color headerBg;
  final Color bodyBg;
  final String message;
  final double tableWidth;
  final ScrollController horizontalController;
  final ScrollPhysics scrollPhysics;

  BorderSide get _borderSide => BorderSide(color: borderColor, width: 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scrollbar(
      controller: horizontalController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: horizontalController,
        scrollDirection: Axis.horizontal,
        physics: scrollPhysics,
        child: SizedBox(
          width: tableWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MultiRowHeader(
                definition: definition,
                scaledColumns: scaledColumns,
                metrics: metrics,
                borderColor: borderColor,
                headerBg: headerBg,
                tableWidth: tableWidth,
              ),
              Container(
                width: tableWidth,
                color: bodyBg,
                constraints: BoxConstraints(
                  minHeight: metrics.isTablet ? 280 : 220,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: metrics.isTablet ? 56 : 40,
                  horizontal: metrics.isCompact ? 16 : 24,
                ),
                foregroundDecoration: BoxDecoration(
                  border: Border(
                    left: _borderSide,
                    right: _borderSide,
                    bottom: _borderSide,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.table_rows_rounded,
                      size: metrics.isTablet ? 48 : 40,
                      color: FormTableTheme.mutedText(context),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: FormTableTheme.mutedText(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.title,
    required this.metrics,
  });

  final String title;
  final FormTableMetrics metrics;

  @override
  Widget build(BuildContext context) {
    if (title.trim().isEmpty) {
      return SizedBox(height: metrics.minRowHeight * 0.75);
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.headerPaddingH,
        vertical: metrics.headerPaddingV,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
              fontSize: metrics.headerFontSize,
              color: FormTableTheme.headerText(context),
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({
    required this.text,
    required this.metrics,
    this.onTap,
  });

  final String text;
  final FormTableMetrics metrics;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = ConstrainedBox(
      constraints: BoxConstraints(minHeight: metrics.minRowHeight),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: metrics.dataPaddingH,
          vertical: metrics.dataPaddingV,
        ),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: metrics.dataFontSize,
                  color: FormTableTheme.bodyText(context),
                ),
            maxLines: metrics.isCompact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    if (onTap == null) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: child),
    );
  }
}
