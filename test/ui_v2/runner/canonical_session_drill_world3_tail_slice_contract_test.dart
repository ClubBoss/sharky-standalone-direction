import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launcher_api_v1.dart';

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
    'w3.s07-w3.s14 surface the late World 3 framework tail on the embedded hand-chain seam',
    (tester) async {
      final adapter = const DrillRuntimeAdapterV1();
      final expectedPrompts = <String, String>{
        'w3.s07': 'button with KJo',
        'w3.s08': 'button with QTs',
        'w3.s09': 'button with QJo',
        'w3.s10': 'button with KQs',
      };
      final lateCapstoneStepTwoBestActions = <String, String>{
        'w3.s11': 'raise',
        'w3.s12': 'call',
        'w3.s13': 'raise',
        'w3.s14': 'raise',
      };
      final lateCapstoneStepTwoLegalActions = <String, List<String>>{
        'w3.s11': const <String>['fold', 'call', 'raise'],
        'w3.s12': const <String>['fold', 'call'],
        'w3.s13': const <String>['fold', 'call', 'raise'],
        'w3.s14': const <String>['fold', 'call', 'raise'],
      };
      final allExpectedPrompts = <String, String>{
        ...expectedPrompts,
        ...lateCapstoneStepTwoBestActions,
      };

      for (final entry in allExpectedPrompts.entries) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        final drills = (await tester.runAsync(
          () => adapter.loadSessionDrills(entry.key),
        ))!;

        await tester.pumpWidget(
          MaterialApp(
            home: CanonicalLauncherV1.sessionDrill(
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
        expect(
          find.byKey(const Key('modern_table_scene_board_state')),
          findsOneWidget,
        );
        if (expectedPrompts.containsKey(entry.key)) {
          expect(find.textContaining(entry.value), findsOneWidget);
        } else {
          expect(
            find.byKey(
              const Key('session_drill_player_hand_chain_action_hero_v1'),
            ),
            findsOneWidget,
          );
          expect(
            find.byKey(
              const Key('session_drill_player_hand_chain_action_villain_v1'),
            ),
            findsOneWidget,
          );
          await tester.tap(
            find.byKey(
              const Key('session_drill_player_hand_chain_action_hero_v1'),
            ),
          );
          await tester.pump();
          expect(find.text('Board state · PREFLOP'), findsOneWidget);
        }

        expect(find.text('Board state · PREFLOP'), findsOneWidget);
      }
    },
  );

  testWidgets(
    'w3.s14 late capstone checkpoint completes as a three-step preflop framework chain',
    (tester) async {
      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w3.s14'),
      ))!;

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalLauncherV1.sessionDrill(
            sessionId: 'w3.s14',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );

      expect(
        find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_hero_v1')),
      );
      await tester.pump();

      expect(
        find.textContaining('button and the pot is unopened'),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pump();

      expect(find.text('Board state · PREFLOP'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_fold_v1')),
      );
      await tester.pump();

      expect(find.text('Session complete'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_hand_chain_action_bar_v1')),
        findsNothing,
      );
      expect(find.text('Session complete'), findsOneWidget);
    },
  );
}
