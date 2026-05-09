import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  Future<void> _pumpUntilSessionReady(
    WidgetTester tester, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 180,
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      await tester.pump(step);
      if (find
          .byKey(const Key('session_drill_player_load_error'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
      if (find
              .byKey(const Key('session_drill_player_table_viewport'))
              .evaluate()
              .isNotEmpty ||
          find.byType(ModernTableScreenV1).evaluate().isNotEmpty) {
        return;
      }
    }
  }

  Future<void> _pumpBounded(
    WidgetTester tester, {
    int ticks = 12,
    Duration step = const Duration(milliseconds: 50),
  }) async {
    for (var i = 0; i < ticks; i++) {
      await tester.pump(step);
    }
  }

  testWidgets(
    'current World 2 surfaced scenario-session class stays usable at phone size without overflow',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      Future<void> openSession(String sessionId) async {
        final drills = (await tester.runAsync(
          () => const DrillRuntimeAdapterV1().loadSessionDrills(sessionId),
        ))!;
        await tester.pumpWidget(
          MaterialApp(
            home: SessionDrillPlayerV1Screen(
              key: ValueKey('session-$sessionId'),
              sessionId: sessionId,
              debugDrillsOverrideV1: drills,
            ),
          ),
        );
        await _pumpUntilSessionReady(tester);
        await _pumpBounded(tester);
        expect(
          find.byKey(const Key('session_drill_player_load_error')),
          findsNothing,
        );
        expect(
          find.byType(CanonicalTerminalSessionDrillSurfacedRunnerV1),
          findsOneWidget,
        );
        expect(find.byType(ModernTableScreenV1), findsOneWidget);
        expect(
          tester
              .getSize(
                find.byKey(const Key('session_drill_player_surfaced_header')),
              )
              .height,
          lessThanOrEqualTo(sessionId == 'w2.s01' ? 82.0 : 88.0),
        );
        expect(
          find.byKey(const Key('session_drill_player_header_title_v1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('session_drill_player_prompt_capsule_v1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('session_drill_player_scene_support_lane_v1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('session_drill_player_status_header')),
          findsNothing,
        );
        expect(
          tester
              .getSize(
                find.byKey(const Key('session_drill_player_table_viewport')),
              )
              .width,
          greaterThanOrEqualTo(380),
        );
        expect(
          tester
              .getTopLeft(
                find.byKey(
                  const Key('session_drill_player_scene_support_lane_v1'),
                ),
              )
              .dy,
          greaterThan(
            tester
                .getBottomLeft(
                  find.byKey(const Key('session_drill_player_table_viewport')),
                )
                .dy,
          ),
        );
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.toolbarHeight, equals(40));
        expect(tester.takeException(), isNull);
      }

      const surfacedScenarioSessionIds = <String>[
        'w2.s01',
        'w2.s02',
        'w2.s03',
        'w2.s04',
        'w2.s06',
        'w2.s07',
        'w2.s08',
        'w2.s09',
        'w2.s10',
        'w2.s11',
        'w2.s12',
        'w2.s13',
        'w2.s14',
      ];
      for (final sessionId in surfacedScenarioSessionIds) {
        await openSession(sessionId);
      }
    },
  );
}
