import '../../shared/models/form_table_column.dart';
import '../../shared/models/form_table_header.dart';

final t13TableDefinition = FormTableDefinition(
  headerRows: [
    [
      FormTableHeaderCell(label: 'Line', rowSpan: 2),
      FormTableHeaderCell(
        label: 'Chainage and Location\nof the Fouling Mark',
        rowSpan: 2,
      ),
      FormTableHeaderCell(label: 'Design\nvalue (m)', rowSpan: 2),
      FormTableHeaderCell(label: 'Measured\nvalue (m)', rowSpan: 2),
      FormTableHeaderCell(label: 'Difference\n(m)', rowSpan: 2),
      FormTableHeaderCell(label: 'Reference/\nAttachments', rowSpan: 2),
      FormTableHeaderCell(label: 'Remarks', rowSpan: 2),
    ],
  ],
  columns: [
    FormTableColumn(title: 'Line', minWidth: 72, value: (r, _) => tableCell(r['line'])),
    FormTableColumn(
      title: 'Location',
      minWidth: 140,
      value: (r, _) => tableCell(r['location']),
    ),
    FormTableColumn(
      title: 'Design (m)',
      minWidth: 72,
      value: (r, _) => tableCell(r['designValue']),
    ),
    FormTableColumn(
      title: 'Measured (m)',
      minWidth: 80,
      value: (r, _) => tableCell(r['measuredValue']),
    ),
    FormTableColumn(
      title: 'Difference (m)',
      minWidth: 88,
      value: (r, _) => tableCell(r['difference']),
    ),
    FormTableColumn(
      title: 'Attachments',
      minWidth: 88,
      value: (r, _) => attachmentsTableCell(r['attachments']),
    ),
    FormTableColumn(title: 'Remarks', minWidth: 100, value: (r, _) => tableCell(r['remarks'])),
  ],
);
