import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_tokens_v1.dart';

/// Visual Gauntlet B1 — the single owner of learning-scene space.
///
/// Before B1 the canonical learning scene carried a token perspective gesture:
/// a ~0.82 silhouette taper and a 15% seat-scale range, both below the
/// threshold at which a viewer reads depth at all. Worse, each element derived
/// its own numbers, so nothing agreed about where "far" was.
///
/// This module replaces that with one projection. Every scene element — rail,
/// seats, player volumes, bets, hero — asks [Act0ScenePerspectiveV1] where it
/// sits, so the scene cannot drift into per-widget fake depth.
///
/// B1 owns geometry and slot architecture only. Premium material (B2), the
/// final character family (B3), and executed object-attached HUD (B4) all
/// attach to the anchors defined here without another scene-layout rewrite.

/// Ordered depth planes of the learning scene. Lower index paints first.
enum Act0ScenePlaneV1 {
  /// Room, horizon, light pool, vignette. Owns the space the table sits in.
  environment,

  /// Player volumes behind the far and mid rail. Occluded by the table.
  farPlayer,

  /// The table object itself: rail, felt, board, pot, seats, bets.
  table,

  /// Hero's near plane. Belongs to the learner, in front of the table.
  nearPlayer,

  /// Teaching, feedback, and future object-attached HUD.
  overlay,
}

/// Which plane a normalized table-space depth belongs to.
Act0ScenePlaneV1 act0ScenePlaneForDepthV1(double depth) {
  if (depth <= 0.34) return Act0ScenePlaneV1.farPlayer;
  if (depth >= 0.82) return Act0ScenePlaneV1.nearPlayer;
  return Act0ScenePlaneV1.table;
}

/// Coarse depth tier name. Retained because Wave A evidence keys on it.
String act0SceneDepthTierV1(double depth) => depth >= 0.68
    ? 'near'
    : depth <= 0.34
    ? 'far'
    : 'mid';

/// The one projection every learning-scene element consumes.
///
/// Normalized table space is `(dx, dy)` in `0..1`, where `dy == 0` is the far
/// edge and `dy == 1` is the near edge.
@immutable
class Act0ScenePerspectiveV1 {
  const Act0ScenePerspectiveV1({
    this.farWidthFactor = 0.66,
    this.nearWidthFactor = 0.97,
    this.plateScaleFar = 0.88,
    this.plateScaleNear = 1.08,
    this.volumeScaleFar = 0.74,
    this.volumeScaleNear = 1.42,
  });

  /// Canonical B1 perspective for the first-learning scene.
  static const Act0ScenePerspectiveV1 canonical = Act0ScenePerspectiveV1();

  /// Silhouette width at the far edge, as a fraction of the layout box.
  final double farWidthFactor;

  /// Silhouette width at the near edge, as a fraction of the layout box.
  final double nearWidthFactor;

  /// Seat plate scale at the far edge.
  ///
  /// Plates carry text, so their depth range is deliberately narrow. Depth is
  /// carried by the player volumes, which carry none. This keeps small-text
  /// accessibility intact while the scene still reads as perspectival — and it
  /// matches how reference-quality poker scenes behave: bodies foreshorten
  /// hard, name plates stay legible.
  final double plateScaleFar;

  /// Seat plate scale at the near edge.
  final double plateScaleNear;

  /// Character-ready volume scale at the far edge.
  final double volumeScaleFar;

  /// Character-ready volume scale at the near edge.
  final double volumeScaleNear;

  /// Silhouette width at [depth], as a fraction of the layout box.
  double widthAt(double depth) =>
      lerpDouble(farWidthFactor, nearWidthFactor, depth.clamp(0.0, 1.0))!;

  /// Projects a flat top-down point onto the perspective silhouette.
  Offset project(Offset point) {
    final depth = point.dy.clamp(0.0, 1.0);
    final convergence = widthAt(depth) / nearWidthFactor;
    // A shallow vertical ease: the far half compresses slightly, the way a
    // receding plane does, without displacing seats off their rail.
    final dy = depth <= 0.34
        ? depth + 0.014
        : depth >= 0.68
        ? depth - 0.008
        : depth;
    return Offset(0.5 + ((point.dx - 0.5) * convergence), dy);
  }

  /// Plate/HUD scale at [depth].
  double plateScaleAt(double depth) =>
      lerpDouble(plateScaleFar, plateScaleNear, depth.clamp(0.0, 1.0))!;

  /// Character-ready volume scale at [depth].
  double volumeScaleAt(double depth) =>
      lerpDouble(volumeScaleFar, volumeScaleNear, depth.clamp(0.0, 1.0))!;

  /// Atmospheric recession at [depth]: how much a far element blends into the
  /// environment. `0` at the near edge, strongest at the far edge.
  double hazeAt(double depth) => (1 - depth.clamp(0.0, 1.0)) * 0.55;
}

/// A stable, character-ready seat slot.
///
/// Every anchor is in normalized table space. B3 places a body inside
/// [characterAnchor]/[volumeSize]; B4 attaches stacks, bets, position labels,
/// status and acting indicators to [plateAnchor] and [betAnchor]. Neither
/// needs to move the scene to do it.
@immutable
class Act0SceneSeatSlotV1 {
  const Act0SceneSeatSlotV1({
    required this.seatId,
    required this.depth,
    required this.plateAnchor,
    required this.characterAnchor,
    required this.betAnchor,
    required this.cardAnchor,
    required this.plateScale,
    required this.volumeScale,
    required this.isHero,
  });

  final String seatId;

  /// Normalized depth, `0` far, `1` near.
  final double depth;

  /// Where the seat plate (identity, stack, position) sits.
  final Offset plateAnchor;

  /// Centre of the reserved character-safe volume, behind the rail.
  final Offset characterAnchor;

  /// Where this seat's bet/chip commitment belongs.
  final Offset betAnchor;

  /// Where this seat's cards belong.
  final Offset cardAnchor;

  /// Depth-resolved plate scale.
  final double plateScale;

  /// Depth-resolved volume scale.
  final double volumeScale;

  /// Whether this slot is the learner's own seat.
  final bool isHero;

  Act0ScenePlaneV1 get plane =>
      isHero ? Act0ScenePlaneV1.nearPlayer : act0ScenePlaneForDepthV1(depth);

  String get depthTier => act0SceneDepthTierV1(depth);

  /// Character-safe volume in logical pixels for a table of [tableWidth].
  ///
  /// Reserved in B1 and only sketched; B3 fills it. Held as a fraction of the
  /// table so it survives every responsive profile.
  Size volumeSize(double tableWidth) =>
      Size(tableWidth * 0.245 * volumeScale, tableWidth * 0.275 * volumeScale);
}

/// The learner's near-plane ownership.
///
/// Wave A gave the hero a 73x42 identity badge sitting inside the felt, which
/// is precisely the "detached `You` UI badge floating below a diagram" the B1
/// admission calls out. This zone is the seam a future embodiment inherits.
@immutable
class Act0SceneHeroZoneV1 {
  const Act0SceneHeroZoneV1({
    required this.seatId,
    required this.anchor,
    required this.depth,
  });

  final String seatId;

  /// Normalized anchor of the hero's near-plane centre.
  final Offset anchor;

  final double depth;

  Act0ScenePlaneV1 get plane => Act0ScenePlaneV1.nearPlayer;
}

/// Resolves canonical seat slots from the scene's flat base slots.
///
/// [baseSlots] stay the source of seat order and rough placement — B1 does not
/// renegotiate which seat is where, only how deep it is.
List<Act0SceneSeatSlotV1> act0SceneSeatSlotsV1({
  required List<Offset> baseSlots,
  required List<String> seatIds,
  required String? heroSeatId,
  Act0ScenePerspectiveV1 perspective = Act0ScenePerspectiveV1.canonical,
}) {
  const sceneCentre = Offset(0.5, 0.52);
  final slots = <Act0SceneSeatSlotV1>[];
  for (var i = 0; i < seatIds.length; i++) {
    final base = baseSlots[i.clamp(0, baseSlots.length - 1)];
    final projected = perspective.project(base);
    final depth = projected.dy.clamp(0.0, 1.0);
    final isHero = seatIds[i] == heroSeatId;

    // Outward normal: away from the centre of the felt. Character volumes push
    // out along it so the rail overlaps them, which is the single strongest
    // depth cue available without art.
    var outward = projected - sceneCentre;
    final length = outward.distance;
    outward = length < 0.0001
        ? const Offset(0, -1)
        : Offset(outward.dx / length, outward.dy / length);

    // Near seats stand further out of frame than far seats, so the scene
    // continues past the screen edge instead of ending at the table.
    //
    // The push is deliberately asymmetric. People sit along the long sides of
    // a poker table, and the learning scene has a teaching layer directly
    // above the far rail, so vertical push stays small. Horizontal push is
    // what fills the flanks Wave A left flat — and it is tuned so the rail
    // always cuts across the lower part of each volume rather than leaving a
    // gap, which is the difference between a seated player and a floating
    // shape beside a diagram.
    final pushX = 0.104 + (0.072 * depth);
    // The far seat has no long side to stand on, so it gets a fixed larger
    // vertical push: enough for its head to clear the far rail and give the
    // scene a far plane, bounded by the teaching layer directly above.
    final pushY = depth <= 0.34 ? 0.082 : 0.052 + (0.030 * depth);

    slots.add(
      Act0SceneSeatSlotV1(
        seatId: seatIds[i],
        depth: depth,
        plateAnchor: projected,
        characterAnchor:
            projected + Offset(outward.dx * pushX, outward.dy * pushY),
        betAnchor: projected - (outward * 0.115),
        cardAnchor: projected - (outward * 0.055),
        plateScale: perspective.plateScaleAt(depth),
        volumeScale: perspective.volumeScaleAt(depth),
        isHero: isHero,
      ),
    );
  }
  return slots;
}

/// Room/environment specification for the scene's background plane.
///
/// B1 owns structural framing: a horizon, a wall/floor relationship, an
/// overhead light pool and grounding contact, so the table stops floating in
/// unowned app space. Detailed premium room art is B2.
@immutable
class Act0SceneEnvironmentV1 {
  const Act0SceneEnvironmentV1({
    this.horizon = 0.17,
    this.lightPoolCentre = const Alignment(0, -0.38),
  });

  static const Act0SceneEnvironmentV1 canonical = Act0SceneEnvironmentV1();

  /// Where the wall meets the floor, as a fraction of the scene height.
  final double horizon;

  /// Centre of the overhead light pool.
  final Alignment lightPoolCentre;
}

/// Paints the environment plane behind the table.
class Act0SceneEnvironmentPainterV1 extends CustomPainter {
  const Act0SceneEnvironmentPainterV1({
    this.environment = Act0SceneEnvironmentV1.canonical,
  });

  final Act0SceneEnvironmentV1 environment;

  static const Color _wallDeep = Color(0xFF040A13);
  static const Color _wallLift = Color(0xFF16283E);
  static const Color _floor = Color(0xFF050C17);
  static const Color _horizonGlow = Color(0xFF23506E);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final horizonY = size.height * environment.horizon;

    // Wall plane: darkest at the ceiling, lifting toward the horizon.
    canvas.drawRect(
      Rect.fromLTRB(0, 0, size.width, horizonY),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[_wallDeep, _wallLift],
        ).createShader(Rect.fromLTRB(0, 0, size.width, horizonY)),
    );

    // Floor plane: falls away from the horizon toward the viewer.
    canvas.drawRect(
      Rect.fromLTRB(0, horizonY, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const <Color>[_wallLift, _floor],
        ).createShader(Rect.fromLTRB(0, horizonY, size.width, size.height)),
    );

    // Horizon bloom: the room has a light source behind the far rail. This is
    // what stops the far edge reading as a cut-out against flat navy.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(0, (horizonY / size.height) * 2 - 1),
          radius: 0.92,
          colors: <Color>[
            _horizonGlow.withValues(alpha: 0.62),
            _horizonGlow.withValues(alpha: 0.20),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.42, 1],
        ).createShader(rect),
    );

    // Overhead light pool: the lamp above the table, tinted by felt bounce.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: environment.lightPoolCentre,
          radius: 0.78,
          colors: <Color>[
            Act0TableFeltCanonV1.feltCenter.withValues(alpha: 0.13),
            Act0TableFeltCanonV1.feltEdge.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.5, 1],
        ).createShader(rect),
    );

    // Corner vignette: keeps attention on the poker situation and gives the
    // room edges instead of letting the scene bleed into app chrome.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.06),
          radius: 1.05,
          colors: <Color>[
            Colors.transparent,
            Act0VisualCanonV1.appBlack.withValues(alpha: 0.52),
          ],
          stops: const <double>[0.58, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant Act0SceneEnvironmentPainterV1 oldDelegate) =>
      oldDelegate.environment.horizon != environment.horizon ||
      oldDelegate.environment.lightPoolCentre != environment.lightPoolCentre;
}

/// Paints the contact shadow that seats the table on the floor.
class Act0SceneGroundingPainterV1 extends CustomPainter {
  const Act0SceneGroundingPainterV1();

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height * 0.60);
    final rect = Rect.fromCenter(
      center: centre,
      width: size.width * 1.02,
      height: size.height * 0.86,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            Act0VisualCanonV1.appBlack.withValues(alpha: 0.46),
            Act0VisualCanonV1.appBlack.withValues(alpha: 0.18),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.66, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant Act0SceneGroundingPainterV1 oldDelegate) =>
      false;
}

/// The perspective silhouette of the learning-scene table.
///
/// Derives its taper from [Act0ScenePerspectiveV1] rather than hard-coded path
/// constants, so the rail and everything standing on it cannot disagree.
class Act0SceneTableShapeV1 extends ShapeBorder {
  const Act0SceneTableShapeV1({
    this.side = BorderSide.none,
    this.perspective = Act0ScenePerspectiveV1.canonical,
  });

  final BorderSide side;
  final Act0ScenePerspectiveV1 perspective;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  Path _path(Rect rect) {
    final w = rect.width;
    final h = rect.height;
    double x(double fraction) => rect.left + (w * fraction);
    double y(double fraction) => rect.top + (h * fraction);

    final farHalf = perspective.farWidthFactor / 2;
    final nearHalf = perspective.nearWidthFactor / 2;
    // Shoulder: where the long side straightens out of the far arc.
    final shoulderHalf = lerpDouble(farHalf, nearHalf, 0.16)!;

    return Path()
      ..moveTo(x(0.5 - farHalf + 0.045), y(0))
      ..cubicTo(
        x(0.5 - farHalf + 0.10),
        y(-0.009),
        x(0.5 + farHalf - 0.10),
        y(-0.009),
        x(0.5 + farHalf - 0.045),
        y(0),
      )
      ..quadraticBezierTo(
        x(0.5 + farHalf + 0.020),
        y(0.028),
        x(0.5 + shoulderHalf),
        y(0.13),
      )
      ..lineTo(x(0.5 + nearHalf), y(0.80))
      ..quadraticBezierTo(
        x(0.5 + nearHalf + 0.015),
        y(0.93),
        x(0.5 + nearHalf - 0.105),
        y(0.985),
      )
      ..quadraticBezierTo(x(0.5), y(1.012), x(0.5 - nearHalf + 0.105), y(0.985))
      ..quadraticBezierTo(
        x(0.5 - nearHalf - 0.015),
        y(0.93),
        x(0.5 - nearHalf),
        y(0.80),
      )
      ..lineTo(x(0.5 - shoulderHalf), y(0.13))
      ..quadraticBezierTo(
        x(0.5 - farHalf - 0.020),
        y(0.028),
        x(0.5 - farHalf + 0.045),
        y(0),
      )
      ..close();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => _path(rect);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      _path(rect.deflate(side.width));

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;
    canvas.drawPath(_path(rect.deflate(side.width / 2)), side.toPaint());
  }

  @override
  ShapeBorder scale(double t) =>
      Act0SceneTableShapeV1(side: side.scale(t), perspective: perspective);
}

/// The `farPlayer` plane: every reserved player volume around the table.
///
/// Lives between the environment and the table so the rail cuts across the
/// volumes it should occlude. That single overlap is what turns a top-down
/// diagram into a scene the learner is sitting inside.
class Act0SceneVolumeLayerV1 extends StatelessWidget {
  const Act0SceneVolumeLayerV1({
    super.key,
    required this.slots,
    this.inactiveSeatIds = const <String>{},
    this.perspective = Act0ScenePerspectiveV1.canonical,
    this.rimColor,
    this.bodyColor,
  });

  final List<Act0SceneSeatSlotV1> slots;

  /// Seats that are folded or out of the hand.
  final Set<String> inactiveSeatIds;

  final Act0ScenePerspectiveV1 perspective;

  /// Scene key-light rim tone, forwarded to every volume.
  final Color? rimColor;

  /// Room ambient body tone, forwarded to every volume.
  final Color? bodyColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        if (width <= 0 || height <= 0) return const SizedBox.shrink();

        // Far first, so nearer volumes overlap their neighbours correctly.
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
                  child: Act0SceneCharacterVolumeV1(
                    key: Key('act0_scene_player_volume_${slot.seatId}'),
                    slot: slot,
                    size: slot.volumeSize(width),
                    active: !inactiveSeatIds.contains(slot.seatId),
                    perspective: perspective,
                    rimColor: rimColor,
                    bodyColor: bodyColor,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Paints the learner's near plane.
///
/// The hero is the camera, so B1 does not give it a body. It gives it a lit
/// side of the table: a foreground pool centred on the hero anchor and a rim
/// along the near rail, the edge closest to the viewer. Together they answer
/// "where do I sit" without a detached badge doing the work.
class Act0SceneHeroPlanePainterV1 extends CustomPainter {
  const Act0SceneHeroPlanePainterV1({required this.heroAnchor});

  final Offset heroAnchor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final centre = Offset(
      size.width * heroAnchor.dx,
      size.height * heroAnchor.dy,
    );

    // Foreground pool: the learner's side of the felt catches more light.
    final pool = Rect.fromCenter(
      center: centre,
      width: size.width * 1.02,
      height: size.height * 0.62,
    );
    canvas.drawOval(
      pool,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            Act0TableFeltCanonV1.feltCenter.withValues(alpha: 0.40),
            Act0TableFeltCanonV1.feltCenter.withValues(alpha: 0.14),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.52, 1],
        ).createShader(pool),
    );

    // Near-rail rim: the closest edge of the table reads as lit and physical.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.transparent,
            Act0TableFeltCanonV1.innerHairline.withValues(alpha: 0.06),
            Act0TableFeltCanonV1.innerHairline.withValues(alpha: 0.16),
          ],
          stops: const <double>[0.72, 0.92, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant Act0SceneHeroPlanePainterV1 oldDelegate) =>
      oldDelegate.heroAnchor != heroAnchor;
}

/// The learner's own foreground volume, seen from behind.
///
/// This is the counterpart to the occlusion on the far plane. Far players
/// stand behind the rail and the table cuts across them; the hero sits in
/// front of the rail and cuts across the table. That symmetry is what puts the
/// learner *at* the table rather than above a diagram of one — and it is what
/// the detached `You` badge could never do on its own.
///
/// As the object closest to the camera it is the darkest thing in the scene,
/// lit only along its rim by the overhead lamp. B3 inherits this exact volume.
class Act0SceneHeroForegroundV1 extends StatelessWidget {
  const Act0SceneHeroForegroundV1({super.key, this.rimColor});

  /// Rim tone from the scene's key light; null keeps the B1 default.
  final Color? rimColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          widthFactor: 0.72,
          heightFactor: 0.17,
          child: FractionalTranslation(
            // Clears the hero's own plate, then continues down behind the
            // action dock so the learner's seat has no visible end.
            translation: const Offset(0, 0.86),
            child: CustomPaint(
              painter: _Act0SceneHeroForegroundPainterV1(rimColor: rimColor),
            ),
          ),
        ),
      ),
    );
  }
}

class _Act0SceneHeroForegroundPainterV1 extends CustomPainter {
  const _Act0SceneHeroForegroundPainterV1({this.rimColor});

  final Color? rimColor;

  static const Color _mass = Color(0xFF060C16);
  static const Color _rimDefault = Color(0xFF5E86AE);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final shoulders = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.68)
      ..cubicTo(w * 0.14, h * 0.58, w * 0.26, h * 0.51, w * 0.335, h * 0.44)
      ..cubicTo(w * 0.352, h * 0.05, w * 0.648, h * 0.05, w * 0.665, h * 0.44)
      ..cubicTo(w * 0.74, h * 0.51, w * 0.86, h * 0.58, w, h * 0.68)
      ..lineTo(w, h)
      ..close();

    canvas.drawPath(shoulders, Paint()..color = _mass);

    // Rim light: the overhead lamp catching the top of the learner's shoulders
    // and head. Without it the mass reads as a hole rather than a body.
    canvas.drawPath(
      shoulders,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, h * 0.030)
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            (rimColor ?? _rimDefault).withValues(alpha: 0.52),
            (rimColor ?? _rimDefault).withValues(alpha: 0.06),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.72)),
    );
  }

  @override
  bool shouldRepaint(covariant _Act0SceneHeroForegroundPainterV1 oldDelegate) =>
      oldDelegate.rimColor != rimColor;
}

/// A reserved, character-safe player volume.
///
/// B1 deliberately ships presence, not personality: a chair mass, a shoulder
/// line and a head, in low-contrast room tones. It establishes scale, depth,
/// anchor, overlap ownership and art-safe space so B3 can drop a real
/// character into exactly this box. It is not the character family.
class Act0SceneCharacterVolumeV1 extends StatelessWidget {
  const Act0SceneCharacterVolumeV1({
    super.key,
    required this.slot,
    required this.size,
    this.active = true,
    this.perspective = Act0ScenePerspectiveV1.canonical,
    this.rimColor,
    this.bodyColor,
  });

  final Act0SceneSeatSlotV1 slot;
  final Size size;

  /// Folded/out-of-hand seats recede further into the room.
  final bool active;

  final Act0ScenePerspectiveV1 perspective;

  /// Rim tone from the scene's key light. B2 supplies this so the volumes are
  /// lit by the same source as the table and room instead of glowing on their
  /// own. Null keeps the B1 self-lit defaults.
  final Color? rimColor;

  /// Body tone, tinted by the room's ambient.
  final Color? bodyColor;

  @override
  Widget build(BuildContext context) {
    final haze = perspective.hazeAt(slot.depth);
    return IgnorePointer(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Opacity(
          opacity: (active ? 1.0 : 0.62) * (1 - (haze * 0.30)),
          child: CustomPaint(
            painter: _Act0SceneCharacterVolumePainterV1(
              haze: haze,
              rimColor: rimColor,
              bodyColor: bodyColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _Act0SceneCharacterVolumePainterV1 extends CustomPainter {
  const _Act0SceneCharacterVolumePainterV1({
    required this.haze,
    this.rimColor,
    this.bodyColor,
  });

  final double haze;
  final Color? rimColor;
  final Color? bodyColor;

  static const Color _chairDefault = Color(0xFF1B2E49);
  static const Color _bodyDefault = Color(0xFF28405F);
  static const Color _rimDefault = Color(0xFF6D8FB4);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = bodyColor ?? _bodyDefault;
    final chairTone = Color.lerp(_chairDefault, body, 0.25)!;
    final rimTone = rimColor ?? _rimDefault;
    // Far volumes sit deeper in the room haze, so their contrast drops.
    final lift = 1 - haze;

    // Chair back: the mass that reads as furniture behind the player.
    final chair = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.10, h * 0.24, w * 0.80, h * 0.76),
      Radius.circular(w * 0.19),
    );
    canvas.drawRRect(
      chair,
      Paint()..color = Color.lerp(chairTone, body, 0.15 * lift)!,
    );

    // Shoulders.
    final shoulders = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.19, h * 0.50, w * 0.62, h * 0.50),
      Radius.circular(w * 0.24),
    );
    canvas.drawRRect(shoulders, Paint()..color = body);

    // Head.
    canvas.drawCircle(
      Offset(w * 0.50, h * 0.36),
      w * 0.163,
      Paint()..color = body,
    );

    // Rim light from the overhead lamp. This is what makes the volume read as
    // a body in a lit room rather than a flat hole in the background.
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, w * 0.018)
      ..color = rimTone.withValues(alpha: 0.62 * lift);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * 0.50, h * 0.36), radius: w * 0.163),
      math.pi * 1.12,
      math.pi * 0.78,
      false,
      rim,
    );
    canvas.drawArc(
      Rect.fromLTWH(w * 0.19, h * 0.50, w * 0.62, h * 0.34),
      math.pi * 1.06,
      math.pi * 0.88,
      false,
      rim,
    );
  }

  @override
  bool shouldRepaint(
    covariant _Act0SceneCharacterVolumePainterV1 oldDelegate,
  ) =>
      oldDelegate.haze != haze ||
      oldDelegate.rimColor != rimColor ||
      oldDelegate.bodyColor != bodyColor;
}
