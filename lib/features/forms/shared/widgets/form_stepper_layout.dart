import 'package:flutter/material.dart';

import 'form_action_bar.dart';
import 'form_step_indicator.dart';

/// Shared form layout: row selector, step indicator, content, sticky action bar.
class FormStepperLayout extends StatelessWidget {
  const FormStepperLayout({
    super.key,
    required this.stepCount,
    required this.currentStep,
    required this.isLoading,
    required this.canRemoveRow,
    required this.onPrevious,
    required this.onNext,
    required this.onAddRow,
    required this.child,
    this.onStepTap,
    this.rowLabels,
    this.currentRow,
    this.onRowSelected,
    this.onRemoveRow,
    this.addRowLabel = 'Add Row',
    this.header,
  });

  final int stepCount;
  final int currentStep;
  final bool isLoading;
  final bool canRemoveRow;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onAddRow;
  final VoidCallback? onRemoveRow;
  final ValueChanged<int>? onStepTap;
  final List<String>? rowLabels;
  final int? currentRow;
  final ValueChanged<int>? onRowSelected;
  final String addRowLabel;
  final Widget child;
  final Widget? header;

  bool get _isLastStep => currentStep == stepCount - 1;
  bool get _canGoPrevious => currentStep > 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (rowLabels != null && rowLabels!.length > 1)
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: rowLabels!.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(rowLabels![i]),
                    selected: currentRow == i,
                    onSelected: onRowSelected != null
                        ? (_) => onRowSelected!(i)
                        : null,
                  ),
                );
              },
            ),
          ),
        if (header != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: header,
          ),
          const SizedBox(height: 8),
        ],
        FormStepIndicator(
          totalSteps: stepCount,
          currentStep: currentStep,
          onStepTap: onStepTap,
        ),
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
        ),
        FormActionBar(
          isLoading: isLoading,
          canGoPrevious: _canGoPrevious,
          isLastStep: _isLastStep,
          canRemoveRow: canRemoveRow,
          onPrevious: onPrevious,
          onNext: onNext,
          onAddRow: onAddRow,
          onRemoveRow: onRemoveRow,
          addRowLabel: addRowLabel,
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
