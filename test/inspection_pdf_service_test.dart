import 'package:flutter_test/flutter_test.dart';
import 'package:itctc/features/inspections/services/inspection_pdf_service.dart';

void main() {
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
}
