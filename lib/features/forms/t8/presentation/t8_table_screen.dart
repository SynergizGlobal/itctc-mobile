import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../shared/widgets/form_inspection_table_scaffold.dart';
import '../data/t8_table_columns.dart';

class T8TableScreen extends ConsumerWidget {
  const T8TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormInspectionTableScaffold(
      formId: 't8',
      formCode: 'Form T-8',
      title: 'Form T-8',
      subtitle: 'Sleeper Spacing & Squareness — Solid-bed Track',
      definition: t8TableDefinition,
      entryRoute: RouteNames.formT8Entry,
    );
  }
}
