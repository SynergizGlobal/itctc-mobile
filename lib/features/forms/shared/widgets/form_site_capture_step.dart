import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/services/dialog_service.dart';
import '../models/form_site_capture.dart';
import '../../../../core/theme/app_colors.dart';
import '../services/app_permission_service.dart';
import '../services/attachment_storage_service.dart';
import '../services/location_capture_service.dart';
import '../services/selfie_capture_service.dart';

class FormSiteCaptureStep extends StatefulWidget {
  const FormSiteCaptureStep({
    super.key,
    required this.recordId,
    required this.siteCapture,
    required this.onChanged,
  });

  final String recordId;
  final FormSiteCapture siteCapture;
  final VoidCallback onChanged;

  @override
  State<FormSiteCaptureStep> createState() => _FormSiteCaptureStepState();
}

class _FormSiteCaptureStepState extends State<FormSiteCaptureStep> {
  bool _capturingLocation = false;
  bool _capturingSelfie = false;

  FormSiteCapture get _capture => widget.siteCapture;

  Future<void> _captureLocation() async {
    setState(() => _capturingLocation = true);
    try {
      final result = await LocationCaptureService.captureCurrentPosition();
      if (!mounted) return;

      if (!result.isSuccess) {
        await _showMessage(
          title: 'Location not captured',
          message: result.errorMessage ?? 'Unknown error',
          showSettings: result.permanentlyDenied,
        );
        return;
      }

      _capture.latitude = result.latitude;
      _capture.longitude = result.longitude;
      _capture.locationAddress = result.address;
      _capture.locationCapturedAt = result.capturedAt;
      widget.onChanged();
    } finally {
      if (mounted) setState(() => _capturingLocation = false);
    }
  }

  Future<void> _captureSelfie() async {
    setState(() => _capturingSelfie = true);
    try {
      final result = await SelfieCaptureService.captureFrontSelfie();
      if (!mounted) return;

      if (result.cancelled) return;

      if (!result.isSuccess) {
        await _showMessage(
          title: 'Selfie not captured',
          message: result.errorMessage ?? 'Unknown error',
          showSettings: result.permanentlyDenied,
        );
        return;
      }

      final previous = _capture.selfie;
      if (previous != null) {
        await AttachmentStorageService.deleteAttachment(previous);
      }

      final attachment = await AttachmentStorageService.persistLocalFile(
        recordId: widget.recordId,
        sourcePath: result.filePath!,
        displayName: result.fileName ?? 'selfie.jpg',
        extension: 'jpg',
      );

      _capture.selfie = attachment;
      widget.onChanged();
    } finally {
      if (mounted) setState(() => _capturingSelfie = false);
    }
  }

  Future<void> _removeSelfie() async {
    final selfie = _capture.selfie;
    if (selfie == null) return;
    await AttachmentStorageService.deleteAttachment(selfie);
    _capture.selfie = null;
    widget.onChanged();
  }

  Future<void> _showSelfiePreview(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      await _showMessage(
        title: 'Preview unavailable',
        message: 'The selfie file could not be found on this device.',
      );
      return;
    }

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (ctx) {
        final sheetHeight = MediaQuery.sizeOf(ctx).height * 0.82;

        return SizedBox(
          height: sheetHeight,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(
                  'Inspector Selfie',
                  style: Theme.of(ctx).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Image.file(file, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showMessage({
    required String title,
    required String message,
    bool showSettings = false,
  }) async {
    await DialogService.showAlert(
      title: title,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.error,
      secondaryAction: showSettings ? 'Open settings' : null,
      onSecondary: showSettings ? AppPermissionService.openSettings : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RequiredSectionTitle(
          title: 'Location',
          isComplete: _capture.hasLocation,
        ),
        const SizedBox(height: 12),
        if (_capture.hasLocation) ...[
          _InfoCard(
            icon: Icons.location_on_rounded,
            title: siteCaptureLocationSummary(_capture),
            trailing: IconButton(
              tooltip: 'Recapture location',
              onPressed: _capturingLocation ? null : _captureLocation,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
        ] else
          FilledButton.icon(
            onPressed: _capturingLocation ? null : _captureLocation,
            icon: _capturingLocation
                ? _smallProgress(theme)
                : const Icon(Icons.my_location_rounded, size: 20),
            label: Text(_capturingLocation ? 'Resolving address…' : 'Capture location'),
          ),
        const SizedBox(height: 24),
        _RequiredSectionTitle(
          title: 'Inspector Selfie',
          isComplete: _capture.hasSelfie,
        ),
        const SizedBox(height: 12),
        if (_capture.hasSelfie) ...[
          _SelfiePreview(
            path: _capture.selfie!.path,
            onRetake: _capturingSelfie ? null : _captureSelfie,
            onRemove: _removeSelfie,
            onPreview: () => _showSelfiePreview(_capture.selfie!.path),
          ),
        ] else
          OutlinedButton.icon(
            onPressed: _capturingSelfie ? null : _captureSelfie,
            icon: _capturingSelfie
                ? _smallProgress(theme)
                : const Icon(Icons.camera_front_rounded, size: 20),
            label: Text(_capturingSelfie ? 'Opening camera…' : 'Take selfie'),
          ),
      ],
    );
  }

  Widget _smallProgress(ThemeData theme) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }
}

class _RequiredSectionTitle extends StatelessWidget {
  const _RequiredSectionTitle({
    required this.title,
    required this.isComplete,
  });

  final String title;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isComplete ? theme.colorScheme.primary : theme.colorScheme.error;

    return Row(
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(width: 4),
        Text('*', style: theme.textTheme.titleSmall?.copyWith(color: color)),
        if (isComplete) ...[
          const SizedBox(width: 8),
          Icon(Icons.check_circle_rounded, size: 18, color: theme.colorScheme.primary),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        trailing: trailing,
      ),
    );
  }
}

class _SelfiePreview extends StatelessWidget {
  const _SelfiePreview({
    required this.path,
    required this.onRetake,
    required this.onRemove,
    required this.onPreview,
  });

  final String path;
  final VoidCallback? onRetake;
  final VoidCallback onRemove;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final file = File(path);
    final hasImage = file.existsSync();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: hasImage ? onPreview : null,
                child: hasImage
                    ? AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Image.file(file, fit: BoxFit.cover),
                      )
                    : const AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Center(child: Icon(Icons.broken_image_rounded)),
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    tooltip: 'Retake selfie',
                    onPressed: onRetake,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Selfie captured',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Remove selfie',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
