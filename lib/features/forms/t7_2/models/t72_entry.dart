import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/form_calculations.dart';
import '../../../../core/utils/validators.dart';
import '../../shared/models/form_attachment.dart';
import '../../shared/models/form_site_capture.dart';
import '../../shared/widgets/solid_bed_fields.dart';

class T72Entry {
  T72Entry({String? id})
      : id = id ?? const Uuid().v4(),
        rcAnchorSerialController = TextEditingController(),
        chainageKmController = TextEditingController(),
        chainageMController = TextEditingController(),
        slabNumberController = TextEditingController(),
        slabTypeController = TextEditingController(),
        resinOriginController = TextEditingController(),
        resinEndController = TextEditingController(),
        cam1Controller = TextEditingController(),
        cam2Controller = TextEditingController(),
        cam3Controller = TextEditingController(),
        cam4Controller = TextEditingController(),
        cam5Controller = TextEditingController(),
        cam6Controller = TextEditingController(),
        cam7Controller = TextEditingController(),
        cam8Controller = TextEditingController(),
        gapOriginController = TextEditingController(),
        gapEndController = TextEditingController(),
        pinOriginController = TextEditingController(),
        pinEndController = TextEditingController(),
        remarksController = TextEditingController();

  final String id;
  final TextEditingController rcAnchorSerialController;
  final TextEditingController chainageKmController;
  final TextEditingController chainageMController;
  final TextEditingController slabNumberController;
  final TextEditingController slabTypeController;
  final TextEditingController resinOriginController;
  final TextEditingController resinEndController;
  final TextEditingController cam1Controller;
  final TextEditingController cam2Controller;
  final TextEditingController cam3Controller;
  final TextEditingController cam4Controller;
  final TextEditingController cam5Controller;
  final TextEditingController cam6Controller;
  final TextEditingController cam7Controller;
  final TextEditingController cam8Controller;
  final TextEditingController gapOriginController;
  final TextEditingController gapEndController;
  final TextEditingController pinOriginController;
  final TextEditingController pinEndController;
  final TextEditingController remarksController;
  final FormSiteCapture siteCapture = FormSiteCapture();
  final List<FormAttachment> attachments = [];

  TrackDirection direction = TrackDirection.up;

  double get resinOrigin => parseDouble(resinOriginController.text) ?? 0;
  double get resinEnd => parseDouble(resinEndController.text) ?? 0;

  List<double> get _camValues => [
        parseDouble(cam1Controller.text) ?? 0,
        parseDouble(cam2Controller.text) ?? 0,
        parseDouble(cam3Controller.text) ?? 0,
        parseDouble(cam4Controller.text) ?? 0,
        parseDouble(cam5Controller.text) ?? 0,
        parseDouble(cam6Controller.text) ?? 0,
        parseDouble(cam7Controller.text) ?? 0,
        parseDouble(cam8Controller.text) ?? 0,
      ];

  double get camAverage => FormCalculations.calculateAverage(_camValues);

  String get resinOriginDisplay =>
      FormCalculations.formatResinThicknessDisplay(resinOrigin);

  String get resinEndDisplay => FormCalculations.formatResinThicknessDisplay(resinEnd);

  String rowLabel(int index) {
    final serial = rcAnchorSerialController.text.trim();
    if (serial.isEmpty) return 'Row ${index + 1}';
    return 'Row ${index + 1} · RC $serial';
  }

  factory T72Entry.fromMap(Map<String, dynamic> data) {
    final entry = T72Entry(id: data['id'] as String?);
    entry.direction = TrackDirectionX.fromStored(data['direction']?.toString());
    entry.rcAnchorSerialController.text = data['rcAnchorSerial']?.toString() ?? '';
    entry.chainageKmController.text = data['chainageKm']?.toString() ?? '';
    entry.chainageMController.text = data['chainageM']?.toString() ?? '';
    entry.slabNumberController.text = data['slabNumber']?.toString() ?? '';
    entry.slabTypeController.text = data['slabType']?.toString() ?? '';
    entry.resinOriginController.text = data['resinOrigin']?.toString() ?? '';
    entry.resinEndController.text = data['resinEnd']?.toString() ?? '';
    entry.cam1Controller.text = data['cam1']?.toString() ?? '';
    entry.cam2Controller.text = data['cam2']?.toString() ?? '';
    entry.cam3Controller.text = data['cam3']?.toString() ?? '';
    entry.cam4Controller.text = data['cam4']?.toString() ?? '';
    entry.cam5Controller.text = data['cam5']?.toString() ?? '';
    entry.cam6Controller.text = data['cam6']?.toString() ?? '';
    entry.cam7Controller.text = data['cam7']?.toString() ?? '';
    entry.cam8Controller.text = data['cam8']?.toString() ?? '';
    entry.gapOriginController.text = data['gapOrigin']?.toString() ?? '';
    entry.gapEndController.text = data['gapEnd']?.toString() ?? '';
    entry.pinOriginController.text = data['pinOrigin']?.toString() ?? '';
    entry.pinEndController.text = data['pinEnd']?.toString() ?? '';
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
        'rcAnchorSerial': rcAnchorSerialController.text,
        'chainageKm': chainageKmController.text,
        'chainageM': chainageMController.text,
        'slabNumber': slabNumberController.text,
        'slabType': slabTypeController.text,
        'resinOrigin': resinOrigin,
        'resinEnd': resinEnd,
        'resinOriginDisplay': resinOriginDisplay,
        'resinEndDisplay': resinEndDisplay,
        'cam1': parseDouble(cam1Controller.text),
        'cam2': parseDouble(cam2Controller.text),
        'cam3': parseDouble(cam3Controller.text),
        'cam4': parseDouble(cam4Controller.text),
        'cam5': parseDouble(cam5Controller.text),
        'cam6': parseDouble(cam6Controller.text),
        'cam7': parseDouble(cam7Controller.text),
        'cam8': parseDouble(cam8Controller.text),
        'camAverage': camAverage,
        'gapOrigin': parseDouble(gapOriginController.text),
        'gapEnd': parseDouble(gapEndController.text),
        'pinOrigin': pinOriginController.text,
        'pinEnd': pinEndController.text,
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'siteCapture': siteCapture.toJson(),
        'remarks': remarksController.text,
      };

  void dispose() {
    rcAnchorSerialController.dispose();
    chainageKmController.dispose();
    chainageMController.dispose();
    slabNumberController.dispose();
    slabTypeController.dispose();
    resinOriginController.dispose();
    resinEndController.dispose();
    cam1Controller.dispose();
    cam2Controller.dispose();
    cam3Controller.dispose();
    cam4Controller.dispose();
    cam5Controller.dispose();
    cam6Controller.dispose();
    cam7Controller.dispose();
    cam8Controller.dispose();
    gapOriginController.dispose();
    gapEndController.dispose();
    pinOriginController.dispose();
    pinEndController.dispose();
    remarksController.dispose();
  }
}
