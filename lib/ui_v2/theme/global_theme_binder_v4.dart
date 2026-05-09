import 'theme_context_v4.dart';

class GlobalThemeBinderV4 {
  GlobalThemeBinderV4(this._context);

  final ThemeContextV4 _context;

  bool getV4Active() => _context.isV4Active();

  dynamic getTokens() => _context.getTokens();

  void prepareForUI() {}
}
