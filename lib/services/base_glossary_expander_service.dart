import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class GlossaryEntry {
  GlossaryEntry({
    required this.glossaryKey,
    required this.glossaryDefEn,
    required this.glossaryDefRu,
  });

  final String glossaryKey;
  final String glossaryDefEn;
  final String glossaryDefRu;

  Map<String, Object?> toJson() => <String, Object?>{
    'glossary_key': glossaryKey,
    'glossary_def_en': glossaryDefEn,
    'glossary_def_ru': glossaryDefRu,
  };
}

class BaseGlossaryExpanderBundle {
  BaseGlossaryExpanderBundle({
    required this.glossaryEntries,
    required this.domainList,
    required this.entryCount,
    required this.timestamp,
  });

  final List<GlossaryEntry> glossaryEntries;
  final List<String> domainList;
  final int entryCount;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
    'glossary_entries': glossaryEntries.map((entry) => entry.toJson()).toList(),
    'domain_list': domainList,
    'entry_count': entryCount,
    'timestamp': timestamp.toIso8601String(),
  };
}

class BaseGlossaryExpanderService {
  static const _inputPath = 'release/_reports/translation_memory_builder.json';

  const BaseGlossaryExpanderService();

  Future<BaseGlossaryExpanderBundle> run() async {
    final data = await _loadAsciiJson(_inputPath);
    final entries = <GlossaryEntry>[];
    final domains = <String>{};
    final rawEntries = data['entries'];
    if (rawEntries is! List) {
      throw BaseGlossaryExpanderException('TM entries missing');
    }
    for (final entry in rawEntries) {
      if (entry is! Map) continue;
      final key = entry['key'];
      final source = entry['source_en'];
      final metadata = entry['metadata'];
      if (key is! String || source is! String) {
        continue;
      }
      if (metadata is Map) {
        final domain = metadata['domain'];
        if (domain is String) {
          domains.add(domain);
        }
      }
      entries.add(
        GlossaryEntry(
          glossaryKey: key,
          glossaryDefEn: source,
          glossaryDefRu: '',
        ),
      );
    }
    final bundle = BaseGlossaryExpanderBundle(
      glossaryEntries: entries,
      domainList: domains.toList()..sort(),
      entryCount: entries.length,
      timestamp: DateTime.now().toUtc(),
    );
    return bundle;
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw BaseGlossaryExpanderException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw BaseGlossaryExpanderException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw BaseGlossaryExpanderException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw BaseGlossaryExpanderException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class BaseGlossaryExpanderException implements Exception {
  final String message;

  BaseGlossaryExpanderException(this.message);

  @override
  String toString() => 'BaseGlossaryExpanderException: $message';
}
