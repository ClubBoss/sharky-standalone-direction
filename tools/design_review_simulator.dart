import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final simulator = _DesignReviewSimulator();
  try {
    final result = await simulator.run();
    await simulator.writeSummary(result);
    await simulator.emitTelemetry(result);
  } finally {
    await simulator.restorePermissions();
  }
}

class _DesignReviewSimulator {
  bool _reportsWritable = false;

  Future<_ReviewResult> run() async {
    final watch = Stopwatch()..start();
    final dashboard = await _parseDashboard();
    final priorities = await _parsePriorities();
    final simulations = _simulateReviews(dashboard, priorities);
    watch.stop();
    final avgConfidence = simulations.isEmpty
        ? 0
        : simulations.map((s) => s.confidence).reduce((a, b) => a + b) /
              simulations.length;
    return _ReviewResult(
      timestamp: DateTime.now().toUtc(),
      simulations: simulations,
      averageConfidence: avgConfidence.toDouble(),
      durationMs: watch.elapsedMilliseconds,
    );
  }

  Future<_DashboardMetrics> _parseDashboard() async {
    final file = File('release/_reports/ux_dashboard_summary.txt');
    if (!file.existsSync()) {
      throw StateError('ux_dashboard_summary.txt not found.');
    }
    final lines = await file.readAsLines();
    final entries = <String, _DashboardEntry>{};
    for (final line in lines) {
      if (!line.startsWith('|')) continue;
      final parts = line.split('|').map((p) => p.trim()).toList();
      if (parts.length < 5 || parts[1] == 'Metric') continue;
      entries[parts[1]] = _DashboardEntry(value: parts[2], badge: parts[3]);
    }
    String badge(String metric) => entries[metric]?.badge ?? 'UNKNOWN';
    double value(String metric) =>
        double.tryParse(entries[metric]?.value ?? '') ?? 0;
    return _DashboardMetrics(
      fpsBadge: badge('Avg FPS'),
      memBadge: badge('Peak Mem (MB)'),
      stabilityBadge: badge('Stability'),
      warningsBadge: badge('Warnings'),
      avgFps: value('Avg FPS'),
    );
  }

  Future<List<_PriorityEntry>> _parsePriorities() async {
    final file = File('release/_reports/ux_prioritization_matrix.md');
    if (!file.existsSync()) {
      throw StateError('ux_prioritization_matrix.md not found.');
    }
    final lines = await file.readAsLines();
    final entries = <_PriorityEntry>[];
    for (final line in lines) {
      if (!line.startsWith('|')) continue;
      final parts = line.split('|').map((p) => p.trim()).toList();
      if (parts.length < 6 || parts[1] == 'Rank') continue;
      final rank = int.tryParse(parts[1]);
      if (rank == null) continue;
      entries.add(
        _PriorityEntry(
          rank: rank,
          area: parts[2],
          impact: parts[3],
          driver: parts[4],
          action: parts[5],
        ),
      );
    }
    entries.sort((a, b) => a.rank.compareTo(b.rank));
    return entries.take(10).toList();
  }

  List<_SimulationRow> _simulateReviews(
    _DashboardMetrics metrics,
    List<_PriorityEntry> priorities,
  ) {
    final categories = <String, _SimulationRow>{};

    void ensureCategory(String name) {
      categories.putIfAbsent(
        name,
        () => _SimulationRow(
          category: name,
          driver: '',
          suggestedChange: '',
          confidence: 85,
        ),
      );
    }

    ensureCategory('Color');
    ensureCategory('Layout');
    ensureCategory('Motion');
    ensureCategory('Spacing');

    int penaltyForBadge(String badge) {
      switch (badge) {
        case 'GREEN':
          return 0;
        case 'ORANGE':
          return 10;
        case 'RED':
          return 20;
        default:
          return 15;
      }
    }

    categories['Color']!.confidence -= penaltyForBadge(metrics.fpsBadge);
    categories['Layout']!.confidence -= penaltyForBadge(metrics.memBadge);
    categories['Motion']!.confidence -= penaltyForBadge(metrics.stabilityBadge);
    categories['Spacing']!.confidence -= penaltyForBadge(metrics.warningsBadge);

    for (final priority in priorities) {
      final category = _mapAreaToCategory(priority.area);
      final row = categories[category];
      if (row == null) continue;
      row.driver = priority.driver;
      row.suggestedChange = priority.action;
      if (priority.impact.toLowerCase() == 'high') {
        row.confidence -= 5;
      } else if (priority.impact.toLowerCase() == 'medium') {
        row.confidence -= 3;
      } else {
        row.confidence -= 1;
      }
    }

    final rows = categories.values.toList();
    for (final row in rows) {
      row.confidence = row.confidence.clamp(0, 100);
      if (row.suggestedChange.isEmpty) {
        row.suggestedChange = 'No new changes required.';
      }
    }
    return rows;
  }

  String _mapAreaToCategory(String area) {
    final lower = area.toLowerCase();
    if (lower.contains('color') || lower.contains('consistency')) {
      return 'Color';
    }
    if (lower.contains('layout') || lower.contains('focus')) {
      return 'Layout';
    }
    if (lower.contains('motion') || lower.contains('performance')) {
      return 'Motion';
    }
    if (lower.contains('spacing') || lower.contains('ergonomics')) {
      return 'Spacing';
    }
    return 'Layout';
  }

  Future<void> writeSummary(_ReviewResult result) async {
    final buffer = StringBuffer()
      ..writeln('Design Review Simulation')
      ..writeln('Timestamp: ${result.timestamp.toIso8601String()}')
      ..writeln(
        'Average confidence: ${result.averageConfidence.toStringAsFixed(1)}%',
      )
      ..writeln()
      ..writeln('| Category | Confidence % | Driver | Suggested Change |')
      ..writeln('|----------|--------------|--------|------------------|');
    for (final row in result.simulations) {
      buffer.writeln(
        '| ${row.category} | ${row.confidence.toStringAsFixed(1)} '
        '| ${row.driver.isEmpty ? '-' : row.driver} '
        '| ${row.suggestedChange} |',
      );
    }

    await _writeReportsFile(
      'release/_reports/design_review_simulation.txt',
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_ReviewResult result) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.designReviewSimulated,
      'timestamp': result.timestamp.toIso8601String(),
      'confidence_avg': result.averageConfidence,
      'change_count': result.simulations.length,
      'duration_ms': result.durationMs,
    };
    final telemetryFile = File('release/_reports/telemetry.jsonl');
    try {
      await telemetryFile.writeAsString(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    } on FileSystemException {
      await _makeReportsWritable();
      await telemetryFile.writeAsString(
        '${jsonEncode(payload)}\n',
        mode: FileMode.append,
      );
    }
  }

  Future<void> restorePermissions() async {
    if (_reportsWritable) {
      await Process.run('chmod', ['-R', 'a-w', 'release/_reports']);
      _reportsWritable = false;
    }
  }

  Future<void> _writeReportsFile(String path, String contents) async {
    final file = File(path);
    try {
      await file.parent.create(recursive: true);
      await file.writeAsString(contents);
    } on FileSystemException {
      await _makeReportsWritable();
      await file.writeAsString(contents);
    }
  }

  Future<void> _makeReportsWritable() async {
    if (_reportsWritable) return;
    await Process.run('chmod', ['-R', 'u+w', 'release/_reports']);
    _reportsWritable = true;
  }
}

class _DashboardEntry {
  _DashboardEntry({required this.value, required this.badge});

  final String value;
  final String badge;
}

class _DashboardMetrics {
  _DashboardMetrics({
    required this.fpsBadge,
    required this.memBadge,
    required this.stabilityBadge,
    required this.warningsBadge,
    required this.avgFps,
  });

  final String fpsBadge;
  final String memBadge;
  final String stabilityBadge;
  final String warningsBadge;
  final double avgFps;
}

class _PriorityEntry {
  _PriorityEntry({
    required this.rank,
    required this.area,
    required this.impact,
    required this.driver,
    required this.action,
  });

  final int rank;
  final String area;
  final String impact;
  final String driver;
  final String action;
}

class _SimulationRow {
  _SimulationRow({
    required this.category,
    required this.driver,
    required this.suggestedChange,
    required this.confidence,
  });

  final String category;
  String driver;
  String suggestedChange;
  double confidence;
}

class _ReviewResult {
  _ReviewResult({
    required this.timestamp,
    required this.simulations,
    required this.averageConfidence,
    required this.durationMs,
  });

  final DateTime timestamp;
  final List<_SimulationRow> simulations;
  final double averageConfidence;
  final int durationMs;
}
