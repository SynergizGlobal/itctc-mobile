import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/form_calculations.dart';
import '../../../../core/utils/validators.dart';
import '../../shared/models/form_attachment.dart';
import '../../shared/models/form_site_capture.dart';

class T2Measurement {
  T2Measurement()
      : designController = TextEditingController(),
        measuredController = TextEditingController();

  final TextEditingController designController;
  final TextEditingController measuredController;

  double get design => parseDouble(designController.text) ?? 0;
  double get measured => parseDouble(measuredController.text) ?? 0;

  double get irregularity => FormCalculations.calculateIrregularity(
        design: design,
        measured: measured,
      );

  bool isWithinTolerance(double tolerance) =>
      FormCalculations.isWithinTolerance(
        irregularity: irregularity,
        tolerance: tolerance,
      );

  Map<String, dynamic> toJson() => {
        'design': design,
        'measured': measured,
        'irregularity': irregularity,
      };

  void dispose() {
    designController.dispose();
    measuredController.dispose();
  }
}

class T2LineData {
  T2LineData()
      : twist = T2Measurement(),
        lateralAlignment = T2Measurement(),
        longitudinalAlignment = T2Measurement(),
        crossLevel = T2Measurement(),
        gauge = T2Measurement(),
        measuringPointController = TextEditingController();

  final T2Measurement twist;
  final T2Measurement lateralAlignment;
  final T2Measurement longitudinalAlignment;
  final T2Measurement crossLevel;
  final T2Measurement gauge;
  final TextEditingController measuringPointController;

  Map<String, dynamic> toJson() => {
        'twist': twist.toJson(),
        'lateralAlignment': lateralAlignment.toJson(),
        'longitudinalAlignment': longitudinalAlignment.toJson(),
        'crossLevel': crossLevel.toJson(),
        'gauge': gauge.toJson(),
        'measuringPoint': measuringPointController.text,
      };

  void dispose() {
    twist.dispose();
    lateralAlignment.dispose();
    longitudinalAlignment.dispose();
    crossLevel.dispose();
    gauge.dispose();
    measuringPointController.dispose();
  }
}

class T2Entry {
  T2Entry({String? id})
      : id = id ?? const Uuid().v4(),
        chainageKmController = TextEditingController(),
        chainageMController = TextEditingController(),
        downLine = T2LineData(),
        upLine = T2LineData();

  final String id;
  final TextEditingController chainageKmController;
  final TextEditingController chainageMController;
  final T2LineData downLine;
  final T2LineData upLine;
  final FormSiteCapture siteCapture = FormSiteCapture();
  final List<FormAttachment> attachments = [];

  TrackType trackType = TrackType.slab;

  String rowLabel(int index) {
    final rowNumber = index + 1;
    final km = chainageKmController.text.trim();
    final m = chainageMController.text.trim();
    if (km.isEmpty && m.isEmpty) return 'Row $rowNumber';
    return 'Row $rowNumber · CH $km+$m';
  }

  factory T2Entry.fromMap(Map<String, dynamic> data) {
    final entry = T2Entry(id: data['id'] as String?);
    entry.chainageKmController.text = data['chainageKm']?.toString() ?? '';
    entry.chainageMController.text = data['chainageM']?.toString() ?? '';
    final track = data['trackType']?.toString() ?? 'slab';
    entry.trackType = track == 'ballasted' ? TrackType.ballasted : TrackType.slab;
    _populateLine(entry.downLine, data['downLine'] as Map<String, dynamic>?);
    _populateLine(entry.upLine, data['upLine'] as Map<String, dynamic>?);
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

  static void _populateLine(T2LineData line, Map<String, dynamic>? data) {
    if (data == null) return;
    _populateMeasurement(line.twist, data['twist'] as Map<String, dynamic>?);
    _populateMeasurement(line.lateralAlignment, data['lateralAlignment'] as Map<String, dynamic>?);
    _populateMeasurement(line.longitudinalAlignment, data['longitudinalAlignment'] as Map<String, dynamic>?);
    _populateMeasurement(line.crossLevel, data['crossLevel'] as Map<String, dynamic>?);
    _populateMeasurement(line.gauge, data['gauge'] as Map<String, dynamic>?);
    line.measuringPointController.text = data['measuringPoint']?.toString() ?? '';
  }

  static void _populateMeasurement(T2Measurement m, Map<String, dynamic>? data) {
    if (data == null) return;
    m.designController.text = data['design']?.toString() ?? '';
    m.measuredController.text = data['measured']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chainageKm': chainageKmController.text,
        'chainageM': chainageMController.text,
        'trackType': trackType.name,
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'siteCapture': siteCapture.toJson(),
        'downLine': downLine.toJson(),
        'upLine': upLine.toJson(),
      };

  void dispose() {
    chainageKmController.dispose();
    chainageMController.dispose();
    downLine.dispose();
    upLine.dispose();
  }
}
