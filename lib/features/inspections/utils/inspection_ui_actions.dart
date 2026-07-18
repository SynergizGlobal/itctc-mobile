import '../../auth/models/user_role.dart';
import '../models/inspection_action.dart';
import '../models/inspection_status.dart';
import '../models/inspection_workflow.dart';

/// Role-aware table / review action labels for local workflow UI.
class InspectionUiActions {
  InspectionUiActions._();

  static String? primaryActionLabel({
    required UserRole role,
    required InspectionStatus status,
  }) {
    final actions = InspectionWorkflow.availableActions(
      role: role,
      status: status,
    );
    if (actions.isEmpty) return null;

    return switch (role) {
      UserRole.inspector => switch (status) {
          InspectionStatus.draft ||
          InspectionStatus.returnedToInspector =>
            'Continue',
          _ => null,
        },
      UserRole.pmc => switch (status) {
          InspectionStatus.submittedToPmc => 'Start Review',
          InspectionStatus.returnedToPmc => 'Continue Review',
          _ => null,
        },
      UserRole.itcEngineer => switch (status) {
          InspectionStatus.pendingItcReview => 'Start Review',
          _ => null,
        },
    };
  }

  static bool canEditFormData({
    required UserRole role,
    required InspectionStatus status,
    required String createdByUsername,
    required String currentUsername,
  }) {
    if (role != UserRole.inspector) return false;
    if (createdByUsername != currentUsername) return false;
    return status.isEditableByInspector;
  }

  static String submitButtonLabel(UserRole role) {
    return switch (role) {
      UserRole.inspector => 'Submit for Review',
      UserRole.pmc => 'Forward to ITC',
      UserRole.itcEngineer => 'Final Approve',
    };
  }

  static List<InspectionAction> reviewActions({
    required UserRole role,
    required InspectionStatus status,
  }) {
    return InspectionWorkflow.availableActions(role: role, status: status)
        .where(
          (action) =>
              action != InspectionAction.saveDraft &&
              action != InspectionAction.submitToPmc,
        )
        .toList();
  }
}
