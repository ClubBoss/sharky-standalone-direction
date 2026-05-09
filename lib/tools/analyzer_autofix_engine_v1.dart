class AnalyzerAutoFixEngineV1 {
  const AnalyzerAutoFixEngineV1({
    this.diagnostics = const <Map<String, dynamic>>[],
  });

  static Map<String, Object> buildAnalyzerAutoFixEngineV1({
    required List<Map<String, dynamic>> diagnostics,
  }) => AnalyzerAutoFixEngineV1(diagnostics: diagnostics).build();

  AnalyzerAutoFixEngineV1.fromInputs({Map<String, Object?>? diagnostics})
    : this(diagnostics: _extractDiagnostics(diagnostics));

  final List<Map<String, dynamic>> diagnostics;

  Map<String, Object> build() {
    final normalizedDiagnostics = diagnostics
        .map(_normalizeDiagnostic)
        .toList(growable: false);

    final categoryBuckets = <String, List<Map<String, Object>>>{
      'unused_import': <Map<String, Object>>[],
      'unused_field': <Map<String, Object>>[],
      'implicit_this': <Map<String, Object>>[],
      'undefined_identifier': <Map<String, Object>>[],
      'other': <Map<String, Object>>[],
    };

    for (final normalized in normalizedDiagnostics) {
      final code = normalized['code'] as String? ?? '';
      final category = _codeToCategory[code] ?? 'other';
      categoryBuckets[category]!.add(normalized);
    }

    for (final bucket in categoryBuckets.values) {
      bucket.sort(_compareDiagnostics);
    }

    final engineMap = <String, Object>{
      'unused_import': categoryBuckets['unused_import']!,
      'unused_field': categoryBuckets['unused_field']!,
      'implicit_this': categoryBuckets['implicit_this']!,
      'undefined_identifier': categoryBuckets['undefined_identifier']!,
      'other': categoryBuckets['other']!,
      'total': normalizedDiagnostics.length,
      'ready': false,
    };

    return <String, Object>{'analyzer_autofix_engine_v1': engineMap};
  }

  static const Map<String, String> _codeToCategory = {
    'unused_import': 'unused_import',
    'unused_field': 'unused_field',
    'implicit_this': 'implicit_this',
    'undefined_identifier': 'undefined_identifier',
  };

  static Map<String, Object> _normalizeDiagnostic(
    Map<String, dynamic> diagnostic,
  ) {
    final file = _normalizeToAscii(diagnostic['file']?.toString() ?? '');
    final code = _normalizeToAscii(diagnostic['code']?.toString() ?? '');
    final message = _normalizeToAscii(diagnostic['message']?.toString() ?? '');
    final line = _normalizeLine(diagnostic['line']);

    return <String, Object>{
      'file': file,
      'line': line,
      'code': code,
      'message': message,
    };
  }

  static int _normalizeLine(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0;
  }

  static String _normalizeToAscii(String raw) => String.fromCharCodes(
    raw.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );

  static int _compareDiagnostics(
    Map<String, Object> first,
    Map<String, Object> second,
  ) {
    final fileCompare = (first['file'] as String).compareTo(
      second['file'] as String,
    );
    if (fileCompare != 0) return fileCompare;

    final firstLine = first['line'] as int;
    final secondLine = second['line'] as int;
    final lineCompare = firstLine.compareTo(secondLine);
    if (lineCompare != 0) return lineCompare;

    return (first['code'] as String).compareTo(second['code'] as String);
  }

  static List<Map<String, dynamic>> _extractDiagnostics(
    Map<String, Object?>? diagnostics,
  ) {
    if (diagnostics == null) return const <Map<String, dynamic>>[];
    final Object? raw = diagnostics['diagnostics'];
    if (raw is Iterable) {
      final List<Map<String, dynamic>> result = <Map<String, dynamic>>[];
      for (final Object? entry in raw) {
        if (entry is Map<String, dynamic>) {
          result.add(_cleanMap(entry));
        } else if (entry is Map) {
          result.add(entry.cast<String, dynamic>());
        }
      }
      return result;
    }
    return const <Map<String, dynamic>>[];
  }

  static Map<String, dynamic> _cleanMap(Map<String, dynamic> source) {
    final Map<String, dynamic> copy = <String, dynamic>{};
    for (final MapEntry<String, dynamic> entry in source.entries) {
      copy[_normalizeToAscii(entry.key)] = entry.value;
    }
    return copy;
  }
}
