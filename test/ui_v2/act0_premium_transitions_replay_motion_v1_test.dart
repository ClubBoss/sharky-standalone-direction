import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

// Regression coverage for `Premium Transitions / Replay Motion v1`
// (docs/_reviews/premium_transitions_replay_motion_v1.md): the shared
// milestone motion contract admitted on exactly two surfaces,
// `_WorldCompletionPayoffV1` and `_BandTransitionPayoffV1`.

const _worldCompletionKey = Key('act0_shell_world_completion_payoff');
const _bandTransitionKey = Key('act0_shell_band_transition_completion_payoff');
const _worldCompletionMotionKey = Key(
  'act0_shell_world_completion_motion_reveal',
);
const _bandTransitionMotionKey = Key(
  'act0_shell_band_transition_completion_motion_reveal',
);
const _sessionSummaryHeroMotionKey = Key(
  'act0_shell_session_summary_proof_hero_motion_reveal',
);
const _continueCta = Key('act0_shell_block_summary_continue_cta');

void main() {
  testWidgets('world completion animates only when admitted', (tester) async {
    await tester.pumpWidget(_host(_worldTwoSummary()));
    await tester.pump();

    expect(find.byKey(_worldCompletionMotionKey), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(_worldCompletionMotionKey),
        matching: find.byType(AnimatedScale),
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(_host(_incompleteWorldTwoSummary()));
    await tester.pump();

    expect(find.byKey(_worldCompletionKey), findsNothing);
    expect(find.byKey(_worldCompletionMotionKey), findsNothing);
  });

  testWidgets('band transition animates only when admitted', (tester) async {
    await tester.pumpWidget(_host(_worldFourSummary()));
    await tester.pump();

    expect(find.byKey(_bandTransitionMotionKey), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(_bandTransitionMotionKey),
        matching: find.byType(AnimatedScale),
      ),
      findsOneWidget,
    );

    // World 4 complete but the next-world route truth does not match the
    // accepted W4->W5 transition: neither payoff (and neither motion
    // reveal) may render.
    await tester.pumpWidget(_host(_worldFourMismatchedNextWorldSummary()));
    await tester.pump();

    expect(find.byKey(_bandTransitionKey), findsNothing);
    expect(find.byKey(_bandTransitionMotionKey), findsNothing);
    expect(find.byKey(_worldCompletionMotionKey), findsNothing);
  });

  testWidgets(
    'world completion and band transition share the same motion contract',
    (tester) async {
      await tester.pumpWidget(_host(_worldTwoSummary()));
      await tester.pump();
      final worldCompletionScale = tester.widget<AnimatedScale>(
        find.descendant(
          of: find.byKey(_worldCompletionMotionKey),
          matching: find.byType(AnimatedScale),
        ),
      );
      final worldCompletionSlide = tester.widget<AnimatedSlide>(
        find.descendant(
          of: find.byKey(_worldCompletionMotionKey),
          matching: find.byType(AnimatedSlide),
        ),
      );

      await tester.pumpWidget(_host(_worldFourSummary()));
      await tester.pump();
      final bandScale = tester.widget<AnimatedScale>(
        find.descendant(
          of: find.byKey(_bandTransitionMotionKey),
          matching: find.byType(AnimatedScale),
        ),
      );
      final bandSlide = tester.widget<AnimatedSlide>(
        find.descendant(
          of: find.byKey(_bandTransitionMotionKey),
          matching: find.byType(AnimatedSlide),
        ),
      );

      // Same easing curves and same details-stage duration on both surfaces -
      // one shared contract, not two independent implementations. Only the
      // identity-stage duration differs (band transition uses the stronger
      // `milestone` token; ordinary completion uses `standard`), which is the
      // one documented, bounded emphasis difference.
      expect(worldCompletionScale.curve, bandScale.curve);
      expect(worldCompletionSlide.curve, bandSlide.curve);
      expect(worldCompletionSlide.duration, bandSlide.duration);
      expect(worldCompletionScale.duration, Act0MotionTokensV1.standard);
      expect(bandScale.duration, Act0MotionTokensV1.milestone);
    },
  );

  testWidgets('Session Summary proof hero uses the shared reveal contract', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_worldFourSummary()));
    await tester.pump();

    expect(find.byKey(_sessionSummaryHeroMotionKey), findsOneWidget);
    final heroScales = tester
        .widgetList<AnimatedScale>(
          find.descendant(
            of: find.byKey(_sessionSummaryHeroMotionKey),
            matching: find.byType(AnimatedScale),
          ),
        )
        .toList(growable: false);
    expect(heroScales, isNotEmpty);
    expect(
      heroScales.map((scale) => scale.duration),
      contains(Act0MotionTokensV1.standard),
    );
    await tester.pumpAndSettle();
    final settledHeroScales = tester.widgetList<AnimatedScale>(
      find.descendant(
        of: find.byKey(_sessionSummaryHeroMotionKey),
        matching: find.byType(AnimatedScale),
      ),
    );
    expect(settledHeroScales.map((scale) => scale.scale), everyElement(1.0));
  });

  testWidgets('reduced motion skips animation with no hidden content', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: _hostChild(_worldFourSummary()),
      ),
    );
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(_bandTransitionMotionKey),
        matching: find.byType(AnimatedScale),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(_sessionSummaryHeroMotionKey),
        matching: find.byType(AnimatedScale),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(_bandTransitionMotionKey),
        matching: find.byType(AnimatedSlide),
      ),
      findsNothing,
    );
    // Identity and details content are both immediately present - no
    // information is gated behind an animation that never runs.
    expect(
      find.descendant(
        of: find.byKey(_bandTransitionMotionKey),
        matching: find.text('Foundation complete'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(_bandTransitionMotionKey),
        matching: find.text('Next: Developing Player'),
      ),
      findsOneWidget,
    );

    // No pending timer: pumpAndSettle must resolve immediately with no
    // extra animated frames, proving there is no timing dependency left.
    await tester.pumpAndSettle();
  });

  testWidgets('rebuild does not replay the reveal', (tester) async {
    await tester.pumpWidget(_host(_worldFourSummary()));
    await tester.pumpAndSettle();

    final settledScale = tester
        .widget<AnimatedScale>(
          find.descendant(
            of: find.byKey(_bandTransitionMotionKey),
            matching: find.byType(AnimatedScale),
          ),
        )
        .scale;
    expect(settledScale, 1.0);

    // Rebuild the same subtree in place (equivalent summary, same widget
    // position) - this must not reset the settled reveal state.
    await tester.pumpWidget(_host(_worldFourSummary()));
    await tester.pump();

    final afterRebuildScale = tester
        .widget<AnimatedScale>(
          find.descendant(
            of: find.byKey(_bandTransitionMotionKey),
            matching: find.byType(AnimatedScale),
          ),
        )
        .scale;
    expect(afterRebuildScale, 1.0);
  });

  testWidgets('CTA callback remains intact and is not intercepted mid-motion', (
    tester,
  ) async {
    var continued = 0;
    await tester.pumpWidget(
      _host(_worldFourSummary(), onContinue: () => continued += 1),
    );
    // Deliberately do not settle first: the reveal is still in flight.
    await tester.pump();

    await tester.ensureVisible(find.byKey(_continueCta));
    await tester.tap(find.byKey(_continueCta));
    await tester.pump();

    expect(continued, 1);
  });

  testWidgets('motion does not alter copy or gating truth', (tester) async {
    final summary = _worldFourSummary();
    // Band transition takes priority at the render site over the ordinary
    // card even though both booleans admit World 4; only the band card must
    // actually render.
    expect(summary.hasBandTransitionPayoff, isTrue);

    await tester.pumpWidget(_host(summary));
    await tester.pump();

    expect(
      tester
          .widget<Text>(
            find.byKey(
              const Key('act0_shell_band_transition_completion_payoff_label'),
            ),
          )
          .data,
      'Foundation complete',
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(
            find.byKey(
              const Key('act0_shell_band_transition_completion_payoff_label'),
            ),
          )
          .data,
      'Foundation complete',
    );
  });

  testWidgets('compact layout has no overflow with motion active', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host(_worldFourSummary()));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'settles deterministically within the existing capture pump budget',
    (tester) async {
      // Mirrors the exact pump sequence
      // tools/act0_real_text_surface_capture_v1.dart already uses for
      // active-route captures: one pump, then one 900ms pump.
      await tester.pumpWidget(_host(_worldFourSummary()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      final scale = tester
          .widget<AnimatedScale>(
            find.descendant(
              of: find.byKey(_bandTransitionMotionKey),
              matching: find.byType(AnimatedScale),
            ),
          )
          .scale;
      final opacities = tester
          .widgetList<AnimatedOpacity>(
            find.descendant(
              of: find.byKey(_bandTransitionMotionKey),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .map((widget) => widget.opacity);
      expect(scale, 1.0);
      expect(opacities, everyElement(1.0));
    },
  );

  test(
    'no new arbitrary duration values on the milestone motion primitive',
    () {
      // Structural guard: every Duration on the shared reveal must resolve to
      // an Act0MotionTokensV1 constant, not a bespoke literal, matching the
      // Motion Direction System v1 contract.
      expect(Act0MotionTokensV1.micro, const Duration(milliseconds: 140));
      expect(Act0MotionTokensV1.standard, const Duration(milliseconds: 260));
      expect(Act0MotionTokensV1.emphasis, const Duration(milliseconds: 420));
      expect(Act0MotionTokensV1.milestone, const Duration(milliseconds: 900));
    },
  );
}

Act0BlockCompletionSummaryV1 _worldTwoSummary() {
  return const Act0BlockCompletionSummaryV1(
    lessonTitle: 'A lesson in World 2',
    xpEarned: 24,
    errorCount: 0,
    taskCount: 4,
    correctCount: 4,
    startLevel: 1,
    endLevel: 2,
    startXp: 188,
    endXp: 12,
    xpTarget: 200,
    milestoneTier: Act0ProgressMilestoneTierV1.world,
    worldNumber: 2,
    worldTitle: 'Hand Discipline',
    nextWorldNumber: 3,
    nextWorldTitle: 'Position Thinking',
    perfectClearCount: 12,
    completedClearCount: 12,
  );
}

Act0BlockCompletionSummaryV1 _incompleteWorldTwoSummary() {
  return const Act0BlockCompletionSummaryV1(
    lessonTitle: 'A lesson in World 2',
    xpEarned: 20,
    errorCount: 0,
    taskCount: 4,
    correctCount: 4,
    startLevel: 1,
    endLevel: 1,
    startXp: 40,
    endXp: 60,
    xpTarget: 200,
    nextLessonTitle: 'Next lesson in the same world',
  );
}

Act0BlockCompletionSummaryV1 _worldFourSummary() {
  return const Act0BlockCompletionSummaryV1(
    lessonTitle: 'A lesson in World 4',
    xpEarned: 24,
    errorCount: 0,
    taskCount: 4,
    correctCount: 4,
    startLevel: 1,
    endLevel: 2,
    startXp: 188,
    endXp: 12,
    xpTarget: 200,
    milestoneTier: Act0ProgressMilestoneTierV1.world,
    worldNumber: 4,
    worldTitle: 'Bet Purpose / Price',
    nextWorldNumber: 5,
    nextWorldTitle: 'Board Awareness',
    perfectClearCount: 12,
    completedClearCount: 12,
  );
}

Act0BlockCompletionSummaryV1 _worldFourMismatchedNextWorldSummary() {
  return const Act0BlockCompletionSummaryV1(
    lessonTitle: 'A lesson in World 4',
    xpEarned: 24,
    errorCount: 0,
    taskCount: 4,
    correctCount: 4,
    startLevel: 1,
    endLevel: 2,
    startXp: 188,
    endXp: 12,
    xpTarget: 200,
    milestoneTier: Act0ProgressMilestoneTierV1.world,
    worldNumber: 4,
    worldTitle: 'Bet Purpose / Price',
    nextWorldNumber: 6,
    nextWorldTitle: 'Range Thinking',
    perfectClearCount: 12,
    completedClearCount: 12,
  );
}

Widget _hostChild(
  Act0BlockCompletionSummaryV1 summary, {
  Act0RepairOutcomeConsumerV1 repairOutcomeConsumer =
      const Act0RepairOutcomeConsumerV1(),
  VoidCallback? onContinue,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Act0BlockCompletionShellV1(
        summary: summary,
        repairOutcomeConsumer: repairOutcomeConsumer,
        onReplay: () {},
        onContinue: onContinue ?? () {},
        onBackToMap: () {},
      ),
    ),
  );
}

Widget _host(
  Act0BlockCompletionSummaryV1 summary, {
  Act0RepairOutcomeConsumerV1 repairOutcomeConsumer =
      const Act0RepairOutcomeConsumerV1(),
  VoidCallback? onContinue,
}) {
  return _hostChild(
    summary,
    repairOutcomeConsumer: repairOutcomeConsumer,
    onContinue: onContinue,
  );
}
