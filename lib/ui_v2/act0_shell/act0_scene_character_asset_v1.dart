import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_depth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_scene_material_v1.dart';

/// Visual Gauntlet B7 — the authored-character asset seam.
///
/// B3 built the character *language* procedurally: parts, value steps, depth
/// falloff. That crossed "cutout -> readable seated human", and it is still the
/// floor this file falls back to. What it could not cross is believability. A
/// head is a circle, a jaw is an offset circle, and no amount of further
/// `CustomPainter` work turns parameterised primitives into a person — past a
/// point every extra path costs complexity and buys nothing.
///
/// So this seam inverts the ownership. Authored transparent artwork owns
/// anatomy, facial planes, hair, hands, clothing and pose. Code keeps
/// everything it was already good at and must not give up: seat identity,
/// projection, scale, rail occlusion, atmospheric recession, B2's shared light,
/// B4's HUD, B5's salience, B6's motion, and deterministic capture.
///
/// The artwork is baked off-stage by `tools/art/act0_b7_character_art_v1.py`.
/// Runtime never runs that tool and never depends on it — it depends on the
/// PNGs, exactly the way it would depend on an illustrator's exports.
///
/// This is the admitted vertical slice, not an asset pack: one opponent
/// identity in one real seat, plus one first-person hero foreground.

/// Assets baked for the slice.
class Act0SceneCharacterAssetV1 {
  const Act0SceneCharacterAssetV1._(this.path);

  /// The near left-flank opponent, three-quarter, turned toward the felt.
  static const Act0SceneCharacterAssetV1 opponentNearLeft =
      Act0SceneCharacterAssetV1._(
        'assets/act0_characters/opponent_near_left_in_hand.png',
      );

  /// The learner's own forearms and hands on the rail.
  static const Act0SceneCharacterAssetV1 heroForeground =
      Act0SceneCharacterAssetV1._('assets/act0_characters/hero_foreground.png');

  static const List<Act0SceneCharacterAssetV1> all =
      <Act0SceneCharacterAssetV1>[opponentNearLeft, heroForeground];

  final String path;
}

/// Synchronous, process-wide store of decoded character artwork.
///
/// Determinism is the whole reason this exists. Canonical captures have to be
/// byte-reproducible, so a figure must never be half-decoded on the frame the
/// evidence is taken. Decoding is therefore hoisted out of paint entirely:
/// callers await [warmUp] once, after which [imageFor] is a synchronous map
/// lookup and every subsequent frame is identical.
///
/// Before warm-up completes — and on any platform where the bundle is
/// unavailable — [imageFor] returns null and the caller paints the B3
/// procedural figure. The seam can degrade, but it can never blank a seat.
class Act0SceneCharacterAssetStoreV1 {
  Act0SceneCharacterAssetStoreV1._();

  static final Map<String, ui.Image> _decoded = <String, ui.Image>{};
  static Future<void>? _pending;

  /// Whether every slice asset is decoded and ready to paint.
  static bool get isReady =>
      Act0SceneCharacterAssetV1.all.every((a) => _decoded.containsKey(a.path));

  static ui.Image? imageFor(Act0SceneCharacterAssetV1 asset) =>
      _decoded[asset.path];

  /// Decodes every slice asset. Safe to call repeatedly; the work happens once.
  static Future<void> warmUp({AssetBundle? bundle}) {
    if (isReady) return Future<void>.value();
    return _pending ??= _decodeAll(bundle ?? rootBundle).whenComplete(() {
      _pending = null;
    });
  }

  static Future<void> _decodeAll(AssetBundle bundle) async {
    for (final asset in Act0SceneCharacterAssetV1.all) {
      if (_decoded.containsKey(asset.path)) continue;
      try {
        final data = await bundle.load(asset.path);
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        _decoded[asset.path] = (await codec.getNextFrame()).image;
      } catch (error, stack) {
        // A missing or unreadable asset must degrade to the procedural figure
        // rather than take the learning scene down with it.
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'act0 scene character assets',
            context: ErrorDescription('decoding ${asset.path}'),
          ),
        );
      }
    }
  }

  @visibleForTesting
  static void resetForTest() {
    _decoded.clear();
    _pending = null;
  }
}

/// Which single seat the slice's authored opponent belongs to.
///
/// The slice buys one authored identity, so it has to be spent on the seat
/// where authored art can actually be judged: the nearest left-flank opponent.
/// That seat is the largest non-hero volume on screen, it sits in the `near`
/// detail tier, and the rail crosses it, so it exercises occlusion, recession
/// and lighting at once. Resolution is a pure function of the slots B1 already
/// produced, so it stays deterministic across every viewport.
String? act0SceneAuthoredOpponentSeatIdV1(List<Act0SceneSeatSlotV1> slots) {
  Act0SceneSeatSlotV1? best;
  for (final slot in slots) {
    if (slot.isHero || slot.plateAnchor.dx >= 0.5) continue;
    if (best == null || slot.depth > best.depth) best = slot;
  }
  return best?.seatId;
}

/// Paints authored artwork into a volume B1 owns.
///
/// The artwork is authored in the same normalized box the procedural painter
/// receives, so this is a drop-in: placement, scale and crop stay exactly where
/// they were. Everything applied on top of the bitmap is scene physics the art
/// is deliberately not allowed to bake in.
class Act0SceneCharacterAssetPainterV1 extends CustomPainter {
  const Act0SceneCharacterAssetPainterV1({
    required this.image,
    required this.haze,
    this.light = Act0SceneLightV1.canonical,
    this.recession = 0.0,
    this.mirror = false,
  });

  final ui.Image image;

  /// B1/B2 atmospheric recession for this seat's depth.
  final double haze;

  final Act0SceneLightV1 light;

  /// Extra recession for a seat that is no longer contesting the pot.
  ///
  /// The slice buys one authored pose, so folded is expressed the way B5
  /// already expresses "less relevant" — further into the room haze — rather
  /// than by popping between authored and procedural art on one seat.
  final double recession;

  final bool mirror;

  /// B2's lit wall tone. Everything drifts toward it with distance and loses
  /// contrast, which is what stops a far figure looking like a near figure
  /// drawn small.
  static const Color _roomTone = Color(0xFF1B3350);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final dst = Offset.zero & size;
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    // The tint has to affect the figure only, never the transparent box around
    // it, so the bitmap gets its own layer and the tint is `srcATop`.
    canvas.saveLayer(dst, Paint());
    if (mirror) {
      canvas.save();
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.high,
    );
    if (mirror) canvas.restore();

    final recede = ((haze * 0.62) + recession).clamp(0.0, 0.86);
    if (recede > 0.001) {
      canvas.drawRect(
        dst,
        Paint()
          ..color = _roomTone.withValues(alpha: recede)
          ..blendMode = BlendMode.srcATop,
      );
    }
    // The scene can be dimmed coherently, so the artwork dims with it rather
    // than staying stubbornly lit while the room drops away.
    final dim = (1.0 - light.intensity).clamp(0.0, 1.0) * 0.7;
    if (dim > 0.001) {
      canvas.drawRect(
        dst,
        Paint()
          ..color = const Color(0xFF03070D).withValues(alpha: dim)
          ..blendMode = BlendMode.srcATop,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant Act0SceneCharacterAssetPainterV1 old) =>
      !identical(old.image, image) ||
      old.haze != haze ||
      old.recession != recession ||
      old.mirror != mirror ||
      old.light.intensity != light.intensity;
}

/// Rebuilds its subtree once the authored artwork is decoded.
///
/// Decoding happens exactly once per process, so in practice this reports
/// ready on the first frame of every run after the first. It exists so that
/// the very first build cannot paint an empty seat while the bundle is still
/// being read.
class Act0SceneCharacterAssetGateV1 extends StatefulWidget {
  const Act0SceneCharacterAssetGateV1({super.key, required this.builder});

  final Widget Function(BuildContext context, bool ready) builder;

  @override
  State<Act0SceneCharacterAssetGateV1> createState() =>
      _Act0SceneCharacterAssetGateStateV1();
}

class _Act0SceneCharacterAssetGateStateV1
    extends State<Act0SceneCharacterAssetGateV1> {
  late bool _ready = Act0SceneCharacterAssetStoreV1.isReady;

  @override
  void initState() {
    super.initState();
    if (_ready) return;
    Act0SceneCharacterAssetStoreV1.warmUp().whenComplete(() {
      if (!mounted) return;
      final ready = Act0SceneCharacterAssetStoreV1.isReady;
      if (ready == _ready) return;
      setState(() => _ready = ready);
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _ready);
}
