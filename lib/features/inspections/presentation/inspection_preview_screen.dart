import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../core/services/dialog_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../forms/shared/utils/workflow_table_columns.dart';
import '../models/inspection_action.dart';
import '../providers/inspection_store_provider.dart';
import '../services/inspection_pdf_service.dart';
import '../utils/inspection_ui_actions.dart';

class InspectionPreviewScreen extends ConsumerWidget {
  const InspectionPreviewScreen({super.key, required this.inspectionId});

  final String inspectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = ref.watch(inspectionByIdProvider(inspectionId));
    final user = ref.watch(authProvider).user;
    final theme = Theme.of(context);

    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inspection Preview')),
        body: const Center(child: Text('Inspection not found')),
      );
    }

    final reviewActions = user == null
        ? const <InspectionAction>[]
        : InspectionUiActions.reviewActions(
            role: user.role,
            status: record.status,
          );
    final canEdit = user != null &&
        InspectionUiActions.canEditFormData(
          role: user.role,
          status: record.status,
          createdByUsername: record.createdByUsername,
          currentUsername: user.username,
        );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Print Preview', style: theme.textTheme.titleMedium),
            Text(
              record.formCode,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          if (canEdit)
            TextButton(
              onPressed: () => context.push(
                '/forms/${record.formId}/entry?inspectionId=${record.id}',
              ),
              child: const Text('Edit'),
            ),
        ],
      ),
      body: PdfPreview(
        key: ValueKey(
          '${record.id}_${record.updatedAt.millisecondsSinceEpoch}_'
          '${record.status.apiCode}_${record.comments.length}',
        ),
        build: (format) => InspectionPdfService.buildPdf(
          record,
          pageFormat: format,
        ),
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: InspectionPdfService.fileNameFor(record),
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
        maxPageWidth: 720,
        scrollViewDecoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        pdfPreviewPageDecoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        actionBarTheme: PdfActionBarTheme(
          backgroundColor: theme.colorScheme.surface,
          iconColor: theme.colorScheme.onSurface,
        ),
        onPrintError: (context, error) {
          DialogService.showError(
            title: 'Print failed',
            message: error.toString(),
          );
        },
        loadingWidget: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Building print layout…'),
            ],
          ),
        ),
        onError: (context, error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not build preview:\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      bottomNavigationBar: reviewActions.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final action in reviewActions) ...[
                      SizedBox(
                        width: double.infinity,
                        child: action.requiresComment
                            ? OutlinedButton(
                                onPressed: () => runInspectionWorkflowAction(
                                  ref: ref,
                                  record: record,
                                  action: action,
                                ),
                                child: Text(action.label),
                              )
                            : FilledButton(
                                onPressed: () => runInspectionWorkflowAction(
                                  ref: ref,
                                  record: record,
                                  action: action,
                                ),
                                child: Text(action.label),
                              ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
