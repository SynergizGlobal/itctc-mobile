import '../../shared/models/form_table_column.dart';
import '../../shared/models/form_table_header.dart';

final t21TableDefinition = FormTableDefinition(
  headerRows: [
    [
      FormTableHeaderCell(label: 'Line', rowSpan: 2),
      FormTableHeaderCell(label: 'Chainage', colSpan: 2),
      FormTableHeaderCell(
        label: 'Distance from Fouling Mark\nto Insulated Joint (m)',
        colSpan: 2,
      ),
      FormTableHeaderCell(
        label: 'Track effective length\n(Insulated Joint + 1.0 m - Stop Limit Sign) (m)',
        colSpan: 3,
      ),
      FormTableHeaderCell(label: 'Reference/\nAttachments', rowSpan: 2),
      FormTableHeaderCell(label: 'Remarks', rowSpan: 2),
    ],
    [
      FormTableHeaderCell(label: 'km'),
      FormTableHeaderCell(label: 'm'),
      FormTableHeaderCell(label: 'Design\n(A)'),
      FormTableHeaderCell(label: 'Measured\n(D)'),
      FormTableHeaderCell(label: 'Design\n(B)'),
      FormTableHeaderCell(label: 'Measured\n(E)'),
      FormTableHeaderCell(label: 'Irregularity\n(E)-(B)'),
    ],
  ],
  columns: [
    FormTableColumn(title: 'Line', minWidth: 72, value: (r, _) => tableCell(r['line'])),
    FormTableColumn(title: 'km', minWidth: 48, value: (r, _) => tableCell(r['chainageKm'])),
    FormTableColumn(title: 'm', minWidth: 48, value: (r, _) => tableCell(r['chainageM'])),
    FormTableColumn(
      title: 'Design (A)',
      minWidth: 72,
      value: (r, _) => tableCell(r['foulingDesign']),
    ),
    FormTableColumn(
      title: 'Measured (D)',
      minWidth: 80,
      value: (r, _) => tableCell(r['foulingMeasured']),
    ),
    FormTableColumn(
      title: 'Design (B)',
      minWidth: 72,
      value: (r, _) => tableCell(r['trackLengthDesign']),
    ),
    FormTableColumn(
      title: 'Measured (E)',
      minWidth: 80,
      value: (r, _) => tableCell(r['trackLengthMeasured']),
    ),
    FormTableColumn(
      title: 'Irregularity',
      minWidth: 80,
      value: (r, _) => tableCell(r['trackLengthIrregularity']),
    ),
    FormTableColumn(
      title: 'Attachments',
      minWidth: 88,
      value: (r, _) => attachmentsTableCell(r['attachments']),
    ),
    FormTableColumn(title: 'Remarks', minWidth: 100, value: (r, _) => tableCell(r['remarks'])),
  ],
);
