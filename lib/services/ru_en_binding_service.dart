import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class RuEnBindingEntry {
  RuEnBindingEntry({
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

class RuEnBindingBundle {
  RuEnBindingBundle({required this.entries, required this.timestamp});

  final List<RuEnBindingEntry> entries;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'entries': entries.map((entry) => entry.toJson()).toList(),
    'timestamp': timestamp.toIso8601String(),
  };
}

class RuEnBindingService {
  static const _previewPath = 'release/_reports/localized_preview_summary.json';
  static const _tmPath = 'release/_reports/translation_memory_builder.json';
  static const _glossaryPath = 'release/_reports/base_glossary_expander.json';

  const RuEnBindingService();

  Future<RuEnBindingBundle> run() async {
    final previewData = await _loadAsciiJson(_previewPath);
    final tmData = await _loadAsciiJson(_tmPath);
    final glossaryData = await _loadAsciiJson(_glossaryPath);

    final previewItems = _extractPreviewItems(previewData['items']);
    final tmMap = _mapEntries(tmData['entries']);
    final glossaryKeys = _collectGlossaryKeys(glossaryData['glossary_entries']);

    final bindingEntries = <RuEnBindingEntry>[];
    for (final item in previewItems) {
      final key = item['key'];
      final keyString = key is String ? key : '';
      final source = keyString.isNotEmpty ? tmMap[keyString] ?? '' : '';
      final missing =
          keyString.isEmpty ||
          item['missing'] == true ||
          !glossaryKeys.contains(keyString);
      final highRisk = item['high_risk'] == true;
      bindingEntries.add(
        RuEnBindingEntry(
          key: keyString,
          sourceEn: source,
          targetRu: '',
          missing: missing,
          highRisk: highRisk,
        ),
      );
    }

    bindingEntries.sort((a, b) => a.key.compareTo(b.key));

    return RuEnBindingBundle(
      entries: bindingEntries,
      timestamp: DateTime.now().toUtc(),
    );
  }

  List<Map<String, Object?>> _extractPreviewItems(Object? raw) {
    if (raw is! List<Object?>) {
      return const [];
    }
    final items = <Map<String, Object?>>[];
    for (final entry in raw) {
      if (entry is Map<String, Object?>) {
        items.add(Map<String, Object?>.from(entry));
      }
    }
    return items;
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
      throw RuEnBindingException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw RuEnBindingException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw RuEnBindingException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw RuEnBindingException('Invalid JSON in $path: ${error.message}');
    }
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((value) => value >= 0x00 && value <= _asciiLimit);
}

class RuEnBindingException implements Exception {
  final String message;

  RuEnBindingException(this.message);

  @override
  String toString() => 'RuEnBindingException: $message';
}
