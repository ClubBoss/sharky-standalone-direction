import 'dart:convert';
import 'dart:io';

const String _fusionMapPath = 'release/_reports/cross_path_fusion_map.json';
const String _depthSummaryPath = 'release/_reports/adaptive_depth_summary.txt';
const String _drillOutputDir = 'content/_generated/drills/v1';
const String _drillOutputFile = 'content/_generated/drills/v1/drills.jsonl';
const String _reportsDir = 'release/_reports';
const String _summaryPath = 'release/_reports/reinforcement_drill_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final fusion = await _readFusionMap();
  if (fusion.links.isEmpty) {
    stdout.writeln(
      'reinforcement_drill_generator: no fusion concepts available.',
    );
    return;
  }

  final depthHints = await _parseDepthHints();
  final drills = _buildDrills(fusion.links, depthHints);
  await _writeDrills(drills);

  final coverage = drills.isEmpty ? 0.0 : drills.length / fusion.links.length;

  await _withReportsWritable(() async {
    await _writeSummary(fusion.links.length, drills, coverage);
    await _appendTelemetry(
      count: drills.length,
      coveragePct: double.parse(coverage.toStringAsFixed(4)),
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'reinforcement_drill_generator: generated ${drills.length} drills '
    '(${(coverage * 100).toStringAsFixed(1)}% coverage).',
  );
}

Future<_FusionMap> _readFusionMap() async {
  final file = File(_fusionMapPath);
  if (!await file.exists()) {
    stdout.writeln('reinforcement_drill_generator: fusion map missing.');
    return const _FusionMap(links: []);
  }
  try {
    final data = jsonDecode(await file.readAsString());
    final links = (data['links'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((link) {
          final concept = link['concept']?.toString();
          if (concept == null || concept.isEmpty) return null;
          final modules = (link['modules'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(
                (module) => _ModuleRef(
                  id: module['id']?.toString() ?? 'unknown',
                  category: module['category']?.toString() ?? 'Other',
                  path: module['path']?.toString() ?? '',
                ),
              )
              .toList();
          if (modules.length < 2) return null;
          return _FusionLink(concept: concept, modules: modules);
        })
        .whereType<_FusionLink>()
        .toList();
    return _FusionMap(links: links);
  } catch (error) {
    stderr.writeln('reinforcement_drill_generator: invalid fusion map: $error');
    return const _FusionMap(links: []);
  }
}

Future<Map<String, String>> _parseDepthHints() async {
  final file = File(_depthSummaryPath);
  if (!await file.exists()) return const {};
  final hints = <String, String>{};
  final pattern = RegExp(r'-\s+(\S+)\s+->\s+(\w+)_pack');
  for (final line in await file.readAsLines()) {
    final match = pattern.firstMatch(line);
    if (match == null) continue;
    final id = match.group(1)!;
    final type = match.group(2)!;
    hints[id] = type;
  }
  return hints;
}

List<_Drill> _buildDrills(
  List<_FusionLink> links,
  Map<String, String> depthHints,
) {
  final drills = <_Drill>[];
  var counter = 1;
  for (final link in links) {
    final categories = link.modules.map((m) => m.category).toSet().toList();
    final sampleModule = link.modules.first;
    final packId = _packIdFromPath(sampleModule.path);
    final tone = depthHints[packId] ?? 'standard';
    final drill = _Drill(
      id: 'fusion_drill_${counter.toString().padLeft(4, '0')}',
      concept: link.concept,
      categories: categories,
      modules: link.modules.map((m) => m.id).toList(),
      tone: tone,
      prompt: _buildPrompt(link.concept, categories, tone),
      reaction: _buildReaction(tone),
    );
    drills.add(drill);
    counter += 1;
  }
  return drills;
}

String _packIdFromPath(String path) {
  if (path.isEmpty) return 'unknown';
  final segments = path.split('/');
  if (segments.length < 2) return path;
  return segments[1]; // content/<pack>/v1/...
}

String _buildPrompt(String concept, List<String> categories, String tone) {
  final categoryText = categories.join(', ');
  final toneText = switch (tone) {
    'advanced' || 'advanced_pack' => 'Push into the advanced lane for',
    'remedial' || 'remedial_pack' => 'Reinforce fundamentals for',
    _ => 'Blend learnings across',
  };
  return '$toneText $categoryText by revisiting the "$concept" concept.';
}

String _buildReaction(String tone) {
  if (tone == 'advanced' || tone == 'advanced_pack') {
    return 'Great control on the advanced fusion sequence.';
  }
  if (tone == 'remedial' || tone == 'remedial_pack') {
    return 'Solid reset. Keep reinforcing the fundamentals.';
  }
  return 'Smooth cross-path integration. Keep pressing.';
}

Future<void> _writeDrills(List<_Drill> drills) async {
  final dir = Directory(_drillOutputDir);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  final file = File(_drillOutputFile);
  final sink = file.openWrite();
  final encoder = JsonEncoder();
  for (final drill in drills) {
    sink.writeln(encoder.convert(drill.toJson()));
  }
  await sink.close();
}

Future<void> _writeSummary(
  int conceptCount,
  List<_Drill> drills,
  double coverage,
) async {
  final buffer = StringBuffer()
    ..writeln('REINFORCEMENT DRILL SUMMARY')
    ..writeln('===========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Fusion concepts: $conceptCount')
    ..writeln('Drills generated: ${drills.length}')
    ..writeln('Coverage: ${(coverage * 100).toStringAsFixed(1)}%')
    ..writeln();

  if (drills.isEmpty) {
    buffer.writeln('No drills generated. Ensure fusion map contains links.');
  } else {
    buffer.writeln('Sample (first 5 drills):');
    for (final drill in drills.take(5)) {
      buffer.writeln(
        '- ${drill.id}: ${drill.concept} across ${drill.categories.join(', ')} '
        '[tone: ${drill.tone}]',
      );
    }
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int count,
  required double coveragePct,
  required int durationMs,
}) async {
  final telemetryFile = File(_telemetryPath);
  final event = <String, Object>{
    'event': 'reinforcement_drills_generated',
    'timestamp': DateTime.now().toIso8601String(),
    'count': count,
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
      'reinforcement_drill_generator: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _FusionMap {
  const _FusionMap({required this.links});
  final List<_FusionLink> links;
}

class _FusionLink {
  const _FusionLink({required this.concept, required this.modules});
  final String concept;
  final List<_ModuleRef> modules;
}

class _ModuleRef {
  const _ModuleRef({
    required this.id,
    required this.category,
    required this.path,
  });

  final String id;
  final String category;
  final String path;
}

class _Drill {
  const _Drill({
    required this.id,
    required this.concept,
    required this.categories,
    required this.modules,
    required this.tone,
    required this.prompt,
    required this.reaction,
  });

  final String id;
  final String concept;
  final List<String> categories;
  final List<String> modules;
  final String tone;
  final String prompt;
  final String reaction;

  Map<String, Object> toJson() => <String, Object>{
    'id': id,
    'concept': concept,
    'categories': categories,
    'modules': modules,
    'tone': tone,
    'prompt': prompt,
    'reaction_text': reaction,
  };
}
