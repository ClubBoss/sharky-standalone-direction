import 'package:flutter/material.dart';

/// Visual Gauntlet B5 — attention-aware rendering.
///
/// B1 gave the scene depth, B2 material, B3 people, B4 attached instrumentation.
/// What none of them gave it was any sense of *what the learner is doing right
/// now*. Rendered side by side, decision, wrong feedback, repair and recheck are
/// pixel-comparable apart from header copy — so the learner re-scans six
/// players, a room and a full table at every single step.
///
/// This module is the one deterministic salience model. It reads only state
/// Wave A already exposes, and it changes nothing except how loud things are.
///
/// Two rules shape every number below.
///
/// 1. **Quiet the field, never light the target.** "Everything important glows"
///    is not a hierarchy. Recession is applied to the room and the people so
///    the poker situation is what remains.
/// 2. **Recede by plane, never by seat.** Eligible answers must stay fair, so
///    nothing here can ever reach a single seat and make it stand out.
///
/// Cards, board, pot, bets, plates, hero, teaching copy and the action dock are
/// never attenuated. That is what keeps the scene readable and the answer
/// unrevealed.

/// Where the learner is, from deterministic Wave A state only.
///
/// No new poker meaning is inferred here — every value maps 1:1 onto a phase
/// the runner already knows.
enum Act0SceneAttentionPhaseV1 {
  /// Being taught. The table is illustration for the copy.
  theory,

  /// Choosing. The situation and the actions both have to stay legible.
  decision,

  /// Verdict is right. The causal object is the thing to look at.
  correctFeedback,

  /// Verdict is wrong. Same focal object, and the field quiets hardest here
  /// because search cost is what actually hurts after a mistake.
  wrongFeedback,

  /// Re-attempting a named target. It should be easy to reacquire.
  repair,

  /// Being asked to recognise the situation again from scratch. The scene has
  /// to come back to normal or the recheck is not a real recheck.
  recheck,
}

/// Coarse salience bands, for callers that want to reason in tiers rather than
/// in raw recession values.
enum Act0SceneSalienceTierV1 { primary, supporting, ambient }

/// The scene's attention state.
@immutable
class Act0SceneAttentionV1 {
  const Act0SceneAttentionV1(this.phase);

  static const Act0SceneAttentionV1 neutral = Act0SceneAttentionV1(
    Act0SceneAttentionPhaseV1.decision,
  );

  final Act0SceneAttentionPhaseV1 phase;

  /// How far the room recedes. Bounded well short of disappearing: B2's
  /// environment must stay spatially present, never become a flat backdrop.
  double get roomRecession => switch (phase) {
    Act0SceneAttentionPhaseV1.theory => 0.34,
    Act0SceneAttentionPhaseV1.decision => 0.20,
    Act0SceneAttentionPhaseV1.correctFeedback => 0.52,
    Act0SceneAttentionPhaseV1.wrongFeedback => 0.74,
    Act0SceneAttentionPhaseV1.repair => 0.52,
    // Recheck deliberately returns almost to normal. If the scene stayed quiet
    // here the learner would be recognising a simplified picture, not the one
    // they will meet again.
    Act0SceneAttentionPhaseV1.recheck => 0.12,
  };

  /// How far the B3 players recede. Always less than the room — people are the
  /// scene's spatial scale, and flattening them would undo B3.
  double get playerRecession => switch (phase) {
    Act0SceneAttentionPhaseV1.theory => 0.30,
    Act0SceneAttentionPhaseV1.decision => 0.16,
    Act0SceneAttentionPhaseV1.correctFeedback => 0.56,
    Act0SceneAttentionPhaseV1.wrongFeedback => 0.64,
    Act0SceneAttentionPhaseV1.repair => 0.56,
    Act0SceneAttentionPhaseV1.recheck => 0.10,
  };

  /// How strongly B4's clue anchor asserts itself.
  ///
  /// B4 shipped this bracket always-on, so it carried no state information and
  /// persisted into recheck as a standing pointer. It now belongs to the phases
  /// that are actually talking about it.
  double get clueEmphasis => switch (phase) {
    Act0SceneAttentionPhaseV1.correctFeedback => 1.0,
    Act0SceneAttentionPhaseV1.wrongFeedback => 1.0,
    // Repair supports reacquisition: the learner is re-attempting a named
    // target, so the clue asserts. It was held at a decision-level 0.34 only
    // while repair and recheck could not be told apart; with the canonical
    // learning-loop stage now resolving them, the intended contract is
    // restored.
    Act0SceneAttentionPhaseV1.repair => 0.85,
    Act0SceneAttentionPhaseV1.decision => 0.30,
    Act0SceneAttentionPhaseV1.theory => 0.22,
    // No standing pointer during recognition.
    Act0SceneAttentionPhaseV1.recheck => 0.0,
  };

  Act0SceneSalienceTierV1 tierForRecession(double recession) =>
      recession >= 0.45
      ? Act0SceneSalienceTierV1.ambient
      : recession >= 0.20
      ? Act0SceneSalienceTierV1.supporting
      : Act0SceneSalienceTierV1.primary;
}

/// Applies bounded recession to a subtree.
///
/// Desaturation, a luminance drop, and an opacity attenuation, combined.
///
/// The first build used the colour matrix alone and measured a mean pixel delta
/// of 2.5/255 at the strongest phase — because this scene is *already* dark and
/// nearly neutral, so darkening and desaturating it further has almost no
/// headroom. Opacity is the lever that actually works here: letting the room
/// and the people settle back toward the base tone flattens their form, which
/// is what recession looks like on a dark scene.
///
/// Still deliberately not blur: this stays deterministic, keeps every edge
/// sharp for accessibility, costs no raster pass, and cannot smear a rank or a
/// suit.
class Act0SceneRecedeV1 extends StatelessWidget {
  const Act0SceneRecedeV1({
    super.key,
    required this.recession,
    required this.child,
    this.maxDesaturation = 0.80,
    this.maxLuminanceDrop = 0.30,
    this.maxOpacityDrop = 0.62,
  });

  /// `0` untouched, `1` fully receded — which is still short of invisible,
  /// because the caps below bound how far this can ever go.
  final double recession;

  final double maxDesaturation;
  final double maxLuminanceDrop;

  /// Bounded well short of invisible: B2's room and B3's people must remain
  /// spatially present, never vanish.
  final double maxOpacityDrop;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final amount = recession.clamp(0.0, 1.0);
    if (amount <= 0.001) return child;

    final saturation = 1 - (maxDesaturation * amount);
    final luminance = 1 - (maxLuminanceDrop * amount);

    // Standard luminance-preserving saturation matrix, then scaled.
    const rw = 0.2126;
    const gw = 0.7152;
    const bw = 0.0722;
    double m(double weight, bool onDiagonal) =>
        (weight + ((onDiagonal ? 1.0 : 0.0) - weight) * saturation) * luminance;

    return Opacity(
      opacity: (1 - (maxOpacityDrop * amount)).clamp(0.0, 1.0),
      child: ColorFiltered(
        colorFilter: ColorFilter.matrix(<double>[
          m(rw, true), m(gw, false), m(bw, false), 0, 0, //
          m(rw, false), m(gw, true), m(bw, false), 0, 0, //
          m(rw, false), m(gw, false), m(bw, true), 0, 0, //
          0, 0, 0, 1, 0,
        ]),
        child: child,
      ),
    );
  }
}
