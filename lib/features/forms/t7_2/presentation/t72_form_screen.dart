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
import '../models/t72_entry.dart';

class T72FormScreen extends ConsumerStatefulWidget {
  const T72FormScreen({super.key, this.inspectionId});

  final String? inspectionId;

  @override
  ConsumerState<T72FormScreen> createState() => _T72FormScreenState();
}

class _T72FormScreenState extends ConsumerState<T72FormScreen> {
  static const _stepCount = 8;

  T72Entry? _entry;
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
        _entry = T72Entry.fromMap(existing.payload);
        return;
      }
    }
    _entry = T72Entry();
  }

  T72Entry get e {
    _ensureLoaded();
    return _entry!;
  }

  void _refresh() => setState(() {});

  Future<void> _persist({required bool submitForReview}) async {
    await saveFormInspection(
      ref: ref,
      context: context,
      formId: 't7-2',
      formCode: 'Form T-7-2',
      title: 'CAM Injected Thickness',
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

  Widget _camField(TextEditingController controller, int point) {
    return NumericTextField(
      label: 'CAM thickness — Point $point (mm)',
      controller: controller,
      suffixText: 'mm',
      onChanged: (_) => _refresh(),
    );
  }

  @override
  Widget build(BuildContext context) {
    _ensureLoaded();
    final isEdit = widget.inspectionId != null;

    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleBlock(
          title: isEdit ? 'Edit Record' : 'Add Record',
          subtitle: 'Form T-7-2 — CAM Injected Thickness',
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
                  'Thickness around RC anchor — Resin: 20 – 60 mm',
                  'Thickness around RC anchor — CAM: 30 – 100 mm',
                  'Thickness of CAM: 40 – 100 mm',
                  'Gap: within 1 mm',
                ],
                note: '*( ) indicates Construction Chainage. Resin > 60 mm shown in ( ).',
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
            UpDownSelector(
              value: e.direction,
              onChanged: (v) => setState(() => e.direction = v),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Serial Number of RC anchor',
              controller: e.rcAnchorSerialController,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: e.chainageKmController,
                    decoration: const InputDecoration(labelText: 'Chainage (km)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: e.chainageMController,
                    decoration: const InputDecoration(labelText: 'Chainage (m)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(label: 'Track slab — Number', controller: e.slabNumberController),
            const SizedBox(height: 12),
            AppTextField(label: 'Track slab — Type', controller: e.slabTypeController),
          ],
        ),
      2 => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumericTextField(
              label: 'Resin injection thickness — Origin (mm)',
              controller: e.resinOriginController,
              suffixText: 'mm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'Resin injection thickness — End (mm)',
              controller: e.resinEndController,
              suffixText: 'mm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            CalculatedValueField(
              label: 'Resin Origin display',
              value: e.resinOriginDisplay,
              suffixText: 'mm',
            ),
            const SizedBox(height: 12),
            CalculatedValueField(
              label: 'Resin End display',
              value: e.resinEndDisplay,
              suffixText: 'mm',
            ),
          ],
        ),
      3 => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _camField(e.cam1Controller, 1),
            const SizedBox(height: 12),
            _camField(e.cam2Controller, 2),
            const SizedBox(height: 12),
            _camField(e.cam3Controller, 3),
            const SizedBox(height: 12),
            _camField(e.cam4Controller, 4),
          ],
        ),
      4 => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _camField(e.cam5Controller, 5),
            const SizedBox(height: 12),
            _camField(e.cam6Controller, 6),
            const SizedBox(height: 12),
            _camField(e.cam7Controller, 7),
            const SizedBox(height: 12),
            _camField(e.cam8Controller, 8),
            const SizedBox(height: 12),
            CalculatedValueField(
              label: 'CAM thickness — Average (mm)',
              value: e.camAverage.toStringAsFixed(0),
              suffixText: 'mm',
            ),
          ],
        ),
      5 => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumericTextField(
              label: 'Gap — Origin (mm)',
              controller: e.gapOriginController,
              suffixText: 'mm',
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'Gap — End (mm)',
              controller: e.gapEndController,
              suffixText: 'mm',
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Reference pin condition — Origin',
              controller: e.pinOriginController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Reference pin condition — End',
              controller: e.pinEndController,
            ),
          ],
        ),
      6 => Column(
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
            FormSummaryRow(label: 'Direction', value: e.direction.label),
            FormSummaryRow(label: 'RC anchor', value: e.rcAnchorSerialController.text),
            FormSummaryRow(
              label: 'Chainage',
              value: '${e.chainageKmController.text}+${e.chainageMController.text}',
            ),
            FormSummaryRow(label: 'Slab', value: '${e.slabNumberController.text} / ${e.slabTypeController.text}'),
            FormSummaryRow(label: 'Resin Origin', value: '${e.resinOriginDisplay} mm'),
            FormSummaryRow(label: 'Resin End', value: '${e.resinEndDisplay} mm'),
            FormSummaryRow(label: 'CAM Average', value: '${e.camAverage.toStringAsFixed(0)} mm'),
            FormSummaryRow(label: 'Gap Origin', value: '${e.gapOriginController.text} mm'),
            FormSummaryRow(label: 'Gap End', value: '${e.gapEndController.text} mm'),
            FormSummaryRow(label: 'Pin Origin', value: e.pinOriginController.text),
            FormSummaryRow(label: 'Pin End', value: e.pinEndController.text),
            FormSummaryRow(
              label: 'Location',
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
