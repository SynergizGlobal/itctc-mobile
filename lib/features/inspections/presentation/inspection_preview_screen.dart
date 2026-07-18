import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_provider.dart';
import '../../forms/shared/utils/workflow_table_columns.dart';
import '../models/inspection_action.dart';
import '../providers/inspection_store_provider.dart';
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
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preview', style: theme.textTheme.titleMedium),
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _PrintableCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.formCode,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(record.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _MetaRow(label: 'Status', value: record.status.label),
                _MetaRow(label: 'Created by', value: record.createdByUsername),
                _MetaRow(
                  label: 'Created',
                  value: dateFormat.format(record.createdAt.toLocal()),
                ),
                _MetaRow(
                  label: 'Updated',
                  value: dateFormat.format(record.updatedAt.toLocal()),
                ),
                if (record.assignedToRole != null)
                  _MetaRow(
                    label: 'Assigned to',
                    value: record.assignedToRole!,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Inspection details', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _PrintableCard(
            child: Column(
              children: [
                for (final entry in _detailEntries(record.payload))
                  FormPreviewDetailRow(
                    label: entry.key,
                    value: entry.value,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Attachments', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _PrintableCard(child: _AttachmentsBlock(payload: record.payload)),
          const SizedBox(height: 16),
          Text('Inspection journey', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _PrintableCard(
            child: record.comments.isEmpty
                ? const Text('No workflow events yet.')
                : Column(
                    children: [
                      for (final event in record.comments)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.timeline,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${event.action.label} · ${event.fromStatus.label} → ${event.toStatus.label}',
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      event.message,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${event.authorUsername} (${event.authorRole}) · ${dateFormat.format(event.createdAt.toLocal())}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ],
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

  List<MapEntry<String, String>> _detailEntries(Map<String, dynamic> payload) {
    final skip = {
      'id',
      'attachments',
      'siteCapture',
      'inspectionId',
      'status',
      'statusLabel',
      'createdByUsername',
      'formId',
      'formCode',
      'title',
    };
    final entries = <MapEntry<String, String>>[];
    payload.forEach((key, value) {
      if (skip.contains(key)) return;
      if (value is Map || value is List) return;
      entries.add(MapEntry(_prettyKey(key), value?.toString() ?? '—'));
    });

    final site = payload['siteCapture'];
    if (site is Map) {
      final address = site['address']?.toString();
      if (address != null && address.trim().isNotEmpty) {
        entries.add(MapEntry('Location', address));
      }
      final selfie = site['selfiePath']?.toString();
      if (selfie != null && selfie.trim().isNotEmpty) {
        entries.add(const MapEntry('Selfie', 'Captured'));
      }
    }

    if (entries.isEmpty) {
      entries.add(const MapEntry('Details', 'No field values yet'));
    }
    return entries;
  }

  String _prettyKey(String key) {
    final spaced = key.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m[1]} ${m[2]}',
    );
    if (spaced.isEmpty) return key;
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}

class FormPreviewDetailRow extends StatelessWidget {
  const FormPreviewDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.trim().isEmpty ? '—' : value,
              style: theme.textTheme.titleSmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return FormPreviewDetailRow(label: label, value: value);
  }
}

class _PrintableCard extends StatelessWidget {
  const _PrintableCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _AttachmentsBlock extends StatelessWidget {
  const _AttachmentsBlock({required this.payload});

  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final raw = payload['attachments'];
    if (raw is! List || raw.isEmpty) {
      return Text(
        'No attachments',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: [
        for (final item in raw)
          if (item is Map)
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.attach_file_rounded),
              title: Text(item['name']?.toString() ?? 'Attachment'),
              subtitle: Text(item['path']?.toString() ?? ''),
            ),
      ],
    );
  }
}
