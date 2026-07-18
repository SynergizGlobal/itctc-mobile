import 'package:flutter_test/flutter_test.dart';
import 'package:itctc/features/inspections/models/inspection_record.dart';
import 'package:itctc/features/inspections/models/inspection_status.dart';
import 'package:itctc/features/inspections/services/inspection_pdf_service.dart';
import 'package:pdf/pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InspectionPdfService helpers', () {
    test('prettyKey splits camelCase', () {
      expect(InspectionPdfService.prettyKey('railSeat'), 'Rail Seat');
      expect(InspectionPdfService.prettyKey('km'), 'Km');
    });

    test('detailEntries skips nested payload and siteCapture', () {
      final entries = InspectionPdfService.detailEntries({
        'id': 'x',
        'attachments': [],
        'siteCapture': {'locationAddress': 'Somewhere'},
        'railSeat': 'OK',
        'gauge': 1435,
        'nested': {'a': 1},
      });

      expect(entries.map((e) => e.key), ['Rail Seat', 'Gauge']);
      expect(entries.first.value, 'OK');
    });

    test('extension classifiers', () {
      expect(InspectionPdfService.isImageExtension('JPG'), isTrue);
      expect(InspectionPdfService.isPdfExtension('pdf'), isTrue);
      expect(InspectionPdfService.isTextExtension('csv'), isTrue);
      expect(InspectionPdfService.isImageExtension('mp4'), isFalse);
    });
  });

  group('InspectionPdfService.buildPdf fonts', () {
    setUp(InspectionPdfService.resetFontCacheForTest);

    test('embeds Noto Sans and renders Unicode glyphs', () async {
      final now = DateTime.utc(2026, 7, 18, 12);
      final record = InspectionRecord(
        id: 'pdf-font-test',
        formId: 't2',
        formCode: 'Form T-2',
        title: 'Track Irregularity',
        status: InspectionStatus.draft,
        createdByUsername: 'in',
        createdAt: now,
        updatedAt: now,
        payload: {
          'chainageKm': '12',
          'chainageM': '345',
          'note': 'Gap — check → left · right …',
        },
      );

      final bytes = await InspectionPdfService.buildPdf(
        record,
        pageFormat: PdfPageFormat.a4,
      );

      expect(bytes.length, greaterThan(1000));
      // Font name appears in the PDF stream when embedded.
      final asString = String.fromCharCodes(bytes);
      expect(asString.contains('NotoSans'), isTrue);
    });

    test('pdfText normalizes fancy punctuation', () {
      expect(
        InspectionPdfService.pdfText('Gap — check → left · right …'),
        'Gap - check -> left - right ...',
      );
    });
  });
}
