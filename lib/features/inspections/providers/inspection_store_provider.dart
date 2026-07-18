import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/models/auth_user.dart';
import '../../auth/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/inspection_action.dart';
import '../models/inspection_record.dart';
import '../models/inspection_status.dart';
import '../models/inspection_workflow.dart';

final inspectionStoreProvider =
    StateNotifierProvider<InspectionStoreNotifier, List<InspectionRecord>>(
  (ref) => InspectionStoreNotifier()..bootstrap(),
);

final inspectionByIdProvider =
    Provider.family<InspectionRecord?, String>((ref, id) {
  final all = ref.watch(inspectionStoreProvider);
  for (final record in all) {
    if (record.id == id) return record;
  }
  return null;
});

final formInspectionsProvider =
    Provider.family<List<InspectionRecord>, String>((ref, formId) {
  final user = ref.watch(authProvider).user;
  final all = ref.watch(inspectionStoreProvider);
  final filtered = all.where((record) {
    if (record.formId != formId) return false;
    if (user == null) return false;
    if (user.role == UserRole.inspector) {
      return record.createdByUsername == user.username;
    }
    // PMC / ITC see submitted+ records for this form (not private drafts of others)
    if (record.status == InspectionStatus.draft &&
        record.createdByUsername != user.username) {
      return false;
    }
    return true;
  }).toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return filtered;
});

/// Inspections visible in the current user's default inbox.
final roleInboxProvider = Provider<List<InspectionRecord>>((ref) {
  final user = ref.watch(authProvider).user;
  final all = ref.watch(inspectionStoreProvider);
  if (user == null) return const [];

  final statuses = InspectionWorkflow.inboxStatusesFor(user.role);
  return all.where((record) {
    if (!statuses.contains(record.status)) return false;
    if (user.role == UserRole.inspector) {
      return record.createdByUsername == user.username;
    }
    return true;
  }).toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
});

/// Inspections that currently need action from the logged-in role.
final roleActionableProvider = Provider<List<InspectionRecord>>((ref) {
  final user = ref.watch(authProvider).user;
  final inbox = ref.watch(roleInboxProvider);
  if (user == null) return const [];

  final actionable = InspectionWorkflow.actionableStatusesFor(user.role);
  return inbox.where((r) => actionable.contains(r.status)).toList();
});

class InspectionStoreNotifier extends StateNotifier<List<InspectionRecord>> {
  InspectionStoreNotifier() : super(const []);

  static const _uuid = Uuid();
  bool _bootstrapped = false;

  Future<void> bootstrap() async {
    if (_bootstrapped) return;
    _bootstrapped = true;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.prefInspections);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      state = decoded
          .whereType<Map>()
          .map((e) => InspectionRecord.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      // Keep empty local store if persistence is corrupt.
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(AppConstants.prefInspections, encoded);
  }

  InspectionRecord createDraft({
    required AuthUser inspector,
    required String formId,
    required String formCode,
    required String title,
    Map<String, dynamic> payload = const {},
  }) {
    if (inspector.role != UserRole.inspector) {
      throw StateError('Only Inspectors can create inspection drafts');
    }

    final now = DateTime.now();
    final record = InspectionRecord(
      id: _uuid.v4(),
      formId: formId,
      formCode: formCode,
      title: title,
      status: InspectionStatus.draft,
      createdByUsername: inspector.username,
      createdAt: now,
      updatedAt: now,
      payload: payload,
      assignedToRole: UserRole.inspector.apiCode,
      comments: [
        InspectionComment(
          id: _uuid.v4(),
          authorUsername: inspector.username,
          authorRole: inspector.role.apiCode,
          message: 'Inspection draft created',
          createdAt: now,
          fromStatus: InspectionStatus.draft,
          toStatus: InspectionStatus.draft,
          action: InspectionAction.saveDraft,
        ),
      ],
    );
    state = [record, ...state];
    _persist();
    return record;
  }

  /// Create or update inspector entry, optionally submit to PMC.
  InspectionRecord saveInspectorEntry({
    required AuthUser inspector,
    required String formId,
    required String formCode,
    required String title,
    required Map<String, dynamic> payload,
    String? inspectionId,
    bool submitForReview = false,
  }) {
    late InspectionRecord record;
    if (inspectionId == null) {
      record = createDraft(
        inspector: inspector,
        formId: formId,
        formCode: formCode,
        title: title,
        payload: payload,
      );
    } else {
      record = updatePayload(
        inspectionId: inspectionId,
        actor: inspector,
        payload: payload,
      );
    }

    if (submitForReview) {
      record = performAction(
        inspectionId: record.id,
        actor: inspector,
        action: InspectionAction.submitToPmc,
        comment: 'Submitted for PMC review',
      );
    } else if (inspectionId != null) {
      // Explicit draft save journey note when updating existing.
      record = performAction(
        inspectionId: record.id,
        actor: inspector,
        action: InspectionAction.saveDraft,
        comment: 'Draft saved',
      );
    }
    return record;
  }

  InspectionRecord updatePayload({
    required String inspectionId,
    required AuthUser actor,
    required Map<String, dynamic> payload,
  }) {
    final current = _require(inspectionId);
    if (actor.role != UserRole.inspector ||
        current.createdByUsername != actor.username) {
      throw StateError('Only the owning Inspector can edit inspection data');
    }
    if (!current.status.isEditableByInspector) {
      throw StateError(
        'Inspection is not editable in status ${current.status.label}',
      );
    }

    final updated = current.copyWith(
      payload: payload,
      updatedAt: DateTime.now(),
    );
    _replace(updated);
    _persist();
    return updated;
  }

  InspectionRecord performAction({
    required String inspectionId,
    required AuthUser actor,
    required InspectionAction action,
    String? comment,
  }) {
    final current = _require(inspectionId);

    if (!InspectionWorkflow.canPerform(
      role: actor.role,
      status: current.status,
      action: action,
    )) {
      throw StateError(
        '${actor.role.shortLabel} cannot ${action.label} '
        'when status is ${current.status.label}',
      );
    }

    if (action.requiresComment && (comment == null || comment.trim().isEmpty)) {
      throw StateError('Comment is required for ${action.label}');
    }

    if (actor.role == UserRole.inspector &&
        current.createdByUsername != actor.username) {
      throw StateError('Inspector can only act on own inspections');
    }

    final nextStatus = action.resultingStatus;
    final now = DateTime.now();
    final comments = [
      ...current.comments,
      InspectionComment(
        id: _uuid.v4(),
        authorUsername: actor.username,
        authorRole: actor.role.apiCode,
        message: (comment == null || comment.trim().isEmpty)
            ? action.label
            : comment.trim(),
        createdAt: now,
        fromStatus: current.status,
        toStatus: nextStatus,
        action: action,
      ),
    ];

    final updated = current.copyWith(
      status: nextStatus,
      comments: comments,
      updatedAt: now,
      assignedToRole: _assignedRoleFor(nextStatus),
    );
    _replace(updated);
    _persist();
    return updated;
  }

  String? _assignedRoleFor(InspectionStatus status) {
    return switch (status) {
      InspectionStatus.draft ||
      InspectionStatus.returnedToInspector =>
        UserRole.inspector.apiCode,
      InspectionStatus.submittedToPmc ||
      InspectionStatus.returnedToPmc =>
        UserRole.pmc.apiCode,
      InspectionStatus.pendingItcReview => UserRole.itcEngineer.apiCode,
      InspectionStatus.approved => null,
    };
  }

  InspectionRecord _require(String id) {
    return state.firstWhere(
      (r) => r.id == id,
      orElse: () => throw StateError('Inspection not found: $id'),
    );
  }

  void _replace(InspectionRecord updated) {
    state = [
      for (final record in state)
        if (record.id == updated.id) updated else record,
    ];
  }

  Future<void> clear() async {
    state = const [];
    await _persist();
  }
}
