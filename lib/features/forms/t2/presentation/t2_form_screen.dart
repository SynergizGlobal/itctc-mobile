import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_bar_title.dart';

import '../../shared/widgets/form_inspection_table_scaffold.dart';
import '../../../inspections/providers/inspection_store_provider.dart';

import '../../../../core/utils/form_calculations.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../shared/form_shared_steps.dart';
import '../../shared/utils/form_site_capture_validation.dart';
import '../../shared/widgets/form_entry_stepper_layout.dart';
import '../../shared/widgets/form_attachments_field.dart';
import '../../shared/widgets/form_site_capture_step.dart';
import '../../shared/models/form_site_capture.dart';
import '../models/t2_entry.dart';
import '../widgets/t2_line_fields.dart';

class T2FormScreen extends ConsumerStatefulWidget {
  const T2FormScreen({super.key, this.inspectionId});

  final String? inspectionId;

  @override
  ConsumerState<T2FormScreen> createState() => _T2FormScreenState();
}

class _T2FormScreenState extends ConsumerState<T2FormScreen> {
  static const _stepCount = 6;

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

    if (widget.inspectionId != null) {
      final existing = ref.read(inspectionByIdProvider(widget.inspectionId!));
      if (existing != null) {
        _entry = T2Entry.fromMap(existing.payload);
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

  Future<void> _persist({required bool submitForReview}) async {
    await saveFormInspection(
      ref: ref,
      context: context,
      formId: 't2',
      formCode: 'Form T-2',
      title: 'Track Irregularity',
      payload: entry.toJson(),
      inspectionId: widget.inspectionId,
      submitForReview: submitForReview,
    );
  }

  Future<void> _goNext() async {
    if (_step == _stepCount - 1) {
      await _persist(submitForReview: true);
      return;
    }
    if (!FormSiteCaptureValidation.guardStep(entry.siteCapture, _step + 1)) {
      return;
    }
    setState(() => _step++);
  }

  void _goToStep(int step) {
    if (!FormSiteCaptureValidation.guardStep(entry.siteCapture, step)) {
      return;
    }
    setState(() => _step = step);
  }

  @override
  Widget build(BuildContext context) {
    _ensureLoaded();
    final isEdit = widget.inspectionId != null;

    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleBlock(
          title: isEdit ? 'Edit Record' : 'Add Record',
          subtitle: 'Form T-2 — Track Irregularity',
        ),
      ),
      body: FormEntryStepperLayout(
        submitLabel: 'Submit for Review',
        onSaveDraft: () => _persist(submitForReview: false),
        stepCount: _stepCount,
        currentStep: _step,
        isLoading: false,
        header: FormSharedSteps.showsToleranceReference(
              step: _step,
              stepCount: _stepCount,
              firstMeasurementStep: 2,
            )
            ? ToleranceReferenceCard(trackType: entry.trackType)
            : null,
        onStepTap: _goToStep,
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
      0 => FormSiteCaptureStep(
          recordId: entry.id,
          siteCapture: entry.siteCapture,
          onChanged: _refresh,
        ),
      1 => Column(
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
      2 => T2LineFields(
          lineData: entry.downLine,
          lineLabel: 'Down Line',
          trackType: entry.trackType,
          onChanged: _refresh,
        ),
      3 => T2LineFields(
          lineData: entry.upLine,
          lineLabel: 'Up Line',
          trackType: entry.trackType,
          onChanged: _refresh,
        ),
      4 => FormAttachmentsField(
          recordId: entry.id,
          attachments: entry.attachments,
          onChanged: _refresh,
        ),
      5 => Column(
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
              label: 'Location',
              value: siteCaptureLocationSummary(entry.siteCapture),
            ),
            FormSummaryRow(
              label: 'Selfie',
              value: siteCaptureSelfieSummary(entry.siteCapture),
            ),
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
