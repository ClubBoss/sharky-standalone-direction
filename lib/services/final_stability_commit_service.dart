import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class FinalStabilityManifest {
  final bool safetyPass;
  final List<String> failDomains;
  final String stabilityLevel;
  final DateTime timestamp;

  FinalStabilityManifest({
    required this.safetyPass,
    required this.failDomains,
    required this.stabilityLevel,
    required this.timestamp,
  });

  Map<String, Object?> toJson() => <String, Object?>{
    'safety_pass': safetyPass,
    'fail_domains': failDomains,
    'stability_level': stabilityLevel,
    'timestamp': timestamp.toIso8601String(),
  };
}

class FinalStabilityCommitService {
  static const String _inputPath =
      'release/_reports/release_safety_result.json';

  const FinalStabilityCommitService();

  Future<FinalStabilityManifest> run() async {
    final map = await _loadJson();
    final safetyPass = _extractBool(map, 'summary', 'safety_pass');
    final failDomains = _extractList(
      map,
      'fail_domains',
    ).whereType<String>().toList(growable: false);
    final stabilityLevel = safetyPass ? 'green' : 'yellow';
    return FinalStabilityManifest(
      safetyPass: safetyPass,
      failDomains: failDomains,
      stabilityLevel: stabilityLevel,
      timestamp: DateTime.now().toUtc(),
    );
  }

  Future<Map<String, Object?>> _loadJson() async {
    final file = File(_inputPath);
    if (!await file.exists()) {
      throw FinalStabilityCommitException('Missing $_inputPath');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw FinalStabilityCommitException('Empty $_inputPath');
    }
    if (!_isAsciiOnly(bytes)) {
      throw FinalStabilityCommitException(
        '$_inputPath contains non-ASCII bytes',
      );
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('Top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw FinalStabilityCommitException('Invalid JSON: ${error.message}');
    }
  }

  bool _extractBool(Map<String, Object?> map, String parentKey, String key) {
    final parent = map[parentKey];
    if (parent is! Map<String, Object?>) {
      throw FinalStabilityCommitException('$parentKey must be an object');
    }
    final value = parent[key];
    if (value is bool) {
      return value;
    }
    throw FinalStabilityCommitException('$parentKey.$key must be a boolean');
  }

  List<Object?> _extractList(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is List) {
      return value;
    }
    throw FinalStabilityCommitException('$key must be a list');
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class FinalStabilityCommitException implements Exception {
  final String message;

  FinalStabilityCommitException(this.message);

  @override
  String toString() => 'FinalStabilityCommitException: $message';
}
