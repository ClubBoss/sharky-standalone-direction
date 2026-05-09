import 'style_token_model_v3.dart';

class ThemeBinderV3 {
  const ThemeBinderV3();

  static const Map<String, String> surfaceBinding = {
    'surface.base.1': 'color.primary',
    'surface.base.2': 'color.primaryContainer',
    'surface.container.1': 'color.surfaceContainer',
    'surface.container.2': 'color.secondaryContainer',
    'surface.overlay.1': 'color.surface',
    'surface.highlight.1': 'color.accent',
  };

  static const Map<String, String> componentSurfaceBinding = {
    'component.card': 'surface.base.1',
    'component.panel': 'surface.container.1',
    'component.section': 'surface.container.2',
    'component.summary': 'surface.container.2',
    'component.chip': 'surface.highlight.1',
    'component.button': 'surface.highlight.1',
    'component.icon': 'surface.overlay.1',
    'component.surface': 'surface.base.2',
  };

  static const Map<String, String> componentMotionBinding = {
    'component.card': 'motion.component.card',
    'component.panel': 'motion.component.panel',
    'component.section': 'motion.component.section',
    'component.summary': 'motion.component.summary',
    'component.chip': 'motion.component.chip',
    'component.button': 'motion.component.button',
    'component.icon': 'motion.component.card',
    'component.surface': 'motion.component.card',
  };

  static const Map<String, String> surfaceMotionFusion = {
    'surface.base.1': 'motion.entry.1',
    'surface.base.2': 'motion.entry.2',
    'surface.container.1': 'motion.exit.1',
    'surface.container.2': 'motion.exit.2',
    'surface.overlay.1': 'motion.emphasis.1',
    'surface.highlight.1': 'motion.tempo.1',
  };

  static const Map<String, String> surfaceTokenMap = {
    'surface.base.1': 'color.primary',
    'surface.base.2': 'color.primary.container',
    'surface.container.1': 'color.background.1',
    'surface.container.2': 'color.background.2',
    'surface.overlay.1': 'color.overlay',
    'surface.highlight.1': 'color.accent',
  };

  static const Map<String, String> motionTokenMap = {
    'motion.component.enter': 'motion.enter.base',
    'motion.component.exit': 'motion.exit.base',
    'motion.component.emphasis': 'motion.emphasis.base',
    'motion.component.tempo': 'motion.tempo.base',
    'motion.component.transition': 'motion.transition.base',
    'motion.component.overlay': 'motion.overlay.base',
  };

  static const Map<String, String> fusionTokenMap = {
    'fusion.base.1': 'fusion.token.base.1',
    'fusion.base.2': 'fusion.token.base.2',
    'fusion.container.1': 'fusion.token.container.1',
    'fusion.container.2': 'fusion.token.container.2',
    'fusion.overlay.1': 'fusion.token.overlay.1',
    'fusion.highlight.1': 'fusion.token.highlight.1',
  };

  String bindSurface(String key) {
    return surfaceBinding[key] ?? '';
  }

  String bindComponentSurface(String key) {
    return componentSurfaceBinding[key] ?? '';
  }

  String bindComponentMotion(String key) {
    return componentMotionBinding[key] ?? '';
  }

  String bindSurfaceMotion(String key) {
    return surfaceMotionFusion[key] ?? '';
  }

  String resolveSurfaceToken(String surfaceKey) {
    return surfaceTokenMap[surfaceKey] ?? '';
  }

  String resolveMotionToken(String motionKey) {
    return motionTokenMap[motionKey] ?? '';
  }

  String resolveFusionToken(String fusionKey) {
    return fusionTokenMap[fusionKey] ?? '';
  }

  String resolveComponentStyle(String key) {
    final s = bindComponentSurface(key);
    final m = bindComponentMotion(key);
    final f = bindSurfaceMotion(s);
    return '$s|$m|$f';
  }

  StyleTokenModelV3 resolveComponentToken(String key) {
    final s = bindComponentSurface(key);
    final m = bindComponentMotion(key);
    final f = bindSurfaceMotion(s);
    return StyleTokenModelV3(surface: s, motion: m, fusion: f);
  }
}
