import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final options = _Options.parse(args);

  // Load previous metrics for delta calculation
  final trendCache = _TrendCache.load();

  final model = _LandingModel.load();
  final runTimestamp = model.lastSyncUtc.isNotEmpty
      ? model.lastSyncUtc
      : DateTime.now().toUtc().toIso8601String();

  if (options.summary) {
    final statusEmoji = model.readinessPercent >= 60 ? '✅' : '❌';
    stdout.writeln(
      'Public Beta V2: ${model.readinessPercent.toStringAsFixed(1)}% '
      '(advisor ${model.advisorScore.toStringAsFixed(1)}%, '
      'feedback ${model.feedbackScore.toStringAsFixed(1)}%) $statusEmoji',
    );
  }

  if (options.generate) {
    await _writeHtml(model);
    final telemetryMetrics = await _writeMetadata(
      model,
      trendCache,
      runTimestamp: runTimestamp,
    );

    // Update trend cache with current values including telemetry
    trendCache.updateMetrics(
      readiness: model.readinessPercent,
      advisor: model.advisorScore,
      feedback: model.feedbackScore,
      timestampUtc: runTimestamp,
      telemetryConfidence: telemetryMetrics['confidence'],
      telemetryEvDiff: telemetryMetrics['evDiff'],
      telemetryLatency: telemetryMetrics['latency'],
      telemetryRetention: telemetryMetrics['retention'],
    );
    trendCache.save();

    if (options.statsBoard) {
      stdout.writeln('Generating stats board...');
      // board.html already exists as static file, just confirm metadata is ready
      final boardFile = File('release/public_beta_v2/board.html');
      if (boardFile.existsSync()) {
        stdout.writeln('Stats board ready: ${boardFile.path}');
      }
    }
  }
}

class _Options {
  _Options({
    required this.summary,
    required this.generate,
    required this.statsBoard,
  });

  final bool summary;
  final bool generate;
  final bool statsBoard;

  static _Options parse(List<String> args) {
    var summary = false;
    var generate = true;
    var statsBoard = false;
    for (final arg in args) {
      switch (arg) {
        case '--summary':
          summary = true;
          break;
        case '--generate':
          generate = true;
          break;
        case '--no-generate':
          generate = false;
          break;
        case '--stats-board':
          statsBoard = true;
          generate = true; // Auto-enable generation for stats board
          break;
      }
    }
    return _Options(
      summary: summary,
      generate: generate,
      statsBoard: statsBoard,
    );
  }
}

class _LandingModel {
  _LandingModel({
    required this.readinessPercent,
    required this.advisorScore,
    required this.feedbackScore,
    required this.topIssues,
    required this.buildVersion,
    required this.lastSyncUtc,
  });

  final double readinessPercent;
  final double advisorScore;
  final double feedbackScore;
  final List<String> topIssues;
  final String buildVersion;
  final String lastSyncUtc;

  static _LandingModel load() {
    final readiness = _readJson('tools/_reports/full_readiness_summary.json');
    final advisor = _readJson('tools/_reports/ai_advisor_summary.json');
    final feedback = _readJson(
      'tools/_reports/public_beta_feedback_summary.json',
    );
    final qaMetadata = _readJson('release/qa_dashboard/metadata.json');

    final readinessPercent =
        (readiness['readiness_score'] as num?)?.toDouble() ?? 0.0;
    final advisorMetrics = advisor['metrics'] as Map<String, dynamic>? ?? {};
    final confidenceBucket =
        advisorMetrics['confidence'] as Map<String, dynamic>? ?? {};
    final advisorScore =
        (confidenceBucket['current'] as num?)?.toDouble() ?? 0.0;

    final feedbackAggregates =
        feedback['aggregates'] as Map<String, dynamic>? ?? {};
    final feedbackScore =
        (feedbackAggregates['avg_ux_latency_ms'] as num?)?.toDouble() ?? 0.0;

    final topIssues = <String>[];
    final issuesRaw = feedbackAggregates['top_issues'];
    if (issuesRaw is List) {
      for (final entry in issuesRaw) {
        if (entry is Map && entry['label'] is String) {
          topIssues.add(entry['label'] as String);
        }
      }
    }

    final buildVersion = qaMetadata['build_version']?.toString() ?? 'unknown';
    final lastSyncUtc =
        qaMetadata['timestamp_utc']?.toString() ??
        DateTime.now().toUtc().toIso8601String();

    return _LandingModel(
      readinessPercent: readinessPercent,
      advisorScore: advisorScore,
      feedbackScore: feedbackScore,
      topIssues: topIssues,
      buildVersion: buildVersion,
      lastSyncUtc: lastSyncUtc,
    );
  }
}

Future<void> _writeHtml(_LandingModel model) async {
  final readinessEmoji = model.readinessPercent >= 60 ? '✅' : '❌';
  final advisorEmoji = model.advisorScore >= 50 ? '✅' : '❌';
  final feedbackEmoji = model.feedbackScore <= 350 ? '✅' : '❌';

  final issues = model.topIssues.isEmpty
      ? '<li>No user issues reported</li>'
      : model.topIssues.map((issue) => '<li>${_escape(issue)}</li>').join();

  final html = [
    '<!DOCTYPE html>',
    '<html lang="en">',
    '<head>',
    '  <meta charset="utf-8" />',
    '  <title>Public Beta Dashboard V2</title>',
    '  <style>',
    '    body {',
    '      font-family: Arial, sans-serif;',
    '      background: #0d1b2a;',
    '      color: #f5f5f5;',
    '      margin: 0;',
    '      padding: 40px;',
    '    }',
    '    h1 { text-align: center; margin-bottom: 24px; }',
    '    .grid { display: flex; gap: 16px; justify-content: center; flex-wrap: wrap; }',
    '    .card { background: #1b263b; border-radius: 12px; padding: 24px; min-width: 200px;',
    '      text-align: center; box-shadow: 0 4px 12px rgba(0,0,0,0.4); }',
    '    .label { font-size: 16px; margin-bottom: 12px; text-transform: uppercase; color: #91a7ff; }',
    '    .value { font-size: 32px; font-weight: bold; }',
    '    .issues { max-width: 640px; margin: 32px auto; background: #112236; padding: 24px; border-radius: 12px; }',
    '    .issues h2 { margin-top: 0; }',
    '    .footer { text-align: center; margin-top: 32px; font-size: 14px; color: #cbd5f5; }',
    '  </style>',
    '</head>',
    '<body>',
    '  <h1>Public Beta Dashboard V2</h1>',
    '  <div class="grid">',
    '    <div class="card">',
    '      <div class="label">Readiness</div>',
    '      <div class="value">${model.readinessPercent.toStringAsFixed(1)}% $readinessEmoji</div>',
    '    </div>',
    '    <div class="card">',
    '      <div class="label">Advisor Confidence</div>',
    '      <div class="value">${model.advisorScore.toStringAsFixed(1)}% $advisorEmoji</div>',
    '    </div>',
    '    <div class="card">',
    '      <div class="label">Feedback Latency</div>',
    '      <div class="value">${model.feedbackScore.toStringAsFixed(1)} ms $feedbackEmoji</div>',
    '    </div>',
    '  </div>',
    '  <div class="issues">',
    '    <h2>Top User Issues</h2>',
    '    <ul>',
    issues,
    '    </ul>',
    '  </div>',
    '  <div class="footer">',
    '    Build Version: ${_escape(model.buildVersion)}<br/>',
    '    Last Updated: ${_escape(model.lastSyncUtc)}',
    '  </div>',
    '</body>',
    '</html>',
  ].join('\n');

  final file = File('release/public_beta_v2/index.html');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync('$html\n');
}

Future<Map<String, double?>> _writeMetadata(
  _LandingModel model,
  _TrendCache trendCache, {
  required String runTimestamp,
}) async {
  // Load raw report data for charts
  final advisor = _readJson('tools/_reports/ai_advisor_summary.json');
  final feedback = _readJson(
    'tools/_reports/public_beta_feedback_summary.json',
  );
  final simulation = _readJson('tools/_reports/simulation_metrics.json');
  final unifiedTelemetry = _readJson(
    'tools/_reports/unified_telemetry_summary.json',
  );

  // Extract unified telemetry metrics first (needed for projectedHistory)
  final derivedMetrics =
      unifiedTelemetry['derived_metrics'] as Map<String, dynamic>? ?? {};
  final unifiedAvgConfidence =
      (derivedMetrics['avg_confidence'] as num?)?.toDouble() ?? 0.0;
  final unifiedAvgEvDiff =
      (derivedMetrics['avg_ev_diff'] as num?)?.toDouble() ?? 0.0;
  final unifiedAvgLatencyMs =
      (derivedMetrics['avg_latency_ms'] as num?)?.toDouble() ?? 0.0;
  final unifiedRetentionScore =
      (derivedMetrics['retention_score'] as num?)?.toDouble() ?? 0.0;
  final telemetryGeneratedAt =
      unifiedTelemetry['generated_at']?.toString() ?? runTimestamp;

  // Calculate deltas from previous run
  final readinessDelta = trendCache.previousReadiness != null
      ? model.readinessPercent - trendCache.previousReadiness!
      : 0.0;
  final advisorDelta = trendCache.previousAdvisor != null
      ? model.advisorScore - trendCache.previousAdvisor!
      : 0.0;
  final feedbackDelta = trendCache.previousFeedback != null
      ? model.feedbackScore - trendCache.previousFeedback!
      : 0.0;

  final projectedHistory = trendCache.projectedHistory(
    timestampUtc: runTimestamp,
    readiness: model.readinessPercent,
    advisor: model.advisorScore,
    feedback: model.feedbackScore,
    telemetryConfidence: unifiedAvgConfidence,
    telemetryEvDiff: unifiedAvgEvDiff,
    telemetryLatency: unifiedAvgLatencyMs,
    telemetryRetention: unifiedRetentionScore,
  );
  final sevenDayAverage = _calculateSevenDayAverage(projectedHistory);
  final streaks = _calculateStreaks(projectedHistory);

  // Extract advisor metrics with seven_day arrays
  final advisorMetrics = advisor['metrics'] as Map<String, dynamic>? ?? {};
  final confidenceData =
      advisorMetrics['confidence'] as Map<String, dynamic>? ?? {};
  final evDiffData = advisorMetrics['ev_diff'] as Map<String, dynamic>? ?? {};
  final correctRatioData =
      advisorMetrics['correct_ratio'] as Map<String, dynamic>? ?? {};

  // Extract feedback records for latency histogram
  final feedbackRecords = feedback['records'] as List<dynamic>? ?? [];
  final latencyRecords = <double>[];
  for (final record in feedbackRecords) {
    if (record is Map<String, dynamic>) {
      final latency = record['ux_latency_ms'];
      if (latency is num) {
        latencyRecords.add(latency.toDouble());
      }
    }
  }

  // Extract simulation metrics
  final simMetrics = simulation['metrics'] as Map<String, dynamic>? ?? {};

  final metadata = <String, dynamic>{
    'readiness': model.readinessPercent,
    'advisor': model.advisorScore,
    'feedback': model.feedbackScore,
    'top_user_issues': model.topIssues,
    'build_version': model.buildVersion,
    'timestamp_utc': runTimestamp,
    // Unified telemetry metrics
    'unified_telemetry': <String, dynamic>{
      'avg_confidence': unifiedAvgConfidence,
      'avg_ev_diff': unifiedAvgEvDiff,
      'avg_latency_ms': unifiedAvgLatencyMs,
      'retention_score': unifiedRetentionScore,
      'generated_at': telemetryGeneratedAt,
    },
    // Delta trends from previous run
    'trends': <String, dynamic>{
      'readiness_delta': readinessDelta,
      'advisor_delta': advisorDelta,
      'feedback_delta': feedbackDelta,
      'has_previous_data': trendCache.hasHistory,
      'seven_day_average': sevenDayAverage,
      'streaks': streaks,
      'trend_history': projectedHistory
          .map((record) => record.toJson())
          .toList(),
    },
    // Raw data for charts
    'advisor_metrics': <String, dynamic>{
      'confidence_seven_day': confidenceData['seven_day'],
      'ev_diff_seven_day': evDiffData['seven_day'],
      'correct_ratio_seven_day': correctRatioData['seven_day'],
    },
    'feedback_latency_records': latencyRecords,
    'simulation_metrics': <String, dynamic>{
      'total_rounds': simMetrics['total_rounds'],
      'avg_latency_ms': simMetrics['avg_latency_ms'],
      'success_rate': simMetrics['success_rate'],
    },
  };
  final encoder = JsonEncoder.withIndent('  ');
  final file = File('release/public_beta_v2/metadata.json');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync('${encoder.convert(metadata)}\n');

  // Return telemetry metrics for cache update
  return <String, double?>{
    'confidence': unifiedAvgConfidence,
    'evDiff': unifiedAvgEvDiff,
    'latency': unifiedAvgLatencyMs,
    'retention': unifiedRetentionScore,
  };
}

Map<String, dynamic> _readJson(String path) {
  final file = File(path);
  if (!file.existsSync()) return const {};
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } catch (e) {
    stderr.writeln('[WARN] Failed to read $path: $e');
  }
  return const {};
}

String _escape(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}

/// Trend cache for storing previous metric values to calculate deltas.
class _TrendCache {
  _TrendCache({List<_TrendRecord>? history})
    : history = List<_TrendRecord>.from(history ?? const []);

  final List<_TrendRecord> history;

  static const _cachePath = 'tools/_reports/.trend_cache.json';

  /// Load cached trends from disk.
  static _TrendCache load() {
    final file = File(_cachePath);
    if (!file.existsSync()) {
      return _TrendCache();
    }
    try {
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is Map<String, dynamic>) {
        final history = <_TrendRecord>[];
        final rawHistory = decoded['history'];
        if (rawHistory is List) {
          for (final entry in rawHistory) {
            if (entry is Map<String, dynamic>) {
              final record = _TrendRecord.fromJson(entry);
              if (record != null) {
                history.add(record);
              }
            }
          }
        } else {
          final legacyRecord = _TrendRecord.fromLegacy(decoded);
          if (legacyRecord != null) {
            history.add(legacyRecord);
          }
        }
        return _TrendCache(history: _trimToSeven(history));
      }
    } catch (e) {
      stderr.writeln('[WARN] Failed to load trend cache: $e');
    }
    return _TrendCache();
  }

  bool get hasHistory => history.isNotEmpty;

  double? get previousReadiness => hasHistory ? history.last.readiness : null;

  double? get previousAdvisor => hasHistory ? history.last.advisor : null;

  double? get previousFeedback => hasHistory ? history.last.feedback : null;

  /// Build projected history that includes the current run without mutating state.
  List<_TrendRecord> projectedHistory({
    required String timestampUtc,
    required double readiness,
    required double advisor,
    required double feedback,
    double? telemetryConfidence,
    double? telemetryEvDiff,
    double? telemetryLatency,
    double? telemetryRetention,
  }) {
    final next = List<_TrendRecord>.from(history)
      ..add(
        _TrendRecord(
          timestampUtc: timestampUtc,
          readiness: readiness,
          advisor: advisor,
          feedback: feedback,
          telemetryConfidence: telemetryConfidence,
          telemetryEvDiff: telemetryEvDiff,
          telemetryLatency: telemetryLatency,
          telemetryRetention: telemetryRetention,
        ),
      );
    return _trimToSeven(next);
  }

  /// Update metrics with current values.
  void updateMetrics({
    required double readiness,
    required double advisor,
    required double feedback,
    required String timestampUtc,
    double? telemetryConfidence,
    double? telemetryEvDiff,
    double? telemetryLatency,
    double? telemetryRetention,
  }) {
    history.add(
      _TrendRecord(
        timestampUtc: timestampUtc,
        readiness: readiness,
        advisor: advisor,
        feedback: feedback,
        telemetryConfidence: telemetryConfidence,
        telemetryEvDiff: telemetryEvDiff,
        telemetryLatency: telemetryLatency,
        telemetryRetention: telemetryRetention,
      ),
    );
    _trimToSeven(history);
  }

  /// Save cache to disk.
  void save() {
    final data = <String, dynamic>{
      'history': history.map((record) => record.toJson()).toList(),
      'last_updated': history.isNotEmpty ? history.last.timestampUtc : null,
    };
    final file = File(_cachePath);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(data)}\n',
    );
  }

  static List<_TrendRecord> _trimToSeven(List<_TrendRecord> records) {
    while (records.length > 7) {
      records.removeAt(0);
    }
    return records;
  }
}

class _TrendRecord {
  _TrendRecord({
    required this.timestampUtc,
    required this.readiness,
    required this.advisor,
    required this.feedback,
    this.telemetryConfidence,
    this.telemetryEvDiff,
    this.telemetryLatency,
    this.telemetryRetention,
  });

  final String timestampUtc;
  final double readiness;
  final double advisor;
  final double feedback;
  final double? telemetryConfidence;
  final double? telemetryEvDiff;
  final double? telemetryLatency;
  final double? telemetryRetention;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'timestamp_utc': timestampUtc,
      'readiness': readiness,
      'advisor': advisor,
      'feedback': feedback,
      if (telemetryConfidence != null)
        'telemetry_confidence': telemetryConfidence,
      if (telemetryEvDiff != null) 'telemetry_ev_diff': telemetryEvDiff,
      if (telemetryLatency != null) 'telemetry_latency': telemetryLatency,
      if (telemetryRetention != null) 'telemetry_retention': telemetryRetention,
    };
  }

  static _TrendRecord? fromJson(Map<String, dynamic> data) {
    final timestamp = data['timestamp_utc']?.toString();
    final readiness = (data['readiness'] as num?)?.toDouble();
    final advisor = (data['advisor'] as num?)?.toDouble();
    final feedback = (data['feedback'] as num?)?.toDouble();
    if (timestamp == null ||
        readiness == null ||
        advisor == null ||
        feedback == null) {
      return null;
    }
    final telemetryConfidence = (data['telemetry_confidence'] as num?)
        ?.toDouble();
    final telemetryEvDiff = (data['telemetry_ev_diff'] as num?)?.toDouble();
    final telemetryLatency = (data['telemetry_latency'] as num?)?.toDouble();
    final telemetryRetention = (data['telemetry_retention'] as num?)
        ?.toDouble();
    return _TrendRecord(
      timestampUtc: timestamp,
      readiness: readiness,
      advisor: advisor,
      feedback: feedback,
      telemetryConfidence: telemetryConfidence,
      telemetryEvDiff: telemetryEvDiff,
      telemetryLatency: telemetryLatency,
      telemetryRetention: telemetryRetention,
    );
  }

  static _TrendRecord? fromLegacy(Map<String, dynamic> data) {
    final readiness = (data['readiness'] as num?)?.toDouble();
    final advisor = (data['advisor'] as num?)?.toDouble();
    final feedback = (data['feedback'] as num?)?.toDouble();
    if (readiness == null && advisor == null && feedback == null) {
      return null;
    }
    final timestamp =
        data['last_updated']?.toString() ??
        DateTime.now().toUtc().toIso8601String();
    return _TrendRecord(
      timestampUtc: timestamp,
      readiness: readiness ?? 0.0,
      advisor: advisor ?? 0.0,
      feedback: feedback ?? 0.0,
      telemetryConfidence: null,
      telemetryEvDiff: null,
      telemetryLatency: null,
      telemetryRetention: null,
    );
  }
}

Map<String, double> _calculateSevenDayAverage(List<_TrendRecord> history) {
  if (history.isEmpty) {
    return const {'readiness': 0.0, 'advisor': 0.0, 'feedback': 0.0};
  }

  double readinessTotal = 0;
  double advisorTotal = 0;
  double feedbackTotal = 0;

  for (final record in history) {
    readinessTotal += record.readiness;
    advisorTotal += record.advisor;
    feedbackTotal += record.feedback;
  }

  final length = history.length.toDouble();

  return {
    'readiness': readinessTotal / length,
    'advisor': advisorTotal / length,
    'feedback': feedbackTotal / length,
  };
}

Map<String, Map<String, dynamic>> _calculateStreaks(
  List<_TrendRecord> history,
) {
  final readinessDelta = _delta(history, (record) => record.readiness);
  final advisorDelta = _delta(history, (record) => record.advisor);
  final feedbackDelta = _delta(history, (record) => record.feedback);

  return {
    'readiness': _streakEntry(readinessDelta),
    'advisor': _streakEntry(advisorDelta),
    'feedback': _streakEntry(feedbackDelta),
  };
}

double _delta(
  List<_TrendRecord> history,
  double Function(_TrendRecord record) selector,
) {
  if (history.length < 2) {
    return 0.0;
  }
  final start = selector(history.first);
  final end = selector(history.last);
  return end - start;
}

Map<String, dynamic> _streakEntry(double delta) {
  const tolerance = 0.1;
  final direction = delta > tolerance
      ? 'improving'
      : (delta < -tolerance ? 'declining' : 'stable');
  return {'direction': direction, 'change': delta};
}
