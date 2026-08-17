import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_depth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_material_v1.dart';

/// Visual Gauntlet B3 — the player embodiment system.
///
/// B1 reserved character-safe volumes; B2 lit them. Neither drew a person. What
/// shipped was a rounded-rect chair, a capsule and a circle — the "circles with
/// shoulders" the B3 acceptance bar rejects outright.
///
/// This module draws Sharky's own players. Deliberately vector and deliberately
/// faceless: at the size that actually ships here, 60-110 px tall on a phone, a
/// face is six pixels and can only become noise. Identity comes from silhouette
/// and posture instead, in the priority order the admission sets — silhouette,
/// body language, depth, lighting, differentiation, and only then detail.
///
/// Two ideas do most of the work:
///
/// 1. **Arms.** A seated poker player is recognised by forearms resting on the
///    rail, not by a head. B1's plane order already has the rail cutting across
///    these volumes, so arms drawn reaching into that cut read as hands on the
///    rail for free.
/// 2. **Figure-ground by value.** Far players are dark against B2's lit wall;
///    near players lift as they approach the lamp and the room behind them
///    falls to floor tone. The figure's value is always the inverse of what is
///    behind it, which is what makes a silhouette legible at all.
///
/// B1 geometry and B2 material are imported, never replaced.

/// Whether a seat is still contesting the pot.
///
/// Posture carries this, not opacity alone. Only the two states Wave A already
/// exposes are modelled; B3 invents no new seat semantics.
enum Act0ScenePlayerPostureV1 {
  /// Upright, leaning in, hands on the rail.
  inHand,

  /// Sat back, arms down, further into the room haze.
  folded,
}

/// One of Sharky's player builds.
///
/// Four archetypes are enough for a six-max table to stop reading as identical
/// mannequins, and few enough that the family still looks like one family.
@immutable
class Act0ScenePlayerArchetypeV1 {
  const Act0ScenePlayerArchetypeV1({
    required this.shoulderHalfWidth,
    required this.headRadius,
    required this.hairMass,
    required this.shoulderSlope,
    required this.leanBias,
  });

  /// Half the shoulder span, as a fraction of the volume width.
  final double shoulderHalfWidth;

  /// Head radius, as a fraction of the volume width.
  final double headRadius;

  /// `0` close-cropped, `1` a full silhouette of hair.
  final double hairMass;

  /// How far the shoulders drop from neck to deltoid.
  final double shoulderSlope;

  /// Resting forward lean, before posture is applied.
  final double leanBias;

  static const List<Act0ScenePlayerArchetypeV1> family =
      <Act0ScenePlayerArchetypeV1>[
        // Broad, close-cropped, sits square.
        Act0ScenePlayerArchetypeV1(
          shoulderHalfWidth: 0.315,
          headRadius: 0.178,
          hairMass: 0.12,
          shoulderSlope: 0.055,
          leanBias: 0.10,
        ),
        // Slighter, fuller hair, sits back a little.
        Act0ScenePlayerArchetypeV1(
          shoulderHalfWidth: 0.262,
          headRadius: 0.168,
          hairMass: 0.62,
          shoulderSlope: 0.085,
          leanBias: -0.06,
        ),
        // Tall and narrow, leans in.
        Act0ScenePlayerArchetypeV1(
          shoulderHalfWidth: 0.275,
          headRadius: 0.160,
          hairMass: 0.30,
          shoulderSlope: 0.100,
          leanBias: 0.20,
        ),
        // Heavy set, low head, square shoulders.
        Act0ScenePlayerArchetypeV1(
          shoulderHalfWidth: 0.340,
          headRadius: 0.188,
          hairMass: 0.45,
          shoulderSlope: 0.040,
          leanBias: 0.02,
        ),
      ];
}

/// Deterministic seat -> archetype assignment.
///
/// `String.hashCode` is not stable across runs, and evidence captures have to
/// reproduce exactly, so this hashes the seat id itself.
Act0ScenePlayerArchetypeV1 act0ScenePlayerArchetypeForSeatV1(String seatId) {
  var hash = 7;
  for (final unit in seatId.codeUnits) {
    hash = ((hash * 31) + unit) & 0x7fffffff;
  }
  return Act0ScenePlayerArchetypeV1.family[hash %
      Act0ScenePlayerArchetypeV1.family.length];
}

/// A seated player.
class Act0ScenePlayerFigureV1 extends StatelessWidget {
  const Act0ScenePlayerFigureV1({
    super.key,
    required this.slot,
    required this.size,
    required this.posture,
    this.light = Act0SceneLightV1.canonical,
    this.perspective = Act0ScenePerspectiveV1.canonical,
  });

  final Act0SceneSeatSlotV1 slot;
  final Size size;
  final Act0ScenePlayerPostureV1 posture;
  final Act0SceneLightV1 light;
  final Act0ScenePerspectiveV1 perspective;

  @override
  Widget build(BuildContext context) {
    // Which way this seat turns to face the pot, from its own anchor. Players
    // on the left of the table turn right, and vice versa.
    final facing = ((0.5 - slot.plateAnchor.dx) * 2.4).clamp(-1.0, 1.0);
    return IgnorePointer(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: CustomPaint(
          painter: _Act0ScenePlayerFigurePainterV1(
            archetype: act0ScenePlayerArchetypeForSeatV1(slot.seatId),
            depth: slot.depth,
            facing: facing,
            posture: posture,
            haze: perspective.hazeAt(slot.depth),
            light: light,
          ),
        ),
      ),
    );
  }
}

class _Act0ScenePlayerFigurePainterV1 extends CustomPainter {
  const _Act0ScenePlayerFigurePainterV1({
    required this.archetype,
    required this.depth,
    required this.facing,
    required this.posture,
    required this.haze,
    required this.light,
  });

  final Act0ScenePlayerArchetypeV1 archetype;
  final double depth;
  final double facing;
  final Act0ScenePlayerPostureV1 posture;
  final double haze;
  final Act0SceneLightV1 light;

  /// Far players sit against B2's lit wall, so they read dark. Near players sit
  /// against the darker floor and closer to the lamp, so they lift.
  static const Color _figureFar = Color(0xFF040A12);
  static const Color _figureNear = Color(0xFF2A4667);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final folded = posture == Act0ScenePlayerPostureV1.folded;

    final figure = Color.lerp(_figureFar, _figureNear, depth)!;
    final lean = (archetype.leanBias + (folded ? -0.26 : 0.10)).clamp(
      -0.4,
      0.4,
    );

    // No chair mass. The first build drew a rounded-rect chair wider than the
    // player, and it became the dominant shape — the figure read as furniture.
    // A seated player is legible from head and shoulders alone.

    // The whole person is one path filled once. Stacking separate shapes is
    // what made the old volume read as parts rather than a silhouette.
    final body = Paint()..color = figure;

    final headR = w * archetype.headRadius;
    final headY = h * (folded ? 0.315 : 0.275);
    final headX = w * (0.5 + (lean * facing * 0.16));
    final shoulderY = h * (folded ? 0.62 : 0.555);
    final halfW = w * archetype.shoulderHalfWidth;

    // Torso: neck into shoulders, then down past the bottom of the box, where
    // the rail crops it.
    final torso = Path()
      ..moveTo(headX - (headR * 0.44), headY + (headR * 0.62))
      ..lineTo(headX - (headR * 0.52), shoulderY - (h * 0.085))
      ..cubicTo(
        headX - halfW * 0.55,
        shoulderY - (h * archetype.shoulderSlope * 0.6),
        w * 0.5 - halfW * 0.92,
        shoulderY - (h * archetype.shoulderSlope),
        w * 0.5 - halfW,
        shoulderY + (h * 0.02),
      )
      ..lineTo(w * 0.5 - (halfW * 1.02), h)
      ..lineTo(w * 0.5 + (halfW * 1.02), h)
      ..lineTo(w * 0.5 + halfW, shoulderY + (h * 0.02))
      ..cubicTo(
        w * 0.5 + halfW * 0.92,
        shoulderY - (h * archetype.shoulderSlope),
        headX + halfW * 0.55,
        shoulderY - (h * archetype.shoulderSlope * 0.6),
        headX + (headR * 0.52),
        shoulderY - (h * 0.085),
      )
      ..lineTo(headX + (headR * 0.44), headY + (headR * 0.62))
      ..close();
    canvas.drawPath(torso, body);

    // The near arm, reaching toward the pot. One arm, on the table side: two
    // symmetric arms made the figure read frontally, and the outer one swept
    // away from the table, which is the opposite of the cue we want.
    final tableSide = facing >= 0 ? 1.0 : -1.0;
    final shoulderX = w * 0.5 + (halfW * 0.80 * tableSide);
    final reach = folded ? 0.10 : 0.30;
    canvas.drawPath(
      Path()
        ..moveTo(shoulderX, shoulderY + (h * 0.01))
        ..quadraticBezierTo(
          shoulderX + (w * 0.10 * tableSide),
          shoulderY + (h * (folded ? 0.26 : 0.17)),
          shoulderX + (w * reach * tableSide),
          h * (folded ? 1.0 : 0.86),
        ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = w * 0.125
        ..color = figure,
    );

    // Head and hair as one mass with the body.
    canvas.drawCircle(Offset(headX, headY), headR, body);
    if (archetype.hairMass > 0.05) {
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(
            headX - (headR * 0.10 * facing),
            headY - (headR * 0.06),
          ),
          radius: headR * (1.0 + (0.22 * archetype.hairMass)),
        ),
        math.pi * 0.96,
        math.pi * (0.62 + (0.42 * archetype.hairMass)),
        true,
        body,
      );
    }

    // Rim from the scene key light, above and slightly forward. Only the top of
    // the head and the near shoulder catch it, which is what turns a flat
    // silhouette into a body in a lit room.
    final rimStrength =
        (0.46 + (0.40 * depth)) * (1 - (haze * 0.35)) * light.intensity;
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.2, w * 0.026)
      ..color = Act0SceneLightV1.specular.withValues(
        alpha: rimStrength.clamp(0.0, 0.85),
      );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(headX, headY), radius: headR * 1.02),
      math.pi * 1.16,
      math.pi * 0.66,
      false,
      rim,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5 - (halfW * 0.94), shoulderY + (h * 0.005))
        ..cubicTo(
          w * 0.5 - halfW * 0.80,
          shoulderY - (h * archetype.shoulderSlope * 1.05),
          headX - (headR * 0.60),
          shoulderY - (h * 0.062),
          headX - (headR * 0.42),
          shoulderY - (h * 0.070),
        ),
      rim,
    );
  }

  @override
  bool shouldRepaint(covariant _Act0ScenePlayerFigurePainterV1 oldDelegate) =>
      oldDelegate.archetype != archetype ||
      oldDelegate.depth != depth ||
      oldDelegate.facing != facing ||
      oldDelegate.posture != posture ||
      oldDelegate.haze != haze ||
      oldDelegate.light.intensity != light.intensity;
}

/// The `farPlayer` plane, now inhabited.
///
/// Replaces B1's `Act0SceneVolumeLayerV1`. Placement, ordering and every anchor
/// come from B1 unchanged — B3 changes who stands in the volume, not where the
/// volume is.
class Act0ScenePlayerLayerV1 extends StatelessWidget {
  const Act0ScenePlayerLayerV1({
    super.key,
    required this.slots,
    this.foldedSeatIds = const <String>{},
    this.light = Act0SceneLightV1.canonical,
    this.perspective = Act0ScenePerspectiveV1.canonical,
  });

  final List<Act0SceneSeatSlotV1> slots;

  /// Seats no longer contesting the pot.
  final Set<String> foldedSeatIds;

  final Act0SceneLightV1 light;
  final Act0ScenePerspectiveV1 perspective;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        if (width <= 0 || height <= 0) return const SizedBox.shrink();

        // Far first, so nearer players overlap their neighbours correctly.
        final ordered = [...slots.where((slot) => !slot.isHero)]
          ..sort((a, b) => a.depth.compareTo(b.depth));

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (final slot in ordered)
              Positioned(
                left: width * slot.characterAnchor.dx,
                top: height * slot.characterAnchor.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: Act0ScenePlayerFigureV1(
                    key: Key('act0_scene_player_figure_${slot.seatId}'),
                    slot: slot,
                    size: slot.volumeSize(width),
                    posture: foldedSeatIds.contains(slot.seatId)
                        ? Act0ScenePlayerPostureV1.folded
                        : Act0ScenePlayerPostureV1.inHand,
                    light: light,
                    perspective: perspective,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Lerp helper kept local so the module owns its own maths.
double act0ScenePlayerLerpV1(double a, double b, double t) =>
    lerpDouble(a, b, t.clamp(0.0, 1.0))!;
