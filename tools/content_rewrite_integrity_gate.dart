import 'dart:convert';
import 'dart:io';

void main() {
  final sequence = _parseSequence();
  final plans = _loadPatchPlans();
  final buffer = StringBuffer();
  buffer.writeln('==== CONTENT REWRITE INTEGRITY GATE ====');
  var totalFail = 0;
  var totalWarn = 0;
  var totalPass = 0;

  for (final module in sequence) {
    buffer.writeln('module: $module');
    final modulePath = _modulePath(module);
    final plan = plans[module];
    final theorySnapshot = _snapshotFile(module, '.before.md');
    final explainSnapshot = _snapshotFile(module, '.before.json');
    final drillsSnapshot = _snapshotFile(module, '.before.jsonl');
    final theoryRewritten = File('$modulePath/theory.md.rewritten');
    final explainRewritten = File('$modulePath/explain.json.rewritten');
    final drillsRewritten = File('$modulePath/drills.jsonl.rewritten');
    var moduleFail = false;
    var moduleWarn = false;

    bool checkPresence(File snapshot, File rewrite, String tag) {
      if (!rewrite.existsSync()) {
        buffer.writeln('  $tag | MISSING');
        moduleFail = true;
        totalFail++;
        return false;
      }
      buffer.writeln('  $tag | PRESENT');
      return true;
    }

    final theoryPresent = theoryRewritten.existsSync();
    if (!theoryPresent) {
      buffer.writeln('  theory | MISSING');
      moduleFail = true;
      totalFail++;
    } else {
      buffer.writeln('  theory | PRESENT');
    }
    if (theorySnapshot == null) {
      buffer.writeln('  theory snapshot | MISSING');
      moduleWarn = true;
      totalWarn++;
    }

    final explainPresent = explainRewritten.existsSync();
    if (!explainPresent) {
      buffer.writeln('  explain | MISSING');
      moduleFail = true;
      totalFail++;
    } else {
      buffer.writeln('  explain | PRESENT');
    }
    if (explainSnapshot == null) {
      buffer.writeln('  explain snapshot | MISSING');
      moduleWarn = true;
      totalWarn++;
    }

    final drillsPresent = drillsRewritten.existsSync();
    if (!drillsPresent) {
      buffer.writeln('  drills | MISSING');
      moduleFail = true;
      totalFail++;
    } else {
      buffer.writeln('  drills | PRESENT');
    }
    if (drillsSnapshot == null) {
      buffer.writeln('  drills snapshot | MISSING');
      moduleWarn = true;
      totalWarn++;
    }

    final planStatus = _evaluatePlan(plan, module);
    buffer.writeln('  plan correspondence | ${planStatus.status}');
    if (planStatus.failed) {
      moduleFail = true;
      totalFail++;
    } else if (planStatus.warn) {
      moduleWarn = true;
      totalWarn++;
    }

    if (theorySnapshot != null && theoryPresent) {
      final theoryCheck = _validateTheory(
        theorySnapshot.readAsStringSync(),
        theoryRewritten.readAsStringSync(),
      );
      buffer.writeln('  theory markdown | ${theoryCheck.status}');
      if (theoryCheck.failed) {
        moduleFail = true;
        totalFail++;
      }
    }

    if (explainSnapshot != null && explainPresent) {
      final explainCheck = _validateJson(
        explainRewritten,
        'explain.json.rewritten',
      );
      buffer.writeln('  explain json | ${explainCheck.status}');
      if (explainCheck.failed) {
        moduleFail = true;
        totalFail++;
      }
    }

    if (drillsSnapshot != null && drillsPresent) {
      final drillsCheck = _validateJsonLines(
        drillsRewritten,
        'drills.jsonl.rewritten',
      );
      buffer.writeln('  drills jsonl | ${drillsCheck.status}');
      if (drillsCheck.failed) {
        moduleFail = true;
        totalFail++;
      }
    }

    if (theorySnapshot != null && theoryPresent) {
      final diff = _diffSummary(
        theorySnapshot.readAsStringSync(),
        theoryRewritten.readAsStringSync(),
      );
      buffer.writeln('  snapshot diff | $diff');
      if (diff == 'no changes detected') {
        moduleFail = true;
        totalFail++;
      }
    }

    if (moduleFail) {
      buffer.writeln('  module status | FAIL');
      totalFail++;
    } else if (moduleWarn) {
      buffer.writeln('  module status | WARN');
      totalWarn++;
    } else {
      buffer.writeln('  module status | PASS');
      totalPass++;
    }
  }

  buffer.writeln('==== TOTALS ====');
  buffer.writeln('PASS | $totalPass');
  buffer.writeln('WARN | $totalWarn');
  buffer.writeln('FAIL | $totalFail');
  final status = totalFail > 0 ? 'FAIL' : 'PASS';
  buffer.writeln('overall status | $status');

  final out = File('release/_reports/rewrite_integrity_report.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
  if (totalFail > 0) exit(1);
}

List<String> _parseSequence() {
  final path = 'release/_reports/rewrite_sequence.txt';
  final file = File(path);
  if (!file.existsSync()) return [];
  return file
      .readAsLinesSync()
      .skip(1)
      .map((line) {
        final parts = line.split('|').map((p) => p.trim()).toList();
        return parts.length > 1 ? parts[1] : '';
      })
      .where((module) => module.isNotEmpty)
      .toList();
}

Map<String, List<String>> _loadPatchPlans() {
  final dir = Directory('release/_reports/patch_plans');
  if (!dir.existsSync()) return {};
  final map = <String, List<String>>{};
  for (final entity in dir.listSync(followLinks: false)) {
    if (entity is! File) continue;
    final module = entity.path
        .split(Platform.pathSeparator)
        .last
        .replaceAll('.txt', '');
    final lines = entity
        .readAsLinesSync()
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    map[module] = lines;
  }
  return map;
}

File? _snapshotFile(String module, String suffix) {
  final base = 'release/_snapshots/$module';
  final file = File('$base/$module$suffix');
  if (file.existsSync()) {
    return file;
  }
  final alt = File('$base/${suffix.replaceAll('.before', '.before')}');
  return alt.existsSync() ? alt : null;
}

String _modulePath(String module) {
  final sanitized = module.replaceAll('\\', Platform.pathSeparator);
  return 'content/$sanitized/v1';
}

_PlanStatus _evaluatePlan(List<String>? actions, String module) {
  if (actions == null || actions.isEmpty) {
    return _PlanStatus(status: 'FAIL', failed: true);
  }
  final diffNeedle = actions
      .where((a) => a.trim().isNotEmpty)
      .map((a) => a.toLowerCase())
      .toList();
  return _PlanStatus(status: 'PASS', actions: diffNeedle);
}

_CheckStatus _validateTheory(String snapshot, String rewritten) {
  if (snapshot.trim() == rewritten.trim()) {
    return _CheckStatus(status: 'FAIL (no diff)', failed: true);
  }
  final heading = RegExp(r'^#{1,3}\s', multiLine: true);
  if (!heading.hasMatch(rewritten)) {
    return _CheckStatus(status: 'FAIL (missing heading)', failed: true);
  }
  if (rewritten.contains('{{explain:') && !rewritten.contains('}}')) {
    return _CheckStatus(status: 'FAIL (unclosed explain)', failed: true);
  }
  if (RegExp(r'\[[^\]]*\]\([^)]*$').hasMatch(rewritten)) {
    return _CheckStatus(status: 'FAIL (malformed link)', failed: true);
  }
  return _CheckStatus(status: 'PASS');
}

_CheckStatus _validateJson(File file, String label) {
  try {
    jsonDecode(file.readAsStringSync());
    return _CheckStatus(status: 'PASS');
  } catch (error) {
    return _CheckStatus(status: 'FAIL (${error.runtimeType})', failed: true);
  }
}

_CheckStatus _validateJsonLines(File file, String label) {
  final lines = file.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    final trimmed = lines[i].trim();
    if (trimmed.isEmpty) continue;
    try {
      jsonDecode(trimmed);
    } catch (error) {
      return _CheckStatus(
        status: 'FAIL (line ${i + 1}: ${error.runtimeType})',
        failed: true,
      );
    }
  }
  return _CheckStatus(status: 'PASS');
}

String _diffSummary(String before, String after) {
  if (before.trim() == after.trim()) {
    return 'no changes detected';
  }
  final beforeLines = before.split('\n');
  final afterLines = after.split('\n');
  final changes = <String>[];
  final minLen = beforeLines.length < afterLines.length
      ? beforeLines.length
      : afterLines.length;
  for (var i = 0; i < minLen; i++) {
    if (beforeLines[i] != afterLines[i]) {
      changes.add('line ${i + 1}');
    }
  }
  if (afterLines.length > beforeLines.length) {
    changes.add('added ${afterLines.length - beforeLines.length} lines');
  }
  if (beforeLines.length > afterLines.length) {
    changes.add('removed ${beforeLines.length - afterLines.length} lines');
  }
  if (changes.isEmpty) {
    changes.add('content reordered');
  }
  return 'changes: ${changes.join(', ')}';
}

class _CheckStatus {
  const _CheckStatus({
    required this.status,
    this.failed = false,
    this.warn = false,
  });

  final String status;
  final bool failed;
  final bool warn;
}

class _PlanStatus {
  _PlanStatus({
    required this.status,
    this.failed = false,
    this.warn = false,
    this.actions = const [],
  });
  final String status;
  final bool failed;
  final bool warn;
  final List<String> actions;
}
