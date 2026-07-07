import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart';

void main() {
  Future<void> pumpUntilSessionReady(
    WidgetTester tester, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 120,
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      await tester.pump(step);
      if (find
              .byKey(const Key('session_drill_player_table_viewport'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('session_drill_player_load_error'))
              .evaluate()
              .isNotEmpty) {
        return;
      }
    }
  }

  SessionDrillItemV1 authoredW5Item(String sessionId, String drillId) {
    final raw = File(
      'content/worlds/world5/v1/sessions/$sessionId/drills/d.$drillId.json',
    ).readAsStringSync();
    final spec = DrillSpecV1.fromJsonString(raw);
    return SessionDrillItemV1(drillId: drillId, spec: spec);
  }

  testWidgets(
    'World 5 structured board context reaches surfaced table source meta',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w5.s04',
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              authoredW5Item(
                'w5.s04',
                'classify_turn_shift_connected_raise_v1',
              ),
            ],
          ),
        ),
      );
      await pumpUntilSessionReady(tester);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_load_error')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('session_drill_player_source_street_v1')),
        findsOneWidget,
      );
      expect(find.text('Street: TURN'), findsOneWidget);
      expect(
        find.byKey(const Key('session_drill_player_source_board_v1')),
        findsOneWidget,
      );
      expect(find.text('Board: Js Td 9c 8h'), findsOneWidget);
      expect(
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
        findsOneWidget,
      );
    },
  );
}
