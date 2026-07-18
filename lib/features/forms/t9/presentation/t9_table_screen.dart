import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../shared/widgets/form_inspection_table_scaffold.dart';
import '../data/t9_table_columns.dart';

class T9TableScreen extends ConsumerWidget {
  const T9TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormInspectionTableScaffold(
      formId: 't9',
      formCode: 'Form T-9',
      title: 'Form T-9',
      subtitle: 'Synthetic Resin Injection Thickness — Solid-bed Track',
      definition: t9TableDefinition,
      entryRoute: RouteNames.formT9Entry,
    );
  }
}
