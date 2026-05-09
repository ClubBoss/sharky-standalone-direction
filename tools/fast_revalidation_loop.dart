import 'dart:convert';
import 'dart:io';

/// Fast Revalidation Loop
///
/// Executes the core content audits and smoke tests sequentially to quickly
/// validate semantic flow health after automated fixes. Results are captured in
/// `tools/_reports/fast_revalidation_summary.json` for dashboard consumption.
Future<void> main(List<String> args) async {
  final results = <String, dynamic>{};
  final missingTests = _detectMissingTests();

  results['missing_tests'] = missingTests;

  final flow = _runStep('content_flow_audit', [
    'dart',
    'run',
    'tools/content_flow_audit.dart',
  ], reportPath: 'tools/_reports/content_flow_audit.json');
  results['content_flow_audit'] = flow;

  final semantic = _runStep(
    'content_semantic_audit',
    ['dart', 'run', 'tools/content_semantic_audit.dart'],
    reportPath: 'tools/_reports/content_semantic_audit.json',
  );
  results['content_semantic_audit'] = semantic;

  final autofix = _runStep(
    'content_semantic_autofix',
    ['dart', 'run', 'tools/content_semantic_autofix.dart'],
    reportPath: 'tools/_reports/content_semantic_autofix.json',
  );
  results['content_semantic_autofix'] = autofix;

  final publisher = _runStep(
    'content_ci_auto_publisher',
    ['dart', 'run', 'tools/content_ci_auto_publisher.dart'],
    reportPath: 'tools/_reports/content_publish_summary.json',
  );
  results['content_ci_auto_publisher'] = publisher;

  final releasePack = _runStep('release_packager', [
    'dart',
    'run',
    'tools/release_packager.dart',
  ], reportPath: 'release/version.json');
  results['release_packager'] = releasePack;

  final smoke = _runStep('smoke_tests', [
    'dart',
    'test',
    '--plain-name',
    'smoke',
  ]);
  smoke['missing_files'] = missingTests;
  results['smoke_tests'] = smoke;

  final pass = _allPass([
    flow,
    semantic,
    autofix,
    publisher,
    releasePack,
    smoke,
  ]);
  final semanticPassPct = _semanticPassRate(semantic);
  final coveragePct = _coveragePercentage(flow);

  final summary = <String, dynamic>{
    'pass': pass,
    'flow_pass': flow['pass'],
    'semantic_pass': semantic['pass'],
    'autofix_pass': autofix['pass'],
    'publisher_pass': publisher['pass'],
    'release_pack_pass': releasePack['pass'],
    'smoke_pass': smoke['pass'],
    'semantic_pass_pct': semanticPassPct,
    'coverage_pct': coveragePct,
    'missing_tests': missingTests,
    'timestamp': DateTime.now().toIso8601String(),
    'details': results,
  };

  final status = pass ? 'PASS (✓)' : 'FAIL (✗)';
  final publisherStatus = publisher['pass'] == true ? 'PASS' : 'FAIL';
  final releaseStatus = releasePack['pass'] == true ? 'PASS' : 'FAIL';
  stdout.writeln(
    'Fast Revalidation Loop: $status • coverage ${coveragePct.toStringAsFixed(1)}% • semantic ${semanticPassPct.toStringAsFixed(1)}% • publisher $publisherStatus • release $releaseStatus • missing tests ${missingTests.length}',
  );

  _writeSummary(summary);
}

Map<String, dynamic> _runStep(
  String name,
  List<String> command, {
  String? reportPath,
}) {
  final result = Process.runSync(
    command.first,
    command.sublist(1),
    runInShell: true,
  );
  final stdoutStr = (result.stdout is String)
      ? result.stdout as String
      : utf8.decode(result.stdout as List<int>);
  final stderrStr = (result.stderr is String)
      ? result.stderr as String
      : utf8.decode(result.stderr as List<int>);

  final pass = result.exitCode == 0;
  final report = reportPath == null ? null : _readJson(reportPath);
  return {
    'command': command.join(' '),
    'exit_code': result.exitCode,
    'stdout': stdoutStr.trim(),
    'stderr': stderrStr.trim(),
    'pass': pass,
    if (report != null) 'report': report,
  };
}

List<String> _detectMissingTests() {
  const candidates = [
    'test/guard_single_site_test.dart',
    'test/mvs_player_smoke_test.dart',
    'test/spotkind_integrity_smoke_test.dart',
  ];
  final missing = <String>[];
  for (final path in candidates) {
    if (!File(path).existsSync()) {
      missing.add(path);
    }
  }
  return missing;
}

bool _allPass(List<Map<String, dynamic>> steps) {
  for (final step in steps) {
    if (step['pass'] != true) return false;
  }
  return true;
}

double _semanticPassRate(Map<String, dynamic> semantic) {
  final report = semantic['report'];
  if (report is Map<String, dynamic>) {
    final aligned = (report['aligned_packs'] as num?)?.toDouble();
    final total = (report['packs'] as num?)?.toDouble();
    if (aligned != null && total != null && total > 0) {
      return (aligned / total) * 100.0;
    }
    if (report['pass'] == true) return 100.0;
  }
  return semantic['pass'] == true ? 100.0 : 0.0;
}

double _coveragePercentage(Map<String, dynamic> flow) {
  final report = flow['report'];
  if (report is Map<String, dynamic>) {
    final coverage = report['coverage'];
    if (coverage is Map<String, dynamic>) {
      final values = coverage.values
          .whereType<num>()
          .map((value) => value.toDouble())
          .toList();
      if (values.isNotEmpty) {
        return values.reduce((a, b) => a + b) / values.length;
      }
    }
  }
  return 0.0;
}

void _writeSummary(Map<String, dynamic> summary) {
  final file = File('tools/_reports/fast_revalidation_summary.json');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(summary));
}

Map<String, dynamic>? _readJson(String path) {
  final file = File(path);
  if (!file.existsSync()) return null;
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } catch (_) {
    return null;
  }
  return null;
}
