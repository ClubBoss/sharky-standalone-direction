import 'dart:convert';
import 'dart:io';

void main() {
  final targetModules = _readReauditModules();
  final discovered = targetModules.isNotEmpty
      ? targetModules
      : _discoverRewrittenModules();
  final buffer = StringBuffer();
  buffer.writeln('==== CONTENT STABILIZATION SNAPSHOT ====');
  var totalModules = 0;
  var totalSnapped = 0;
  var totalSkipped = 0;
  var totalFailed = 0;
  final skipped = <String, String>{};
  final baselineRoot = Directory('release/_baseline');
  baselineRoot.createSync(recursive: true);

  for (final module in discovered) {
    totalModules++;
    final theory = File('content/$module/v1/theory.md.rewritten');
    final explain = File('content/$module/v1/explain.json.rewritten');
    final drills = File('content/$module/v1/drills.jsonl.rewritten');
    final missing = <String>[];
    if (!theory.existsSync()) missing.add('theory');
    if (!explain.existsSync()) missing.add('explain');
    if (!drills.existsSync()) missing.add('drills');
    if (missing.isNotEmpty) {
      totalSkipped++;
      skipped[module] = 'missing ${missing.join(',')}';
      buffer.writeln(
        'module: $module | SKIPPED | missing ${missing.join(', ')}',
      );
      continue;
    }

    final markdownCheck = _checkMarkdown(theory.readAsStringSync());
    final explainCheck = _checkJson(explain);
    final drillsCheck = _checkJsonLines(drills);
    if (markdownCheck != 'PASS' ||
        explainCheck != 'PASS' ||
        drillsCheck != 'PASS') {
      totalFailed++;
      buffer.writeln(
        'module: $module | FAIL | theory=$markdownCheck explain=$explainCheck drills=$drillsCheck',
      );
      continue;
    }

    final moduleBase = Directory('${baselineRoot.path}/$module');
    moduleBase.createSync(recursive: true);
    File(
      '${moduleBase.path}/theory.md',
    ).writeAsStringSync(theory.readAsStringSync());
    File(
      '${moduleBase.path}/explain.json',
    ).writeAsStringSync(explain.readAsStringSync());
    File(
      '${moduleBase.path}/drills.jsonl',
    ).writeAsStringSync(drills.readAsStringSync());
    totalSnapped++;
    buffer.writeln('module: $module | SNAPPED | status=PASS');
  }

  buffer.writeln('==== SUMMARY ====');
  buffer.writeln('modules evaluated  | $totalModules');
  buffer.writeln('modules snapped    | $totalSnapped');
  buffer.writeln('modules skipped    | $totalSkipped');
  buffer.writeln('modules failed     | $totalFailed');
  buffer.writeln('baseline root      | ${baselineRoot.path}');
  if (skipped.isNotEmpty) {
    buffer.writeln('skipped detail     |');
    for (final entry in skipped.entries) {
      buffer.writeln('  - ${entry.key}: ${entry.value}');
    }
  }

  final out = File('release/_reports/stabilization_snapshot.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
  if (totalFailed > 0) exit(1);
}

List<String> _readReauditModules() {
  final file = File('release/_reports/content_reaudit_master.txt');
  if (!file.existsSync()) return [];
  final modules = <String>{};
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('====')) continue;
    final parts = trimmed.split('|').map((p) => p.trim()).toList();
    if (parts.isEmpty) continue;
    final module = parts[0];
    if (module.isNotEmpty) {
      modules.add(module);
    }
  }
  final list = modules.toList();
  list.sort();
  return list;
}

List<String> _discoverRewrittenModules() {
  final modules = <String>{};
  const marker = '/v1/';
  final dir = Directory('content');
  if (!dir.existsSync()) return [];
  for (final entity in dir.listSync(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    final path = entity.path.replaceAll('\\', '/');
    if (!path.endsWith('theory.md.rewritten')) continue;
    final start = path.indexOf('content/');
    if (start < 0) continue;
    final suffix = path.substring(start + 'content/'.length);
    final v1Index = suffix.indexOf(marker);
    if (v1Index < 0) continue;
    final module = suffix.substring(0, v1Index);
    if (module.isNotEmpty) modules.add(module);
  }
  final list = modules.toList();
  list.sort();
  return list;
}

String _checkMarkdown(String content) {
  if (content.trim().isEmpty) return 'FAIL(empty)';
  if (!RegExp(r'^#{1,3}\s', multiLine: true).hasMatch(content)) {
    return 'FAIL(no heading)';
  }
  if (content.contains('{{explain:') && !content.contains('}}')) {
    return 'FAIL(unclosed explain)';
  }
  if (RegExp(r'\[[^\]]*\]\([^)]*$').hasMatch(content)) {
    return 'FAIL(malformed link)';
  }
  return 'PASS';
}

String _checkJson(File file) {
  try {
    jsonDecode(file.readAsStringSync());
    return 'PASS';
  } catch (error) {
    return 'FAIL(${error.runtimeType})';
  }
}

String _checkJsonLines(File file) {
  final lines = file.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    final trimmed = lines[i].trim();
    if (trimmed.isEmpty) continue;
    try {
      jsonDecode(trimmed);
    } catch (error) {
      return 'FAIL(line ${i + 1}: ${error.runtimeType})';
    }
  }
  return 'PASS';
}
