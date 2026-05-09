import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class RuVerifierBundle {
  RuVerifierBundle({
    required this.verified,
    required this.invalidKeys,
    required this.inconsistentSources,
    required this.nonAsciiRuEntries,
    required this.timestamp,
  });

  final bool verified;
  final List<String> invalidKeys;
  final List<String> inconsistentSources;
  final List<String> nonAsciiRuEntries;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'verified': verified,
    'invalid_keys': invalidKeys,
    'inconsistent_sources': inconsistentSources,
    'non_ascii_ru_entries': nonAsciiRuEntries,
    'timestamp': timestamp.toIso8601String(),
  };
}

class RuVerifierService {
  static const _bindingPath = 'release/_reports/ru_en_binding_summary.json';
  static const _tmPath = 'release/_reports/translation_memory_builder.json';
  static const _glossaryPath = 'release/_reports/base_glossary_expander.json';

  const RuVerifierService();

  Future<RuVerifierBundle> run() async {
    final bindingData = await _loadAsciiJson(_bindingPath);
    final tmData = await _loadAsciiJson(_tmPath);
    final glossaryData = await _loadAsciiJson(_glossaryPath);

    final bindingEntries = _extractBindingEntries(bindingData['entries']);
    final tmMap = _mapEntries(tmData['entries']);
    final glossaryKeys = _collectGlossaryKeys(glossaryData['glossary_entries']);

    final invalidKeys = <String>{};
    final inconsistentSources = <String>{};
    final nonAsciiRuEntries = <String>{};

    for (final entry in bindingEntries) {
      final key = entry['key'];
      if (key == null || key.isEmpty) {
        continue;
      }
      final tmSource = tmMap[key];
      final entrySource = entry['source_en'] as String? ?? '';
      final targetRu = entry['target_ru'] as String? ?? '';
      final missingValue = entry['missing'];
      final highRiskValue = entry['high_risk'];

      final existsInTm = tmSource != null;
      final existsInGlossary = glossaryKeys.contains(key);
      if (!existsInTm || !existsInGlossary) {
        invalidKeys.add(key);
      }

      final missingFlag = missingValue is bool ? missingValue : null;
      if (missingFlag == null) {
        inconsistentSources.add(key);
      } else {
        final shouldBeMissing = !existsInGlossary;
        if (missingFlag != shouldBeMissing) {
          inconsistentSources.add(key);
        }
      }

      final highRiskFlag = highRiskValue is bool ? highRiskValue : null;
      if (highRiskFlag == null) {
        inconsistentSources.add(key);
      }

      if (tmSource != null && entrySource != tmSource) {
        inconsistentSources.add(key);
      }

      if (targetRu.isNotEmpty && !_isAsciiOnly(targetRu.codeUnits)) {
        nonAsciiRuEntries.add(key);
      }
    }

    final verified =
        invalidKeys.isEmpty &&
        inconsistentSources.isEmpty &&
        nonAsciiRuEntries.isEmpty;

    return RuVerifierBundle(
      verified: verified,
      invalidKeys: invalidKeys.toList()..sort(),
      inconsistentSources: inconsistentSources.toList()..sort(),
      nonAsciiRuEntries: nonAsciiRuEntries.toList()..sort(),
      timestamp: DateTime.now().toUtc(),
    );
  }

  List<Map<String, dynamic>> _extractBindingEntries(Object? raw) {
    if (raw is! List<Object?>) {
      return const [];
    }
    final entries = <Map<String, dynamic>>[];
    for (final entry in raw) {
      if (entry is Map<String, Object?>) {
        entries.add(Map<String, dynamic>.from(entry));
      }
    }
    return entries;
  }

  Map<String, String> _mapEntries(Object? raw) {
    if (raw is! List<Object?>) {
      return const {};
    }
    final map = <String, String>{};
    for (final entry in raw) {
      if (entry is Map<String, Object?>) {
        final key = entry['key'];
        final source = entry['source_en'];
        if (key is String && source is String) {
          map[key] = source;
        }
      }
    }
    return map;
  }

  Set<String> _collectGlossaryKeys(Object? raw) {
    if (raw is! List<Object?>) {
      return const {};
    }
    final keys = <String>{};
    for (final entry in raw) {
      if (entry is Map<String, Object?>) {
        final key = entry['glossary_key'];
        if (key is String) {
          keys.add(key);
        }
      }
    }
    return keys;
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw RuVerifierException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw RuVerifierException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw RuVerifierException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw RuVerifierException('Invalid JSON in $path: ${error.message}');
    }
  }

  bool _isAsciiOnly(Iterable<int> bytes) =>
      bytes.every((value) => value >= 0x00 && value <= _asciiLimit);
}

class RuVerifierException implements Exception {
  final String message;

  RuVerifierException(this.message);

  @override
  String toString() => 'RuVerifierException: $message';
}
