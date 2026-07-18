import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../shared/widgets/form_inspection_table_scaffold.dart';
import '../data/t10_table_columns.dart';

class T10TableScreen extends ConsumerWidget {
  const T10TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormInspectionTableScaffold(
      formId: 't10',
      formCode: 'Form T-10',
      title: 'Form T-10',
      subtitle: 'Fastening Bolt Torque — Solid-bed Track',
      definition: t10TableDefinition,
      entryRoute: RouteNames.formT10Entry,
    );
  }
}
