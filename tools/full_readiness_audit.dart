import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final embedded = args.contains('--embedded');
  final qaOnly = args.contains('--qa-only');

  if (qaOnly) {
    final qaSummary = await _runFinalQaSweep(embedded: embedded);
    _printQaSection(qaSummary);
    if (qaSummary['pass'] != true) {
      exitCode = 1;
    }
    return;
  }
  final summary = <String, Object?>{};
  final details = <String, Object?>{};
  final recommendations = <String>[];

  final analyzer = await _runCommand(['dart', 'analyze']);
  details['analyzer'] = analyzer;
  final analyzerPass = analyzer.exitCode == 0;
  if (!analyzerPass) {
    recommendations.add('Fix analyzer issues before release.');
  }

  final tests = await _runCommand(['dart', 'test', '--reporter=compact']);
  details['tests'] = tests;
  final testsPass = tests.exitCode == 0;
  if (!testsPass) {
    recommendations.add('Resolve failing tests.');
  }

  _CommandResult dashboard;
  bool dashboardPass;
  if (embedded) {
    dashboard = const _CommandResult(0, 'embedded', '');
    dashboardPass = true;
  } else {
    dashboard = await _runCommand([
      'dart',
      'run',
      'tools/health_dashboard.dart',
      '--fast',
    ]);
    dashboardPass = dashboard.exitCode == 0;
    if (!dashboardPass) {
      recommendations.add('Review health dashboard failures.');
    }
  }
  details['dashboard'] = dashboard;

  final flow = await _runCommand([
    'dart',
    'run',
    'tools/content_flow_audit.dart',
  ]);
  details['content_flow'] = flow;
  final flowReport = _readJson('tools/_reports/content_flow_audit.json');
  final flowPass = flowReport['pass'] == true;
  if (!flowPass) {
    recommendations.add('Address content flow anomalies.');
  }

  final semantic = await _runCommand([
    'dart',
    'run',
    'tools/content_semantic_audit.dart',
  ]);
  details['content_semantic'] = semantic;
  final semanticReport = _readJson(
    'tools/_reports/content_semantic_audit.json',
  );
  final semanticPass = semanticReport['pass'] == true;
  if (!semanticPass) {
    recommendations.add('Review semantic audit warnings.');
  }

  final adaptive = await _runCommand([
    'dart',
    'run',
    'lib/services/adaptive_loop_v3_engine.dart',
  ]);
  details['adaptive_loop_v3'] = adaptive;
  Map<String, dynamic> adaptiveReport = const {};
  if (adaptive.stdout.isNotEmpty) {
    try {
      adaptiveReport = jsonDecode(adaptive.stdout) as Map<String, dynamic>;
    } catch (_) {}
  }
  final adaptiveScore =
      (adaptiveReport['meta_feedback_score'] as num?)?.toDouble() ?? 0.0;

  final release = await _runCommand([
    'dart',
    'run',
    'tools/release_packager.dart',
  ]);
  details['release_pack'] = release;
  Map<String, dynamic> releaseData = const {};
  if (release.stdout.isNotEmpty) {
    try {
      releaseData = jsonDecode(release.stdout) as Map<String, dynamic>;
    } catch (_) {}
  }
  final releasePass = releaseData['status'] == 'pass';
  if (!releasePass) {
    recommendations.add('Fix release packaging errors.');
  }

  final designSnapshot = await _runCommand([
    'dart',
    'run',
    'tools/design_snapshot_refresh.dart',
    '--auto',
  ]);
  details['design_snapshot'] = designSnapshot;
  final designPass = designSnapshot.exitCode == 0;
  if (!designPass) {
    recommendations.add('Designer snapshot auto sync failed.');
  }

  final readinessScore = _computeScore(
    analyzerPass: analyzerPass,
    testsPass: testsPass,
    dashboardPass: dashboardPass,
    contentFlowPass: flowPass,
    contentSemanticPass: semanticPass,
    adaptiveScore: adaptiveScore,
    releasePass: releasePass,
    designPass: designPass,
  );

  final manifestUpdated = _updateManifestReadiness(releaseData, readinessScore);

  if (manifestUpdated) {
    final publicBeta = releaseData['public_beta'];
    if (publicBeta is Map<String, dynamic>) {
      publicBeta['readiness_score'] = readinessScore;
    }
  }

  Map<String, dynamic> landingReport = const {};

  summary
    ..['status'] = readinessScore >= 80 ? 'pass' : 'review'
    ..['analyzer_status'] = analyzerPass
    ..['test_status'] = testsPass
    ..['dashboard_status'] = dashboardPass
    ..['content_flow'] = flowReport
    ..['content_semantic'] = semanticReport
    ..['adaptive'] = adaptiveReport
    ..['release_package'] = releaseData
    ..['design_snapshot'] = designSnapshot.toJson()
    ..['landing_page'] = const {}
    ..['readiness_score'] = readinessScore
    ..['recommendations'] = recommendations
    ..['timestamp'] = DateTime.now().toUtc().toIso8601String();

  final summaryFile = File('tools/_reports/full_readiness_summary.json');
  await summaryFile.parent.create(recursive: true);
  await summaryFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(summary),
  );

  final landing = await _runCommand([
    'dart',
    'run',
    'tools/landing_page_generator.dart',
  ]);
  details['landing_page'] = landing;
  if (landing.stdout.isNotEmpty) {
    landingReport = _parseJsonLine(landing.stdout) ?? const {};
  }
  final landingPass = landing.exitCode == 0;
  if (!landingPass) {
    recommendations.add('Landing page generation failed.');
  }

  summary['landing_page'] = landingReport;

  if (_refreshPublicLanding(releaseData, landingReport)) {
    final publicBeta = releaseData['public_beta'];
    if (publicBeta is Map<String, dynamic>) {
      publicBeta['landing_index'] =
          landingReport['index'] ?? publicBeta['landing_index'];
      publicBeta['landing_metadata'] =
          landingReport['metadata'] ?? publicBeta['landing_metadata'];
    }
  }

  final qaSummary = await _runFinalQaSweep(embedded: embedded);
  summary['final_qa'] = qaSummary;
  if (qaSummary['pass'] != true) {
    recommendations.add('QA sweep reported issues.');
  }

  await summaryFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(summary),
  );

  _printAscii(summary, readinessScore, recommendations);
}

class _CommandResult {
  const _CommandResult(this.exitCode, this.stdout, this.stderr);

  final int exitCode;
  final String stdout;
  final String stderr;

  Map<String, Object?> toJson() => {
    'exit_code': exitCode,
    'stdout': stdout,
    'stderr': stderr,
  };
}

Future<_CommandResult> _runCommand(List<String> command) async {
  final result = await Process.run(
    command.first,
    command.sublist(1),
    runInShell: true,
  );
  return _CommandResult(
    result.exitCode,
    (result.stdout ?? '').toString().trim(),
    (result.stderr ?? '').toString().trim(),
  );
}

Map<String, dynamic> _readJson(String path) {
  final file = File(path);
  if (!file.existsSync()) return const {};
  try {
    final data = jsonDecode(file.readAsStringSync());
    if (data is Map<String, dynamic>) {
      return data;
    }
  } catch (_) {}
  return const {};
}

Map<String, dynamic>? _parseJsonLine(String stdout) {
  final lines = stdout.trim().split('\n').reversed;
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final data = jsonDecode(trimmed);
        if (data is Map<String, dynamic>) {
          return data;
        }
      } catch (_) {}
    }
  }
  return null;
}

Future<Map<String, Object?>> _runFinalQaSweep({
  bool writeReport = true,
  bool embedded = false,
}) async {
  if (embedded) {
    final qa = <String, Object?>{
      'pass': true,
      'skipped': true,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'analyzer': const {'exit_code': 0, 'warnings': 0},
      'smoke_tests': const {
        'exit_code': 0,
        'tests': 0,
        'duration_seconds': 0,
        'avg_seconds': null,
      },
      'flutter_test': const {
        'exit_code': 0,
        'tests': 0,
        'duration_seconds': 0,
        'avg_seconds': null,
      },
      'dashboard': const {
        'exit_code': 0,
        'avg_fps': null,
        'frame_ms': null,
        'telemetry_pass': null,
        'telemetry_samples': 0,
      },
    };
    if (writeReport) {
      final qaFile = File('tools/_reports/final_qa_summary.json');
      qaFile.parent.createSync(recursive: true);
      qaFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(qa));
    }
    return qa;
  }

  final qa = <String, Object?>{};

  final analyzer = await _runCommand(['dart', 'analyze']);
  final analyzerWarnings = _countAnalyzerWarnings(analyzer.stdout);
  qa['analyzer'] = {
    'exit_code': analyzer.exitCode,
    'warnings': analyzerWarnings,
  };

  final smoke = await _runCommand([
    'dart',
    'test',
    '-r',
    'expanded',
    'test/guard_single_site_test.dart',
    'test/mvs_player_smoke_test.dart',
    'test/spotkind_integrity_smoke_test.dart',
  ]);
  final smokeMetrics = _parseTestSummary(smoke.stdout);
  smokeMetrics['exit_code'] = smoke.exitCode;
  qa['smoke_tests'] = smokeMetrics;

  final flutter = await _runCommand(['flutter', 'test']);
  final flutterMetrics = _parseTestSummary(flutter.stdout);
  flutterMetrics['exit_code'] = flutter.exitCode;
  qa['flutter_test'] = flutterMetrics;

  final dashboard = await _runCommand([
    'dart',
    'run',
    'tools/health_dashboard.dart',
    '--fast',
  ]);
  final dashboardMetrics = _parseDashboardMetrics(dashboard.stdout);
  dashboardMetrics['exit_code'] = dashboard.exitCode;
  qa['dashboard'] = dashboardMetrics;

  qa['pass'] =
      analyzer.exitCode == 0 &&
      smoke.exitCode == 0 &&
      flutter.exitCode == 0 &&
      dashboard.exitCode == 0;
  qa['timestamp'] = DateTime.now().toUtc().toIso8601String();

  if (writeReport) {
    final qaFile = File('tools/_reports/final_qa_summary.json');
    qaFile.parent.createSync(recursive: true);
    qaFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(qa));
  }

  return qa;
}

bool _refreshPublicLanding(
  Map<String, dynamic> releaseData,
  Map<String, dynamic> landingReport,
) {
  final publicBeta = releaseData['public_beta'];
  if (publicBeta is! Map<String, dynamic>) {
    return false;
  }
  final destIndexPath = publicBeta['landing_index'];
  final destMetaPath = publicBeta['landing_metadata'];
  final srcIndexPath = landingReport['index'] ?? 'release/landing/index.html';
  final srcMetaPath =
      landingReport['metadata'] ?? 'release/landing/metadata.json';

  var updated = false;

  if (srcIndexPath is String && destIndexPath is String) {
    final src = File(srcIndexPath);
    if (src.existsSync()) {
      File(destIndexPath).parent.createSync(recursive: true);
      src.copySync(destIndexPath);
      updated = true;
    }
  }

  if (srcMetaPath is String && destMetaPath is String) {
    final src = File(srcMetaPath);
    if (src.existsSync()) {
      File(destMetaPath).parent.createSync(recursive: true);
      src.copySync(destMetaPath);
      updated = true;
    }
  }

  return updated;
}

Map<String, Object?> _asMap(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return value.cast<String, Object?>();
  return <String, Object?>{};
}

double _computeScore({
  required bool analyzerPass,
  required bool testsPass,
  required bool dashboardPass,
  required bool contentFlowPass,
  required bool contentSemanticPass,
  required double adaptiveScore,
  required bool releasePass,
  required bool designPass,
}) {
  final adaptiveWeighted = adaptiveScore.clamp(0.0, 1.0) * 10.0;
  return (analyzerPass ? 20 : 0) +
      (testsPass ? 20 : 0) +
      (dashboardPass ? 15 : 0) +
      (contentFlowPass ? 15 : 0) +
      (contentSemanticPass ? 15 : 0) +
      (releasePass ? 5 : 0) +
      (designPass ? 5 : 0) +
      adaptiveWeighted;
}

bool _updateManifestReadiness(
  Map<String, dynamic> releaseData,
  double readinessScore,
) {
  final publicBeta = releaseData['public_beta'];
  if (publicBeta is! Map<String, dynamic>) {
    return false;
  }
  final manifestPath = publicBeta['manifest'];
  if (manifestPath is! String) {
    return false;
  }
  final manifestFile = File(manifestPath);
  if (!manifestFile.existsSync()) {
    return false;
  }
  try {
    final data = jsonDecode(manifestFile.readAsStringSync());
    if (data is! Map<String, dynamic>) {
      return false;
    }
    data['readiness_score'] = readinessScore;
    manifestFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(data),
    );
    return true;
  } catch (_) {
    return false;
  }
}

void _printAscii(
  Map<String, Object?> summary,
  double readinessScore,
  List<String> recommendations,
) {
  String statusLabel(bool pass) => pass ? 'PASS' : 'FAIL';
  final analyzerPass = summary['analyzer_status'] == true;
  final testsPass = summary['test_status'] == true;
  final dashboardPass = summary['dashboard_status'] == true;
  final contentFlowPass = (summary['content_flow'] as Map?)?['pass'] == true;
  final contentSemanticPass =
      (summary['content_semantic'] as Map?)?['pass'] == true;
  final releasePass = (summary['release_package'] as Map?)?['status'] == 'pass';
  final designPass = (summary['design_snapshot'] as Map?)?['exit_code'] == 0;
  final adaptiveScore =
      (summary['adaptive'] as Map?)?['meta_feedback_score'] ?? 0.0;

  stdout.writeln('================ Readiness Audit ================');
  stdout.writeln('Analyzer         : ${statusLabel(analyzerPass)}');
  stdout.writeln('Tests            : ${statusLabel(testsPass)}');
  stdout.writeln('Dashboard (--fast): ${statusLabel(dashboardPass)}');
  stdout.writeln('Content Flow     : ${statusLabel(contentFlowPass)}');
  stdout.writeln('Semantic Audit   : ${statusLabel(contentSemanticPass)}');
  stdout.writeln(
    'Adaptive Loop V3 : ${(adaptiveScore as num).toStringAsFixed(2)} meta',
  );
  stdout.writeln('Release Package  : ${statusLabel(releasePass)}');
  stdout.writeln('Design Snapshot  : ${statusLabel(designPass)}');
  _printQaSection(_asMap(summary['final_qa']));
  stdout.writeln('--------------------------------------------------');
  stdout.writeln(
    'Release Readiness Score: ${readinessScore.toStringAsFixed(1)} / 100',
  );
  if (recommendations.isEmpty) {
    stdout.writeln('All systems green for Beta release.');
  } else {
    stdout.writeln('Recommendations:');
    for (final rec in recommendations) {
      stdout.writeln('- $rec');
    }
  }
}

void _printQaSection(Map<String, Object?> qa) {
  if (qa.isEmpty) return;
  if (qa['skipped'] == true) {
    stdout.writeln('Final QA & UX Sweep: SKIPPED (embedded mode)');
    return;
  }
  final pass = qa['pass'] == true;
  stdout.writeln('Final QA & UX Sweep: ${pass ? 'PASS ✅' : 'FAIL ❌'}');
  final analyzer = _asMap(qa['analyzer']);
  final warnings = (analyzer['warnings'] as num?)?.toInt() ?? 0;
  stdout.writeln('  Analyzer warnings: $warnings');

  final smoke = _asMap(qa['smoke_tests']);
  if (smoke.isNotEmpty) {
    final duration = _formatDuration(smoke['duration_seconds'] as int?);
    final tests = (smoke['tests'] as num?)?.toInt() ?? 0;
    stdout.writeln(
      '  Smoke tests: ${smoke['exit_code'] == 0 ? 'PASS' : 'FAIL'} '
      '($duration / $tests tests, ${_formatAvgSeconds(smoke['avg_seconds'])})',
    );
  }

  final flutter = _asMap(qa['flutter_test']);
  if (flutter.isNotEmpty) {
    final duration = _formatDuration(flutter['duration_seconds'] as int?);
    stdout.writeln(
      '  Flutter test: ${flutter['exit_code'] == 0 ? 'PASS' : 'FAIL'} ($duration)',
    );
  }

  final dashboard = _asMap(qa['dashboard']);
  if (dashboard.isNotEmpty) {
    final fps = (dashboard['avg_fps'] as num?)?.toDouble();
    final frameMs = (dashboard['frame_ms'] as num?)?.toDouble();
    final telemetryFlag = dashboard['telemetry_pass'];
    final telemetrySamples =
        (dashboard['telemetry_samples'] as num?)?.toInt() ?? 0;
    final frameLabel = frameMs != null
        ? '${frameMs.toStringAsFixed(2)} ms'
        : 'unknown';
    final fpsLabel = fps != null && fps > 0
        ? ' @ ${fps.toStringAsFixed(1)} fps'
        : '';
    stdout.writeln('  UI frame cost: $frameLabel$fpsLabel');
    String telemetryLabel;
    if (telemetryFlag == null) {
      telemetryLabel = 'UNKNOWN';
    } else {
      telemetryLabel = telemetryFlag == true ? 'PASS' : 'FAIL';
    }
    stdout.writeln(
      '  Telemetry: $telemetryLabel '
      '(samples $telemetrySamples)',
    );
  }
}

String _formatAvgSeconds(Object? avgSeconds) {
  if (avgSeconds is num && avgSeconds.isFinite) {
    return '${avgSeconds.toDouble().toStringAsFixed(2)}s/test';
  }
  return 'n/a';
}

String _formatDuration(int? seconds) {
  if (seconds == null || seconds < 0) return 'n/a';
  final minutes = seconds ~/ 60;
  final remain = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remain.toString().padLeft(2, '0')}';
}

int _countAnalyzerWarnings(String output) {
  return RegExp(r'warning', caseSensitive: false).allMatches(output).length;
}

Map<String, Object?> _parseTestSummary(String output) {
  final matches = RegExp(
    r'(\d{2}):(\d{2})\s+\+(\d+)',
  ).allMatches(output).toList();
  if (matches.isEmpty) {
    return {'tests': 0, 'duration_seconds': null, 'avg_seconds': null};
  }
  final match = matches.last;
  final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
  final seconds = int.tryParse(match.group(2) ?? '0') ?? 0;
  final tests = int.tryParse(match.group(3) ?? '0') ?? 0;
  final totalSeconds = minutes * 60 + seconds;
  final avgSeconds = tests > 0 ? totalSeconds / tests : null;
  return {
    'tests': tests,
    'duration_seconds': totalSeconds,
    'avg_seconds': avgSeconds,
  };
}

Map<String, Object?> _parseDashboardMetrics(String output) {
  final metrics = <String, Object?>{};
  final fpsMatch = RegExp(
    r'avg FPS\s+([0-9.]+)',
    caseSensitive: false,
  ).firstMatch(output);
  if (fpsMatch != null) {
    final fps = double.tryParse(fpsMatch.group(1) ?? '');
    if (fps != null && fps > 0) {
      metrics['avg_fps'] = fps;
      metrics['frame_ms'] = 1000.0 / fps;
    }
  }
  final telemetryMatch = RegExp(
    r'Telemetry Beta:\s+([^\n]+)',
  ).firstMatch(output);
  if (telemetryMatch != null) {
    final line = telemetryMatch.group(1) ?? '';
    metrics['telemetry_pass'] = line.contains('PASS');
    final samplesMatch = RegExp(r'samples\s+(\d+)').firstMatch(line);
    metrics['telemetry_samples'] =
        int.tryParse(samplesMatch?.group(1) ?? '0') ?? 0;
  }
  return metrics;
}
