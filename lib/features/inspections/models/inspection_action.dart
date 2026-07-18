import '../../auth/models/user_role.dart';
import 'inspection_status.dart';

/// Role actions on an inspection record.
enum InspectionAction {
  saveDraft,
  submitToPmc,
  pmcApprove,
  pmcReturnToInspector,
  pmcResubmitToItc,
  itcApprove,
  itcReturnToPmc,
  itcReturnToInspector;

  String get label => switch (this) {
        InspectionAction.saveDraft => 'Save draft',
        InspectionAction.submitToPmc => 'Submit to PMC',
        InspectionAction.pmcApprove => 'Approve & forward to ITC',
        InspectionAction.pmcReturnToInspector => 'Return to Inspector',
        InspectionAction.pmcResubmitToItc => 'Resubmit to ITC',
        InspectionAction.itcApprove => 'Final approve',
        InspectionAction.itcReturnToPmc => 'Return to PMC',
        InspectionAction.itcReturnToInspector => 'Return to Inspector',
      };

  String get apiCode => switch (this) {
        InspectionAction.saveDraft => 'SAVE_DRAFT',
        InspectionAction.submitToPmc => 'SUBMIT_TO_PMC',
        InspectionAction.pmcApprove => 'PMC_APPROVE',
        InspectionAction.pmcReturnToInspector => 'PMC_RETURN_TO_INSPECTOR',
        InspectionAction.pmcResubmitToItc => 'PMC_RESUBMIT_TO_ITC',
        InspectionAction.itcApprove => 'ITC_APPROVE',
        InspectionAction.itcReturnToPmc => 'ITC_RETURN_TO_PMC',
        InspectionAction.itcReturnToInspector => 'ITC_RETURN_TO_INSPECTOR',
      };

  UserRole get actorRole => switch (this) {
        InspectionAction.saveDraft ||
        InspectionAction.submitToPmc =>
          UserRole.inspector,
        InspectionAction.pmcApprove ||
        InspectionAction.pmcReturnToInspector ||
        InspectionAction.pmcResubmitToItc =>
          UserRole.pmc,
        InspectionAction.itcApprove ||
        InspectionAction.itcReturnToPmc ||
        InspectionAction.itcReturnToInspector =>
          UserRole.itcEngineer,
      };

  InspectionStatus get resultingStatus => switch (this) {
        InspectionAction.saveDraft => InspectionStatus.draft,
        InspectionAction.submitToPmc => InspectionStatus.submittedToPmc,
        InspectionAction.pmcApprove => InspectionStatus.pendingItcReview,
        InspectionAction.pmcReturnToInspector =>
          InspectionStatus.returnedToInspector,
        InspectionAction.pmcResubmitToItc => InspectionStatus.pendingItcReview,
        InspectionAction.itcApprove => InspectionStatus.approved,
        InspectionAction.itcReturnToPmc => InspectionStatus.returnedToPmc,
        InspectionAction.itcReturnToInspector =>
          InspectionStatus.returnedToInspector,
      };

  bool get requiresComment => switch (this) {
        InspectionAction.pmcReturnToInspector ||
        InspectionAction.itcReturnToPmc ||
        InspectionAction.itcReturnToInspector =>
          true,
        _ => false,
      };
}
