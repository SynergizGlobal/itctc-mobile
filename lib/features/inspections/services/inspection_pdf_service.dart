import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../forms/shared/models/form_attachment.dart';
import '../../forms/shared/models/form_site_capture.dart';
import '../../forms/shared/services/attachment_storage_service.dart';
import '../../auth/models/user_role.dart';
import '../models/inspection_record.dart';

/// Builds a print-ready inspection PDF and exports via system Print / Share.
class InspectionPdfService {
  InspectionPdfService._();

  static const _imageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  };

  static const _textExtensions = {'txt', 'csv'};

  static const _pdfExtensions = {'pdf'};

  /// Max pages rasterized from an attached PDF (keeps memory bounded).
  static const maxEmbeddedPdfPages = 12;

  static bool isImageExtension(String extension) =>
      _imageExtensions.contains(extension.toLowerCase());

  static bool isTextExtension(String extension) =>
      _textExtensions.contains(extension.toLowerCase());

  static bool isPdfExtension(String extension) =>
      _pdfExtensions.contains(extension.toLowerCase());

  static String fileNameFor(InspectionRecord record) {
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final safeCode = record.formCode.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return '${safeCode}_inspection_$stamp.pdf';
  }

  static Future<Uint8List> buildPdf(
    InspectionRecord record, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final attachments = parseAttachments(record.payload['attachments']);
    final site = FormSiteCapture.fromMap(
      record.payload['siteCapture'] is Map
          ? Map<String, dynamic>.from(record.payload['siteCapture'] as Map)
          : null,
    );
    final details = detailEntries(record.payload);

    final imageBlocks = <_EmbeddedBlock>[];
    final docBlocks = <_EmbeddedBlock>[];
    final skippedVideos = <FormAttachment>[];
    final unreadable = <FormAttachment>[];

    final selfie = site.selfie;
    if (selfie != null) {
      final block = await _loadImageBlock(selfie, label: 'Inspector selfie');
      if (block != null) {
        imageBlocks.add(block);
      } else {
        unreadable.add(selfie);
      }
    }

    for (final attachment in attachments) {
      final ext = attachment.extension.toLowerCase();
      if (AttachmentStorageService.isVideoExtension(ext)) {
        skippedVideos.add(attachment);
        continue;
      }
      if (isImageExtension(ext)) {
        final block = await _loadImageBlock(attachment);
        if (block != null) {
          imageBlocks.add(block);
        } else {
          unreadable.add(attachment);
        }
        continue;
      }
      if (isPdfExtension(ext)) {
        final pages = await _rasterizePdfAttachment(attachment);
        if (pages.isEmpty) {
          unreadable.add(attachment);
        } else {
          docBlocks.addAll(pages);
        }
        continue;
      }
      if (isTextExtension(ext)) {
        final text = await _readTextAttachment(attachment);
        if (text == null) {
          unreadable.add(attachment);
        } else {
          docBlocks.add(
            _EmbeddedBlock.text(
              title: attachment.name,
              body: text,
            ),
          );
        }
        continue;
      }

      // Office docs and other binaries: include a labeled placeholder.
      docBlocks.add(
        _EmbeddedBlock.note(
          title: attachment.name,
          body:
              'Document type .$ext cannot be rendered inline. '
              'Open the original file from the app attachments to view it.',
        ),
      );
    }

    final doc = pw.Document(
      title: '${record.formCode} Inspection',
      author: record.createdByUsername,
      subject: record.title,
      creator: 'ITCTC Forms',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.fromLTRB(36, 40, 36, 48),
        header: (context) => _buildHeader(record),
        footer: (context) => _buildFooter(context, record),
        build: (context) => [
          _sectionTitle('Inspection summary'),
          _metaTable(record, dateFormat),
          pw.SizedBox(height: 16),
          _sectionTitle('Field details'),
          _detailsTable(details),
          if (site.hasLocation) ...[
            pw.SizedBox(height: 16),
            _sectionTitle('Site location'),
            _kv('Address', site.locationAddress ?? '—'),
            if (site.latitude != null && site.longitude != null)
              _kv(
                'Coordinates',
                '${site.latitude!.toStringAsFixed(6)}, '
                    '${site.longitude!.toStringAsFixed(6)}',
              ),
            if (site.locationCapturedAt != null)
              _kv(
                'Captured',
                dateFormat.format(site.locationCapturedAt!.toLocal()),
              ),
          ],
          if (imageBlocks.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _sectionTitle('Images'),
            for (final block in imageBlocks) ...[
              pw.SizedBox(height: 8),
              pw.Text(
                block.title,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Image(
                pw.MemoryImage(block.bytes!),
                fit: pw.BoxFit.contain,
                height: 280,
              ),
            ],
          ],
          if (docBlocks.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _sectionTitle('Documents'),
            for (final block in docBlocks) ...[
              pw.SizedBox(height: 10),
              pw.Text(
                block.title,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              if (block.bytes != null)
                pw.Image(
                  pw.MemoryImage(block.bytes!),
                  fit: pw.BoxFit.contain,
                  height: 360,
                )
              else if (block.body != null)
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    block.body!,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
            ],
          ],
          if (skippedVideos.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _sectionTitle('Video attachments (not printed)'),
            pw.Text(
              'Videos are excluded from the printable PDF per store and '
              'print guidelines. Open them in the app if needed.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 6),
            for (final video in skippedVideos)
              pw.Bullet(
                text: '${video.name} (${_formatBytes(video.size)})',
                style: const pw.TextStyle(fontSize: 9),
              ),
          ],
          if (unreadable.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _sectionTitle('Attachments unavailable'),
            for (final item in unreadable)
              pw.Bullet(
                text: '${item.name} — file missing or unreadable',
                style: const pw.TextStyle(fontSize: 9),
              ),
          ],
          pw.SizedBox(height: 16),
          _sectionTitle('Inspection journey'),
          if (record.comments.isEmpty)
            pw.Text(
              'No workflow events yet.',
              style: const pw.TextStyle(fontSize: 10),
            )
          else
            for (final event in record.comments) ...[
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${event.action.label} · '
                      '${event.fromStatus.label} → ${event.toStatus.label}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      event.message,
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${event.authorUsername} (${UserRole.displayLabel(event.authorRole)}) · '
                      '${dateFormat.format(event.createdAt.toLocal())}',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );

    return doc.save();
  }

  /// System print dialog (no storage permission required).
  static Future<void> printPdf(InspectionRecord record) async {
    final bytes = await buildPdf(record);
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: fileNameFor(record),
    );
  }

  /// Share / save via the OS sheet (Files, Drive, AirDrop, etc.).
  static Future<void> sharePdf(InspectionRecord record) async {
    final bytes = await buildPdf(record);
    final name = fileNameFor(record);
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, name));
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf', name: name)],
        subject: '${record.formCode} inspection PDF',
        text: 'Printable inspection report for ${record.formCode}.',
      ),
    );
  }

  static List<MapEntry<String, String>> detailEntries(
    Map<String, dynamic> payload,
  ) {
    const skip = {
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
      entries.add(MapEntry(prettyKey(key), value?.toString() ?? '—'));
    });
    if (entries.isEmpty) {
      entries.add(const MapEntry('Details', 'No field values yet'));
    }
    return entries;
  }

  static String prettyKey(String key) {
    final spaced = key.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m[1]} ${m[2]}',
    );
    if (spaced.isEmpty) return key;
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  static pw.Widget _buildHeader(InspectionRecord record) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'NHSRCL · ITCTC',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey800,
                  ),
                ),
                pw.Text(
                  'Field Inspection Report',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.Text(
              record.formCode,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Divider(color: PdfColors.blueGrey400, thickness: 1),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _buildFooter(
    pw.Context context,
    InspectionRecord record,
  ) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey400, thickness: 0.5),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'ID: ${record.id}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 6),
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      color: PdfColors.blueGrey50,
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey900,
        ),
      ),
    );
  }

  static pw.Widget _metaTable(
    InspectionRecord record,
    DateFormat dateFormat,
  ) {
    final rows = <List<String>>[
      ['Title', record.title],
      ['Status', record.status.label],
      ['Created by', record.createdByUsername],
      ['Created', dateFormat.format(record.createdAt.toLocal())],
      ['Updated', dateFormat.format(record.updatedAt.toLocal())],
      if (record.assignedToRole != null)
        ['Assigned to', UserRole.displayLabel(record.assignedToRole)],
    ];
    return _twoColumnTable(rows);
  }

  static pw.Widget _detailsTable(List<MapEntry<String, String>> details) {
    return _twoColumnTable([
      for (final e in details) [e.key, e.value.trim().isEmpty ? '—' : e.value],
    ]);
  }

  static pw.Widget _twoColumnTable(List<List<String>> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(3),
      },
      children: [
        for (final row in rows)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  row[0],
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  row[1],
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  static pw.Widget _kv(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 90,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  static Future<_EmbeddedBlock?> _loadImageBlock(
    FormAttachment attachment, {
    String? label,
  }) async {
    final file = File(attachment.path);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return null;
    return _EmbeddedBlock.image(
      title: label ?? attachment.name,
      bytes: bytes,
    );
  }

  static Future<List<_EmbeddedBlock>> _rasterizePdfAttachment(
    FormAttachment attachment,
  ) async {
    final file = File(attachment.path);
    if (!await file.exists()) return const [];
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return const [];

    final blocks = <_EmbeddedBlock>[];
    var index = 0;
    try {
      await for (final page in Printing.raster(
        bytes,
        dpi: 120,
      )) {
        index++;
        if (index > maxEmbeddedPdfPages) {
          blocks.add(
            _EmbeddedBlock.note(
              title: attachment.name,
              body:
                  'Only the first $maxEmbeddedPdfPages pages were included. '
                  'Open the original PDF attachment for the full document.',
            ),
          );
          break;
        }
        final png = await page.toPng();
        blocks.add(
          _EmbeddedBlock.image(
            title: '${attachment.name} — page $index',
            bytes: png,
          ),
        );
      }
    } catch (_) {
      return [
        _EmbeddedBlock.note(
          title: attachment.name,
          body: 'Could not render this PDF inline. Open the original attachment.',
        ),
      ];
    }
    return blocks;
  }

  static Future<String?> _readTextAttachment(FormAttachment attachment) async {
    final file = File(attachment.path);
    if (!await file.exists()) return null;
    try {
      final text = await file.readAsString();
      if (text.length > 20000) {
        return '${text.substring(0, 20000)}\n\n… truncated for print …';
      }
      return text;
    } catch (_) {
      return null;
    }
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _EmbeddedBlock {
  const _EmbeddedBlock._({
    required this.title,
    this.bytes,
    this.body,
  });

  factory _EmbeddedBlock.image({
    required String title,
    required Uint8List bytes,
  }) =>
      _EmbeddedBlock._(title: title, bytes: bytes);

  factory _EmbeddedBlock.text({
    required String title,
    required String body,
  }) =>
      _EmbeddedBlock._(title: title, body: body);

  factory _EmbeddedBlock.note({
    required String title,
    required String body,
  }) =>
      _EmbeddedBlock._(title: title, body: body);

  final String title;
  final Uint8List? bytes;
  final String? body;
}
