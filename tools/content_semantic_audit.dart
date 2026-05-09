import 'dart:convert';
import 'dart:io';

const String _contentRoot = 'content';
const String _previewRoot = 'content_adaptive_preview';
const String _summaryPath =
    'release/_reports/content_semantic_audit_summary.txt';
const String _telemetryPath = 'release/_reports/telemetry.jsonl';

Future<void> main(List<String> args) async {
  final audit = ContentSemanticAudit();
  final ok = await audit.run();
  if (!ok) {
    exitCode = 2;
  }
}

class ContentSemanticAudit {
  Future<bool> run() async {
    final stopwatch = Stopwatch()..start();
    final modules = await _discoverModules();
    final moduleResults = <_ModuleIssues>[];
    for (final module in modules) {
      moduleResults.add(await _auditModule(module));
    }

    final hasIssues = moduleResults.any((result) => result.hasIssues);
    await _withReportsWritable(() async {
      await _writeSummary(
        modules: moduleResults,
        durationMs: stopwatch.elapsedMilliseconds,
      );
      await _emitTelemetry(
        modules: moduleResults,
        durationMs: stopwatch.elapsedMilliseconds,
        verdict: hasIssues ? 'FAIL' : 'PASS',
      );
    });

    return !hasIssues;
  }

  Future<List<_ModuleRef>> _discoverModules() async {
    final refs = <_ModuleRef>[];
    for (final root in [_contentRoot, _previewRoot]) {
      final dir = Directory(root);
      if (!await dir.exists()) continue;
      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is Directory && entity.path.endsWith('/v1')) {
          refs.add(_ModuleRef(entity.path));
        }
      }
    }
    refs.sort((a, b) => a.path.compareTo(b.path));
    return refs;
  }

  Future<_ModuleIssues> _auditModule(_ModuleRef module) async {
    final issues = <String>[];

    final drills = await module.resolveFile('drills.jsonl');
    final quiz = await module.resolveFile('quiz.jsonl');
    final recap = await module.resolveFile('recap.md');

    final idRegistry = <String, String>{};

    if (drills != null) {
      issues.addAll(
        await _checkJsonl(
          file: drills,
          idRegistry: idRegistry,
          difficultyField: 'difficulty',
          titleConsistencyFields: const ['goal', 'lesson_goal'],
        ),
      );
    }
    if (quiz != null) {
      issues.addAll(
        await _checkJsonl(
          file: quiz,
          idRegistry: idRegistry,
          difficultyField: 'difficulty',
          titleConsistencyFields: const ['goal', 'lesson_goal'],
          quizSpecific: true,
        ),
      );
    }
    if (recap != null) {
      final data = await recap.readAsString();
      if (!_isAscii(data)) {
        issues.add('recap.md contains non-ASCII characters.');
      }
    }
    return _ModuleIssues(module.path, issues);
  }

  Future<List<String>> _checkJsonl({
    required File file,
    required Map<String, String> idRegistry,
    String? difficultyField,
    List<String> titleConsistencyFields = const [],
    bool quizSpecific = false,
  }) async {
    final issues = <String>[];
    final lines = file
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    var lineNumber = 0;
    await for (final line in lines) {
      lineNumber++;
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      Map<String, dynamic>? record;
      try {
        final decoded = json.decode(trimmed);
        if (decoded is Map<String, dynamic>) {
          record = decoded;
        }
      } catch (_) {
        issues.add('${file.path}: line $lineNumber invalid JSON.');
        continue;
      }
      if (record == null) {
        issues.add('${file.path}: line $lineNumber invalid JSON object.');
        continue;
      }

      final id = record['id']?.toString();
      if (id == null || id.isEmpty) {
        issues.add('${file.path}: line $lineNumber missing "id" field.');
      } else if (idRegistry.containsKey(id)) {
        issues.add(
          '${file.path}: line $lineNumber duplicate id "$id" '
          '(already in ${idRegistry[id]}).',
        );
      } else {
        idRegistry[id] = file.path;
      }

      if (difficultyField != null) {
        final diff = record[difficultyField]?.toString();
        if (diff != null && !_allowedDifficulties.contains(diff)) {
          issues.add(
            '${file.path}: line $lineNumber difficulty "$diff" not in '
            '${_allowedDifficulties.join(', ')}.',
          );
        }
      }

      if (quizSpecific) {
        final choices = record['choices'];
        final answer = record['answer'];
        if (choices is! List || choices.length < 2) {
          issues.add(
            '${file.path}: line $lineNumber quiz choices must contain ≥ 2 options.',
          );
        } else if (answer is! num || answer < 0 || answer >= choices.length) {
          issues.add(
            '${file.path}: line $lineNumber quiz answer out of range.',
          );
        }
      }

      if (!_isAscii(trimmed)) {
        issues.add('${file.path}: line $lineNumber contains non-ASCII text.');
      }

      if (titleConsistencyFields.length == 2) {
        final primary = record[titleConsistencyFields[0]]?.toString();
        final secondary = record[titleConsistencyFields[1]]?.toString();
        if (primary != null && secondary != null) {
          if (!secondary.contains(primary)) {
            issues.add(
              '${file.path}: line $lineNumber field '
              '${titleConsistencyFields[1]} should reference '
              '${titleConsistencyFields[0]}.',
            );
          }
        }
      }
    }
    return issues;
  }
}

const Set<String> _allowedDifficulties = {
  'easy',
  'medium',
  'hard',
  'adaptive',
  'quiz',
};

class _ModuleRef {
  const _ModuleRef(this.path);
  final String path;

  Future<File?> resolveFile(String fileName) async {
    final direct = File('$path/$fileName');
    if (await direct.exists()) return direct;
    final meta = File('$path/_meta/$fileName');
    if (await meta.exists()) return meta;
    return null;
  }
}

class _ModuleIssues {
  _ModuleIssues(this.path, this.issues);

  final String path;
  final List<String> issues;

  bool get hasIssues => issues.isNotEmpty;
}

Future<void> _writeSummary({
  required List<_ModuleIssues> modules,
  required int durationMs,
}) async {
  final buffer = StringBuffer()
    ..writeln('CONTENT SEMANTIC AUDIT SUMMARY')
    ..writeln('==============================')
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln('Duration: ${durationMs}ms')
    ..writeln('Modules audited: ${modules.length}')
    ..writeln();

  final failing = modules.where((module) => module.hasIssues).toList();
  if (failing.isEmpty) {
    buffer.writeln('All modules passed semantic and structural checks.');
  } else {
    buffer.writeln('Modules with issues:');
    for (final module in failing) {
      buffer.writeln('- ${module.path}');
      for (final issue in module.issues) {
        buffer.writeln('  • $issue');
      }
    }
  }

  await File(_summaryPath).writeAsString(buffer.toString());
}

Future<void> _emitTelemetry({
  required List<_ModuleIssues> modules,
  required int durationMs,
  required String verdict,
}) async {
  final payload = <String, Object?>{
    'event': 'content_semantic_audit_completed',
    'timestamp': DateTime.now().toIso8601String(),
    'verdict': verdict,
    'modules_audited': modules.length,
    'violations': modules
        .where((module) => module.hasIssues)
        .map((module) => {'module': module.path, 'issues': module.issues})
        .toList(),
    'duration_ms': durationMs,
  };
  final sink = File(_telemetryPath).openWrite(mode: FileMode.append);
  sink.writeln(jsonEncode(payload));
  await sink.close();
}

Future<void> _withReportsWritable(Future<void> Function() action) async {
  await _setPermissions(true);
  try {
    await action();
  } finally {
    await _setPermissions(false);
  }
}

Future<void> _setPermissions(bool addWrite) async {
  final mode = addWrite ? 'u+w' : 'u-w';
  await Process.run('chmod', ['-R', mode, 'release/_reports']);
}

bool _isAscii(String value) => value.codeUnits.every((code) => code <= 0x7F);
