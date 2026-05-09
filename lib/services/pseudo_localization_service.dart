import 'dart:convert';
import 'dart:io';
import 'dart:math';

const _asciiLimit = 0x7F;
const _reportsDir = 'release/_reports';

/// Maps ASCII characters to accented variants using Unicode escapes so that the
/// source file remains ASCII-only.
const _accentMap = <String, String>{
  'a': '\u0101',
  'A': '\u0100',
  'e': '\u0113',
  'E': '\u0112',
  'i': '\u012B',
  'I': '\u012A',
  'o': '\u014D',
  'O': '\u014C',
  'u': '\u016B',
  'U': '\u016A',
  'c': '\u0107',
  'C': '\u0106',
  's': '\u0161',
  'S': '\u0160',
  'n': '\u0146',
  'N': '\u0145',
  't': '\u0163',
  'T': '\u0162',
  'r': '\u0155',
  'R': '\u0154',
  'l': '\u013C',
  'L': '\u013B',
};

/// Symbols used to pad pseudo content so we can control the length ratio.
const _padSequence = '~';

class PseudoLocalizedEntry {
  PseudoLocalizedEntry({
    required this.key,
    required this.sourceEn,
    required this.pseudoRu,
    required this.lengthRatio,
  });

  final String key;
  final String sourceEn;
  final String pseudoRu;
  final double lengthRatio;

  Map<String, Object?> toJson() => <String, Object?>{
    'key': key,
    'source_en': sourceEn,
    'pseudo_ru': pseudoRu,
    'length_ratio': lengthRatio,
  };
}

class PseudoLocalizationBundle {
  PseudoLocalizationBundle({
    required this.pseudoEntries,
    required this.timestamp,
  });

  final List<PseudoLocalizedEntry> pseudoEntries;
  final DateTime timestamp;

  int get entryCount => pseudoEntries.length;

  Map<String, Object?> toJson() => <String, Object?>{
    'pseudo_entries': pseudoEntries.map((entry) => entry.toJson()).toList(),
    'entry_count': entryCount,
    'timestamp': timestamp.toIso8601String(),
  };
}

class PseudoLocalizationService {
  static const _inputPath = '$_reportsDir/translation_memory_builder.json';

  const PseudoLocalizationService();

  Future<PseudoLocalizationBundle> run() async {
    final raw = await _loadAsciiJson(_inputPath);
    final entries = _extractEntries(raw);
    final pseudoEntries = <PseudoLocalizedEntry>[];
    for (final entry in entries) {
      final key = entry['key'];
      final source = entry['source_en'];
      if (key is String && source is String) {
        final pseudoValue = _pseudoLocalize(source);
        final ratio = source.isEmpty ? 0.0 : pseudoValue.length / source.length;
        pseudoEntries.add(
          PseudoLocalizedEntry(
            key: key,
            sourceEn: source,
            pseudoRu: pseudoValue,
            lengthRatio: ratio,
          ),
        );
      }
    }

    return PseudoLocalizationBundle(
      pseudoEntries: pseudoEntries,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw PseudoLocalizationException('Missing $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw PseudoLocalizationException('Empty $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw PseudoLocalizationException('$path contains non-ASCII bytes');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw PseudoLocalizationException(
        'Invalid JSON in $path: ${error.message}',
      );
    }
  }

  List<Map<String, Object?>> _extractEntries(Map<String, Object?> raw) {
    final rawEntries = raw['entries'];
    if (rawEntries is! List<Object?>) {
      return const [];
    }
    final entries = <Map<String, Object?>>[];
    for (final candidate in rawEntries) {
      if (candidate is Map<String, Object?>) {
        entries.add(Map<String, Object?>.from(candidate));
      }
    }
    return entries;
  }

  String _pseudoLocalize(String value) {
    final converted = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      converted.write(_accentMap[char] ?? char);
    }
    final finalBase = _normalizeLength(converted.toString(), value.length);
    return '[ $finalBase ]';
  }

  String _normalizeLength(String base, int sourceLength) {
    if (sourceLength <= 0) {
      return base;
    }
    final minLen = max(0, (1.2 * sourceLength).ceil());
    var maxLen = (1.4 * sourceLength).floor();
    if (maxLen < minLen) {
      maxLen = minLen;
    }
    final targetLen = ((1.3 * sourceLength).round()).clamp(minLen, maxLen);
    final targetBaseLen = max(0, targetLen - 4);
    return _padOrTrim(base, targetBaseLen);
  }

  String _padOrTrim(String value, int targetLength) {
    if (targetLength <= 0) {
      return '';
    }
    if (value.length == targetLength) {
      return value;
    }
    if (value.length > targetLength) {
      return value.substring(0, targetLength);
    }
    final buffer = StringBuffer(value);
    while (buffer.length < targetLength) {
      buffer.write(_padSequence);
    }
    final result = buffer.toString();
    if (result.length > targetLength) {
      return result.substring(0, targetLength);
    }
    return result;
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class PseudoLocalizationException implements Exception {
  final String message;

  PseudoLocalizationException(this.message);

  @override
  String toString() => 'PseudoLocalizationException: $message';
}
