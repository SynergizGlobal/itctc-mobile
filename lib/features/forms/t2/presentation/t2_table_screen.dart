import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../providers/form_table_providers.dart';
import '../../shared/widgets/form_table_scaffold.dart';
import '../data/t2_table_columns.dart';

class T2TableScreen extends ConsumerWidget {
  const T2TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(t2TableProvider);

    return FormTableScaffold(
      title: 'Form T-2',
      subtitle: 'Track Irregularity Measurement',
      definition: t2TableDefinition,
      rows: rows,
      onAdd: () => context.push(RouteNames.formT2Entry),
      onRowTap: (index) => context.push('${RouteNames.formT2Entry}?index=$index'),
    );
  }
}
