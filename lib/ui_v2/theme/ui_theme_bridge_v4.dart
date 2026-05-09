import 'ui_theme_wiring_v4.dart';

class UIThemeBridgeV4 {
  UIThemeBridgeV4(this._wiring);

  final UIThemeWiringV4 _wiring;

  void injectIntoApp() {}

  bool getActive() => _wiring.isV4Active();

  dynamic getTheme() => _wiring.getTheme();
}
