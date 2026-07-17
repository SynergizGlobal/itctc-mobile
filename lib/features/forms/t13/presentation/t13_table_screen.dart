import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../providers/form_table_providers.dart';
import '../../shared/widgets/form_table_scaffold.dart';
import '../data/t13_table_columns.dart';

class T13TableScreen extends ConsumerWidget {
  const T13TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(t13TableProvider);

    return FormTableScaffold(
      title: 'Form T-13',
      subtitle: 'Fouling Mark',
      definition: t13TableDefinition,
      rows: rows,
      onAdd: () => context.push(RouteNames.formT13Entry),
      onRowTap: (index) => context.push('${RouteNames.formT13Entry}?index=$index'),
    );
  }
}
