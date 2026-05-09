import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:poker_analyzer/services/monetization_auto_balancer.dart';
import 'package:poker_analyzer/services/chip_flow_balancer.dart';

Future<void> main(List<String> args) async {
  final config = _Config.parse(args);

  final readinessResult = await _runTool('tools/full_readiness_audit.dart', [
    '--embedded',
  ]);
  final readinessSummary = _readJson(
    'tools/_reports/full_readiness_summary.json',
  );
  final readinessScore =
      (readinessSummary['readiness_score'] as num?)?.toDouble() ?? 0.0;

  final advisorResult = await _runTool('tools/ai_advisor_report.dart', [
    '--summary',
  ]);
  final advisorSummary = _readJson('tools/_reports/ai_advisor_summary.json');
  final advisorMetrics =
      advisorSummary['metrics'] as Map<String, dynamic>? ?? {};
  final confidenceBucket =
      advisorMetrics['confidence'] as Map<String, dynamic>? ?? {};
  final advisorScore = (confidenceBucket['current'] as num?)?.toDouble() ?? 0.0;

  final feedbackResult = await _runTool('tools/public_beta_feedback.dart', [
    '--summary',
  ]);
  final feedbackSummary = _readJson(
    'tools/_reports/public_beta_feedback_summary.json',
  );
  final aggregates =
      feedbackSummary['aggregates'] as Map<String, dynamic>? ?? {};
  final feedbackCount = (aggregates['records_analyzed'] as num?)?.toInt() ?? 0;

  final telemetryResult = await _runTool('tools/telemetry_unifier.dart', []);
  final unifiedTelemetry = _readJson(
    'tools/_reports/unified_telemetry_summary.json',
  );
  final unifiedDerived =
      unifiedTelemetry['derived_metrics'] as Map<String, dynamic>? ?? {};
  final unifiedFeeds = unifiedTelemetry['feeds_merged'] as num? ?? 0;

  // Regenerate public beta landing and metrics (optimized with caching)
  final betaResult = await _runTool('tools/public_beta_landing_v2.dart', [
    '--stats-board',
  ]);

  // Stage G9B: Run monetization projection and auto-balance economy
  final monetizationResult = await _runTool(
    'tools/monetization_balance_heuristic.dart',
    [],
  );
  Map<String, Object> autoBalanceSummary = const {};
  try {
    autoBalanceSummary = await MonetizationAutoBalancer.instance.recalibrate();
  } catch (e) {
    stderr.writeln('[WARN] Monetization auto-balance failed: $e');
  }

  Map<String, Object> chipBalanceSummary = const {};
  try {
    chipBalanceSummary = await ChipFlowBalancer.instance.recalibrate();
  } catch (e) {
    stderr.writeln('[WARN] Chip flow rebalance failed: $e');
  }

  final banner =
      'QA Release Summary: ${readinessScore.toStringAsFixed(1)}% | Advisor ${advisorScore.toStringAsFixed(2)} | Feedback $feedbackCount';

  if (config.summary) {
    stdout.writeln(banner);
    if (betaResult == 0) {
      stdout.writeln('Beta metrics dashboard: UPDATED ✅');
    }
  }

  if (config.autoSync && betaResult == 0) {
    final copied = await _autoSyncBetaDashboard();
    if (copied != null) {
      stdout.writeln('Auto-sync complete [OK] ($copied)');
    }
  }

  final output = <String, dynamic>{
    'generated_at': DateTime.now().toUtc().toIso8601String(),
    'readiness': {'score': readinessScore, 'exit_code': readinessResult},
    'advisor': {'confidence_score': advisorScore, 'exit_code': advisorResult},
    'feedback': {
      'records_analyzed': feedbackCount,
      'exit_code': feedbackResult,
    },
    'beta_dashboard': {'exit_code': betaResult},
    'unified_telemetry': {
      'exit_code': telemetryResult,
      'feeds_merged': unifiedFeeds,
      'derived_metrics': unifiedDerived,
    },
    'monetization': {
      'projection_exit_code': monetizationResult,
      'auto_balance': autoBalanceSummary,
    },
    'chip_flow_balance': chipBalanceSummary,
    'banner': banner,
  };

  final reportFile = File('tools/_reports/qa_release_summary.json');
  reportFile.parent.createSync(recursive: true);
  reportFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(output),
  );

  if (readinessResult != 0 ||
      advisorResult != 0 ||
      feedbackResult != 0 ||
      telemetryResult != 0 ||
      monetizationResult != 0) {
    exitCode = 1;
  }
}

class _Config {
  _Config({required this.summary, required this.autoSync});

  final bool summary;
  final bool autoSync;

  static _Config parse(List<String> args) {
    var summary = false;
    var autoSync = false;
    for (final arg in args) {
      switch (arg) {
        case '--summary':
          summary = true;
          break;
        case '--auto':
        case '--ci':
          summary = true;
          break;
        case '--auto-sync':
          autoSync = true;
          break;
      }
    }
    return _Config(summary: summary, autoSync: autoSync);
  }
}

Future<int> _runTool(String script, List<String> arguments) async {
  final proc = await Process.run('dart', ['run', script, ...arguments]);
  if (proc.stdout is String && (proc.stdout as String).isNotEmpty) {
    stdout.write(proc.stdout);
  }
  if (proc.stderr is String && (proc.stderr as String).isNotEmpty) {
    stderr.write(proc.stderr);
  }
  return proc.exitCode;
}

Map<String, dynamic> _readJson(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    return const {};
  }
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

Future<int?> _autoSyncBetaDashboard() async {
  final source = Directory('release/public_beta_v2');
  if (!source.existsSync()) {
    return null;
  }
  final destination = Directory('release/public_beta_sync');
  var copied = 0;
  for (final entity in source.listSync(recursive: true)) {
    if (entity is File) {
      final relativePath = p.relative(entity.path, from: source.path);
      final target = File(p.join(destination.path, relativePath));
      target.parent.createSync(recursive: true);
      entity.copySync(target.path);
      copied += 1;
    }
  }
  return copied;
}
