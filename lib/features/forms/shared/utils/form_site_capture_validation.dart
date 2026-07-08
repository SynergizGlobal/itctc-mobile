import 'package:flutter/material.dart';

import '../../../../core/services/dialog_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../form_shared_steps.dart';
import '../models/form_site_capture.dart';

abstract final class FormSiteCaptureValidation {
  static bool canAccessStep(FormSiteCapture capture, int targetStep) {
    if (targetStep <= FormSharedSteps.siteCapture) return true;
    return capture.isComplete;
  }

  static String requirementMessage(FormSiteCapture capture) {
    if (capture.isComplete) return '';

    final missing = <String>[];
    if (!capture.hasLocation) missing.add('location');
    if (!capture.hasSelfie) missing.add('inspector selfie');

    if (missing.length == 2) {
      return 'Location and inspector selfie are required before continuing.';
    }
    return '${missing.first[0].toUpperCase()}${missing.first.substring(1)} is required before continuing.';
  }

  static bool guardStep(
    FormSiteCapture capture,
    int targetStep,
  ) {
    if (canAccessStep(capture, targetStep)) return true;

    DialogService.showAlert(
      title: 'Required',
      message: requirementMessage(capture),
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.warning,
    );
    return false;
  }
}
