import 'package:flutter/material.dart';

/// Expandable panel for tolerances and other reference blocks on form steps.
class CollapsibleFormPanel extends StatefulWidget {
  const CollapsibleFormPanel({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.expandedMaxHeight = 220,
    this.backgroundColor,
    this.foregroundColor,
    this.margin = EdgeInsets.zero,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;
  final double expandedMaxHeight;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry margin;

  @override
  State<CollapsibleFormPanel> createState() => _CollapsibleFormPanelState();
}

class _CollapsibleFormPanelState extends State<CollapsibleFormPanel> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = widget.backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final fg = widget.foregroundColor ?? theme.colorScheme.onSurface;

    return Padding(
      padding: widget.margin,
      child: Card(
        margin: EdgeInsets.zero,
        color: bg,
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.titleSmall?.copyWith(color: fg),
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: fg.withValues(alpha: 0.85),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
              sizeCurve: Curves.easeInOut,
              crossFadeState:
                  _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(height: 1, color: fg.withValues(alpha: 0.12)),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: widget.expandedMaxHeight),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
