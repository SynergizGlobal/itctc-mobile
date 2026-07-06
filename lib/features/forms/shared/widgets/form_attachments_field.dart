import 'package:flutter/material.dart';

import '../services/attachment_access_policy.dart';
import '../services/attachment_picker_service.dart';
import '../services/attachment_storage_service.dart';
import '../models/form_attachment.dart';

class FormAttachmentsField extends StatefulWidget {
  const FormAttachmentsField({
    super.key,
    required this.recordId,
    required this.attachments,
    required this.onChanged,
  });

  final String recordId;
  final List<FormAttachment> attachments;
  final VoidCallback onChanged;

  @override
  State<FormAttachmentsField> createState() => _FormAttachmentsFieldState();
}

class _FormAttachmentsFieldState extends State<FormAttachmentsField> {
  bool _picking = false;

  Future<void> _pickFiles() async {
    setState(() => _picking = true);
    try {
      final result = await AttachmentPickerService.pickReferenceFiles();
      if (!mounted) return;

      if (result.cancelled) return;

      if (result.hasError) {
        await _showPickError(result);
        return;
      }

      for (final file in result.files) {
        final attachment = await AttachmentStorageService.persistPlatformFile(
          recordId: widget.recordId,
          file: file,
        );
        widget.attachments.add(attachment);
      }
      widget.onChanged();
    } catch (error) {
      if (!mounted) return;
      await _showPickError(
        AttachmentPickResult(
          files: const [],
          errorMessage: 'Could not add file: $error',
          permissionDenied: AttachmentAccessPolicy.isPermissionError(error),
        ),
      );
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _showPickError(AttachmentPickResult result) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Could not add attachment'),
          content: Text(result.errorMessage ?? 'Unknown error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeAttachment(FormAttachment attachment) async {
    await AttachmentStorageService.deleteAttachment(attachment);
    widget.attachments.remove(attachment);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Reference / Attachments',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Upload images or documents (JPEG, PNG, PDF, DOC, XLSX, etc.)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _picking ? null : _pickFiles,
          icon: _picking
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              : const Icon(Icons.attach_file_rounded, size: 20),
          label: Text(_picking ? 'Adding files…' : 'Add files'),
        ),
        if (widget.attachments.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...widget.attachments.map(
            (attachment) => _AttachmentTile(
              attachment: attachment,
              onRemove: () => _removeAttachment(attachment),
            ),
          ),
        ],
      ],
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.attachment,
    required this.onRemove,
  });

  final FormAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: Icon(
          _iconForExtension(attachment.extension),
          color: theme.colorScheme.primary,
        ),
        title: Text(
          attachment.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(_formatSize(attachment.size)),
        trailing: IconButton(
          tooltip: 'Remove',
          icon: const Icon(Icons.close_rounded, size: 20),
          onPressed: onRemove,
        ),
      ),
    );
  }

  IconData _iconForExtension(String extension) {
    return switch (extension.toLowerCase()) {
      'jpg' || 'jpeg' || 'png' || 'gif' || 'webp' => Icons.image_rounded,
      'pdf' => Icons.picture_as_pdf_rounded,
      'doc' || 'docx' => Icons.description_rounded,
      'xls' || 'xlsx' || 'csv' => Icons.table_chart_rounded,
      _ => Icons.insert_drive_file_rounded,
    };
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

String attachmentsSummary(List<FormAttachment> attachments) {
  if (attachments.isEmpty) return '—';
  if (attachments.length == 1) return attachments.first.name;
  return '${attachments.length} files';
}

String attachmentsSummaryFromRow(dynamic raw) {
  return attachmentsSummary(parseAttachments(raw));
}
