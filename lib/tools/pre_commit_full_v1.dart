class PreCommitFullV1 {
  const PreCommitFullV1({
    this.unifiedValidationMap = const <String, Object>{},
    this.driftGateMap = const <String, Object>{},
    this.formatOk = false,
    this.analyzeOk = false,
    this.dartTestsOk = false,
    this.flutterTestsOk = false,
  });

  PreCommitFullV1.fromInputs({
    Map<String, Object?>? unifiedValidationMap,
    Map<String, Object?>? driftGateMap,
    bool formatOk = false,
    bool analyzeOk = false,
    bool dartTestsOk = false,
    bool flutterTestsOk = false,
  }) : this(
         unifiedValidationMap: _safe(unifiedValidationMap),
         driftGateMap: _safe(driftGateMap),
         formatOk: formatOk,
         analyzeOk: analyzeOk,
         dartTestsOk: dartTestsOk,
         flutterTestsOk: flutterTestsOk,
       );

  final Map<String, Object> unifiedValidationMap;
  final Map<String, Object> driftGateMap;
  final bool formatOk;
  final bool analyzeOk;
  final bool dartTestsOk;
  final bool flutterTestsOk;

  Map<String, Object> build() => buildPreCommitFullV1(
    unifiedValidationMap: unifiedValidationMap,
    driftGateMap: driftGateMap,
    formatOk: formatOk,
    analyzeOk: analyzeOk,
    dartTestsOk: dartTestsOk,
    flutterTestsOk: flutterTestsOk,
  );

  static Map<String, Object> buildPreCommitFullV1({
    required Map<String, Object> unifiedValidationMap,
    required Map<String, Object> driftGateMap,
    required bool formatOk,
    required bool analyzeOk,
    required bool dartTestsOk,
    required bool flutterTestsOk,
  }) {
    final bool unifiedValidationOk = unifiedValidationMap['all_ok'] == true;
    final bool driftGateOk = driftGateMap['drift_detected'] == false;
    final bool allOk =
        formatOk &&
        analyzeOk &&
        dartTestsOk &&
        flutterTestsOk &&
        unifiedValidationOk &&
        driftGateOk;
    return <String, Object>{
      'pre_commit_full_v1': <String, Object>{
        'format_ok': formatOk,
        'analyze_ok': analyzeOk,
        'dart_tests_ok': dartTestsOk,
        'flutter_tests_ok': flutterTestsOk,
        'unified_validation_ok': unifiedValidationOk,
        'drift_gate_ok': driftGateOk,
        'all_ok': allOk,
        'sorted_checks': <String>[
          'format_ok',
          'analyze_ok',
          'dart_tests_ok',
          'flutter_tests_ok',
          'unified_validation_ok',
          'drift_gate_ok',
        ],
        'ready': false,
      },
    };
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
