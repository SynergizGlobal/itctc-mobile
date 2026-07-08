import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../providers/form_table_providers.dart';
import '../../shared/widgets/form_table_scaffold.dart';
import '../data/t9_table_columns.dart';

class T9TableScreen extends ConsumerWidget {
  const T9TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(t9TableProvider);

    return FormTableScaffold(
      title: 'Form T-9',
      subtitle: 'Synthetic Resin Injection Thickness — Solid-bed Track',
      definition: t9TableDefinition,
      rows: rows,
      onAdd: () => context.push(RouteNames.formT9Entry),
      onRowTap: (index) => context.push('${RouteNames.formT9Entry}?index=$index'),
    );
  }
}
