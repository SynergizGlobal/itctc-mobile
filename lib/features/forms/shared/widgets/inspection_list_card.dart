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
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    record.status.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (highlights.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in highlights.take(6))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.key,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            item.value,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                InspectionRowActions(row: row, entryRoute: entryRoute),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.push(
                    RouteNames.inspectionPreview(record.id),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
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
