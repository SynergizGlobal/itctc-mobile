import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/form_attachment.dart';

class AttachmentStorageService {
  AttachmentStorageService._();

  static const allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'csv',
    'txt',
    'mp4',
    'mov',
    'm4v',
    'webm',
    'mkv',
    'avi',
    '3gp',
  ];

  static const videoExtensions = {
    'mp4',
    'mov',
    'm4v',
    'webm',
    'mkv',
    'avi',
    '3gp',
  };

  static bool isVideoExtension(String extension) {
    return videoExtensions.contains(extension.toLowerCase());
  }

  static Future<String> _recordDir(String recordId) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'form_attachments', recordId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  static Future<FormAttachment> persistPlatformFile({
    required String recordId,
    required PlatformFile file,
  }) async {
    final extension = _normalizeExtension(file.extension, file.name);
    final id = const Uuid().v4();
    final destPath = p.join(await _recordDir(recordId), '$id.$extension');
    final destFile = File(destPath);

    if (file.path != null && file.path!.isNotEmpty) {
      await File(file.path!).copy(destPath);
    } else if (file.bytes != null && file.bytes!.isNotEmpty) {
      await destFile.writeAsBytes(file.bytes!, flush: true);
    } else if (file.readStream != null) {
      final sink = destFile.openWrite();
      await sink.addStream(file.readStream!);
      await sink.close();
    } else {
      throw StateError('Selected file has no readable content.');
    }

    final size = file.size > 0 ? file.size : await destFile.length();

    return FormAttachment(
      id: id,
      name: file.name,
      path: destPath,
      size: size,
      extension: extension,
    );
  }

  static Future<FormAttachment> persistLocalFile({
    required String recordId,
    required String sourcePath,
    required String displayName,
    String? extension,
  }) async {
    final normalizedExtension = _normalizeExtension(extension, displayName);
    final id = const Uuid().v4();
    final destPath = p.join(await _recordDir(recordId), '$id.$normalizedExtension');
    await File(sourcePath).copy(destPath);
    final size = await File(destPath).length();

    return FormAttachment(
      id: id,
      name: displayName,
      path: destPath,
      size: size,
      extension: normalizedExtension,
    );
  }

  static Future<void> deleteAttachment(FormAttachment attachment) async {
    final file = File(attachment.path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static String _normalizeExtension(String? extension, String fileName) {
    final fromName = p.extension(fileName).replaceFirst('.', '').toLowerCase();
    final ext = (extension ?? fromName).toLowerCase();
    return ext.isEmpty ? 'bin' : ext;
  }
}
