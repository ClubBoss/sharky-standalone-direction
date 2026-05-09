import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class LocalizedPreviewItem {
  LocalizedPreviewItem({
    required this.key,
    required this.sourceEn,
    required this.pseudo,
    required this.missing,
    required this.highRisk,
  });

  final String key;
  final String sourceEn;
  final String pseudo;
  final bool missing;
  final bool highRisk;

  Map<String, Object?> toJson() => <String, Object?>{
    'key': key,
    'source_en': sourceEn,
    'pseudo': pseudo,
    'missing': missing,
    'high_risk': highRisk,
  };
}

class LocalizedPreviewBundle {
  LocalizedPreviewBundle({required this.items, required this.timestamp});

  final List<LocalizedPreviewItem> items;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'items': items.map((item) => item.toJson()).toList(),
    'timestamp': timestamp.toIso8601String(),
  };
}

class LocalizedPreviewService {
  static const _tmPath = 'release/_reports/translation_memory_builder.json';
  static const _pseudoPath = 'release/_reports/pseudo_localization.json';
  static const _coveragePath = 'release/_reports/i18n_asset_coverage.json';
  static const _autofixPath =
      'release/_reports/localization_autofix_summary.json';

  const LocalizedPreviewService();

  Future<LocalizedPreviewBundle> run() async {
    final tmData = await _loadAsciiJson(_tmPath);
    final pseudoData = await _loadAsciiJson(_pseudoPath);
    await _loadAsciiJson(_coveragePath);
    final autofixData = await _loadAsciiJson(_autofixPath);

    final tmMap = _mapEntries(tmData['entries']);
    final pseudoMap = _mapPseudoEntries(pseudoData['pseudo_entries']);
    final missingKeys = _collectMissingKeys(autofixData['missing_keys']);
    final highRiskSet = _collectMissingKeys(autofixData['high_risk_strings']);

    final items = <LocalizedPreviewItem>[];
    for (final key in tmMap.keys) {
      final source = tmMap[key] ?? '';
      final pseudo = pseudoMap[key] ?? '';
      final missing = missingKeys.contains(key);
      final highRisk = highRiskSet.contains(key);
      items.add(
        LocalizedPreviewItem(
          key: key,
          sourceEn: source,
          pseudo: pseudo,
          missing: missing,
          highRisk: highRisk,
        ),
      );
    }

    items.sort((a, b) => a.key.compareTo(b.key));

    return LocalizedPreviewBundle(
      items: items,
      timestamp: DateTime.now().toUtc(),
    );
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

  Map<String, String> _mapPseudoEntries(Object? raw) {
    if (raw is! List<Object?>) {
      return const {};
    }
    final map = <String, String>{};
    for (final entry in raw) {
      if (entry is Map<String, Object?>) {
        final key = entry['key'];
        final pseudo = entry['pseudo_ru'];
        if (key is String && pseudo is String) {
          map[key] = pseudo;
        }
      }
    }
    return map;
  }

  Set<String> _collectMissingKeys(Object? raw) {
    if (raw is! List<Object?>) {
      return const {};
    }
    final keys = <String>{};
    for (final entry in raw) {
      if (entry is String) {
        keys.add(entry);
      }
    }
    return keys;
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw LocalizedPreviewException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw LocalizedPreviewException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw LocalizedPreviewException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw LocalizedPreviewException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((value) => value >= 0x00 && value <= _asciiLimit);
}

class LocalizedPreviewException implements Exception {
  final String message;

  LocalizedPreviewException(this.message);

  @override
  String toString() => 'LocalizedPreviewException: $message';
}
