import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/route_names.dart';
import '../../shared/widgets/form_inspection_table_scaffold.dart';
import '../data/t72_table_columns.dart';

class T72TableScreen extends ConsumerWidget {
  const T72TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormInspectionTableScaffold(
      formId: 't7-2',
      formCode: 'Form T-7-2',
      title: 'Form T-7-2',
      subtitle: 'CAM Injected Thickness',
      definition: t72TableDefinition,
      entryRoute: RouteNames.formT72Entry,
    );
  }
}
