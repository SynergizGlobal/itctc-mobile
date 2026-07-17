import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../providers/form_table_providers.dart';
import '../../shared/widgets/form_table_scaffold.dart';
import '../data/t21_table_columns.dart';

class T21TableScreen extends ConsumerWidget {
  const T21TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(t21TableProvider);

    return FormTableScaffold(
      title: 'Form T-21',
      subtitle: 'Track Effective Length — Stations & Depots',
      definition: t21TableDefinition,
      rows: rows,
      onAdd: () => context.push(RouteNames.formT21Entry),
      onRowTap: (index) => context.push('${RouteNames.formT21Entry}?index=$index'),
    );
  }
}
