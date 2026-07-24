import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/error_handler.dart';
import '../../../../core/widgets/keyboard_dismiss.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../inspections/models/inspection_action.dart';
import '../../../inspections/models/inspection_record.dart';
import '../../../inspections/models/inspection_status.dart';
import '../../../inspections/providers/inspection_store_provider.dart';
import '../../../inspections/utils/inspection_ui_actions.dart';
import '../models/form_table_column.dart';
import '../models/form_table_header.dart';

/// Appends Status / Preview / Actions columns to a paper-form table definition.
FormTableDefinition withWorkflowColumns(
  FormTableDefinition base, {
  required String entryRoute,
}) {
  final headerRows = base.headerRows.map((row) => [...row]).toList();
  if (headerRows.isEmpty) {
    headerRows.add([]);
  }

  final rowSpan = headerRows.length;
  headerRows.first.addAll([
    FormTableHeaderCell(label: 'Status', rowSpan: rowSpan),
    FormTableHeaderCell(label: 'Preview', rowSpan: rowSpan),
    FormTableHeaderCell(label: 'Actions', rowSpan: rowSpan),
  ]);

  return FormTableDefinition(
    headerRows: headerRows,
    columns: [
      ...base.columns,
      FormTableColumn(
        title: 'Status',
        minWidth: 110,
        value: (row, _) => tableCell(row['statusLabel']),
      ),
      FormTableColumn(
        title: 'Preview',
        minWidth: 88,
        value: (_, _) => 'Preview',
        cellBuilder: (context, row, _) {
          final id = row['inspectionId']?.toString();
          if (id == null || id.isEmpty) return const Text('—');
          return TextButton(
            onPressed: () => context.push(RouteNames.inspectionPreview(id)),
            child: const Text('Preview'),
          );
        },
      ),
      FormTableColumn(
        title: 'Actions',
        minWidth: 168,
        value: (_, _) => 'Actions',
        cellBuilder: (context, row, _) {
          return InspectionRowActions(
            row: row,
            entryRoute: entryRoute,
          );
        },
      ),
    ],
  );
}

Map<String, dynamic> inspectionToTableRow(InspectionRecord record) {
  return {
    ...record.payload,
    'inspectionId': record.id,
    'status': record.status.apiCode,
    'statusLabel': record.status.label,
    'createdByUsername': record.createdByUsername,
    'formId': record.formId,
    'formCode': record.formCode,
    'title': record.title,
  };
}

/// Shared primary workflow button for table cells and list cards.
class InspectionRowActions extends ConsumerWidget {
  const InspectionRowActions({
    super.key,
    required this.row,
    required this.entryRoute,
  });

  final Map<String, dynamic> row;
  final String entryRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final id = row['inspectionId']?.toString();
    if (user == null || id == null) return const SizedBox.shrink();

    final status = InspectionStatus.tryParse(row['status']?.toString()) ??
        InspectionStatus.draft;
    final createdBy = row['createdByUsername']?.toString() ?? '';
    final primaryLabel = InspectionUiActions.primaryActionLabel(
      role: user.role,
      status: status,
    );
    if (primaryLabel == null) return const SizedBox.shrink();

    final canEdit = InspectionUiActions.canEditFormData(
      role: user.role,
      status: status,
      createdByUsername: createdBy,
      currentUsername: user.username,
    );

    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      onPressed: () {
        if (canEdit) {
          context.push('$entryRoute?inspectionId=$id');
        } else {
          context.push(RouteNames.inspectionPreview(id));
        }
      },
      child: Text(primaryLabel),
    );
  }
}

Future<void> runInspectionWorkflowAction({
  required WidgetRef ref,
  required InspectionRecord record,
  required InspectionAction action,
}) async {
  final user = ref.read(authProvider).user;
  if (user == null) return;

  String? comment;
  if (action.requiresComment) {
    comment = await promptInspectionComment(
      title: action.label,
      hint: 'Enter review comments',
    );
    if (comment == null) return;
  } else {
    final confirmed = await DialogService.showConfirm(
      title: action.label,
      message: 'Apply "${action.label}" to ${record.formCode}?',
      confirmLabel: action.label,
    );
    if (confirmed != true) return;
  }

  try {
    ref.read(inspectionStoreProvider.notifier).performAction(
          inspectionId: record.id,
          actor: user,
          action: action,
          comment: comment,
        );

    await Future<void>.delayed(Duration.zero);
    await WidgetsBinding.instance.endOfFrame;
    await DialogService.showSuccess(
      title: 'Updated',
      message: '${record.formCode} is now ${action.resultingStatus.label}.',
    );
  } catch (e) {
    await DialogService.showError(
      title: 'Action failed',
      message: e.toString(),
    );
  }
}

Future<String?> promptInspectionComment({
  required String title,
  required String hint,
}) async {
  final context = ErrorHandler.navigatorKey.currentContext;
  if (context == null || !context.mounted) return null;

  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 4,
          textInputAction: TextInputAction.newline,
          onTapOutside: KeyboardDismiss.onTapOutside,
          decoration: InputDecoration(hintText: hint),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
  await Future<void>.delayed(Duration.zero);
  controller.dispose();
  if (result == null || result.isEmpty) return null;
  return result;
}
