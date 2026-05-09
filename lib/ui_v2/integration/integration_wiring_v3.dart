import '../theme/theme_loader_v4.dart';

class IntegrationWiringV3 {
  final Object persona;
  final Object adaptive;
  final Object theme;
  final Object visual;
  final Object ai;
  bool _v4Active = false;
  final ThemeLoaderV4 _themeLoaderV4;

  IntegrationWiringV3({
    this.persona = const _PlaceholderPersona(),
    this.adaptive = const _PlaceholderAdaptive(),
    this.theme = const _PlaceholderTheme(),
    this.visual = const _PlaceholderVisual(),
    this.ai = const _PlaceholderAI(),
    ThemeLoaderV4? themeLoaderV4,
  }) : _themeLoaderV4 = themeLoaderV4 ?? ThemeLoaderV4();

  void wirePersonalization() {}
  void wirePersona() {}
  void wireTheme() {}
  void syncAll() {}

  String snapshotIntegration() => '';

  void syncV4Activation(bool flag) {
    _v4Active = flag;
    _themeLoaderV4.loadActivation(flag);
    forwardV4Activation();
  }

  bool getV4Activation() => _v4Active;

  ThemeLoaderV4 getThemeLoaderV4() => _themeLoaderV4;

  void forwardV4Activation() {
    _pushActivation(persona);
    _pushActivation(adaptive);
    _pushActivation(visual);
  }

  void _pushActivation(Object component) {
    try {
      (component as dynamic).syncV4Activation(_v4Active);
    } catch (_) {
      // ignore components without the hook
    }
  }
}

class _PlaceholderPersona {
  const _PlaceholderPersona();
}

class _PlaceholderAdaptive {
  const _PlaceholderAdaptive();
}

class _PlaceholderTheme {
  const _PlaceholderTheme();
}

class _PlaceholderVisual {
  const _PlaceholderVisual();
}

class _PlaceholderAI {
  const _PlaceholderAI();
}
