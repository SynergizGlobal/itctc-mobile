import '../../shared/models/form_table_column.dart';
import '../../shared/models/form_table_header.dart';

String _meas(Map<String, dynamic> row, String line, String field, String type) {
  final lineData = row[line] as Map<String, dynamic>?;
  if (lineData == null) return '—';
  final m = lineData[field] as Map<String, dynamic>?;
  if (m == null) return '—';
  return tableCell(m[type]);
}

List<FormTableColumn> _lineMeasurementColumns({
  required String lineKey,
  required String prefix,
  required List<String> fields,
  required List<String> labels,
}) {
  final columns = <FormTableColumn>[];
  for (var i = 0; i < fields.length; i++) {
    final field = fields[i];
    final label = labels[i];
    columns.addAll([
      FormTableColumn(
        title: '$prefix $label D',
        minWidth: 58,
        value: (r, _) => _meas(r, lineKey, field, 'design'),
      ),
      FormTableColumn(
        title: '$prefix $label M',
        minWidth: 58,
        value: (r, _) => _meas(r, lineKey, field, 'measured'),
      ),
      FormTableColumn(
        title: '$prefix $label I',
        minWidth: 58,
        value: (r, _) => _meas(r, lineKey, field, 'irregularity'),
      ),
    ]);
  }
  return columns;
}

const _dlFields = [
  'twist',
  'lateralAlignment',
  'longitudinalAlignment',
  'crossLevel',
  'gauge',
];
const _dlLabels = [
  'Twist',
  'Lateral',
  'Long.',
  'Cross',
  'Gauge',
];

const _ulFields = [
  'gauge',
  'crossLevel',
  'longitudinalAlignment',
  'lateralAlignment',
  'twist',
];
const _ulLabels = [
  'Gauge',
  'Cross',
  'Long.',
  'Lateral',
  'Twist',
];

final t2TableDefinition = FormTableDefinition(
  headerRows: [
    [
      FormTableHeaderCell(label: 'Down Line', colSpan: 16),
      FormTableHeaderCell(label: 'Chainage', colSpan: 2, rowSpan: 2),
      FormTableHeaderCell(label: 'Up Line', colSpan: 16),
      FormTableHeaderCell(label: 'Reference/\nAttachments', rowSpan: 3),
    ],
    [
      FormTableHeaderCell(label: 'Twist', colSpan: 3),
      FormTableHeaderCell(label: 'Lateral\nalignment', colSpan: 3),
      FormTableHeaderCell(label: 'Longitudinal\nalignment', colSpan: 3),
      FormTableHeaderCell(label: 'Cross\nLevel', colSpan: 3),
      FormTableHeaderCell(label: 'Gauge', colSpan: 3),
      FormTableHeaderCell(label: 'Measuring\npoint', rowSpan: 2),
      FormTableHeaderCell(label: 'Measuring\npoint', rowSpan: 2),
      FormTableHeaderCell(label: 'Gauge', colSpan: 3),
      FormTableHeaderCell(label: 'Cross\nLevel', colSpan: 3),
      FormTableHeaderCell(label: 'Longitudinal\nalignment', colSpan: 3),
      FormTableHeaderCell(label: 'Lateral\nalignment', colSpan: 3),
      FormTableHeaderCell(label: 'Twist', colSpan: 3),
    ],
    [
      const FormTableHeaderCell(label: 'Design\nvalue'),
      const FormTableHeaderCell(label: 'Measured\nvalue'),
      const FormTableHeaderCell(label: 'Irregularity'),
      const FormTableHeaderCell(label: 'Design\nvalue'),
      const FormTableHeaderCell(label: 'Measured\nvalue'),
      const FormTableHeaderCell(label: 'Irregularity'),
      const FormTableHeaderCell(label: 'Design\nvalue'),
      const FormTableHeaderCell(label: 'Measured\nvalue'),
      const FormTableHeaderCell(label: 'Irregularity'),
      const FormTableHeaderCell(label: 'Design\nvalue'),
      const FormTableHeaderCell(label: 'Measured\nvalue'),
      const FormTableHeaderCell(label: 'Irregularity'),
      const FormTableHeaderCell(label: 'Design\nvalue'),
      const FormTableHeaderCell(label: 'Measured\nvalue'),
      const FormTableHeaderCell(label: 'Irregularity'),
      FormTableHeaderCell(label: 'km'),
      FormTableHeaderCell(label: 'm'),
      const FormTableHeaderCell(label: 'Design\nvalue'),
      const FormTableHeaderCell(label: 'Measured\nvalue'),
      const FormTableHeaderCell(label: 'Irregularity'),
      const FormTableHeaderCell(label: 'Design\nvalue'),
      const FormTableHeaderCell(label: 'Measured\nvalue'),
      const FormTableHeaderCell(label: 'Irregularity'),
      const FormTableHeaderCell(label: 'Design\nvalue'),
      const FormTableHeaderCell(label: 'Measured\nvalue'),
      const FormTableHeaderCell(label: 'Irregularity'),
      const FormTableHeaderCell(label: 'Design\nvalue'),
      const FormTableHeaderCell(label: 'Measured\nvalue'),
      const FormTableHeaderCell(label: 'Irregularity'),
      const FormTableHeaderCell(label: 'Design\nvalue'),
      const FormTableHeaderCell(label: 'Measured\nvalue'),
      const FormTableHeaderCell(label: 'Irregularity'),
    ],
  ],
  columns: [
    ..._lineMeasurementColumns(
      lineKey: 'downLine',
      prefix: 'DL',
      fields: _dlFields,
      labels: _dlLabels,
    ),
    FormTableColumn(
      title: 'DL Pt',
      minWidth: 64,
      value: (r, _) {
        final dl = r['downLine'] as Map<String, dynamic>?;
        return tableCell(dl?['measuringPoint']);
      },
    ),
    FormTableColumn(title: 'km', minWidth: 56, value: (r, _) => tableCell(r['chainageKm'])),
    FormTableColumn(title: 'm', minWidth: 56, value: (r, _) => tableCell(r['chainageM'])),
    FormTableColumn(
      title: 'UL Pt',
      minWidth: 64,
      value: (r, _) {
        final ul = r['upLine'] as Map<String, dynamic>?;
        return tableCell(ul?['measuringPoint']);
      },
    ),
    ..._lineMeasurementColumns(
      lineKey: 'upLine',
      prefix: 'UL',
      fields: _ulFields,
      labels: _ulLabels,
    ),
    FormTableColumn(
      title: 'Attachments',
      minWidth: 120,
      value: (r, _) => attachmentsTableCell(r['attachments']),
    ),
  ],
);
