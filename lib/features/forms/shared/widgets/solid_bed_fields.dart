import 'package:flutter/material.dart';

import 'collapsible_form_panel.dart';

enum TrackDirection { up, down }

extension TrackDirectionX on TrackDirection {
  String get label => this == TrackDirection.up ? 'Up' : 'Down';

  static TrackDirection fromStored(String? value) {
    return value?.toLowerCase() == 'down' ? TrackDirection.down : TrackDirection.up;
  }
}

class UpDownSelector extends StatelessWidget {
  const UpDownSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TrackDirection value;
  final ValueChanged<TrackDirection> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Up / Down', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<TrackDirection>(
          segments: const [
            ButtonSegment(value: TrackDirection.up, label: Text('Up')),
            ButtonSegment(value: TrackDirection.down, label: Text('Down')),
          ],
          selected: {value},
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ],
    );
  }
}

class SolidBedChainageFields extends StatelessWidget {
  const SolidBedChainageFields({
    super.key,
    required this.kmController,
    required this.mController,
    required this.cmController,
    this.onChanged,
  });

  final TextEditingController kmController;
  final TextEditingController mController;
  final TextEditingController cmController;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: kmController,
            decoration: const InputDecoration(labelText: 'Chainage (km)', hintText: '0'),
            keyboardType: TextInputType.number,
            onChanged: (_) => onChanged?.call(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: mController,
            decoration: const InputDecoration(labelText: 'Chainage (m)', hintText: '000'),
            keyboardType: TextInputType.number,
            onChanged: (_) => onChanged?.call(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: cmController,
            decoration: const InputDecoration(labelText: 'Chainage (cm)', hintText: '00'),
            keyboardType: TextInputType.number,
            onChanged: (_) => onChanged?.call(),
          ),
        ),
      ],
    );
  }
}

class FormToleranceBanner extends StatelessWidget {
  const FormToleranceBanner({
    super.key,
    required this.items,
    this.note,
    this.initiallyExpanded = false,
    this.expandedMaxHeight = 220,
  });

  final List<String> items;
  final String? note;
  final bool initiallyExpanded;
  final double expandedMaxHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CollapsibleFormPanel(
      title: 'Tolerances',
      initiallyExpanded: initiallyExpanded,
      expandedMaxHeight: expandedMaxHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(item, style: theme.textTheme.bodySmall),
            ),
          ),
          if (note != null) ...[
            const SizedBox(height: 4),
            Text(
              note!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
