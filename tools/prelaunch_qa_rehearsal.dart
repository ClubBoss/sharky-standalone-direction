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
      name: 'FULL_QA',
      command: ['dart', 'run', 'tools/full_qa_sweep.dart'],
      reportPath: 'release/_reports/full_qa_report.txt',
    ),
    _Phase(
      name: 'CD_OPT',
      command: ['dart', 'run', 'tools/continuous_delivery_optimizer.dart'],
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
      name: 'RELEASE_DOC',
      command: [
        'dart',
        'run',
        'tools/release_doc_generator.dart',
        '--version=$version',
      ],
    ),
    _Phase(
      name: 'TELEMETRY_DASH',
      command: ['dart', 'run', 'tools/telemetry_dashboard_cli.dart'],
    ),
    _Phase(
      name: 'QA_CI',
      command: ['dart', 'run', 'tools/qa_ci_perfection_sweep.dart'],
      reportPath: 'release/_reports/prelaunch_rehearsal_report.txt',
    ),
  ];

  final rehearsalStart = DateTime.now();
  final results = <_PhaseResult>[];

  for (final phase in phases) {
    stdout.writeln('$_yellow==> ${phase.name} starting$_reset');
    final result = await _runPhase(phase);
    results.add(result);
    final color = result.success ? _green : _red;
    stdout.writeln(
      '$color${phase.name} finished in '
      '${result.duration.inSeconds}s (exit ${result.exitCode})$_reset',
    );
    stdout.writeln('');
    if (!result.success) {
      // continue to gather remaining results to provide full report.
    }
  }

  final totalDuration = DateTime.now().difference(rehearsalStart);
  await _writeSummary(results, totalDuration);
  _printSummaryTable(results);

  final failures = results.where((result) => !result.success).length;
  final telemetry = <String, Object>{
    'event': 'prelaunch_rehearsal_completed',
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'duration_ms': totalDuration.inMilliseconds,
    'phases': results.length,
    'failures': failures,
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
  final summary = await _readReportSummary(phase.reportPath);
  return _PhaseResult(
    phase: phase,
    exitCode: exitCode,
    duration: duration,
    reportSummary: summary,
  );
}

Future<String?> _readReportSummary(String? path) async {
  if (path == null) {
    return null;
  }
  final file = File(path);
  if (!await file.exists()) {
    return 'report missing';
  }
  try {
    final content = await file.readAsString();
    return content
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .take(3)
        .join(' | ');
  } catch (_) {
    return 'unable to read report';
  }
}

Future<void> _writeSummary(
  List<_PhaseResult> results,
  Duration totalDuration,
) async {
  final buffer = StringBuffer()
    ..writeln('Pre-Launch QA Rehearsal')
    ..writeln('Timestamp: ${DateTime.now().toUtc().toIso8601String()}')
    ..writeln('Total duration: ${totalDuration.inSeconds}s')
    ..writeln('');
  for (final result in results) {
    buffer.writeln(
      '${result.phase.name}: ${result.success ? 'PASS' : 'FAIL'} '
      '(${result.duration.inSeconds}s)',
    );
    if (result.reportSummary != null) {
      buffer.writeln('  ${result.reportSummary}');
    }
  }
  final file = File('release/_reports/prelaunch_rehearsal_report.txt');
  await file.parent.create(recursive: true);
  await file.writeAsString(buffer.toString());
}

void _printSummaryTable(List<_PhaseResult> results) {
  final rows = <List<String>>[
    ['Phase', 'Status', 'Duration(s)', 'Details'],
  ];
  for (final result in results) {
    rows.add([
      result.phase.name,
      result.success ? 'PASS' : 'FAIL',
      result.duration.inSeconds.toString(),
      result.reportSummary ?? '-',
    ]);
  }
  final widths = List<int>.filled(4, 0);
  for (final row in rows) {
    for (var i = 0; i < row.length; i++) {
      if (row[i].length > widths[i]) {
        widths[i] = row[i].length;
      }
    }
  }
  String formatRow(List<String> row, {bool header = false}) {
    final cells = <String>[];
    for (var i = 0; i < row.length; i++) {
      cells.add(row[i].padRight(widths[i]));
    }
    final line = '| ${cells.join(' | ')} |';
    if (header) return line;
    return row[1] == 'PASS' ? '$_green$line$_reset' : '$_red$line$_reset';
  }

  final border =
      '+-${List.generate(widths.length, (i) => '-' * widths[i]).join('-+-')}-+';
  stdout.writeln(border);
  stdout.writeln(formatRow(rows.first, header: true));
  stdout.writeln(border);
  for (final row in rows.skip(1)) {
    stdout.writeln(formatRow(row));
  }
  stdout.writeln(border);
}

Future<String> _readVersion() async {
  final file = File('pubspec.yaml');
  if (!await file.exists()) {
    return '0.0.0';
  }
  final lines = await file.readAsLines();
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('version:')) {
      final value = trimmed.substring('version:'.length).trim();
      return value.isEmpty ? '0.0.0' : value;
    }
  }
  return '0.0.0';
}

class _Phase {
  const _Phase({required this.name, required this.command, this.reportPath});

  final String name;
  final List<String> command;
  final String? reportPath;
}

class _PhaseResult {
  _PhaseResult({
    required this.phase,
    required this.exitCode,
    required this.duration,
    required this.reportSummary,
  }) : success = exitCode == 0;

  final _Phase phase;
  final int exitCode;
  final Duration duration;
  final bool success;
  final String? reportSummary;
}
