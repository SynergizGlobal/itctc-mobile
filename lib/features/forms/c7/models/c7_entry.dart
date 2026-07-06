import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/form_calculations.dart';
import '../../../../core/utils/validators.dart';
import '../../shared/models/form_attachment.dart';

class C7Entry {
  C7Entry({String? id})
      : id = id ?? const Uuid().v4(),
        chainageKmController = TextEditingController(),
        chainageMController = TextEditingController(),
        straightCurveController = TextEditingController(),
        trackTypeController = TextEditingController(),
        cantController = TextEditingController(),
        h1Controller = TextEditingController(),
        h2Controller = TextEditingController(),
        h3Controller = TextEditingController(),
        h4Controller = TextEditingController(),
        h5Controller = TextEditingController(),
        h6Controller = TextEditingController(),
        standardAController = TextEditingController(),
        standardBController = TextEditingController(),
        remarksController = TextEditingController();

  final String id;
  final TextEditingController chainageKmController;
  final TextEditingController chainageMController;
  final TextEditingController straightCurveController;
  final TextEditingController trackTypeController;
  final TextEditingController cantController;
  final TextEditingController h1Controller;
  final TextEditingController h2Controller;
  final TextEditingController h3Controller;
  final TextEditingController h4Controller;
  final TextEditingController h5Controller;
  final TextEditingController h6Controller;
  final TextEditingController standardAController;
  final TextEditingController standardBController;
  final TextEditingController remarksController;
  final List<FormAttachment> attachments = [];

  double get h1 => parseDouble(h1Controller.text) ?? 0;
  double get h2 => parseDouble(h2Controller.text) ?? 0;
  double get h3 => parseDouble(h3Controller.text) ?? 0;
  double get h4 => parseDouble(h4Controller.text) ?? 0;
  double get h5 => parseDouble(h5Controller.text) ?? 0;
  double get h6 => parseDouble(h6Controller.text) ?? 0;

  double get calculatedA => FormCalculations.calculateNoiseBarrierA(
        h1: h1,
        h2: h2,
        h5: h5,
      );

  double get calculatedB => FormCalculations.calculateNoiseBarrierB(
        h3: h3,
        h4: h4,
        h6: h6,
      );

  String rowLabel(int index) {
    final rowNumber = index + 1;
    final km = chainageKmController.text.trim();
    final m = chainageMController.text.trim();
    if (km.isEmpty && m.isEmpty) return 'Row $rowNumber';
    return 'Row $rowNumber · CH $km+$m';
  }

  factory C7Entry.fromMap(Map<String, dynamic> data) {
    final entry = C7Entry(id: data['id'] as String?);
    entry.chainageKmController.text = data['chainageKm']?.toString() ?? '';
    entry.chainageMController.text = data['chainageM']?.toString() ?? '';
    entry.straightCurveController.text = data['straightCurve']?.toString() ?? '';
    entry.trackTypeController.text = data['trackType']?.toString() ?? '';
    entry.cantController.text = data['cantValue']?.toString() ?? '';
    entry.h1Controller.text = data['h1']?.toString() ?? '';
    entry.h2Controller.text = data['h2']?.toString() ?? '';
    entry.h3Controller.text = data['h3']?.toString() ?? '';
    entry.h4Controller.text = data['h4']?.toString() ?? '';
    entry.h5Controller.text = data['h5']?.toString() ?? '';
    entry.h6Controller.text = data['h6']?.toString() ?? '';
    entry.standardAController.text = data['standardA']?.toString() ?? '';
    entry.standardBController.text = data['standardB']?.toString() ?? '';
    entry.remarksController.text = data['remarks']?.toString() ?? '';
    entry.attachments.addAll(parseAttachments(data['attachments']));
    return entry;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chainageKm': chainageKmController.text,
        'chainageM': chainageMController.text,
        'straightCurve': straightCurveController.text,
        'cantValue': parseDouble(cantController.text),
        'trackType': trackTypeController.text,
        'h1': h1,
        'h2': h2,
        'h3': h3,
        'h4': h4,
        'h5': h5,
        'h6': h6,
        'calculatedA': calculatedA,
        'standardA': parseDouble(standardAController.text),
        'calculatedB': calculatedB,
        'standardB': parseDouble(standardBController.text),
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'remarks': remarksController.text,
      };

  void dispose() {
    chainageKmController.dispose();
    chainageMController.dispose();
    straightCurveController.dispose();
    trackTypeController.dispose();
    cantController.dispose();
    h1Controller.dispose();
    h2Controller.dispose();
    h3Controller.dispose();
    h4Controller.dispose();
    h5Controller.dispose();
    h6Controller.dispose();
    standardAController.dispose();
    standardBController.dispose();
    remarksController.dispose();
  }
}
