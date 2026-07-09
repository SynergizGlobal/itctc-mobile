import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:itctc/core/routing/route_names.dart';
import 'package:itctc/features/forms/c1/data/c1_table_columns.dart';
import 'package:itctc/features/forms/c7/data/c7_table_columns.dart';
import 'package:itctc/features/forms/shared/models/form_table_header.dart';
import 'package:itctc/features/forms/shared/utils/form_table_responsive.dart';
import 'package:itctc/features/forms/shared/widgets/form_data_table.dart';
import 'package:itctc/features/forms/t2/data/t2_table_columns.dart';
import 'package:itctc/features/forms/t7_2/data/t72_table_columns.dart';
import 'package:itctc/features/forms/t8/data/t8_table_columns.dart';
import 'package:itctc/features/forms/t9/data/t9_table_columns.dart';
import 'package:itctc/features/forms/t10/data/t10_table_columns.dart';
import 'package:itctc/features/auth/providers/auth_provider.dart';
import 'package:itctc/main.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) {
            final notifier = AuthNotifier();
            notifier.authenticateForTesting();
            return notifier;
          }),
        ],
        child: const ItctcApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('App loads home screen', (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.text('ITCTC Forms'), findsOneWidget);
  });

  group('FormTableMetrics breakpoints', () {
    test('compact phone uses smaller fonts', () {
      final metrics = FormTableMetrics.fromConstraints(
        const BoxConstraints(maxWidth: 320),
      );

      expect(metrics.isCompact, isTrue);
      expect(metrics.headerFontSize, 9);
    });

    test('medium phone scales columns', () {
      final metrics = FormTableMetrics.fromConstraints(
        const BoxConstraints(maxWidth: 390),
      );

      expect(metrics.isCompact, isFalse);
      expect(metrics.isTablet, isFalse);
    });

    test('tablet uses tablet sizing', () {
      final metrics = FormTableMetrics.fromConstraints(
        const BoxConstraints(maxWidth: 768),
      );

      expect(metrics.isTablet, isTrue);
    });

    test('large screen uses expanded sizing', () {
      final metrics = FormTableMetrics.fromConstraints(
        const BoxConstraints(maxWidth: 1024),
      );

      expect(metrics.columnScale, 1.05);
      expect(metrics.minRowHeight, 52);
    });
  });

  group('FormDataTable responsive layout', () {
    Future<void> pumpTable(
      WidgetTester tester, {
      required Size size,
      required FormTableDefinition definition,
      TargetPlatform platform = TargetPlatform.android,
      List<Map<String, dynamic>> rows = const [],
    }) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: platform),
          home: Scaffold(
            body: SizedBox(
              width: size.width,
              height: size.height,
              child: FormDataTable(
                definition: definition,
                rows: rows,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    const screenSizes = <Size>[
      Size(320, 568), // iPhone SE / small Android
      Size(360, 640), // common Android
      Size(390, 844), // iPhone 14
      Size(768, 1024), // iPad portrait
      Size(1024, 1366), // iPad Pro / large tablet
    ];

    for (final definition in [
      c1TableDefinition,
      c7TableDefinition,
      t2TableDefinition,
      t72TableDefinition,
      t8TableDefinition,
      t9TableDefinition,
      t10TableDefinition,
    ]) {
      for (final size in screenSizes) {
        testWidgets(
          '${definition.columns.length} cols at ${size.width.toInt()}x${size.height.toInt()} (Android)',
          (tester) async {
            await pumpTable(
              tester,
              size: size,
              definition: definition,
              platform: TargetPlatform.android,
            );

            expect(find.byType(FormDataTable), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );

        testWidgets(
          '${definition.columns.length} cols at ${size.width.toInt()}x${size.height.toInt()} (iOS)',
          (tester) async {
            await pumpTable(
              tester,
              size: size,
              definition: definition,
              platform: TargetPlatform.iOS,
            );

            expect(find.byType(FormDataTable), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    testWidgets('shows empty state on narrow C-1 screen', (tester) async {
      await pumpTable(
        tester,
        size: const Size(320, 568),
        definition: c1TableDefinition,
      );

      expect(find.textContaining('No records yet'), findsOneWidget);
    });

    testWidgets('horizontal scroll controller exists on narrow screen', (tester) async {
      await pumpTable(
        tester,
        size: const Size(360, 640),
        definition: t2TableDefinition,
      );

      final horizontalScroll = tester.widget<Scrollable>(
        find.descendant(
          of: find.byType(FormDataTable),
          matching: find.byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.right,
          ),
        ),
      );

      expect(horizontalScroll.controller, isNotNull);
    });

    testWidgets('renders multi-row header on large C-1 screen', (tester) async {
      await pumpTable(
        tester,
        size: const Size(1024, 1366),
        definition: c1TableDefinition,
      );

      expect(find.text('Width value (mm)'), findsOneWidget);
      expect(find.textContaining('Chainage'), findsWidgets);
    });
  });

  testWidgets('C1 table screen navigates without layout overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) {
            final notifier = AuthNotifier();
            notifier.authenticateForTesting();
            return notifier;
          }),
        ],
        child: const ItctcApp(),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.text('ITCTC Forms'));
    GoRouter.of(context).push(RouteNames.formC1);
    await tester.pumpAndSettle();

    expect(find.text('Form C-1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
