import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const double appBarToolbarHeight = 64;
  static const double appBarIconSize = 26;

  static TextStyle appBarTitleStyle(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.2,
      );

  static TextStyle appBarSubtitleStyle(Color color) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.25,
      );

  static AppBarTheme _appBarTheme({
    required Color background,
    required Color foreground,
  }) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      toolbarHeight: appBarToolbarHeight,
      backgroundColor: background,
      foregroundColor: foreground,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: appBarTitleStyle(foreground),
      iconTheme: IconThemeData(color: foreground, size: appBarIconSize),
      actionsIconTheme: IconThemeData(color: foreground, size: appBarIconSize),
      titleSpacing: 16,
    );
  }

  static TextTheme _buildTextTheme({
    required Color primary,
    required Color secondary,
    required Color tertiary,
  }) {
    final base = GoogleFonts.plusJakartaSans;
    return TextTheme(
      displayLarge: base(fontSize: 32, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5),
      displayMedium: base(fontSize: 28, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.25),
      headlineLarge: base(fontSize: 22, fontWeight: FontWeight.w700, color: primary),
      headlineMedium: base(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      headlineSmall: base(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      titleLarge: base(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      titleMedium: base(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      titleSmall: base(fontSize: 13, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: base(fontSize: 16, fontWeight: FontWeight.w400, color: primary, height: 1.5),
      bodyMedium: base(fontSize: 14, fontWeight: FontWeight.w400, color: primary, height: 1.5),
      bodySmall: base(fontSize: 12, fontWeight: FontWeight.w400, color: secondary, height: 1.4),
      labelLarge: base(fontSize: 14, fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.1),
      labelMedium: base(fontSize: 12, fontWeight: FontWeight.w500, color: secondary, letterSpacing: 0.3),
      labelSmall: base(fontSize: 11, fontWeight: FontWeight.w500, color: tertiary, letterSpacing: 0.3),
    );
  }

  static ThemeData light() {
    const onSurface = AppColors.lightTextPrimary;
    const onSurfaceVariant = AppColors.lightTextSecondary;
    const onSurfaceMuted = AppColors.lightTextTertiary;

    final colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.accentContainer,
      onTertiaryContainer: AppColors.onAccentContainer,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorderSubtle,
      surfaceContainerHighest: AppColors.lightBorderSubtle,
      surfaceContainerHigh: AppColors.lightInputFill,
      surfaceContainer: AppColors.lightBackground,
    );

    final textTheme = _buildTextTheme(
      primary: onSurface,
      secondary: onSurfaceVariant,
      tertiary: onSurfaceMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      dividerColor: AppColors.lightTableBorder,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: textTheme,
      iconTheme: const IconThemeData(color: onSurfaceVariant, size: 24),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          iconSize: appBarIconSize,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.all(10),
        ),
      ),
      appBarTheme: _appBarTheme(
        background: AppColors.lightSurface,
        foreground: onSurface,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.lightCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorderSubtle),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightInputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: onSurfaceVariant),
        floatingLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: onSurfaceMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.lightBorder,
          disabledForegroundColor: onSurfaceMuted,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return onSurfaceVariant;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.primary;
            return AppColors.lightInputFill;
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.lightBorder),
          ),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: onSurfaceMuted,
        indicatorColor: AppColors.primary,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500),
        dividerColor: AppColors.lightBorderSubtle,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightInputFill,
        selectedColor: AppColors.primaryContainer,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: onSurface),
        secondaryLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: onSurfaceVariant),
        side: const BorderSide(color: AppColors.lightBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        iconTheme: const IconThemeData(color: AppColors.primary, size: 18),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightTableBorder,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: onSurfaceVariant,
        textColor: onSurface,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        subtitleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: onSurfaceVariant,
        ),
      ),
    );
  }

  static ThemeData dark() {
    const onSurface = AppColors.darkTextPrimary;
    const onSurfaceVariant = AppColors.darkTextSecondary;
    const onSurfaceMuted = AppColors.darkTextTertiary;

    final colorScheme = ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      primaryContainer: AppColors.calculatedFieldDark,
      onPrimaryContainer: AppColors.calculatedFieldTextDark,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.onSecondaryContainer,
      onSecondaryContainer: AppColors.secondaryContainer,
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.onAccentContainer,
      onTertiaryContainer: AppColors.accentContainer,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.darkSurface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.inactiveStepDark,
      surfaceContainerHighest: AppColors.inactiveStepDark,
      surfaceContainerHigh: AppColors.darkBackground,
      surfaceContainer: AppColors.darkBackground,
    );

    final textTheme = _buildTextTheme(
      primary: onSurface,
      secondary: onSurfaceVariant,
      tertiary: onSurfaceMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      dividerColor: AppColors.darkTableBorder,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      iconTheme: const IconThemeData(color: onSurfaceVariant, size: 24),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          iconSize: appBarIconSize,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.all(10),
        ),
      ),
      appBarTheme: _appBarTheme(
        background: AppColors.darkSurface,
        foreground: onSurface,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: onSurfaceVariant),
        floatingLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryLight,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: onSurfaceMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.white;
            return onSurfaceVariant;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.primaryLight;
            return AppColors.darkInputFill;
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.darkBorder),
          ),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: onSurfaceMuted,
        indicatorColor: AppColors.primaryLight,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500),
        dividerColor: AppColors.darkBorder,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkInputFill,
        selectedColor: AppColors.calculatedFieldDark,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: onSurface),
        side: const BorderSide(color: AppColors.darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        iconTheme: const IconThemeData(color: AppColors.primaryLight, size: 18),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkTableBorder,
        thickness: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: onSurfaceVariant,
        textColor: onSurface,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        subtitleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: onSurfaceVariant,
        ),
      ),
    );
  }
}
