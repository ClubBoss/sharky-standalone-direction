// B5 salience-model guard.
//
// The renderer must treat a targeted repair and a targeted recheck differently:
// repair quiets the field for reacquisition, recheck restores near-normal
// recognition and leaves no standing clue pointer.
//
// This locks that behaviour into the model itself. The runtime resolver's
// ability to *reach* both phases on the canonical learning route is blocked
// upstream — see B5_PHASE_SIGNAL_BLOCKER in
// docs/_reviews/visual_gauntlet_b5_gap_map_v1.md — so this guards the half that
// is provable today and will fail loudly if the model's contract regresses.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_salience_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

String _resolvedPhase(WidgetTester tester) {
  final matches = find
      .byWidgetPredicate(
        (widget) =>
            widget.key?.toString().contains('act0_scene_attention_phase_') ??
            false,
      )
      .evaluate();
  expect(
    matches,
    isNotEmpty,
    reason: 'the scene must publish its resolved B5 attention phase',
  );
  return matches.first.widget.key
      .toString()
      .split('act0_scene_attention_phase_')
      .last
      .replaceAll(RegExp(r"['>\]]"), '');
}

Future<void> _tap(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key).first);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(key).first, warnIfMissed: false);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'the canonical learning sequence resolves distinct B5 attention phases',
    (tester) async {
      tester.view.physicalSize = const Size(402, 874);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            state: Act0ShellStateV1.sample,
            showPlacementOnStart: false,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface:
                  Act0ControlledDemoCaptureSurfaceV1.runnerFirstWrongFeedback,
              worldId: 'world_1',
              lessonId: 'fold_check_call_raise',
              taskId: 'actions_check_drill',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(_resolvedPhase(tester), 'wrongFeedback');

      await _tap(tester, const Key('act0_shell_feedback_continue_cta'));
      expect(
        _resolvedPhase(tester),
        'repair',
        reason: 'the targeted repair attempt must resolve to the repair phase',
      );

      await _tap(tester, const Key('act0_shell_option_check'));
      await _tap(tester, const Key('act0_shell_feedback_continue_cta'));
      expect(
        _resolvedPhase(tester),
        'recheck',
        reason:
            'the targeted recheck attempt must resolve to the recheck phase',
      );
    },
  );
  test('repair and recheck are distinct B5 attention phases', () {
    const repair = Act0SceneAttentionV1(Act0SceneAttentionPhaseV1.repair);
    const recheck = Act0SceneAttentionV1(Act0SceneAttentionPhaseV1.recheck);

    expect(
      repair.roomRecession,
      greaterThan(recheck.roomRecession),
      reason: 'repair must quiet the field more than recheck',
    );
    expect(
      repair.playerRecession,
      greaterThan(recheck.playerRecession),
      reason: 'repair must quiet the players more than recheck',
    );
    expect(
      recheck.clueEmphasis,
      0.0,
      reason: 'recheck must leave no standing clue pointer',
    );
  });

  test('recheck restores near-normal recognition context', () {
    const recheck = Act0SceneAttentionV1(Act0SceneAttentionPhaseV1.recheck);
    const decision = Act0SceneAttentionV1(Act0SceneAttentionPhaseV1.decision);

    expect(
      recheck.roomRecession,
      lessThanOrEqualTo(decision.roomRecession),
      reason: 'recheck must not be quieter than a normal decision',
    );
    expect(
      recheck.playerRecession,
      lessThanOrEqualTo(decision.playerRecession),
      reason: 'recheck must not be quieter than a normal decision',
    );
  });

  test('only feedback asserts the clue anchor', () {
    for (final phase in <Act0SceneAttentionPhaseV1>[
      Act0SceneAttentionPhaseV1.decision,
      Act0SceneAttentionPhaseV1.repair,
      Act0SceneAttentionPhaseV1.recheck,
    ]) {
      expect(
        Act0SceneAttentionV1(phase).clueEmphasis,
        lessThan(
          const Act0SceneAttentionV1(
            Act0SceneAttentionPhaseV1.wrongFeedback,
          ).clueEmphasis,
        ),
        reason:
            'phase $phase leaves an answer open and must not assert the '
            'clue as hard as feedback does',
      );
    }
  });
}
