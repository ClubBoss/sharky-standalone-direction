class TimingConsolidatorV1 {
  const TimingConsolidatorV1({
    this.timingSeedMap = const <String, Object>{},
    this.timingEnvelopeMap = const <String, Object>{},
  });

  TimingConsolidatorV1.fromInputs({
    Map<String, Object?>? timingSeedMap,
    Map<String, Object?>? timingEnvelopeMap,
  }) : this(
         timingSeedMap: _safe(timingSeedMap),
         timingEnvelopeMap: _safe(timingEnvelopeMap),
       );

  final Map<String, Object> timingSeedMap;
  final Map<String, Object> timingEnvelopeMap;

  Map<String, Object> build() {
    final double seedValue = _extractScore(
      timingSeedMap['timing_seed_v1'] as Map<String, Object?>?,
      'seed_value',
    );
    final double envelopeValue = _extractScore(
      timingEnvelopeMap['timing_envelope_v1'] as Map<String, Object?>?,
      'envelope_value',
    );

    double consolidatedValue = (seedValue * 0.5) + (envelopeValue * 0.5);
    consolidatedValue = consolidatedValue.clamp(0.0, 1.0);

    String consolidatedTag = 'timing_soft';
    if (consolidatedValue >= 0.80) {
      consolidatedTag = 'timing_sharp';
    } else if (consolidatedValue >= 0.45) {
      consolidatedTag = 'timing_balanced';
    }

    return <String, Object>{
      'timing_consolidator_v1': <String, Object>{
        'consolidated_value': consolidatedValue,
        'consolidated_tag': _ascii(consolidatedTag),
        'ready': true,
      },
    };
  }

  static double _extractScore(Map<String, Object?>? body, String key) {
    if (body == null) return 0.0;
    final Object? raw = body[key];
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      final double? parsed = double.tryParse(raw);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> cleaned = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      cleaned[entry.key] = entry.value ?? '';
    }
    return cleaned;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
