import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/preferences/inspection_list_view_mode.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_bar_title.dart';
import '../../../../core/widgets/keyboard_dismiss.dart';
import '../../../auth/models/user_role.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../inspections/models/inspection_record.dart';
import '../../../inspections/providers/inspection_store_provider.dart';
import '../models/form_table_column.dart';
import '../models/form_table_header.dart';
import '../utils/form_table_theme.dart';
import '../utils/inspection_list_highlights.dart';
import '../utils/workflow_table_columns.dart';
import 'form_data_table.dart';
import 'inspection_list_card.dart';
import 'inspection_record_count_bar.dart';

/// Shared table/card host for inspection-backed form lists.
class FormInspectionTableScaffold extends ConsumerStatefulWidget {
  const FormInspectionTableScaffold({
    super.key,
    required this.formId,
    required this.formCode,
    required this.title,
    required this.subtitle,
    required this.definition,
    required this.entryRoute,
  });

  final String formId;
  final String formCode;
  final String title;
  final String subtitle;
  final FormTableDefinition definition;
  final String entryRoute;

  @override
  ConsumerState<FormInspectionTableScaffold> createState() =>
      _FormInspectionTableScaffoldState();
}

class _FormInspectionTableScaffoldState
    extends ConsumerState<FormInspectionTableScaffold> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocus;
  bool _searchOpen = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<InspectionRecord> _filter(List<InspectionRecord> source) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return source;
    return source.where((record) => _matches(record, q)).toList(growable: false);
  }

  bool _matches(InspectionRecord record, String q) {
    final haystack = [
      record.id,
      record.status.label,
      record.status.apiCode,
      record.createdByUsername,
      record.title,
      record.formCode,
      record.payload['chainageKm']?.toString(),
      record.payload['chainageM']?.toString(),
      record.payload['trackType']?.toString(),
      record.payload['location']?.toString(),
      record.payload['station']?.toString(),
      if (record.payload['chainageKm'] != null ||
          record.payload['chainageM'] != null)
        'ch ${record.payload['chainageKm']}+${record.payload['chainageM']}',
    ].whereType<String>().map((s) => s.toLowerCase());

    return haystack.any((value) => value.contains(q));
  }

  void _openSearch() {
    setState(() => _searchOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    _searchFocus.unfocus();
    _searchController.clear();
    setState(() {
      _searchOpen = false;
      _query = '';
    });
  }

  void _clearQuery() {
    _searchController.clear();
    setState(() => _query = '');
    _searchFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;
    final listMode = ref.watch(inspectionListViewModeProvider);
    final inspections =
        _filter(ref.watch(formInspectionsProvider(widget.formId)));
    final rows = inspections.map(inspectionToTableRow).toList();
    final tableDefinition = withWorkflowColumns(
      widget.definition,
      entryRoute: widget.entryRoute,
    );
    final canAdd = user?.role == UserRole.inspector;
    final hasQuery = _query.trim().isNotEmpty;

    return PopScope(
      canPop: !_searchOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _searchOpen) _closeSearch();
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: _searchOpen ? 0 : null,
          title: _searchOpen
              ? TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  textInputAction: TextInputAction.search,
                  onTapOutside: KeyboardDismiss.onTapOutside,
                  onChanged: (value) => setState(() => _query = value),
                  style: AppTheme.appBarTitleStyle(theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search inspections…',
                    hintStyle: AppTheme.appBarSubtitleStyle(
                      theme.colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    suffixIcon: hasQuery
                        ? IconButton(
                            tooltip: 'Clear',
                            onPressed: _clearQuery,
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                  ),
                )
              : AppBarTitleBlock(
                  title: widget.title,
                  subtitle: widget.subtitle,
                ),
          actions: [
            if (!_searchOpen)
              IconButton(
                tooltip: 'Search',
                onPressed: _openSearch,
                icon: const Icon(Icons.search_rounded),
              ),
          ],
        ),
        body: listMode == InspectionListViewMode.table
            ? FormDataTable(
                definition: tableDefinition,
                rows: rows,
                emptyMessage: hasQuery
                    ? 'No inspections match your search.'
                    : canAdd
                        ? 'No inspections yet.\nTap Add Inspection to start.'
                        : 'No inspections available for review yet.',
              )
            : _CardsBody(
                columns: widget.definition.columns,
                inspections: inspections,
                entryRoute: widget.entryRoute,
                canAdd: canAdd,
                hasQuery: hasQuery,
              ),
        bottomNavigationBar: canAdd
            ? Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: FormTableTheme.border(context)),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.push(widget.entryRoute),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Add Inspection'),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _CardsBody extends StatelessWidget {
  const _CardsBody({
    required this.columns,
    required this.inspections,
    required this.entryRoute,
    required this.canAdd,
    required this.hasQuery,
  });

  final List<FormTableColumn> columns;
  final List<InspectionRecord> inspections;
  final String entryRoute;
  final bool canAdd;
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (inspections.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            hasQuery
                ? 'No inspections match your search.'
                : canAdd
                    ? 'No inspections yet.\nTap Add Inspection to start.'
                    : 'No inspections available for review yet.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: inspections.length,
            itemBuilder: (context, index) {
              final record = inspections[index];
              final row = inspectionToTableRow(record);
              return InspectionListCard(
                record: record,
                entryRoute: entryRoute,
                highlights: buildInspectionHighlights(
                  columns: columns,
                  row: row,
                ),
              );
            },
          ),
        ),
        InspectionRecordCountBar(count: inspections.length),
      ],
    );
  }
}

Future<void> saveFormInspection({
  required WidgetRef ref,
  required BuildContext context,
  required String formId,
  required String formCode,
  required String title,
  required Map<String, dynamic> payload,
  String? inspectionId,
  required bool submitForReview,
}) async {
  final user = ref.read(authProvider).user;
  if (user == null) return;

  if (user.role != UserRole.inspector) {
    await DialogService.showError(
      title: 'Not allowed',
      message: 'Only Inspectors can create or edit inspection form data.',
    );
    return;
  }

  try {
    ref.read(inspectionStoreProvider.notifier).saveInspectorEntry(
          inspector: user,
          formId: formId,
          formCode: formCode,
          title: title,
          payload: payload,
          inspectionId: inspectionId,
          submitForReview: submitForReview,
        );

    if (!context.mounted) return;
    await DialogService.showSuccess(
      title: submitForReview ? 'Submitted for Review' : 'Draft Saved',
      message: submitForReview
          ? '$formCode has been submitted to PMC.'
          : '$formCode draft is saved locally.',
    );
    if (context.mounted) context.pop();
  } catch (e) {
    await DialogService.showError(
      title: 'Save failed',
      message: e.toString(),
    );
  }
}

InspectionRecord? findInspection(WidgetRef ref, String? inspectionId) {
  if (inspectionId == null) return null;
  return ref.read(inspectionByIdProvider(inspectionId));
}
