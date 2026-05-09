import 'dart:convert';
import 'dart:io';

void main() {
  final sequence = _parseSequence();
  final planCache = _loadPatchPlans();
  final buffer = StringBuffer();
  buffer.writeln('==== CONTENT REWRITE APPLY ====');
  var modulesProcessed = 0;
  var modulesApplied = 0;
  var modulesSkipped = 0;
  var modulesFailed = 0;
  var rewrittenFiles = 0;

  for (final module in sequence) {
    modulesProcessed++;
    buffer.writeln('module: $module');
    final plan = planCache[module];
    final planExists = plan != null && plan.actions.isNotEmpty;
    if (!planExists) {
      buffer.writeln('  plan | missing or empty');
      modulesFailed++;
      buffer.writeln('  status | FAIL');
      continue;
    }
    buffer.writeln('  plan | actions=${plan.actions.length}');
    final rewriteDir = Directory(_moduleContentPath(module));
    if (!rewriteDir.existsSync()) {
      rewriteDir.createSync(recursive: true);
    }
    var moduleApplied = false;
    final fileStatuses = <String>[];
    for (final type in _FileType.values) {
      final snapshot = _snapshotFile(module, type);
      if (snapshot == null) {
        fileStatuses.add('${type.name}:missing-snapshot');
        continue;
      }
      final rewritten = File(
        '${snapshot.path.replaceAll('.before', '')}.rewritten',
      );
      if (rewritten.existsSync()) {
        fileStatuses.add('${type.name}:SKIPPED');
        continue;
      }
      final transformed = _applyActions(snapshot, type, plan.actions);
      if (transformed == null) {
        fileStatuses.add('${type.name}:FAIL');
        continue;
      }
      rewritten.parent.createSync(recursive: true);
      rewritten.writeAsStringSync(transformed);
      fileStatuses.add('${type.name}:APPLIED');
      moduleApplied = true;
      rewrittenFiles++;
    }
    final status = moduleApplied ? 'APPLIED' : 'SKIPPED';
    if (status == 'APPLIED') modulesApplied++;
    if (status == 'SKIPPED') modulesSkipped++;
    if (fileStatuses.any((s) => s.contains('missing') || s.contains('FAIL'))) {
      modulesFailed++;
    }
    buffer.writeln('  files | ${fileStatuses.join(', ')}');
    buffer.writeln('  status | $status');
  }

  buffer.writeln('==== SUMMARY ====');
  buffer.writeln('modules processed | $modulesProcessed');
  buffer.writeln('modules applied   | $modulesApplied');
  buffer.writeln('modules skipped   | $modulesSkipped');
  buffer.writeln('modules failed    | $modulesFailed');
  buffer.writeln('files rewritten   | $rewrittenFiles');

  final out = File('release/_reports/rewrite_apply_report.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
}

List<String> _parseSequence() {
  final file = File('release/_reports/rewrite_sequence.txt');
  if (!file.existsSync()) return [];
  final lines = file.readAsLinesSync();
  return lines
      .skip(1)
      .map((line) {
        final parts = line.split('|').map((p) => p.trim()).toList();
        if (parts.length < 2) return '';
        return parts[1];
      })
      .where((module) => module.isNotEmpty)
      .toList();
}

Map<String, _PatchPlanData> _loadPatchPlans() {
  final path = 'release/_reports/patch_plans';
  final dir = Directory(path);
  if (!dir.existsSync()) return {};
  final map = <String, _PatchPlanData>{};
  for (final entity in dir.listSync(followLinks: false)) {
    if (entity is! File) continue;
    final module = entity.path
        .split(Platform.pathSeparator)
        .last
        .replaceAll('.txt', '');
    final actions = entity
        .readAsLinesSync()
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    map[module] = _PatchPlanData(actions: actions);
  }
  return map;
}

String _moduleContentPath(String module) {
  final sanitized = module.replaceAll('\\', Platform.pathSeparator);
  return 'content/$sanitized/v1';
}

File? _snapshotFile(String module, _FileType type) {
  final base = 'release/_snapshots/$module';
  final path = '$base/${type.fileName}';
  final file = File(path);
  return file.existsSync() ? file : null;
}

String? _applyActions(File snapshot, _FileType type, List<String> actions) {
  try {
    final content = snapshot.readAsStringSync();
    switch (type) {
      case _FileType.theory:
        return _applyTheory(content, actions);
      case _FileType.explain:
        return _applyJson(content, actions);
      case _FileType.drills:
        return _applyJsonLines(content, actions);
    }
  } catch (_) {
    return null;
  }
}

String _applyTheory(String content, List<String> actions) {
  final buffer = StringBuffer();
  buffer.write(content.trimRight());
  if (actions.isNotEmpty) {
    buffer.writeln();
    buffer.writeln();
    buffer.writeln('<!-- REWRITE ACTIONS -->');
    for (final action in actions) {
      buffer.writeln(' - $action');
    }
    buffer.writeln('<!-- END ACTIONS -->');
  }
  return buffer.toString();
}

String _applyJson(String content, List<String> actions) {
  try {
    final decoded = jsonDecode(content);
    final mutated = _attachMeta(decoded, actions);
    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(mutated);
  } catch (_) {
    final buffer = StringBuffer();
    buffer.write(content.trimRight());
    if (actions.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('// rewrite actions:');
      for (final action in actions) {
        buffer.writeln('// - $action');
      }
    }
    return buffer.toString();
  }
}

String _applyJsonLines(String content, List<String> actions) {
  final lines = content.split('\n');
  final transformed = <String>[];
  for (var line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      transformed.add(line);
      continue;
    }
    try {
      final decoded = jsonDecode(trimmed);
      final mutated = _attachMeta(decoded, actions);
      transformed.add(jsonEncode(mutated));
    } catch (_) {
      transformed.add(line);
    }
  }
  return transformed.join('\n');
}

dynamic _attachMeta(dynamic value, List<String> actions) {
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    map['_rewriteMeta'] = {
      'actions': actions,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return map;
  } else if (value is List) {
    return value
        .map((element) => _attachMeta(element, actions))
        .toList(growable: false);
  }
  return value;
}

enum _FileType {
  theory('theory.before.md'),
  explain('explain.before.json'),
  drills('drills.before.jsonl');

  const _FileType(this.fileName);
  final String fileName;
  String get name => toString().split('.').last;
}

class _PatchPlanData {
  _PatchPlanData({required this.actions});
  final List<String> actions;
}
