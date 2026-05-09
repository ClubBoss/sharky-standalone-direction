import 'dart:convert';
import 'dart:io';

void main() {
  final modules = _discoverRewrittenModules();
  final buffer = StringBuffer();
  buffer.writeln('==== CONTENT RE-AUDIT MASTER ====');
  buffer.writeln(
    'module | structure | density | coherence | tte | consistency | status',
  );
  var totalPass = 0;
  var totalWarn = 0;
  var totalFail = 0;
  final topPriority = <String>[];

  for (final module in modules) {
    final result = _auditModule(module);
    buffer.writeln(
      '$module | structure=${result.structureStatus} | density=${result.densityStr} | coherence=${result.coherenceStr} | tte=${result.tteStr} | consistency=${result.consistencyStr} | status=${result.status}',
    );
    if (result.status == 'FAIL') totalFail++;
    if (result.status == 'WARN') totalWarn++;
    if (result.status == 'PASS') totalPass++;
    if (result.status != 'PASS' || result.consistencyScore < 0.55) {
      topPriority.add(module);
    }
  }

  buffer.writeln('==== GLOBAL STATS ====');
  buffer.writeln('total modules    | ${modules.length}');
  buffer.writeln('pass             | $totalPass');
  buffer.writeln('warn             | $totalWarn');
  buffer.writeln('fail             | $totalFail');
  buffer.writeln('top priority     | ${topPriority.join(', ')}');
  buffer.writeln(
    'heat map         | PASS:$totalPass WARN:$totalWarn FAIL:$totalFail',
  );

  final out = File('release/_reports/content_reaudit_master.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
  if (totalFail > 0) exit(1);
}

List<String> _discoverRewrittenModules() {
  final root = Directory('content');
  if (!root.existsSync()) return [];
  final modules = <String>{};
  const marker = '/v1/';
  final entries = root.listSync(recursive: true, followLinks: false);
  for (final entity in entries) {
    if (entity is! File) continue;
    final path = entity.path.replaceAll('\\', '/');
    if (!path.endsWith('theory.md.rewritten')) continue;
    final start = path.indexOf('content/');
    if (start < 0) continue;
    final suffix = path.substring(start + 'content/'.length);
    final v1Index = suffix.indexOf(marker);
    if (v1Index < 0) continue;
    final module = suffix.substring(0, v1Index);
    if (module.isNotEmpty) {
      modules.add(module);
    }
  }
  final list = modules.toList();
  list.sort();
  return list;
}

_AuditResult _auditModule(String module) {
  final theory = File('content/$module/v1/theory.md.rewritten');
  final explain = File('content/$module/v1/explain.json.rewritten');
  final drills = File('content/$module/v1/drills.jsonl.rewritten');
  final required = <String, File>{
    'theory': theory,
    'explain': explain,
    'drills': drills,
  };
  final missing = required.entries
      .where((entry) => !entry.value.existsSync())
      .map((entry) => entry.key)
      .toList();
  final structureStatus = missing.isEmpty
      ? 'ok'
      : 'missing(${missing.join(',')})';

  final theoryContent = theory.existsSync() ? theory.readAsStringSync() : '';
  final nonEmptyLines = theoryContent
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .length;
  final charCount = maxInt(1, theoryContent.length);
  final density = nonEmptyLines / charCount * 1000;
  var densityNormalized = density / 120;
  if (densityNormalized < 0) densityNormalized = 0;
  if (densityNormalized > 1) densityNormalized = 1;
  final densityStr = density.toStringAsFixed(1);

  final sections = [
    'Overview',
    'Core Principles',
    'Examples',
    'Mistakes / Leaks',
    'Heuristics',
    'Summary',
  ];
  final lowercase = theoryContent.toLowerCase();
  final present = sections
      .where((section) => lowercase.contains(section.toLowerCase()))
      .length;
  final coherenceScore = present / sections.length;
  final coherenceStr = coherenceScore.toStringAsFixed(2);

  final explainKeys = <String>{};
  var explainParseFail = false;
  if (explain.existsSync()) {
    try {
      final decoded = jsonDecode(explain.readAsStringSync());
      if (decoded is Map) {
        explainKeys.addAll(decoded.keys.map((k) => k.toString()));
      }
    } catch (_) {
      explainParseFail = true;
    }
  }

  final markerReg = RegExp(r'\{\{explain:([^\}]+)\}\}');
  final markers = <String>{};
  for (final match in markerReg.allMatches(theoryContent)) {
    markers.add(match.group(1)?.trim() ?? '');
  }
  final requiredKeys = markers.where((key) => key.isNotEmpty).toList();
  final defined = explainKeys.length;
  var coverageScore = 1.0;
  if (requiredKeys.isNotEmpty) {
    coverageScore = defined / requiredKeys.length;
    if (coverageScore < 0) coverageScore = 0;
    if (coverageScore > 1) coverageScore = 1;
  }
  final tteStr = coverageScore.toStringAsFixed(2);

  final drillsContent = drills.existsSync() ? drills.readAsStringSync() : '';
  final drillsLines = drillsContent.split('\n');
  var drillsJsonFailure = false;
  if (drills.existsSync()) {
    for (var i = 0; i < drillsLines.length; i++) {
      final line = drillsLines[i].trim();
      if (line.isEmpty) continue;
      try {
        jsonDecode(line);
      } catch (_) {
        drillsJsonFailure = true;
        break;
      }
    }
  }

  final explainContent = explain.existsSync() ? explain.readAsStringSync() : '';
  final combined = StringBuffer();
  combined.write(theoryContent);
  combined.write(explainContent);
  combined.write(drillsContent);
  final planFile = File('release/_reports/patch_plans/$module.txt');
  final planLines = planFile.existsSync()
      ? planFile.readAsLinesSync()
      : <String>[];
  final planStatus = _planMatch(planLines, combined.toString());

  final consistencyScore = _combineConsistency(
    structureOk: missing.isEmpty,
    densityNormalized: densityNormalized,
    coherenceScore: coherenceScore,
    tteScore: coverageScore,
  );
  final consistencyStr = consistencyScore.toStringAsFixed(2);

  final markdownStatus = _checkMarkdown(theoryContent);
  var status = 'PASS';
  if (missing.isNotEmpty ||
      explainParseFail ||
      drillsJsonFailure ||
      markdownStatus != 'PASS') {
    status = 'FAIL';
  } else if (coverageScore < 0.6 ||
      coherenceScore < 0.5 ||
      planStatus != 'PASS') {
    status = 'WARN';
  } else if (consistencyScore < 0.65) {
    status = 'WARN';
  }

  return _AuditResult(
    module: module,
    structureStatus: structureStatus,
    densityStr: densityStr,
    coherenceStr: coherenceStr,
    tteStr: tteStr,
    consistencyStr: consistencyStr,
    status: status,
    consistencyScore: consistencyScore,
  );
}

String _checkMarkdown(String content) {
  if (content.trim().isEmpty) return 'FAIL';
  if (!RegExp(r'^#{1,3}\s', multiLine: true).hasMatch(content)) {
    return 'FAIL';
  }
  if (content.contains('{{explain:') && !content.contains('}}')) {
    return 'FAIL';
  }
  if (RegExp(r'\[[^\]]*\]\([^)]*$').hasMatch(content)) {
    return 'FAIL';
  }
  return 'PASS';
}

double _combineConsistency({
  required bool structureOk,
  required double densityNormalized,
  required double coherenceScore,
  required double tteScore,
}) {
  const structureWeight = 0.3;
  const densityWeight = 0.25;
  const coherenceWeight = 0.25;
  const tteWeight = 0.2;
  final structureScore = structureOk ? 1.0 : 0.4;
  return (structureWeight * structureScore) +
      (densityWeight * densityNormalized) +
      (coherenceWeight * coherenceScore) +
      (tteWeight * tteScore);
}

String _planMatch(List<String> actions, String combined) {
  if (actions.isEmpty) return 'WARN';
  final candidate = actions
      .where((a) => a.trim().isNotEmpty)
      .map((a) => a.toLowerCase())
      .toList();
  final lower = combined.toLowerCase();
  for (final action in candidate) {
    if (action.isEmpty) continue;
    if (lower.contains(action)) {
      return 'PASS';
    }
  }
  return 'WARN';
}

int maxInt(int a, int b) => a > b ? a : b;

class _AuditResult {
  _AuditResult({
    required this.module,
    required this.structureStatus,
    required this.densityStr,
    required this.coherenceStr,
    required this.tteStr,
    required this.consistencyStr,
    required this.status,
    required this.consistencyScore,
  });

  final String module;
  final String structureStatus;
  final String densityStr;
  final String coherenceStr;
  final String tteStr;
  final String consistencyStr;
  final String status;
  final double consistencyScore;
}
