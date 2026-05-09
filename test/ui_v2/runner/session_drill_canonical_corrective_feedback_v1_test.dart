import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_corrective_feedback_v1.dart';

void main() {
  DrillSpecV1 _spec(String raw) => DrillSpecV1.fromJsonString(raw);

  test('canonical corrective feedback upgrades compact spatial and action drill families', () {
    final seatTapSpec = _spec(
      '{"id":"seat_tap_contract_v1","kind":"seat_tap","prompt":"Tap the button first.","expected":{"role":"btn"},"error_class":"expected_action_mismatch","why_v1":"The button tells you who acts last after the flop.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
    );
    final boardTapSpec = _spec(
      '{"id":"board_tap_contract_v1","kind":"board_tap","prompt":"Tap the turn first.","expected":{"boardSlot":"turn"},"error_class":"expected_action_mismatch","why_v1":"The turn card changes whether pressure should keep building.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
    );
    final actionChoiceSpec = _spec(
      '{"id":"action_choice_contract_v1","kind":"action_choice","prompt":"Choose the better line.","available_actions_v1":["fold","call","raise"],"expected":{"actionId":"call"},"error_class":"expected_action_mismatch","why_v1":"Calling keeps showdown value in while a raise overstates the hand.","feedback_incorrect_by_action_v1":{"raise":"Incorrect. Raising turns this medium-strength hand into a thin bluff."},"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect. Generic fallback."}',
    );
    final betSizingSpec = _spec(
      '{"id":"bet_sizing_contract_v1","kind":"bet_sizing_choice_v1","prompt":"Choose sizing.","expected":{"presetId":"half_pot"},"error_class":"expected_action_mismatch","why_v1":"Half pot keeps worse hands in more often.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect."}',
    );
    final rangeBucketSpec = _spec(
      '{"id":"range_bucket_contract_v1","kind":"range_bucket_classifier_v1","prompt":"Range bucket is strong in position. Choose action.","range_bucket_v1":"strong","expected_action":"raise","acceptable_actions":["call"],"error_class":"expected_action_mismatch","why_v1":"Raise now to build value while strong hands can still get called.","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect. This strong bucket spot expects raise."}',
    );

    final seatTapFeedback = resolveSessionDrillCanonicalCorrectiveFeedbackV1(
      sessionId: 'w2.s02',
      spec: seatTapSpec,
      isFail: true,
      chosenEventV1: DrillUserEventV1.seatTap(role: 'bb'),
    );
    expect(seatTapFeedback, isNotNull);
    expect(
      seatTapFeedback!.detailText,
      'Better answer: BTN. BB misses this scene.',
    );
    expect(seatTapFeedback.whyText, startsWith('Notice:'));
    expect(seatTapFeedback.whyText, contains('Next time:'));

    final boardTapFeedback = resolveSessionDrillCanonicalCorrectiveFeedbackV1(
      sessionId: 'w2.s04',
      spec: boardTapSpec,
      isFail: true,
      chosenEventV1: DrillUserEventV1.boardTap('flop_mid'),
    );
    expect(boardTapFeedback, isNotNull);
    expect(
      boardTapFeedback!.detailText,
      'Better answer: TURN. FLOP MIDDLE misses this scene.',
    );
    expect(boardTapFeedback.whyText, startsWith('Notice:'));
    expect(boardTapFeedback.whyText, contains('Next time:'));

    final actionChoiceFeedback = resolveSessionDrillCanonicalCorrectiveFeedbackV1(
      sessionId: 'w5.s01',
      spec: actionChoiceSpec,
      isFail: true,
      chosenActionIdV1: 'raise',
      chosenEventV1: DrillUserEventV1.actionChoice('raise'),
    );
    expect(actionChoiceFeedback, isNotNull);
    expect(
      actionChoiceFeedback!.detailText,
      'Better line: CALL. RAISE is weaker here.',
    );
    expect(actionChoiceFeedback.whyText, contains('Raising turns this medium-strength hand into a thin bluff.'));
    expect(actionChoiceFeedback.whyText, contains('Next time:'));

    final betSizingFeedback = resolveSessionDrillCanonicalCorrectiveFeedbackV1(
      sessionId: 'cash.s05',
      spec: betSizingSpec,
      isFail: true,
      chosenActionIdV1: 'pot',
      chosenEventV1: DrillUserEventV1.actionChoice('pot'),
    );
    expect(betSizingFeedback, isNotNull);
    expect(
      betSizingFeedback!.detailText,
      'Better line: BET 1/2. BET POT is weaker here.',
    );
    expect(betSizingFeedback.whyText, startsWith('Notice:'));
    expect(betSizingFeedback.whyText, contains('Next time:'));

    final rangeBucketFeedback = resolveSessionDrillCanonicalCorrectiveFeedbackV1(
      sessionId: 'w6.s01',
      spec: rangeBucketSpec,
      isFail: true,
      chosenActionIdV1: 'fold',
      chosenEventV1: DrillUserEventV1.actionChoice('fold'),
    );
    expect(rangeBucketFeedback, isNotNull);
    expect(
      rangeBucketFeedback!.detailText,
      'Better line: RAISE. FOLD is weaker here.',
    );
    expect(rangeBucketFeedback.whyText, startsWith('Notice:'));
    expect(rangeBucketFeedback.whyText, contains('Next time:'));
    expect(
      rangeBucketFeedback.whyText,
      contains('Raise now to build value while strong hands can still get called.'),
    );
  });

  test('canonical corrective feedback upgrades the active world1/world6 hand-chain cluster', () {
    final world1HandChainSpec = _spec(
      '{"id":"chain_world1_contract_v1","kind":"hand_chain_v1","chain_id":"w1_contract_chain_v1","prompt":"Play this short World 1 chain.","expected":{},"error_class":"unused","steps":[{"street":"preflop","prompt":"Step 1","available_actions_v1":["fold","call","raise"],"expected_action":"raise","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch","why_v1":"World 1 starts by rewarding clean first-in spots from good seats."},{"street":"preflop","prompt":"Step 2","available_actions_v1":["fold","call"],"expected_action":"call","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch","why_v1":"Facing pressure now points to the cleaner call."}]}',
    );
    final world1PresetHandChainSpec = _spec(
      '{"id":"chain_world1_preset_contract_v1","kind":"hand_chain_v1","chain_id":"w1_preset_chain_v1","prompt":"Play this World 1 bridge chain.","expected":{},"error_class":"unused","steps":[{"street":"flop","prompt":"Step 1","expected_preset_id":"half_pot","acceptable_preset_ids":["one_third_pot"],"feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch","why_v1":"Half pot builds value while still keeping weaker hands in."},{"street":"turn","prompt":"Step 2","expected_preset_id":"one_third_pot","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch","why_v1":"One third pot keeps the price comfortable."}]}',
    );
    final world6HandChainSpec = _spec(
      '{"id":"chain_world6_contract_v1","kind":"hand_chain_v1","chain_id":"w6_contract_chain_v1","prompt":"Play this short World 6 chain.","expected":{},"error_class":"unused","steps":[{"street":"turn","prompt":"Step 1","available_actions_v1":["fold","call","raise"],"expected_action":"raise","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch","why_v1":"The point of World 6 synthesis is to act more strongly only when several range signals point the same way."},{"street":"river","prompt":"Step 2","available_actions_v1":["fold","call"],"expected_action":"fold","feedback_correct_v1":"Correct.","feedback_incorrect_v1":"Incorrect.","error_class":"expected_action_mismatch","why_v1":"When the full range picture thins out, folding protects chips."}]}',
    );

    final world1Feedback = resolveSessionDrillCanonicalCorrectiveFeedbackV1(
      sessionId: 'w1.s10',
      spec: world1HandChainSpec,
      isFail: true,
      currentHandChainStepV1: world1HandChainSpec.chainStepsV1!.first,
      currentHandChainWhyV1: world1HandChainSpec.chainStepsV1!.first.whyV1,
      chosenActionIdV1: 'call',
    );
    expect(world1Feedback, isNotNull);
    expect(
      world1Feedback!.detailText,
      'Better line: raise. call is weaker here.',
    );
    expect(world1Feedback.whyText, startsWith('Notice:'));
    expect(world1Feedback.whyText, contains('Next time:'));

    final world1PresetFeedback = resolveSessionDrillCanonicalCorrectiveFeedbackV1(
      sessionId: 'w1.s01',
      spec: world1PresetHandChainSpec,
      isFail: true,
      currentHandChainStepV1: world1PresetHandChainSpec.chainStepsV1!.first,
      currentHandChainWhyV1:
          world1PresetHandChainSpec.chainStepsV1!.first.whyV1,
      chosenActionIdV1: 'one_third_pot',
    );
    expect(world1PresetFeedback, isNotNull);
    expect(
      world1PresetFeedback!.detailText,
      'Better line: BET 1/2. BET 1/3 is weaker here.',
    );
    expect(
      world1PresetFeedback.whyText,
      contains(
        'Next time: Read the frame first, then choose the size that matches the expected line.',
      ),
    );

    final world6Feedback = resolveSessionDrillCanonicalCorrectiveFeedbackV1(
      sessionId: 'w6.s10',
      spec: world6HandChainSpec,
      isFail: true,
      currentHandChainStepV1: world6HandChainSpec.chainStepsV1!.first,
      currentHandChainWhyV1: world6HandChainSpec.chainStepsV1!.first.whyV1,
      chosenActionIdV1: 'call',
    );
    expect(world6Feedback, isNotNull);
    expect(
      world6Feedback!.detailText,
      'Better line: raise. call is weaker here.',
    );
    expect(world6Feedback.whyText, startsWith('Notice:'));
    expect(world6Feedback.whyText, contains('Next time:'));
  });
}
