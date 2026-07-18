import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/form_inspection_table_scaffold.dart';
import '../../../inspections/providers/inspection_store_provider.dart';

import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/calculated_value_field.dart';
import '../../shared/models/form_site_capture.dart';
import '../../shared/utils/form_site_capture_validation.dart';
import '../../shared/widgets/form_attachments_field.dart';
import '../../shared/widgets/form_entry_stepper_layout.dart';
import '../../shared/widgets/form_site_capture_step.dart';
import '../models/t13_entry.dart';

class T13FormScreen extends ConsumerStatefulWidget {
  const T13FormScreen({super.key, this.inspectionId});

  final String? inspectionId;

  @override
  ConsumerState<T13FormScreen> createState() => _T13FormScreenState();
}

class _T13FormScreenState extends ConsumerState<T13FormScreen> {
  static const _stepCount = 5;

  T13Entry? _entry;
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
        _entry = T13Entry.fromMap(existing.payload);
        return;
      }
    }
    _entry = T13Entry();
  }

  T13Entry get e {
    _ensureLoaded();
    return _entry!;
  }

  void _refresh() => setState(() {});

  Future<void> _persist({required bool submitForReview}) async {
    await saveFormInspection(
      ref: ref,
      context: context,
      formId: 't13',
      formCode: 'Form T-13',
      title: 'Fouling Mark',
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
    final theme = Theme.of(context);
    final isEdit = widget.inspectionId != null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEdit ? 'Edit Record' : 'Add Record', style: theme.textTheme.titleMedium),
            Text(
              'Form T-13 — Fouling Mark',
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
            const SizedBox(height: 16),
            AppTextField(
              label: 'Chainage and Location of the Fouling Mark',
              controller: e.locationController,
              maxLines: 2,
            ),
          ],
        ),
      2 => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumericTextField(
              label: 'Design value (m)',
              controller: e.designValueController,
              suffixText: 'm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'Measured value (m)',
              controller: e.measuredValueController,
              suffixText: 'm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            CalculatedValueField(
              label: 'Difference (m)',
              value: e.difference?.toStringAsFixed(3) ?? '—',
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
            FormSummaryRow(label: 'Line', value: e.lineController.text),
            FormSummaryRow(label: 'Location', value: e.locationController.text),
            FormSummaryRow(
              label: 'Design value',
              value: e.designValue?.toString() ?? '—',
            ),
            FormSummaryRow(
              label: 'Measured value',
              value: e.measuredValue?.toString() ?? '—',
            ),
            FormSummaryRow(
              label: 'Difference',
              value: e.difference?.toStringAsFixed(3) ?? '—',
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
