import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/form_table_providers.dart';
import '../models/c1_entry.dart';
import 'c1_form_stepper.dart';

class C1FormScreen extends ConsumerStatefulWidget {
  const C1FormScreen({super.key, this.editIndex});

  final int? editIndex;

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

    if (widget.editIndex != null) {
      final rows = ref.read(c1TableProvider);
      if (widget.editIndex! < rows.length) {
        _entry = C1Entry.fromMap(rows[widget.editIndex!]);
        return;
      }
    }
    _entry = C1Entry();
  }

  C1Entry get entry {
    _ensureLoaded();
    return _entry!;
  }

  void _saveToTable() {
    final record = entry.toJson();
    if (widget.editIndex != null) {
      ref.read(c1TableProvider.notifier).updateRecord(widget.editIndex!, record);
    } else {
      ref.read(c1TableProvider.notifier).addRecord(record);
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    _ensureLoaded();
    final theme = Theme.of(context);
    final isEdit = widget.editIndex != null;

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
        onSubmit: _saveToTable,
      ),
    );
  }
}
