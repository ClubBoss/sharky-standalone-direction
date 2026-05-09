import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/canonical/progression_handoff_context_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  SessionDrillItemV1 _item(String id, {required String expected}) {
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"board_texture_classifier_v1","prompt":"Classify texture and choose action.","board_texture_v1":"dry","expected_action":"$expected","error_class":"expected_action_mismatch","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  SessionDrillItemV1 _initiativeItem(String id, {required String actorId}) {
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"initiative_aggressor_choice_v1","prompt":"Hero raised and villain called. Who has initiative?","player_count_v1":2,"hero_seat_v1":"btn","villain_seat_v1":"bb","active_seats_v1":["btn","bb"],"street_v1":"flop","last_aggressor_v1":"hero","initiative_owner_v1":"hero","available_actions_v1":["hero","villain"],"expected":{"actionId":"$actorId"},"error_class":"initiative_aggressor_choice_mismatch","why_v1":"The raiser keeps initiative.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  SessionDrillItemV1 _positionItem(String id, {required String actorId}) {
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"position_thinking_choice_v1","prompt":"Who is in position after the flop?","player_count_v1":2,"hero_seat_v1":"btn","villain_seat_v1":"bb","active_seats_v1":["btn","bb"],"street_v1":"flop","available_actions_v1":["hero","villain"],"expected":{"actionId":"$actorId"},"error_class":"position_thinking_choice_mismatch","why_v1":"The button acts later after the flop.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  SessionDrillItemV1 _boardTextureItem(
    String id, {
    required String expectedAction,
  }) {
    return SessionDrillItemV1(
      drillId: id,
      spec: DrillSpecV1.fromJsonString(
        '{"id":"$id","kind":"board_texture_classifier_v1","prompt":"Flop A-7-2 rainbow. Choose CALL for the calmer board or RAISE for the more pressure-building board.","street_v1":"flop","board_cards_v1":["As","7d","2c"],"board_texture_v1":"dry","available_actions_v1":["call","raise"],"expected_action":"$expectedAction","error_class":"expected_action_mismatch","why_v1":"A-7-2 rainbow is dry, so fewer draws and turn shifts build pressure right away.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
      ),
    );
  }

  testWidgets(
    'promoted session entries surface campaign-to-session handoff context in the header',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w6.s01',
            handoffContextV1: buildProgressionHandoffContextForPackV1(
              'world6_spine_campaign_v1',
            ),
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _item('texture_handoff', expected: 'fold'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_handoff_status_v1')),
        findsOneWidget,
      );
      expect(find.text('Campaign route -> World 6 sessions'), findsOneWidget);
      expect(find.text('World 6'), findsOneWidget);
    },
  );

  testWidgets(
    'launched session surfaces continuation reason at the first learner-facing moment',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w2.s01',
            handoffContextV1: const ProgressionHandoffContextV1(
              statusLine: 'Recent focus: Board Texture',
              continuationHeadline: 'Recent focus: Board Texture',
              continuationReasonLine:
                  'You missed this texture twice. Re-anchor on the paired board cue before you choose.',
              continuationTargetEntryId: 'w2.s01',
              continuationFocusId: 'board_texture',
              continuationReasonCode: 'paired_board_misses',
            ),
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _item('texture_handoff_reason', expected: 'fold'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_continuation_reason_v1')),
        findsOneWidget,
      );
      expect(
        find.text(
          'You missed this texture twice. Re-anchor on the paired board cue before you choose.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'review launch surfaces weak-pattern target and goal at the first learner-facing moment',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w2.s01',
            handoffContextV1: const ProgressionHandoffContextV1(
              statusLine: 'Review: Board Texture',
              continuationHeadline: 'Review: Board Texture',
              continuationReasonLine:
                  'Review target: Board Texture. Goal: Name the board texture first, then choose the line.',
              continuationTargetEntryId: 'w2.s01',
              continuationFocusId: 'board_texture',
              continuationReasonCode: 'progression_review_fit',
              continuationWeaknessLabel: 'Board Texture',
              continuationReviewGoal:
                  'Name the board texture first, then choose the line.',
            ),
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _item('texture_review_reason', expected: 'fold'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_review_weakness_v1')),
        findsOneWidget,
      );
      expect(find.text('Review target: Board Texture'), findsOneWidget);
      expect(
        find.byKey(const Key('session_drill_player_review_goal_v1')),
        findsOneWidget,
      );
      expect(
        find.text('Goal: Name the board texture first, then choose the line.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'position review launch reshapes the first support block into corrective practice',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w2.s02',
            handoffContextV1: const ProgressionHandoffContextV1(
              statusLine: 'Review: Position',
              continuationHeadline: 'Review: Position',
              continuationReasonLine:
                  'Review target: Position. Goal: Re-anchor on who acts later before you choose.',
              continuationTargetEntryId: 'w2.s02',
              continuationFocusId: 'position',
              continuationReasonCode: 'progression_review_fit',
              continuationWeaknessLabel: 'Position',
              continuationReviewGoal:
                  'Re-anchor on who acts later before you choose.',
            ),
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _positionItem('position_review_entry', actorId: 'hero'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Weak pattern: Position'), findsOneWidget);
      expect(
        find.byKey(const Key('session_drill_player_review_weakness_v1')),
        findsOneWidget,
      );
      expect(
        find.text(
          'Goal: Re-anchor on who acts later before you choose. Practice rule: Find who acts later after the flop, then anchor the in-position player before you choose.',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_review_goal_v1')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'initiative review launch reshapes the first intro block into corrective practice',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w2.s03',
            handoffContextV1: const ProgressionHandoffContextV1(
              statusLine: 'Review: Positions and Initiative',
              continuationHeadline: 'Review: Positions and Initiative',
              continuationReasonLine:
                  'Review target: Positions and Initiative. Goal: Re-anchor on who owns the action before you choose.',
              continuationTargetEntryId: 'w2.s03',
              continuationFocusId: 'initiative',
              continuationReasonCode: 'progression_review_fit',
              continuationWeaknessLabel: 'Positions and Initiative',
              continuationReviewGoal:
                  'Re-anchor on who owns the action before you choose.',
            ),
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _initiativeItem('initiative_review_intro', actorId: 'hero'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Weak pattern: Positions and Initiative'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_review_weakness_v1')),
        findsOneWidget,
      );
      expect(
        find.text(
          'Goal: Re-anchor on who owns the action before you choose. Practice rule: Find the last aggressor first, then carry initiative forward to that player.',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_review_goal_v1')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'board texture review launch reshapes the first support block into corrective practice',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w2.s04',
            handoffContextV1: const ProgressionHandoffContextV1(
              statusLine: 'Review: Board Texture',
              continuationHeadline: 'Review: Board Texture',
              continuationReasonLine:
                  'Review target: Board Texture. Goal: Name the board texture first, then choose the line.',
              continuationTargetEntryId: 'w2.s04',
              continuationFocusId: 'board_texture',
              continuationReasonCode: 'progression_review_fit',
              continuationWeaknessLabel: 'Board Texture',
              continuationReviewGoal:
                  'Name the board texture first, then choose the line.',
            ),
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _boardTextureItem('texture_review_entry', expectedAction: 'call'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Weak pattern: Board Texture'), findsOneWidget);
      expect(
        find.byKey(const Key('session_drill_player_review_weakness_v1')),
        findsOneWidget,
      );
      expect(
        find.text(
          'Goal: Name the board texture first, then choose the line. Practice rule: Classify board pressure first, then choose the calmer or pressure-building label.',
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_review_goal_v1')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'completed session drill player shows low-noise continuation surface',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'w5.s01',
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _item('texture_done', expected: 'fold'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('session_drill_player_complete')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_result_ok')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_completion_surface_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_completion_status_header_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_next_session_cta')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('session_drill_player_completion_action_stack_v1'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('session_drill_player_back_to_map_cta')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'world10 track sessions surface structured progression framing and continue to the next track session',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'cash.s01',
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _item('track_done', expected: 'fold'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('World 10 Cash Track · Session 1 of 10 · Board Texture'),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Next lesson ready: World 10 Cash Track · Session 2 of 10.'),
        findsOneWidget,
      );
      expect(
        tester
            .getTopLeft(
              find.byKey(const Key('session_drill_player_next_session_cta')),
            )
            .dy,
        lessThan(
          tester
              .getTopLeft(
                find.byKey(const Key('session_drill_player_back_to_map_cta')),
              )
              .dy,
        ),
      );
      await tester.tap(
        find.byKey(const Key('session_drill_player_next_session_cta')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final player = tester.widget<SessionDrillPlayerV1Screen>(
        find.byType(SessionDrillPlayerV1Screen).last,
      );
      expect(player.sessionId, 'cash.s02');
    },
  );

  testWidgets(
    'world10 late-track sessions continue through the full canonical ten-session sequence',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionDrillPlayerV1Screen(
            sessionId: 'cash.s09',
            debugDrillsOverrideV1: <SessionDrillItemV1>[
              _item('track_done_late', expected: 'fold'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('World 10 Cash Track · Session 9 of 10 · Board Texture'),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('session_drill_player_texture_fold_v1')),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Next lesson ready: World 10 Cash Track · Session 10 of 10.',
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(const Key('session_drill_player_next_session_cta')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final player = tester.widget<SessionDrillPlayerV1Screen>(
        find.byType(SessionDrillPlayerV1Screen).last,
      );
      expect(player.sessionId, 'cash.s10');
    },
  );

  testWidgets('completion continuation CTA returns to map root', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Column(
                children: [
                  const Text('MAP_ROOT', key: Key('map_root')),
                  ElevatedButton(
                    key: const Key('open_session_drill_player_cta'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => SessionDrillPlayerV1Screen(
                            sessionId: 'w5.s01',
                            debugDrillsOverrideV1: <SessionDrillItemV1>[
                              _item('texture_done', expected: 'fold'),
                            ],
                          ),
                        ),
                      );
                    },
                    child: const Text('OPEN'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open_session_drill_player_cta')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('session_drill_player_texture_fold_v1')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('session_drill_player_back_to_map_cta')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('map_root')), findsOneWidget);
    expect(find.byType(SessionDrillPlayerV1Screen), findsNothing);
  });
}
