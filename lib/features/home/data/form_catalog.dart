import '../models/form_info.dart';

class FormCatalog {
  FormCatalog._();

  static const List<FormInfo> allForms = [
    FormInfo(
      id: 'c1',
      code: 'Form C-1',
      title: 'Formation Width Measurement',
      formatName:
          'Measurement record of formation width (Earth work, Viaduct and Bridge section)',
      category: FormCategory.civil,
      routePath: '/forms/c1',
      measurementInterval: 'Straight: 100m · Curve: 20m',
    ),
    FormInfo(
      id: 'c7',
      code: 'Form C-7',
      title: 'Noise Barrier Height',
      formatName:
          'Measurement record of height of noise barrier (Earth work, Viaduct and Bridge section)',
      category: FormCategory.civil,
      routePath: '/forms/c7',
      measurementInterval: 'Straight: 50m · Curve: 20m',
    ),
    FormInfo(
      id: 't2',
      code: 'Form T-2',
      title: 'Track Irregularity',
      formatName: 'Measurement record of Finished state of track Irregularity',
      category: FormCategory.track,
      routePath: '/forms/t2',
      measurementInterval: 'Per chainage point',
    ),
    FormInfo(
      id: 't7-2',
      code: 'Form T-7-2',
      title: 'CAM Injected Thickness',
      formatName: 'Measurement record of CAM injected thickness',
      category: FormCategory.track,
      routePath: '/forms/t7-2',
      measurementInterval: 'Per RC anchor',
    ),
    FormInfo(
      id: 't8',
      code: 'Form T-8',
      title: "Sleeper Spacing & Squareness",
      formatName:
          "Measurement record of Sleeper's spacing and squareness with Synthetic Sleepers",
      category: FormCategory.track,
      routePath: '/forms/t8',
      measurementInterval: 'Per sleeper',
    ),
    FormInfo(
      id: 't9',
      code: 'Form T-9',
      title: 'Synthetic Resin Injection Thickness',
      formatName:
          'Measurement record of Synthetic Resin injection thickness with Synthetic Sleepers',
      category: FormCategory.track,
      routePath: '/forms/t9',
      measurementInterval: 'Per sleeper',
    ),
    FormInfo(
      id: 't10',
      code: 'Form T-10',
      title: 'Fastening Bolt Torque',
      formatName: 'Measurement record of Fastening Bolt with Synthetic Sleepers',
      category: FormCategory.track,
      routePath: '/forms/t10',
      measurementInterval: 'Per sleeper',
    ),
  ];

  static FormInfo? getById(String id) {
    try {
      return allForms.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }
}
