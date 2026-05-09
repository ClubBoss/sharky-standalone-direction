import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class IntegrationSnapshotService {
  static const _domainPaths = <String, String>{
    'stability': 'release/_reports/stability_snapshot_v2.json',
    'system_sanity': 'release/_reports/system_sanity_result.json',
    'consistency': 'release/_reports/content_consistency_result.json',
    'telemetry': 'release/_reports/telemetry_integrity_result.json',
    'cache': 'release/_reports/cache_reliability_result.json',
    'file_structure': 'release/_reports/file_structure_integrity_result.json',
    'replayability': 'release/_reports/content_replayability_result.json',
    'ux': 'release/_reports/ux_stability_result.json',
    'schema': 'release/_reports/api_schema_lint_result.json',
    'assets': 'release/_reports/asset_cohesion_result.json',
  };

  const IntegrationSnapshotService();

  Future<IntegrationSnapshotResult> run() async {
    final loaded = <String, Map<String, Object?>>{};
    for (final entry in _domainPaths.entries) {
      loaded[entry.key] = await _loadAsciiJson(entry.value);
    }

    final notes = <String>[];
    final statuses = <String, bool>{};
    final snapshot = <String, Object?>{};

    statuses['stability'] = _processStability(
      loaded['stability']!,
      snapshot,
      notes,
    );
    statuses['system_sanity'] = _processBoolDomain(
      domain: 'system_sanity',
      data: loaded['system_sanity']!,
      statusKey: 'sanity_pass',
      snapshot: snapshot,
      notes: notes,
    );
    statuses['consistency'] = _processBoolDomain(
      domain: 'consistency',
      data: loaded['consistency']!,
      statusKey: 'consistent',
      snapshot: snapshot,
      notes: notes,
    );
    statuses['telemetry'] = _processBoolDomain(
      domain: 'telemetry',
      data: loaded['telemetry']!,
      statusKey: 'integrity_pass',
      snapshot: snapshot,
      notes: notes,
    );
    statuses['cache'] = _processBoolDomain(
      domain: 'cache',
      data: loaded['cache']!,
      statusKey: 'reliable',
      snapshot: snapshot,
      notes: notes,
    );
    statuses['file_structure'] = _processBoolDomain(
      domain: 'file_structure',
      data: loaded['file_structure']!,
      statusKey: 'structure_pass',
      snapshot: snapshot,
      notes: notes,
    );
    statuses['replayability'] = _processBoolDomain(
      domain: 'replayability',
      data: loaded['replayability']!,
      statusKey: 'replayable',
      snapshot: snapshot,
      notes: notes,
    );
    statuses['ux'] = _processBoolDomain(
      domain: 'ux',
      data: loaded['ux']!,
      statusKey: 'ux_stable',
      snapshot: snapshot,
      notes: notes,
    );
    statuses['schema'] = _processBoolDomain(
      domain: 'schema',
      data: loaded['schema']!,
      statusKey: 'schema_valid',
      snapshot: snapshot,
      notes: notes,
    );
    statuses['assets'] = _processBoolDomain(
      domain: 'assets',
      data: loaded['assets']!,
      statusKey: 'cohesive',
      snapshot: snapshot,
      notes: notes,
    );

    final integrationPass = statuses.values.every((value) => value);
    final summary = IntegrationSnapshotSummary(
      integrationPass: integrationPass,
      timestamp: DateTime.now().toUtc(),
    );

    final payload = <String, Object?>{...snapshot, 'summary': summary.toJson()};

    return IntegrationSnapshotResult(
      snapshot: payload,
      summary: summary,
      notes: notes,
    );
  }

  Future<Map<String, Object?>> _loadAsciiJson(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw IntegrationSnapshotException('Missing file $path');
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw IntegrationSnapshotException('Empty file $path');
    }
    if (!_isAsciiOnly(bytes)) {
      throw IntegrationSnapshotException('Non-ASCII content in $path');
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, Object?>) {
        throw IntegrationSnapshotException('$path must contain a JSON object');
      }
      return Map<String, Object?>.from(decoded);
    } on FormatException catch (error) {
      throw IntegrationSnapshotException('$path JSON error: ${error.message}');
    }
  }

  bool _processStability(
    Map<String, Object?> data,
    Map<String, Object?> snapshot,
    List<String> notes,
  ) {
    final summary = _extractMap(data['summary']);
    final healthScore = _extractNumber(summary, 'health_score');
    if (healthScore == null) {
      notes.add('stability summary missing health_score');
    }
    final healthy = healthScore != null && healthScore >= 0;
    snapshot['stability'] = _domainSnapshot(data, 'health_score', healthScore);
    return healthy;
  }

  bool _processBoolDomain({
    required String domain,
    required Map<String, Object?> data,
    required String statusKey,
    required Map<String, Object?> snapshot,
    required List<String> notes,
  }) {
    final summary = _extractMap(data['summary']);
    final isHealthy = _extractBool(
      summary,
      statusKey,
      '$domain summary',
      notes,
    );
    snapshot[domain] = _domainSnapshot(data, statusKey, summary[statusKey]);
    return isHealthy;
  }

  Map<String, Object?> _extractMap(Object? value) =>
      value is Map<String, Object?> ? Map<String, Object?>.from(value) : {};

  double? _extractNumber(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  bool _extractBool(
    Map<String, Object?> map,
    String key,
    String label,
    List<String> notes,
  ) {
    final value = map[key];
    if (value is bool) {
      return value;
    }
    notes.add('$label.$key is not a boolean');
    return false;
  }

  Map<String, Object?> _domainSnapshot(
    Map<String, Object?> bundle,
    String statusKey,
    Object? statusValue,
  ) => {
    'bundle': bundle,
    'status': {'key': statusKey, 'value': statusValue},
  };

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class IntegrationSnapshotResult {
  final Map<String, Object?> snapshot;
  final IntegrationSnapshotSummary summary;
  final List<String> notes;

  IntegrationSnapshotResult({
    required this.snapshot,
    required this.summary,
    required this.notes,
  });

  Map<String, Object?> toJson() => snapshot;
}

class IntegrationSnapshotSummary {
  final bool integrationPass;
  final DateTime timestamp;

  IntegrationSnapshotSummary({
    required this.integrationPass,
    required this.timestamp,
  });

  Map<String, Object?> toJson() => <String, Object?>{
    'integration_pass': integrationPass,
    'timestamp': timestamp.toIso8601String(),
  };
}

class IntegrationSnapshotException implements Exception {
  final String message;

  IntegrationSnapshotException(this.message);

  @override
  String toString() => 'IntegrationSnapshotException: $message';
}
