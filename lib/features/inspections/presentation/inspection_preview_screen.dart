import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';

import '../../../core/services/dialog_service.dart';
import '../../../core/widgets/app_bar_title.dart';
import '../../auth/providers/auth_provider.dart';
import '../../forms/shared/utils/workflow_table_columns.dart';
import '../models/inspection_action.dart';
import '../models/inspection_record.dart';
import '../providers/inspection_store_provider.dart';
import '../services/inspection_pdf_service.dart';
import '../utils/inspection_ui_actions.dart';
import 'widgets/safe_pdf_preview.dart';

class InspectionPreviewScreen extends ConsumerStatefulWidget {
  const InspectionPreviewScreen({super.key, required this.inspectionId});

  final String inspectionId;

  @override
  ConsumerState<InspectionPreviewScreen> createState() =>
      _InspectionPreviewScreenState();
}

class _InspectionPreviewScreenState
    extends ConsumerState<InspectionPreviewScreen> {
  Uint8List? _pdfBytes;
  String? _builtSignature;
  Object? _buildError;
  var _building = false;

  String _signature(InspectionRecord record) =>
      '${record.id}|${record.updatedAt.millisecondsSinceEpoch}|'
      '${record.status.apiCode}|${record.comments.length}';

  Future<void> _ensurePdf(InspectionRecord record) async {
    final signature = _signature(record);
    if (_builtSignature == signature && _pdfBytes != null) return;
    if (_building) return;

    _building = true;
    if (mounted) {
      setState(() => _buildError = null);
    }

    try {
      final bytes = await InspectionPdfService.buildPdf(
        record,
        pageFormat: PdfPageFormat.a4,
      );
      if (!mounted) return;

      final latest = ref.read(inspectionByIdProvider(widget.inspectionId));
      if (latest == null) {
        _building = false;
        return;
      }
      if (_signature(latest) != signature) {
        _building = false;
        await _ensurePdf(latest);
        return;
      }

      setState(() {
        _pdfBytes = bytes;
        _builtSignature = signature;
        _building = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _buildError = error;
        _building = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = ref.watch(inspectionByIdProvider(widget.inspectionId));
    final user = ref.watch(authProvider).user;
    final theme = Theme.of(context);

    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inspection Preview')),
        body: const Center(child: Text('Inspection not found')),
      );
    }

    final signature = _signature(record);
    if (_builtSignature != signature && !_building) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ensurePdf(record);
      });
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
        title: AppBarTitleBlock(
          title: 'Print Preview',
          subtitle: record.formCode,
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
      body: _buildBody(theme, record),
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

  Widget _buildBody(ThemeData theme, InspectionRecord record) {
    if (_buildError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not build preview:\n$_buildError',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  _builtSignature = null;
                  _ensurePdf(record);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final bytes = _pdfBytes;
    if (bytes == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Building print layout…'),
          ],
        ),
      );
    }

    return SafePdfPreview(
      bytes: bytes,
      fileName: InspectionPdfService.fileNameFor(record),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      actionBarColor: theme.colorScheme.surface,
      actionIconColor: theme.colorScheme.onSurface,
      onPrintError: (error) {
        DialogService.showError(
          title: 'Print failed',
          message: error.toString(),
        );
      },
    );
  }
}
