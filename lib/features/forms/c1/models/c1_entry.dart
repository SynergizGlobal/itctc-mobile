import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/form_calculations.dart';
import '../../../../core/utils/validators.dart';
import '../../shared/models/form_attachment.dart';

class C1Entry {
  C1Entry({String? id})
      : id = id ?? const Uuid().v4(),
        chainageKmController = TextEditingController(),
        chainageMController = TextEditingController(),
        structureTypeController = TextEditingController(),
        straightCurveController = TextEditingController(),
        trackTypeController = TextEditingController(),
        cantController = TextEditingController(),
        aController = TextEditingController(),
        bController = TextEditingController(),
        bPrimeController = TextEditingController(),
        cController = TextEditingController(),
        standardAController = TextEditingController(),
        standardBController = TextEditingController(),
        standardCController = TextEditingController(),
        standardDController = TextEditingController(),
        measuredDController = TextEditingController(),
        remarksController = TextEditingController();

  final String id;
  final TextEditingController chainageKmController;
  final TextEditingController chainageMController;
  final TextEditingController structureTypeController;
  final TextEditingController straightCurveController;
  final TextEditingController trackTypeController;
  final TextEditingController cantController;
  final TextEditingController aController;
  final TextEditingController bController;
  final TextEditingController bPrimeController;
  final TextEditingController cController;
  final TextEditingController standardAController;
  final TextEditingController standardBController;
  final TextEditingController standardCController;
  final TextEditingController standardDController;
  final TextEditingController measuredDController;
  final TextEditingController remarksController;
  final List<FormAttachment> attachments = [];

  bool get isStraight {
    final value = straightCurveController.text.trim().toLowerCase();
    if (value.isEmpty) return true;
    return value.contains('straight');
  }

  double get cant => parseDouble(cantController.text) ?? 0;
  double get a => parseDouble(aController.text) ?? 0;
  double get b => parseDouble(bController.text) ?? 0;
  double? get bPrime => parseDouble(bPrimeController.text);
  double get c => parseDouble(cController.text) ?? 0;

  double get xDown => FormCalculations.calculateX(
        isStraight: isStraight,
        cantValue: cant,
      );

  double get xUp => xDown;

  double get calculatedA => FormCalculations.calculateA(a: a, x: xDown);
  double get calculatedB => FormCalculations.calculateB(b: b, bPrime: bPrime);
  double get calculatedC => FormCalculations.calculateC(c: c, x: xUp);

  String rowLabel(int index) {
    final rowNumber = index + 1;
    final km = chainageKmController.text.trim();
    final m = chainageMController.text.trim();
    if (km.isEmpty && m.isEmpty) return 'Row $rowNumber';
    return 'Row $rowNumber · CH $km+$m';
  }

  factory C1Entry.fromMap(Map<String, dynamic> data) {
    final entry = C1Entry(id: data['id'] as String?);
    entry.chainageKmController.text = data['chainageKm']?.toString() ?? '';
    entry.chainageMController.text = data['chainageM']?.toString() ?? '';
    entry.structureTypeController.text = data['structureType']?.toString() ?? '';
    entry.straightCurveController.text = data['straightCurve']?.toString() ?? '';
    entry.trackTypeController.text = data['trackType']?.toString() ?? '';
    entry.cantController.text = data['cantValue']?.toString() ?? '';
    entry.aController.text = data['a']?.toString() ?? '';
    entry.bController.text = data['b']?.toString() ?? '';
    entry.bPrimeController.text = data['bPrime']?.toString() ?? '';
    entry.cController.text = data['c']?.toString() ?? '';
    entry.standardAController.text = data['standardA']?.toString() ?? '';
    entry.standardBController.text = data['standardB']?.toString() ?? '';
    entry.standardCController.text = data['standardC']?.toString() ?? '';
    entry.standardDController.text = data['standardD']?.toString() ?? '';
    entry.measuredDController.text = data['measuredD']?.toString() ?? '';
    entry.remarksController.text = data['remarks']?.toString() ?? '';
    entry.attachments.addAll(parseAttachments(data['attachments']));
    return entry;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chainageKm': chainageKmController.text,
        'chainageM': chainageMController.text,
        'structureType': structureTypeController.text,
        'straightCurve': straightCurveController.text,
        'trackType': trackTypeController.text,
        'cantValue': cant,
        'a': a,
        'xDown': xDown,
        'calculatedA': calculatedA,
        'standardA': parseDouble(standardAController.text),
        'b': b,
        'bPrime': bPrime,
        'calculatedB': calculatedB,
        'standardB': parseDouble(standardBController.text),
        'c': c,
        'xUp': xUp,
        'calculatedC': calculatedC,
        'standardC': parseDouble(standardCController.text),
        'standardD': parseDouble(standardDController.text),
        'measuredD': parseDouble(measuredDController.text),
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'remarks': remarksController.text,
      };

  void dispose() {
    chainageKmController.dispose();
    chainageMController.dispose();
    structureTypeController.dispose();
    straightCurveController.dispose();
    trackTypeController.dispose();
    cantController.dispose();
    aController.dispose();
    bController.dispose();
    bPrimeController.dispose();
    cController.dispose();
    standardAController.dispose();
    standardBController.dispose();
    standardCController.dispose();
    standardDController.dispose();
    measuredDController.dispose();
    remarksController.dispose();
  }
}
