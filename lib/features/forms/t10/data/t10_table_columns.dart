import '../../shared/models/form_table_column.dart';
import '../../shared/models/form_table_header.dart';

final t10TableDefinition = FormTableDefinition(
  headerRows: [
    [
      FormTableHeaderCell(label: 'Up /\nDown', rowSpan: 2),
      FormTableHeaderCell(label: 'Chainage', colSpan: 3),
      FormTableHeaderCell(label: 'Sleeper\nNo.', rowSpan: 2),
      FormTableHeaderCell(label: 'Measured value (Nm)', colSpan: 2),
      FormTableHeaderCell(label: 'Reference/\nAttachments', rowSpan: 2),
      FormTableHeaderCell(label: 'Remarks', rowSpan: 2),
    ],
    [
      FormTableHeaderCell(label: 'km'),
      FormTableHeaderCell(label: 'm'),
      FormTableHeaderCell(label: 'cm'),
      FormTableHeaderCell(label: 'Left'),
      FormTableHeaderCell(label: 'Right'),
    ],
  ],
  columns: [
    FormTableColumn(title: 'Up/Down', minWidth: 56, value: (r, _) => tableCell(r['direction'])),
    FormTableColumn(title: 'km', minWidth: 48, value: (r, _) => tableCell(r['chainageKm'])),
    FormTableColumn(title: 'm', minWidth: 48, value: (r, _) => tableCell(r['chainageM'])),
    FormTableColumn(title: 'cm', minWidth: 48, value: (r, _) => tableCell(r['chainageCm'])),
    FormTableColumn(title: 'Sleeper No.', minWidth: 64, value: (r, _) => tableCell(r['sleeperNo'])),
    FormTableColumn(title: 'Left', minWidth: 64, value: (r, _) => tableCell(r['torqueLeft'])),
    FormTableColumn(title: 'Right', minWidth: 64, value: (r, _) => tableCell(r['torqueRight'])),
    FormTableColumn(
      title: 'Attachments',
      minWidth: 88,
      value: (r, _) => attachmentsTableCell(r['attachments']),
    ),
    FormTableColumn(title: 'Remarks', minWidth: 100, value: (r, _) => tableCell(r['remarks'])),
  ],
);
