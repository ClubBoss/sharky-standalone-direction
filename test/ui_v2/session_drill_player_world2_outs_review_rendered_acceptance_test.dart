import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart';

void main() {
  Future<void> _pumpBounded(
    WidgetTester tester, {
    int ticks = 12,
    Duration step = const Duration(milliseconds: 50),
  }) async {
    for (var i = 0; i < ticks; i++) {
      await tester.pump(step);
    }
  }

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

  Future<void> _tapVisible(
    WidgetTester tester,
    Finder finder, {
    Duration settle = const Duration(milliseconds: 80),
  }) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump(settle);
  }

  void _expectLeftToRightOrder(
    WidgetTester tester,
    List<Key> keys,
  ) {
    double? previousLeft;
    for (final key in keys) {
      final finder = find.byKey(key);
      expect(finder, findsOneWidget);
      final currentLeft = tester.getRect(finder).left;
      if (previousLeft != null) {
        expect(currentLeft, greaterThan(previousLeft));
      }
      previousLeft = currentLeft;
    }
  }

  SessionDrillItemV1 _outsItem(
    String id, {
    required String prompt,
    required String outs,
    required String why,
    required List<String> heroHoleCards,
    required List<String> boardCards,
    String street = 'flop',
  }) {
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"outs_count_choice_v1","prompt":"$prompt","street_v1":"$street","hero_hole_cards_v1":["${heroHoleCards.join('","')}"],"board_cards_v1":["${boardCards.join('","')}"],"available_actions_v1":["4","8","9","15"],"expected":{"actionId":"$outs"},"error_class":"outs_count_choice_mismatch","why_v1":"$why","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  SessionDrillItemV1 _reviewItem(
    String id, {
    required String expectedAction,
    String texture = 'dry',
    List<String> boardCards = const <String>['As', '7d', '2c'],
  }) {
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"board_texture_classifier_v1","prompt":"Flop A-7-2 rainbow. Choose CALL for the calmer board or RAISE for the more pressure-building board.","street_v1":"flop","board_cards_v1":["${boardCards.join('","')}"],"board_texture_v1":"$texture","available_actions_v1":["call","raise","fold"],"expected_action":"$expectedAction","error_class":"expected_action_mismatch","why_v1":"Read the board texture before you lock in the action.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  testWidgets(
    'w2.s05 direct canonical path keeps review framing and prompt readable above the action surface',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _reviewItem(
          'bridge_review_dry_cheap_continue_v1',
          expectedAction: 'call',
        ),
        _reviewItem(
          'bridge_review_wet_expensive_release_v1',
          expectedAction: 'fold',
          texture: 'wet',
          boardCards: const <String>['Ah', 'Jh', '9c'],
        ),
        _reviewItem(
          'bridge_review_paired_fair_price_continue_v1',
          expectedAction: 'call',
          texture: 'paired',
          boardCards: const <String>['Kd', 'Kc', '4s'],
        ),
        _reviewItem(
          'bridge_review_connected_future_street_release_v1',
          expectedAction: 'fold',
          texture: 'connected',
          boardCards: const <String>['9h', '8c', '7d'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s05',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpBounded(tester, ticks: 20);

      expect(
        find.byKey(const Key('session_drill_player_load_error')),
        findsNothing,
      );

      final surfacedPromptFinder = find.byKey(
        const Key('session_drill_player_prompt_capsule_v1'),
      );
      final reviewCardFinder = find.byKey(
        const Key('session_drill_player_world2_review_intro_card_v1'),
      );
      final promptCardFinder = find.byKey(
        const Key('session_drill_player_text_led_prompt_card_v1'),
      );
      final reviewIntroLineFinder = find.byKey(
        const Key('session_drill_player_world2_review_intro_line_1_v1'),
      );
      final actionBarFinder = find.byKey(
        const Key('session_drill_player_texture_action_bar_v1'),
      );
      final genericPromptFinder = find.byKey(
        const Key('session_drill_player_prompt'),
      );

      expect(surfacedPromptFinder, findsNothing);
      expect(genericPromptFinder, findsOneWidget);
      expect(promptCardFinder, findsOneWidget);
      expect(reviewCardFinder, findsOneWidget);
      expect(reviewIntroLineFinder, findsOneWidget);
      expect(actionBarFinder, findsOneWidget);

      final promptRect = tester.getRect(genericPromptFinder);
      final reviewCardRect = tester.getRect(reviewCardFinder);
      final actionBarRect = tester.getRect(actionBarFinder);

      expect(reviewCardRect.height, greaterThan(44));
      expect(actionBarRect.height, greaterThan(40));
      expect(reviewCardRect.bottom, lessThanOrEqualTo(promptRect.top));
      expect(promptRect.bottom, lessThan(actionBarRect.top));
      expect(actionBarRect.top - promptRect.bottom, greaterThanOrEqualTo(8));
      expect(actionBarRect.top, greaterThan(reviewCardRect.bottom));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'w2.s05 direct canonical review normalizes authored call-raise-fold into fold-call-raise button order',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s05',
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _reviewItem(
                'bridge_review_authored_out_of_order_v1',
                expectedAction: 'call',
              ),
            ],
          ),
        ),
      );
      await _pumpBounded(tester, ticks: 20);

      _expectLeftToRightOrder(tester, const <Key>[
        Key('session_drill_player_texture_fold_v1'),
        Key('session_drill_player_texture_call_v1'),
        Key('session_drill_player_texture_raise_v1'),
      ]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'w2.s05 direct canonical review keeps call-raise subset in call-raise order',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      final subsetItem = SessionDrillItemV1(
        drillId: 'bridge_review_subset_call_raise_v1',
        spec: DrillSpecV1.fromJsonString(
          '{"id":"bridge_review_subset_call_raise_v1","kind":"board_texture_classifier_v1","prompt":"Choose CALL for the calmer board or RAISE for the more pressure-building board.","street_v1":"flop","board_cards_v1":["As","7d","2c"],"board_texture_v1":"dry","available_actions_v1":["raise","call"],"expected_action":"call","error_class":"expected_action_mismatch","why_v1":"Read the board texture before you lock in the action.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s05',
            debugDrillsOverrideV1: <SessionDrillItemV1>[subsetItem],
          ),
        ),
      );
      await _pumpBounded(tester, ticks: 20);

      expect(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
        findsNothing,
      );
      _expectLeftToRightOrder(tester, const <Key>[
        Key('session_drill_player_texture_call_v1'),
        Key('session_drill_player_texture_raise_v1'),
      ]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'w2.s05 direct canonical path keeps incorrect review explanation integrated with the action surface on phone size',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _reviewItem(
          'bridge_review_dry_cheap_continue_v1',
          expectedAction: 'call',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s05',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpBounded(tester, ticks: 20);

      await _tapVisible(
        tester,
        find.byKey(const Key('session_drill_player_texture_raise_v1')),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_result_fail_detail')),
      );

      final failDetailFinder = find.byKey(
        const Key('session_drill_player_result_fail_detail'),
      );
      final failWhyFinder = find.byKey(
        const Key('session_drill_player_result_fail_why_v1'),
      );
      final actionBarFinder = find.byKey(
        const Key('session_drill_player_texture_action_bar_v1'),
      );

      expect(failDetailFinder, findsOneWidget);
      expect(failWhyFinder, findsOneWidget);
      expect(actionBarFinder, findsOneWidget);

      final failDetailRect = tester.getRect(failDetailFinder);
      final failWhyRect = tester.getRect(failWhyFinder);
      final actionBarRect = tester.getRect(actionBarFinder);
      expect(failDetailRect.bottom, lessThanOrEqualTo(failWhyRect.top));
      expect(failDetailRect.bottom, lessThan(actionBarRect.top));
      expect(
        actionBarRect.top - failDetailRect.bottom,
        greaterThanOrEqualTo(8),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'w2.s06 direct canonical path keeps surfaced prompt, outs explanation, and outs action visible together on phone size',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s06',
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _outsItem(
                'count_flush_draw_nine_outs',
                prompt: 'Four-flush on the flop. How many outs?',
                outs: '9',
                why: 'A flush draw usually has 9 outs.',
                heroHoleCards: const <String>['Ah', 'Qh'],
                boardCards: const <String>['Kc', '7h', '2h'],
              ),
            ],
          ),
        ),
      );
      await _pumpBounded(tester, ticks: 20);

      expect(
        find.byKey(const Key('session_drill_player_load_error')),
        findsNothing,
      );

      final surfacedPromptFinder = find.byKey(
        const Key('session_drill_player_prompt_capsule_v1'),
      );
      final tableFinder = find.byKey(
        const Key('session_drill_player_table_viewport'),
      );
      final supportLaneFinder = find.byKey(
        const Key('session_drill_player_scene_support_lane_v1'),
      );
      final introFinder = find.byKey(
        const Key('session_drill_player_world2_outs_intro_supplement_v1'),
      );
      final introBodyFinder = find.byKey(
        const Key('session_drill_player_world2_outs_intro_supplement_v1_body'),
      );
      final outsBarFinder = find.byKey(
        const Key('session_drill_player_outs_count_bar_v1'),
      );

      expect(surfacedPromptFinder, findsOneWidget);
      expect(
        find.byKey(const Key('session_drill_player_prompt')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('modern_table_scene_proof_badge')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('modern_table_scene_proof_badge')),
          matching: find.text('OUTS'),
        ),
        findsOneWidget,
      );
      expect(tableFinder, findsOneWidget);
      expect(supportLaneFinder, findsOneWidget);
      expect(introFinder, findsOneWidget);
      expect(introBodyFinder, findsOneWidget);
      expect(outsBarFinder, findsOneWidget);
      expect(
        find.byKey(const Key('session_drill_player_outs_source_street_v1')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('session_drill_player_outs_source_hero_v1')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('session_drill_player_outs_source_board_v1')),
        findsNothing,
      );

      final promptRect = tester.getRect(surfacedPromptFinder);
      final tableRect = tester.getRect(tableFinder);
      final supportLaneRect = tester.getRect(supportLaneFinder);
      final introRect = tester.getRect(introFinder);
      final outsBarRect = tester.getRect(outsBarFinder);
      expect(promptRect.bottom, lessThan(tableRect.top));
      expect(supportLaneRect.top, greaterThan(tableRect.bottom));
      expect(supportLaneRect.top - tableRect.bottom, greaterThanOrEqualTo(4));
      expect(introRect.height, greaterThan(56));
      expect(introRect.top, greaterThanOrEqualTo(supportLaneRect.top));
      expect(introRect.bottom, lessThan(outsBarRect.top));
      expect(outsBarRect.height, greaterThan(40));
      expect(outsBarRect.top, greaterThanOrEqualTo(supportLaneRect.top));
      expect(outsBarRect.bottom, lessThanOrEqualTo(supportLaneRect.bottom));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'w2.s06 direct canonical path renders corrective outs fail detail and fix line',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s06',
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _outsItem(
                'count_flush_draw_nine_outs',
                prompt: 'Four-flush on the flop. How many outs?',
                outs: '9',
                why: 'A flush draw usually has 9 outs.',
                heroHoleCards: const <String>['Ah', 'Qh'],
                boardCards: const <String>['Kc', '7h', '2h'],
              ),
            ],
          ),
        ),
      );
      await _pumpBounded(tester, ticks: 20);

      await _tapVisible(
        tester,
        find.byKey(const Key('session_drill_player_outs_8_v1')),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(const Key('session_drill_player_result_fail_detail')),
      );

      expect(
        find.text('Better answer: 9 outs. 8 misses this scene.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Notice: A flush draw usually has 9 outs.'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Next time: Count the live improving cards before you answer.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'w2.s05 direct canonical path surfaces review recap above the completion surface after the chain completes',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      final drills = <SessionDrillItemV1>[
        _reviewItem(
          'bridge_review_dry_cheap_continue_v1',
          expectedAction: 'call',
        ),
        _reviewItem(
          'bridge_review_wet_expensive_release_v1',
          expectedAction: 'fold',
          texture: 'wet',
          boardCards: const <String>['Ah', 'Jh', '9c'],
        ),
        _reviewItem(
          'bridge_review_paired_fair_price_continue_v1',
          expectedAction: 'call',
          texture: 'paired',
          boardCards: const <String>['Kd', 'Kc', '4s'],
        ),
        _reviewItem(
          'bridge_review_connected_future_street_release_v1',
          expectedAction: 'fold',
          texture: 'connected',
          boardCards: const <String>['9h', '8c', '7d'],
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s05',
            debugDrillsOverrideV1: drills,
          ),
        ),
      );
      await _pumpBounded(tester, ticks: 20);

      await _tapVisible(
        tester,
        find.byKey(const Key('session_drill_player_texture_call_v1')),
      );
      await _tapVisible(
        tester,
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
      );
      await _tapVisible(
        tester,
        find.byKey(const Key('session_drill_player_texture_call_v1')),
      );
      await _tapVisible(
        tester,
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(
          const Key('session_drill_player_world2_review_recap_card_v1'),
        ),
      );

      final recapFinder = find.byKey(
        const Key('session_drill_player_world2_review_recap_card_v1'),
      );
      final promptCardFinder = find.byKey(
        const Key('session_drill_player_text_led_prompt_card_v1'),
      );
      final completionFinder = find.byKey(
        const Key('session_drill_player_completion_surface_v1'),
      );

      expect(
        find.byKey(const Key('session_drill_player_load_error')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
      expect(promptCardFinder, findsOneWidget);
      expect(recapFinder, findsOneWidget);
      expect(completionFinder, findsOneWidget);

      final recapRect = tester.getRect(recapFinder);
      final completionRect = tester.getRect(completionFinder);
      expect(recapRect.height, greaterThan(44));
      expect(completionRect.height, greaterThan(72));
      expect(recapRect.bottom, lessThan(completionRect.top));
      expect(completionRect.top - recapRect.bottom, greaterThanOrEqualTo(8));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'w2.s06 direct canonical path surfaces outs recap above the completion surface after the outs chain completes',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: CanonicalTerminalSessionDrillSurfacedRunnerV1(
            sessionId: 'w2.s06',
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _outsItem(
                'count_flush_draw_nine_outs',
                prompt: 'Four-flush on the flop. How many outs?',
                outs: '9',
                why: 'A flush draw usually has 9 outs.',
                heroHoleCards: const <String>['Ah', 'Qh'],
                boardCards: const <String>['Kc', '7h', '2h'],
              ),
              _outsItem(
                'count_open_ended_straight_draw_eight_outs',
                prompt: 'Open-ended straight draw. How many outs?',
                outs: '8',
                why: 'An open-ended straight draw usually has 8 outs.',
                heroHoleCards: const <String>['Qc', 'Jd'],
                boardCards: const <String>['Th', '9c', '2d'],
              ),
              _outsItem(
                'count_gutshot_four_outs',
                prompt: 'Gutshot straight draw. How many outs?',
                outs: '4',
                why: 'A gutshot usually has 4 outs.',
                heroHoleCards: const <String>['Qc', 'Jd'],
                boardCards: const <String>['Ah', 'Tc', '2d'],
              ),
            ],
          ),
        ),
      );
      await _pumpBounded(tester, ticks: 20);

      await _tapVisible(
        tester,
        find.byKey(const Key('session_drill_player_outs_9_v1')),
      );
      await _tapVisible(
        tester,
        find.byKey(const Key('session_drill_player_outs_8_v1')),
      );
      await _tapVisible(
        tester,
        find.byKey(const Key('session_drill_player_outs_4_v1')),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(
          const Key('session_drill_player_world2_outs_recap_supplement_v1'),
        ),
      );

      final recapFinder = find.byKey(
        const Key('session_drill_player_world2_outs_recap_supplement_v1'),
      );
      final recapBodyFinder = find.byKey(
        const Key('session_drill_player_world2_outs_recap_supplement_v1_body'),
      );
      final outsBarFinder = find.byKey(
        const Key('session_drill_player_outs_count_bar_v1'),
      );

      expect(
        find.byKey(const Key('session_drill_player_load_error')),
        findsNothing,
      );
      expect(recapFinder, findsOneWidget);
      expect(recapBodyFinder, findsOneWidget);
      expect(outsBarFinder, findsNothing);

      final recapRect = tester.getRect(recapFinder);
      expect(recapRect.height, greaterThan(44));
      expect(tester.takeException(), isNull);
    },
  );
}
