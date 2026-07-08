import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../providers/form_table_providers.dart';
import '../../shared/widgets/form_table_scaffold.dart';
import '../data/t10_table_columns.dart';

class T10TableScreen extends ConsumerWidget {
  const T10TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(t10TableProvider);

    return FormTableScaffold(
      title: 'Form T-10',
      subtitle: 'Fastening Bolt Torque — Solid-bed Track',
      definition: t10TableDefinition,
      rows: rows,
      onAdd: () => context.push(RouteNames.formT10Entry),
      onRowTap: (index) => context.push('${RouteNames.formT10Entry}?index=$index'),
    );
  }
}
