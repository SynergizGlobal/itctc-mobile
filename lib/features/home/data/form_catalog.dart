import '../models/form_info.dart';

class FormCatalog {
  FormCatalog._();

  static const List<FormInfo> allForms = [
    FormInfo(
      id: 'c1',
      code: 'Form C-1',
      title: 'Formation Width Measurement',
      description:
          'Measurement record of formation width for Earth work, Viaduct and Bridge sections.',
      category: FormCategory.civil,
      routePath: '/forms/c1',
      measurementInterval: 'Straight: 100m · Curve: 20m',
    ),
    FormInfo(
      id: 'c7',
      code: 'Form C-7',
      title: 'Noise Barrier Height',
      description:
          'Measurement record of height of noise barrier for Earth work, Viaduct and Bridge sections.',
      category: FormCategory.civil,
      routePath: '/forms/c7',
      measurementInterval: 'Straight: 50m · Curve: 20m',
    ),
    FormInfo(
      id: 't2',
      code: 'Form T-2',
      title: 'Track Irregularity',
      description:
          'Measurement record of finished state of track irregularity for Down and Up lines.',
      category: FormCategory.track,
      routePath: '/forms/t2',
      measurementInterval: 'Per chainage point',
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
