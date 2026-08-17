import 'dart:math' as math;

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

/// The dealer button, as an object resting on the cloth.
///
/// Wave A expressed the same dealer semantic as a flat white capsule with a
/// letter in it — a Flutter chip floating above the scene. The semantic is
/// unchanged here; only its physical expression is. A real dealer button is a
/// pressed disc: bright where it faces the lamp, shadowed on the far side,
/// with a milled edge and an engraved face.
class Act0SceneDealerPuckV1 extends StatelessWidget {
  const Act0SceneDealerPuckV1({
    super.key,
    this.diameter = 18,
    this.light = Act0SceneLightV1.canonical,
  });

  final double diameter;
  final Act0SceneLightV1 light;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: _Act0SceneDealerPuckPainterV1(light: light),
        child: Center(
          child: Text(
            'D',
            style: TextStyle(
              color: const Color(0xFF16222F),
              fontSize: diameter * 0.47,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _Act0SceneDealerPuckPainterV1 extends CustomPainter {
  const _Act0SceneDealerPuckPainterV1({required this.light});

  final Act0SceneLightV1 light;

  static const Color _faceLit = Color(0xFFF6F9FC);
  static const Color _faceShade = Color(0xFFB9C7D6);
  static const Color _edge = Color(0xFF7C8DA0);
  static const Color _ink = Color(0xFF16222F);

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);

    // Contact shadow on the cloth. Tight and offset with the lamp, so the puck
    // sits on the surface instead of hovering over it.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(r, r + (size.height * 0.10)),
        width: size.width * 0.94,
        height: size.height * 0.70,
      ),
      Paint()
        ..color = const Color(0x8C020609)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.4),
    );

    // Milled edge.
    canvas.drawCircle(c, r, Paint()..color = _edge);

    // Face, lit from the same lamp as the rail crown.
    canvas.drawCircle(
      c,
      r * 0.90,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 1.0,
          colors: const <Color>[_faceLit, _faceShade],
        ).createShader(Rect.fromCircle(center: c, radius: r * 0.90)),
    );

    // Engraved ring inside the rim.
    canvas.drawCircle(
      c,
      r * 0.72,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.7, r * 0.075)
        ..color = _edge.withValues(alpha: 0.42),
    );
  }

  @override
  bool shouldRepaint(covariant _Act0SceneDealerPuckPainterV1 oldDelegate) =>
      oldDelegate.light.intensity != light.intensity;
}

/// Corner brackets clamped to the exact object a Wave A clue is about.
///
/// Wave A already decides which table object is causal and already says so in
/// copy. What it lacked was a mark that visibly *belongs* to that object: a
/// gold border plus a diffuse glow reads as a tint, not as a pointer.
///
/// Brackets clamp to the object's own corners, so the marker cannot be mistaken
/// for a card style or drift onto a neighbour. This is deliberately local — no
/// dimming, no blur, no scene-wide treatment. Attention-aware rendering is B5.
class Act0SceneClueBracketPainterV1 extends CustomPainter {
  const Act0SceneClueBracketPainterV1({required this.tone, this.inset = 1.4});

  /// The existing Wave A clue colour, passed through unchanged.
  final Color tone;

  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final arm = math.min(size.width, size.height) * 0.30;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, size.width * 0.075)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = tone;

    final l = inset;
    final t = inset;
    final r = size.width - inset;
    final b = size.height - inset;

    canvas.drawPath(
      Path()
        ..moveTo(l, t + arm)
        ..lineTo(l, t)
        ..lineTo(l + arm, t)
        ..moveTo(r - arm, t)
        ..lineTo(r, t)
        ..lineTo(r, t + arm)
        ..moveTo(r, b - arm)
        ..lineTo(r, b)
        ..lineTo(r - arm, b)
        ..moveTo(l + arm, b)
        ..lineTo(l, b)
        ..lineTo(l, b - arm),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant Act0SceneClueBracketPainterV1 oldDelegate) =>
      oldDelegate.tone != tone || oldDelegate.inset != inset;
}
