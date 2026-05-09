import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;
const _allowedRuPlaceholders = {'', 'TBD', 'TODO'};

class CrossLocaleConsistencyResult {
  CrossLocaleConsistencyResult({
    required this.missingKeys,
    required this.inconsistentEn,
    required this.unexpectedRuPopulated,
    required this.orphanTmEntries,
    required this.consistencyPass,
    required this.timestamp,
  });

  final List<String> missingKeys;
  final List<String> inconsistentEn;
  final List<String> unexpectedRuPopulated;
  final List<String> orphanTmEntries;
  final bool consistencyPass;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'missing_keys': missingKeys,
    'inconsistent_en': inconsistentEn,
    'unexpected_ru_populated': unexpectedRuPopulated,
    'orphan_tm_entries': orphanTmEntries,
    'consistency_pass': consistencyPass,
    'timestamp': timestamp.toIso8601String(),
  };
}

class CrossLocaleConsistencyService {
  static const _glossaryPath = 'release/_reports/base_glossary_expander.json';
  static const _tmPath = 'release/_reports/translation_memory_builder.json';

  const CrossLocaleConsistencyService();

  Future<CrossLocaleConsistencyResult> run() async {
    final glossaryData = await _loadAsciiJson(_glossaryPath);
    final tmData = await _loadAsciiJson(_tmPath);

    final glossaryEntries = _extractGlossaryEntries(
      glossaryData['glossary_entries'],
    );
    final tmEntries = _extractTmEntries(tmData['entries']);

    final missingKeys = <String>[];
    final inconsistentEn = <String>[];
    final unexpectedRuPopulated = <String>[];

    for (final entry in glossaryEntries) {
      final glossaryKey = entry['glossary_key'];
      if (glossaryKey is! String) continue;
      final tmMatch = tmEntries[glossaryKey];
      if (tmMatch == null) {
        missingKeys.add(glossaryKey);
        continue;
      }
      final sourceEn = tmMatch['source_en'] as String? ?? '';
      if (sourceEn != entry['glossary_def_en']) {
        inconsistentEn.add(glossaryKey);
      }
      final ruDef = entry['glossary_def_ru'] as String? ?? '';
      if (!_allowedRuPlaceholders.contains(ruDef)) {
        unexpectedRuPopulated.add(glossaryKey);
      }
      tmEntries.remove(glossaryKey);
    }

    final orphanTmEntries = tmEntries.keys.toList()..sort();

    final pass =
        missingKeys.isEmpty &&
        inconsistentEn.isEmpty &&
        unexpectedRuPopulated.isEmpty &&
        orphanTmEntries.isEmpty;

    return CrossLocaleConsistencyResult(
      missingKeys: missingKeys,
      inconsistentEn: inconsistentEn,
      unexpectedRuPopulated: unexpectedRuPopulated,
      orphanTmEntries: orphanTmEntries,
      consistencyPass: pass,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw CrossLocaleConsistencyException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw CrossLocaleConsistencyException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw CrossLocaleConsistencyException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw CrossLocaleConsistencyException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);

  List<Map<String, Object?>> _extractGlossaryEntries(Object? raw) {
    if (raw is! List) return const [];
    final entries = <Map<String, Object?>>[];
    for (final entry in raw) {
      if (entry is Map<String, Object?>) {
        entries.add(entry);
      }
    }
    return entries;
  }

  Map<String, Map<String, Object?>> _extractTmEntries(Object? raw) {
    if (raw is! List) return {};
    final map = <String, Map<String, Object?>>{};
    for (final entry in raw) {
      if (entry is Map<String, Object?>) {
        final key = entry['key'];
        if (key is String) {
          map[key] = entry;
        }
      }
    }
    return map;
  }
}

class CrossLocaleConsistencyException implements Exception {
  final String message;

  CrossLocaleConsistencyException(this.message);

  @override
  String toString() => 'CrossLocaleConsistencyException: $message';
}
