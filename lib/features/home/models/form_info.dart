import 'package:flutter/material.dart';

enum FormCategory {
  civil('Civil Works', Icons.construction_rounded),
  track('Track Works', Icons.train_rounded),
  electrical('Electrical', Icons.electrical_services_rounded),
  signalling('Signalling', Icons.traffic_rounded);

  const FormCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

class FormInfo {
  const FormInfo({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.category,
    required this.routePath,
    this.measurementInterval,
  });

  final String id;
  final String code;
  final String title;
  final String description;
  final FormCategory category;
  final String routePath;
  final String? measurementInterval;
}
