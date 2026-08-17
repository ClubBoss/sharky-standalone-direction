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
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_salience_v1.dart';

void main() {
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
