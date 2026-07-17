import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../providers/form_table_providers.dart';
import '../../shared/widgets/form_table_scaffold.dart';
import '../data/t22_table_columns.dart';

class T22TableScreen extends ConsumerWidget {
  const T22TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(t22TableProvider);

    return FormTableScaffold(
      title: 'Form T-22',
      subtitle: 'Buffer Stop (1st GRADE with GRAVEL FILL)',
      definition: t22TableDefinition,
      rows: rows,
      onAdd: () => context.push(RouteNames.formT22Entry),
      onRowTap: (index) => context.push('${RouteNames.formT22Entry}?index=$index'),
    );
  }
}
