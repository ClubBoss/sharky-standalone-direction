abstract class BaseComponentV3 {
  BaseComponentV3();

  void buildPlaceholder() {}

  void applyThemeTokens() {}
  void applySurface() {}
  void applyMotion() {}
  String appliedStyle = '';
  void applyResolvedStyle(String style) {
    appliedStyle = style;
  }

  Map<String, String> parsedTokens = const {};

  void applyStyleTokens() {
    parsedTokens = parseStyleTokens(appliedStyle);
  }

  Map<String, String> parseStyleTokens(String style) {
    return const {};
  }
}
