import 'package:flutter/material.dart';

import 'form_step_indicator.dart';

/// Single-record entry stepper: numbered steps + Previous / Next / Submit only.
class FormEntryStepperLayout extends StatelessWidget {
  const FormEntryStepperLayout({
    super.key,
    required this.stepCount,
    required this.currentStep,
    required this.isLoading,
    required this.onPrevious,
    required this.onNext,
    required this.child,
    this.onStepTap,
    this.header,
  });

  final int stepCount;
  final int currentStep;
  final bool isLoading;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Widget child;
  final ValueChanged<int>? onStepTap;
  final Widget? header;

  bool get _isLastStep => currentStep == stepCount - 1;
  bool get _canGoPrevious => currentStep > 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        FormStepIndicator(
          totalSteps: stepCount,
          currentStep: currentStep,
          onStepTap: onStepTap,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (header != null) ...[
                  header!,
                  const SizedBox(height: 12),
                ],
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(top: BorderSide(color: theme.dividerColor)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _canGoPrevious && !isLoading ? onPrevious : null,
                      child: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onNext,
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isLastStep ? 'Submit' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FormSummaryRow extends StatelessWidget {
  const FormSummaryRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = value.trim().isEmpty || value.trim() == 'mm' ? '—' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Flexible(
            child: Text(
              display,
              style: theme.textTheme.titleSmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
