/// Inspection workflow statuses aligned to the NHSRCL review chain.
///
/// `apiCode` values are stable for future backend mapping.
enum InspectionStatus {
  /// Inspector is creating / editing before first submit.
  draft,

  /// Inspector submitted; waiting for PMC review.
  submittedToPmc,

  /// PMC or ITC returned the record for inspector corrections.
  returnedToInspector,

  /// PMC approved; waiting for ITC Engineer.
  pendingItcReview,

  /// ITC returned the record to PMC for clarification.
  returnedToPmc,

  /// ITC final approval — workflow complete.
  approved;

  String get label => switch (this) {
        InspectionStatus.draft => 'Draft',
        InspectionStatus.submittedToPmc => 'Submitted to PMC',
        InspectionStatus.returnedToInspector => 'Returned to Inspector',
        InspectionStatus.pendingItcReview => 'Pending ITC Review',
        InspectionStatus.returnedToPmc => 'Returned to PMC',
        InspectionStatus.approved => 'Approved',
      };

  String get apiCode => switch (this) {
        InspectionStatus.draft => 'DRAFT',
        InspectionStatus.submittedToPmc => 'SUBMITTED_TO_PMC',
        InspectionStatus.returnedToInspector => 'RETURNED_TO_INSPECTOR',
        InspectionStatus.pendingItcReview => 'PENDING_ITC_REVIEW',
        InspectionStatus.returnedToPmc => 'RETURNED_TO_PMC',
        InspectionStatus.approved => 'APPROVED',
      };

  bool get isFinalApproved => this == InspectionStatus.approved;

  bool get isEditableByInspector =>
      this == InspectionStatus.draft ||
      this == InspectionStatus.returnedToInspector;

  static InspectionStatus? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final key = value.trim().toUpperCase().replaceAll(' ', '_');
    for (final status in InspectionStatus.values) {
      if (status.apiCode == key || status.name.toUpperCase() == key) {
        return status;
      }
    }
    return null;
  }
}
