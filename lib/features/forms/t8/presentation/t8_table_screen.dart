import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../providers/form_table_providers.dart';
import '../../shared/widgets/form_table_scaffold.dart';
import '../data/t8_table_columns.dart';

class T8TableScreen extends ConsumerWidget {
  const T8TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(t8TableProvider);

    return FormTableScaffold(
      title: 'Form T-8',
      subtitle: "Sleeper Spacing & Squareness — Solid-bed Track",
      definition: t8TableDefinition,
      rows: rows,
      onAdd: () => context.push(RouteNames.formT8Entry),
      onRowTap: (index) => context.push('${RouteNames.formT8Entry}?index=$index'),
    );
  }
}
