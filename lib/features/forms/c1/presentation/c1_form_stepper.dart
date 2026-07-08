import 'package:flutter/material.dart';

import '../../shared/utils/form_site_capture_validation.dart';
import '../../shared/widgets/form_entry_stepper_layout.dart';
import '../../shared/widgets/form_attachments_field.dart';
import '../../shared/widgets/form_site_capture_step.dart';
import '../../shared/models/form_site_capture.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/calculated_value_field.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../models/c1_entry.dart';

class C1FormStepper extends StatefulWidget {
  const C1FormStepper({
    super.key,
    required this.entry,
    required this.isLoading,
    required this.onSubmit,
  });

  final C1Entry entry;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  State<C1FormStepper> createState() => _C1FormStepperState();
}

class _C1FormStepperState extends State<C1FormStepper> {
  static const _stepCount = 6;
  int _step = 0;

  C1Entry get _entry => widget.entry;

  void _refresh() => setState(() {});

  void _goNext() {
    if (_step == _stepCount - 1) {
      widget.onSubmit();
      return;
    }
    if (!FormSiteCaptureValidation.guardStep(_entry.siteCapture, _step + 1)) {
      return;
    }
    setState(() => _step++);
  }

  void _goToStep(int step) {
    if (!FormSiteCaptureValidation.guardStep(_entry.siteCapture, step)) {
      return;
    }
    setState(() => _step = step);
  }

  @override
  Widget build(BuildContext context) {
    return FormEntryStepperLayout(
      stepCount: _stepCount,
      currentStep: _step,
      isLoading: widget.isLoading,
      onStepTap: _goToStep,
      onPrevious: () {
        if (_step > 0) setState(() => _step--);
      },
      onNext: _goNext,
      child: _buildStep(),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => FormSiteCaptureStep(
          recordId: _entry.id,
          siteCapture: _entry.siteCapture,
          onChanged: _refresh,
        ),
      1 => Column(
          children: [
            ChainageFields(
              kmController: _entry.chainageKmController,
              mController: _entry.chainageMController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Type of Structure',
              controller: _entry.structureTypeController,
              hint: 'Earthwork / Viaduct / Bridge',
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Straight / Curve (R = ***)',
              controller: _entry.straightCurveController,
              hint: 'e.g. Straight, R=5000',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Type of track',
              controller: _entry.trackTypeController,
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'Applied cant value (mm)',
              controller: _entry.cantController,
              suffixText: 'mm',
              onChanged: (_) => _refresh(),
            ),
          ],
        ),
      2 => Column(
          children: [
            NumericTextField(
              label: 'a — Measured value',
              controller: _entry.aController,
              suffixText: 'mm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            CalculatedValueField(
              label: 'X — Calculated value',
              value: _entry.xDown.toStringAsFixed(2),
              suffixText: 'mm',
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'A = a + X — Standard value',
              controller: _entry.standardAController,
              suffixText: 'mm',
            ),
            const SizedBox(height: 12),
            CalculatedValueField(
              label: 'A = a + X — Measured value',
              value: _entry.calculatedA.toStringAsFixed(2),
              suffixText: 'mm',
            ),
          ],
        ),
      3 => Column(
          children: [
            NumericTextField(
              label: 'b — Measured value',
              controller: _entry.bController,
              suffixText: 'mm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: "b' — Measured value",
              controller: _entry.bPrimeController,
              suffixText: 'mm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: "B = b (or b') — Standard value",
              controller: _entry.standardBController,
              suffixText: 'mm',
            ),
            const SizedBox(height: 12),
            CalculatedValueField(
              label: "B = b (or b') — Measured value",
              value: _entry.calculatedB.toStringAsFixed(2),
              suffixText: 'mm',
            ),
          ],
        ),
      4 => Column(
          children: [
            NumericTextField(
              label: 'c — Measured value',
              controller: _entry.cController,
              suffixText: 'mm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            CalculatedValueField(
              label: 'X — Calculated value',
              value: _entry.xUp.toStringAsFixed(2),
              suffixText: 'mm',
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'C = c + X — Standard value',
              controller: _entry.standardCController,
              suffixText: 'mm',
            ),
            const SizedBox(height: 12),
            CalculatedValueField(
              label: 'C = c + X — Measured value',
              value: _entry.calculatedC.toStringAsFixed(2),
              suffixText: 'mm',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NumericTextField(
                    label: 'D — Standard value',
                    controller: _entry.standardDController,
                    suffixText: 'mm',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NumericTextField(
                    label: 'D — Measured value',
                    controller: _entry.measuredDController,
                    suffixText: 'mm',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FormAttachmentsField(
              recordId: _entry.id,
              attachments: _entry.attachments,
              onChanged: _refresh,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Remarks (position of maintenance walkway, etc.)',
              controller: _entry.remarksController,
              maxLines: 2,
            ),
          ],
        ),
      _ => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Review', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            FormSummaryRow(
              label: 'Chainage',
              value: '${_entry.chainageKmController.text}+${_entry.chainageMController.text}',
            ),
            FormSummaryRow(label: 'Type of Structure', value: _entry.structureTypeController.text),
            FormSummaryRow(label: 'Straight / Curve', value: _entry.straightCurveController.text),
            FormSummaryRow(label: 'Type of track', value: _entry.trackTypeController.text),
            FormSummaryRow(label: 'Applied cant value', value: '${_entry.cantController.text} mm'),
            FormSummaryRow(
              label: 'Location',
              value: siteCaptureLocationSummary(_entry.siteCapture),
            ),
            FormSummaryRow(
              label: 'Selfie',
              value: siteCaptureSelfieSummary(_entry.siteCapture),
            ),
            FormSummaryRow(label: 'a', value: '${_entry.aController.text} mm'),
            FormSummaryRow(label: 'X (DL)', value: '${_entry.xDown.toStringAsFixed(2)} mm'),
            FormSummaryRow(label: 'A measured', value: '${_entry.calculatedA.toStringAsFixed(2)} mm'),
            FormSummaryRow(label: 'b / b\'', value: '${_entry.bController.text} / ${_entry.bPrimeController.text} mm'),
            FormSummaryRow(label: 'B measured', value: '${_entry.calculatedB.toStringAsFixed(2)} mm'),
            FormSummaryRow(label: 'c', value: '${_entry.cController.text} mm'),
            FormSummaryRow(label: 'C measured', value: '${_entry.calculatedC.toStringAsFixed(2)} mm'),
            FormSummaryRow(label: 'D measured', value: '${_entry.measuredDController.text} mm'),
            FormSummaryRow(
              label: 'Attachments',
              value: attachmentsSummary(_entry.attachments),
            ),
            FormSummaryRow(label: 'Remarks', value: _entry.remarksController.text),
          ],
        ),
    };
  }
}
