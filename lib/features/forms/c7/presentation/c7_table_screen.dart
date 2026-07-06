import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../providers/form_table_providers.dart';
import '../../shared/widgets/form_table_scaffold.dart';
import '../data/c7_table_columns.dart';

class C7TableScreen extends ConsumerWidget {
  const C7TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(c7TableProvider);

    return FormTableScaffold(
      title: 'Form C-7',
      subtitle: 'Noise Barrier Height Measurement',
      definition: c7TableDefinition,
      rows: rows,
      onAdd: () => context.push(RouteNames.formC7Entry),
      onRowTap: (index) => context.push('${RouteNames.formC7Entry}?index=$index'),
    );
  }
}
