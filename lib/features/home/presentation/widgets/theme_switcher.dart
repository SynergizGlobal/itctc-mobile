import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_provider.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return PopupMenuButton<ThemeMode>(
      icon: Icon(_iconForMode(themeMode)),
      tooltip: 'Theme',
      onSelected: (mode) => ref.read(themeModeProvider.notifier).setThemeMode(mode),
      itemBuilder: (context) => [
        _buildItem(context, ThemeMode.system, 'System', Icons.brightness_auto_rounded, themeMode),
        _buildItem(context, ThemeMode.light, 'Light', Icons.light_mode_rounded, themeMode),
        _buildItem(context, ThemeMode.dark, 'Dark', Icons.dark_mode_rounded, themeMode),
      ],
    );
  }

  PopupMenuItem<ThemeMode> _buildItem(
    BuildContext context,
    ThemeMode mode,
    String label,
    IconData icon,
    ThemeMode current,
  ) {
    return PopupMenuItem(
      value: mode,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
          if (mode == current) ...[
            const Spacer(),
            Icon(Icons.check_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
          ],
        ],
      ),
    );
  }

  IconData _iconForMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => Icons.light_mode_rounded,
      ThemeMode.dark => Icons.dark_mode_rounded,
      ThemeMode.system => Icons.brightness_auto_rounded,
    };
  }
}
