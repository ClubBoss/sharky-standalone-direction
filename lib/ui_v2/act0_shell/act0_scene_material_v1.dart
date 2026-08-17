import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_depth_v1.dart';

/// Visual Gauntlet B2 — the material and lighting layer of the learning scene.
///
/// B1 made the scene spatially correct: planes, perspective, seat slots, hero
/// ownership. Underneath that geometry the table had almost no material. The
/// rail was a flat 10 px band — `railInner`, `railMid` and `railOuter` were
/// literally the same colour — finished with a neon cyan outline, which is why
/// the scene still read as a styled Flutter shape rather than a physical
/// object.
///
/// This module owns the answer: one key light, a rail with real volume, and
/// cloth that behaves like cloth. Every highlight in the scene derives from
/// [Act0SceneLightV1] so nothing glows on its own.
///
/// B1 geometry is imported, never replaced. The rail band keeps its existing
/// padding, so all new volume is painted rather than laid out and the B1 seat
/// anchors and table allocation stay byte-identical.

/// The scene's single key light.
///
/// A lamp above the table and slightly toward the viewer. Rail crown specular,
/// felt pool, distance falloff, player-volume rim and hero rim all resolve
/// against this one source.
@immutable
class Act0SceneLightV1 {
  const Act0SceneLightV1({
    this.origin = const Alignment(0, -0.58),
    this.intensity = 1.0,
  });

  static const Act0SceneLightV1 canonical = Act0SceneLightV1();

  /// Where the lamp sits in scene space.
  final Alignment origin;

  /// Global multiplier, so the whole scene can be dimmed coherently.
  final double intensity;

  /// Cool specular returned by hard, semi-gloss surfaces (the rail).
  static const Color specular = Color(0xFFBBD6EE);

  /// Warm-neutral ambient of the room.
  static const Color ambient = Color(0xFF25405C);

  /// Green bounce thrown back up off the cloth onto the rail's inner bevel.
  static const Color feltBounce = Color(0xFF2F6D5C);

  /// How strongly a surface at [depth] is lit. Light falls off toward the far
  /// rail, which is what gives the cloth its distance gradient.
  double falloffAt(double depth) =>
      (0.52 + (0.48 * depth.clamp(0.0, 1.0))) * intensity;
}

/// Paints the table as a physical object: rail volume plus its shadows.
///
/// Draws BEHIND the table's children, so the felt and everything standing on it
/// cover the middle and only the rail band remains visible. That ordering is
/// deliberate — a foreground pass would paint over seat plates that sit close to
/// the felt edge.
class Act0SceneTableMaterialPainterV1 extends CustomPainter {
  const Act0SceneTableMaterialPainterV1({
    this.light = Act0SceneLightV1.canonical,
    this.railWidth = 10.0,
    this.railOverhang = 5.0,
    this.perspective = Act0ScenePerspectiveV1.canonical,
  });

  final Act0SceneLightV1 light;

  /// Felt inset, matching the table's padding.
  final double railWidth;

  /// How far the rail stands proud of the silhouette, into the room. Volume is
  /// gained outward so the playing surface keeps its B1 geometry exactly.
  final double railOverhang;

  final Act0ScenePerspectiveV1 perspective;

  /// Rail material, navy leather rather than borrowed reference wood. Gold is
  /// deliberately absent — it stays reserved for mastery and reward.
  static const Color _outerWall = Color(0xFF060E1A);
  static const Color _bodyDeep = Color(0xFF16293F);
  static const Color _bodyMid = Color(0xFF27456A);
  static const Color _crown = Color(0xFF3E6A93);

  Path _outerPath(Size size) => Act0SceneTableShapeV1(
    perspective: perspective,
  ).getOuterPath((Offset.zero & size).inflate(railOverhang));

  Path _innerPath(Size size) => Act0SceneTableShapeV1(
    perspective: perspective,
  ).getOuterPath((Offset.zero & size).deflate(railWidth));

  @override
  void paint(Canvas canvas, Size size) {
    final outer = _outerPath(size);
    final inner = _innerPath(size);
    final rect = Offset.zero & size;

    // Contact shadow. The table sits on the floor rather than hovering above a
    // blurred rectangle, so the shadow follows the silhouette.
    canvas.save();
    canvas.translate(0, size.height * 0.018);
    canvas.drawPath(
      outer,
      Paint()
        ..color = const Color(0xCC01050B)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.restore();

    // Rail body. The crown is brightest where it faces the lamp and falls away
    // toward the near edge, which is below and behind the light.
    canvas.drawPath(
      outer,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.lerp(_bodyMid, _crown, 0.85 * light.intensity)!,
            _bodyMid,
            _bodyDeep,
          ],
          stops: const <double>[0, 0.46, 1],
        ).createShader(rect),
    );

    // The rail band is the only part of this painter the viewer ever sees; the
    // felt covers the rest. Clipping to the band keeps every later stroke
    // physically confined to the rail.
    final band = Path.combine(PathOperation.difference, outer, inner);

    canvas.save();
    canvas.clipPath(band);

    // Directional crown specular: a broad soft highlight centred on the lamp.
    final specularRect = Rect.fromCenter(
      center: Offset(
        size.width * (0.5 + (light.origin.x * 0.5)),
        size.height * (0.5 + (light.origin.y * 0.5)),
      ),
      width: size.width * 1.7,
      height: size.height * 1.25,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            Act0SceneLightV1.specular.withValues(alpha: 0.30 * light.intensity),
            Act0SceneLightV1.specular.withValues(alpha: 0.09 * light.intensity),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.46, 1],
        ).createShader(specularRect),
    );

    // A tighter hot line along the far rail crown, where the surface turns most
    // directly into the lamp. This is the strongest single "hard material" cue.
    canvas.drawPath(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = railWidth * 0.42
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2)
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Act0SceneLightV1.specular.withValues(alpha: 0.52 * light.intensity),
            Act0SceneLightV1.specular.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.34, 0.62],
        ).createShader(rect),
    );

    canvas.restore();

    // Outer wall: the rail's shadowed vertical face and the silhouette's
    // definition. This replaces the neon outline that made the table read as a
    // widget — a real table is defined by a dark edge, not a lit one.
    canvas.drawPath(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = _outerWall.withValues(alpha: 0.92),
    );

    // Inner bevel: the rail turning down into the cloth, picking up green
    // bounce from the felt directly below it.
    canvas.drawPath(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Act0SceneLightV1.feltBounce.withValues(
          alpha: 0.55 * light.intensity,
        ),
    );
  }

  @override
  bool shouldRepaint(covariant Act0SceneTableMaterialPainterV1 oldDelegate) =>
      oldDelegate.light.intensity != light.intensity ||
      oldDelegate.light.origin != light.origin ||
      oldDelegate.railWidth != railWidth ||
      oldDelegate.railOverhang != railOverhang;
}

/// Paints the cloth as a matte surface under the same key light.
///
/// Cloth absorbs where the rail returns a specular. That contrast — not either
/// surface on its own — is what reads as "materials".
class Act0SceneFeltMaterialPainterV1 extends CustomPainter {
  const Act0SceneFeltMaterialPainterV1({
    this.light = Act0SceneLightV1.canonical,
    this.perspective = Act0ScenePerspectiveV1.canonical,
  });

  final Act0SceneLightV1 light;
  final Act0ScenePerspectiveV1 perspective;

  static const Color _shade = Color(0xFF04140F);
  static const Color _lit = Color(0xFF33A184);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final surface = Act0SceneTableShapeV1(
      perspective: perspective,
    ).getOuterPath(rect);

    canvas.save();
    canvas.clipPath(surface);

    // Distance falloff: the far end of the cloth is further from the lamp and
    // reads darker. This is most of what sells the table's length.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            _shade.withValues(alpha: 0.34),
            _shade.withValues(alpha: 0.10),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.34, 0.66],
        ).createShader(rect),
    );

    // Key pool on the cloth, centred under the lamp.
    final pool = Rect.fromCenter(
      center: Offset(
        size.width * (0.5 + (light.origin.x * 0.34)),
        size.height * (0.5 + (light.origin.y * 0.30)),
      ),
      width: size.width * 1.34,
      height: size.height * 0.92,
    );
    canvas.drawOval(
      pool,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            _lit.withValues(alpha: 0.38 * light.intensity),
            _lit.withValues(alpha: 0.14 * light.intensity),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.52, 1],
        ).createShader(pool),
    );

    // Nap sheen: a soft diagonal band, the way brushed cloth catches a raking
    // light. Kept low so it reads as texture, never as a gradient.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: const Alignment(-1, -0.75),
          end: const Alignment(1, 0.75),
          colors: <Color>[
            Colors.transparent,
            Colors.white.withValues(alpha: 0.035 * light.intensity),
            Colors.transparent,
          ],
          stops: const <double>[0.24, 0.5, 0.78],
        ).createShader(rect),
    );

    // The rail's cast shadow on the cloth. This is the single cue that proves
    // the rail is raised above the surface rather than drawn onto it.
    canvas.drawPath(
      surface,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(5.0, size.width * 0.026)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.5)
        ..color = _shade.withValues(alpha: 0.52),
    );

    // Edge absorption: cloth darkens as it curves away into the rail.
    canvas.drawPath(
      surface,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = _shade.withValues(alpha: 0.55),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant Act0SceneFeltMaterialPainterV1 oldDelegate) =>
      oldDelegate.light.intensity != light.intensity ||
      oldDelegate.light.origin != light.origin;
}
