import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../providers/form_table_providers.dart';
import '../../shared/widgets/form_table_scaffold.dart';
import '../data/c1_table_columns.dart';

class C1TableScreen extends ConsumerWidget {
  const C1TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(c1TableProvider);

    return FormTableScaffold(
      title: 'Form C-1',
      subtitle: 'Formation Width Measurement',
      definition: c1TableDefinition,
      rows: rows,
      onAdd: () => context.push(RouteNames.formC1Entry),
      onRowTap: (index) => context.push('${RouteNames.formC1Entry}?index=$index'),
    );
  }
}
