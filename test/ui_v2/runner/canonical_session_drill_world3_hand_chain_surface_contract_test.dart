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
    'w3 early repaired hand-chain sessions surface embedded table state instead of text-only mode',
    (tester) async {
      final adapter = const DrillRuntimeAdapterV1();
      final expectedHeroCards = <String, List<String>>{
        'w3.s01': <String>['A♠', 'K♦'],
        'w3.s07': <String>['K♥', 'J♦'],
      };

      for (final entry in expectedHeroCards.entries) {
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
          find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('modern_table_scene_board_state')),
          findsOneWidget,
        );

        expect(find.text('Board state · PREFLOP'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('modern_table_hero_cards')),
            matching: find.text(entry.value.first),
          ),
          findsOneWidget,
        );
      }
    },
  );

  testWidgets(
    'w3.s07 embedded table follows repaired hand-chain step progression',
    (tester) async {
      final drills = (await tester.runAsync(
        () => const DrillRuntimeAdapterV1().loadSessionDrills('w3.s07'),
      ))!;

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalLauncherV1.sessionDrill(
            sessionId: 'w3.s07',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_hand_chain_table_v1')),
      );

      expect(find.text('K♥'), findsOneWidget);

      await tester.tap(
        find.byKey(
          const Key('session_drill_player_hand_chain_action_raise_v1'),
        ),
      );
      await tester.pump();
      await tester.tap(
        find.byKey(const Key('session_drill_player_hand_chain_action_fold_v1')),
      );
      await tester.pump();

      expect(find.text('8♣'), findsOneWidget);
      expect(find.text('Board state · PREFLOP'), findsOneWidget);
    },
  );
}
