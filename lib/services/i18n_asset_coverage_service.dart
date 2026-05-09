import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class I18nAssetCoverageBundle {
  I18nAssetCoverageBundle({
    required this.totalKeys,
    required this.covered,
    required this.coverageRatio,
    required this.missingInGlossary,
    required this.missingInTm,
    required this.missingInPseudo,
    required this.timestamp,
  });

  final int totalKeys;
  final int covered;
  final double coverageRatio;
  final List<String> missingInGlossary;
  final List<String> missingInTm;
  final List<String> missingInPseudo;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'total_keys': totalKeys,
    'covered': covered,
    'coverage_ratio': coverageRatio,
    'missing_in_glossary': missingInGlossary,
    'missing_in_tm': missingInTm,
    'missing_in_pseudo': missingInPseudo,
    'timestamp': timestamp.toIso8601String(),
  };
}

class I18nAssetCoverageService {
  static const _tmPath = 'release/_reports/translation_memory_builder.json';
  static const _glossaryPath = 'release/_reports/base_glossary_expander.json';
  static const _pseudoPath = 'release/_reports/pseudo_localization.json';

  const I18nAssetCoverageService();

  Future<I18nAssetCoverageBundle> run() async {
    final tmData = await _loadJson(_tmPath);
    final glossaryData = await _loadJson(_glossaryPath);
    final pseudoData = await _loadJson(_pseudoPath, enforceAscii: false);

    final tmKeys = _extractTmKeys(tmData);
    final glossaryKeys = _extractGlossaryKeys(glossaryData);
    final pseudoKeys = _extractPseudoKeys(pseudoData);

    final missingInGlossary =
        tmKeys.where((key) => !glossaryKeys.contains(key)).toList()..sort();
    final missingInPseudo =
        tmKeys.where((key) => !pseudoKeys.contains(key)).toList()..sort();
    final allReportedKeys = {...glossaryKeys, ...pseudoKeys};
    final missingInTm =
        allReportedKeys.where((key) => !tmKeys.contains(key)).toList()..sort();

    final coveredCount = tmKeys
        .where((key) => glossaryKeys.contains(key) && pseudoKeys.contains(key))
        .length;
    final totalKeys = tmKeys.length;
    final coverageRatio = totalKeys == 0 ? 1.0 : coveredCount / totalKeys;

    return I18nAssetCoverageBundle(
      totalKeys: totalKeys,
      covered: coveredCount,
      coverageRatio: coverageRatio,
      missingInGlossary: missingInGlossary,
      missingInTm: missingInTm,
      missingInPseudo: missingInPseudo,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadJson(
    String path, {
    bool enforceAscii = true,
  }) async {
    final file = File(path);
    if (!await file.exists()) {
      throw I18nAssetCoverageException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw I18nAssetCoverageException('Empty $path');
    }
    if (enforceAscii && !_isAsciiOnly(bytes)) {
      throw I18nAssetCoverageException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw I18nAssetCoverageException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  List<String> _extractTmKeys(Map<String, Object?> raw) {
    final entries = raw['entries'];
    if (entries is! List<Object?>) {
      return const [];
    }
    final keys = <String>{};
    for (final candidate in entries) {
      if (candidate is Map<String, Object?>) {
        final key = candidate['key'];
        if (key is String && key.trim().isNotEmpty) {
          keys.add(key);
        }
      }
    }
    return keys.toList()..sort();
  }

  List<String> _extractGlossaryKeys(Map<String, Object?> raw) {
    final entries = raw['glossary_entries'];
    if (entries is! List<Object?>) {
      return const [];
    }
    final keys = <String>{};
    for (final candidate in entries) {
      if (candidate is Map<String, Object?>) {
        final key = candidate['glossary_key'];
        if (key is String && key.trim().isNotEmpty) {
          keys.add(key);
        }
      }
    }
    return keys.toList()..sort();
  }

  List<String> _extractPseudoKeys(Map<String, Object?> raw) {
    final entries = raw['pseudo_entries'];
    if (entries is! List<Object?>) {
      return const [];
    }
    final keys = <String>{};
    for (final candidate in entries) {
      if (candidate is Map<String, Object?>) {
        final key = candidate['key'];
        if (key is String && key.trim().isNotEmpty) {
          keys.add(key);
        }
      }
    }
    return keys.toList()..sort();
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((value) => value >= 0x00 && value <= _asciiLimit);
}

class I18nAssetCoverageException implements Exception {
  final String message;

  I18nAssetCoverageException(this.message);

  @override
  String toString() => 'I18nAssetCoverageException: $message';
}
