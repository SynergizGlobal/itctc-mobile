import 'dart:io';

import 'package:flutter/foundation.dart';

/// Store-policy-friendly attachment access model.
///
/// Attachments use the OS document picker only:
/// - Android: Storage Access Framework (ACTION_OPEN_DOCUMENT) — no broad
///   READ_EXTERNAL_STORAGE / READ_MEDIA_* permissions on Android 10+.
/// - iOS: UIDocumentPicker (import mode) — no photo-library permission for
///   [FileType.custom] picks.
class AttachmentAccessPolicy {
  AttachmentAccessPolicy._();

  static bool get usesSystemDocumentPickerOnly => !kIsWeb;

  static bool isPermissionError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('permission') ||
        message.contains('denied') ||
        message.contains('not authorized') ||
        message.contains('unauthorized');
  }
}
