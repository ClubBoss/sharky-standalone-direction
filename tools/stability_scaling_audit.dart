import 'dart:convert';
import 'dart:io';

import 'package:poker_analyzer/constants/telemetry_events.dart';

Future<void> main(List<String> args) async {
  final audit = _StabilityScalingAudit();
  final result = await audit.run();
  result.printSummary();
  await result.writeReport('release/_reports/stability_scaling_audit.txt');
  result.emitTelemetry();
}

class _StabilityScalingAudit {
  static const List<_ReportProbe> _probes = <_ReportProbe>[
    _ReportProbe(
      label: 'Launch',
      keywords: ['launch readiness summary', 'launch readiness'],
    ),
    _ReportProbe(
      label: 'QA',
      keywords: [
        'final stakeholder summary',
        'final stakeholder sweep',
        'full readiness',
      ],
    ),
    _ReportProbe(label: 'UX', keywords: ['visual integrity', 'visual polish']),
  ];

  Future<_AuditResult> run() async {
    final dir = Directory('release/_reports');
    if (!dir.existsSync()) {
      return _AuditResult.empty('Missing release/_reports directory');
    }
    final files = dir.listSync().whereType<File>().toList();

    final categoryScores = <String, double>{};
    var warningCount = 0;
    for (final probe in _probes) {
      final file = _findFile(files, probe.keywords);
      if (file == null) {
        warningCount++;
        categoryScores[probe.label] = 0.0;
        continue;
      }
      final content = file.readAsStringSync().toLowerCase();
      final pass = _passWordPattern.hasMatch(content);
      final fail = _failWordPattern.hasMatch(content);
      final warn = _warnWordPattern.hasMatch(content);
      final score = fail
          ? 0.0
          : pass
          ? 1.0
          : 0.5;
      if (warn) warningCount++;
      categoryScores[probe.label] = score;
    }

    final warningRate =
        warningCount / (_probes.length == 0 ? 1 : _probes.length);
    final stabilityScore =
        (categoryScores.values.fold<double>(0, (sum, score) => sum + score) -
            warningRate) /
        (_probes.length == 0 ? 1 : _probes.length);

    return _AuditResult(
      categoryScores: categoryScores,
      warningCount: warningCount,
      stabilityScore: stabilityScore.clamp(0.0, 1.0),
    );
  }

  File? _findFile(List<File> files, List<String> keywords) {
    for (final file in files) {
      final lower = file.path.toLowerCase();
      final normalized = lower.replaceAll('_', ' ');
      if (keywords.any(
        (keyword) => lower.contains(keyword) || normalized.contains(keyword),
      )) {
        return file;
      }
    }
    return null;
  }
}

class _AuditResult {
  _AuditResult({
    required this.categoryScores,
    required this.warningCount,
    required this.stabilityScore,
  });

  _AuditResult.empty(String error)
    : categoryScores = const <String, double>{},
      warningCount = 1,
      stabilityScore = 0.0 {
    stderr.writeln('WARN: $error');
  }

  final Map<String, double> categoryScores;
  final int warningCount;
  final double stabilityScore;

  void printSummary() {
    stdout.writeln('+--------------+--------+');
    stdout.writeln('| Category     | Score  |');
    stdout.writeln('+--------------+--------+');
    categoryScores.forEach((category, score) {
      stdout.writeln(
        '| ${category.padRight(12)} | ${score.toStringAsFixed(2).padLeft(6)} |',
      );
    });
    stdout.writeln('+--------------+--------+');
    stdout.writeln(
      'Stability Score: ${stabilityScore.toStringAsFixed(3)} '
      '(warnings=$warningCount)',
    );
  }

  Future<void> writeReport(String path) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    final buffer = StringBuffer()
      ..writeln('Stability Scaling Audit')
      ..writeln('Timestamp: ${DateTime.now().toUtc().toIso8601String()}')
      ..writeln('');
    categoryScores.forEach((category, score) {
      buffer.writeln('$category=${score.toStringAsFixed(2)}');
    });
    buffer
      ..writeln('')
      ..writeln('warnings=$warningCount')
      ..writeln('stability_score=${stabilityScore.toStringAsFixed(3)}');
    await file.writeAsString(buffer.toString());
  }

  void emitTelemetry() {
    final payload = <String, Object>{
      'event': TelemetryEvents.stabilityScalingAuditCompleted,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'warnings': warningCount,
      'stabilityScore': stabilityScore,
      'categories': categoryScores,
    };
    stdout.writeln(jsonEncode(payload));
  }
}

class _ReportProbe {
  const _ReportProbe({required this.label, required this.keywords});

  final String label;
  final List<String> keywords;
}

final RegExp _passWordPattern = RegExp(r'\bpass\b', caseSensitive: false);
final RegExp _failWordPattern = RegExp(r'\bfail\b', caseSensitive: false);
final RegExp _warnWordPattern = RegExp(
  r'\bwarn(?:ing)?\b',
  caseSensitive: false,
);
