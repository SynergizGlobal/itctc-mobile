import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_bar_title.dart';

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
import '../models/t22_entry.dart';

class T22FormScreen extends ConsumerStatefulWidget {
  const T22FormScreen({super.key, this.inspectionId});

  final String? inspectionId;

  @override
  ConsumerState<T22FormScreen> createState() => _T22FormScreenState();
}

class _T22FormScreenState extends ConsumerState<T22FormScreen> {
  static const _stepCount = 5;

  T22Entry? _entry;
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
        _entry = T22Entry.fromMap(existing.payload);
        return;
      }
    }
    _entry = T22Entry();
  }

  T22Entry get e {
    _ensureLoaded();
    return _entry!;
  }

  void _refresh() => setState(() {});

  Future<void> _persist({required bool submitForReview}) async {
    await saveFormInspection(
      ref: ref,
      context: context,
      formId: 't22',
      formCode: 'Form T-22',
      title: 'Buffer Stop',
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

  @override
  Widget build(BuildContext context) {
    _ensureLoaded();
    final isEdit = widget.inspectionId != null;

    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleBlock(
          title: isEdit ? 'Edit Record' : 'Add Record',
          subtitle: 'Form T-22 — Buffer Stop',
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
                  'Standard values (mm): (1) 250, (2) 5,000, (3) 1,000, (4) 3,400, (5) 3,900',
                ],
                note: '( ) is the standard value on the paper form.',
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
            AppTextField(label: 'Line', controller: e.lineController),
          ],
        ),
      2 => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < e.pointControllers.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              NumericTextField(
                label: 'Measured value — ${T22Entry.pointLabels[i]}',
                controller: e.pointControllers[i],
                suffixText: 'mm',
                onChanged: (_) => _refresh(),
              ),
              const SizedBox(height: 8),
              CalculatedValueField(
                label: 'Irregularity — ${T22Entry.pointLabels[i]}',
                value: e.irregularities[i]?.toStringAsFixed(0) ?? '—',
                suffixText: 'mm',
              ),
            ],
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
            FormSummaryRow(label: 'Line', value: e.lineController.text),
            for (var i = 0; i < T22Entry.pointLabels.length; i++) ...[
              FormSummaryRow(
                label: T22Entry.pointLabels[i],
                value: e.measuredValues[i]?.toStringAsFixed(0) ?? '—',
              ),
              FormSummaryRow(
                label: 'Irregularity ${T22Entry.pointLabels[i]}',
                value: e.irregularities[i]?.toStringAsFixed(0) ?? '—',
              ),
            ],
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
