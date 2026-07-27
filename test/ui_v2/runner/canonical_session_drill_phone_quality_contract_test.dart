import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';

void main() {
  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    for (var tick = 0; tick < 100; tick++) {
      await tester.pump(const Duration(milliseconds: 80));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('Timed out waiting for ${finder.description}');
  }

  void setPhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
  }

  testWidgets(
    'canonical launcher keeps World 2 live seat context and support lanes readable on phone',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      setPhoneViewport(tester);
      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w2.s02'),
      ))!;

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalLauncherV1.sessionDrill(
            sessionId: 'w2.s02',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_table_viewport')),
      );
      await tester.pumpAndSettle();

      final prompt = tester.getRect(
        find.byKey(const Key('session_drill_player_prompt_capsule_v1')),
      );
      final table = tester.getRect(
        find.byKey(const Key('session_drill_player_table_viewport')),
      );
      final marker = find.byKey(const Key('modern_table_seat_marker_0'));
      final acting = find.byKey(const Key('modern_table_seat_action_marker_0'));

      expect(prompt.bottom, lessThan(table.top));
      expect(marker, findsOneWidget);
      expect(
        find.descendant(of: marker, matching: find.text('BTN')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('modern_table_seat_marker_1')),
        findsOneWidget,
      );
      expect(acting, findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'canonical launcher keeps World 9 spatial seat truth dominant on phone',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      setPhoneViewport(tester);
      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w9.s05'),
      ))!;

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalLauncherV1.sessionDrill(
            sessionId: 'w9.s05',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_spatial_table_v1')),
      );
      await tester.pumpAndSettle();

      final target = find.byKey(const Key('modern_table_seat_marker_1'));
      expect(target, findsOneWidget);
      expect(
        find.descendant(of: target, matching: find.text('S2')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
