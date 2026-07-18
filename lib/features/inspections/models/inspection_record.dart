import 'inspection_action.dart';
import 'inspection_status.dart';

class InspectionComment {
  const InspectionComment({
    required this.id,
    required this.authorUsername,
    required this.authorRole,
    required this.message,
    required this.createdAt,
    required this.fromStatus,
    required this.toStatus,
    required this.action,
  });

  final String id;
  final String authorUsername;
  final String authorRole;
  final String message;
  final DateTime createdAt;
  final InspectionStatus fromStatus;
  final InspectionStatus toStatus;
  final InspectionAction action;

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorUsername': authorUsername,
        'authorRole': authorRole,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
        'fromStatus': fromStatus.apiCode,
        'toStatus': toStatus.apiCode,
        'action': action.apiCode,
      };

  factory InspectionComment.fromJson(Map<String, dynamic> json) {
    return InspectionComment(
      id: json['id']?.toString() ?? '',
      authorUsername: json['authorUsername']?.toString() ?? '',
      authorRole: json['authorRole']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      fromStatus: InspectionStatus.tryParse(json['fromStatus']?.toString()) ??
          InspectionStatus.draft,
      toStatus: InspectionStatus.tryParse(json['toStatus']?.toString()) ??
          InspectionStatus.draft,
      action: InspectionAction.values.firstWhere(
        (a) => a.apiCode == json['action']?.toString(),
        orElse: () => InspectionAction.saveDraft,
      ),
    );
  }
}

/// Local inspection envelope around a form measurement record.
///
/// Designed so backend can accept the same shape later.
class InspectionRecord {
  const InspectionRecord({
    required this.id,
    required this.formId,
    required this.formCode,
    required this.title,
    required this.status,
    required this.createdByUsername,
    required this.updatedAt,
    required this.createdAt,
    this.payload = const {},
    this.comments = const [],
    this.assignedToRole,
  });

  final String id;
  final String formId;
  final String formCode;
  final String title;
  final InspectionStatus status;
  final String createdByUsername;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> payload;
  final List<InspectionComment> comments;
  final String? assignedToRole;

  InspectionRecord copyWith({
    InspectionStatus? status,
    Map<String, dynamic>? payload,
    List<InspectionComment>? comments,
    DateTime? updatedAt,
    String? assignedToRole,
    bool clearAssignedToRole = false,
  }) {
    return InspectionRecord(
      id: id,
      formId: formId,
      formCode: formCode,
      title: title,
      status: status ?? this.status,
      createdByUsername: createdByUsername,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      payload: payload ?? this.payload,
      comments: comments ?? this.comments,
      assignedToRole:
          clearAssignedToRole ? null : (assignedToRole ?? this.assignedToRole),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'formId': formId,
        'formCode': formCode,
        'title': title,
        'status': status.apiCode,
        'createdByUsername': createdByUsername,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'payload': payload,
        'comments': comments.map((c) => c.toJson()).toList(),
        'assignedToRole': assignedToRole,
      };

  factory InspectionRecord.fromJson(Map<String, dynamic> json) {
    return InspectionRecord(
      id: json['id']?.toString() ?? '',
      formId: json['formId']?.toString() ?? '',
      formCode: json['formCode']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: InspectionStatus.tryParse(json['status']?.toString()) ??
          InspectionStatus.draft,
      createdByUsername: json['createdByUsername']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      payload: json['payload'] is Map
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : const {},
      comments: json['comments'] is List
          ? (json['comments'] as List)
              .whereType<Map>()
              .map((e) => InspectionComment.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      assignedToRole: json['assignedToRole']?.toString(),
    );
  }
}
