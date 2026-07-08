import 'package:flutter_test/flutter_test.dart';
import 'package:itctc/features/forms/shared/form_shared_steps.dart';

void main() {
  group('FormSharedSteps.showsToleranceReference', () {
    test('hides on site capture, attachments, and review for 5-step form', () {
      const stepCount = 5;

      expect(
        FormSharedSteps.showsToleranceReference(step: 0, stepCount: stepCount),
        isFalse,
      );
      expect(
        FormSharedSteps.showsToleranceReference(step: 1, stepCount: stepCount),
        isTrue,
      );
      expect(
        FormSharedSteps.showsToleranceReference(step: 2, stepCount: stepCount),
        isTrue,
      );
      expect(
        FormSharedSteps.showsToleranceReference(step: 3, stepCount: stepCount),
        isFalse,
      );
      expect(
        FormSharedSteps.showsToleranceReference(step: 4, stepCount: stepCount),
        isFalse,
      );
    });

    test('T-2 shows header tolerance only on down/up line steps', () {
      const stepCount = 6;

      expect(
        FormSharedSteps.showsToleranceReference(
          step: 1,
          stepCount: stepCount,
          firstMeasurementStep: 2,
        ),
        isFalse,
      );
      expect(
        FormSharedSteps.showsToleranceReference(
          step: 2,
          stepCount: stepCount,
          firstMeasurementStep: 2,
        ),
        isTrue,
      );
      expect(
        FormSharedSteps.showsToleranceReference(
          step: 3,
          stepCount: stepCount,
          firstMeasurementStep: 2,
        ),
        isTrue,
      );
      expect(
        FormSharedSteps.showsToleranceReference(
          step: 4,
          stepCount: stepCount,
          firstMeasurementStep: 2,
        ),
        isFalse,
      );
    });
  });
}
