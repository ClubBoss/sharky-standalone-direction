import '../integration/integration_wiring_v3.dart';
import 'theme_loader_v4.dart';
import 'v4_token_registry.dart';

class ThemeContextV4 {
  ThemeContextV4(this._wiring);

  final IntegrationWiringV3 _wiring;

  ThemeLoaderV4 get _loader => _wiring.getThemeLoaderV4();

  V4TokenRegistry getTokens() => _loader.getTokens();

  bool isV4Active() => _loader.getV4Active();
}
