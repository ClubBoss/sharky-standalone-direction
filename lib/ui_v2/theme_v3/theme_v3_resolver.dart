import '../theme_v3/style_token_bundle_v4.dart';
import '../theme_v3/theme_v3.dart';

ThemeV3 resolveThemeV3() => ThemeV3();

StyleTokenBundleV4 resolveComponentBundleV4() =>
    resolveThemeV3().getComponentBundleV4();
