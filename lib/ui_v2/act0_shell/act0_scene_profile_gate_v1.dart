import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'act0_scene_hybrid_shell_v1.dart';
import 'act0_scene_profile_v1.dart';
import 'act0_shell_state_v1.dart';

typedef Act0RegisteredSceneBuilderV1 =
    Widget Function(BuildContext, ui.Image, Act0SceneProfileV1);

/// An attempt-scoped asset/compatibility gate, not a state or learning owner.
/// Pending decode never flashes another room. A missing, invalid or incompatible
/// image chooses the untouched original path. That choice is latched until a
/// new scenario key; ordinary decisions/feedback cannot swap backgrounds.
class Act0SceneProfileGateV1 extends StatefulWidget {
  const Act0SceneProfileGateV1({
    super.key,
    required this.scenarioKey,
    required this.sourceTables,
    required this.originalBuilder,
    required this.registeredBuilder,
    this.enabled = kAct0F7TableScenePreview,
    this.profile = act0PremiumTableSceneProfileV1,
    this.store,
    this.assetBundle,
  });
  final String scenarioKey;
  final List<Act0TableStateV1> sourceTables;
  final WidgetBuilder originalBuilder;
  final Act0RegisteredSceneBuilderV1 registeredBuilder;
  final bool enabled;
  final Act0SceneProfileV1 profile;
  final Act0SceneSinglePlateImageStoreV1? store;
  final AssetBundle? assetBundle;

  static final premiumStore = Act0SceneSinglePlateImageStoreV1(
    act0PremiumTableSceneProfileV1.assetPath,
    library: 'Sharky F7 scene profile',
  );

  @override
  State<Act0SceneProfileGateV1> createState() => _GateState();
}

class _GateState extends State<Act0SceneProfileGateV1> {
  ui.Image? _image;
  bool _resolved = false;
  late Act0SceneProfileV1 _profile;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant Act0SceneProfileGateV1 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scenarioKey != oldWidget.scenarioKey) _resolve();
  }

  void _resolve() {
    final generation = ++_generation;
    _resolved = false;
    _image = null;
    _profile = widget.profile;
    if (!widget.enabled ||
        !widget.profile.supportsScenario(widget.sourceTables)) {
      _resolved = true;
      return;
    }
    final store = widget.store ?? Act0SceneProfileGateV1.premiumStore;
    if (store.assetPath != widget.profile.assetPath) {
      _resolved = true;
      return;
    }
    final profile = widget.profile;
    unawaited(
      store
          .warmUp(bundle: widget.assetBundle)
          .then((image) {
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
          })
          .catchError((Object _) {
            if (mounted && generation == _generation)
              setState(() => _resolved = true);
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_resolved)
      return const SizedBox.expand(key: Key('act0_f7_scene_loading'));
    final image = _image;
    return image == null
        ? widget.originalBuilder(context)
        : widget.registeredBuilder(context, image, _profile);
  }
}

class Act0RegisteredScenePainterV1 extends CustomPainter {
  const Act0RegisteredScenePainterV1({
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
  bool shouldRepaint(covariant Act0RegisteredScenePainterV1 oldDelegate) =>
      image != oldDelegate.image ||
      registration.destinationRect != oldDelegate.registration.destinationRect;
}
