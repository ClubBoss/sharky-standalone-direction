import 'dynamic_theme_spec.dart';

class BuildContext {}

class ThemeData {}

Future<ThemeData> applyDynamicThemeBridge(
  BuildContext context,
  DynamicThemeSpec spec,
  ThemeData? baseTheme,
) {
  throw UnsupportedError(
    'Dynamic theme application requires Flutter; run inside a Flutter context.',
  );
}
