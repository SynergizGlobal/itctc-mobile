import '../../shared/models/form_table_column.dart';
import '../../shared/models/form_table_header.dart';

final t72TableDefinition = FormTableDefinition(
  headerRows: [
    [
      FormTableHeaderCell(label: 'Up /\nDown', rowSpan: 2),
      FormTableHeaderCell(label: 'Serial Number\nof RC anchor', rowSpan: 2),
      FormTableHeaderCell(label: 'Chainage', colSpan: 2),
      FormTableHeaderCell(label: 'Track slab', colSpan: 2),
      FormTableHeaderCell(label: 'Resin injection\nthickness', colSpan: 2),
      FormTableHeaderCell(label: 'CAM injection\nthickness', colSpan: 9),
      FormTableHeaderCell(label: 'Gap', colSpan: 2),
      FormTableHeaderCell(label: 'Reference pin\ncondition', colSpan: 2),
      FormTableHeaderCell(label: 'Reference/\nAttachments', rowSpan: 2),
      FormTableHeaderCell(label: 'Remarks', rowSpan: 2),
    ],
    [
      FormTableHeaderCell(label: 'km'),
      FormTableHeaderCell(label: 'm'),
      FormTableHeaderCell(label: 'Number'),
      FormTableHeaderCell(label: 'Type'),
      FormTableHeaderCell(label: 'Origin'),
      FormTableHeaderCell(label: 'End'),
      ...List.generate(8, (i) => FormTableHeaderCell(label: '${i + 1}')),
      const FormTableHeaderCell(label: 'Average'),
      FormTableHeaderCell(label: 'Origin'),
      FormTableHeaderCell(label: 'End'),
      FormTableHeaderCell(label: 'Origin'),
      FormTableHeaderCell(label: 'End'),
    ],
  ],
  columns: [
    FormTableColumn(title: 'Up/Down', minWidth: 52, value: (r, _) => tableCell(r['direction'])),
    FormTableColumn(title: 'RC anchor', minWidth: 64, value: (r, _) => tableCell(r['rcAnchorSerial'])),
    FormTableColumn(title: 'km', minWidth: 44, value: (r, _) => tableCell(r['chainageKm'])),
    FormTableColumn(title: 'm', minWidth: 44, value: (r, _) => tableCell(r['chainageM'])),
    FormTableColumn(title: 'Slab No.', minWidth: 56, value: (r, _) => tableCell(r['slabNumber'])),
    FormTableColumn(title: 'Slab Type', minWidth: 64, value: (r, _) => tableCell(r['slabType'])),
    FormTableColumn(
      title: 'Resin Origin',
      minWidth: 56,
      value: (r, _) => tableCell(r['resinOriginDisplay'] ?? r['resinOrigin']),
    ),
    FormTableColumn(
      title: 'Resin End',
      minWidth: 56,
      value: (r, _) => tableCell(r['resinEndDisplay'] ?? r['resinEnd']),
    ),
    for (var i = 1; i <= 8; i++)
      FormTableColumn(title: '$i', minWidth: 48, value: (r, _) => tableCell(r['cam$i'])),
    FormTableColumn(title: 'Average', minWidth: 56, value: (r, _) => tableCell(r['camAverage'])),
    FormTableColumn(title: 'Gap Origin', minWidth: 52, value: (r, _) => tableCell(r['gapOrigin'])),
    FormTableColumn(title: 'Gap End', minWidth: 52, value: (r, _) => tableCell(r['gapEnd'])),
    FormTableColumn(title: 'Pin Origin', minWidth: 64, value: (r, _) => tableCell(r['pinOrigin'])),
    FormTableColumn(title: 'Pin End', minWidth: 64, value: (r, _) => tableCell(r['pinEnd'])),
    FormTableColumn(
      title: 'Attachments',
      minWidth: 88,
      value: (r, _) => attachmentsTableCell(r['attachments']),
    ),
    FormTableColumn(title: 'Remarks', minWidth: 96, value: (r, _) => tableCell(r['remarks'])),
  ],
);
