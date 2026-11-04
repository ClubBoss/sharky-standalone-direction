import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'act0_f7_scene_compatibility_v1.dart';
import 'act0_f7_scene_source_v1.dart';
import 'act0_scene_hybrid_shell_v1.dart';
import 'act0_scene_profile_v1.dart';

typedef Act0F7RegisteredSceneBuilderV1 =
    Widget Function(BuildContext, ui.Image, Act0SceneProfileV1);

/// Scene-only selection. Keep the Runner's controls/feedback outside this gate.
/// The complete task inventory is preflighted before decoding. A fallback is
/// latched until a new task/attempt key, even if a later frame becomes suitable.
class Act0F7SceneGateV1 extends StatefulWidget {
  const Act0F7SceneGateV1({
    super.key,
    required this.source,
    required this.originalBuilder,
    required this.registeredBuilder,
    this.enabled = kAct0F7TableScenePreview,
    this.profile = act0PremiumTableSceneProfileV1,
    this.store,
    this.assetBundle,
  });

  final Act0F7SceneSourceV1 source;
  final WidgetBuilder originalBuilder;
  final Act0F7RegisteredSceneBuilderV1 registeredBuilder;
  final bool enabled;
  final Act0SceneProfileV1 profile;
  final Act0SceneSinglePlateImageStoreV1? store;
  final AssetBundle? assetBundle;

  static final premiumStore = Act0SceneSinglePlateImageStoreV1(
    act0PremiumTableSceneProfileV1.assetPath,
    library: 'Sharky F7 preparation',
  );

  @override
  State<Act0F7SceneGateV1> createState() => _Act0F7SceneGateStateV1();
}

class _Act0F7SceneGateStateV1 extends State<Act0F7SceneGateV1> {
  ui.Image? _image;
  bool _resolved = false;
  int _generation = 0;
  late Act0SceneProfileV1 _profile;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant Act0F7SceneGateV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.source.scenarioKey != oldWidget.source.scenarioKey) {
      _resolve();
    } else if (!widget.enabled ||
        !identical(widget.profile, _profile) ||
        !act0F7SceneCompatibilityV1(
          widget.source,
          profile: _profile,
        ).canUsePng) {
      // Unexpected unsafe source/configuration updates must never retain a
      // baked person over an empty seat. Invalidate any in-flight decode too.
      ++_generation;
      _image = null;
      _resolved = true;
    }
  }

  void _resolve() {
    final generation = ++_generation;
    _image = null;
    _resolved = false;
    _profile = widget.profile;
    if (!widget.enabled ||
        !act0F7SceneCompatibilityV1(
          widget.source,
          profile: _profile,
        ).canUsePng) {
      _resolved = true;
      return;
    }
    final store = widget.store ?? Act0F7SceneGateV1.premiumStore;
    if (store.assetPath != _profile.assetPath) {
      _resolved = true;
      return;
    }
    final profile = _profile;
    unawaited(
      store
          .warmUp(bundle: widget.assetBundle)
          .then(
            (image) {
              if (!mounted || generation != _generation) return;
              setState(() {
                _image =
                    image != null &&
                        image.width == profile.sourceSize.width &&
                        image.height == profile.sourceSize.height
                    ? image
                    : null;
                _resolved = true;
              });
            },
            onError: (Object _, StackTrace __) {
              if (!mounted || generation != _generation) return;
              setState(() => _resolved = true);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_resolved) {
      // Seats can be answer controls too. Keep the accepted procedural scene
      // usable while decoding, just as for a missing/incompatible plate.
      return KeyedSubtree(
        key: const Key('act0_f7_scene_loading'),
        child: widget.originalBuilder(context),
      );
    }
    final image = _image;
    return image == null
        ? widget.originalBuilder(context)
        : widget.registeredBuilder(context, image, _profile);
  }
}

/// Artwork only; all live facts use the same registration in the integrator's
/// existing source-owned overlay widgets. No cards or actors are drawn here.
class Act0F7RegisteredScenePainterV1 extends CustomPainter {
  const Act0F7RegisteredScenePainterV1({
    required this.image,
    required this.registration,
  });
  final ui.Image image;
  final Act0SceneRegistrationV1 registration;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawImageRect(
      image,
      registration.sourceRect,
      registration.destinationRect,
      Paint()..filterQuality = FilterQuality.high,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant Act0F7RegisteredScenePainterV1 oldDelegate) =>
      image != oldDelegate.image ||
      registration.sourceRect != oldDelegate.registration.sourceRect ||
      registration.destinationRect != oldDelegate.registration.destinationRect;
}
