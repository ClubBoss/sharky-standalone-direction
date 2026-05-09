import 'v4_token_registry.dart';

class ThemeLoaderV4 {
  ThemeLoaderV4() : _tokens = const V4TokenRegistry();

  final V4TokenRegistry _tokens;
  bool _v4Active = false;

  V4TokenRegistry loadTokens() => _tokens;

  void loadActivation(bool flag) => _v4Active = flag;

  bool getV4Active() => _v4Active;

  V4TokenRegistry getTokens() => _tokens;
}
