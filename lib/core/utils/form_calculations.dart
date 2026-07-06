import 'dart:math';

import '../constants/app_constants.dart';

/// Shared calculation utilities for NHSRCL forms.
class FormCalculations {
  FormCalculations._();

  /// Round to nearest integer as per form instructions.
  static double round(double value) => value.roundToDouble();

  /// X = horizontal distance between rail head centre and track centre.
  /// Straight: constant 750mm. Curve: sqrt(750^2 - (cant/2)^2).
  static double calculateX({
    required bool isStraight,
    required double cantValue,
  }) {
    if (isStraight) return AppConstants.straightSectionX;
    final halfCant = cantValue / 2;
    final x = sqrt(
      pow(AppConstants.railHeadRadius, 2) - pow(halfCant, 2),
    ).toDouble();
    return round(x);
  }

  /// A = a + X (Down line width from track centre)
  static double calculateA({required double a, required double x}) {
    return round(a + x);
  }

  /// C = c + X (Up line width from track centre)
  static double calculateC({required double c, required double x}) {
    return round(c + x);
  }

  /// B = b or b' (track centre spacing)
  static double calculateB({required double b, double? bPrime}) {
    return round(bPrime ?? b);
  }

  /// A = (h1 + h2) / 2 + h5 (Down line noise barrier height)
  static double calculateNoiseBarrierA({
    required double h1,
    required double h2,
    required double h5,
  }) {
    return round((h1 + h2) / 2 + h5);
  }

  /// B = (h3 + h4) / 2 + h6 (Up line noise barrier height)
  static double calculateNoiseBarrierB({
    required double h3,
    required double h4,
    required double h6,
  }) {
    return round((h3 + h4) / 2 + h6);
  }

  /// Irregularity = Measured - Design
  static double calculateIrregularity({
    required double design,
    required double measured,
  }) {
    return round(measured - design);
  }

  static bool isWithinTolerance({
    required double irregularity,
    required double tolerance,
  }) {
    return irregularity.abs() <= tolerance;
  }
}

enum TrackType { slab, ballasted }

class ToleranceConfig {
  const ToleranceConfig({
    required this.gauge,
    required this.crossLevel,
    required this.longitudinalAlignment,
    required this.lateralAlignment,
  });

  final double gauge;
  final double crossLevel;
  final double longitudinalAlignment;
  final double lateralAlignment;

  static ToleranceConfig forTrackType(TrackType type) {
    return switch (type) {
      TrackType.slab => const ToleranceConfig(
          gauge: 1,
          crossLevel: 1,
          longitudinalAlignment: 2,
          lateralAlignment: 2,
        ),
      TrackType.ballasted => const ToleranceConfig(
          gauge: 2,
          crossLevel: 2,
          longitudinalAlignment: 3,
          lateralAlignment: 3,
        ),
    };
  }

  double toleranceFor(String category) {
    return switch (category) {
      'gauge' => gauge,
      'crossLevel' => crossLevel,
      'longitudinalAlignment' => longitudinalAlignment,
      'lateralAlignment' => lateralAlignment,
      'twist' => crossLevel,
      _ => 0,
    };
  }
}

enum SectionType { straight, curve }

extension SectionTypeX on SectionType {
  bool get isStraight => this == SectionType.straight;
}
