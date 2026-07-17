import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/form_calculations.dart';
import '../../../../core/utils/validators.dart';
import '../../shared/models/form_attachment.dart';
import '../../shared/models/form_site_capture.dart';

class T21Entry {
  T21Entry({String? id})
      : id = id ?? const Uuid().v4(),
        locationController = TextEditingController(),
        lineController = TextEditingController(),
        chainageKmController = TextEditingController(),
        chainageMController = TextEditingController(),
        foulingDesignController = TextEditingController(),
        foulingMeasuredController = TextEditingController(),
        trackLengthDesignController = TextEditingController(text: '332.0'),
        trackLengthMeasuredController = TextEditingController(),
        remarksController = TextEditingController();

  final String id;
  final TextEditingController locationController;
  final TextEditingController lineController;
  final TextEditingController chainageKmController;
  final TextEditingController chainageMController;
  final TextEditingController foulingDesignController;
  final TextEditingController foulingMeasuredController;
  final TextEditingController trackLengthDesignController;
  final TextEditingController trackLengthMeasuredController;
  final TextEditingController remarksController;
  final FormSiteCapture siteCapture = FormSiteCapture();
  final List<FormAttachment> attachments = [];

  double? get foulingDesign => parseDouble(foulingDesignController.text);
  double? get foulingMeasured => parseDouble(foulingMeasuredController.text);
  double? get trackLengthDesign => parseDouble(trackLengthDesignController.text);
  double? get trackLengthMeasured => parseDouble(trackLengthMeasuredController.text);

  double? get trackLengthIrregularity {
    final design = trackLengthDesign;
    final measured = trackLengthMeasured;
    if (design == null || measured == null) return null;
    return FormCalculations.calculateIrregularity(
      design: design,
      measured: measured,
    );
  }

  bool? get foulingDistanceOk {
    final measured = foulingMeasured;
    if (measured == null) return null;
    return FormCalculations.isFoulingDistanceWithinTolerance(
      measuredMeters: measured,
    );
  }

  String rowLabel(int index) {
    final location = locationController.text.trim();
    if (location.isEmpty) return 'Row ${index + 1}';
    return 'Row ${index + 1} · $location';
  }

  factory T21Entry.fromMap(Map<String, dynamic> data) {
    final entry = T21Entry(id: data['id'] as String?);
    entry.locationController.text = data['location']?.toString() ?? '';
    entry.lineController.text = data['line']?.toString() ?? '';
    entry.chainageKmController.text = data['chainageKm']?.toString() ?? '';
    entry.chainageMController.text = data['chainageM']?.toString() ?? '';
    entry.foulingDesignController.text = data['foulingDesign']?.toString() ?? '';
    entry.foulingMeasuredController.text = data['foulingMeasured']?.toString() ?? '';
    entry.trackLengthDesignController.text =
        data['trackLengthDesign']?.toString() ?? '332.0';
    entry.trackLengthMeasuredController.text =
        data['trackLengthMeasured']?.toString() ?? '';
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
        'location': locationController.text,
        'line': lineController.text,
        'chainageKm': chainageKmController.text,
        'chainageM': chainageMController.text,
        'foulingDesign': foulingDesign,
        'foulingMeasured': foulingMeasured,
        'trackLengthDesign': trackLengthDesign,
        'trackLengthMeasured': trackLengthMeasured,
        'trackLengthIrregularity': trackLengthIrregularity,
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'siteCapture': siteCapture.toJson(),
        'remarks': remarksController.text,
      };

  void dispose() {
    locationController.dispose();
    lineController.dispose();
    chainageKmController.dispose();
    chainageMController.dispose();
    foulingDesignController.dispose();
    foulingMeasuredController.dispose();
    trackLengthDesignController.dispose();
    trackLengthMeasuredController.dispose();
    remarksController.dispose();
  }
}
