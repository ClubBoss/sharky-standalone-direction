import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class ReleaseSafetyCheckService {
  static const _inputPath = 'release/_reports/integration_snapshot_v2.json';
  static const _boolDomains = {
    'system_sanity': 'sanity_pass',
    'consistency': 'consistent',
    'telemetry': 'integrity_pass',
    'cache': 'reliable',
    'file_structure': 'structure_pass',
    'replayability': 'replayable',
    'ux': 'ux_stable',
    'schema': 'schema_valid',
    'assets': 'cohesive',
  };

  const ReleaseSafetyCheckService();

  Future<ReleaseSafetyResult> run() async {
    final snapshot = await _loadAsciiJson(_inputPath);
    final failDomains = <String>[];

    final stabilityEntry = _extractDomain(snapshot, 'stability');
    final healthScore = _extractNumberFromStatus(
      stabilityEntry,
      'health_score',
    );
    if (healthScore == null) {
      failDomains.add('stability.health_score missing');
    } else if (healthScore < 0.8) {
      failDomains.add(
        'stability.health_score=${healthScore.toStringAsFixed(2)}',
      );
    }

    for (final entry in _boolDomains.entries) {
      final domainEntry = _extractDomain(snapshot, entry.key);
      final statusValue = _statusValue(domainEntry);
      if (statusValue is! bool) {
        failDomains.add('${entry.key}.${entry.value} invalid');
        continue;
      }
      if (!statusValue) {
        failDomains.add('${entry.key}.${entry.value}=false');
      }
    }

    final safetyPass =
        failDomains.isEmpty && healthScore != null && healthScore >= 0.8;
    final summary = ReleaseSafetySummary(
      safetyPass: safetyPass,
      timestamp: DateTime.now().toUtc(),
    );
    final result = ReleaseSafetyResult(
      failDomains: failDomains,
      summary: summary,
    );
    if (!safetyPass) {
      throw ReleaseSafetyException(result, 'Release safety check failed');
    }
    return result;
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw ReleaseSafetyException(
        ReleaseSafetyResult(
          failDomains: ['missing $path'],
          summary: ReleaseSafetySummary(
            safetyPass: false,
            timestamp: DateTime.now().toUtc(),
          ),
        ),
        'Missing integration snapshot',
      );
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw ReleaseSafetyException(
        ReleaseSafetyResult(
          failDomains: ['empty $path'],
          summary: ReleaseSafetySummary(
            safetyPass: false,
            timestamp: DateTime.now().toUtc(),
          ),
        ),
        'Empty integration snapshot',
      );
    }
    if (!_isAsciiOnly(bytes)) {
      throw ReleaseSafetyException(
        ReleaseSafetyResult(
          failDomains: ['non-ASCII $path'],
          summary: ReleaseSafetySummary(
            safetyPass: false,
            timestamp: DateTime.now().toUtc(),
          ),
        ),
        'Integration snapshot contains non-ASCII content',
      );
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('top-level JSON must be an object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw ReleaseSafetyException(
        ReleaseSafetyResult(
          failDomains: ['invalid JSON: ${error.message}'],
          summary: ReleaseSafetySummary(
            safetyPass: false,
            timestamp: DateTime.now().toUtc(),
          ),
        ),
        'Integration snapshot JSON error',
      );
    }
  }

  Map<String, Object?> _extractDomain(
    Map<String, Object?> snapshot,
    String domain,
  ) {
    final entry = snapshot[domain];
    if (entry is! Map<String, Object?>) {
      throw ReleaseSafetyException(
        ReleaseSafetyResult(
          failDomains: ['missing domain $domain'],
          summary: ReleaseSafetySummary(
            safetyPass: false,
            timestamp: DateTime.now().toUtc(),
          ),
        ),
        'Integration snapshot missing $domain',
      );
    }
    return entry;
  }

  Object? _statusValue(Map<String, Object?> domainEntry) =>
      (domainEntry['status'] as Map?)?['value'];

  double? _extractNumberFromStatus(
    Map<String, Object?> domainEntry,
    String key,
  ) {
    final status = _statusValue(domainEntry);
    if (status is num) {
      return status.toDouble();
    }
    final bundle = domainEntry['bundle'];
    if (bundle is Map<String, Object?>) {
      final summary = bundle['summary'];
      if (summary is Map<String, Object?>) {
        final value = summary[key];
        if (value is num) {
          return value.toDouble();
        }
      }
    }
    return null;
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class ReleaseSafetyResult {
  final List<String> failDomains;
  final ReleaseSafetySummary summary;

  ReleaseSafetyResult({required this.failDomains, required this.summary});

  Map<String, Object?> toJson() => <String, Object?>{
    'fail_domains': failDomains,
    'summary': summary.toJson(),
  };
}

class ReleaseSafetySummary {
  final bool safetyPass;
  final DateTime timestamp;

  ReleaseSafetySummary({required this.safetyPass, required this.timestamp});

  Map<String, Object?> toJson() => <String, Object?>{
    'safety_pass': safetyPass,
    'timestamp': timestamp.toIso8601String(),
  };
}

class ReleaseSafetyException implements Exception {
  final ReleaseSafetyResult result;
  final String message;

  ReleaseSafetyException(this.result, this.message);

  @override
  String toString() => 'ReleaseSafetyException: $message';
}
