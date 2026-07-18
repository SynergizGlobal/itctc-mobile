import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/dialog_service.dart';
import '../../../auth/models/user_role.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../inspections/models/inspection_record.dart';
import '../../../inspections/providers/inspection_store_provider.dart';
import '../models/form_table_header.dart';
import '../utils/form_table_theme.dart';
import '../utils/workflow_table_columns.dart';
import 'form_data_table.dart';

/// Shared table host for inspection-backed form lists.
class FormInspectionTableScaffold extends ConsumerWidget {
  const FormInspectionTableScaffold({
    super.key,
    required this.formId,
    required this.formCode,
    required this.title,
    required this.subtitle,
    required this.definition,
    required this.entryRoute,
  });

  final String formId;
  final String formCode;
  final String title;
  final String subtitle;
  final FormTableDefinition definition;
  final String entryRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;
    final inspections = ref.watch(formInspectionsProvider(formId));
    final rows = inspections.map(inspectionToTableRow).toList();
    final tableDefinition = withWorkflowColumns(
      definition,
      entryRoute: entryRoute,
    );
    final canAdd = user?.role == UserRole.inspector;

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
        definition: tableDefinition,
        rows: rows,
        emptyMessage: canAdd
            ? 'No inspections yet.\nTap Add Inspection to start.'
            : 'No inspections available for review yet.',
      ),
      bottomNavigationBar: canAdd
          ? Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: FormTableTheme.border(context)),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.push(entryRoute),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Add Inspection'),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

Future<void> saveFormInspection({
  required WidgetRef ref,
  required BuildContext context,
  required String formId,
  required String formCode,
  required String title,
  required Map<String, dynamic> payload,
  String? inspectionId,
  required bool submitForReview,
}) async {
  final user = ref.read(authProvider).user;
  if (user == null) return;

  if (user.role != UserRole.inspector) {
    await DialogService.showError(
      title: 'Not allowed',
      message: 'Only Inspectors can create or edit inspection form data.',
    );
    return;
  }

  try {
    ref.read(inspectionStoreProvider.notifier).saveInspectorEntry(
          inspector: user,
          formId: formId,
          formCode: formCode,
          title: title,
          payload: payload,
          inspectionId: inspectionId,
          submitForReview: submitForReview,
        );

    // Show dialog while the form route is still mounted, then pop after it
    // closes. Popping first then showing a dialog races Overlay deactivation.
    if (!context.mounted) return;
    await DialogService.showSuccess(
      title: submitForReview ? 'Submitted for Review' : 'Draft Saved',
      message: submitForReview
          ? '$formCode has been submitted to PMC.'
          : '$formCode draft is saved locally.',
    );
    if (context.mounted) context.pop();
  } catch (e) {
    await DialogService.showError(
      title: 'Save failed',
      message: e.toString(),
    );
  }
}

InspectionRecord? findInspection(WidgetRef ref, String? inspectionId) {
  if (inspectionId == null) return null;
  return ref.read(inspectionByIdProvider(inspectionId));
}
