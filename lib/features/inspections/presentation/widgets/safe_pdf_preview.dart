import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// PDF page preview that avoids [PdfPreview]'s known mid-raster list race.
class SafePdfPreview extends StatefulWidget {
  const SafePdfPreview({
    super.key,
    required this.bytes,
    required this.fileName,
    this.maxPageWidth = 720,
    this.backgroundColor,
    this.actionBarColor,
    this.actionIconColor,
    this.onPrintError,
  });

  final Uint8List bytes;
  final String fileName;
  final double maxPageWidth;
  final Color? backgroundColor;
  final Color? actionBarColor;
  final Color? actionIconColor;
  final void Function(Object error)? onPrintError;

  @override
  State<SafePdfPreview> createState() => _SafePdfPreviewState();
}

class _SafePdfPreviewState extends State<SafePdfPreview> {
  final List<MemoryImage> _pages = [];
  var _generation = 0;
  var _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _raster();
    });
  }

  @override
  void didUpdateWidget(covariant SafePdfPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.bytes, widget.bytes)) {
      _raster();
    }
  }

  @override
  void dispose() {
    _generation++;
    for (final page in _pages) {
      page.evict();
    }
    _pages.clear();
    super.dispose();
  }

  Future<void> _raster() async {
    final generation = ++_generation;
    for (final page in _pages) {
      page.evict();
    }
    _pages.clear();

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final dpi = (72.0 * dpr).clamp(96.0, 144.0);

      await for (final page in Printing.raster(
        widget.bytes,
        dpi: dpi,
      )) {
        if (!mounted || generation != _generation) return;

        final png = await page.toPng();
        if (!mounted || generation != _generation) return;

        // Append only — never assign by index (avoids PdfPreview race).
        setState(() {
          _pages.add(MemoryImage(png));
          _loading = false;
        });
      }

      if (!mounted || generation != _generation) return;
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _print() async {
    try {
      await Printing.layoutPdf(
        onLayout: (_) async => widget.bytes,
        name: widget.fileName,
      );
    } catch (error) {
      widget.onPrintError?.call(error);
    }
  }

  Future<void> _share() async {
    try {
      await Printing.sharePdf(
        bytes: widget.bytes,
        filename: widget.fileName,
      );
    } catch (error) {
      widget.onPrintError?.call(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background =
        widget.backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final barColor = widget.actionBarColor ?? theme.colorScheme.surface;
    final iconColor = widget.actionIconColor ?? theme.colorScheme.onSurface;

    return Column(
      children: [
        Expanded(
          child: ColoredBox(
            color: background,
            child: _buildPages(theme),
          ),
        ),
        Material(
          color: barColor,
          elevation: 1,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Print',
                    onPressed: _pages.isEmpty ? null : _print,
                    icon: Icon(Icons.print_outlined, color: iconColor),
                  ),
                  IconButton(
                    tooltip: 'Share',
                    onPressed: _pages.isEmpty ? null : _share,
                    icon: Icon(Icons.share_outlined, color: iconColor),
                  ),
                  const Spacer(),
                  if (_loading && _pages.isNotEmpty)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (_pages.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${_pages.length} page${_pages.length == 1 ? '' : 's'}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPages(ThemeData theme) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not show preview:\n$_error',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_loading && _pages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Preparing preview…'),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > widget.maxPageWidth
            ? widget.maxPageWidth
            : constraints.maxWidth - 24;

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          itemCount: _pages.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return Center(
              child: Container(
                width: width,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image(
                  image: _pages[index],
                  width: width,
                  fit: BoxFit.fitWidth,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
