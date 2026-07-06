import 'package:flutter/material.dart';

import '../utils/form_table_theme.dart';
import 'form_data_table.dart';
import '../models/form_table_header.dart';

class FormTableScaffold extends StatelessWidget {
  const FormTableScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.definition,
    required this.rows,
    required this.onAdd,
    this.onRowTap,
    this.emptyMessage,
    this.addLabel = 'Add',
  });

  final String title;
  final String subtitle;
  final FormTableDefinition definition;
  final List<Map<String, dynamic>> rows;
  final VoidCallback onAdd;
  final void Function(int index)? onRowTap;
  final String? emptyMessage;
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            final compact = MediaQuery.sizeOf(context).width < 360;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: compact ? 15 : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: compact ? 11 : null,
                  ),
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        ),
      ),
      body: FormDataTable(
        definition: definition,
        rows: rows,
        onRowTap: onRowTap,
        emptyMessage: emptyMessage ?? 'No records yet.\nTap Add to enter data.',
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: FormTableTheme.border(context))),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: Text(addLabel),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
