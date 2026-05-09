class StabilityConsistencyV3 {
  StabilityConsistencyV3._({
    required this.omegaFinalExport,
    required this.omegaMasterBundle,
    required this.lambdaFinalAggregation,
    required this.tableAdaptationSurface,
    required this.coldPathValidator,
  });

  factory StabilityConsistencyV3.fromInputs({
    Map<String, Object>? omegaFinalExport,
    Map<String, Object>? omegaMasterBundle,
    Map<String, Object>? lambdaFinalAggregation,
    Map<String, Object>? tableAdaptationSurface,
    Map<String, Object>? coldPathValidator,
  }) => StabilityConsistencyV3._(
    omegaFinalExport: _sanitize(omegaFinalExport),
    omegaMasterBundle: _sanitize(omegaMasterBundle),
    lambdaFinalAggregation: _sanitize(lambdaFinalAggregation),
    tableAdaptationSurface: _sanitize(tableAdaptationSurface),
    coldPathValidator: _sanitize(coldPathValidator),
  );

  final Map<String, Object> omegaFinalExport;
  final Map<String, Object> omegaMasterBundle;
  final Map<String, Object> lambdaFinalAggregation;
  final Map<String, Object> tableAdaptationSurface;
  final Map<String, Object> coldPathValidator;

  Map<String, Object> build() {
    final double readyRatio = _readyRatio();
    final double driftRatio = _driftRatio();
    final double missingRatio = _missingRatio();
    final String tag = _determineTag(driftRatio, missingRatio);
    return Map<String, Object>.unmodifiable(<String, Object>{
      'stability_consistency_v3':
          Map<String, Object>.unmodifiable(<String, Object>{
            'ready_ratio': readyRatio,
            'drift_ratio': driftRatio,
            'missing_ratio': missingRatio,
            'tag': _ascii(tag),
            'ready': true,
          }),
    });
  }

  double _readyRatio() {
    final List<Map<String, Object>> sections = <Map<String, Object>>[
      omegaFinalExport,
      omegaMasterBundle,
      lambdaFinalAggregation,
      tableAdaptationSurface,
      coldPathValidator,
    ];
    final int readyCount = sections.where(_isReady).length;
    return readyCount / sections.length;
  }

  double _driftRatio() {
    final Set<String> expectedKeys = <String>{
      'ready',
      'tag',
      'surface_strength',
      'master_value',
      'fusion_value',
      'shift_strength',
      'highlight_strength',
      'engine_strength',
    };
    final Set<String> observed = <String>{};
    observed.addAll(omegaFinalExport.keys.whereType<String>());
    observed.addAll(omegaMasterBundle.keys.whereType<String>());
    observed.addAll(lambdaFinalAggregation.keys.whereType<String>());
    observed.addAll(tableAdaptationSurface.keys.whereType<String>());
    observed.addAll(coldPathValidator.keys.whereType<String>());
    final int driftCount = observed
        .where((key) => !expectedKeys.contains(key))
        .length;
    return driftCount / (observed.isEmpty ? 1 : observed.length);
  }

  double _missingRatio() {
    final List<Map<String, Object>> sections = <Map<String, Object>>[
      omegaFinalExport,
      omegaMasterBundle,
      lambdaFinalAggregation,
      tableAdaptationSurface,
      coldPathValidator,
    ];
    final int missingCount = sections
        .where((section) => !_isReady(section))
        .length;
    return missingCount / sections.length;
  }

  String _determineTag(double driftRatio, double missingRatio) {
    if (driftRatio > 0.15 || missingRatio > 0.15) return 'critical';
    if (driftRatio > 0.0 || missingRatio > 0.0) return 'warn';
    return 'ok';
  }

  static bool _isReady(Map<String, Object> map) {
    final Object? ready = map['ready'];
    if (ready is bool) return ready;
    return false;
  }

  static Map<String, Object> _sanitize(Map<String, Object>? map) {
    if (map == null) return const <String, Object>{};
    final Map<String, Object> cleaned = <String, Object>{};
    for (final MapEntry<String, Object> entry in map.entries) {
      cleaned[_ascii(entry.key)] = entry.value;
    }
    return cleaned;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
