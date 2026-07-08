// T-8: 11 leaf columns
import '../../shared/models/form_table_column.dart';
import '../../shared/models/form_table_header.dart';

final t8TableDefinition = FormTableDefinition(
  headerRows: [
    [
      FormTableHeaderCell(label: 'Up /\nDown', rowSpan: 2),
      FormTableHeaderCell(label: 'Chainage', colSpan: 3),
      FormTableHeaderCell(label: 'Sleeper\nNo.', rowSpan: 2),
      FormTableHeaderCell(label: 'Squareness\n(mm)', rowSpan: 2),
      FormTableHeaderCell(label: 'Spacing (mm)', colSpan: 3),
      FormTableHeaderCell(label: 'Reference/\nAttachments', rowSpan: 2),
      FormTableHeaderCell(label: 'Remarks', rowSpan: 2),
    ],
    [
      FormTableHeaderCell(label: 'km'),
      FormTableHeaderCell(label: 'm'),
      FormTableHeaderCell(label: 'cm'),
      FormTableHeaderCell(label: 'Design'),
      FormTableHeaderCell(label: 'Measured'),
      FormTableHeaderCell(label: 'Irregularity'),
    ],
  ],
  columns: [
    FormTableColumn(
      title: 'Up/Down',
      minWidth: 56,
      value: (r, _) => tableCell(r['direction']),
    ),
    FormTableColumn(title: 'km', minWidth: 48, value: (r, _) => tableCell(r['chainageKm'])),
    FormTableColumn(title: 'm', minWidth: 48, value: (r, _) => tableCell(r['chainageM'])),
    FormTableColumn(title: 'cm', minWidth: 48, value: (r, _) => tableCell(r['chainageCm'])),
    FormTableColumn(title: 'Sleeper', minWidth: 64, value: (r, _) => tableCell(r['sleeperNo'])),
    FormTableColumn(title: 'Squareness', minWidth: 72, value: (r, _) => tableCell(r['squareness'])),
    FormTableColumn(title: 'Design', minWidth: 64, value: (r, _) => tableCell(r['spacingDesign'])),
    FormTableColumn(title: 'Measured', minWidth: 72, value: (r, _) => tableCell(r['spacingMeasured'])),
    FormTableColumn(
      title: 'Irregularity',
      minWidth: 72,
      value: (r, _) => tableCell(r['spacingIrregularity']),
    ),
    FormTableColumn(
      title: 'Attachments',
      minWidth: 88,
      value: (r, _) => attachmentsTableCell(r['attachments']),
    ),
    FormTableColumn(title: 'Remarks', minWidth: 100, value: (r, _) => tableCell(r['remarks'])),
  ],
);
