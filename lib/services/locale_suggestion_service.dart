import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class LocaleSuggestionBundle {
  LocaleSuggestionBundle({
    required this.riskScore,
    required this.missingKeys,
    required this.pseudoStats,
    required this.priority,
    required this.timestamp,
  });

  final double riskScore;
  final List<String> missingKeys;
  final Map<String, Object?> pseudoStats;
  final String priority;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'risk_score': riskScore,
    'missing_keys': missingKeys,
    'pseudo_stats': pseudoStats,
    'priority': priority,
    'timestamp': timestamp.toIso8601String(),
  };
}

class LocaleSuggestionService {
  static const _tmPath = 'release/_reports/translation_memory_builder.json';
  static const _glossaryPath = 'release/_reports/base_glossary_expander.json';
  static const _pseudoPath = 'release/_reports/pseudo_localization.json';
  static const _coveragePath = 'release/_reports/i18n_asset_coverage.json';

  const LocaleSuggestionService();

  Future<LocaleSuggestionBundle> run() async {
    final tmData = await _loadAsciiJson(_tmPath);
    final glossaryData = await _loadAsciiJson(_glossaryPath);
    final pseudoData = await _loadAsciiJson(_pseudoPath);
    final coverageData = await _loadAsciiJson(_coveragePath);

    final tmKeys = _extractKeysFromEntries(tmData['entries']);
    final glossaryKeys = _extractKeysFromGlossary(
      glossaryData['glossary_entries'],
    );
    final pseudoDiags = _extractPseudoDiagnostics(pseudoData['pseudo_entries']);
    final coverageTotal = _extractTotalKeys(coverageData);
    final coverageMissing = _extractMissingKeys(coverageData);

    final avgPseudoRatio = pseudoDiags.isEmpty
        ? 1.0
        : pseudoDiags
                  .map((entry) => entry.lengthRatio)
                  .reduce((a, b) => a + b) /
              pseudoDiags.length;
    final maxPseudoRatio = pseudoDiags.isEmpty
        ? 1.0
        : pseudoDiags
              .map((entry) => entry.lengthRatio)
              .reduce((a, b) => a > b ? a : b);
    final highRiskCount = pseudoDiags
        .where((entry) => entry.lengthRatio > 1.35)
        .length;

    final totalKeys = coverageTotal;
    final missingKeys = coverageMissing.toList()..sort();
    final missingRatio = totalKeys == 0 ? 0.0 : missingKeys.length / totalKeys;

    final riskScore = (avgPseudoRatio + missingRatio) / 2;
    final priority = _priorityForScore(riskScore);

    final pseudoStats = <String, Object?>{
      'avg_length_ratio': avgPseudoRatio,
      'max_length_ratio': maxPseudoRatio,
      'high_risk_entries': highRiskCount,
      'entry_count': pseudoDiags.length,
      'tm_entry_count': tmKeys.length,
      'glossary_entry_count': glossaryKeys.length,
    };

    return LocaleSuggestionBundle(
      riskScore: riskScore,
      missingKeys: missingKeys,
      pseudoStats: pseudoStats,
      priority: priority,
      timestamp: DateTime.now().toUtc(),
    );
  }

  List<String> _extractKeysFromEntries(Object? raw) {
    if (raw is! List<Object?>) {
      return const [];
    }
    final keys = <String>{};
    for (final candidate in raw) {
      if (candidate is Map<String, Object?>) {
        final key = candidate['key'];
        if (key is String && key.trim().isNotEmpty) {
          keys.add(key);
        }
      }
    }
    return keys.toList();
  }

  List<String> _extractKeysFromGlossary(Object? raw) {
    if (raw is! List<Object?>) {
      return const [];
    }
    final keys = <String>{};
    for (final candidate in raw) {
      if (candidate is Map<String, Object?>) {
        final key = candidate['glossary_key'];
        if (key is String && key.trim().isNotEmpty) {
          keys.add(key);
        }
      }
    }
    return keys.toList();
  }

  List<_PseudoDiag> _extractPseudoDiagnostics(Object? raw) {
    if (raw is! List<Object?>) {
      return const [];
    }
    final diagnostics = <_PseudoDiag>[];
    for (final candidate in raw) {
      if (candidate is Map<String, Object?>) {
        final key = candidate['key'];
        final ratioValue = candidate['length_ratio'];
        final ratio = ratioValue is num ? ratioValue.toDouble() : null;
        if (key is String && ratio != null) {
          diagnostics.add(_PseudoDiag(key: key, lengthRatio: ratio));
        }
      }
    }
    return diagnostics;
  }

  int _extractTotalKeys(Map<String, Object?> raw) {
    final total = raw['total_keys'];
    if (total is int) {
      return total;
    }
    if (total is num) {
      return total.toInt();
    }
    return 0;
  }

  Set<String> _extractMissingKeys(Map<String, Object?> raw) {
    final missing = <String>{};
    void collect(String key, Object? value) {
      if (value is List<Object?>) {
        for (final entry in value) {
          if (entry is String && entry.trim().isNotEmpty) {
            missing.add(entry);
          }
        }
      }
    }

    collect('missing_in_glossary', raw['missing_in_glossary']);
    collect('missing_in_tm', raw['missing_in_tm']);
    collect('missing_in_pseudo', raw['missing_in_pseudo']);
    return missing;
  }

  String _priorityForScore(double score) {
    if (score >= 0.70) return 'HIGH';
    if (score >= 0.40) return 'MEDIUM';
    return 'LOW';
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw LocaleSuggestionException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw LocaleSuggestionException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw LocaleSuggestionException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw LocaleSuggestionException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((value) => value >= 0x00 && value <= _asciiLimit);
}

class _PseudoDiag {
  _PseudoDiag({required this.key, required this.lengthRatio});

  final String key;
  final double lengthRatio;
}

class LocaleSuggestionException implements Exception {
  final String message;

  LocaleSuggestionException(this.message);

  @override
  String toString() => 'LocaleSuggestionException: $message';
}
