import '../../shared/models/form_table_column.dart';
import '../../shared/models/form_table_header.dart';

final t22TableDefinition = FormTableDefinition(
  headerRows: [
    [
      FormTableHeaderCell(label: 'Line', rowSpan: 2),
      FormTableHeaderCell(label: 'Measurement point', colSpan: 5),
      FormTableHeaderCell(label: 'Reference/\nAttachments', rowSpan: 2),
      FormTableHeaderCell(label: 'Remarks', rowSpan: 2),
    ],
    [
      FormTableHeaderCell(label: '(1)\n250 mm'),
      FormTableHeaderCell(label: '(2)\n5,000 mm'),
      FormTableHeaderCell(label: '(3)\n1,000 mm'),
      FormTableHeaderCell(label: '(4)\n3,400 mm'),
      FormTableHeaderCell(label: '(5)\n3,900 mm'),
    ],
  ],
  columns: [
    FormTableColumn(title: 'Line', minWidth: 72, value: (r, _) => tableCell(r['line'])),
    FormTableColumn(title: '(1)', minWidth: 72, value: (r, _) => tableCell(r['point1'])),
    FormTableColumn(title: '(2)', minWidth: 72, value: (r, _) => tableCell(r['point2'])),
    FormTableColumn(title: '(3)', minWidth: 72, value: (r, _) => tableCell(r['point3'])),
    FormTableColumn(title: '(4)', minWidth: 72, value: (r, _) => tableCell(r['point4'])),
    FormTableColumn(title: '(5)', minWidth: 72, value: (r, _) => tableCell(r['point5'])),
    FormTableColumn(
      title: 'Attachments',
      minWidth: 88,
      value: (r, _) => attachmentsTableCell(r['attachments']),
    ),
    FormTableColumn(title: 'Remarks', minWidth: 100, value: (r, _) => tableCell(r['remarks'])),
  ],
);
