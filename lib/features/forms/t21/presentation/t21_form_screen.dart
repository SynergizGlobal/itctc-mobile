import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/form_inspection_table_scaffold.dart';
import '../../../inspections/providers/inspection_store_provider.dart';

import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/calculated_value_field.dart';
import '../../shared/form_shared_steps.dart';
import '../../shared/models/form_site_capture.dart';
import '../../shared/utils/form_site_capture_validation.dart';
import '../../shared/widgets/form_attachments_field.dart';
import '../../shared/widgets/form_entry_stepper_layout.dart';
import '../../shared/widgets/form_site_capture_step.dart';
import '../../shared/widgets/solid_bed_fields.dart';
import '../models/t21_entry.dart';

class T21FormScreen extends ConsumerStatefulWidget {
  const T21FormScreen({super.key, this.inspectionId});

  final String? inspectionId;

  @override
  ConsumerState<T21FormScreen> createState() => _T21FormScreenState();
}

class _T21FormScreenState extends ConsumerState<T21FormScreen> {
  static const _stepCount = 5;

  T21Entry? _entry;
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
        _entry = T21Entry.fromMap(existing.payload);
        return;
      }
    }
    _entry = T21Entry();
  }

  T21Entry get e {
    _ensureLoaded();
    return _entry!;
  }

  void _refresh() => setState(() {});

  Future<void> _persist({required bool submitForReview}) async {
    await saveFormInspection(
      ref: ref,
      context: context,
      formId: 't21',
      formCode: 'Form T-21',
      title: 'Track Effective Length',
      payload: e.toJson(),
      inspectionId: widget.inspectionId,
      submitForReview: submitForReview,
    );
  }

  Future<void> _goNext() async {
    if (_step == _stepCount - 1) {
      await _persist(submitForReview: true);
      return;
    }
    if (!FormSiteCaptureValidation.guardStep(e.siteCapture, _step + 1)) {
      return;
    }
    setState(() => _step++);
  }

  void _goToStep(int step) {
    if (!FormSiteCaptureValidation.guardStep(e.siteCapture, step)) {
      return;
    }
    setState(() => _step = step);
  }

  String _foulingStatus() {
    final ok = e.foulingDistanceOk;
    final measured = e.foulingMeasured;
    if (measured == null) return '—';
    return ok == true
        ? '${measured.toStringAsFixed(1)} m'
        : '${measured.toStringAsFixed(1)} m (below 5.0 m minimum)';
  }

  @override
  Widget build(BuildContext context) {
    _ensureLoaded();
    final theme = Theme.of(context);
    final isEdit = widget.inspectionId != null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEdit ? 'Edit Record' : 'Add Record', style: theme.textTheme.titleMedium),
            Text(
              'Form T-21 — Track Effective Length',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: FormEntryStepperLayout(
        submitLabel: 'Submit for Review',
        onSaveDraft: () => _persist(submitForReview: false),
        stepCount: _stepCount,
        currentStep: _step,
        isLoading: false,
        header: FormSharedSteps.showsToleranceReference(step: _step, stepCount: _stepCount)
            ? const FormToleranceBanner(
                items: [
                  'Distance from Fouling Mark to Insulated Joint: 5.0 m or more',
                  'Track effective length design reference: 332.0 m',
                ],
              )
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
          recordId: e.id,
          siteCapture: e.siteCapture,
          onChanged: _refresh,
        ),
      1 => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Location (Station / Depot)',
              controller: e.locationController,
            ),
            const SizedBox(height: 16),
            AppTextField(label: 'Line', controller: e.lineController),
            const SizedBox(height: 16),
            ChainageKmMFields(
              kmController: e.chainageKmController,
              mController: e.chainageMController,
              onChanged: _refresh,
            ),
          ],
        ),
      2 => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Distance from Fouling Mark to Insulated Joint',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'Design value (A) — m',
              controller: e.foulingDesignController,
              suffixText: 'm',
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'Measured value (D) — m',
              controller: e.foulingMeasuredController,
              suffixText: 'm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 24),
            Text(
              'Track effective length (Insulated Joint + 1.0 m - Stop Limit Sign)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'Design value (B) — m',
              controller: e.trackLengthDesignController,
              suffixText: 'm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'Measured value (E) — m',
              controller: e.trackLengthMeasuredController,
              suffixText: 'm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            CalculatedValueField(
              label: 'Irregularity (E) - (B) — m',
              value: e.trackLengthIrregularity?.toStringAsFixed(1) ?? '—',
              suffixText: 'm',
            ),
          ],
        ),
      3 => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormAttachmentsField(
              recordId: e.id,
              attachments: e.attachments,
              onChanged: _refresh,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Remarks',
              controller: e.remarksController,
              maxLines: 3,
            ),
          ],
        ),
      _ => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Review', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            FormSummaryRow(label: 'Location', value: e.locationController.text),
            FormSummaryRow(label: 'Line', value: e.lineController.text),
            FormSummaryRow(
              label: 'Chainage',
              value: '${e.chainageKmController.text}+${e.chainageMController.text}',
            ),
            FormSummaryRow(label: 'Fouling distance (D)', value: _foulingStatus()),
            FormSummaryRow(
              label: 'Track length design (B)',
              value: e.trackLengthDesign?.toString() ?? '—',
            ),
            FormSummaryRow(
              label: 'Track length measured (E)',
              value: e.trackLengthMeasured?.toString() ?? '—',
            ),
            FormSummaryRow(
              label: 'Track length irregularity',
              value: e.trackLengthIrregularity?.toStringAsFixed(1) ?? '—',
            ),
            FormSummaryRow(
              label: 'Location capture',
              value: siteCaptureLocationSummary(e.siteCapture),
            ),
            FormSummaryRow(
              label: 'Selfie',
              value: siteCaptureSelfieSummary(e.siteCapture),
            ),
            FormSummaryRow(
              label: 'Attachments',
              value: attachmentsSummary(e.attachments),
            ),
            FormSummaryRow(label: 'Remarks', value: e.remarksController.text),
          ],
        ),
    };
  }
}
