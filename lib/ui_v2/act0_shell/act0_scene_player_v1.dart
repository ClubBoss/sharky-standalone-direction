import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_depth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_material_v1.dart';

/// Visual Gauntlet B3 — the player embodiment system.
///
/// B1 reserved character-safe volumes; B2 lit them. Neither drew a person.
///
/// The first B3 pass replaced those volumes with single-path silhouettes. That
/// crossed "blob -> human shape" but stopped short: one near-black path per
/// player has no internal form, so six of them read as cutouts rather than as
/// distinct people sitting down. Mastermind called that `INSUFFICIENT`, and
/// correctly placed the fix in B3 — a character *language* is foundational, not
/// polish B7 can retrofit.
///
/// So a figure here is built from parts, not from one fill: hair, head, neck,
/// collar, torso garment, sleeve, cuff, hand. Internal value steps between skin
/// and cloth are what make a 70 px figure read as a person; a rim light alone
/// never will.
///
/// Restraint is a requirement, not a shortcut. The table and the learning
/// objects stay dominant, so the palette is muted into Sharky's Deep Ocean
/// range and every part recedes toward the room as it gets further away.
///
/// B1 geometry and B2 material/lighting are imported, never replaced.

/// Whether a seat is still contesting the pot.
enum Act0ScenePlayerPostureV1 {
  /// Upright, leaning in, hands on the rail.
  inHand,

  /// Sat back, arms down, further into the room haze.
  folded,
}

/// How much internal form a figure gets, by distance.
///
/// Detail must fall off with depth or the far seats become noise competing with
/// the board. Far players stay unmistakably people; they simply stop carrying
/// garment structure the viewer could not resolve anyway.
enum Act0ScenePlayerDetailV1 { far, mid, near }

Act0ScenePlayerDetailV1 act0ScenePlayerDetailForDepthV1(double depth) {
  if (depth <= 0.34) return Act0ScenePlayerDetailV1.far;
  if (depth >= 0.62) return Act0ScenePlayerDetailV1.near;
  return Act0ScenePlayerDetailV1.mid;
}

/// The upper-body garment a player is wearing.
///
/// Each is chosen because it reads differently in *shoulder line and collar* at
/// phone scale, which is the only place clothing can register here.
enum Act0ScenePlayerGarmentV1 {
  /// Structured shoulders, open lapels, lighter inner shirt.
  jacket,

  /// Soft shoulders, hood mass behind the neck.
  hoodie,

  /// Pointed collar.
  shirt,

  /// Plain crew neck.
  tee,
}

/// One of Sharky's player builds.
@immutable
class Act0ScenePlayerArchetypeV1 {
  const Act0ScenePlayerArchetypeV1({
    required this.shoulderHalfWidth,
    required this.headRadius,
    required this.hairMass,
    required this.shoulderSlope,
    required this.leanBias,
    required this.garment,
    required this.skin,
    required this.hair,
    required this.garmentTone,
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

  final Act0ScenePlayerGarmentV1 garment;

  /// Desaturated on purpose. A saturated face at this size pulls attention off
  /// the board, and the scene is lit by a cool lamp, not a studio key.
  final Color skin;

  final Color hair;

  /// Muted into the Deep Ocean range so six players never shout at once.
  final Color garmentTone;

  static const List<Act0ScenePlayerArchetypeV1> family =
      <Act0ScenePlayerArchetypeV1>[
        // Broad, close-cropped, structured jacket, sits square.
        Act0ScenePlayerArchetypeV1(
          shoulderHalfWidth: 0.330,
          headRadius: 0.176,
          hairMass: 0.16,
          shoulderSlope: 0.050,
          leanBias: 0.10,
          garment: Act0ScenePlayerGarmentV1.jacket,
          skin: Color(0xFF8A6350),
          hair: Color(0xFF15100D),
          garmentTone: Color(0xFF2B3C53),
        ),
        // Slighter, full hair, hoodie, sits back a little.
        Act0ScenePlayerArchetypeV1(
          shoulderHalfWidth: 0.262,
          headRadius: 0.166,
          hairMass: 0.72,
          shoulderSlope: 0.088,
          leanBias: -0.06,
          garment: Act0ScenePlayerGarmentV1.hoodie,
          skin: Color(0xFFB08A6E),
          hair: Color(0xFF2C1E17),
          garmentTone: Color(0xFF1F4A46),
        ),
        // Tall and narrow, collared shirt, leans in.
        Act0ScenePlayerArchetypeV1(
          shoulderHalfWidth: 0.276,
          headRadius: 0.158,
          hairMass: 0.34,
          shoulderSlope: 0.100,
          leanBias: 0.20,
          garment: Act0ScenePlayerGarmentV1.shirt,
          skin: Color(0xFF6F5142),
          hair: Color(0xFF191C24),
          garmentTone: Color(0xFF39404E),
        ),
        // Heavy set, low head, plain tee, square shoulders.
        Act0ScenePlayerArchetypeV1(
          shoulderHalfWidth: 0.348,
          headRadius: 0.186,
          hairMass: 0.46,
          shoulderSlope: 0.038,
          leanBias: 0.02,
          garment: Act0ScenePlayerGarmentV1.tee,
          skin: Color(0xFFC09B80),
          hair: Color(0xFF3A2A20),
          garmentTone: Color(0xFF324660),
        ),
      ];
}

/// Deterministic seat -> archetype assignment.
///
/// `String.hashCode` is not stable across runs and evidence captures have to
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
    // Which way this seat turns to face the pot, from its own anchor.
    final facing = ((0.5 - slot.plateAnchor.dx) * 2.4).clamp(-1.0, 1.0);
    final procedural = _Act0ScenePlayerFigurePainterV1(
      archetype: act0ScenePlayerArchetypeForSeatV1(slot.seatId),
      depth: slot.depth,
      facing: facing,
      posture: posture,
      detail: act0ScenePlayerDetailForDepthV1(slot.depth),
      haze: perspective.hazeAt(slot.depth),
      light: light,
    );
    // Cycle B — premium seated-embodiment pilot. Exactly one seat, the
    // far-centre opponent (the only seat whose runtime envelope exposes a
    // coherent unoccluded head+shoulder region), swaps its procedural figure
    // for the authored production render. Every other seat is byte-identical.
    // Geometry, anchors and z-order are untouched: the asset rides the exact
    // volume the procedural painter used.
    final child = Act0ScenePilotCharacterAssetV1.isFarCentrePilotSeat(slot)
        ? _Act0ScenePilotFigureV1(
            size: size,
            haze: perspective.hazeAt(slot.depth),
            folded: posture == Act0ScenePlayerPostureV1.folded,
            fallback: procedural,
          )
        : CustomPaint(painter: procedural);
    return IgnorePointer(
      child: SizedBox(width: size.width, height: size.height, child: child),
    );
  }
}

/// Cycle B pilot: the single authored production opponent render and the
/// deterministic rule for which seat receives it.
class Act0ScenePilotCharacterAssetV1 {
  const Act0ScenePilotCharacterAssetV1._();

  /// The one authored production asset admitted by the Cycle B pilot.
  static const String farCentreAssetPath =
      'assets/act0_characters/opponent_far_centre_in_hand.png';

  /// True for the far-centre opponent seat only.
  ///
  /// Resolved from geometry, not a seat id, so production tables that label the
  /// far-centre seat differently still route correctly: the farthest depth
  /// tier ([Act0ScenePlayerDetailV1.far]) combined with a near-centre plate
  /// anchor uniquely identifies the seat sitting directly across the table
  /// from the learner. Never the hero.
  static bool isFarCentrePilotSeat(Act0SceneSeatSlotV1 slot) {
    if (slot.isHero) return false;
    if (act0ScenePlayerDetailForDepthV1(slot.depth) !=
        Act0ScenePlayerDetailV1.far) {
      return false;
    }
    return (slot.plateAnchor.dx - 0.5).abs() < 0.15;
  }
}

/// Decodes the authored pilot render once and paints it into the seat's exact
/// reserved volume, with the same depth recession the procedural figures carry.
///
/// Until the asset has decoded it paints [fallback] — the procedural figure —
/// so the seat is never blank for a frame.
class _Act0ScenePilotFigureV1 extends StatefulWidget {
  const _Act0ScenePilotFigureV1({
    required this.size,
    required this.haze,
    required this.folded,
    required this.fallback,
  });

  final Size size;
  final double haze;
  final bool folded;
  final _Act0ScenePlayerFigurePainterV1 fallback;

  @override
  State<_Act0ScenePilotFigureV1> createState() =>
      _Act0ScenePilotFigureV1State();
}

class _Act0ScenePilotFigureV1State extends State<_Act0ScenePilotFigureV1> {
  ui.Image? _image;
  Object? _pending;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_image != null) return;
    final token = Object();
    _pending = token;
    const provider = AssetImage(
      Act0ScenePilotCharacterAssetV1.farCentreAssetPath,
    );
    final stream = provider.resolve(createLocalImageConfiguration(context));
    late final ImageStreamListener listener;
    listener = ImageStreamListener((info, _) {
      stream.removeListener(listener);
      if (!mounted || _pending != token) return;
      setState(() => _image = info.image);
    }, onError: (_, __) => stream.removeListener(listener));
    stream.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    if (image == null) {
      return CustomPaint(size: widget.size, painter: widget.fallback);
    }
    return CustomPaint(
      size: widget.size,
      painter: _Act0ScenePilotFigurePainterV1(
        image: image,
        haze: widget.haze,
        folded: widget.folded,
      ),
    );
  }
}

class _Act0ScenePilotFigurePainterV1 extends CustomPainter {
  const _Act0ScenePilotFigurePainterV1({
    required this.image,
    required this.haze,
    required this.folded,
  });

  final ui.Image image;
  final double haze;
  final bool folded;

  /// B2's lit wall tone — the same value the procedural figures recede toward,
  /// so the pilot sits at the same depth as its neighbours.
  static const Color _roomTone = Color(0xFF1B3350);

  @override
  void paint(Canvas canvas, Size size) {
    final dst = Offset.zero & size;
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    // Match `_Act0ScenePlayerFigurePainterV1._recede`: colours lerp toward the
    // room tone by `haze * 0.62`; folded seats recede further.
    final tint = ((haze * 0.62) + (folded ? 0.20 : 0.0)).clamp(0.0, 0.85);
    final opacity = (folded ? 0.72 : 1.0) * (1 - (haze * 0.10));

    canvas.saveLayer(dst, Paint());
    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()
        ..filterQuality = FilterQuality.high
        ..color = Color.fromRGBO(255, 255, 255, opacity.clamp(0.0, 1.0)),
    );
    // srcATop so only the figure's own pixels take the haze, never the
    // transparent margin.
    canvas.drawRect(
      dst,
      Paint()
        ..color = _roomTone.withValues(alpha: tint)
        ..blendMode = BlendMode.srcATop,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _Act0ScenePilotFigurePainterV1 oldDelegate) =>
      !identical(oldDelegate.image, image) ||
      oldDelegate.haze != haze ||
      oldDelegate.folded != folded;
}

class _Act0ScenePlayerFigurePainterV1 extends CustomPainter {
  const _Act0ScenePlayerFigurePainterV1({
    required this.archetype,
    required this.depth,
    required this.facing,
    required this.posture,
    required this.detail,
    required this.haze,
    required this.light,
  });

  final Act0ScenePlayerArchetypeV1 archetype;
  final double depth;
  final double facing;
  final Act0ScenePlayerPostureV1 posture;
  final Act0ScenePlayerDetailV1 detail;
  final double haze;
  final Act0SceneLightV1 light;

  /// B2's lit wall tone. Everything drifts toward it with distance and loses
  /// contrast, which is what stops far players looking like near players drawn
  /// small.
  static const Color _roomTone = Color(0xFF1B3350);

  Color _recede(Color base) => Color.lerp(base, _roomTone, haze * 0.62)!;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final folded = posture == Act0ScenePlayerPostureV1.folded;
    final showsGarmentDetail = detail != Act0ScenePlayerDetailV1.far;
    final showsHands = detail == Act0ScenePlayerDetailV1.near;

    final skin = _recede(archetype.skin);
    final hair = _recede(archetype.hair);
    final cloth = _recede(archetype.garmentTone);
    final clothLit = Color.lerp(cloth, Act0SceneLightV1.specular, 0.16)!;
    final clothShade = Color.lerp(cloth, const Color(0xFF040A12), 0.42)!;

    final lean = (archetype.leanBias + (folded ? -0.26 : 0.10)).clamp(
      -0.4,
      0.4,
    );
    final headR = w * archetype.headRadius;
    final headY = h * (folded ? 0.315 : 0.275);
    final headX = w * (0.5 + (lean * facing * 0.16));
    final shoulderY = h * (folded ? 0.62 : 0.555);
    final halfW = w * archetype.shoulderHalfWidth;
    final tableSide = facing >= 0 ? 1.0 : -1.0;

    // 1. Hood or hair mass behind the head, so the head separates from the
    //    torso before any of it is drawn.
    if (archetype.garment == Act0ScenePlayerGarmentV1.hoodie) {
      canvas.drawCircle(
        Offset(headX, headY + (headR * 0.42)),
        headR * 1.42,
        Paint()..color = clothShade,
      );
    }
    if (archetype.hairMass > 0.05) {
      canvas.drawCircle(
        Offset(headX - (headR * 0.08 * facing), headY - (headR * 0.10)),
        headR * (1.06 + (0.20 * archetype.hairMass)),
        Paint()..color = hair,
      );
    }

    // 2. Neck, in shaded skin. Small, but it is the join that stops a head
    //    reading as a ball resting on a block.
    canvas.drawRect(
      Rect.fromLTRB(
        headX - (headR * 0.40),
        headY + (headR * 0.30),
        headX + (headR * 0.40),
        shoulderY + (h * 0.02),
      ),
      Paint()..color = Color.lerp(skin, clothShade, 0.34)!,
    );

    // 3. Head.
    canvas.drawCircle(Offset(headX, headY), headR, Paint()..color = skin);

    // 4. Hair front, clipped to the skull and offset away from the light so a
    //    forehead stays visible. Silhouette identity lives here.
    if (archetype.hairMass > 0.05) {
      canvas.save();
      canvas.clipPath(
        Path()..addOval(
          Rect.fromCircle(center: Offset(headX, headY), radius: headR * 1.02),
        ),
      );
      canvas.drawCircle(
        Offset(
          headX - (headR * 0.14 * facing),
          headY - (headR * (0.62 - (0.42 * archetype.hairMass))),
        ),
        headR * (0.94 + (0.18 * archetype.hairMass)),
        Paint()..color = hair,
      );
      canvas.restore();
    }

    // 5. Torso garment, cut by the rail at the bottom of the box.
    final torso = Path()
      ..moveTo(headX - (headR * 0.52), shoulderY - (h * 0.085))
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
      ..close();
    canvas.drawPath(
      torso,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[clothLit, cloth, clothShade],
          stops: const <double>[0, 0.42, 1],
        ).createShader(Rect.fromLTWH(0, shoulderY - (h * 0.12), w, h * 0.72)),
    );

    // 6. Collar / neckline: the cheapest garment signal that survives at 70 px,
    //    and the one that actually separates jacket from hoodie from shirt.
    if (showsGarmentDetail) {
      final nx = headX;
      final ny = shoulderY - (h * 0.045);
      final neckline = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.1, w * 0.028)
        ..strokeCap = StrokeCap.round
        ..color = clothShade;
      switch (archetype.garment) {
        case Act0ScenePlayerGarmentV1.jacket:
          canvas.drawPath(
            Path()
              ..moveTo(nx - (headR * 0.52), ny)
              ..lineTo(nx, ny + (h * 0.085))
              ..lineTo(nx + (headR * 0.52), ny)
              ..close(),
            Paint()..color = Color.lerp(cloth, Colors.white, 0.22)!,
          );
          canvas.drawLine(
            Offset(nx - (headR * 0.56), ny - (h * 0.006)),
            Offset(nx - (headR * 0.06), ny + (h * 0.080)),
            neckline,
          );
          canvas.drawLine(
            Offset(nx + (headR * 0.56), ny - (h * 0.006)),
            Offset(nx + (headR * 0.06), ny + (h * 0.080)),
            neckline,
          );
        case Act0ScenePlayerGarmentV1.hoodie:
          canvas.drawArc(
            Rect.fromCenter(
              center: Offset(nx, ny + (h * 0.010)),
              width: headR * 2.5,
              height: h * 0.10,
            ),
            0,
            math.pi,
            false,
            neckline..strokeWidth = math.max(1.4, w * 0.040),
          );
        case Act0ScenePlayerGarmentV1.shirt:
          canvas.drawPath(
            Path()
              ..moveTo(nx - (headR * 0.50), ny)
              ..lineTo(nx - (headR * 0.10), ny + (h * 0.062))
              ..lineTo(nx + (headR * 0.10), ny + (h * 0.062))
              ..lineTo(nx + (headR * 0.50), ny),
            neckline,
          );
        case Act0ScenePlayerGarmentV1.tee:
          canvas.drawArc(
            Rect.fromCenter(
              center: Offset(nx, ny - (h * 0.004)),
              width: headR * 1.7,
              height: h * 0.062,
            ),
            0,
            math.pi,
            false,
            neckline,
          );
      }
    }

    // 7. The near arm, reaching toward the pot and into the rail cut, where B1's
    //    occlusion turns the crop into a hand resting on the wood.
    final reach = folded ? 0.10 : 0.30;
    final shoulderX = w * 0.5 + (halfW * 0.80 * tableSide);
    final handX = shoulderX + (w * reach * tableSide);
    final handY = h * (folded ? 1.0 : 0.86);
    canvas.drawPath(
      Path()
        ..moveTo(shoulderX, shoulderY + (h * 0.01))
        ..quadraticBezierTo(
          shoulderX + (w * 0.10 * tableSide),
          shoulderY + (h * (folded ? 0.26 : 0.17)),
          handX,
          handY,
        ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = w * 0.125
        ..color = cloth,
    );
    if (showsHands && !folded) {
      // Cuff, then a hand. Only near players carry this; at mid and far it
      // would be two pixels of mush.
      canvas.drawCircle(
        Offset(handX, handY),
        w * 0.070,
        Paint()..color = clothShade,
      );
      canvas.drawCircle(
        Offset(handX + (w * 0.030 * tableSide), handY + (h * 0.030)),
        w * 0.058,
        Paint()..color = skin,
      );
    }

    // 8. Rim from the scene key light. Now that the figure has internal form,
    //    the rim describes it rather than substituting for it.
    final rimStrength =
        (0.34 + (0.34 * depth)) * (1 - (haze * 0.40)) * light.intensity;
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.1, w * 0.022)
      ..color = Act0SceneLightV1.specular.withValues(
        alpha: rimStrength.clamp(0.0, 0.80),
      );
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(headX - (headR * 0.06 * facing), headY),
        radius: headR * (1.02 + (0.14 * archetype.hairMass)),
      ),
      math.pi * 1.16,
      math.pi * 0.62,
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
          headX - (headR * 0.44),
          shoulderY - (h * 0.072),
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
      oldDelegate.detail != detail ||
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

// ===========================================================================
// CYCLE C — BOUNDED_SPATIAL_REBALANCE_V1 (experimental)
//
// A tiered opponent layer that approaches the C2 / C2-9 North-Star seating
// grammar with NO camera and NO table-geometry change. It replaces the flat
// single-plane `Act0ScenePlayerLayerV1` on the canonical camera path only.
//
// Three causal moves, all owned here:
//   1. SCENE_WORLD_WIDTH — opponents are laid out in a world wider than the
//      felt (`worldWidenFraction`), so upper/near flanks sit in visible room
//      OUTSIDE the table instead of being hidden behind it.
//   2. SEAT_ANCHOR / PLAYER_VOLUME — each opponent is re-tiered
//      (far-centre / upper-flank / near-flank) with its own anchor, scale and
//      inward orientation, giving a real depth ladder.
//   3. LAYER / OCCLUSION — near-flank opponents render on the FRONT plane
//      (after the table), so the felt edge occludes their outer body the way
//      the hero foreground does, instead of the whole figure hiding behind
//      the rail.
//
// Non-UTG seats use a diagnostic seated-body proxy (head + neck + shoulders +
// torso + chair back + near arm) sized to fill the proposed envelope — enough
// to judge physical seating. It is explicitly NOT production art. UTG reuses
// the Cycle B authored asset as one realistic anchor.
// ===========================================================================

/// Depth tier of a re-tiered opponent seat.
enum Act0SceneOpponentTierV1 { farCentre, upperFlank, nearFlank }

/// Which composited plane a tiered layer paints.
enum Act0SceneTieredPlaneV1 {
  /// Behind the table: far-centre + upper flanks.
  back,

  /// In front of the table edge: near flanks.
  front,
}

/// Re-tiering + re-anchoring rule for the Cycle C spatial rebalance.
@immutable
class Act0SceneTieredSeatingV1 {
  const Act0SceneTieredSeatingV1({
    this.worldWidenFraction = 0.32,
    this.topLiftFraction = 0.06,
    this.bottomDropFraction = 0.04,
  });

  static const Act0SceneTieredSeatingV1 candidateV1 =
      Act0SceneTieredSeatingV1();

  /// How much wider than the felt stage the opponent world is, total
  /// (split evenly left/right).
  final double worldWidenFraction;

  /// How far above the stage the world box starts, as a stage-height fraction.
  final double topLiftFraction;

  /// How far below the stage the world box ends, as a stage-height fraction.
  final double bottomDropFraction;

  Act0SceneOpponentTierV1 tierFor(Act0SceneSeatSlotV1 slot) {
    final offCentre = (slot.plateAnchor.dx - 0.5).abs();
    if (offCentre < 0.15) return Act0SceneOpponentTierV1.farCentre;
    if (slot.depth < 0.5) return Act0SceneOpponentTierV1.upperFlank;
    return Act0SceneOpponentTierV1.nearFlank;
  }

  bool paintsOn(Act0SceneOpponentTierV1 tier, Act0SceneTieredPlaneV1 plane) {
    final front = tier == Act0SceneOpponentTierV1.nearFlank;
    return front == (plane == Act0SceneTieredPlaneV1.front);
  }

  /// Anchor of the figure centre, in *world* fractions (0..1 of the widened
  /// box). `side` is -1 for a left seat, +1 for a right seat.
  Offset worldAnchorFor(Act0SceneOpponentTierV1 tier, double side) {
    switch (tier) {
      case Act0SceneOpponentTierV1.farCentre:
        return const Offset(0.5, 0.085);
      case Act0SceneOpponentTierV1.upperFlank:
        return Offset(side < 0 ? 0.10 : 0.90, 0.27);
      case Act0SceneOpponentTierV1.nearFlank:
        return Offset(side < 0 ? 0.055 : 0.945, 0.80);
    }
  }

  /// Envelope scale multiplier on the seat's base volume.
  double scaleFor(Act0SceneOpponentTierV1 tier) {
    switch (tier) {
      case Act0SceneOpponentTierV1.farCentre:
        return 0.95;
      case Act0SceneOpponentTierV1.upperFlank:
        return 1.35;
      case Act0SceneOpponentTierV1.nearFlank:
        return 1.55;
    }
  }

  /// Inward turn, -1..1, feeding the figure painter's `facing`.
  double facingFor(Act0SceneOpponentTierV1 tier, double side) {
    switch (tier) {
      case Act0SceneOpponentTierV1.farCentre:
        return 0.05;
      case Act0SceneOpponentTierV1.upperFlank:
        return side < 0 ? 0.62 : -0.62;
      case Act0SceneOpponentTierV1.nearFlank:
        return side < 0 ? 0.92 : -0.92;
    }
  }
}

/// The Cycle C tiered opponent layer. Renders exactly the tiers that belong on
/// [plane]; instantiate once per plane inside the scene stack.
class Act0SceneTieredOpponentLayerV1 extends StatelessWidget {
  const Act0SceneTieredOpponentLayerV1({
    super.key,
    required this.slots,
    required this.plane,
    this.foldedSeatIds = const <String>{},
    this.rules = Act0SceneTieredSeatingV1.candidateV1,
    this.light = Act0SceneLightV1.canonical,
    this.perspective = Act0ScenePerspectiveV1.canonical,
  });

  final List<Act0SceneSeatSlotV1> slots;
  final Act0SceneTieredPlaneV1 plane;
  final Set<String> foldedSeatIds;
  final Act0SceneTieredSeatingV1 rules;
  final Act0SceneLightV1 light;
  final Act0ScenePerspectiveV1 perspective;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        if (width <= 0 || height <= 0) return const SizedBox.shrink();

        final opponents = slots.where((s) => !s.isHero).toList()
          ..sort((a, b) => a.depth.compareTo(b.depth));

        final children = <Widget>[];
        for (final slot in opponents) {
          final tier = rules.tierFor(slot);
          if (!rules.paintsOn(tier, plane)) continue;
          final side = slot.plateAnchor.dx < 0.5 ? -1.0 : 1.0;
          final anchor = tier == Act0SceneOpponentTierV1.farCentre
              ? rules.worldAnchorFor(tier, side)
              : rules.worldAnchorFor(tier, side);
          final scale = rules.scaleFor(tier);
          final baseBox = slot.volumeSize(
            width / (1 + rules.worldWidenFraction),
          );
          final box = Size(baseBox.width * scale, baseBox.height * scale);
          final isPilot = Act0ScenePilotCharacterAssetV1.isFarCentrePilotSeat(
            slot,
          );
          final folded = foldedSeatIds.contains(slot.seatId);
          children.add(
            Positioned(
              left: width * anchor.dx,
              top: height * anchor.dy,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: SizedBox(
                  key: Key('act0_scene_player_figure_${slot.seatId}'),
                  width: box.width,
                  height: box.height,
                  child: IgnorePointer(
                    child: isPilot
                        ? Act0ScenePlayerFigureV1(
                            slot: slot,
                            size: box,
                            posture: folded
                                ? Act0ScenePlayerPostureV1.folded
                                : Act0ScenePlayerPostureV1.inHand,
                            light: light,
                            perspective: perspective,
                          )
                        : CustomPaint(
                            size: box,
                            painter: _Act0SceneDiagnosticSeatedProxyPainterV1(
                              tier: tier,
                              side: side,
                              facing: rules.facingFor(tier, side),
                              depth: slot.depth,
                              haze: perspective.hazeAt(slot.depth),
                              folded: folded,
                              archetype: act0ScenePlayerArchetypeForSeatV1(
                                slot.seatId,
                              ),
                              light: light,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          );
        }
        return Stack(clipBehavior: Clip.none, children: children);
      },
    );
  }
}

/// Diagnostic seated-body proxy: enough head / neck / shoulder / torso / chair
/// / arm volume to judge whether an envelope reads as a seated person. NOT
/// production art.
class _Act0SceneDiagnosticSeatedProxyPainterV1 extends CustomPainter {
  const _Act0SceneDiagnosticSeatedProxyPainterV1({
    required this.tier,
    required this.side,
    required this.facing,
    required this.depth,
    required this.haze,
    required this.folded,
    required this.archetype,
    required this.light,
  });

  final Act0SceneOpponentTierV1 tier;
  final double side;
  final double facing;
  final double depth;
  final double haze;
  final bool folded;
  final Act0ScenePlayerArchetypeV1 archetype;
  final Act0SceneLightV1 light;

  static const Color _roomTone = Color(0xFF1B3350);

  Color _recede(Color base) => Color.lerp(base, _roomTone, haze * 0.62)!;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final skin = _recede(archetype.skin);
    final hair = _recede(archetype.hair);
    final cloth = _recede(archetype.garmentTone);
    final clothShade = Color.lerp(cloth, const Color(0xFF040A12), 0.45)!;
    final chair = Color.lerp(clothShade, _roomTone, 0.35)!;

    // Head sits high in the box; the near tier crops tighter so its large
    // envelope reads as head + shoulder + arm rather than a torso over the felt.
    final headCY =
        h * (tier == Act0SceneOpponentTierV1.nearFlank ? 0.22 : 0.30);
    final headR =
        w * (tier == Act0SceneOpponentTierV1.nearFlank ? 0.185 : 0.22);
    final headCX = w * (0.5 + (facing * 0.08));
    final shoulderY = headCY + (headR * 1.7);
    final shoulderHalf = w * (folded ? 0.30 : 0.36);

    // Chair back — the furniture mass that reads as "seated".
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          headCX - shoulderHalf * 1.15,
          headCY - headR * 0.4,
          shoulderHalf * 2.3,
          h - (headCY - headR * 0.4),
        ),
        Radius.circular(w * 0.16),
      ),
      Paint()..color = chair,
    );

    // Torso — tapers from shoulders to the bottom of frame.
    final torso = Path()
      ..moveTo(headCX - shoulderHalf, shoulderY)
      ..quadraticBezierTo(
        headCX - shoulderHalf * 1.02,
        shoulderY + (h - shoulderY) * 0.5,
        headCX - shoulderHalf * 0.86,
        h,
      )
      ..lineTo(headCX + shoulderHalf * 0.86, h)
      ..quadraticBezierTo(
        headCX + shoulderHalf * 1.02,
        shoulderY + (h - shoulderY) * 0.5,
        headCX + shoulderHalf,
        shoulderY,
      )
      ..quadraticBezierTo(
        headCX,
        shoulderY - headR * 0.9,
        headCX - shoulderHalf,
        shoulderY,
      )
      ..close();
    canvas.drawPath(
      torso,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.lerp(cloth, Act0SceneLightV1.specular, 0.12)!,
            cloth,
            clothShade,
          ],
          stops: const <double>[0, 0.4, 1],
        ).createShader(Rect.fromLTWH(0, shoulderY - h * 0.1, w, h)),
    );

    // Near arm reaching toward the felt / rail.
    if (tier != Act0SceneOpponentTierV1.farCentre && !folded) {
      final ax = headCX + (shoulderHalf * 0.7 * facing.sign);
      canvas.drawPath(
        Path()
          ..moveTo(ax, shoulderY + h * 0.02)
          ..quadraticBezierTo(
            ax + (w * 0.16 * facing.sign),
            shoulderY + (h - shoulderY) * 0.42,
            headCX + (w * 0.34 * facing.sign),
            h * 0.92,
          ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = w * 0.16
          ..color = cloth,
      );
    }

    // Neck + head.
    canvas.drawRect(
      Rect.fromLTRB(
        headCX - headR * 0.42,
        headCY + headR * 0.35,
        headCX + headR * 0.42,
        shoulderY + h * 0.01,
      ),
      Paint()..color = Color.lerp(skin, clothShade, 0.4)!,
    );
    if (archetype.hairMass > 0.05) {
      canvas.drawCircle(
        Offset(headCX - headR * 0.08 * facing.sign, headCY - headR * 0.12),
        headR * (1.05 + 0.2 * archetype.hairMass),
        Paint()..color = hair,
      );
    }
    canvas.drawCircle(Offset(headCX, headCY), headR, Paint()..color = skin);
    if (archetype.hairMass > 0.05) {
      canvas.save();
      canvas.clipPath(
        Path()..addOval(
          Rect.fromCircle(center: Offset(headCX, headCY), radius: headR * 1.02),
        ),
      );
      canvas.drawCircle(
        Offset(
          headCX - headR * 0.16 * facing.sign,
          headCY - headR * (0.55 - 0.4 * archetype.hairMass),
        ),
        headR * (0.95 + 0.16 * archetype.hairMass),
        Paint()..color = hair,
      );
      canvas.restore();
    }

    // Key-light rim along the head + inner shoulder.
    final rimStrength =
        (0.30 + 0.34 * depth) * (1 - haze * 0.4) * light.intensity;
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.1, w * 0.02)
      ..color = Act0SceneLightV1.specular.withValues(
        alpha: rimStrength.clamp(0.0, 0.8),
      );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(headCX, headCY), radius: headR * 1.03),
      math.pi * 1.15,
      math.pi * 0.7,
      false,
      rim,
    );
  }

  @override
  bool shouldRepaint(
    covariant _Act0SceneDiagnosticSeatedProxyPainterV1 oldDelegate,
  ) =>
      oldDelegate.tier != tier ||
      oldDelegate.facing != facing ||
      oldDelegate.depth != depth ||
      oldDelegate.haze != haze ||
      oldDelegate.folded != folded ||
      oldDelegate.archetype != archetype ||
      oldDelegate.light.intensity != light.intensity;
}

/// The learner, from the learner's own seat.
///
/// Strictly first-person: sleeves, cuffs and the backs of the hands on the
/// cloth, plus the shoulder line at the bottom of frame. No frontal avatar —
/// the hero is the camera, and drawing a face here would break the spatial
/// premise the whole scene rests on.
///
/// The arms are routed outside the hole-card lane, the identity plate and the
/// dealer button. They frame the learner's hand; they never cover it.
class Act0ScenePlayerHeroV1 extends StatelessWidget {
  const Act0ScenePlayerHeroV1({
    super.key,
    this.light = Act0SceneLightV1.canonical,
  });

  final Act0SceneLightV1 light;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          widthFactor: 0.74,
          heightFactor: 0.19,
          child: FractionalTranslation(
            translation: const Offset(0, 0.80),
            child: CustomPaint(
              painter: _Act0ScenePlayerHeroPainterV1(light: light),
            ),
          ),
        ),
      ),
    );
  }
}

class _Act0ScenePlayerHeroPainterV1 extends CustomPainter {
  const _Act0ScenePlayerHeroPainterV1({required this.light});

  final Act0SceneLightV1 light;

  /// The learner's own sleeve. Closest thing to the camera and out of the
  /// lamp's throw, so it stays the darkest cloth in the scene — but it is
  /// cloth, with a cuff and a hand, not a black bar.
  static const Color _sleeve = Color(0xFF1B2740);
  static const Color _sleeveShade = Color(0xFF080D16);
  static const Color _cuff = Color(0xFF2C3B58);
  static const Color _skin = Color(0xFF7C5A4A);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final sleeveShader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const <Color>[_sleeve, _sleeveShade],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    for (final side in const <double>[-1, 1]) {
      canvas.drawPath(
        Path()
          ..moveTo(w * (0.5 + (0.42 * side)), h * 0.94)
          ..quadraticBezierTo(
            w * (0.5 + (0.47 * side)),
            h * 0.44,
            w * (0.5 + (0.455 * side)),
            h * 0.10,
          ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = h * 0.17
          ..shader = sleeveShader,
      );
      // Cuff, then the back of the hand resting on the cloth. Drawn as a flat
      // oval rather than a disc: a circle at this size reads as a knob or a
      // chip, which is the last thing the near rail needs.
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * (0.5 + (0.457 * side)), h * 0.185),
          width: h * 0.20,
          height: h * 0.13,
        ),
        Paint()..color = _cuff,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * (0.5 + (0.449 * side)), h * 0.095),
          width: h * 0.175,
          height: h * 0.105,
        ),
        Paint()..color = _skin,
      );
    }

    // Shoulder line, cropped by the action dock below.
    final shoulders = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.70)
      ..cubicTo(w * 0.14, h * 0.60, w * 0.26, h * 0.53, w * 0.335, h * 0.46)
      ..cubicTo(w * 0.352, h * 0.06, w * 0.648, h * 0.06, w * 0.665, h * 0.46)
      ..cubicTo(w * 0.74, h * 0.53, w * 0.86, h * 0.60, w, h * 0.70)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(shoulders, Paint()..shader = sleeveShader);

    // The overhead lamp catching the top of the learner's head and shoulders.
    canvas.drawPath(
      shoulders,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.3, h * 0.034)
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Act0SceneLightV1.specular.withValues(alpha: 0.58 * light.intensity),
            Act0SceneLightV1.specular.withValues(alpha: 0.05),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.74)),
    );
  }

  @override
  bool shouldRepaint(covariant _Act0ScenePlayerHeroPainterV1 oldDelegate) =>
      oldDelegate.light.intensity != light.intensity;
}
