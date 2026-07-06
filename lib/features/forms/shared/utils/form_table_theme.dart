import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Theme-aware colors for form data tables in light and dark mode.
class FormTableTheme {
  FormTableTheme._();

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color border(BuildContext context) => _isDark(context)
      ? AppColors.darkTableBorder
      : AppColors.lightTableBorder;

  static Color headerBackground(BuildContext context) => _isDark(context)
      ? AppColors.darkTableHeader
      : AppColors.lightTableHeader;

  static Color bodyBackground(BuildContext context) => _isDark(context)
      ? AppColors.darkTableBody
      : AppColors.lightTableBody;

  static Color headerText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color bodyText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color mutedText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;
}
