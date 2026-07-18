import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/form_inspection_table_scaffold.dart';
import '../../../inspections/providers/inspection_store_provider.dart';
import '../models/c1_entry.dart';
import 'c1_form_stepper.dart';

class C1FormScreen extends ConsumerStatefulWidget {
  const C1FormScreen({super.key, this.inspectionId});

  final String? inspectionId;

  @override
  ConsumerState<C1FormScreen> createState() => _C1FormScreenState();
}

class _C1FormScreenState extends ConsumerState<C1FormScreen> {
  C1Entry? _entry;
  bool _loaded = false;

  @override
  void dispose() {
    _entry?.dispose();
    super.dispose();
  }

  void _ensureLoaded() {
    if (_loaded) return;
    _loaded = true;

    if (widget.inspectionId != null) {
      final existing = ref.read(inspectionByIdProvider(widget.inspectionId!));
      if (existing != null) {
        _entry = C1Entry.fromMap(existing.payload);
        return;
      }
    }
    _entry = C1Entry();
  }

  C1Entry get entry {
    _ensureLoaded();
    return _entry!;
  }

  Future<void> _persist({required bool submitForReview}) async {
    await saveFormInspection(
      ref: ref,
      context: context,
      formId: 'c1',
      formCode: 'Form C-1',
      title: 'Formation Width Measurement',
      payload: entry.toJson(),
      inspectionId: widget.inspectionId,
      submitForReview: submitForReview,
    );
  }

  @override
  Widget build(BuildContext context) {
    _ensureLoaded();
    final theme = Theme.of(context);
    final isEdit = widget.inspectionId != null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEdit ? 'Edit Record' : 'Add Record', style: theme.textTheme.titleMedium),
            Text(
              'Form C-1 — Formation Width',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: C1FormStepper(
        entry: entry,
        isLoading: false,
        onSubmit: () => _persist(submitForReview: true),
        onSaveDraft: () => _persist(submitForReview: false),
      ),
    );
  }
}
