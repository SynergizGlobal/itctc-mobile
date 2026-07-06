import 'package:flutter/material.dart';

import '../../../../core/utils/form_calculations.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/calculated_value_field.dart';
import '../../../../core/widgets/section_header.dart';
import '../models/t2_entry.dart';

class T2LineFields extends StatelessWidget {
  const T2LineFields({
    super.key,
    required this.lineData,
    required this.lineLabel,
    required this.trackType,
    this.onChanged,
  });

  final T2LineData lineData;
  final String lineLabel;
  final TrackType trackType;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final d = lineData;
    final config = ToleranceConfig.forTrackType(trackType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: lineLabel,
          icon: lineLabel.contains('Down')
              ? Icons.arrow_downward_rounded
              : Icons.arrow_upward_rounded,
        ),
        _MeasurementRow(
          label: 'Twist',
          measurement: d.twist,
          tolerance: config.gauge,
          onChanged: onChanged,
        ),
        _MeasurementRow(
          label: 'Lateral alignment',
          measurement: d.lateralAlignment,
          tolerance: config.lateralAlignment,
          onChanged: onChanged,
        ),
        _MeasurementRow(
          label: 'Longitudinal alignment',
          measurement: d.longitudinalAlignment,
          tolerance: config.longitudinalAlignment,
          onChanged: onChanged,
        ),
        _MeasurementRow(
          label: 'Cross Level',
          measurement: d.crossLevel,
          tolerance: config.crossLevel,
          onChanged: onChanged,
        ),
        _MeasurementRow(
          label: 'Gauge',
          measurement: d.gauge,
          tolerance: config.gauge,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: 'Measuring point',
          controller: d.measuringPointController,
        ),
      ],
    );
  }
}

class _MeasurementRow extends StatelessWidget {
  const _MeasurementRow({
    required this.label,
    required this.measurement,
    required this.tolerance,
    this.onChanged,
  });

  final String label;
  final T2Measurement measurement;
  final double tolerance;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final irregularity = measurement.irregularity;
    final withinTolerance = measurement.isWithinTolerance(tolerance);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: NumericTextField(
                  label: 'Design value',
                  controller: measurement.designController,
                  onChanged: (_) => onChanged?.call(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NumericTextField(
                  label: 'Measured value',
                  controller: measurement.measuredController,
                  onChanged: (_) => onChanged?.call(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CalculatedValueField(
            label: 'Irregularity',
            value: irregularity.toStringAsFixed(2),
            suffixText: withinTolerance ? 'Within tolerance' : 'Check tolerance',
          ),
        ],
      ),
    );
  }
}

class ToleranceReferenceCard extends StatelessWidget {
  const ToleranceReferenceCard({super.key, required this.trackType});

  final TrackType trackType;

  @override
  Widget build(BuildContext context) {
    final config = ToleranceConfig.forTrackType(trackType);
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tolerances — ${trackType.name.toUpperCase()} Track',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            _TolRow('Gauge', '±${config.gauge}'),
            _TolRow('Cross Level', '±${config.crossLevel}'),
            _TolRow('Longitudinal alignment', '±${config.longitudinalAlignment}/10m chord'),
            _TolRow('Lateral alignment', '±${config.lateralAlignment}/10m chord'),
          ],
        ),
      ),
    );
  }
}

class _TolRow extends StatelessWidget {
  const _TolRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.85),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
