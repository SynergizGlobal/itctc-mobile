import 'package:flutter/foundation.dart';

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
