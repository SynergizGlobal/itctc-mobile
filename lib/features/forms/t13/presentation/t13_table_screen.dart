import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../shared/widgets/form_inspection_table_scaffold.dart';
import '../data/t13_table_columns.dart';

class T13TableScreen extends ConsumerWidget {
  const T13TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormInspectionTableScaffold(
      formId: 't13',
      formCode: 'Form T-13',
      title: 'Form T-13',
      subtitle: 'Fouling Mark',
      definition: t13TableDefinition,
      entryRoute: RouteNames.formT13Entry,
    );
  }
}
