import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/calculated_value_field.dart';
import '../../../../core/widgets/form_widgets.dart';
import '../../providers/form_table_providers.dart';
import '../../shared/utils/form_site_capture_validation.dart';
import '../../shared/widgets/form_entry_stepper_layout.dart';
import '../../shared/widgets/form_attachments_field.dart';
import '../../shared/widgets/form_site_capture_step.dart';
import '../../shared/models/form_site_capture.dart';
import '../models/c7_entry.dart';

class C7FormScreen extends ConsumerStatefulWidget {
  const C7FormScreen({super.key, this.editIndex});

  final int? editIndex;

  @override
  ConsumerState<C7FormScreen> createState() => _C7FormScreenState();
}

class _C7FormScreenState extends ConsumerState<C7FormScreen> {
  static const _stepCount = 5;

  C7Entry? _entry;
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
      final rows = ref.read(c7TableProvider);
      if (widget.editIndex! < rows.length) {
        _entry = C7Entry.fromMap(rows[widget.editIndex!]);
        return;
      }
    }
    _entry = C7Entry();
  }

  C7Entry get e {
    _ensureLoaded();
    return _entry!;
  }

  void _refresh() => setState(() {});

  void _saveToTable() {
    final record = e.toJson();
    if (widget.editIndex != null) {
      ref.read(c7TableProvider.notifier).updateRecord(widget.editIndex!, record);
    } else {
      ref.read(c7TableProvider.notifier).addRecord(record);
    }
    context.pop();
  }

  void _goNext() {
    if (_step == _stepCount - 1) {
      _saveToTable();
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
    final isEdit = widget.editIndex != null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEdit ? 'Edit Record' : 'Add Record', style: theme.textTheme.titleMedium),
            Text(
              'Form C-7 — Noise Barrier Height',
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
          children: [
            ChainageFields(
              kmController: e.chainageKmController,
              mController: e.chainageMController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Straight / Curve (R = ***)',
              controller: e.straightCurveController,
              hint: 'e.g. Straight, R=5000',
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'Applied cant value (mm)',
              controller: e.cantController,
              suffixText: 'mm',
            ),
            const SizedBox(height: 12),
            AppTextField(label: 'Type of track', controller: e.trackTypeController),
          ],
        ),
      2 => Column(
          children: [
            NumericTextField(
              label: 'h1 — Measured value',
              controller: e.h1Controller,
              suffixText: 'mm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'h2 — Measured value',
              controller: e.h2Controller,
              suffixText: 'mm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'h3 — Measured value',
              controller: e.h3Controller,
              suffixText: 'mm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'h4 — Measured value',
              controller: e.h4Controller,
              suffixText: 'mm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'h5 — Measured value',
              controller: e.h5Controller,
              suffixText: 'mm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'h6 — Measured value',
              controller: e.h6Controller,
              suffixText: 'mm',
              onChanged: (_) => _refresh(),
            ),
          ],
        ),
      3 => Column(
          children: [
            NumericTextField(
              label: 'A = (h1 + h2) / 2 + h5 — Standard value',
              controller: e.standardAController,
              suffixText: 'mm',
            ),
            const SizedBox(height: 12),
            CalculatedValueField(
              label: 'A = (h1 + h2) / 2 + h5 — Measured value',
              value: e.calculatedA.toStringAsFixed(2),
              suffixText: 'mm',
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'B = (h3 + h4) / 2 + h6 — Standard value',
              controller: e.standardBController,
              suffixText: 'mm',
            ),
            const SizedBox(height: 12),
            CalculatedValueField(
              label: 'B = (h3 + h4) / 2 + h6 — Measured value',
              value: e.calculatedB.toStringAsFixed(2),
              suffixText: 'mm',
            ),
            const SizedBox(height: 12),
            FormAttachmentsField(
              recordId: e.id,
              attachments: e.attachments,
              onChanged: _refresh,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Remarks',
              controller: e.remarksController,
              hint: 'Record structure type of main line',
              maxLines: 2,
            ),
          ],
        ),
      _ => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Review', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            FormSummaryRow(label: 'Chainage', value: '${e.chainageKmController.text}+${e.chainageMController.text}'),
            FormSummaryRow(label: 'Straight / Curve', value: e.straightCurveController.text),
            FormSummaryRow(label: 'Applied cant value', value: '${e.cantController.text} mm'),
            FormSummaryRow(label: 'Type of track', value: e.trackTypeController.text),
            FormSummaryRow(
              label: 'Location',
              value: siteCaptureLocationSummary(e.siteCapture),
            ),
            FormSummaryRow(
              label: 'Selfie',
              value: siteCaptureSelfieSummary(e.siteCapture),
            ),
            FormSummaryRow(label: 'h1', value: '${e.h1Controller.text} mm'),
            FormSummaryRow(label: 'h2', value: '${e.h2Controller.text} mm'),
            FormSummaryRow(label: 'h3', value: '${e.h3Controller.text} mm'),
            FormSummaryRow(label: 'h4', value: '${e.h4Controller.text} mm'),
            FormSummaryRow(label: 'h5', value: '${e.h5Controller.text} mm'),
            FormSummaryRow(label: 'h6', value: '${e.h6Controller.text} mm'),
            FormSummaryRow(label: 'A measured', value: '${e.calculatedA.toStringAsFixed(2)} mm'),
            FormSummaryRow(label: 'B measured', value: '${e.calculatedB.toStringAsFixed(2)} mm'),
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
