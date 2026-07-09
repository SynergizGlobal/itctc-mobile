import 'package:flutter/material.dart';

enum FormCategory {
  civil('Civil Works'),
  track('Track Works'),
  electrical('Electrical'),
  signalling('Signalling');

  const FormCategory(this.label);
  final String label;
}

enum FormBuildStatus {
  ready('Ready'),
  planned('Planned');

  const FormBuildStatus(this.label);
  final String label;
}

class FormInfo {
  /// Shared home-list icon for every measurement record form.
  static const IconData listIcon = Icons.fact_check_rounded;

  const FormInfo({
    required this.id,
    required this.code,
    required this.title,
    required this.formatName,
    required this.category,
    required this.routePath,
    required this.buildStatus,
    this.measurementInterval,
  });

  final String id;
  final String code;
  final String title;
  /// Official format name from NHSRCL / JRTT inspection formats table.
  final String formatName;
  final FormCategory category;
  final String routePath;
  final FormBuildStatus buildStatus;
  final String? measurementInterval;

  bool get isImplemented => buildStatus == FormBuildStatus.ready;
}
