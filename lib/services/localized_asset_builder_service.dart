import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class LocalizedAssetEntry {
  LocalizedAssetEntry({
    required this.key,
    required this.sourceEn,
    required this.targetRu,
    required this.missing,
    required this.highRisk,
  });

  final String key;
  final String sourceEn;
  final String targetRu;
  final bool missing;
  final bool highRisk;

  Map<String, Object?> toJson() => <String, Object?>{
    'key': key,
    'source_en': sourceEn,
    'target_ru': targetRu,
    'missing': missing,
    'high_risk': highRisk,
  };
}

class LocalizedAssetBundle {
  LocalizedAssetBundle({
    required this.entries,
    required this.coverage,
    required this.timestamp,
  });

  final List<LocalizedAssetEntry> entries;
  final double coverage;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'entries': entries.map((entry) => entry.toJson()).toList(),
    'coverage': coverage,
    'timestamp': timestamp.toIso8601String(),
  };
}

class LocalizedAssetBuilderService {
  static const _verifierPath = 'release/_reports/ru_verifier_summary.json';
  static const _bindingPath = 'release/_reports/ru_en_binding_summary.json';
  static const _tmPath = 'release/_reports/translation_memory_builder.json';
  static const _glossaryPath = 'release/_reports/base_glossary_expander.json';

  const LocalizedAssetBuilderService();

  Future<LocalizedAssetBundle> run() async {
    final verifierData = await _loadAsciiJson(_verifierPath);
    final bindingData = await _loadAsciiJson(_bindingPath);
    await _loadAsciiJson(_tmPath);
    await _loadAsciiJson(_glossaryPath);

    final verified = verifierData['verified'];
    if (verified != true) {
      throw LocalizedAssetBuilderException('Verifier reported failure');
    }

    final bindingEntries = _extractBindingEntries(bindingData['entries']);
    final entries = <LocalizedAssetEntry>[];
    var filled = 0;

    for (final entry in bindingEntries) {
      final key = entry['key'] as String? ?? '';
      final source = entry['source_en'] as String? ?? '';
      final target = entry['target_ru'] as String? ?? '';
      final missing = entry['missing'] == true;
      final highRisk = entry['high_risk'] == true;
      if (target.isNotEmpty) {
        filled += 1;
      }
      entries.add(
        LocalizedAssetEntry(
          key: key,
          sourceEn: source,
          targetRu: target,
          missing: missing,
          highRisk: highRisk,
        ),
      );
    }

    final coverage = entries.isEmpty ? 1.0 : filled / entries.length;

    return LocalizedAssetBundle(
      entries: entries,
      coverage: coverage,
      timestamp: DateTime.now().toUtc(),
    );
  }

  List<Map<String, Object?>> _extractBindingEntries(Object? raw) {
    if (raw is! List<Object?>) {
      return const [];
    }
    return raw
        .whereType<Map<String, Object?>>()
        .map(Map<String, Object?>.from)
        .toList();
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw LocalizedAssetBuilderException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw LocalizedAssetBuilderException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw LocalizedAssetBuilderException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw LocalizedAssetBuilderException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  bool _isAsciiOnly(Iterable<int> bytes) =>
      bytes.every((value) => value >= 0x00 && value <= _asciiLimit);
}

class LocalizedAssetBuilderException implements Exception {
  final String message;

  LocalizedAssetBuilderException(this.message);

  @override
  String toString() => 'LocalizedAssetBuilderException: $message';
}
