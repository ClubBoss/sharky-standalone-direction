import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/modern_table_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
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

  SessionDrillItemV1 _item(
    String id, {
    required String texture,
    required String expected,
    List<String> acceptable = const <String>[],
    String? why,
  }) {
    final acceptableJson = acceptable.isEmpty
        ? ''
        : ',"acceptable_actions":[${acceptable.map((a) => '"$a"').join(',')}]';
    final whyJson = why == null ? '' : ',"why_v1":"$why"';
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"board_texture_classifier_v1","prompt":"Classify texture and choose action.","board_texture_v1":"$texture","expected_action":"$expected"$acceptableJson,"error_class":"expected_action_mismatch"$whyJson,"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  testWidgets(
    'board_texture_classifier_v1 action bar and expected/acceptable/fail outcomes are deterministic',
    (tester) async {
      final drills = <SessionDrillItemV1>[
        _item(
          'texture_a',
          texture: 'dry',
          expected: 'raise',
          acceptable: const <String>['call'],
          why:
              'Calling is legal, but raising captures more value on dry boards.',
        ),
        _item(
          'texture_b',
          texture: 'wet',
          expected: 'call',
          acceptable: const <String>['fold'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w5.s01',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_texture_action_bar_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_texture_call_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
        findsOneWidget,
      );
      expect(find.byType(ModernTableScreenV1), findsOneWidget);
      expect(
        find.byKey(const Key('modern_table_scene_board_state')),
        findsOneWidget,
      );
      expect(find.text('Board state · FLOP'), findsOneWidget);
      expect(find.textContaining('PREFLOP'), findsNothing);

      final world5Table = tester.widget<ModernTableScreenV1>(
        find.byType(ModernTableScreenV1),
      );
      expect(world5Table.scenarioSpec?.decisionNodeV1.street.name, 'flop');
      expect(
        world5Table.debugBoardCardLabels,
        equals(const <String>['A♠', '7♦', '2♣']),
      );

      // Wrong action => FAIL
      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('session_drill_player_result_fail')),
        findsOneWidget,
      );

      // Acceptable action => soft-pass + why
      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_call_v1')),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('session_drill_player_result_soft_pass_info_v1')),
        findsOneWidget,
      );
      expect(
        find.text('CALL works, but RAISE is the stronger line here.'),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_result_soft_pass_reason_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Calling is legal, but raising captures more value on dry boards.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'repaired World 5 sessions surface embedded table state without PREFLOP fallback',
    (tester) async {
      final expectedStreetBySession = <String, String>{
        'w5.s03': 'FLOP',
        'w5.s05': 'RIVER',
        'w5.s06': 'FLOP',
        'w5.s07': 'FLOP',
        'w5.s09': 'FLOP',
        'w5.s10': 'FLOP',
      };

      for (final entry in expectedStreetBySession.entries) {
        final drills = (await tester.runAsync(
          () => const DrillRuntimeAdapterV1().loadSessionDrills(entry.key),
        ))!;

        await tester.pumpWidget(
          MaterialApp(
            home: SessionDrillPlayerV1Screen(
              sessionId: entry.key,
              debugDrillsOverrideV1: drills,
            ),
          ),
        );
        await _pumpUntilFound(tester, find.byType(ModernTableScreenV1));

        expect(find.byType(ModernTableScreenV1), findsOneWidget);
        expect(
          find.byKey(const Key('modern_table_scene_board_state')),
          findsOneWidget,
        );

        final table = tester.widget<ModernTableScreenV1>(
          find.byType(ModernTableScreenV1),
        );
        expect(
          table.scenarioSpec?.decisionNodeV1.street.name.toUpperCase(),
          entry.value,
        );
        final boardStateLabel = tester.widget<Text>(
          find.byKey(const Key('modern_table_scene_board_state')),
        );
        expect(boardStateLabel.data, contains(entry.value));
        expect(boardStateLabel.data, isNot(contains('PREFLOP')));
      }
    },
  );
}
