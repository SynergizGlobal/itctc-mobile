import '../../auth/models/user_role.dart';
import 'inspection_action.dart';
import 'inspection_status.dart';

/// Pure workflow rules — same logic will map 1:1 to backend permissions later.
class InspectionWorkflow {
  InspectionWorkflow._();

  /// Default inbox statuses each role should see after login.
  static List<InspectionStatus> inboxStatusesFor(UserRole role) {
    return switch (role) {
      UserRole.inspector => const [
          InspectionStatus.draft,
          InspectionStatus.returnedToInspector,
          InspectionStatus.submittedToPmc,
          InspectionStatus.pendingItcReview,
          InspectionStatus.returnedToPmc,
          InspectionStatus.approved,
        ],
      UserRole.pmc => const [
          InspectionStatus.submittedToPmc,
          InspectionStatus.returnedToPmc,
          InspectionStatus.pendingItcReview,
          InspectionStatus.approved,
        ],
      UserRole.itcEngineer => const [
          InspectionStatus.pendingItcReview,
          InspectionStatus.approved,
          InspectionStatus.returnedToPmc,
        ],
    };
  }

  /// Statuses that need action from this role right now.
  static List<InspectionStatus> actionableStatusesFor(UserRole role) {
    return switch (role) {
      UserRole.inspector => const [
          InspectionStatus.draft,
          InspectionStatus.returnedToInspector,
        ],
      UserRole.pmc => const [
          InspectionStatus.submittedToPmc,
          InspectionStatus.returnedToPmc,
        ],
      UserRole.itcEngineer => const [
          InspectionStatus.pendingItcReview,
        ],
    };
  }

  static List<InspectionAction> availableActions({
    required UserRole role,
    required InspectionStatus status,
  }) {
    return InspectionAction.values.where((action) {
      if (action.actorRole != role) return false;
      return switch (action) {
        InspectionAction.saveDraft =>
          status == InspectionStatus.draft ||
              status == InspectionStatus.returnedToInspector,
        InspectionAction.submitToPmc =>
          status == InspectionStatus.draft ||
              status == InspectionStatus.returnedToInspector,
        InspectionAction.pmcApprove => status == InspectionStatus.submittedToPmc,
        InspectionAction.pmcReturnToInspector =>
          status == InspectionStatus.submittedToPmc ||
              status == InspectionStatus.returnedToPmc,
        InspectionAction.pmcResubmitToItc =>
          status == InspectionStatus.returnedToPmc,
        InspectionAction.itcApprove =>
          status == InspectionStatus.pendingItcReview,
        InspectionAction.itcReturnToPmc =>
          status == InspectionStatus.pendingItcReview,
        InspectionAction.itcReturnToInspector =>
          status == InspectionStatus.pendingItcReview,
      };
    }).toList();
  }

  static bool canPerform({
    required UserRole role,
    required InspectionStatus status,
    required InspectionAction action,
  }) {
    return availableActions(role: role, status: status).contains(action);
  }
}
