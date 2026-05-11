import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  SessionDrillItemV1 _item(
    String id, {
    required String prompt,
    required String intent,
    required String expected,
    required String why,
    List<String>? acceptable,
    String? feedbackAcceptable,
    Map<String, String>? feedbackIncorrectByAction,
  }) {
    final acceptableJson = acceptable == null
        ? ''
        : ',"acceptable_actions":[${acceptable.map((a) => '"$a"').join(',')}]';
    final acceptableFeedbackJson = feedbackAcceptable == null
        ? ''
        : ',"feedback_acceptable_v1":"$feedbackAcceptable"';
    final incorrectByActionJson = feedbackIncorrectByAction == null
        ? ''
        : ',"feedback_incorrect_by_action_v1":{${feedbackIncorrectByAction.entries.map((entry) => '"${entry.key}":"${entry.value}"').join(',')}}';
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"action_choice","prompt":"$prompt","intent_v1":"$intent","available_actions_v1":["fold","call","raise"],"expected":{"actionId":"$expected"}$acceptableJson,"error_class":"expected_action_mismatch","why_v1":"$why"$acceptableFeedbackJson$incorrectByActionJson,"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect. Generic fallback."}',
      ),
    );
  }

  testWidgets(
    'action_choice drills use the generic action bar and advance deterministically',
    (tester) async {
      final drills = <SessionDrillItemV1>[
        _item(
          'position_raise',
          prompt: 'Button first-in spot: choose the open default.',
          intent: 'position_ip_advantage',
          expected: 'raise',
          why: 'Button first-in defaults to raise for value and initiative.',
        ),
        _item(
          'oop_fold',
          prompt: 'Weak small blind pressure spot: choose the safer response.',
          intent: 'position_oop_pain',
          expected: 'fold',
          why: 'Weak out-of-position pressure spots collapse to fold.',
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

      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
      );
      await tester.pump();

      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'action_choice soft-pass prefers feedback_acceptable_v1 over generic wording',
    (tester) async {
      final drills = <SessionDrillItemV1>[
        _item(
          'pressure_call_best',
          prompt: 'Facing one open with acceptable price, choose response.',
          intent: 'position_oop_pain',
          expected: 'call',
          acceptable: const <String>['fold'],
          feedbackAcceptable:
              'Acceptable. Folding avoids a bigger mistake, but this price is good enough that calling keeps more value in play.',
          why:
              'Facing one open with a playable hand and a fair price, calling continues cleanly without forcing extra aggression.',
        ),
        _item(
          'pressure_raise_best',
          prompt: 'Facing one open with a strong hand, choose response.',
          intent: 'position_oop_pain',
          expected: 'raise',
          why:
              'Facing one open with a strong hand, raising isolates weaker continues best.',
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

      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_result_soft_pass_info_v1')),
        findsOneWidget,
      );
      expect(
        find.text(
          'Acceptable. Folding avoids a bigger mistake, but this price is good enough that calling keeps more value in play.',
        ),
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
          'Facing one open with a playable hand and a fair price, calling continues cleanly without forcing extra aggression.',
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'action_choice fail prefers feedback_incorrect_by_action_v1 for the chosen wrong action',
    (tester) async {
      final drills = <SessionDrillItemV1>[
        _item(
          'bridge_showdown_best_call',
          prompt: 'Bridge showdown-intent node: choose action.',
          intent: 'position_oop_pain',
          expected: 'call',
          why:
              'A medium-strength hand that already reaches showdown often enough should check instead of turning itself into a thin bluff.',
          feedbackIncorrectByAction: const <String, String>{
            'fold':
                'Incorrect. Folding gives up a medium-strength hand that already reaches showdown often enough, so checking preserves the cheaper showdown path.',
            'raise':
                'Incorrect. Raising turns this medium-strength hand into a thin bluff, so checking is cleaner and preserves showdown value.',
          },
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

      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('session_drill_player_result_fail_detail')),
        findsOneWidget,
      );
      expect(
        find.text('Better line: CALL. RAISE is weaker here.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_fail_why_v1')),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Raising turns this medium-strength hand into a thin bluff',
        ),
        findsOneWidget,
      );
      expect(find.text('Incorrect. Generic fallback.'), findsNothing);
    },
  );
}
