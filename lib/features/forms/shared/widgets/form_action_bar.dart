import 'package:flutter/material.dart';

/// Sticky bottom bar shared across all forms.
class FormActionBar extends StatelessWidget {
  const FormActionBar({
    super.key,
    required this.isLoading,
    required this.canGoPrevious,
    required this.isLastStep,
    required this.canRemoveRow,
    required this.onPrevious,
    required this.onNext,
    required this.onAddRow,
    this.onRemoveRow,
    this.addRowLabel = 'Add Row',
  });

  final bool isLoading;
  final bool canGoPrevious;
  final bool isLastStep;
  final bool canRemoveRow;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onAddRow;
  final VoidCallback? onRemoveRow;
  final String addRowLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: canGoPrevious && !isLoading ? onPrevious : null,
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
                          : Text(isLastStep ? 'Submit' : 'Next'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : onAddRow,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(addRowLabel),
                    ),
                  ),
                  if (canRemoveRow && onRemoveRow != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : onRemoveRow,
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(color: theme.colorScheme.error),
                        ),
                        label: const Text('Remove Row'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
