import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/form_calculations.dart';
import '../../../../core/utils/validators.dart';
import '../../shared/models/form_attachment.dart';
import '../../shared/models/form_site_capture.dart';

class T22Entry {
  T22Entry({String? id})
      : id = id ?? const Uuid().v4(),
        lineController = TextEditingController(),
        point1Controller = TextEditingController(),
        point2Controller = TextEditingController(),
        point3Controller = TextEditingController(),
        point4Controller = TextEditingController(),
        point5Controller = TextEditingController(),
        remarksController = TextEditingController();

  static const pointLabels = [
    '(1) 250 mm',
    '(2) 5,000 mm',
    '(3) 1,000 mm',
    '(4) 3,400 mm',
    '(5) 3,900 mm',
  ];

  final String id;
  final TextEditingController lineController;
  final TextEditingController point1Controller;
  final TextEditingController point2Controller;
  final TextEditingController point3Controller;
  final TextEditingController point4Controller;
  final TextEditingController point5Controller;
  final TextEditingController remarksController;
  final FormSiteCapture siteCapture = FormSiteCapture();
  final List<FormAttachment> attachments = [];

  List<TextEditingController> get pointControllers => [
        point1Controller,
        point2Controller,
        point3Controller,
        point4Controller,
        point5Controller,
      ];

  List<double?> get measuredValues =>
      pointControllers.map((c) => parseDouble(c.text)).toList();

  List<double?> get irregularities {
    final standards = FormCalculations.t22StandardValuesMm;
    return List.generate(standards.length, (index) {
      final measured = measuredValues[index];
      if (measured == null) return null;
      return FormCalculations.calculateIrregularity(
        design: standards[index],
        measured: measured,
      );
    });
  }

  String rowLabel(int index) {
    final line = lineController.text.trim();
    if (line.isEmpty) return 'Row ${index + 1}';
    return 'Row ${index + 1} · $line';
  }

  factory T22Entry.fromMap(Map<String, dynamic> data) {
    final entry = T22Entry(id: data['id'] as String?);
    entry.lineController.text = data['line']?.toString() ?? '';
    entry.point1Controller.text = data['point1']?.toString() ?? '';
    entry.point2Controller.text = data['point2']?.toString() ?? '';
    entry.point3Controller.text = data['point3']?.toString() ?? '';
    entry.point4Controller.text = data['point4']?.toString() ?? '';
    entry.point5Controller.text = data['point5']?.toString() ?? '';
    entry.remarksController.text = data['remarks']?.toString() ?? '';
    entry.attachments.addAll(parseAttachments(data['attachments']));
    entry.siteCapture.applyFrom(
      FormSiteCapture.fromMap(
        data['siteCapture'] is Map
            ? Map<String, dynamic>.from(data['siteCapture'] as Map)
            : null,
      ),
    );
    return entry;
  }

  Map<String, dynamic> toJson() {
    final irregularityValues = irregularities;
    return {
      'id': id,
      'line': lineController.text,
      'point1': parseDouble(point1Controller.text),
      'point2': parseDouble(point2Controller.text),
      'point3': parseDouble(point3Controller.text),
      'point4': parseDouble(point4Controller.text),
      'point5': parseDouble(point5Controller.text),
      'irregularity1': irregularityValues[0],
      'irregularity2': irregularityValues[1],
      'irregularity3': irregularityValues[2],
      'irregularity4': irregularityValues[3],
      'irregularity5': irregularityValues[4],
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'siteCapture': siteCapture.toJson(),
      'remarks': remarksController.text,
    };
  }

  void dispose() {
    lineController.dispose();
    point1Controller.dispose();
    point2Controller.dispose();
    point3Controller.dispose();
    point4Controller.dispose();
    point5Controller.dispose();
    remarksController.dispose();
  }
}
