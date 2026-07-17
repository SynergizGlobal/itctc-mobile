import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/form_calculations.dart';
import '../../../../core/utils/validators.dart';
import '../../shared/models/form_attachment.dart';
import '../../shared/models/form_site_capture.dart';

class T13Entry {
  T13Entry({String? id})
      : id = id ?? const Uuid().v4(),
        lineController = TextEditingController(),
        locationController = TextEditingController(),
        designValueController = TextEditingController(),
        measuredValueController = TextEditingController(),
        remarksController = TextEditingController();

  final String id;
  final TextEditingController lineController;
  final TextEditingController locationController;
  final TextEditingController designValueController;
  final TextEditingController measuredValueController;
  final TextEditingController remarksController;
  final FormSiteCapture siteCapture = FormSiteCapture();
  final List<FormAttachment> attachments = [];

  double? get designValue => parseDouble(designValueController.text);
  double? get measuredValue => parseDouble(measuredValueController.text);

  double? get difference {
    final design = designValue;
    final measured = measuredValue;
    if (design == null || measured == null) return null;
    return FormCalculations.calculateDifference(
      design: design,
      measured: measured,
    );
  }

  String rowLabel(int index) {
    final location = locationController.text.trim();
    if (location.isEmpty) return 'Row ${index + 1}';
    return 'Row ${index + 1} · $location';
  }

  factory T13Entry.fromMap(Map<String, dynamic> data) {
    final entry = T13Entry(id: data['id'] as String?);
    entry.lineController.text = data['line']?.toString() ?? '';
    entry.locationController.text = data['location']?.toString() ?? '';
    entry.designValueController.text = data['designValue']?.toString() ?? '';
    entry.measuredValueController.text = data['measuredValue']?.toString() ?? '';
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'line': lineController.text,
        'location': locationController.text,
        'designValue': designValue,
        'measuredValue': measuredValue,
        'difference': difference,
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'siteCapture': siteCapture.toJson(),
        'remarks': remarksController.text,
      };

  void dispose() {
    lineController.dispose();
    locationController.dispose();
    designValueController.dispose();
    measuredValueController.dispose();
    remarksController.dispose();
  }
}
