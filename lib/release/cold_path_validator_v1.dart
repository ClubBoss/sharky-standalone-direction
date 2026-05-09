import '../ui_v2/release/release_assembly_harmonization_v2.dart';

class ColdPathValidatorV1 {
  const ColdPathValidatorV1();

  static Map<String, Object> validate({
    required Map<String, Object?> v4SurfaceMap,
    required Map<String, Object?> v3SurfaceMap,
  }) {
    final List<String> v4Keys = _sortedKeys(v4SurfaceMap);
    final List<String> v3Keys = _sortedKeys(v3SurfaceMap);
    final List<String> missingInV4 = v3Keys
        .where((key) => !v4Keys.contains(key))
        .toList();
    final List<String> missingInV3 = v4Keys
        .where((key) => !v3Keys.contains(key))
        .toList();
    final bool ready = v4SurfaceMap.isNotEmpty && v3SurfaceMap.isNotEmpty;
    final bool compatible = missingInV4.isEmpty && missingInV3.isEmpty;
    return <String, Object>{
      'validator_ready': ready,
      'v4_keys': v4Keys,
      'v3_keys': v3Keys,
      'missing_in_v4': missingInV4,
      'missing_in_v3': missingInV3,
      'compatible': compatible,
      'harmonization': ReleaseAssemblyHarmonizationV2(
        Map<String, dynamic>.from(v4SurfaceMap),
        Map<String, dynamic>.from(v3SurfaceMap),
      ).asReadOnlyMap(),
    };
  }

  static List<String> _sortedKeys(Map<String, Object?> map) {
    final List<String> keys = map.keys.whereType<String>().toList()..sort();
    return keys;
  }
}
