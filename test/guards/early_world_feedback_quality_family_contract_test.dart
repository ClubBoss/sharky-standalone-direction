import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_corrective_feedback_v1.dart';

void main() {
  DrillSpecV1 _loadSpec(String path) =>
      DrillSpecV1.fromJsonString(File(path).readAsStringSync());

  test('world2 outs, world2 review, world1/world3 hand-chain, and world6 range families use canonical corrective feedback', () {
    final outsSpec = _loadSpec(
      'content/worlds/world2/v1/sessions/w2.s06/drills/d.count_flush_draw_nine_outs.json',
    );
    final reviewSpec = _loadSpec(
      'content/worlds/world2/v1/sessions/w2.s05/drills/d.review_showdown_hero_top_pair.json',
    );
    final world1HandChainSpec = _loadSpec(
      'content/worlds/world1/v1/sessions/w1.s10/drills/d.chain_world1_final_checkpoint_v1.json',
    );
    final handChainSpec = _loadSpec(
      'content/worlds/world3/v1/sessions/w3.s03/drills/d.chain_preflop_checkpoint_v1.json',
    );
    final rangeBucketSpec = _loadSpec(
      'content/worlds/world6/v1/sessions/w6.s01/drills/d.classify_strong_raise.json',
    );
    final world6HandChainSpec = _loadSpec(
      'content/worlds/world6/v1/sessions/w6.s10/drills/d.chain_world6_range_synthesis_recap_v1.json',
    );

    final outsFeedback = resolveSessionDrillCanonicalCorrectiveFeedbackV1(
      sessionId: 'w2.s06',
      spec: outsSpec,
      isFail: true,
      chosenActionIdV1: '8',
    );
    expect(outsFeedback, isNotNull);
    expect(outsFeedback!.detailText, isNot('Incorrect.'));
    expect(outsFeedback.detailText, 'Better answer: 9 outs. 8 misses this scene.');
    expect(outsFeedback.whyText, startsWith('Notice:'));
    expect(outsFeedback.whyText, contains('Next time:'));

    final reviewFeedback = resolveSessionDrillCanonicalCorrectiveFeedbackV1(
      sessionId: 'w2.s05',
      spec: reviewSpec,
      isFail: true,
      chosenActionIdV1: 'villain',
    );
    expect(reviewFeedback, isNotNull);
    expect(reviewFeedback!.detailText, isNot('Incorrect.'));
    expect(
      reviewFeedback.detailText,
      'Better answer: Hero. Villain misses this scene.',
    );
    expect(reviewFeedback.whyText, startsWith('Notice:'));
    expect(reviewFeedback.whyText, contains('Next time:'));

    final world1HandChainStep = world1HandChainSpec.chainStepsV1!.first;
    final world1HandChainFeedback =
        resolveSessionDrillCanonicalCorrectiveFeedbackV1(
          sessionId: 'w1.s10',
          spec: world1HandChainSpec,
          isFail: true,
          currentHandChainStepV1: world1HandChainStep,
          currentHandChainWhyV1: world1HandChainStep.whyV1,
          chosenActionIdV1: 'call',
        );
    expect(world1HandChainFeedback, isNotNull);
    expect(world1HandChainFeedback!.detailText, isNot('Incorrect.'));
    expect(
      world1HandChainFeedback.detailText,
      'Better line: raise. call is weaker here.',
    );
    expect(world1HandChainFeedback.whyText, startsWith('Notice:'));
    expect(world1HandChainFeedback.whyText, contains('Next time:'));

    final handChainStep = handChainSpec.chainStepsV1!.first;
    final handChainFeedback = resolveSessionDrillCanonicalCorrectiveFeedbackV1(
      sessionId: 'w3.s03',
      spec: handChainSpec,
      isFail: true,
      currentHandChainStepV1: handChainStep,
      currentHandChainWhyV1: handChainStep.whyV1,
      chosenActionIdV1: 'call',
    );
    expect(handChainFeedback, isNotNull);
    expect(handChainFeedback!.detailText, isNot('Incorrect.'));
    expect(
      handChainFeedback.detailText,
      'Better line: raise. call is weaker here.',
    );
    expect(handChainFeedback.whyText, startsWith('Notice:'));
    expect(handChainFeedback.whyText, contains('Next time:'));

    final world6HandChainStep = world6HandChainSpec.chainStepsV1!.first;
    final world6HandChainFeedback =
        resolveSessionDrillCanonicalCorrectiveFeedbackV1(
          sessionId: 'w6.s10',
          spec: world6HandChainSpec,
          isFail: true,
          currentHandChainStepV1: world6HandChainStep,
          currentHandChainWhyV1: world6HandChainStep.whyV1,
          chosenActionIdV1: 'raise',
        );
    expect(world6HandChainFeedback, isNotNull);
    expect(world6HandChainFeedback!.detailText, isNot('Incorrect.'));
    expect(
      world6HandChainFeedback.detailText,
      'Better line: call. raise is weaker here.',
    );
    expect(world6HandChainFeedback.whyText, startsWith('Notice:'));
    expect(world6HandChainFeedback.whyText, contains('Next time:'));

    final rangeBucketFeedback = resolveSessionDrillCanonicalCorrectiveFeedbackV1(
      sessionId: 'w6.s01',
      spec: rangeBucketSpec,
      isFail: true,
      chosenActionIdV1: 'fold',
    );
    expect(rangeBucketFeedback, isNotNull);
    expect(rangeBucketFeedback!.detailText, isNot('Incorrect.'));
    expect(
      rangeBucketFeedback.detailText,
      'Better line: RAISE. FOLD is weaker here.',
    );
    expect(rangeBucketFeedback.whyText, startsWith('Notice:'));
    expect(rangeBucketFeedback.whyText, contains('Next time:'));
  });

  test('active session fail surfaces route admitted families through the shared seam', () {
    final playerSource = File(
      'lib/ui_v2/screens/session_drill_player_v1_screen.dart',
    ).readAsStringSync();
    final surfacedRunnerSource = File(
      'lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart',
    ).readAsStringSync();

    expect(
      playerSource,
      contains('CanonicalTerminalSessionDrillSurfacedRunnerV1('),
    );

    expect(
      surfacedRunnerSource,
      contains('resolveSessionDrillCanonicalCorrectiveFeedbackV1('),
    );
    expect(surfacedRunnerSource, contains('correctiveFeedbackV1?.detailText'));
    expect(surfacedRunnerSource, contains('correctiveFeedbackV1?.whyText'));
    expect(surfacedRunnerSource, contains('chosenEventV1: _lastChosenEventV1'));
  });

  test('canonical corrective feedback admits the compact session explanation cluster', () {
    final correctiveSource = File(
      'lib/ui_v2/runner/session_drill_canonical_corrective_feedback_v1.dart',
    ).readAsStringSync();

    expect(correctiveSource, contains('case DrillKindV1.seatTap:'));
    expect(correctiveSource, contains('case DrillKindV1.boardTap:'));
    expect(correctiveSource, contains('case DrillKindV1.holeCardsTap:'));
    expect(correctiveSource, contains('case DrillKindV1.actionChoice:'));
    expect(correctiveSource, contains('case DrillKindV1.betSizingChoice:'));
    expect(correctiveSource, contains('case DrillKindV1.rangeBucketClassifier:'));
    expect(
      correctiveSource,
      contains('_supportsCanonicalHandChainCorrectiveFeedbackV1('),
    );
    expect(correctiveSource, contains('_preferredTeachingTextV1('));
  });
}
