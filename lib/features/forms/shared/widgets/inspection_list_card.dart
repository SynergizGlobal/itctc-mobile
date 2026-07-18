import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../inspections/models/inspection_record.dart';
import '../utils/workflow_table_columns.dart';

/// Generic inspection card with status and optional highlight chips.
class InspectionListCard extends ConsumerWidget {
  const InspectionListCard({
    super.key,
    required this.record,
    required this.entryRoute,
    this.highlights = const [],
  });

  final InspectionRecord record;
  final String entryRoute;
  final List<MapEntry<String, String>> highlights;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final row = inspectionToTableRow(record);
    final title = _titleFor(record);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    record.status.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            if (highlights.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final item in highlights.take(6))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.key,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.15,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            item.value,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 2),
            Row(
              children: [
                InspectionRowActions(row: row, entryRoute: entryRoute),
                const Spacer(),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => context.push(
                    RouteNames.inspectionPreview(record.id),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Preview'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _titleFor(InspectionRecord record) {
    final payload = record.payload;
    final km = payload['chainageKm'];
    final m = payload['chainageM'];
    if (km != null || m != null) {
      return 'CH ${km ?? '—'}+${m ?? '—'}';
    }
    final location = payload['location'] ?? payload['station'];
    if (location != null && location.toString().trim().isNotEmpty) {
      return location.toString();
    }
    return record.formCode;
  }
}
