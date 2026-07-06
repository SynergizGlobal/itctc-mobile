import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/form_calculations.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../providers/form_table_providers.dart';
import '../../shared/widgets/form_entry_stepper_layout.dart';
import '../../shared/widgets/form_attachments_field.dart';
import '../models/t2_entry.dart';
import '../widgets/t2_line_fields.dart';

class T2FormScreen extends ConsumerStatefulWidget {
  const T2FormScreen({super.key, this.editIndex});

  final int? editIndex;

  @override
  ConsumerState<T2FormScreen> createState() => _T2FormScreenState();
}

class _T2FormScreenState extends ConsumerState<T2FormScreen> {
  static const _stepCount = 5;

  T2Entry? _entry;
  bool _loaded = false;
  int _step = 0;

  @override
  void dispose() {
    _entry?.dispose();
    super.dispose();
  }

  void _ensureLoaded() {
    if (_loaded) return;
    _loaded = true;

    if (widget.editIndex != null) {
      final rows = ref.read(t2TableProvider);
      if (widget.editIndex! < rows.length) {
        _entry = T2Entry.fromMap(rows[widget.editIndex!]);
        return;
      }
    }
    _entry = T2Entry();
  }

  T2Entry get entry {
    _ensureLoaded();
    return _entry!;
  }

  void _refresh() => setState(() {});

  void _saveToTable() {
    final record = entry.toJson();
    if (widget.editIndex != null) {
      ref.read(t2TableProvider.notifier).updateRecord(widget.editIndex!, record);
    } else {
      ref.read(t2TableProvider.notifier).addRecord(record);
    }
    context.pop();
  }

  void _goNext() {
    if (_step == _stepCount - 1) {
      _saveToTable();
      return;
    }
    setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    _ensureLoaded();
    final theme = Theme.of(context);
    final isEdit = widget.editIndex != null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEdit ? 'Edit Record' : 'Add Record', style: theme.textTheme.titleMedium),
            Text(
              'Form T-2 — Track Irregularity',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: FormEntryStepperLayout(
        stepCount: _stepCount,
        currentStep: _step,
        isLoading: false,
        header: _step > 0 ? ToleranceReferenceCard(trackType: entry.trackType) : null,
        onStepTap: (s) => setState(() => _step = s),
        onPrevious: () {
          if (_step > 0) setState(() => _step--);
        },
        onNext: _goNext,
        child: _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ChainageFields(
              kmController: entry.chainageKmController,
              mController: entry.chainageMController,
            ),
            const SizedBox(height: 16),
            Text('Track Type', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<TrackType>(
              segments: const [
                ButtonSegment(value: TrackType.slab, label: Text('Slab Track')),
                ButtonSegment(value: TrackType.ballasted, label: Text('Ballasted Track')),
              ],
              selected: {entry.trackType},
              onSelectionChanged: (s) => setState(() => entry.trackType = s.first),
            ),
            const SizedBox(height: 16),
            ToleranceReferenceCard(trackType: entry.trackType),
          ],
        ),
      1 => T2LineFields(
          lineData: entry.downLine,
          lineLabel: 'Down Line',
          trackType: entry.trackType,
          onChanged: _refresh,
        ),
      2 => T2LineFields(
          lineData: entry.upLine,
          lineLabel: 'Up Line',
          trackType: entry.trackType,
          onChanged: _refresh,
        ),
      3 => FormAttachmentsField(
          recordId: entry.id,
          attachments: entry.attachments,
          onChanged: _refresh,
        ),
      4 => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Review', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            FormSummaryRow(
              label: 'Chainage',
              value: '${entry.chainageKmController.text}+${entry.chainageMController.text}',
            ),
            FormSummaryRow(label: 'Track type', value: entry.trackType.name),
            FormSummaryRow(
              label: 'Attachments',
              value: attachmentsSummary(entry.attachments),
            ),
            FormSummaryRow(
              label: 'DL Measuring point',
              value: entry.downLine.measuringPointController.text,
            ),
            FormSummaryRow(
              label: 'UL Measuring point',
              value: entry.upLine.measuringPointController.text,
            ),
            FormSummaryRow(
              label: 'DL Twist irregularity',
              value: entry.downLine.twist.irregularity.toStringAsFixed(2),
            ),
            FormSummaryRow(
              label: 'UL Gauge irregularity',
              value: entry.upLine.gauge.irregularity.toStringAsFixed(2),
            ),
          ],
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
