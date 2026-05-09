import 'dart:convert';
import 'dart:io';

const _asciiLimit = 0x7F;

class ApiSchemaLintService {
  static const _bundleSchemas = {
    'release/_reports/stability_snapshot_v2.json': {
      'summary': Map,
      'content_metrics': Map,
      'planner_metrics': Map,
    },
    'release/_reports/content_consistency_result.json': {
      'inconsistencies': List,
      'summary': Map,
    },
    'release/_reports/telemetry_integrity_result.json': {
      'issues': List,
      'summary': Map,
    },
    'release/_reports/cache_reliability_result.json': {
      'corrupted': List,
      'summary': Map,
    },
    'release/_reports/file_structure_integrity_result.json': {
      'missing_paths': List,
      'invalid_files': List,
      'summary': Map,
    },
    'release/_reports/content_replayability_result.json': {
      'broken_modules': List,
      'summary': Map,
    },
    'release/_reports/ux_stability_result.json': {
      'issues': List,
      'summary': Map,
    },
  };

  const ApiSchemaLintService();

  Future<ApiSchemaLintResult> run() async {
    final issues = <String>[];

    for (final entry in _bundleSchemas.entries) {
      final path = entry.key;
      final schema = entry.value;
      final map = await _loadAsciiJson(path, issues);
      if (map == null) {
        continue;
      }
      _validateSchema(path, schema, map, issues);
      _validateSummary(path, map['summary'], issues);
    }

    final result = _buildResult(issues);
    if (!result.summary.schemaValid) {
      throw ApiSchemaLintException(
        result,
        'Schema lint failed: ${issues.join(' | ')}',
      );
    }
    return result;
  }

  Future<Map<String, dynamic>?> _loadAsciiJson(
    String path,
    List<String> issues,
  ) async {
    final file = File(path);
    if (!await file.exists()) {
      issues.add('$path: missing');
      return null;
    }
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        issues.add('$path: empty file');
        return null;
      }
      if (!_isAsciiOnly(bytes)) {
        issues.add('$path: contains non-ASCII bytes');
        return null;
      }
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map) {
        issues.add('$path: top-level JSON must be an object');
        return null;
      }
      return Map<String, dynamic>.from(decoded);
    } on FormatException catch (error) {
      issues.add('$path: JSON parse error (${error.message})');
    } on FileSystemException catch (error) {
      issues.add('$path: unable to read file ($error)');
    }
    return null;
  }

  void _validateSchema(
    String path,
    Map<String, Type> schema,
    Map<String, dynamic> map,
    List<String> issues,
  ) {
    final actualKeys = map.keys.toSet();
    final expectedKeys = schema.keys.toSet();
    for (final key in expectedKeys.difference(actualKeys)) {
      issues.add('$path: missing key $key');
    }
    for (final key in actualKeys.difference(expectedKeys)) {
      issues.add('$path: unexpected key $key');
    }
    for (final entry in schema.entries) {
      final value = map[entry.key];
      if (value == null) {
        continue;
      }
      final expectedType = entry.value;
      if (expectedType == List && value is! List) {
        issues.add('$path: $entry.key must be a list');
        continue;
      }
      if (expectedType == Map && value is! Map) {
        issues.add('$path: $entry.key must be an object');
      }
    }
  }

  void _validateSummary(String path, Object? summary, List<String> issues) {
    if (summary is! Map) {
      issues.add('$path: summary must be an object');
      return;
    }
    final timestamp = summary['timestamp'];
    if (timestamp is! String || timestamp.trim().isEmpty) {
      issues.add('$path: summary.timestamp missing or empty');
    } else if (DateTime.tryParse(timestamp) == null) {
      issues.add('$path: summary.timestamp is not ISO 8601');
    }
    for (final entry in summary.entries) {
      final value = entry.value;
      if (value is num && value < 0) {
        issues.add('$path: summary.${entry.key} has negative value');
      }
    }
  }

  ApiSchemaLintResult _buildResult(List<String> issues) {
    final snapshot = List<String>.from(issues);
    final summary = ApiSchemaLintSummary(
      schemaValid: snapshot.isEmpty,
      timestamp: DateTime.now().toUtc(),
    );
    return ApiSchemaLintResult(schemaIssues: snapshot, summary: summary);
  }

  bool _isAsciiOnly(List<int> bytes) =>
      bytes.every((entry) => entry >= 0x00 && entry <= _asciiLimit);
}

class ApiSchemaLintResult {
  final List<String> schemaIssues;
  final ApiSchemaLintSummary summary;

  ApiSchemaLintResult({required this.schemaIssues, required this.summary});

  Map<String, Object?> toJson() => <String, Object?>{
    'schema_issues': schemaIssues,
    'summary': summary.toJson(),
  };
}

class ApiSchemaLintSummary {
  final bool schemaValid;
  final DateTime timestamp;

  ApiSchemaLintSummary({required this.schemaValid, required this.timestamp});

  Map<String, Object?> toJson() => <String, Object?>{
    'schema_valid': schemaValid,
    'timestamp': timestamp.toIso8601String(),
  };
}

class ApiSchemaLintException implements Exception {
  final ApiSchemaLintResult result;
  final String message;

  ApiSchemaLintException(this.result, this.message);

  @override
  String toString() => 'ApiSchemaLintException: $message';
}
