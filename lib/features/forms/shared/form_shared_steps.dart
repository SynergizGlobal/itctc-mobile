abstract final class FormSharedSteps {
  static const int siteCapture = 0;
  static const int formFieldsStart = 1;

  /// Tolerance reference is shown only on measurement steps — not site capture,
  /// attachments, or review (first step and last two steps).
  static bool showsToleranceReference({
    required int step,
    required int stepCount,
    int firstMeasurementStep = formFieldsStart,
  }) {
    if (stepCount < 3) return false;
    return step >= firstMeasurementStep && step < stepCount - 2;
  }
}
