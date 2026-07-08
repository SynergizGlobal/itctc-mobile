import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/calculated_value_field.dart';
import '../../providers/form_table_providers.dart';
import '../../shared/models/form_site_capture.dart';
import '../../shared/utils/form_site_capture_validation.dart';
import '../../shared/widgets/form_attachments_field.dart';
import '../../shared/widgets/form_entry_stepper_layout.dart';
import '../../shared/widgets/form_site_capture_step.dart';
import '../../shared/widgets/solid_bed_fields.dart';
import '../models/t8_entry.dart';

class T8FormScreen extends ConsumerStatefulWidget {
  const T8FormScreen({super.key, this.editIndex});

  final int? editIndex;

  @override
  ConsumerState<T8FormScreen> createState() => _T8FormScreenState();
}

class _T8FormScreenState extends ConsumerState<T8FormScreen> {
  static const _stepCount = 5;

  T8Entry? _entry;
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
      final rows = ref.read(t8TableProvider);
      if (widget.editIndex! < rows.length) {
        _entry = T8Entry.fromMap(rows[widget.editIndex!]);
        return;
      }
    }
    _entry = T8Entry();
  }

  T8Entry get e {
    _ensureLoaded();
    return _entry!;
  }

  void _refresh() => setState(() {});

  void _saveToTable() {
    final record = e.toJson();
    if (widget.editIndex != null) {
      ref.read(t8TableProvider.notifier).updateRecord(widget.editIndex!, record);
    } else {
      ref.read(t8TableProvider.notifier).addRecord(record);
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
              'Form T-8 — Sleeper Spacing & Squareness',
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
        header: _step > 0
            ? const FormToleranceBanner(
                items: [
                  'Squareness: ± 5 mm',
                  'Spacing irregularity: ± 5 mm',
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
              label: 'Squareness (mm)',
              controller: e.squarenessController,
              suffixText: 'mm',
            ),
            const SizedBox(height: 16),
            NumericTextField(
              label: 'Spacing — Design value (mm)',
              controller: e.spacingDesignController,
              suffixText: 'mm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            NumericTextField(
              label: 'Spacing — Measured value (mm)',
              controller: e.spacingMeasuredController,
              suffixText: 'mm',
              onChanged: (_) => _refresh(),
            ),
            const SizedBox(height: 12),
            CalculatedValueField(
              label: 'Spacing — Irregularity (mm)',
              value: e.spacingIrregularity.toStringAsFixed(0),
              suffixText: 'mm',
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
            FormSummaryRow(label: 'Squareness', value: '${e.squarenessController.text} mm'),
            FormSummaryRow(label: 'Spacing design', value: '${e.spacingDesignController.text} mm'),
            FormSummaryRow(
              label: 'Spacing measured',
              value: '${e.spacingMeasuredController.text} mm',
            ),
            FormSummaryRow(
              label: 'Spacing irregularity',
              value: '${e.spacingIrregularity.toStringAsFixed(0)} mm',
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
