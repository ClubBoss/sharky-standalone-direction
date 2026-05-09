import 'ui_theme_entrypoint_v4.dart';

class UIThemeWiringV4 {
  UIThemeWiringV4(this._entry);

  final UIThemeEntrypointV4 _entry;

  void attachToRoot() {}

  dynamic getTheme() => _entry.getTokens();

  bool isV4Active() => _entry.isV4Active();
}
