import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class TranslationMemoryEntry {
  TranslationMemoryEntry({
    required this.key,
    required this.sourceEn,
    required this.targetRu,
    required this.metadata,
  });

  final String key;
  final String sourceEn;
  final String targetRu;
  final Map<String, Object?> metadata;

  Map<String, Object?> toJson() => <String, Object?>{
    'key': key,
    'source_en': sourceEn,
    'target_ru': targetRu,
    'metadata': metadata,
  };
}

class TranslationMemoryBundle {
  TranslationMemoryBundle({
    required this.entries,
    required this.domains,
    required this.timestamp,
  });

  final List<TranslationMemoryEntry> entries;
  final List<String> domains;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'entries': entries.map((entry) => entry.toJson()).toList(),
    'domains': domains,
    'timestamp': timestamp.toIso8601String(),
  };
}

class TranslationMemoryBuilderService {
  static const _inputPath = 'release/_reports/localization_core_bootstrap.json';

  const TranslationMemoryBuilderService();

  Future<TranslationMemoryBundle> run() async {
    final localization = await _loadAsciiJson(_inputPath);
    final seed = _extractMap(localization, 'translation_memory_seed');
    final entries = <TranslationMemoryEntry>[];
    final domainSet = <String>{};

    seed.forEach((key, value) {
      if (value is! String || value.trim().isEmpty) {
        return;
      }
      final domain = _domainForKey(key);
      domainSet.add(domain);
      entries.add(
        TranslationMemoryEntry(
          key: key,
          sourceEn: value,
          targetRu: '',
          metadata: {
            'domain': domain,
            'length': value.length,
            'hash': _asciiHash(value),
          },
        ),
      );
    });

    final bundle = TranslationMemoryBundle(
      entries: entries,
      domains: domainSet.toList()..sort(),
      timestamp: DateTime.now().toUtc(),
    );
    return bundle;
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw TranslationMemoryBuilderException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw TranslationMemoryBuilderException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw TranslationMemoryBuilderException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw TranslationMemoryBuilderException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  Map<String, Object?> _extractMap(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is Map<String, Object?>) {
      return Map<String, Object?>.from(value);
    }
    return const {};
  }

  String _domainForKey(String key) {
    final normalized = key.toLowerCase();
    if (normalized.contains('cta')) return 'cta';
    if (normalized.contains('persona')) return 'persona';
    if (normalized.contains('onboarding')) return 'onboarding';
    if (normalized.contains('retention')) return 'retention';
    return 'general';
  }

  String _asciiHash(String value) {
    var hash = 0x9e3779b1;
    for (final run in value.codeUnits) {
      hash = 0x1fffffff & (hash ^ run);
      hash = 0x1fffffff & ((hash << 5) - hash);
    }
    return (hash & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class TranslationMemoryBuilderException implements Exception {
  final String message;

  TranslationMemoryBuilderException(this.message);

  @override
  String toString() => 'TranslationMemoryBuilderException: $message';
}
