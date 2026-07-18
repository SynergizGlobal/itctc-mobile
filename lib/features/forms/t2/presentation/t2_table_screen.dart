import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../shared/widgets/form_inspection_table_scaffold.dart';
import '../data/t2_table_columns.dart';

class T2TableScreen extends ConsumerWidget {
  const T2TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormInspectionTableScaffold(
      formId: 't2',
      formCode: 'Form T-2',
      title: 'Form T-2',
      subtitle: 'Track Irregularity',
      definition: t2TableDefinition,
      entryRoute: RouteNames.formT2Entry,
    );
  }
}
