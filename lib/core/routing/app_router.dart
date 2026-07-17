import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/models/auth_state.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/forms/c1/presentation/c1_form_screen.dart';
import '../../features/forms/c1/presentation/c1_table_screen.dart';
import '../../features/forms/c7/presentation/c7_form_screen.dart';
import '../../features/forms/c7/presentation/c7_table_screen.dart';
import '../../features/forms/t2/presentation/t2_form_screen.dart';
import '../../features/forms/t2/presentation/t2_table_screen.dart';
import '../../features/forms/t7_2/presentation/t72_form_screen.dart';
import '../../features/forms/t7_2/presentation/t72_table_screen.dart';
import '../../features/forms/t8/presentation/t8_form_screen.dart';
import '../../features/forms/t8/presentation/t8_table_screen.dart';
import '../../features/forms/t9/presentation/t9_form_screen.dart';
import '../../features/forms/t9/presentation/t9_table_screen.dart';
import '../../features/forms/t10/presentation/t10_form_screen.dart';
import '../../features/forms/t10/presentation/t10_table_screen.dart';
import '../../features/forms/t13/presentation/t13_form_screen.dart';
import '../../features/forms/t13/presentation/t13_table_screen.dart';
import '../../features/forms/t21/presentation/t21_form_screen.dart';
import '../../features/forms/t21/presentation/t21_table_screen.dart';
import '../../features/forms/t22/presentation/t22_form_screen.dart';
import '../../features/forms/t22/presentation/t22_table_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../services/error_handler.dart';
import 'route_names.dart';

int? _parseEditIndex(GoRouterState state) {
  final indexStr = state.uri.queryParameters['index'];
  return indexStr != null ? int.tryParse(indexStr) : null;
}

final _routerRefreshProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.listen<AuthState>(authProvider, (_, _) => notifier.value++);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  final refresh = ref.watch(_routerRefreshProvider);

  return GoRouter(
    navigatorKey: ErrorHandler.navigatorKey,
    initialLocation: RouteNames.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isSplash = location == RouteNames.splash;
      final isLogin = location == RouteNames.login;

      if (!auth.isBootstrapped) {
        return isSplash ? null : RouteNames.splash;
      }

      if (!auth.isAuthenticated) {
        return isLogin ? null : RouteNames.login;
      }

      if (isSplash || isLogin) {
        return RouteNames.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.formC1,
        builder: (context, state) => const C1TableScreen(),
        routes: [
          GoRoute(
            path: 'entry',
            builder: (context, state) => C1FormScreen(editIndex: _parseEditIndex(state)),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.formC7,
        builder: (context, state) => const C7TableScreen(),
        routes: [
          GoRoute(
            path: 'entry',
            builder: (context, state) => C7FormScreen(editIndex: _parseEditIndex(state)),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.formT2,
        builder: (context, state) => const T2TableScreen(),
        routes: [
          GoRoute(
            path: 'entry',
            builder: (context, state) => T2FormScreen(editIndex: _parseEditIndex(state)),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.formT72,
        builder: (context, state) => const T72TableScreen(),
        routes: [
          GoRoute(
            path: 'entry',
            builder: (context, state) => T72FormScreen(editIndex: _parseEditIndex(state)),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.formT8,
        builder: (context, state) => const T8TableScreen(),
        routes: [
          GoRoute(
            path: 'entry',
            builder: (context, state) => T8FormScreen(editIndex: _parseEditIndex(state)),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.formT9,
        builder: (context, state) => const T9TableScreen(),
        routes: [
          GoRoute(
            path: 'entry',
            builder: (context, state) => T9FormScreen(editIndex: _parseEditIndex(state)),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.formT10,
        builder: (context, state) => const T10TableScreen(),
        routes: [
          GoRoute(
            path: 'entry',
            builder: (context, state) => T10FormScreen(editIndex: _parseEditIndex(state)),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.formT13,
        builder: (context, state) => const T13TableScreen(),
        routes: [
          GoRoute(
            path: 'entry',
            builder: (context, state) => T13FormScreen(editIndex: _parseEditIndex(state)),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.formT21,
        builder: (context, state) => const T21TableScreen(),
        routes: [
          GoRoute(
            path: 'entry',
            builder: (context, state) => T21FormScreen(editIndex: _parseEditIndex(state)),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.formT22,
        builder: (context, state) => const T22TableScreen(),
        routes: [
          GoRoute(
            path: 'entry',
            builder: (context, state) => T22FormScreen(editIndex: _parseEditIndex(state)),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text('Route not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
