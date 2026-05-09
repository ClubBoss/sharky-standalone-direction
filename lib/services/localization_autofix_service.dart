import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class LocalizationAutofixBundle {
  LocalizationAutofixBundle({
    required this.priority,
    required this.missingKeys,
    required this.inconsistentSources,
    required this.highRiskStrings,
    required this.timestamp,
  });

  final String priority;
  final List<String> missingKeys;
  final List<String> inconsistentSources;
  final List<String> highRiskStrings;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'priority': priority,
    'missing_keys': missingKeys,
    'inconsistent_sources': inconsistentSources,
    'high_risk_strings': highRiskStrings,
    'timestamp': timestamp.toIso8601String(),
  };
}

class LocalizationAutofixService {
  static const _tmPath = 'release/_reports/translation_memory_builder.json';
  static const _glossaryPath = 'release/_reports/base_glossary_expander.json';
  static const _pseudoPath = 'release/_reports/pseudo_localization.json';
  static const _coveragePath = 'release/_reports/i18n_asset_coverage.json';
  static const _suggestionPath =
      'release/_reports/locale_suggestion_summary.json';

  const LocalizationAutofixService();

  Future<LocalizationAutofixBundle> run() async {
    final tmData = await _loadAsciiJson(_tmPath);
    final glossaryData = await _loadAsciiJson(_glossaryPath);
    final pseudoData = await _loadAsciiJson(_pseudoPath);
    final coverageData = await _loadAsciiJson(_coveragePath);
    final suggestionData = await _loadAsciiJson(_suggestionPath);

    final tmSources = _extractTmSources(tmData['entries']);
    final glossaryEntries = _extractGlossaryEntries(
      glossaryData['glossary_entries'],
    );
    final pseudoRatios = _extractPseudoRatios(pseudoData['pseudo_entries']);
    final coverageMissing = _extractCoverageMissingKeys(coverageData);
    final priority = _extractPriority(suggestionData);

    final missingKeys = coverageMissing.toList()..sort();
    final inconsistentSources = _findInconsistentSources(
      tmSources,
      glossaryEntries,
    ).toList()..sort();
    final highRiskStrings =
        pseudoRatios
            .where((entry) => entry.ratio > 1.35)
            .map((entry) => entry.key)
            .toList()
          ..sort();

    return LocalizationAutofixBundle(
      priority: priority,
      missingKeys: missingKeys,
      inconsistentSources: inconsistentSources,
      highRiskStrings: highRiskStrings,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Map<String, String> _extractTmSources(Object? raw) {
    if (raw is! List<Object?>) {
      return const {};
    }
    final map = <String, String>{};
    for (final item in raw) {
      if (item is Map<String, Object?>) {
        final key = item['key'];
        final source = item['source_en'];
        if (key is String && source is String && source.isNotEmpty) {
          map[key] = source;
        }
      }
    }
    return map;
  }

  Map<String, String> _extractGlossaryEntries(Object? raw) {
    if (raw is! List<Object?>) {
      return const {};
    }
    final map = <String, String>{};
    for (final item in raw) {
      if (item is Map<String, Object?>) {
        final key = item['glossary_key'];
        final def = item['glossary_def_en'];
        if (key is String && def is String) {
          map[key] = def;
        }
      }
    }
    return map;
  }

  List<_PseudoRatio> _extractPseudoRatios(Object? raw) {
    if (raw is! List<Object?>) {
      return const [];
    }
    final ratios = <_PseudoRatio>[];
    for (final item in raw) {
      if (item is Map<String, Object?>) {
        final key = item['key'];
        final ratioValue = item['length_ratio'];
        final ratio = ratioValue is num ? ratioValue.toDouble() : null;
        if (key is String && ratio != null) {
          ratios.add(_PseudoRatio(key: key, ratio: ratio));
        }
      }
    }
    return ratios;
  }

  Set<String> _extractCoverageMissingKeys(Map<String, Object?> raw) {
    final missing = <String>{};
    void collect(Object? value) {
      if (value is List<Object?>) {
        for (final entry in value) {
          if (entry is String && entry.trim().isNotEmpty) {
            missing.add(entry);
          }
        }
      }
    }

    collect(raw['missing_in_glossary']);
    collect(raw['missing_in_tm']);
    collect(raw['missing_in_pseudo']);
    return missing;
  }

  Set<String> _findInconsistentSources(
    Map<String, String> tmSources,
    Map<String, String> glossaryEntries,
  ) {
    final inconsistent = <String>{};
    for (final key in glossaryEntries.keys) {
      final tmValue = tmSources[key];
      final glossaryValue = glossaryEntries[key];
      if (tmValue != null &&
          glossaryValue != null &&
          glossaryValue.isNotEmpty &&
          glossaryValue != tmValue) {
        inconsistent.add(key);
      }
    }
    return inconsistent;
  }

  String _extractPriority(Map<String, Object?> raw) {
    final value = raw['priority'];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return 'LOW';
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw LocalizationAutofixException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw LocalizationAutofixException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw LocalizationAutofixException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw LocalizationAutofixException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((value) => value >= 0x00 && value <= _asciiLimit);
}

class _PseudoRatio {
  _PseudoRatio({required this.key, required this.ratio});

  final String key;
  final double ratio;
}

class LocalizationAutofixException implements Exception {
  final String message;

  LocalizationAutofixException(this.message);

  @override
  String toString() => 'LocalizationAutofixException: $message';
}
