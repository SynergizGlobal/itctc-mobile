import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../shared/widgets/form_inspection_table_scaffold.dart';
import '../data/t22_table_columns.dart';

class T22TableScreen extends ConsumerWidget {
  const T22TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormInspectionTableScaffold(
      formId: 't22',
      formCode: 'Form T-22',
      title: 'Form T-22',
      subtitle: 'Buffer Stop (1st GRADE with GRAVEL FILL)',
      definition: t22TableDefinition,
      entryRoute: RouteNames.formT22Entry,
    );
  }
}
