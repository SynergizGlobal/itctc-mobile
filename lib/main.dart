import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/services/error_handler.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/widgets/keyboard_dismiss.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorHandler.initialize();
  runApp(const ProviderScope(child: ItctcApp()));
}

class ItctcApp extends ConsumerWidget {
  const ItctcApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'ITCTC Forms',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return KeyboardDismissScope(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
