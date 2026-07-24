import 'package:flutter/material.dart';

import 'keyboard_dismiss.dart';

class ChainageFields extends StatelessWidget {
  const ChainageFields({
    super.key,
    required this.kmController,
    required this.mController,
    this.onChanged,
  });

  final TextEditingController kmController;
  final TextEditingController mController;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: kmController,
            decoration: const InputDecoration(
              labelText: 'Chainage (km)',
              hintText: '0',
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onTapOutside: KeyboardDismiss.onTapOutside,
            onChanged: (_) => onChanged?.call(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: mController,
            decoration: const InputDecoration(
              labelText: 'Chainage (m)',
              hintText: '000',
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onTapOutside: KeyboardDismiss.onTapOutside,
            onFieldSubmitted: (_) => KeyboardDismiss.hide(context),
            onChanged: (_) => onChanged?.call(),
          ),
        ),
      ],
    );
  }
}

class SubmitBar extends StatelessWidget {
  const SubmitBar({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.onAddEntry,
    this.addLabel = 'Add Entry',
  });

  final VoidCallback onSubmit;
  final bool isLoading;
  final VoidCallback? onAddEntry;
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (onAddEntry != null) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onAddEntry,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(addLabel),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: onAddEntry != null ? 1 : 2,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onSubmit,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
                label: Text(isLoading ? 'Submitting...' : 'Submit Form'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
