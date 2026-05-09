import 'dart:convert';
import 'dart:io';
import 'dart:math';

const String _drillsPath = 'content/_generated/drills/v1/drills.jsonl';
const String _fusionMapPath = 'release/_reports/cross_path_fusion_map.json';
const String _reportsDir = 'release/_reports';
const String _summaryPath = 'release/_reports/meta_content_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final drills = await _loadDrills();
  if (drills.isEmpty) {
    stdout.writeln('meta_content_evaluator: no drills found.');
    return;
  }
  final fusionConcepts = await _loadFusionConcepts();

  final evaluations = drills
      .map((d) => _scoreDrill(d, fusionConcepts))
      .toList();
  final avgScore =
      evaluations.map((e) => e.overall).reduce((a, b) => a + b) /
      evaluations.length;

  await _withReportsWritable(() async {
    await _writeSummary(evaluations, avgScore);
    await _appendTelemetry(
      avgScore: double.parse(avgScore.toStringAsFixed(4)),
      coveragePct: 1.0,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'meta_content_evaluator: evaluated ${evaluations.length} drills '
    '(avg score ${(avgScore * 100).toStringAsFixed(1)}%).',
  );
}

Future<List<_Drill>> _loadDrills() async {
  final file = File(_drillsPath);
  if (!await file.exists()) return const [];
  final drills = <_Drill>[];
  final lines = await file.readAsLines();
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    try {
      final decoded = jsonDecode(line);
      if (decoded is Map<String, dynamic>) {
        drills.add(_Drill.fromJson(decoded));
      }
    } catch (_) {
      // skip malformed rows
    }
  }
  return drills;
}

Future<Set<String>> _loadFusionConcepts() async {
  final file = File(_fusionMapPath);
  if (!await file.exists()) return const {};
  try {
    final data = jsonDecode(await file.readAsString());
    final links = data['links'] as List<dynamic>? ?? const [];
    return {
      for (final link in links)
        if (link is Map && link['concept'] is String) link['concept'] as String,
    };
  } catch (_) {
    return const {};
  }
}

_DrillEvaluation _scoreDrill(_Drill drill, Set<String> fusionConcepts) {
  final clarity = _clarityScore(drill.prompt);
  final depth = _depthScore(drill.modules.length, drill.categories.length);
  final redundancy = _redundancyScore(drill.modules);
  final evGain = _evGainScore(
    drill.tone,
    fusionConcepts.contains(drill.concept),
  );
  final overall = (clarity + depth + redundancy + evGain) / 4;
  return _DrillEvaluation(
    drill: drill,
    clarity: clarity,
    depth: depth,
    redundancy: redundancy,
    evGain: evGain,
    overall: overall,
  );
}

double _clarityScore(String text) {
  if (text.isEmpty) return 0.0;
  final normalized = text.length / 160;
  return normalized.clamp(0.4, 1.0);
}

double _depthScore(int moduleCount, int categoryCount) {
  final moduleScore = (moduleCount / 40).clamp(0.2, 1.0);
  final categoryScore = (categoryCount / 4).clamp(0.25, 1.0);
  return double.parse(((moduleScore + categoryScore) / 2).toStringAsFixed(4));
}

double _redundancyScore(List<String> modules) {
  if (modules.isEmpty) return 0.0;
  final uniqueCount = modules.toSet().length;
  final redundantRatio = (modules.length - uniqueCount) / modules.length;
  final score = 1.0 - redundantRatio;
  return score.clamp(0.3, 1.0);
}

double _evGainScore(String tone, bool conceptLinked) {
  final base = switch (tone) {
    'advanced' || 'advanced_pack' => 0.9,
    'remedial' || 'remedial_pack' => 0.75,
    _ => 0.8,
  };
  return conceptLinked ? min(1.0, base + 0.05) : base;
}

Future<void> _writeSummary(
  List<_DrillEvaluation> evaluations,
  double avgScore,
) async {
  evaluations.sort((a, b) => b.overall.compareTo(a.overall));
  final buffer = StringBuffer()
    ..writeln('META CONTENT SUMMARY')
    ..writeln('====================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Drills evaluated: ${evaluations.length}')
    ..writeln('Average score: ${(avgScore * 100).toStringAsFixed(1)}%')
    ..writeln();

  final top = evaluations.take(5);
  final bottom = evaluations.reversed.take(5);

  buffer
    ..writeln('Top Drills:')
    ..writeln(_formatList(top))
    ..writeln()
    ..writeln('Needs Attention:')
    ..writeln(_formatList(bottom));

  await File(_summaryPath).writeAsString(buffer.toString());
}

String _formatList(Iterable<_DrillEvaluation> items) {
  if (items.isEmpty) return '- (none)';
  final lines = <String>[];
  for (final eval in items) {
    lines.add(
      '- ${eval.drill.id}: ${eval.drill.concept} '
      '[overall ${(eval.overall * 100).toStringAsFixed(1)}%, '
      'clarity ${(eval.clarity * 100).toStringAsFixed(0)}%, '
      'depth ${(eval.depth * 100).toStringAsFixed(0)}%]',
    );
  }
  return lines.join('\n');
}

Future<void> _appendTelemetry({
  required double avgScore,
  required double coveragePct,
  required int durationMs,
}) async {
  final telemetryFile = File(_telemetryPath);
  final event = <String, Object>{
    'event': 'meta_content_evaluated',
    'timestamp': DateTime.now().toIso8601String(),
    'avg_score': avgScore,
    'coverage_pct': coveragePct,
    'duration_ms': durationMs,
  };
  await telemetryFile.writeAsString(
    jsonEncode(event) + '\n',
    mode: FileMode.append,
    flush: true,
  );
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setReportsPermissions(addWrite: true);
  try {
    await action();
  } finally {
    await _setReportsPermissions(addWrite: false);
  }
}

Future<void> _setReportsPermissions({required bool addWrite}) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  final result = await Process.run('chmod', ['-R', mode, _reportsDir]);
  if (result.exitCode != 0) {
    stderr.writeln(
      'meta_content_evaluator: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _Drill {
  _Drill({
    required this.id,
    required this.concept,
    required this.categories,
    required this.modules,
    required this.tone,
    required this.prompt,
    required this.reaction,
  });

  factory _Drill.fromJson(Map<String, dynamic> json) {
    return _Drill(
      id: json['id']?.toString() ?? 'unknown',
      concept: json['concept']?.toString() ?? 'concept',
      categories: (json['categories'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      modules: (json['modules'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      tone: json['tone']?.toString() ?? 'standard',
      prompt: json['prompt']?.toString() ?? '',
      reaction: json['reaction_text']?.toString() ?? '',
    );
  }

  final String id;
  final String concept;
  final List<String> categories;
  final List<String> modules;
  final String tone;
  final String prompt;
  final String reaction;
}

class _DrillEvaluation {
  _DrillEvaluation({
    required this.drill,
    required this.clarity,
    required this.depth,
    required this.redundancy,
    required this.evGain,
    required this.overall,
  });

  final _Drill drill;
  final double clarity;
  final double depth;
  final double redundancy;
  final double evGain;
  final double overall;
}
