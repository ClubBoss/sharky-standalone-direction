import 'dart:convert';
import 'dart:io';

// Smart Regression Baseline & Anomaly Detection
// Compares current health_dashboard.json to a baseline and flags regressions.
// Usage:
//   dart run tools/health_regression_analyzer.dart [--baseline <path>] [--save-as-baseline]
// Outputs:
//   - ASCII summary to stdout
//   - health_regression.json with diffs and status

Future<void> main(List<String> args) async {
  final opts = _parseArgs(args);
  final currentFile = File('health_dashboard.json');
  final baselinePath =
      opts['baseline'] as String? ?? 'baseline/health_dashboard_prev.json';
  final baselineFile = File(baselinePath);
  final saveAsBaseline = (opts['saveAsBaseline'] as bool?) ?? false;

  if (!await currentFile.exists()) {
    stderr.writeln(
      'Error: health_dashboard.json not found. Run: dart run tools/health_dashboard.dart --ci',
    );
    exitCode = 2;
    return;
  }

  final current =
      jsonDecode(await currentFile.readAsString()) as Map<String, dynamic>;
  Map<String, dynamic>? baseline;
  if (await baselineFile.exists()) {
    baseline =
        jsonDecode(await baselineFile.readAsString()) as Map<String, dynamic>;
  }

  final result = _analyze(current, baseline, baselinePath);

  // Print ASCII summary
  _printAscii(result);

  // Write JSON report
  final reportFile = File('health_regression.json');
  await reportFile.writeAsString(jsonEncode(result));

  // Optionally save current as baseline
  if (saveAsBaseline) {
    final dir = baselineFile.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await currentFile.copy(baselineFile.path);
  }

  // Exit with non-zero on failure
  if (result['status'] == 'fail') {
    exitCode = 1;
  } else {
    exitCode = 0;
  }
}

Map<String, Object?> _parseArgs(List<String> args) {
  final map = <String, Object?>{};
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (a == '--baseline' && i + 1 < args.length) {
      map['baseline'] = args[++i];
    } else if (a == '--save-as-baseline') {
      map['saveAsBaseline'] = true;
    }
  }
  return map;
}

Map<String, Object?> _analyze(
  Map<String, dynamic> curr,
  Map<String, dynamic>? prev,
  String baselinePath,
) {
  final now = DateTime.now().toUtc().toIso8601String();

  // Extract metrics helper
  T? get<T>(Map obj, List<String> path) {
    dynamic v = obj;
    for (final key in path) {
      if (v is Map && v.containsKey(key)) {
        v = v[key];
      } else {
        return null;
      }
    }
    return v is T ? v : null;
  }

  // Current metrics
  final currCoverage =
      (get<num>(curr, ['coverage', 'percent'])?.toDouble()) ?? 0.0;
  final currTestsFailed = (get<num>(curr, ['tests', 'failed'])?.toInt()) ?? 0;
  final currTestsPassed = (get<num>(curr, ['tests', 'passed'])?.toInt()) ?? 0;
  final currAnalyzerErrors =
      (get<num>(curr, ['analyze', 'errors'])?.toInt()) ?? 0;
  final currContentValid = (get<num>(curr, [
    'content_validation',
    'valid',
  ])?.toInt());
  final currContentTotal = (get<num>(curr, [
    'content_validation',
    'total',
  ])?.toInt());
  final currFps = _extractAvgFps(curr);

  // Previous metrics (may be null)
  final prevCoverage = prev != null
      ? (get<num>(prev, ['coverage', 'percent'])?.toDouble())
      : null;
  final prevTestsFailed = prev != null
      ? (get<num>(prev, ['tests', 'failed'])?.toInt())
      : null;
  final prevTestsPassed = prev != null
      ? (get<num>(prev, ['tests', 'passed'])?.toInt())
      : null;
  final prevAnalyzerErrors = prev != null
      ? (get<num>(prev, ['analyze', 'errors'])?.toInt())
      : null;
  final prevContentValid = prev != null
      ? (get<num>(prev, ['content_validation', 'valid'])?.toInt())
      : null;
  final prevContentTotal = prev != null
      ? (get<num>(prev, ['content_validation', 'total'])?.toInt())
      : null;
  final prevFps = prev != null ? _extractAvgFps(prev) : null;

  // Thresholds
  const coverageDropThreshold = 2.0; // percentage points
  const fpsDropPctThreshold = 0.05; // 5%

  final warnings = <String>[];
  final errors = <String>[];

  // Checks
  if (currAnalyzerErrors > 0) {
    errors.add('Analyzer errors > 0 ($currAnalyzerErrors)');
  }
  if (currTestsFailed > 0) {
    errors.add('Test failures > 0 ($currTestsFailed)');
  }
  if (prevCoverage != null) {
    final drop = prevCoverage - currCoverage;
    if (drop > coverageDropThreshold) {
      warnings.add(
        'Coverage drop ${drop.toStringAsFixed(2)}pp (${prevCoverage.toStringAsFixed(2)}% -> ${currCoverage.toStringAsFixed(2)}%)',
      );
    }
  }
  if (prevFps != null && currFps != null && prevFps > 0) {
    final dropPct = (prevFps - currFps) / prevFps;
    if (dropPct > fpsDropPctThreshold) {
      warnings.add(
        'FPS drop ${(dropPct * 100).toStringAsFixed(1)}% (${prevFps.toStringAsFixed(1)} -> ${currFps.toStringAsFixed(1)})',
      );
    }
  }

  // Compose metrics diff
  Map<String, Object?> metricReport(
    String name,
    num? prevVal,
    num? currVal, {
    bool percent = false,
  }) {
    final diff = (prevVal != null && currVal != null)
        ? (currVal - prevVal)
        : null;
    final pct = (percent && prevVal != null && prevVal != 0 && currVal != null)
        ? ((currVal - prevVal) / prevVal * 100)
        : null;
    return {
      'name': name,
      'previous': prevVal,
      'current': currVal,
      'delta': diff,
      'percentChange': pct,
    };
  }

  final metrics = <Map<String, Object?>>[];
  metrics.add(
    metricReport(
      'coverage.percent',
      prevCoverage,
      currCoverage,
      percent: false,
    ),
  );
  metrics.add(
    metricReport(
      'tests.passed',
      prevTestsPassed,
      currTestsPassed,
      percent: false,
    ),
  );
  metrics.add(
    metricReport(
      'tests.failed',
      prevTestsFailed,
      currTestsFailed,
      percent: false,
    ),
  );
  metrics.add(
    metricReport(
      'analyze.errors',
      prevAnalyzerErrors,
      currAnalyzerErrors,
      percent: false,
    ),
  );
  if (currFps != null || prevFps != null) {
    metrics.add(
      metricReport('ui_performance.avgFps', prevFps, currFps, percent: true),
    );
  }
  if (currContentValid != null || prevContentValid != null) {
    // Report valid count and total as separate metrics
    metrics.add(
      metricReport(
        'content_validation.valid',
        prevContentValid,
        currContentValid,
        percent: false,
      ),
    );
    metrics.add(
      metricReport(
        'content_validation.total',
        prevContentTotal,
        currContentTotal,
        percent: false,
      ),
    );
  }

  final status = errors.isNotEmpty
      ? 'fail'
      : (warnings.isNotEmpty
            ? 'warn'
            : (prev == null ? 'no-baseline' : 'pass'));

  return {
    'timestamp': now,
    'baseline': baselinePath,
    'status': status,
    'errors': errors,
    'warnings': warnings,
    'metrics': metrics,
  };
}

double? _extractAvgFps(Map<String, dynamic> data) {
  // Try direct path first
  final direct = (data['ui_performance'] is Map)
      ? (data['ui_performance']['avgFps'] as num?)
      : null;
  if (direct != null) return direct.toDouble();

  // Try screens map average: ui_performance.screens[*].avgFps
  final perf = data['ui_performance'];
  if (perf is Map) {
    final screens = perf['screens'];
    if (screens is Map) {
      var sum = 0.0;
      var count = 0;
      for (final v in screens.values) {
        if (v is Map) {
          final fps = v['avgFps'];
          if (fps is num) {
            sum += fps.toDouble();
            count++;
          }
        }
      }
      if (count > 0) return sum / count;
    }
  }
  return null;
}

void _printAscii(Map<String, Object?> report) {
  final status = report['status'];
  final errors = (report['errors'] as List).cast<String>();
  final warnings = (report['warnings'] as List).cast<String>();
  final metrics = (report['metrics'] as List).cast<Map>();

  stdout.writeln('==============================');
  stdout.writeln(' Health Regression Comparison');
  stdout.writeln('==============================');
  stdout.writeln('Baseline: ${report['baseline']}');
  stdout.writeln(
    'Status  : ${status == 'pass'
        ? '✅ All stable'
        : status == 'warn'
        ? '⚠️ Regression detected'
        : status == 'no-baseline'
        ? 'ℹ️ No baseline; nothing to compare'
        : '❌ Fail'}',
  );
  stdout.writeln('');

  for (final m in metrics) {
    final name = m['name'];
    final prev = m['previous'];
    final curr = m['current'];
    final delta = m['delta'];
    final pct = m['percentChange'];
    final deltaStr = delta == null
        ? ''
        : (delta is num && delta >= 0 ? '+$delta' : '$delta');
    final pctStr = pct == null ? '' : ' (${pct.toStringAsFixed(1)}%)';
    stdout.writeln(' - $name: $prev -> $curr $deltaStr$pctStr');
  }

  if (errors.isNotEmpty) {
    stdout.writeln('\nErrors:');
    for (final e in errors) {
      stdout.writeln(' • $e');
    }
  }
  if (warnings.isNotEmpty) {
    stdout.writeln('\nWarnings:');
    for (final w in warnings) {
      stdout.writeln(' • $w');
    }
  }
}
