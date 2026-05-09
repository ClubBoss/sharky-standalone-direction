import 'dart:convert';
import 'dart:io';

const _green = '\x1B[32m';
const _red = '\x1B[31m';
const _yellow = '\x1B[33m';
const _reset = '\x1B[0m';

Future<void> main(List<String> args) async {
  final version = await _readVersion();
  final phases = <_Phase>[
    _Phase(
      name: 'PACKAGER',
      command: ['dart', 'run', 'tools/release_packager.dart'],
      reportHint: 'release/_reports/full_qa_report.txt',
    ),
    _Phase(
      name: 'MOBILE_BUILD',
      command: [
        'dart',
        'run',
        'tools/mobile_build_configurator.dart',
        '--platform=android',
      ],
    ),
    _Phase(
      name: 'AUTO_PATCH',
      command: ['dart', 'run', 'tools/auto_patch_builder.dart'],
    ),
    _Phase(
      name: 'DOCS',
      command: [
        'dart',
        'run',
        'tools/release_doc_generator.dart',
        '--version=$version',
      ],
      reportHint: 'release/_reports/release_doc_summary.txt',
    ),
    _Phase(
      name: 'MARKETING',
      command: ['dart', 'run', 'tools/marketing_pipeline_cli.dart'],
      reportHint: 'release/_reports/marketing_summary.txt',
    ),
    _Phase(
      name: 'TELEMETRY',
      command: ['dart', 'run', 'tools/telemetry_dashboard_cli.dart'],
      reportHint: 'release/_reports/telemetry_dashboard.txt',
    ),
  ];

  final start = DateTime.now();
  final results = <_PhaseResult>[];

  for (final phase in phases) {
    stdout.writeln('$_yellow==> ${phase.name} starting$_reset');
    final result = await _runPhase(phase);
    results.add(result);
    final color = result.success ? _green : _red;
    stdout.writeln(
      '$color${phase.name} finished in ${result.duration.inSeconds}s '
      '(exit ${result.exitCode})$_reset',
    );
    stdout.writeln('');
    if (!result.success) {
      // continue gathering to provide full report before exit.
    }
  }

  final totalDuration = DateTime.now().difference(start);
  final kpis = await _collectKpis();
  await _writeSummary(version, results, kpis, totalDuration);

  final failures = results.where((result) => !result.success).length;
  final telemetry = <String, Object>{
    'event': 'final_release_completed',
    'version': version,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'duration_ms': totalDuration.inMilliseconds,
    'phases': results.length,
    'failures': failures,
    'kpis': kpis,
  };
  stdout.writeln(jsonEncode(telemetry));

  if (failures > 0) {
    exit(1);
  }
}

Future<_PhaseResult> _runPhase(_Phase phase) async {
  final start = DateTime.now();
  final process = await Process.start(
    phase.command.first,
    phase.command.sublist(1),
    runInShell: false,
  );
  await Future.wait([
    stdout.addStream(process.stdout),
    stderr.addStream(process.stderr),
  ]);
  final exitCode = await process.exitCode;
  final duration = DateTime.now().difference(start);
  final reportSummary = phase.reportHint == null
      ? null
      : await _readReportSnippet(phase.reportHint!);
  return _PhaseResult(
    phase: phase,
    exitCode: exitCode,
    duration: duration,
    reportSummary: reportSummary,
  );
}

Future<Map<String, double>> _collectKpis() async {
  final telemetry = await _readFileIfExists(
    'release/_reports/telemetry_dashboard.txt',
  );
  final ai = await _readFileIfExists(
    'release/_reports/ai_reliability_audit.txt',
  );
  final marketing = await _readFileIfExists(
    'release/_reports/marketing_summary.txt',
  );

  return {
    'retention_7d':
        _extractPercent(telemetry, ['retention_7d', 'retention_avg_7']) ?? 0.0,
    'retention_14d':
        _extractPercent(telemetry, ['retention_14d', 'retention_avg_14']) ??
        0.0,
    'conversion':
        _extractPercent(marketing, ['premium_conversion', 'conversion_rate']) ??
        0.0,
    'ai_accuracy': _extractPercent(ai, ['Win Rate', 'ai_accuracy']) ?? 0.0,
  };
}

Future<void> _writeSummary(
  String version,
  List<_PhaseResult> results,
  Map<String, double> kpis,
  Duration totalDuration,
) async {
  final buffer = StringBuffer()
    ..writeln('Final Release Summary')
    ..writeln('Version: $version')
    ..writeln('Timestamp: ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln('Total Duration: ${totalDuration.inSeconds}s')
    ..writeln('');

  buffer.writeln('Phase Results:');
  for (final result in results) {
    buffer.writeln(
      '- ${result.phase.name}: ${result.success ? 'PASS' : 'FAIL'} '
      '(${result.duration.inSeconds}s)',
    );
    if (result.reportSummary != null) {
      buffer.writeln('    ${result.reportSummary}');
    }
  }
  buffer.writeln('');
  buffer.writeln('Key Performance Indicators:');
  kpis.forEach((key, value) {
    buffer.writeln('  $key: ${(value * 100).toStringAsFixed(2)}%');
  });
  buffer.writeln('');
  buffer.writeln('Next-release checklist:');
  buffer.writeln('- Verify marketing creatives for next sprint');
  buffer.writeln('- Review telemetry anomalies');
  buffer.writeln('- Confirm store metadata translations');

  final file = File('release/_reports/final_release_summary.txt');
  await file.parent.create(recursive: true);
  await file.writeAsString(buffer.toString());
}

Future<String> _readVersion() async {
  final file = File('pubspec.yaml');
  if (!await file.exists()) {
    return '0.0.0';
  }
  for (final line in await file.readAsLines()) {
    final trimmed = line.trim();
    if (trimmed.startsWith('version:')) {
      final value = trimmed.substring('version:'.length).trim();
      return value.isEmpty ? '0.0.0' : value;
    }
  }
  return '0.0.0';
}

Future<String?> _readReportSnippet(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return null;
  }
  final lines = await file.readAsLines();
  return lines.where((line) => line.trim().isNotEmpty).take(2).join(' | ');
}

Future<String> _readFileIfExists(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    return '';
  }
  return file.readAsString();
}

double? _extractPercent(String content, List<String> keys) {
  final value = _extractMetric(content, keys);
  if (value == null) return null;
  return value > 1 ? value / 100 : value;
}

double? _extractMetric(String content, List<String> keys) {
  if (content.isEmpty) return null;
  for (final key in keys) {
    final regex = RegExp(
      '$key\\s*[:=]\\s*([0-9]+\\.?[0-9]*)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(content);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
  }
  return null;
}

class _Phase {
  const _Phase({required this.name, required this.command, this.reportHint});

  final String name;
  final List<String> command;
  final String? reportHint;
}

class _PhaseResult {
  _PhaseResult({
    required this.phase,
    required this.exitCode,
    required this.duration,
    this.reportSummary,
  }) : success = exitCode == 0;

  final _Phase phase;
  final int exitCode;
  final Duration duration;
  final bool success;
  final String? reportSummary;
}
