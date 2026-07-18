import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../shared/widgets/form_inspection_table_scaffold.dart';
import '../data/c7_table_columns.dart';

class C7TableScreen extends ConsumerWidget {
  const C7TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormInspectionTableScaffold(
      formId: 'c7',
      formCode: 'Form C-7',
      title: 'Form C-7',
      subtitle: 'Noise Barrier Height',
      definition: c7TableDefinition,
      entryRoute: RouteNames.formC7Entry,
    );
  }
}
