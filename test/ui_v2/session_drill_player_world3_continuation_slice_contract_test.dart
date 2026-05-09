import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> _pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration step = const Duration(milliseconds: 80),
    int maxTicks = 40,
  }) async {
    for (var i = 0; i < maxTicks; i++) {
      await tester.pump(step);
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    fail('Timed out waiting for ${finder.description}');
  }

  testWidgets(
    'w3.s04-w3.s06 surface the continuation framework slice on the embedded hand-chain seam',
    (tester) async {
      final adapter = const DrillRuntimeAdapterV1();
      final expectedPrompts = <String, String>{
        'w3.s04': 'cutoff with QQ',
        'w3.s05': 'button with 99',
        'w3.s06': 'button with ATo',
      };

      for (final entry in expectedPrompts.entries) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        final drills = (await tester.runAsync(
          () => adapter.loadSessionDrills(entry.key),
        ))!;

        await tester.pumpWidget(
          MaterialApp(
            home: SessionDrillPlayerV1Screen(
              sessionId: entry.key,
              debugDrillsOverrideV1: drills,
            ),
          ),
        );
        await _pumpUntilFound(
          tester,
          find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
        );

        expect(
          find.byKey(
            const Key('session_drill_player_hand_chain_action_bar_v1'),
          ),
          findsOneWidget,
        );
        expect(find.byType(ModernTableScreenV1), findsOneWidget);
        expect(
          find.byKey(const Key('modern_table_scene_board_state')),
          findsOneWidget,
        );
        expect(find.textContaining(entry.value), findsOneWidget);

        final table = tester.widget<ModernTableScreenV1>(
          find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
        );
        expect(table.scenarioSpec, isNotNull);
        expect(table.scenarioSpec!.decisionNodeV1.street, Street.preflop);
        expect(
          table.scenarioSpec!.decisionNodeV1.legalActions,
          equals(const <String>['fold', 'call', 'raise']),
        );

        final boardStateLabel = tester.widget<Text>(
          find.byKey(const Key('modern_table_scene_board_state')),
        );
        expect(boardStateLabel.data, 'Board state · PREFLOP');
      }
    },
  );

  testWidgets(
    'w3.s06 mixed checkpoint continuation completes as a three-step preflop framework chain',
    (tester) async {
      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w3.s06'),
      ))!;

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w3.s06',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );

      expect(find.textContaining('button with ATo'), findsOneWidget);
      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pump();

      expect(find.textContaining('button with KTs'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
      );
      await tester.pump();

      expect(find.textContaining('big blind with J8o'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_fold_v1')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_hand_chain_action_bar_v1')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
    },
  );
}
