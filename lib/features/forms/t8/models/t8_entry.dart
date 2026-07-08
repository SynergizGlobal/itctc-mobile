import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/form_calculations.dart';
import '../../../../core/utils/validators.dart';
import '../../shared/models/form_attachment.dart';
import '../../shared/models/form_site_capture.dart';
import '../../shared/widgets/solid_bed_fields.dart';

class T8Entry {
  T8Entry({String? id})
      : id = id ?? const Uuid().v4(),
        chainageKmController = TextEditingController(),
        chainageMController = TextEditingController(),
        chainageCmController = TextEditingController(),
        sleeperNoController = TextEditingController(),
        squarenessController = TextEditingController(),
        spacingDesignController = TextEditingController(),
        spacingMeasuredController = TextEditingController(),
        remarksController = TextEditingController();

  final String id;
  final TextEditingController chainageKmController;
  final TextEditingController chainageMController;
  final TextEditingController chainageCmController;
  final TextEditingController sleeperNoController;
  final TextEditingController squarenessController;
  final TextEditingController spacingDesignController;
  final TextEditingController spacingMeasuredController;
  final TextEditingController remarksController;
  final FormSiteCapture siteCapture = FormSiteCapture();
  final List<FormAttachment> attachments = [];

  TrackDirection direction = TrackDirection.up;

  double get spacingDesign => parseDouble(spacingDesignController.text) ?? 0;
  double get spacingMeasured => parseDouble(spacingMeasuredController.text) ?? 0;

  double get spacingIrregularity => FormCalculations.calculateIrregularity(
        design: spacingDesign,
        measured: spacingMeasured,
      );

  String rowLabel(int index) {
    final sleeper = sleeperNoController.text.trim();
    if (sleeper.isEmpty) return 'Row ${index + 1}';
    return 'Row ${index + 1} · Sleeper $sleeper';
  }

  factory T8Entry.fromMap(Map<String, dynamic> data) {
    final entry = T8Entry(id: data['id'] as String?);
    entry.direction = TrackDirectionX.fromStored(data['direction']?.toString());
    entry.chainageKmController.text = data['chainageKm']?.toString() ?? '';
    entry.chainageMController.text = data['chainageM']?.toString() ?? '';
    entry.chainageCmController.text = data['chainageCm']?.toString() ?? '';
    entry.sleeperNoController.text = data['sleeperNo']?.toString() ?? '';
    entry.squarenessController.text = data['squareness']?.toString() ?? '';
    entry.spacingDesignController.text = data['spacingDesign']?.toString() ?? '';
    entry.spacingMeasuredController.text = data['spacingMeasured']?.toString() ?? '';
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
        'direction': direction.label.toLowerCase(),
        'chainageKm': chainageKmController.text,
        'chainageM': chainageMController.text,
        'chainageCm': chainageCmController.text,
        'sleeperNo': sleeperNoController.text,
        'squareness': parseDouble(squarenessController.text),
        'spacingDesign': spacingDesign,
        'spacingMeasured': spacingMeasured,
        'spacingIrregularity': spacingIrregularity,
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'siteCapture': siteCapture.toJson(),
        'remarks': remarksController.text,
      };

  void dispose() {
    chainageKmController.dispose();
    chainageMController.dispose();
    chainageCmController.dispose();
    sleeperNoController.dispose();
    squarenessController.dispose();
    spacingDesignController.dispose();
    spacingMeasuredController.dispose();
    remarksController.dispose();
  }
}
