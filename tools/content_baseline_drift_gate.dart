import 'dart:convert';
import 'dart:io';

void main() {
  final baselineRoot = Directory('release/_baseline');
  if (!baselineRoot.existsSync()) {
    stdout.writeln('Baseline directory missing');
    exit(1);
  }
  final modules = baselineRoot
      .listSync(followLinks: false)
      .whereType<Directory>()
      .toList();
  modules.sort((a, b) => a.path.compareTo(b.path));
  final buffer = StringBuffer();
  buffer.writeln('==== CONTENT BASELINE DRIFT GATE ====');
  var totalPass = 0;
  var totalDrift = 0;
  var totalFail = 0;
  var driftDetected = false;

  for (final moduleDir in modules) {
    final module = moduleDir.path.split(Platform.pathSeparator).last;
    buffer.writeln('module: $module');
    final baselineTheory = File('${moduleDir.path}/theory.md');
    final baselineExplain = File('${moduleDir.path}/explain.json');
    final baselineDrills = File('${moduleDir.path}/drills.jsonl');
    final rewrittenTheory = File('content/$module/v1/theory.md.rewritten');
    final rewrittenExplain = File('content/$module/v1/explain.json.rewritten');
    final rewrittenDrills = File('content/$module/v1/drills.jsonl.rewritten');
    final issues = <String>[];
    bool fail = false;

    void checkPresence(File baseline, File rewritten, String label) {
      if (!baseline.existsSync()) {
        issues.add('$label baseline missing');
        fail = true;
      }
      if (!rewritten.existsSync()) {
        issues.add('$label rewritten missing');
        fail = true;
      }
    }

    checkPresence(baselineTheory, rewrittenTheory, 'theory');
    checkPresence(baselineExplain, rewrittenExplain, 'explain');
    checkPresence(baselineDrills, rewrittenDrills, 'drills');

    if (fail) {
      buffer.writeln('  status | FAIL');
      buffer.writeln('  reasons | ${issues.join('; ')}');
      totalFail++;
      driftDetected = true;
      continue;
    }

    if (!_compareFiles(baselineTheory, rewrittenTheory)) {
      issues.add('theory content drift');
    }
    if (!_compareJson(baselineExplain, rewrittenExplain)) {
      issues.add('explain json drift');
    }
    if (!_compareJsonLines(baselineDrills, rewrittenDrills)) {
      issues.add('drills jsonl drift');
    }

    final markdownCheck = _checkMarkdown(rewrittenTheory.readAsStringSync());
    if (markdownCheck != 'PASS') {
      issues.add('theory markdown violation: $markdownCheck');
    }

    if (issues.isEmpty) {
      buffer.writeln('  status | PASS');
      totalPass++;
      continue;
    }

    buffer.writeln('  status | DRIFT');
    buffer.writeln('  reasons | ${issues.join('; ')}');
    totalDrift++;
    driftDetected = true;
  }

  buffer.writeln('==== GLOBAL SUMMARY ====');
  buffer.writeln('PASS  | $totalPass');
  buffer.writeln('DRIFT | $totalDrift');
  buffer.writeln('FAIL  | $totalFail');
  final summary = File('release/_reports/baseline_drift_gate.txt');
  summary.parent.createSync(recursive: true);
  summary.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
  if (driftDetected) exit(1);
}

bool _compareFiles(File baseline, File rewritten) {
  final baseLines = baseline.readAsLinesSync();
  final writtenLines = rewritten.readAsLinesSync();
  if (baseLines.length != writtenLines.length) return false;
  for (var i = 0; i < baseLines.length; i++) {
    if (baseLines[i].trim() != writtenLines[i].trim()) return false;
  }
  return true;
}

bool _compareJson(File baseline, File rewritten) {
  try {
    final base = jsonDecode(baseline.readAsStringSync());
    final rewrittenJson = jsonDecode(rewritten.readAsStringSync());
    return jsonEncode(base) == jsonEncode(rewrittenJson);
  } catch (_) {
    return false;
  }
}

bool _compareJsonLines(File baseline, File rewritten) {
  final baseLines = baseline.readAsLinesSync();
  final rewrittenLines = rewritten.readAsLinesSync();
  if (baseLines.length != rewrittenLines.length) return false;
  for (var i = 0; i < baseLines.length; i++) {
    final left = baseLines[i].trim();
    final right = rewrittenLines[i].trim();
    if (left.isEmpty && right.isEmpty) continue;
    try {
      final decodedBase = jsonDecode(left);
      final decodedRewrite = jsonDecode(right);
      if (jsonEncode(decodedBase) != jsonEncode(decodedRewrite)) return false;
    } catch (_) {
      return false;
    }
  }
  return true;
}

String _checkMarkdown(String content) {
  if (content.trim().isEmpty) return 'empty';
  if (!RegExp(r'^#{1,3}\s', multiLine: true).hasMatch(content)) {
    return 'missing-heading';
  }
  if (content.contains('{{explain:') && !content.contains('}}')) {
    return 'unclosed-explain';
  }
  if (RegExp(r'\[[^\]]*\]\([^)]*$').hasMatch(content)) {
    return 'malformed-link';
  }
  return 'PASS';
}
