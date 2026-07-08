// T-7-2: 21 leaf columns
import '../../shared/models/form_table_column.dart';
import '../../shared/models/form_table_header.dart';

final t72TableDefinition = FormTableDefinition(
  headerRows: [
    [
      FormTableHeaderCell(label: 'Up /\nDown', rowSpan: 2),
      FormTableHeaderCell(label: 'RC anchor\nserial', rowSpan: 2),
      FormTableHeaderCell(label: 'Chainage', colSpan: 2),
      FormTableHeaderCell(label: 'Track slab', colSpan: 2),
      FormTableHeaderCell(label: 'Resin (mm)', colSpan: 2),
      FormTableHeaderCell(label: 'CAM injection thickness (mm)', colSpan: 9),
      FormTableHeaderCell(label: 'Gap (mm)', colSpan: 2),
      FormTableHeaderCell(label: 'Pin condition', colSpan: 2),
      FormTableHeaderCell(label: 'Reference/\nAttachments', rowSpan: 2),
      FormTableHeaderCell(label: 'Remarks', rowSpan: 2),
    ],
    [
      FormTableHeaderCell(label: 'km'),
      FormTableHeaderCell(label: 'm'),
      FormTableHeaderCell(label: 'No.'),
      FormTableHeaderCell(label: 'Type'),
      FormTableHeaderCell(label: 'Origin'),
      FormTableHeaderCell(label: 'End'),
      ...List.generate(8, (i) => FormTableHeaderCell(label: '${i + 1}')),
      const FormTableHeaderCell(label: 'Avg'),
      FormTableHeaderCell(label: 'Origin'),
      FormTableHeaderCell(label: 'End'),
      FormTableHeaderCell(label: 'Origin'),
      FormTableHeaderCell(label: 'End'),
    ],
  ],
  columns: [
    FormTableColumn(title: 'Up/Down', minWidth: 52, value: (r, _) => tableCell(r['direction'])),
    FormTableColumn(title: 'RC', minWidth: 64, value: (r, _) => tableCell(r['rcAnchorSerial'])),
    FormTableColumn(title: 'km', minWidth: 44, value: (r, _) => tableCell(r['chainageKm'])),
    FormTableColumn(title: 'm', minWidth: 44, value: (r, _) => tableCell(r['chainageM'])),
    FormTableColumn(title: 'Slab No', minWidth: 56, value: (r, _) => tableCell(r['slabNumber'])),
    FormTableColumn(title: 'Slab Type', minWidth: 64, value: (r, _) => tableCell(r['slabType'])),
    FormTableColumn(
      title: 'Resin O',
      minWidth: 56,
      value: (r, _) => tableCell(r['resinOriginDisplay'] ?? r['resinOrigin']),
    ),
    FormTableColumn(
      title: 'Resin E',
      minWidth: 56,
      value: (r, _) => tableCell(r['resinEndDisplay'] ?? r['resinEnd']),
    ),
    for (var i = 1; i <= 8; i++)
      FormTableColumn(title: 'CAM$i', minWidth: 48, value: (r, _) => tableCell(r['cam$i'])),
    FormTableColumn(title: 'CAM Avg', minWidth: 56, value: (r, _) => tableCell(r['camAverage'])),
    FormTableColumn(title: 'Gap O', minWidth: 52, value: (r, _) => tableCell(r['gapOrigin'])),
    FormTableColumn(title: 'Gap E', minWidth: 52, value: (r, _) => tableCell(r['gapEnd'])),
    FormTableColumn(title: 'Pin O', minWidth: 64, value: (r, _) => tableCell(r['pinOrigin'])),
    FormTableColumn(title: 'Pin E', minWidth: 64, value: (r, _) => tableCell(r['pinEnd'])),
    FormTableColumn(
      title: 'Attachments',
      minWidth: 88,
      value: (r, _) => attachmentsTableCell(r['attachments']),
    ),
    FormTableColumn(title: 'Remarks', minWidth: 96, value: (r, _) => tableCell(r['remarks'])),
  ],
);
