class ExplanationInlineInjectorV4 {
  const ExplanationInlineInjectorV4({
    required this.profile,
    required this.kernel,
    required this.overlay,
    required this.hooks,
    required this.tooltips,
  });

  final Map<String, Object> profile;
  final Map<String, Object> kernel;
  final Map<String, Object> overlay;
  final List<Map<String, String>> hooks;
  final List<Map<String, String>> tooltips;

  Map<String, Object> exportInlineExplainBundle() =>
      Map<String, Object>.unmodifiable({
        'profile': Map<String, Object>.unmodifiable(profile),
        'kernel': Map<String, Object>.unmodifiable(kernel),
        'overlay': Map<String, Object>.unmodifiable(overlay),
        'hooks': List<Map<String, String>>.unmodifiable(
          hooks.map(Map<String, String>.unmodifiable),
        ),
        'tooltips': List<Map<String, String>>.unmodifiable(
          tooltips.map(Map<String, String>.unmodifiable),
        ),
      });
}
