import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final options = _Options.parse(args);
  final aggregator = _FeedbackAggregator();

  try {
    final summary = await aggregator.generate(
      includeSummaryPrint: options.summary,
      syncFirestore: options.syncFirestore,
    );

    final outputPath = 'tools/_reports/public_beta_feedback_summary.json';
    await _writeSummaryFile(outputPath, summary);

    if (options.summary) {
      _printAsciiSummary(summary);
    }

    // Emit machine-friendly JSON on the last line for callers (dashboard/tests).
    final aggregates =
        (summary['aggregates'] as Map<String, Object?>?) ?? const {};
    stdout.writeln(
      jsonEncode({
        'pass': true,
        'records_analyzed':
            (aggregates['records_analyzed'] as num?)?.toInt() ?? 0,
        'path': outputPath,
        'sync': summary['sync'],
      }),
    );
  } catch (e, st) {
    stderr.writeln('[PublicBetaFeedback] Failed: $e');
    stderr.writeln(st);
    stdout.writeln(jsonEncode({'pass': false, 'error': e.toString()}));
    exitCode = 1;
  }
}

class _Options {
  _Options({required this.summary, required this.syncFirestore});

  final bool summary;
  final bool syncFirestore;

  static _Options parse(List<String> args) {
    var summary = false;
    var sync = false;

    for (final arg in args) {
      switch (arg) {
        case '--summary':
          summary = true;
          break;
        case '--sync-firestore':
          sync = true;
          break;
        case '--help':
        case '-h':
          _printUsage();
          exit(0);
        default:
          stderr.writeln('Unknown option: $arg');
          _printUsage();
          exit(64);
      }
    }

    // Default to summary mode when no explicit switch provided.
    if (!summary && !sync) {
      summary = true;
    }

    return _Options(summary: summary, syncFirestore: sync);
  }
}

void _printUsage() {
  stdout.writeln(
    'Usage: dart run tools/public_beta_feedback.dart [--summary] [--sync-firestore]',
  );
}

Future<void> _writeSummaryFile(
  String path,
  Map<String, Object?> summary,
) async {
  final file = File(path);
  file.parent.createSync(recursive: true);
  final encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString('${encoder.convert(summary)}\n');
  stdout.writeln('[PublicBetaFeedback] Wrote summary to $path');
}

void _printAsciiSummary(Map<String, Object?> summary) {
  stdout.writeln('Public Beta Feedback Summary');
  stdout.writeln('────────────────────────────');
  final aggregates = summary['aggregates'] as Map<String, Object?>? ?? const {};
  stdout.writeln(
    'Events: ${(summary['total_events'] as num?)?.toInt() ?? 0} | Users: ${(summary['unique_users'] as num?)?.toInt() ?? 0}',
  );
  stdout.writeln(
    'Avg UX latency: ${_formatNumber(aggregates['avg_ux_latency_ms'])} ms | '
    'Avg Simulation latency: ${_formatNumber(aggregates['avg_sim_latency_ms'])} ms',
  );
  stdout.writeln(
    'Avg Retention Score: ${_formatNumber(aggregates['avg_retention_score_percent'])} %',
  );

  final issues = aggregates['top_issues'] as List<dynamic>? ?? const [];
  if (issues.isEmpty) {
    stdout.writeln('Top Issues: none reported');
  } else {
    stdout.writeln('Top Issues:');
    for (var i = 0; i < issues.length; i++) {
      final issue = issues[i];
      if (issue is Map) {
        final label = issue['label'] ?? 'unknown';
        final count = issue['count'] ?? 0;
        stdout.writeln('  ${i + 1}. $label ($count)');
      } else {
        stdout.writeln('  ${i + 1}. $issue');
      }
    }
  }
  stdout.writeln('');
}

String _formatNumber(Object? value) {
  if (value is num) {
    return value.toStringAsFixed(2);
  }
  return '0.00';
}

class _FeedbackAggregator {
  static const List<String> _eventWhitelist = <String>[
    'ai_retention_score',
    'ux_loop_latency_ms',
    'simulation_ux_latency_ms',
  ];

  Future<Map<String, Object?>> generate({
    required bool includeSummaryPrint,
    required bool syncFirestore,
  }) async {
    final events = await _loadEvents();
    final builder = _AggregateBuilder();
    for (final event in events) {
      if (!_eventWhitelist.contains(event.name)) {
        continue;
      }
      builder.consume(event);
    }

    final aggregates = builder.build();
    final syncResult = await _syncIfRequested(
      syncFirestore: syncFirestore,
      summary: aggregates,
    );

    return <String, Object?>{
      'generated_at': DateTime.now().toUtc().toIso8601String(),
      'total_events': builder.totalEvents,
      'unique_users': builder.uniqueUsers,
      'aggregates': aggregates,
      'records': builder.records,
      'sync': syncResult,
    };
  }

  Future<List<_TelemetryRecord>> _loadEvents() async {
    final reportsDir = Directory('tools/_reports');
    if (!reportsDir.existsSync()) {
      stdout.writeln('[PublicBetaFeedback] No reports directory found.');
      return const <_TelemetryRecord>[];
    }

    final records = <_TelemetryRecord>[];
    await for (final entity in reportsDir.list(recursive: false)) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.isNotEmpty
          ? entity.uri.pathSegments.last
          : entity.path;
      if (!name.endsWith('.jsonl')) continue;
      if (!name.contains('firebase') && !name.contains('telemetry')) continue;

      final lines = await entity.readAsLines();
      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          final decoded = jsonDecode(line);
          if (decoded is Map<String, dynamic>) {
            final record = _TelemetryRecord.fromJson(decoded);
            if (record != null) {
              records.add(record);
            }
          }
        } catch (_) {
          stderr.writeln(
            '[PublicBetaFeedback] Skipped malformed telemetry line: $line',
          );
        }
      }
    }
    return records;
  }

  Future<Map<String, Object?>> _syncIfRequested({
    required bool syncFirestore,
    required Map<String, Object?> summary,
  }) async {
    if (!syncFirestore) {
      return {'requested': false, 'status': 'skipped'};
    }

    // Offline-safe stub: attempt to detect firebase CLI availability.
    try {
      final result = await Process.run('which', ['firebase'], runInShell: true);
      final hasCli =
          result.exitCode == 0 && (result.stdout as String).trim().isNotEmpty;
      if (!hasCli) {
        stdout.writeln(
          '[PublicBetaFeedback] firebase CLI not found, skipping Firestore sync.',
        );
        return {'requested': true, 'status': 'skipped_offline'};
      }
    } catch (_) {
      stdout.writeln(
        '[PublicBetaFeedback] Unable to check firebase CLI, skipping sync.',
      );
      return {'requested': true, 'status': 'skipped_offline'};
    }

    // In offline mode we do not perform network operations. Report stub success.
    stdout.writeln(
      '[PublicBetaFeedback] Firestore sync requested but disabled in offline mode.',
    );
    return {'requested': true, 'status': 'skipped_offline'};
  }
}

class _AggregateBuilder {
  final Map<String, _UserSessionAggregate> _sessions = {};
  final Map<String, int> _issueCounts = {};
  int totalEvents = 0;

  void consume(_TelemetryRecord record) {
    totalEvents++;
    final key = '${record.userHash}|${record.sessionType}';
    final session = _sessions.putIfAbsent(
      key,
      () => _UserSessionAggregate(
        userHash: record.userHash,
        sessionType: record.sessionType,
      ),
    );
    session.apply(record);

    final issueKey = record.issueLabel;
    if (issueKey != null && issueKey.isNotEmpty) {
      _issueCounts[issueKey] = (_issueCounts[issueKey] ?? 0) + 1;
    }
  }

  Map<String, Object?> build() {
    final sessionList = _sessions.values.toList()
      ..sort((a, b) => a.userHash.compareTo(b.userHash));

    var totalUxLatency = 0.0;
    var uxCount = 0;
    var totalSimLatency = 0.0;
    var simCount = 0;
    var totalRetention = 0.0;
    var retentionCount = 0;

    final records = <Map<String, Object?>>[];
    for (final session in sessionList) {
      totalUxLatency += session.uxLatencyTotal;
      uxCount += session.uxLatencyCount;
      totalSimLatency += session.simLatencyTotal;
      simCount += session.simLatencyCount;
      totalRetention += session.retentionTotal;
      retentionCount += session.retentionCount;

      records.add(session.toJson());
    }

    final topIssues = _issueCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return <String, Object?>{
      'records_analyzed': sessionList.length,
      'avg_ux_latency_ms': uxCount == 0 ? 0.0 : totalUxLatency / uxCount,
      'avg_sim_latency_ms': simCount == 0 ? 0.0 : totalSimLatency / (simCount),
      'avg_retention_score_percent': retentionCount == 0
          ? 0.0
          : totalRetention / retentionCount,
      'top_issues': topIssues
          .take(5)
          .map((entry) {
            return {'label': entry.key, 'count': entry.value};
          })
          .toList(growable: false),
    };
  }

  int get uniqueUsers {
    final users = <String>{};
    for (final aggregate in _sessions.values) {
      users.add(aggregate.userHash);
    }
    return users.length;
  }

  List<Map<String, Object?>> get records {
    return _sessions.values
        .map((aggregate) => aggregate.toJson())
        .toList(growable: false)
      ..sort((a, b) {
        final left = '${a['user']}|${a['session_type']}';
        final right = '${b['user']}|${b['session_type']}';
        return left.compareTo(right);
      });
  }
}

class _UserSessionAggregate {
  _UserSessionAggregate({required this.userHash, required this.sessionType});

  final String userHash;
  final String sessionType;

  double uxLatencyTotal = 0.0;
  int uxLatencyCount = 0;
  double simLatencyTotal = 0.0;
  int simLatencyCount = 0;
  double retentionTotal = 0.0;
  int retentionCount = 0;

  final Map<String, double> _metrics = {};

  void apply(_TelemetryRecord record) {
    switch (record.name) {
      case 'ux_loop_latency_ms':
        final value = record.params['value_ms'];
        if (value is num) {
          uxLatencyTotal += value.toDouble();
          uxLatencyCount += 1;
        }
        break;
      case 'simulation_ux_latency_ms':
        final value = record.params['latency_ms'];
        if (value is num) {
          simLatencyTotal += value.toDouble();
          simLatencyCount += 1;
        }
        break;
      case 'ai_retention_score':
        final value =
            record.params['retention_score_percent'] ??
            record.params['retention'] ??
            record.params['value'];
        if (value is num) {
          retentionTotal += value.toDouble();
          retentionCount += 1;
        }
        final accuracy =
            record.params['accuracy_percent'] ??
            record.params['accuracy'] ??
            record.params['ai_accuracy'];
        if (accuracy is num) {
          _metrics['accuracy_percent'] = _blend(
            _metrics['accuracy_percent'],
            accuracy.toDouble(),
          );
        }
        break;
    }

    // Collect any other numeric metrics consistently.
    record.params.forEach((key, value) {
      if (value is num && _isMetricKey(key)) {
        _metrics[key] = _blend(_metrics[key], value.toDouble());
      }
    });
  }

  Map<String, Object?> toJson() {
    final result = <String, Object?>{
      'user': userHash,
      'session_type': sessionType,
      'avg_ux_latency_ms': uxLatencyCount == 0
          ? 0.0
          : double.parse((uxLatencyTotal / uxLatencyCount).toStringAsFixed(2)),
      'avg_sim_latency_ms': simLatencyCount == 0
          ? 0.0
          : double.parse(
              (simLatencyTotal / simLatencyCount).toStringAsFixed(2),
            ),
      'avg_retention_score_percent': retentionCount == 0
          ? 0.0
          : double.parse((retentionTotal / retentionCount).toStringAsFixed(2)),
    };
    final metricKeys = _metrics.keys.toList()..sort();
    for (final key in metricKeys) {
      result[key] = double.parse(_metrics[key]!.toStringAsFixed(2));
    }
    return result;
  }

  bool _isMetricKey(String key) {
    const ignoreKeys = {'value_ms', 'latency_ms', 'timestamp', 'user_id'};
    return !ignoreKeys.contains(key);
  }

  double _blend(double? existing, double value) {
    if (existing == null) return value;
    return (existing + value) / 2.0;
  }
}

class _TelemetryRecord {
  _TelemetryRecord({
    required this.name,
    required this.params,
    required this.userHash,
    required this.sessionType,
    required this.issueLabel,
  });

  final String name;
  final Map<String, dynamic> params;
  final String userHash;
  final String sessionType;
  final String? issueLabel;

  static _TelemetryRecord? fromJson(Map<String, dynamic> json) {
    final rawName = json['name'] ?? json['event'] ?? '';
    if (rawName is! String || rawName.isEmpty) {
      return null;
    }
    final params = <String, dynamic>{};
    if (json['params'] is Map) {
      (json['params'] as Map).forEach((key, value) {
        if (key is String) params[key] = value;
      });
    }
    if (params.isEmpty && json.isNotEmpty) {
      // Some exporters flatten params at top level prefixed with "param_".
      for (final entry in json.entries) {
        final key = entry.key;
        if (key.startsWith('param_')) {
          params[key.substring('param_'.length)] = entry.value;
        }
      }
    }

    final userKey = _resolveUserKey(json, params);
    final userHash = _hashUserKey(userKey);
    final sessionType = _resolveSessionType(json, params);
    final issue = _resolveIssueLabel(json, params);

    return _TelemetryRecord(
      name: rawName,
      params: params,
      userHash: userHash,
      sessionType: sessionType,
      issueLabel: issue,
    );
  }

  static String _resolveUserKey(
    Map<String, dynamic> json,
    Map<String, dynamic> params,
  ) {
    final candidates = <String?>[
      json['user_id']?.toString(),
      json['uid']?.toString(),
      json['player_id']?.toString(),
      params['user_id']?.toString(),
      params['uid']?.toString(),
      params['player_id']?.toString(),
      params['device_id']?.toString(),
      json['session_id']?.toString(),
    ];
    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return 'anon';
  }

  static String _resolveSessionType(
    Map<String, dynamic> json,
    Map<String, dynamic> params,
  ) {
    final candidates = <String?>[
      json['session_type']?.toString(),
      params['session_type']?.toString(),
      params['mode']?.toString(),
      params['context']?.toString(),
    ];
    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return 'unknown';
  }

  static String? _resolveIssueLabel(
    Map<String, dynamic> json,
    Map<String, dynamic> params,
  ) {
    final candidates = <String?>[
      params['issue']?.toString(),
      params['error']?.toString(),
      params['weakness_tag']?.toString(),
      json['issue']?.toString(),
    ];
    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return null;
  }
}

String _hashUserKey(String input) {
  const int fnvOffsetBasis = 0xcbf29ce484222325;
  const int fnvPrime = 0x100000001b3;
  int hash = fnvOffsetBasis;
  final bytes = utf8.encode(input);
  for (final byte in bytes) {
    hash ^= byte;
    hash = (hash * fnvPrime) & 0xFFFFFFFFFFFFFFFF;
  }
  return hash.toRadixString(16).padLeft(16, '0');
}
