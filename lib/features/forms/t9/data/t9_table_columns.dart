// T-9: 12 leaf columns
import '../../shared/models/form_table_column.dart';
import '../../shared/models/form_table_header.dart';

final t9TableDefinition = FormTableDefinition(
  headerRows: [
    [
      FormTableHeaderCell(label: 'Up /\nDown', rowSpan: 2),
      FormTableHeaderCell(label: 'Chainage', colSpan: 3),
      FormTableHeaderCell(label: 'Sleeper\nNo.', rowSpan: 2),
      FormTableHeaderCell(label: 'Injection thickness (mm)', colSpan: 4),
      FormTableHeaderCell(label: 'Gap\n(mm)', rowSpan: 2),
      FormTableHeaderCell(label: 'Reference/\nAttachments', rowSpan: 2),
      FormTableHeaderCell(label: 'Remarks', rowSpan: 2),
    ],
    [
      FormTableHeaderCell(label: 'km'),
      FormTableHeaderCell(label: 'm'),
      FormTableHeaderCell(label: 'cm'),
      FormTableHeaderCell(label: 'Left'),
      FormTableHeaderCell(label: 'Centre'),
      FormTableHeaderCell(label: 'Right'),
      FormTableHeaderCell(label: 'Average'),
    ],
  ],
  columns: [
    FormTableColumn(title: 'Up/Down', minWidth: 56, value: (r, _) => tableCell(r['direction'])),
    FormTableColumn(title: 'km', minWidth: 48, value: (r, _) => tableCell(r['chainageKm'])),
    FormTableColumn(title: 'm', minWidth: 48, value: (r, _) => tableCell(r['chainageM'])),
    FormTableColumn(title: 'cm', minWidth: 48, value: (r, _) => tableCell(r['chainageCm'])),
    FormTableColumn(title: 'Sleeper', minWidth: 64, value: (r, _) => tableCell(r['sleeperNo'])),
    FormTableColumn(title: 'Left', minWidth: 56, value: (r, _) => tableCell(r['thicknessLeft'])),
    FormTableColumn(title: 'Centre', minWidth: 56, value: (r, _) => tableCell(r['thicknessCentre'])),
    FormTableColumn(title: 'Right', minWidth: 56, value: (r, _) => tableCell(r['thicknessRight'])),
    FormTableColumn(title: 'Average', minWidth: 64, value: (r, _) => tableCell(r['thicknessAverage'])),
    FormTableColumn(title: 'Gap', minWidth: 56, value: (r, _) => tableCell(r['gap'])),
    FormTableColumn(
      title: 'Attachments',
      minWidth: 88,
      value: (r, _) => attachmentsTableCell(r['attachments']),
    ),
    FormTableColumn(title: 'Remarks', minWidth: 100, value: (r, _) => tableCell(r['remarks'])),
  ],
);
