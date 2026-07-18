import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:itctc/features/auth/data/auth_credentials.dart';
import 'package:itctc/features/auth/models/user_role.dart';
import 'package:itctc/features/inspections/models/inspection_action.dart';
import 'package:itctc/features/inspections/models/inspection_status.dart';
import 'package:itctc/features/inspections/models/inspection_workflow.dart';
import 'package:itctc/features/inspections/providers/inspection_store_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthCredentials', () {
    test('validates three role accounts with shared password', () {
      expect(
        AuthCredentials.validate('itctc_in_001', '1234')?.role,
        UserRole.inspector,
      );
      expect(
        AuthCredentials.validate('itctc_pmc_001', '1234')?.role,
        UserRole.pmc,
      );
      expect(
        AuthCredentials.validate('itctc_itc_001', '1234')?.role,
        UserRole.itcEngineer,
      );
    });

    test('rejects wrong password', () {
      expect(AuthCredentials.validate('itctc_in_001', 'wrong'), isNull);
    });
  });

  group('InspectionWorkflow', () {
    test('inspector can submit draft to PMC', () {
      final actions = InspectionWorkflow.availableActions(
        role: UserRole.inspector,
        status: InspectionStatus.draft,
      );

      expect(actions, contains(InspectionAction.submitToPmc));
      expect(actions, isNot(contains(InspectionAction.pmcApprove)));
    });

    test('pmc can approve or return submitted inspection', () {
      final actions = InspectionWorkflow.availableActions(
        role: UserRole.pmc,
        status: InspectionStatus.submittedToPmc,
      );

      expect(actions, contains(InspectionAction.pmcApprove));
      expect(actions, contains(InspectionAction.pmcReturnToInspector));
    });

    test('itc can final-approve or return pending review', () {
      final actions = InspectionWorkflow.availableActions(
        role: UserRole.itcEngineer,
        status: InspectionStatus.pendingItcReview,
      );

      expect(actions, contains(InspectionAction.itcApprove));
      expect(actions, contains(InspectionAction.itcReturnToPmc));
      expect(actions, contains(InspectionAction.itcReturnToInspector));
    });
  });

  group('InspectionStoreNotifier', () {
    test('runs full happy-path workflow locally', () async {
      final store = InspectionStoreNotifier();
      final inspector = AuthCredentials.inspector;
      final pmc = AuthCredentials.pmc;
      final itc = AuthCredentials.itcEngineer;

      final draft = store.createDraft(
        inspector: inspector,
        formId: 't13',
        formCode: 'Form T-13',
        title: 'Fouling Mark',
      );
      expect(draft.status, InspectionStatus.draft);

      final submitted = store.performAction(
        inspectionId: draft.id,
        actor: inspector,
        action: InspectionAction.submitToPmc,
      );
      expect(submitted.status, InspectionStatus.submittedToPmc);

      final pendingItc = store.performAction(
        inspectionId: draft.id,
        actor: pmc,
        action: InspectionAction.pmcApprove,
      );
      expect(pendingItc.status, InspectionStatus.pendingItcReview);

      final approved = store.performAction(
        inspectionId: draft.id,
        actor: itc,
        action: InspectionAction.itcApprove,
      );
      expect(approved.status, InspectionStatus.approved);
      expect(approved.status.isFinalApproved, isTrue);
      expect(approved.comments, isNotEmpty);
    });

    test('pmc return requires comment and sends back to inspector', () {
      final store = InspectionStoreNotifier();
      final draft = store.createDraft(
        inspector: AuthCredentials.inspector,
        formId: 't21',
        formCode: 'Form T-21',
        title: 'Track Effective Length',
      );
      store.performAction(
        inspectionId: draft.id,
        actor: AuthCredentials.inspector,
        action: InspectionAction.submitToPmc,
      );

      expect(
        () => store.performAction(
          inspectionId: draft.id,
          actor: AuthCredentials.pmc,
          action: InspectionAction.pmcReturnToInspector,
        ),
        throwsA(isA<StateError>()),
      );

      final returned = store.performAction(
        inspectionId: draft.id,
        actor: AuthCredentials.pmc,
        action: InspectionAction.pmcReturnToInspector,
        comment: 'Please recheck measured value.',
      );

      expect(returned.status, InspectionStatus.returnedToInspector);
      expect(returned.comments.last.message, 'Please recheck measured value.');
      expect(returned.status.isEditableByInspector, isTrue);
    });

    test('itc return to pmc then pmc can resubmit', () {
      final store = InspectionStoreNotifier();
      final draft = store.createDraft(
        inspector: AuthCredentials.inspector,
        formId: 't22',
        formCode: 'Form T-22',
        title: 'Buffer Stop',
      );
      store.performAction(
        inspectionId: draft.id,
        actor: AuthCredentials.inspector,
        action: InspectionAction.submitToPmc,
      );
      store.performAction(
        inspectionId: draft.id,
        actor: AuthCredentials.pmc,
        action: InspectionAction.pmcApprove,
      );

      final returnedToPmc = store.performAction(
        inspectionId: draft.id,
        actor: AuthCredentials.itcEngineer,
        action: InspectionAction.itcReturnToPmc,
        comment: 'Need PMC clarification on point (2).',
      );
      expect(returnedToPmc.status, InspectionStatus.returnedToPmc);

      final resubmitted = store.performAction(
        inspectionId: draft.id,
        actor: AuthCredentials.pmc,
        action: InspectionAction.pmcResubmitToItc,
        comment: 'Clarified measurement point (2).',
      );
      expect(resubmitted.status, InspectionStatus.pendingItcReview);
    });
  });
}
