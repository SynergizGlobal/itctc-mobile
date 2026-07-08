import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/form_calculations.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../providers/form_table_providers.dart';
import '../../shared/form_shared_steps.dart';
import '../../shared/models/form_site_capture.dart';
import '../../shared/utils/form_site_capture_validation.dart';
import '../../shared/widgets/form_attachments_field.dart';
import '../../shared/widgets/form_entry_stepper_layout.dart';
import '../../shared/widgets/form_site_capture_step.dart';
import '../../shared/widgets/solid_bed_fields.dart';
import '../models/t10_entry.dart';

class T10FormScreen extends ConsumerStatefulWidget {
  const T10FormScreen({super.key, this.editIndex});

  final int? editIndex;

  @override
  ConsumerState<T10FormScreen> createState() => _T10FormScreenState();
}

class _T10FormScreenState extends ConsumerState<T10FormScreen> {
  static const _stepCount = 5;

  T10Entry? _entry;
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
      final rows = ref.read(t10TableProvider);
      if (widget.editIndex! < rows.length) {
        _entry = T10Entry.fromMap(rows[widget.editIndex!]);
        return;
      }
    }
    _entry = T10Entry();
  }

  T10Entry get e {
    _ensureLoaded();
    return _entry!;
  }

  void _refresh() => setState(() {});

  void _saveToTable() {
    final record = e.toJson();
    if (widget.editIndex != null) {
      ref.read(t10TableProvider.notifier).updateRecord(widget.editIndex!, record);
    } else {
      ref.read(t10TableProvider.notifier).addRecord(record);
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

  String _torqueStatus(double? value) {
    if (value == null) return '—';
    final ok = FormCalculations.isBoltTorqueWithinTolerance(measured: value);
    return ok ? '${value.toStringAsFixed(0)} Nm' : '${value.toStringAsFixed(0)} Nm (out of range)';
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
              'Form T-10 — Fastening Bolt Torque',
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
        header: FormSharedSteps.showsToleranceReference(step: _step, stepCount: _stepCount)
            ? const FormToleranceBanner(
                items: [
                  'Standard value: 150 Nm',
                  'Tolerances: ± 10%',
                ],
                note: '*( ) indicates Construction Chainage.',
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
            SolidBedChainageFields(
              kmController: e.chainageKmController,
              mController: e.chainageMController,
              cmController: e.chainageCmController,
            ),
            const SizedBox(height: 16),
            AppTextField(label: 'Sleeper No.', controller: e.sleeperNoController),
          ],
        ),
      2 => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumericTextField(
              label: 'Measured value — Left (Nm)',
              controller: e.torqueLeftController,
              suffixText: 'Nm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'Measured value — Right (Nm)',
              controller: e.torqueRightController,
              suffixText: 'Nm',
              onChanged: (_) => _refresh(),
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
            FormSummaryRow(label: 'Direction', value: e.direction.label),
            FormSummaryRow(
              label: 'Chainage',
              value:
                  '${e.chainageKmController.text}+${e.chainageMController.text}+${e.chainageCmController.text}',
            ),
            FormSummaryRow(label: 'Sleeper No.', value: e.sleeperNoController.text),
            FormSummaryRow(
              label: 'Torque Left',
              value: _torqueStatus(double.tryParse(e.torqueLeftController.text)),
            ),
            FormSummaryRow(
              label: 'Torque Right',
              value: _torqueStatus(double.tryParse(e.torqueRightController.text)),
            ),
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
