import 'v4_token_registry_v1.dart';

class V4ThemeStruct {
  V4ThemeStruct({
    Map<String, Object?>? colors,
    Map<String, Object?>? typography,
    Map<String, Object?>? spacing,
    Map<String, Object?>? elevation,
    Map<String, Object?>? motion,
  }) : colors = colors ?? const {},
       typography = typography ?? const {},
       spacing = spacing ?? const {},
       elevation = elevation ?? const {},
       motion = motion ?? const {};

  final Map<String, Object?> colors;
  final Map<String, Object?> typography;
  final Map<String, Object?> spacing;
  final Map<String, Object?> elevation;
  final Map<String, Object?> motion;

  Map<String, Object?> asMap() => {
    "colors": colors,
    "typography": typography,
    "spacing": spacing,
    "elevation": elevation,
    "motion": motion,
  };

  factory V4ThemeStruct.fromDefaults() {
    return V4ThemeStruct(
      colors: V4TokenRegistryV1.baseColors,
      typography: V4TokenRegistryV1.baseTypography,
      spacing: V4TokenRegistryV1.baseSpacing,
      elevation: const {},
      motion: const {},
    );
  }
}
