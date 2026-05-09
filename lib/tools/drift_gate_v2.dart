import 'dart:convert';

class DriftGateV2 {
  const DriftGateV2({
    this.rewrittenMap = const <String, Object>{},
    this.baselineMap = const <String, Object>{},
  });

  DriftGateV2.fromInputs({
    Map<String, Object?>? rewrittenMap,
    Map<String, Object?>? baselineMap,
  }) : this(rewrittenMap: _safe(rewrittenMap), baselineMap: _safe(baselineMap));

  final Map<String, Object> rewrittenMap;
  final Map<String, Object> baselineMap;

  Map<String, Object> build() =>
      buildDriftGateV2(rewrittenMap: rewrittenMap, baselineMap: baselineMap);

  static Map<String, Object> buildDriftGateV2({
    required Map<String, Object> rewrittenMap,
    required Map<String, Object> baselineMap,
  }) {
    final List<String> rewrittenKeys = _sortedKeys(rewrittenMap);
    final List<String> baselineKeys = _sortedKeys(baselineMap);
    final Set<String> rewrittenSet = Set<String>.from(rewrittenKeys);
    final Set<String> baselineSet = Set<String>.from(baselineKeys);
    final List<String> missingInRewritten =
        baselineSet.difference(rewrittenSet).toList()..sort();
    final List<String> missingInBaseline =
        rewrittenSet.difference(baselineSet).toList()..sort();
    final bool driftDetected = _hasDrift(
      rewrittenMap,
      baselineMap,
      rewrittenKeys,
      baselineKeys,
      missingInRewritten,
      missingInBaseline,
    );
    return <String, Object>{
      'drift_gate_v2': <String, Object>{
        'rewritten_keys': rewrittenKeys,
        'baseline_keys': baselineKeys,
        'missing_in_rewritten': missingInRewritten,
        'missing_in_baseline': missingInBaseline,
        'drift_detected': driftDetected,
        'ready': false,
      },
    };
  }

  static bool _hasDrift(
    Map<String, Object> rewrittenMap,
    Map<String, Object> baselineMap,
    List<String> rewrittenKeys,
    List<String> baselineKeys,
    List<String> missingInRewritten,
    List<String> missingInBaseline,
  ) {
    if (missingInRewritten.isNotEmpty || missingInBaseline.isNotEmpty) {
      return true;
    }
    final Set<String> overlap = <String>{...rewrittenKeys, ...baselineKeys}
        .where(
          (key) =>
              rewrittenMap.containsKey(key) && baselineMap.containsKey(key),
        )
        .toSet();
    for (final String key in overlap) {
      final String rewrittenValue = _valueAsString(rewrittenMap[key]);
      final String baselineValue = _valueAsString(baselineMap[key]);
      if (rewrittenValue != baselineValue) {
        return true;
      }
    }
    return false;
  }

  static String _valueAsString(Object? value) {
    if (value is String) {
      return _ascii(value);
    }
    return jsonEncode(value);
  }

  static List<String> _sortedKeys(Map<String, Object> map) {
    final List<String> keys = map.keys.whereType<String>().map(_ascii).toList()
      ..sort();
    return keys;
  }

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> target = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      final String key = _ascii(entry.key);
      final Object value = entry.value is String
          ? _ascii(entry.value as String)
          : entry.value ?? '';
      target[key] = value;
    }
    return target;
  }

  static String _ascii(String input) =>
      String.fromCharCodes(input.codeUnits.where((c) => c >= 0 && c < 128));
}
