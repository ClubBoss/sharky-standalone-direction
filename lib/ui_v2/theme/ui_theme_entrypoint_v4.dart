import 'global_theme_binder_v4.dart';

class UIThemeEntrypointV4 {
  UIThemeEntrypointV4(this._binder);

  final GlobalThemeBinderV4 _binder;

  void initForApp() {}

  bool isV4Active() => _binder.getV4Active();

  dynamic getTokens() => _binder.getTokens();
}
