import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_material_v1.dart';

/// Visual Gauntlet B4 — object-attached HUD.
///
/// B1 gave every seat a `plateAnchor` and a `betAnchor`. B2 made the table a
/// physical object. B3 put a real person in every seat. The HUD did not move
/// with any of it: identity stayed a flat app pill carrying a generic avatar
/// glyph — beside an actual drawn player — and commitments stayed parked
/// mid-cloth while `betAnchor` was consumed by nothing.
///
/// This module is the seam where information starts belonging to the object it
/// describes. A nameplate here is set *into* the surface rather than floating
/// over it: recessed fill, a dark top edge where the surface steps down, and a
/// lit bottom edge catching the same lamp as the rail crown.
///
/// It changes presentation and ownership only. No poker truth, no calculation,
/// no seat semantics, and no B1/B2/B3 geometry.

/// A nameplate belonging to a seat.
///
/// Deliberately darker and quieter than the Wave A pill it replaces. Six of
/// these plus figures plus chips share one rail, so the plate's job is to sit
/// down into the scene and let the cards stay dominant.
@immutable
class Act0SceneNameplateV1 {
  const Act0SceneNameplateV1._();

  /// Recessed body of the plate. Semi-opaque so the cloth or rail beneath still
  /// reads through it, which is what stops it looking like a pasted card.
  static const Color recess = Color(0xE60A1421);

  /// Where the surface steps down into the plate.
  static const Color topEdge = Color(0xFF04090F);

  /// The lower lip, catching the scene key light.
  static const Color litEdge = Color(0x3DBBD6EE);

  /// Quiet outline. Not a focus colour — state still owns those.
  static const Color hairline = Color(0x59223347);

  /// An engraved plate, optionally tinted by a state colour.
  ///
  /// [stateTone] is passed straight through from the existing seat visual
  /// state, so acting / selectable / focus semantics keep their exact current
  /// meaning and simply gain a physical carrier.
  static BoxDecoration decoration({
    required double radius,
    Color? stateTone,
    double stateStrength = 0,
    Act0SceneLightV1 light = Act0SceneLightV1.canonical,
  }) {
    final tone = stateTone;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          topEdge.withValues(alpha: 0.96),
          recess,
          Color.lerp(recess, litEdge, 0.10)!,
        ],
        stops: const <double>[0, 0.42, 1],
      ),
      border: Border.all(
        color: tone == null || stateStrength <= 0
            ? hairline
            : Color.lerp(hairline, tone, stateStrength.clamp(0.0, 1.0))!,
        width: tone != null && stateStrength > 0 ? 1.15 : 1.0,
      ),
      boxShadow: <BoxShadow>[
        // Contact shadow under the plate: it is set into the surface, so it
        // occludes a little of what is behind it rather than glowing.
        const BoxShadow(
          color: Color(0x730A1220),
          blurRadius: 5,
          offset: Offset(0, 1.5),
        ),
        if (tone != null && stateStrength > 0)
          BoxShadow(
            color: tone.withValues(alpha: 0.16 * stateStrength),
            blurRadius: 9,
          ),
      ],
    );
  }
}
