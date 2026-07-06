import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF1B4F72);
  static const Color primaryLight = Color(0xFF2E86C1);
  static const Color primaryContainer = Color(0xFFD6EAF8);
  static const Color onPrimaryContainer = Color(0xFF0D3B5C);

  static const Color secondary = Color(0xFF117A65);
  static const Color secondaryContainer = Color(0xFFD1FAE5);
  static const Color onSecondaryContainer = Color(0xFF064E3B);

  static const Color accent = Color(0xFFB8860B);
  static const Color accentContainer = Color(0xFFFFF3CD);
  static const Color onAccentContainer = Color(0xFF6B4F00);

  static const Color success = Color(0xFF1E8449);
  static const Color warning = Color(0xFFD68910);
  static const Color error = Color(0xFFC0392B);
  static const Color info = Color(0xFF2874A6);

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFF1F5F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFCBD5E1);
  static const Color lightBorderSubtle = Color(0xFFE2E8F0);
  static const Color lightInputFill = Color(0xFFF8FAFC);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF64748B);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkInputFill = Color(0xFF0F172A);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);

  // Semantic surfaces
  static const Color calculatedField = Color(0xFFDBEAFE);
  static const Color calculatedFieldBorder = Color(0xFF93C5FD);
  static const Color calculatedFieldText = Color(0xFF1E3A5F);
  static const Color calculatedFieldDark = Color(0xFF1E3A5F);
  static const Color calculatedFieldBorderDark = Color(0xFF3B82F6);
  static const Color calculatedFieldTextDark = Color(0xFFDBEAFE);

  static const Color toleranceFail = Color(0xFFFEE2E2);
  static const Color toleranceFailBorder = Color(0xFFF87171);
  static const Color toleranceFailDark = Color(0xFF450A0A);
  static const Color toleranceFailBorderDark = Color(0xFFEF4444);

  static const Color inactiveStep = Color(0xFFCBD5E1);
  static const Color inactiveStepDark = Color(0xFF475569);

  // Form data tables — borders must contrast with header and body surfaces
  static const Color lightTableBorder = Color(0xFF64748B);
  static const Color lightTableHeader = Color(0xFFE2E8F0);
  static const Color lightTableBody = Color(0xFFFFFFFF);

  static const Color darkTableBorder = Color(0xFFCBD5E1);
  static const Color darkTableHeader = Color(0xFF334155);
  static const Color darkTableBody = Color(0xFF1E293B);
}
