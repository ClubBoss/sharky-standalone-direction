import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The five authored opponent identities in the production six-max scene.
enum Act0SceneCharacterIdentityV1 { utg, bb, hj, sb, co }

/// Authored character state requested by the scene.
///
/// Only engaged PNGs are required in the current production wave. Folded seats
/// deliberately reuse the engaged render and receive the established recession
/// treatment in [Act0SceneCharacterPainterV1].
enum Act0SceneCharacterStateV1 { engaged, folded }

/// Visual-only mapping from a logical seat envelope to authored character art.
///
/// Values are proportional to the existing envelope. This contract never owns
/// or mutates camera, table, rail, seat-anchor, card or commitment geometry.
@immutable
class Act0SceneCharacterArtFitV1 {
  const Act0SceneCharacterArtFitV1({
    this.scale = 1,
    this.relativeOffset = Offset.zero,
  });

  final double scale;
  final Offset relativeOffset;

  Rect destinationRectFor(Size envelope) {
    final width = envelope.width * scale;
    final height = envelope.height * scale;
    return Rect.fromLTWH(
      ((envelope.width - width) / 2) + (envelope.width * relativeOffset.dx),
      envelope.height * relativeOffset.dy,
      width,
      height,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Act0SceneCharacterArtFitV1 &&
      other.scale == scale &&
      other.relativeOffset == relativeOffset;

  @override
  int get hashCode => Object.hash(scale, relativeOffset);

  static const standard = Act0SceneCharacterArtFitV1();

  /// Runtime-proven far-centre UTG art fit.
  static const utg = Act0SceneCharacterArtFitV1(
    scale: 1.30,
    relativeOffset: Offset(0, -0.28),
  );
}

/// Stable paths and art-fit defaults for the production cast.
class Act0SceneCharacterAssetRegistryV1 {
  const Act0SceneCharacterAssetRegistryV1._();

  static String engagedPathFor(Act0SceneCharacterIdentityV1 identity) =>
      'assets/act0_characters/opponent_${identity.name}_engaged.png';

  static String pathFor(
    Act0SceneCharacterIdentityV1 identity,
    Act0SceneCharacterStateV1 state,
  ) {
    // Folded-specific artwork is intentionally not required in this wave.
    return engagedPathFor(identity);
  }

  static Act0SceneCharacterArtFitV1 artFitFor(
    Act0SceneCharacterIdentityV1 identity,
  ) => switch (identity) {
    Act0SceneCharacterIdentityV1.utg => Act0SceneCharacterArtFitV1.utg,
    _ => Act0SceneCharacterArtFitV1.standard,
  };
}

/// Decode-once store for production character PNGs.
///
/// A missing not-yet-supplied asset is a supported state and resolves to null,
/// allowing the procedural player to remain visible. Invalid image bytes are a
/// real decode failure and are reported through [FlutterError].
class Act0SceneCharacterImageStoreV1 {
  Act0SceneCharacterImageStoreV1();

  static final shared = Act0SceneCharacterImageStoreV1();

  final Map<String, ui.Image> _ready = <String, ui.Image>{};
  final Map<String, Future<ui.Image?>> _pending = <String, Future<ui.Image?>>{};
  final Set<String> _missing = <String>{};

  ui.Image? readyImageFor(String path) => _ready[path];

  bool isReady(String path) => _ready.containsKey(path);

  bool isPending(String path) => _pending.containsKey(path);

  bool isMissing(String path) => _missing.contains(path);

  Future<ui.Image?> load(String path, {AssetBundle? bundle}) {
    final ready = _ready[path];
    if (ready != null) return SynchronousFuture<ui.Image?>(ready);
    if (_missing.contains(path)) return SynchronousFuture<ui.Image?>(null);
    final inFlight = _pending[path];
    if (inFlight != null) return inFlight;

    final future = _load(path, bundle ?? rootBundle);
    _pending[path] = future;
    unawaited(
      future.whenComplete(() {
        if (identical(_pending[path], future)) _pending.remove(path);
      }),
    );
    return future;
  }

  Future<ui.Image?> _load(String path, AssetBundle bundle) async {
    final ByteData data;
    try {
      data = await bundle.load(path);
    } on FlutterError {
      // Keep the procedural figure visible if a bundled asset is unavailable.
      _missing.add(path);
      return null;
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'Sharky production character assets',
          context: ErrorDescription('while loading $path'),
        ),
      );
      return null;
    }

    try {
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      try {
        final frame = await codec.getNextFrame();
        _ready[path] = frame.image;
        return frame.image;
      } finally {
        codec.dispose();
      }
    } catch (error, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'Sharky production character assets',
          context: ErrorDescription('while decoding $path'),
        ),
      );
      return null;
    }
  }

  @visibleForTesting
  void clear() {
    for (final image in _ready.values) {
      image.dispose();
    }
    _ready.clear();
    _pending.clear();
    _missing.clear();
  }
}

/// Loads an authored opponent if present and otherwise keeps [fallback]
/// visible. The logical envelope is never resized by this widget.
class Act0SceneCharacterFigureV1 extends StatefulWidget {
  const Act0SceneCharacterFigureV1({
    super.key,
    required this.identity,
    required this.state,
    required this.size,
    required this.haze,
    required this.fallback,
    this.store,
  });

  final Act0SceneCharacterIdentityV1 identity;
  final Act0SceneCharacterStateV1 state;
  final Size size;
  final double haze;
  final Widget fallback;
  final Act0SceneCharacterImageStoreV1? store;

  @override
  State<Act0SceneCharacterFigureV1> createState() =>
      _Act0SceneCharacterFigureV1State();
}

class _Act0SceneCharacterFigureV1State
    extends State<Act0SceneCharacterFigureV1> {
  ui.Image? _image;
  String? _attemptedPath;
  Object? _pendingToken;

  Act0SceneCharacterImageStoreV1 get _store =>
      widget.store ?? Act0SceneCharacterImageStoreV1.shared;

  String get _path =>
      Act0SceneCharacterAssetRegistryV1.pathFor(widget.identity, widget.state);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant Act0SceneCharacterFigureV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.identity != widget.identity ||
        oldWidget.state != widget.state ||
        oldWidget.store != widget.store) {
      _image = null;
      _attemptedPath = null;
      _resolve();
    }
  }

  void _resolve() {
    final path = _path;
    final ready = _store.readyImageFor(path);
    if (ready != null) {
      _image = ready;
      _attemptedPath = path;
      return;
    }
    if (_attemptedPath == path) return;
    _attemptedPath = path;
    final token = Object();
    _pendingToken = token;
    unawaited(
      _store.load(path).then((image) {
        if (!mounted || _pendingToken != token || image == null) return;
        setState(() => _image = image);
      }),
    );
  }

  @override
  void dispose() {
    _pendingToken = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _image ?? _store.readyImageFor(_path);
    if (image == null) {
      return KeyedSubtree(
        key: Key('act0_scene_character_${widget.identity.name}_fallback'),
        child: widget.fallback,
      );
    }
    return CustomPaint(
      key: Key('act0_scene_character_${widget.identity.name}_ready'),
      size: widget.size,
      painter: Act0SceneCharacterPainterV1(
        image: image,
        artFit: Act0SceneCharacterAssetRegistryV1.artFitFor(widget.identity),
        haze: widget.haze,
        folded: widget.state == Act0SceneCharacterStateV1.folded,
      ),
    );
  }
}

/// Whole-source to fitted-destination painter with the established depth and
/// folded-state recession treatment.
class Act0SceneCharacterPainterV1 extends CustomPainter {
  const Act0SceneCharacterPainterV1({
    required this.image,
    required this.artFit,
    required this.haze,
    required this.folded,
  });

  final ui.Image image;
  final Act0SceneCharacterArtFitV1 artFit;
  final double haze;
  final bool folded;

  static const Color _roomTone = Color(0xFF1B3350);

  @override
  void paint(Canvas canvas, Size size) {
    final destination = artFit.destinationRectFor(size);
    final source = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    // Keep depth hierarchy, but avoid stacking a heavy authored-art haze on
    // top of the scene-level attention recession. Far and upper-flank faces
    // retain their depth tint while staying physically present in the room.
    final tint = ((haze * 0.50) + (folded ? 0.20 : 0.0)).clamp(0.0, 0.85);
    final opacity = (folded ? 0.72 : 1.0) * (1 - (haze * 0.06));

    canvas.saveLayer(destination, Paint());
    canvas.drawImageRect(
      image,
      source,
      destination,
      Paint()
        ..filterQuality = FilterQuality.high
        ..color = Color.fromRGBO(255, 255, 255, opacity.clamp(0.0, 1.0)),
    );
    canvas.drawRect(
      destination,
      Paint()
        ..color = _roomTone.withValues(alpha: tint)
        ..blendMode = BlendMode.srcATop,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant Act0SceneCharacterPainterV1 oldDelegate) =>
      !identical(oldDelegate.image, image) ||
      oldDelegate.artFit != artFit ||
      oldDelegate.haze != haze ||
      oldDelegate.folded != folded;
}
