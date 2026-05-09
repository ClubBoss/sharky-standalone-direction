import 'dart:collection';
import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) {
  final options = _CliOptions.parse(arguments);

  if (!options.shouldRun) {
    _printUsage();
    exitCode = 64;
    return;
  }

  final rootDir = options.rootPath != null
      ? Directory(options.rootPath!)
      : Directory.current;
  final runner = _AiAdvisorReport(rootDir);
  final snapshot = runner.buildSnapshot();

  if (options.export || options.summary || options.trend) {
    runner.writeSummary(snapshot);
  }

  if (options.summary) {
    _AsciiRenderer.printSummary(snapshot);
  }

  if (options.trend) {
    _AsciiRenderer.printTrend(snapshot);
  }

  if (options.export && !options.summary && !options.trend) {
    stdout.writeln(
      'ai_advisor_summary.json written to tools/_reports/ai_advisor_summary.json',
    );
  }
}

void _printUsage() {
  stdout.writeln(
    'Usage: dart run tools/ai_advisor_report.dart [--summary] [--trend] [--export] [--root=<path>]',
  );
  stdout.writeln('  --summary   Generate JSON summary and print ASCII table.');
  stdout.writeln(
    '  --trend     Print trend deltas versus trailing 7-day baselines.',
  );
  stdout.writeln('  --export    Persist JSON summary without printing tables.');
}

class _CliOptions {
  _CliOptions(this.summary, this.trend, this.export, this.rootPath);

  final bool summary;
  final bool trend;
  final bool export;
  final String? rootPath;

  bool get shouldRun => summary || trend || export;

  static _CliOptions parse(List<String> args) {
    var summary = false;
    var trend = false;
    var export = false;
    String? rootPath;

    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      switch (arg) {
        case '--summary':
          summary = true;
          break;
        case '--trend':
          trend = true;
          break;
        case '--export':
          export = true;
          break;
        case '--help':
        case '-h':
          _printUsage();
          exit(0);
        default:
          if (arg.startsWith('--root=')) {
            rootPath = arg.substring('--root='.length);
          } else if (arg == '--root' && i + 1 < args.length) {
            rootPath = args[++i];
          } else {
            stderr.writeln('Unrecognized option: $arg');
            _printUsage();
            exit(64);
          }
      }
    }

    if (!summary && !trend && !export) {
      summary = true;
    }

    return _CliOptions(summary, trend, export, rootPath);
  }
}

class _AiAdvisorReport {
  _AiAdvisorReport(this.root);

  final Directory root;

  static const String _reportsDir = 'tools/_reports';
  static const String _summaryPath = '$_reportsDir/ai_advisor_summary.json';
  static const String _releaseSummaryPath =
      'release/public_beta_v2/ai_advisor_summary.json';

  static const String _miniAiTunerPath =
      '$_reportsDir/mini_ai_tuner_summary.json';
  static const String _aiCoachMetricsPath =
      '$_reportsDir/ai_coach_metrics.json';
  static const String _retentionPath =
      '$_reportsDir/ai_coaching_retention.json';

  Map<String, dynamic> buildSnapshot() {
    final tuner = _readJson(_miniAiTunerPath);
    final coach = _readJson(_aiCoachMetricsPath);
    final retention = _readJson(_retentionPath);

    final sources = [tuner, coach, retention];
    final feedsMerged = sources.where((source) => source.isNotEmpty).length;

    final collector = _MetricCollector();
    for (final source in sources) {
      collector.collect(source);
    }

    final weaknesses = _WeaknessCollector.collectAll(sources);
    final topWeaknesses = weaknesses.take(5).toList(growable: false);

    final metrics = collector.build();
    final status = _StatusEvaluator.evaluate(metrics);

    final snapshot = LinkedHashMap<String, dynamic>.from({
      'generated_at': DateTime.now().toUtc().toIso8601String(),
      'status': status.label,
      'pass': status.passed,
      'metrics': metrics.toJson(),
      'trend_vs_last_7_days': metrics.trendDirections(),
      'feeds_merged': feedsMerged,
      'weakness_tags': topWeaknesses
          .map(
            (tag) => {
              'tag': tag.tag,
              'ev_loss': double.parse(tag.evLoss.toStringAsFixed(4)),
              'count': tag.count,
            },
          )
          .toList(),
      'source_files': {
        'mini_ai_tuner_summary': _miniAiTunerPath,
        'ai_coach_metrics': _aiCoachMetricsPath,
        'ai_coaching_retention': _retentionPath,
      },
      if (status.notes.isNotEmpty) 'notes': status.notes,
    });

    _logTelemetry(
      feedsMerged: feedsMerged,
      weaknessCount: topWeaknesses.length,
    );

    return snapshot;
  }

  void writeSummary(Map<String, dynamic> snapshot) {
    _writeJson(_summaryPath, snapshot);
    _writeJson(_releaseSummaryPath, snapshot);
  }

  void _writeJson(String relativePath, Map<String, dynamic> snapshot) {
    final file = File.fromUri(root.uri.resolve(relativePath));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(snapshot),
    );
  }

  Map<String, dynamic> _readJson(String relativePath) {
    final file = File.fromUri(root.uri.resolve(relativePath));
    if (!file.existsSync()) {
      return const {};
    }
    try {
      final content = file.readAsStringSync();
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return const {};
    } catch (e) {
      stderr.writeln('[WARN] Failed to read $relativePath: $e');
      return const {};
    }
  }

  void _logTelemetry({required int feedsMerged, required int weaknessCount}) {
    stdout.writeln(
      'telemetry: ai_advisor_report_generated feeds=$feedsMerged weaknesses=$weaknessCount',
    );
  }
}

class _MetricCollector {
  final _MetricBucket _evDiff = _MetricBucket('avg_ev_diff');
  final _MetricBucket _confidence = _MetricBucket('avg_confidence');
  final _MetricBucket _correct = _MetricBucket('correct_ratio');
  final _MetricBucket _retention = _MetricBucket('retention_score');

  void collect(Map<String, dynamic> source) {
    if (source.isEmpty) return;
    _walk(source, currentKey: '');
  }

  _AdvisorMetrics build() {
    return _AdvisorMetrics(
      evDiff: _evDiff.build(),
      confidence: _confidence.build(),
      correctRatio: _correct.build(),
      retentionScore: _retention.build(),
    );
  }

  void _walk(dynamic node, {required String currentKey}) {
    if (node is Map) {
      for (final entry in node.entries) {
        final key = entry.key.toString();
        final nextKey = currentKey.isEmpty ? key : '$currentKey.$key';
        _walk(entry.value, currentKey: nextKey);
      }
      return;
    }
    if (node is Iterable) {
      for (final value in node) {
        _walk(value, currentKey: currentKey);
      }
      return;
    }
    if (node is num) {
      _recordMetric(currentKey, node.toDouble());
    }
  }

  void _recordMetric(String keyPath, double value) {
    final normalized = keyPath.toLowerCase();
    final isSevenDay =
        normalized.contains('7d') ||
        normalized.contains('seven') ||
        normalized.contains('weekly');

    if (_matches(normalized, ['ev_diff', 'evdelta', 'expected_value'])) {
      _evDiff.add(value, isSevenDay: isSevenDay);
      return;
    }
    if (_matches(normalized, [
      'confidence',
      'confidence_score',
      'confidence_avg',
    ])) {
      _confidence.add(value, isSevenDay: isSevenDay);
      return;
    }
    if (_matches(normalized, [
      'correct_ratio',
      'accuracy',
      'win_rate',
      'correctness',
    ])) {
      _correct.add(value, isSevenDay: isSevenDay);
      return;
    }
    if (_matches(normalized, [
      'retention',
      'retention_score',
      'retained',
      'engagement',
    ])) {
      _retention.add(value, isSevenDay: isSevenDay);
    }
  }

  bool _matches(String key, List<String> needles) {
    for (final needle in needles) {
      if (key.contains(needle)) return true;
    }
    return false;
  }
}

class _MetricBucket {
  _MetricBucket(this.name);

  final String name;
  final List<double> _currentValues = [];
  final List<double> _sevenDayValues = [];

  void add(double value, {required bool isSevenDay}) {
    if (isSevenDay) {
      _sevenDayValues.add(value);
    } else {
      _currentValues.add(value);
    }
  }

  _MetricView build() {
    return _MetricView(
      name: name,
      current: _average(_currentValues),
      sevenDay: _average(_sevenDayValues),
    );
  }

  double _average(List<double> values) {
    if (values.isEmpty) return double.nan;
    var sum = 0.0;
    for (final value in values) {
      sum += value;
    }
    return sum / values.length;
  }
}

class _AdvisorMetrics {
  _AdvisorMetrics({
    required this.evDiff,
    required this.confidence,
    required this.correctRatio,
    required this.retentionScore,
  });

  final _MetricView evDiff;
  final _MetricView confidence;
  final _MetricView correctRatio;
  final _MetricView retentionScore;

  Map<String, dynamic> toJson() {
    final evJson = LinkedHashMap<String, dynamic>.from(evDiff.toJson());
    final confidenceJson = LinkedHashMap<String, dynamic>.from(
      confidence.toJson(),
    );
    final correctJson = LinkedHashMap<String, dynamic>.from(
      correctRatio.toJson(),
    );
    final retentionJson = LinkedHashMap<String, dynamic>.from(
      retentionScore.toJson(),
    );

    final output = LinkedHashMap<String, dynamic>();
    output['avg_ev_diff'] = evJson;
    output['avg_confidence'] = confidenceJson;
    output['correct_ratio'] = correctJson;
    output['retention_score'] = retentionJson;
    // Legacy keys for downstream compatibility.
    output['ev_diff'] = LinkedHashMap<String, dynamic>.from(evJson);
    output['confidence'] = LinkedHashMap<String, dynamic>.from(confidenceJson);
    return output;
  }

  Map<String, String> trendDirections() {
    return LinkedHashMap<String, String>.from({
      'avg_ev_diff': evDiff.trendDirection,
      'avg_confidence': confidence.trendDirection,
      'correct_ratio': correctRatio.trendDirection,
      'retention_score': retentionScore.trendDirection,
      'ev_diff': evDiff.trendDirection,
      'confidence': confidence.trendDirection,
    });
  }
}

class _MetricView {
  _MetricView({
    required this.name,
    required this.current,
    required this.sevenDay,
  });

  final String name;
  final double current;
  final double sevenDay;

  double get delta {
    if (current.isNaN || sevenDay.isNaN) return double.nan;
    return current - sevenDay;
  }

  Map<String, dynamic> toJson() {
    return LinkedHashMap<String, dynamic>.from({
      'current': _normalize(current),
      'seven_day': _normalize(sevenDay),
      'delta': _normalize(delta),
    });
  }

  String get trendDirection {
    if (delta.isNaN || delta == 0.0) return 'STABLE';
    const epsilon = 0.0005;
    if (delta.abs() < epsilon) return 'STABLE';
    return delta > 0 ? 'UP' : 'DOWN';
  }

  static double? _normalize(double value) {
    if (value.isNaN || value.isInfinite) return null;
    return double.parse(value.toStringAsFixed(4));
  }
}

class _WeaknessCollector {
  static Iterable<_WeaknessTag> collectAll(
    List<Map<String, dynamic>> sources,
  ) sync* {
    final Map<String, _WeaknessTag> merged = <String, _WeaknessTag>{};

    for (final source in sources) {
      if (source.isEmpty) continue;
      _walk(source, merged);
    }

    final values = merged.values.toList()
      ..sort((a, b) => b.evLoss.compareTo(a.evLoss));

    for (final value in values) {
      yield value;
    }
  }

  static void _walk(dynamic node, Map<String, _WeaknessTag> merged) {
    if (node is Map) {
      if (node.containsKey('tag') && node.containsKey('ev_loss')) {
        final tag = node['tag'].toString();
        final evLoss = (node['ev_loss'] as num?)?.toDouble();
        if (evLoss != null) {
          final count = (node['count'] as num?)?.toInt() ?? 1;
          final existing = merged[tag];
          if (existing == null) {
            merged[tag] = _WeaknessTag(tag: tag, evLoss: evLoss, count: count);
          } else {
            merged[tag] = existing.combine(evLoss, count);
          }
        }
      }
      for (final entry in node.entries) {
        _walk(entry.value, merged);
      }
      return;
    }
    if (node is Iterable) {
      for (final value in node) {
        _walk(value, merged);
      }
    }
  }
}

class _WeaknessTag {
  const _WeaknessTag({
    required this.tag,
    required this.evLoss,
    required this.count,
  });

  final String tag;
  final double evLoss;
  final int count;

  _WeaknessTag combine(double additionalLoss, int additionalCount) {
    final totalLoss = (evLoss * count) + (additionalLoss * additionalCount);
    final totalCount = count + additionalCount;
    final avgLoss = totalCount == 0 ? 0.0 : totalLoss / totalCount;
    return _WeaknessTag(tag: tag, evLoss: avgLoss, count: totalCount);
  }
}

class _Status {
  const _Status({
    required this.label,
    required this.passed,
    required this.notes,
  });

  final String label;
  final bool passed;
  final List<String> notes;
}

class _StatusEvaluator {
  static const double _evDiffThreshold = -0.5;
  static const double _confidenceThreshold = 0.55;
  static const double _correctThreshold = 0.6;
  static const double _retentionThreshold = 0.7;

  static _Status evaluate(_AdvisorMetrics metrics) {
    final notes = <String>[];

    final evCurrent = metrics.evDiff.current;
    final confidenceCurrent = metrics.confidence.current;
    final correctCurrent = metrics.correctRatio.current;
    final retentionCurrent = metrics.retentionScore.current;

    var passed = true;

    if (evCurrent.isNaN) {
      notes.add('EV diff unavailable.');
      passed = false;
    } else if (evCurrent < _evDiffThreshold) {
      notes.add(
        'Average EV diff below target (${evCurrent.toStringAsFixed(2)}).',
      );
      passed = false;
    }

    if (confidenceCurrent.isNaN) {
      notes.add('Confidence score missing.');
      passed = false;
    } else if (confidenceCurrent < _confidenceThreshold) {
      notes.add(
        'Confidence score (${confidenceCurrent.toStringAsFixed(2)}) below threshold.',
      );
      passed = false;
    }

    if (correctCurrent.isNaN) {
      notes.add('Correct ratio unavailable.');
      passed = false;
    } else if (correctCurrent < _correctThreshold) {
      notes.add(
        'Correct ratio (${correctCurrent.toStringAsFixed(2)}) below expectation.',
      );
      passed = false;
    }

    if (retentionCurrent.isNaN) {
      notes.add('Retention score missing.');
      passed = false;
    } else if (retentionCurrent < _retentionThreshold) {
      notes.add(
        'Retention score (${retentionCurrent.toStringAsFixed(2)}) below threshold.',
      );
      passed = false;
    }

    final label = passed ? 'PASS' : 'FAIL';
    return _Status(label: label, passed: passed, notes: notes);
  }
}

class _AsciiRenderer {
  static void printSummary(Map<String, dynamic> snapshot) {
    final metrics = _extractMetricViews(snapshot);
    final rows = <List<String>>[
      ['Metric', 'Current', '7d Avg', 'Delta'],
      ...metrics.map(
        (metric) => [
          metric.label,
          metric.current,
          metric.sevenDay,
          metric.delta,
        ],
      ),
    ];

    _printTable(rows);

    final weaknesses = snapshot['weakness_tags'];
    if (weaknesses is List && weaknesses.isNotEmpty) {
      stdout.writeln('Top Weakness Tags:');
      for (var i = 0; i < weaknesses.length; i++) {
        final entry = weaknesses[i];
        if (entry is Map) {
          final tag = entry['tag'] ?? 'unknown';
          final loss = entry['ev_loss'];
          stdout.writeln(
            '  ${i + 1}. $tag (${_formatDouble(loss, suffix: ' EV')})',
          );
        }
      }
    } else {
      stdout.writeln('Top Weakness Tags: none detected.');
    }
  }

  static void printTrend(Map<String, dynamic> snapshot) {
    final metrics = _extractMetricViews(snapshot);
    stdout.writeln('Trend vs 7-day baseline:');
    for (final metric in metrics) {
      final arrow = _trendArrow(metric.deltaValue);
      stdout.writeln('  ${metric.label}: ${metric.delta} $arrow');
    }
  }

  static void _printTable(List<List<String>> rows) {
    if (rows.isEmpty) return;
    final columnWidths = _computeColumnWidths(rows);

    stdout.writeln(_tableBorder(columnWidths));
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final cells = <String>[];
      for (var col = 0; col < row.length; col++) {
        final cell = row[col];
        final width = columnWidths[col];
        cells.add(_pad(cell, width));
      }
      stdout.writeln('| ${cells.join(' | ')} |');
      if (i == 0 || i == rows.length - 1) {
        stdout.writeln(_tableBorder(columnWidths));
      }
    }
  }

  static List<int> _computeColumnWidths(List<List<String>> rows) {
    final widths = <int>[];
    for (final row in rows) {
      for (var col = 0; col < row.length; col++) {
        final cell = row[col];
        if (widths.length <= col) {
          widths.add(cell.length);
        } else {
          widths[col] = cell.length > widths[col] ? cell.length : widths[col];
        }
      }
    }
    return widths;
  }

  static String _tableBorder(List<int> widths) {
    final segments = widths.map((w) => '-' * (w + 2)).join('+');
    return '+$segments+';
  }

  static String _pad(String value, int width) {
    if (value.length >= width) return value;
    return value + ' ' * (width - value.length);
  }

  static Iterable<_MetricRow> _extractMetricViews(
    Map<String, dynamic> snapshot,
  ) sync* {
    final metrics = snapshot['metrics'];
    if (metrics is! Map) return;
    for (final entry in metrics.entries) {
      final name = entry.key.toString();
      final payload = entry.value;
      if (payload is Map) {
        final current = payload['current'];
        final sevenDay = payload['seven_day'];
        final delta = payload['delta'];
        yield _MetricRow(
          label: _prettyLabel(name),
          current: _formatDouble(current),
          sevenDay: _formatDouble(sevenDay),
          delta: _formatDouble(delta),
          deltaValue: delta is num ? delta.toDouble() : double.nan,
        );
      }
    }
  }

  static String _prettyLabel(String key) {
    switch (key) {
      case 'avg_ev_diff':
        return 'EV Diff (bb)';
      case 'avg_confidence':
        return 'Confidence';
      case 'correct_ratio':
        return 'Correct %';
      case 'retention_score':
        return 'Retention';
      default:
        return key;
    }
  }

  static String _trendArrow(double delta) {
    if (delta.isNaN || delta == 0.0) return '--';
    return delta > 0 ? '(up)' : '(down)';
  }

  static String _formatDouble(Object? value, {String suffix = ''}) {
    if (value is num) {
      final rounded = value.toStringAsFixed(3);
      return suffix.isEmpty ? rounded : '$rounded$suffix';
    }
    if (value is String) return value;
    return 'n/a';
  }
}

class _MetricRow {
  _MetricRow({
    required this.label,
    required this.current,
    required this.sevenDay,
    required this.delta,
    required this.deltaValue,
  });

  final String label;
  final String current;
  final String sevenDay;
  final String delta;
  final double deltaValue;
}
