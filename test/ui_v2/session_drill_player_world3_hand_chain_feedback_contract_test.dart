import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/drill_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart';
import 'package:poker_analyzer/ui_v2/screens/session_drill_player_v1_screen.dart';

void main() {
  SessionDrillItemV1 _world3CheckpointChainItem() {
    return SessionDrillItemV1(
      drillId: 'chain_preflop_checkpoint_v1',
      spec: DrillSpecV1.fromJsonString(
        '{"id":"chain_preflop_checkpoint_v1","kind":"hand_chain_v1","chain_id":"w3_s03_preflop_checkpoint_v1","prompt":"Play this short World 3 preflop checkpoint chain.","expected":{},"error_class":"unused","steps":[{"street":"preflop","prompt":"Step 1: Hero is in the cutoff with AQs and the pot is unopened. Which compact preflop action fits best?","player_count_v1":4,"hero_seat_v1":"co","villain_seat_v1":"bb","active_seats_v1":["btn","co","bb"],"empty_seats_v1":["sb"],"hero_hole_cards_v1":["As","Qs"],"available_actions_v1":["fold","call","raise"],"expected_action":"raise","feedback_correct_v1":"Correct. In an unopened cutoff spot, AQs is strong enough to open and take the initiative.","feedback_incorrect_v1":"Incorrect. In an unopened cutoff spot, AQs is strong enough to start the pot, so raising is the clearest first action.","error_class":"expected_action_mismatch","why_v1":"A strong hand category plus an unopened pot still points to the clearest first action: raise."},{"street":"preflop","prompt":"Step 2: Hero is now on the button with KQo after the cutoff opened first. Which compact action fits better?","player_count_v1":4,"hero_seat_v1":"btn","villain_seat_v1":"co","active_seats_v1":["btn","co","bb"],"empty_seats_v1":["sb"],"hero_hole_cards_v1":["Kh","Qd"],"available_actions_v1":["fold","call","raise"],"expected_action":"call","feedback_correct_v1":"Correct. Facing a cutoff open, KQo keeps enough value to continue by calling in position.","feedback_incorrect_v1":"Incorrect. Facing a cutoff open, KQo plays better as an in-position call than as a thin raise.","error_class":"expected_action_mismatch","why_v1":"Facing a cutoff open, KQo keeps enough value to continue by calling in position."}]}',
      ),
    );
  }

  testWidgets('w3 hand-chain misses use corrective fail detail and fix line', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(1440, 2560);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: SessionDrillPlayerV1Screen(
          sessionId: 'w3.s03',
          debugDrillsOverrideV1: <SessionDrillItemV1>[
            _world3CheckpointChainItem(),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byType(CanonicalTerminalSessionDrillSurfacedRunnerV1),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('session_drill_player_hand_chain_action_call_v1')),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('session_drill_player_result_fail_detail')),
      findsOneWidget,
    );
    expect(
      find.text('Better line: raise. call is weaker here.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('session_drill_player_result_fail_why_v1')),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Notice: A strong hand category plus an unopened pot still points to the clearest first action: raise.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'Next time: Read the frame first, then choose the expected line.',
      ),
      findsOneWidget,
    );
  });
}
