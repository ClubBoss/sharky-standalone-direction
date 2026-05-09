import 'dart:convert';
import 'dart:io';

const _green = '\x1B[32m';
const _red = '\x1B[31m';
const _yellow = '\x1B[33m';
const _reset = '\x1B[0m';

Future<void> main(List<String> args) async {
  final phases = <_Phase>[
    _Phase(
      name: 'FORMAT',
      command: ['dart', 'format', '--set-exit-if-changed', '.'],
    ),
    _Phase(name: 'ANALYZE', command: ['dart', 'analyze']),
    _Phase(name: 'TESTS', command: ['dart', 'test', '-r', 'expanded']),
    _Phase(
      name: 'VISUAL',
      command: ['dart', 'run', 'tools/visual_integrity_audit.dart'],
      reportPath: 'release/_reports/visual_integrity_audit.txt',
    ),
    _Phase(
      name: 'I18N',
      command: ['dart', 'run', 'tools/localization_content_audit.dart'],
      reportPath: 'release/_reports/localization_content_audit.json',
    ),
    _Phase(
      name: 'AI',
      command: ['dart', 'run', 'tools/ai_reliability_audit.dart'],
      reportPath: 'release/_reports/ai_reliability_audit.txt',
    ),
  ];

  final overallStart = DateTime.now();
  final results = <_PhaseResult>[];

  for (final phase in phases) {
    stdout.writeln('$_yellow==> Running ${phase.name}$_reset');
    final result = await _runPhase(phase);
    results.add(result);
    final color = result.success ? _green : _red;
    stdout.writeln(
      '$color${phase.name} completed in ${result.duration.inSeconds}s '
      'with exit ${result.exitCode}$_reset',
    );
    stdout.writeln('');
    if (!result.success) {
      // Continue to collect full matrix but note failure.
    }
  }

  final totalDuration = DateTime.now().difference(overallStart);
  _printSummary(results);

  final passCount = results.where((r) => r.success).length;
  final passRate = results.isEmpty ? 0.0 : passCount / results.length;
  final telemetry = <String, Object>{
    'event': 'qa_ci_perfection_completed',
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    'duration_ms': totalDuration.inMilliseconds,
    'format': results.firstWhere((r) => r.phase.name == 'FORMAT').success,
    'analyze': results.firstWhere((r) => r.phase.name == 'ANALYZE').success,
    'tests': results.firstWhere((r) => r.phase.name == 'TESTS').success,
    'visual': results.firstWhere((r) => r.phase.name == 'VISUAL').success,
    'i18n': results.firstWhere((r) => r.phase.name == 'I18N').success,
    'ai': results.firstWhere((r) => r.phase.name == 'AI').success,
    'passRate': double.parse(passRate.toStringAsFixed(3)),
  };
  stdout.writeln(jsonEncode(telemetry));

  if (passCount != results.length) {
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
  final detail = await _readReportSummary(phase.reportPath);
  return _PhaseResult(
    phase: phase,
    duration: duration,
    exitCode: exitCode,
    success: exitCode == 0,
    reportSummary: detail,
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
  final content = await file.readAsString();
  if (path.endsWith('.json')) {
    try {
      final decoded = jsonDecode(content);
      if (decoded is Map) {
        final entries = decoded.entries
            .take(3)
            .map((entry) {
              final value = entry.value;
              if (value is List) {
                return '${entry.key}=${value.length}';
              }
              return '${entry.key}=$value';
            })
            .join(', ');
        return entries;
      }
    } catch (_) {
      return 'invalid json report';
    }
  }
  final lines = content.split('\n').where((line) => line.trim().isNotEmpty);
  return lines.take(3).join(' | ');
}

void _printSummary(List<_PhaseResult> results) {
  final rows = <List<String>>[
    ['Phase', 'Status', 'Duration(s)', 'Details'],
  ];
  for (final result in results) {
    final status = result.success ? 'PASS' : 'FAIL';
    rows.add([
      result.phase.name,
      status,
      result.duration.inSeconds.toString(),
      result.reportSummary ?? '-',
    ]);
  }

  final colWidths = List<int>.filled(4, 0);
  for (final row in rows) {
    for (var i = 0; i < row.length; i++) {
      if (row[i].length > colWidths[i]) {
        colWidths[i] = row[i].length;
      }
    }
  }

  String buildRow(List<String> row, {String? color}) {
    final cells = <String>[];
    for (var i = 0; i < row.length; i++) {
      cells.add(row[i].padRight(colWidths[i]));
    }
    final line = '| ${cells.join(' | ')} |';
    if (color == null) return line;
    return '$color$line$_reset';
  }

  final border =
      '+-${List.generate(colWidths.length, (i) => '-' * colWidths[i]).join('-+-')}-+';
  stdout.writeln(border);
  stdout.writeln(buildRow(rows.first));
  stdout.writeln(border);
  for (final row in rows.skip(1)) {
    final status = row[1];
    final color = status == 'PASS' ? _green : _red;
    stdout.writeln(buildRow(row, color: color));
  }
  stdout.writeln(border);
}

class _Phase {
  const _Phase({required this.name, required this.command, this.reportPath});

  final String name;
  final List<String> command;
  final String? reportPath;
}

class _PhaseResult {
  const _PhaseResult({
    required this.phase,
    required this.duration,
    required this.exitCode,
    required this.success,
    this.reportSummary,
  });

  final _Phase phase;
  final Duration duration;
  final int exitCode;
  final bool success;
  final String? reportSummary;
}
