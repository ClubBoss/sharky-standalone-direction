import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class CacheReliabilityPassService {
  static const _cacheFiles = <String>[
    'release/_cache/xp_cache.json',
    'release/_cache/progression_cache.json',
    'release/_cache/planner_cache.json',
    'release/_cache/persona_cache.json',
    'release/_cache/hint_cache.json',
  ];

  const CacheReliabilityPassService();

  Future<CacheReliabilityResult> run() async {
    final corrupted = <String>[];
    final reasons = <String>[];
    for (final path in _cacheFiles) {
      final file = File(path);
      if (!await file.exists()) {
        continue;
      }

      final outcome = await _validateFile(file);
      if (outcome.isValid) {
        continue;
      }

      corrupted.add(path);
      reasons.add('$path: ${outcome.reason}');
    }

    final summary = CacheReliabilitySummary(
      reliable: corrupted.isEmpty,
      timestamp: DateTime.now().toUtc(),
    );
    final result = CacheReliabilityResult(
      corrupted: corrupted,
      summary: summary,
    );

    if (!summary.reliable) {
      final message = reasons.isEmpty
          ? 'Corrupted cache files detected.'
          : reasons.join(' | ');
      throw CacheReliabilityException(result, message);
    }

    return result;
  }

  Future<_ValidationOutcome> _validateFile(File file) async {
    final bytes = await _readBytes(file);
    if (bytes == null) {
      return const _ValidationOutcome.invalid('Unable to read file.');
    }

    if (!_isAsciiOnly(bytes)) {
      return const _ValidationOutcome.invalid('Non-ASCII bytes detected.');
    }

    final content = utf8.decode(bytes);
    Object? decoded;

    try {
      decoded = jsonDecode(content);
    } on FormatException catch (error) {
      return _ValidationOutcome.invalid('JSON parse failure: ${error.message}');
    }

    if (decoded is! Map) {
      return const _ValidationOutcome.invalid(
        'Top-level JSON must be an object.',
      );
    }

    if (decoded.keys.any((key) => key is! String)) {
      return const _ValidationOutcome.invalid(
        'Cache map contains non-string keys.',
      );
    }

    final cacheMap = (decoded).cast<String, dynamic>();

    if (!_containsTimestamp(cacheMap)) {
      return const _ValidationOutcome.invalid('Missing timestamp entry.');
    }

    if (_hasInvalidValues(cacheMap)) {
      return const _ValidationOutcome.invalid(
        'Invalid or negative values discovered.',
      );
    }

    return const _ValidationOutcome.valid();
  }

  Future<List<int>?> _readBytes(File file) async {
    try {
      return await file.readAsBytes();
    } on FileSystemException {
      return null;
    }
  }

  bool _isAsciiOnly(List<int> data) =>
      data.every((entry) => entry >= 0x00 && entry <= _asciiLimit);

  bool _containsTimestamp(Map<String, dynamic> map) {
    if (!map.containsKey('timestamp')) {
      return false;
    }
    final timestamp = map['timestamp'];
    if (timestamp is! String) {
      return false;
    }
    return DateTime.tryParse(timestamp) != null;
  }

  bool _hasInvalidValues(Object? value) {
    if (value is Map) {
      for (final entry in value.entries) {
        if (entry.key is! String) {
          return true;
        }
        if (_hasInvalidValues(entry.value)) {
          return true;
        }
      }
      return false;
    }

    if (value is List) {
      for (final element in value) {
        if (_hasInvalidValues(element)) {
          return true;
        }
      }
      return false;
    }

    if (value is int) {
      return value < 0;
    }

    if (value is double) {
      if (value.isNaN || value.isInfinite) {
        return true;
      }
      return value < 0;
    }

    return false;
  }
}

class CacheReliabilityResult {
  final List<String> corrupted;
  final CacheReliabilitySummary summary;

  CacheReliabilityResult({required this.corrupted, required this.summary});

  Map<String, Object?> toJson() => <String, Object?>{
    'corrupted': corrupted,
    'summary': summary.toJson(),
  };
}

class CacheReliabilitySummary {
  final bool reliable;
  final DateTime timestamp;

  CacheReliabilitySummary({required this.reliable, required this.timestamp});

  Map<String, Object?> toJson() => <String, Object?>{
    'reliable': reliable,
    'timestamp': timestamp.toIso8601String(),
  };
}

class CacheReliabilityException implements Exception {
  final CacheReliabilityResult result;
  final String message;

  CacheReliabilityException(this.result, this.message);

  @override
  String toString() => 'CacheReliabilityException: $message';
}

class _ValidationOutcome {
  final bool isValid;
  final String reason;

  const _ValidationOutcome._(this.isValid, this.reason);

  const _ValidationOutcome.valid() : this._(true, '');
  const _ValidationOutcome.invalid(String reason) : this._(false, reason);
}
