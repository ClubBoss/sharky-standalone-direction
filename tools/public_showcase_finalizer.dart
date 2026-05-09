import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final finalizer = _PublicShowcaseFinalizer();
  try {
    final overview = await finalizer.buildOverview();
    await finalizer.writeOverview(overview);
    await finalizer.emitTelemetry(overview);
  } finally {
    await finalizer.restorePermissions();
  }
}

class _PublicShowcaseFinalizer {
  bool _reportsWritable = false;

  Future<_ShowcaseOverview> buildOverview() async {
    final watch = Stopwatch()..start();
    final dashboard = await _parseDashboard();
    final review = await _parseDesignReview();
    final preview = await _parseVisualPreview();
    watch.stop();

    return _ShowcaseOverview(
      timestamp: DateTime.now().toUtc(),
      avgFps: dashboard.avgFps,
      stability: dashboard.stabilityScore,
      confidenceAvg: review.averageConfidence,
      dashboardBadge: dashboard.stabilityBadge,
      keyVisuals: preview,
      firstReviewRow: review.rows.isNotEmpty ? review.rows.first : null,
      durationMs: watch.elapsedMilliseconds,
    );
  }

  Future<_DashboardStats> _parseDashboard() async {
    final file = File('release/_reports/ux_dashboard_summary.txt');
    if (!file.existsSync()) {
      throw StateError('ux_dashboard_summary.txt not found.');
    }
    final lines = await file.readAsLines();
    double? avgFps;
    double? stability;
    String stabilityBadge = 'UNKNOWN';
    for (final line in lines) {
      if (!line.startsWith('|')) continue;
      final cells = line.split('|').map((c) => c.trim()).toList();
      if (cells.length < 5 || cells[1] == 'Metric') continue;
      final metric = cells[1];
      if (metric == 'Avg FPS') {
        avgFps = double.tryParse(cells[2]);
      } else if (metric == 'Stability') {
        stability = double.tryParse(cells[2]);
        stabilityBadge = cells[3];
      }
    }
    if (avgFps == null || stability == null) {
      throw StateError('Missing metrics in ux_dashboard_summary.txt');
    }
    return _DashboardStats(
      avgFps: avgFps,
      stabilityScore: stability,
      stabilityBadge: stabilityBadge,
    );
  }

  Future<_ReviewSummary> _parseDesignReview() async {
    final file = File('release/_reports/design_review_simulation.txt');
    if (!file.existsSync()) {
      throw StateError('design_review_simulation.txt not found.');
    }
    final lines = await file.readAsLines();
    double? confidenceAvg;
    final rows = <_ReviewRow>[];
    for (final line in lines) {
      if (line.startsWith('Average confidence:')) {
        final value = line.split(':').last.trim().replaceFirst('%', '');
        confidenceAvg = double.tryParse(value);
      } else if (line.startsWith('|')) {
        final parts = line.split('|').map((p) => p.trim()).toList();
        if (parts.length < 5 ||
            parts[1] == 'Category' ||
            parts[1].startsWith('----')) {
          continue;
        }
        rows.add(
          _ReviewRow(
            category: parts[1],
            confidence: parts[2],
            driver: parts[3],
            change: parts[4],
          ),
        );
      }
    }
    if (confidenceAvg == null) {
      throw StateError('design_review_simulation.txt missing confidence line.');
    }
    return _ReviewSummary(averageConfidence: confidenceAvg, rows: rows);
  }

  Future<List<String>> _parseVisualPreview() async {
    final file = File('release/_reports/visual_iteration_preview.md');
    if (!file.existsSync()) {
      throw StateError('visual_iteration_preview.md not found.');
    }
    final lines = await file.readAsLines();
    final highlights = <String>[];
    for (final line in lines) {
      if (line.startsWith('### ')) {
        highlights.add(line.replaceFirst('### ', '').trim());
      }
      if (highlights.length >= 3) break;
    }
    return highlights;
  }

  Future<void> writeOverview(_ShowcaseOverview overview) async {
    final buffer = StringBuffer()
      ..writeln('Public Showcase Final Overview')
      ..writeln('Timestamp: ${overview.timestamp.toIso8601String()}')
      ..writeln()
      ..writeln('## UX Metrics')
      ..writeln('| Metric | Value |')
      ..writeln('|--------|-------|')
      ..writeln('| Avg FPS | ${overview.avgFps.toStringAsFixed(2)} |')
      ..writeln(
        '| Stability | ${overview.stability.toStringAsFixed(3)} '
        '[${overview.dashboardBadge}] |',
      )
      ..writeln(
        '| Review Confidence | ${overview.confidenceAvg.toStringAsFixed(1)}% |',
      )
      ..writeln()
      ..writeln('## Design Review Highlights');

    if (overview.firstReviewRow != null) {
      buffer
        ..writeln('| Category | Confidence | Driver | Suggested Change |')
        ..writeln('|----------|------------|--------|------------------|')
        ..writeln(
          '| ${overview.firstReviewRow!.category} '
          '| ${overview.firstReviewRow!.confidence} '
          '| ${overview.firstReviewRow!.driver.isEmpty ? '-' : overview.firstReviewRow!.driver} '
          '| ${overview.firstReviewRow!.change} |',
        );
    } else {
      buffer.writeln('- No review rows available.');
    }

    buffer
      ..writeln()
      ..writeln('## Visual Iteration Sneak Peek');
    if (overview.keyVisuals.isEmpty) {
      buffer.writeln('- No iteration highlights recorded.');
    } else {
      for (final visual in overview.keyVisuals) {
        buffer.writeln('- $visual');
      }
    }

    await _writeReportsFile(
      'release/_reports/public_showcase_final.txt',
      buffer.toString(),
    );
  }

  Future<void> emitTelemetry(_ShowcaseOverview overview) async {
    final payload = <String, Object>{
      'event': TelemetryEvents.publicShowcaseFinalized,
      'timestamp': overview.timestamp.toIso8601String(),
      'fps': overview.avgFps,
      'stability': overview.stability,
      'confidence_avg': overview.confidenceAvg,
      'duration_ms': overview.durationMs,
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

class _DashboardStats {
  _DashboardStats({
    required this.avgFps,
    required this.stabilityScore,
    required this.stabilityBadge,
  });

  final double avgFps;
  final double stabilityScore;
  final String stabilityBadge;
}

class _ReviewSummary {
  _ReviewSummary({required this.averageConfidence, required this.rows});

  final double averageConfidence;
  final List<_ReviewRow> rows;
}

class _ReviewRow {
  _ReviewRow({
    required this.category,
    required this.confidence,
    required this.driver,
    required this.change,
  });

  final String category;
  final String confidence;
  final String driver;
  final String change;
}

class _ShowcaseOverview {
  _ShowcaseOverview({
    required this.timestamp,
    required this.avgFps,
    required this.stability,
    required this.confidenceAvg,
    required this.dashboardBadge,
    required this.keyVisuals,
    required this.firstReviewRow,
    required this.durationMs,
  });

  final DateTime timestamp;
  final double avgFps;
  final double stability;
  final double confidenceAvg;
  final String dashboardBadge;
  final List<String> keyVisuals;
  final _ReviewRow? firstReviewRow;
  final int durationMs;
}
