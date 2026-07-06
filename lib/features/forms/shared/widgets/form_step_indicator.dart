import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Global numbered step indicator with connecting lines between steps.
class FormStepIndicator extends StatelessWidget {
  const FormStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.onStepTap,
  });

  final int totalSteps;
  final int currentStep;
  final ValueChanged<int>? onStepTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactiveBg = theme.brightness == Brightness.light
        ? AppColors.inactiveStep
        : AppColors.inactiveStepDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          if (index.isOdd) {
            final lineIndex = index ~/ 2;
            final isCompleted = lineIndex < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? theme.colorScheme.primary
                      : inactiveBg,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isActive = stepIndex == currentStep;
          final isDone = stepIndex < currentStep;

          return GestureDetector(
            onTap: onStepTap != null ? () => onStepTap!(stepIndex) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive || isDone
                    ? theme.colorScheme.primary
                    : inactiveBg,
                border: isActive
                    ? Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        width: 3,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '${stepIndex + 1}',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isActive || isDone
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
