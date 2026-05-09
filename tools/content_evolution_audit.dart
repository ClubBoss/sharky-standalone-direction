import 'dart:convert';
import 'dart:io';

const String _contentRoot = 'content';
const String _reportsDir = 'release/_reports';
const String _reportPath = 'release/_reports/content_evolution_audit.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final stopwatch = Stopwatch()..start();
  final modules = await _collectModules();
  final totalModules = modules.length;
  final incomplete = modules.where((m) => m.missingFields.isNotEmpty).toList();
  final coverage = _computeCoverage(modules);
  final completionPercent = totalModules == 0
      ? 1.0
      : (totalModules - incomplete.length) / totalModules;

  final buffer = StringBuffer()
    ..writeln('CONTENT EVOLUTION AUDIT')
    ..writeln('=======================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Modules scanned: $totalModules')
    ..writeln('Modules complete: ${totalModules - incomplete.length}')
    ..writeln('Completion: ${(completionPercent * 100).toStringAsFixed(1)}%')
    ..writeln()
    ..writeln('Path Coverage:')
    ..writeln(_formatCoverage(coverage))
    ..writeln('Incomplete Modules: ${incomplete.length}')
    ..writeln();

  if (incomplete.isEmpty) {
    buffer.writeln('All modules satisfy metadata requirements.');
  } else {
    buffer.writeln('Missing Metadata Details:');
    for (final module in incomplete) {
      buffer.writeln(
        '- ${module.id ?? module.file}:${module.line} '
        '[${module.category}] -> missing ${module.missingFields.join(', ')}',
      );
    }
  }

  await _withReportsWritable(() async {
    await File(_reportPath).writeAsString(buffer.toString());
    await _appendTelemetry(
      modules: totalModules,
      coverage: completionPercent,
      missing: incomplete.length,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  });

  stdout.writeln(
    'content_evolution_audit: scanned $totalModules modules, '
    '${incomplete.length} missing metadata.',
  );
}

Future<List<_ModuleRecord>> _collectModules() async {
  final root = Directory(_contentRoot);
  if (!await root.exists()) return const [];
  final modules = <_ModuleRecord>[];

  await for (final entry in root.list(recursive: false, followLinks: false)) {
    if (entry is! Directory) continue;
    final v1 = Directory('${entry.path}/v1');
    if (!v1.existsSync()) continue;
    final category = _pathCategory(entry.path);
    final files = v1
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.jsonl'));

    for (final file in files) {
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
          // Skip malformed JSON.
        }
        if (data == null) continue;
        final hasTitle =
            _hasNonEmpty(data['title']) ||
            _hasNonEmpty(data['goal']) ||
            _hasNonEmpty(data['lesson_goal']);
        final hasGoal = _hasNonEmpty(data['goal']);
        final hasReaction = _hasNonEmpty(data['reaction_text']);
        final missing = <String>[];
        if (!hasTitle) missing.add('title');
        if (!hasGoal) missing.add('goal');
        if (!hasReaction) missing.add('reaction_text');

        modules.add(
          _ModuleRecord(
            id: data['id']?.toString(),
            category: category,
            file: file.path,
            line: i + 1,
            missingFields: missing,
          ),
        );
      }
    }
  }

  return modules;
}

Map<String, _CoverageStats> _computeCoverage(List<_ModuleRecord> modules) {
  final map = <String, _CoverageStats>{};
  for (final module in modules) {
    final stats = map.putIfAbsent(module.category, _CoverageStats.new);
    stats.total += 1;
    if (module.missingFields.isEmpty) {
      stats.complete += 1;
    }
  }
  return map;
}

String _formatCoverage(Map<String, _CoverageStats> coverage) {
  if (coverage.isEmpty) {
    return '- No modules detected';
  }
  final keys = coverage.keys.toList()..sort();
  return keys
      .map((key) {
        final stats = coverage[key]!;
        final percent = stats.total == 0
            ? 0
            : (stats.complete / stats.total) * 100;
        return '- $key: ${stats.complete}/${stats.total} '
            '(${percent.toStringAsFixed(1)}%)';
      })
      .join('\n');
}

bool _hasNonEmpty(Object? value) {
  if (value == null) return false;
  final text = value.toString().trim();
  return text.isNotEmpty;
}

String _pathCategory(String path) {
  final name = path.split(Platform.pathSeparator).last.toLowerCase();
  if (name.contains('cash')) return 'Cash';
  if (name.contains('mtt')) return 'MTT';
  if (name.contains('live')) return 'Live';
  return 'Other';
}

Future<void> _appendTelemetry({
  required int modules,
  required double coverage,
  required int missing,
  required int durationMs,
}) async {
  final telemetryFile = File(_telemetryPath);
  final event = <String, Object>{
    'event': 'content_evolution_audited',
    'timestamp': DateTime.now().toIso8601String(),
    'modules': modules,
    'coverage': double.parse(coverage.toStringAsFixed(4)),
    'missing': missing,
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
      'content_evolution_audit: chmod failed '
      '(${result.exitCode}): ${result.stderr}',
    );
  }
}

class _ModuleRecord {
  const _ModuleRecord({
    required this.id,
    required this.category,
    required this.file,
    required this.line,
    required this.missingFields,
  });

  final String? id;
  final String category;
  final String file;
  final int line;
  final List<String> missingFields;
}

class _CoverageStats {
  int total = 0;
  int complete = 0;
}
