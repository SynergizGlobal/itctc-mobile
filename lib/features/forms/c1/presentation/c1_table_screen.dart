import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../shared/widgets/form_inspection_table_scaffold.dart';
import '../data/c1_table_columns.dart';

class C1TableScreen extends ConsumerWidget {
  const C1TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormInspectionTableScaffold(
      formId: 'c1',
      formCode: 'Form C-1',
      title: 'Form C-1',
      subtitle: 'Formation Width — Earthwork / Viaduct / Bridge',
      definition: c1TableDefinition,
      entryRoute: RouteNames.formC1Entry,
    );
  }
}
