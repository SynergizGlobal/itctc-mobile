import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CalculatedValueField extends StatelessWidget {
  const CalculatedValueField({
    super.key,
    required this.label,
    required this.value,
    this.suffixText,
  });

  final String label;
  final String value;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final display = value.trim().isEmpty ? '—' : value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.calculatedFieldDark : AppColors.calculatedField,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppColors.calculatedFieldBorderDark
                  : AppColors.calculatedFieldBorder,
            ),
          ),
          child: Text(
            suffixText != null && display != '—' ? '$display $suffixText' : display,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.calculatedFieldTextDark
                  : AppColors.calculatedFieldText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
