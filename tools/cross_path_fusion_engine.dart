import 'dart:convert';
import 'dart:io';

const String _contentRoot = 'content';
const String _reportsDir = 'release/_reports';
const String _summaryPath = 'release/_reports/cross_path_fusion_summary.txt';
const String _fusionJsonPath = 'release/_reports/cross_path_fusion_map.json';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final modules = await _collectModules();
  if (modules.isEmpty) {
    stdout.writeln('cross_path_fusion_engine: no modules found.');
    return;
  }

  final links = _buildFusionLinks(modules);
  final uniqueLinkedModules = <String>{
    for (final link in links) ...link.modules.map((m) => m.id),
  };
  final coveragePct = modules.isEmpty
      ? 0.0
      : uniqueLinkedModules.length / modules.length;

  await _withReportsWritable(() async {
    await _writeFusionJson(links);
    await _writeSummary(modules.length, links, coveragePct);
    await _appendTelemetry(
      links: links.length,
      coveragePct: double.parse(coveragePct.toStringAsFixed(4)),
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'cross_path_fusion_engine: ${links.length} concepts linked '
    '(${(coveragePct * 100).toStringAsFixed(1)}% module coverage).',
  );
}

Future<List<_Module>> _collectModules() async {
  final root = Directory(_contentRoot);
  if (!await root.exists()) return const [];
  final modules = <_Module>[];

  await for (final packDir in root.list(recursive: false, followLinks: false)) {
    if (packDir is! Directory) continue;
    final v1 = Directory('${packDir.path}/v1');
    if (!v1.existsSync()) continue;
    final category = _pathCategory(packDir.path);
    for (final file
        in v1
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()
            .where((f) => f.path.endsWith('.jsonl'))) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final raw = lines[i].trim();
        if (raw.isEmpty || raw.startsWith('#')) continue;
        Map<String, dynamic>? data;
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            data = decoded;
          }
        } catch (_) {
          // skip malformed rows
        }
        if (data == null) continue;
        final text = '${data['goal'] ?? ''} ${data['reaction_text'] ?? ''}';
        final tokens = _extractTokens(text);
        if (tokens.isEmpty) continue;
        modules.add(
          _Module(
            id: data['id']?.toString() ?? '${file.path}:${i + 1}',
            category: category,
            path: file.path,
            tokens: tokens,
          ),
        );
      }
    }
  }
  return modules;
}

List<_FusionLink> _buildFusionLinks(List<_Module> modules) {
  final tokenMap = <String, List<_Module>>{};
  for (final module in modules) {
    for (final token in module.tokens) {
      tokenMap.putIfAbsent(token, () => []).add(module);
    }
  }
  final links = <_FusionLink>[];
  tokenMap.forEach((token, mods) {
    final uniqueCategories = mods.map((m) => m.category).toSet();
    if (uniqueCategories.length < 2) return;
    final dedupedModules = _dedupeModules(mods);
    if (dedupedModules.length < 2) return;
    links.add(_FusionLink(concept: token, modules: dedupedModules));
  });
  links.sort((a, b) => b.modules.length.compareTo(a.modules.length));
  return links;
}

List<_ModuleRef> _dedupeModules(List<_Module> modules) {
  final seen = <String>{};
  final refs = <_ModuleRef>[];
  for (final module in modules) {
    if (seen.add(module.id)) {
      refs.add(
        _ModuleRef(id: module.id, category: module.category, path: module.path),
      );
    }
  }
  return refs;
}

Set<String> _extractTokens(String text) {
  final matches = RegExp(r'[A-Za-z]{5,}').allMatches(text.toLowerCase());
  return matches
      .map((m) => m.group(0)!)
      .where((word) => !_stopwords.contains(word))
      .toSet();
}

Future<void> _writeFusionJson(List<_FusionLink> links) async {
  final payload = {
    'generated_at': DateTime.now().toIso8601String(),
    'links': [
      for (final link in links)
        {
          'concept': link.concept,
          'modules': [
            for (final module in link.modules)
              {
                'id': module.id,
                'category': module.category,
                'path': module.path,
              },
          ],
        },
    ],
  };
  final encoder = const JsonEncoder.withIndent('  ');
  await File(_fusionJsonPath).writeAsString(encoder.convert(payload));
}

Future<void> _writeSummary(
  int totalModules,
  List<_FusionLink> links,
  double coveragePct,
) async {
  final buffer = StringBuffer()
    ..writeln('CROSS-PATH FUSION SUMMARY')
    ..writeln('==========================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Modules scanned: $totalModules')
    ..writeln('Fusion concepts: ${links.length}')
    ..writeln(
      'Coverage: ${(coveragePct * 100).toStringAsFixed(1)}% of modules linked',
    )
    ..writeln();

  if (links.isEmpty) {
    buffer.writeln('No cross-path concepts detected.');
  } else {
    buffer.writeln('Top Concepts:');
    for (final link in links.take(20)) {
      buffer.writeln(
        '- ${link.concept}: ${link.modules.length} modules '
        '(${link.modules.map((m) => m.category).toSet().join(', ')})',
      );
    }
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _appendTelemetry({
  required int links,
  required double coveragePct,
  required int durationMs,
}) async {
  final telemetryFile = File(_telemetryPath);
  final event = <String, Object>{
    'event': 'cross_path_fused',
    'timestamp': DateTime.now().toIso8601String(),
    'links': links,
    'coverage_pct': double.parse(coveragePct.toStringAsFixed(4)),
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
      'cross_path_fusion_engine: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

String _pathCategory(String path) {
  final lower = path.toLowerCase();
  if (lower.contains('cash')) return 'Cash';
  if (lower.contains('mtt')) return 'MTT';
  if (lower.contains('live')) return 'Live';
  return 'Other';
}

const Set<String> _stopwords = {
  'about',
  'after',
  'again',
  'being',
  'better',
  'bring',
  'build',
  'check',
  'chips',
  'focus',
  'games',
  'great',
  'leave',
  'level',
  'table',
  'train',
  'value',
  'wider',
  'would',
};

class _Module {
  _Module({
    required this.id,
    required this.category,
    required this.path,
    required this.tokens,
  });

  final String id;
  final String category;
  final String path;
  final Set<String> tokens;
}

class _ModuleRef {
  _ModuleRef({required this.id, required this.category, required this.path});

  final String id;
  final String category;
  final String path;
}

class _FusionLink {
  _FusionLink({required this.concept, required this.modules});

  final String concept;
  final List<_ModuleRef> modules;
}
