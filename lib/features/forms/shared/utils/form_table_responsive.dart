import 'package:flutter/material.dart';

import '../models/form_table_column.dart';

/// Responsive sizing for wide form tables on phones, tablets, and large screens.
class FormTableMetrics {
  const FormTableMetrics({
    required this.viewportWidth,
    required this.columnScale,
    required this.headerFontSize,
    required this.dataFontSize,
    required this.headerPaddingH,
    required this.headerPaddingV,
    required this.dataPaddingH,
    required this.dataPaddingV,
    required this.minRowHeight,
    required this.isCompact,
    required this.isTablet,
  });

  factory FormTableMetrics.fromConstraints(BoxConstraints constraints) {
    final viewportWidth =
        constraints.maxWidth.isFinite ? constraints.maxWidth : 360.0;

    if (viewportWidth >= 900) {
      return FormTableMetrics(
        viewportWidth: viewportWidth,
        columnScale: 1.05,
        headerFontSize: 11,
        dataFontSize: 12,
        headerPaddingH: 8,
        headerPaddingV: 10,
        dataPaddingH: 8,
        dataPaddingV: 12,
        minRowHeight: 52,
        isCompact: false,
        isTablet: true,
      );
    }

    if (viewportWidth >= 600) {
      return FormTableMetrics(
        viewportWidth: viewportWidth,
        columnScale: 1.0,
        headerFontSize: 10,
        dataFontSize: 11,
        headerPaddingH: 7,
        headerPaddingV: 9,
        dataPaddingH: 7,
        dataPaddingV: 11,
        minRowHeight: 48,
        isCompact: false,
        isTablet: true,
      );
    }

    if (viewportWidth >= 360) {
      return FormTableMetrics(
        viewportWidth: viewportWidth,
        columnScale: 0.95,
        headerFontSize: 10,
        dataFontSize: 11,
        headerPaddingH: 6,
        headerPaddingV: 8,
        dataPaddingH: 6,
        dataPaddingV: 10,
        minRowHeight: 48,
        isCompact: false,
        isTablet: false,
      );
    }

    return FormTableMetrics(
      viewportWidth: viewportWidth,
      columnScale: 0.9,
      headerFontSize: 9,
      dataFontSize: 10,
      headerPaddingH: 4,
      headerPaddingV: 7,
      dataPaddingH: 4,
      dataPaddingV: 9,
      minRowHeight: 44,
      isCompact: true,
      isTablet: false,
    );
  }

  final double viewportWidth;
  final double columnScale;
  final double headerFontSize;
  final double dataFontSize;
  final double headerPaddingH;
  final double headerPaddingV;
  final double dataPaddingH;
  final double dataPaddingV;
  final double minRowHeight;
  final bool isCompact;
  final bool isTablet;

  double scaledWidth(double baseWidth) =>
      (baseWidth * columnScale).clamp(44.0, baseWidth * 1.1);

  bool needsHorizontalScroll(double tableWidth) =>
      tableWidth > viewportWidth + 1;
}

class ScaledFormTableColumn {
  const ScaledFormTableColumn({
    required this.column,
    required this.width,
  });

  final FormTableColumn column;
  final double width;
}

List<ScaledFormTableColumn> buildScaledColumns(
  List<FormTableColumn> columns,
  FormTableMetrics metrics,
) {
  return columns
      .map(
        (c) => ScaledFormTableColumn(
          column: c,
          width: metrics.scaledWidth(c.minWidth),
        ),
      )
      .toList();
}

double scaledTableWidth(
  List<FormTableColumn> columns,
  FormTableMetrics metrics,
) {
  return buildScaledColumns(columns, metrics)
      .fold<double>(0, (sum, c) => sum + c.width);
}
