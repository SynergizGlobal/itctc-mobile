import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'attachment_access_policy.dart';
import 'attachment_storage_service.dart';

class AttachmentPickResult {
  const AttachmentPickResult({
    required this.files,
    this.cancelled = false,
    this.errorMessage,
    this.permissionDenied = false,
    this.needsAppRestart = false,
  });

  const AttachmentPickResult.cancelled()
      : files = const [],
        cancelled = true,
        errorMessage = null,
        permissionDenied = false,
        needsAppRestart = false;

  final List<PlatformFile> files;
  final bool cancelled;
  final String? errorMessage;
  final bool permissionDenied;
  final bool needsAppRestart;

  bool get hasError => errorMessage != null;
}

class AttachmentPickerService {
  AttachmentPickerService._();

  static Future<AttachmentPickResult> pickReferenceFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: AttachmentStorageService.allowedExtensions,
        withData: !kIsWeb,
      );

      if (result == null || result.files.isEmpty) {
        return const AttachmentPickResult.cancelled();
      }

      final readable = <PlatformFile>[];
      for (final file in result.files) {
        if (_hasReadableContent(file)) {
          readable.add(file);
          continue;
        }

        return AttachmentPickResult(
          files: const [],
          errorMessage:
              'Could not read "${file.name}". Try choosing the file again.',
        );
      }

      return AttachmentPickResult(files: readable);
    } on MissingPluginException {
      return const AttachmentPickResult(
        files: [],
        needsAppRestart: true,
        errorMessage:
            'File picker is not available in this app session. '
            'Stop the app completely, then run a full rebuild '
            '(flutter run — not hot reload).',
      );
    } on PlatformException catch (error) {
      final denied = AttachmentAccessPolicy.isPermissionError(error) ||
          error.code.toLowerCase().contains('permission');
      return AttachmentPickResult(
        files: const [],
        errorMessage: denied
            ? 'File access was denied. You can enable access in system settings.'
            : error.message ?? 'Could not open the file picker.',
        permissionDenied: denied,
      );
    } catch (error) {
      if (error is MissingPluginException) {
        return const AttachmentPickResult(
          files: [],
          needsAppRestart: true,
          errorMessage:
              'File picker is not available in this app session. '
              'Stop the app completely, then run a full rebuild '
              '(flutter run — not hot reload).',
        );
      }

      final denied = AttachmentAccessPolicy.isPermissionError(error);
      return AttachmentPickResult(
        files: const [],
        errorMessage: denied
            ? 'File access was denied. You can enable access in system settings.'
            : 'Could not open the file picker: $error',
        permissionDenied: denied,
      );
    }
  }

  static bool _hasReadableContent(PlatformFile file) {
    return (file.path != null && file.path!.isNotEmpty) ||
        (file.bytes != null && file.bytes!.isNotEmpty);
  }
}
