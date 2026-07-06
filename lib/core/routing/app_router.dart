import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/forms/c1/presentation/c1_form_screen.dart';
import '../../features/forms/c1/presentation/c1_table_screen.dart';
import '../../features/forms/c7/presentation/c7_form_screen.dart';
import '../../features/forms/c7/presentation/c7_table_screen.dart';
import '../../features/forms/t2/presentation/t2_form_screen.dart';
import '../../features/forms/t2/presentation/t2_table_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../services/error_handler.dart';
import 'route_names.dart';

int? _parseEditIndex(GoRouterState state) {
  final indexStr = state.uri.queryParameters['index'];
  return indexStr != null ? int.tryParse(indexStr) : null;
}

final appRouter = GoRouter(
  navigatorKey: ErrorHandler.navigatorKey,
  initialLocation: RouteNames.home,
  routes: [
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
