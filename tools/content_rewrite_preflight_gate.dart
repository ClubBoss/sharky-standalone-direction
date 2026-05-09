import 'dart:io';

void main() {
  final sequence = _parseSequence();
  final patchPlans = _parsePatchPlanIndex();
  final planFiles = _scanPatchPlanFiles();
  final consistency = _parseConsistency();
  final density = _parseDensityNormalized();
  final tteCoverage = _parseTapExplainCoverage();
  final ttePriority = _parseTapExplainPriorityMap();
  final tteDrafts = _parseTapExplainDraftIndex();
  final buffer = StringBuffer();
  buffer.writeln('==== CONTENT REWRITE PREFLIGHT GATE ====');
  var fail = false;
  var riskScore = 0;
  var totalMissingSnapshots = 0;
  var totalMissingPlans = 0;
  var totalInvalidPlans = 0;
  var totalMissingConsistency = 0;
  var totalDensityCritical = 0;
  var totalTteIssues = 0;
  int sequenceIndex = 0;
  final seen = <String>{};

  for (final entry in sequence) {
    sequenceIndex++;
    final module = entry.module;
    buffer.writeln('module[$sequenceIndex]: $module');
    if (!seen.add(module)) {
      buffer.writeln('  FAIL | duplicate module in sequence');
      fail = true;
      riskScore += 4;
      continue;
    }
    final snapshotStatus = _snapshotStatus(module);
    if (!snapshotStatus.hasAll) {
      buffer.writeln(
        '  snapshot | missing (${snapshotStatus.missing.join(', ')})',
      );
      totalMissingSnapshots++;
      fail = true;
      riskScore += 3;
    } else {
      buffer.writeln('  snapshot | ok');
    }
    final planIndex = patchPlans[module];
    final planFile = planFiles[module];
    final planExists = planIndex != null || planFile != null;
    final planValid = (planFile?.actionable ?? planIndex?.actionable ?? false);
    if (!planExists) {
      buffer.writeln('  plan | missing');
      totalMissingPlans++;
      fail = true;
      riskScore += 5;
    } else if (!planValid) {
      buffer.writeln('  plan | invalid / no actionable steps');
      totalInvalidPlans++;
      fail = true;
      riskScore += 3;
    } else {
      buffer.writeln('  plan | actionable');
    }
    final consistencyEntry = consistency[module];
    if (consistencyEntry == null) {
      buffer.writeln('  consistency | no entry found');
      totalMissingConsistency++;
      fail = true;
      riskScore += 2;
    } else {
      buffer.writeln('  consistency | ${consistencyEntry.status}');
    }
    final densityEntry = density[module];
    final isCritical = densityEntry?.isCritical ?? false;
    if (isCritical) {
      totalDensityCritical++;
      buffer.writeln('  density | critical');
      riskScore += 3;
      if (!planValid) {
        buffer.writeln('    -> critical module without validated plan');
        fail = true;
        riskScore += 2;
      }
    }
    final coverageEntry = tteCoverage[module];
    final draftEntry = tteDrafts[module];
    final priorityEntry = ttePriority[module];
    final missingKeys = coverageEntry?.missing ?? 0;
    final hasDrafts = draftEntry?.hasDrafts ?? false;
    final allowedToRemain = priorityEntry?.allowed ?? false;
    if (missingKeys > 0) {
      if (!hasDrafts && !allowedToRemain) {
        buffer.writeln(
          '  tap-to-explain | missing drafts for $missingKeys keys',
        );
        totalTteIssues++;
        fail = true;
        riskScore += 3;
      } else {
        buffer.writeln('  tap-to-explain | drafts/allowlist satisfied');
      }
    } else {
      buffer.writeln('  tap-to-explain | coverage ok');
    }
    riskScore += snapshotStatus.extraRisk;
    riskScore += (planExists ? 0 : 1);
    if (densityEntry != null) {
      riskScore += densityEntry.severity;
    }
  }

  if (sequence.isEmpty) {
    buffer.writeln('NO SEQUENCE | rewrite sequence is empty');
    fail = true;
    riskScore += 5;
  }

  final riskThreshold = 8;
  final status = (!fail && riskScore <= riskThreshold) ? 'PASS' : 'FAIL';
  buffer.writeln('==== SUMMARY ====');
  buffer.writeln('sequence length          | ${sequence.length}');
  buffer.writeln('missing snapshots        | $totalMissingSnapshots');
  buffer.writeln('missing plans            | $totalMissingPlans');
  buffer.writeln('invalid plans            | $totalInvalidPlans');
  buffer.writeln('missing consistency rows | $totalMissingConsistency');
  buffer.writeln('critical densities        | $totalDensityCritical');
  buffer.writeln('tap-to-explain issues    | $totalTteIssues');
  buffer.writeln('risk score               | $riskScore');
  buffer.writeln('risk threshold           | $riskThreshold');
  buffer.writeln('overall status           | $status');

  final out = File('release/_reports/rewrite_preflight_gate.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
  if (status == 'FAIL') exit(1);
}

List<_SequenceEntry> _parseSequence() {
  final file = File('release/_reports/rewrite_sequence.txt');
  if (!file.existsSync()) return [];
  final lines = file.readAsLinesSync();
  final list = <_SequenceEntry>[];
  for (var i = 1; i < lines.length; i++) {
    final parts = lines[i].split('|').map((p) => p.trim()).toList();
    if (parts.length < 2) continue;
    final module = parts[1];
    list.add(_SequenceEntry(module: module));
  }
  return list;
}

Map<String, _PatchPlanIndex> _parsePatchPlanIndex() {
  final map = <String, _PatchPlanIndex>{};
  final file = File('release/_reports/patch_plans/_index.txt');
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.isEmpty) continue;
    final module = parts[0];
    final entries = parts.length > 2 ? parts[2] : '';
    final actions = entries
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    map[module] = _PatchPlanIndex(actionable: actions.isNotEmpty);
  }
  return map;
}

Map<String, _PlanFile> _scanPatchPlanFiles() {
  final map = <String, _PlanFile>{};
  final dir = Directory('release/_reports/patch_plans');
  if (!dir.existsSync()) return map;
  for (final entity in dir.listSync(followLinks: false)) {
    if (entity is! File) continue;
    final name = entity.path.split(Platform.pathSeparator).last;
    if (!name.endsWith('.txt')) continue;
    final module = name.replaceAll('.txt', '');
    final lines = entity
        .readAsLinesSync()
        .where((l) => l.trim().isNotEmpty)
        .toList();
    final actionable = lines.any(
      (line) =>
          line.contains('Action') ||
          line.contains('- ') ||
          line.contains(':') ||
          RegExp(r'\bfix\b', caseSensitive: false).hasMatch(line),
    );
    map[module] = _PlanFile(actionable: actionable, lineCount: lines.length);
  }
  return map;
}

Map<String, _ConsistencyRow> _parseConsistency() {
  final file = File('release/_reports/content_consistency_map.txt');
  final map = <String, _ConsistencyRow>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 2) continue;
    map[parts[1]] = _ConsistencyRow(status: parts.length > 2 ? parts[2] : 'ok');
  }
  return map;
}

Map<String, _DensityStatus> _parseDensityNormalized() {
  final file = File('release/_reports/theory_density_normalized.txt');
  final map = <String, _DensityStatus>{};
  if (!file.existsSync()) return map;
  String? module;
  for (final raw in file.readAsLinesSync()) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    if (line.startsWith('module:')) {
      module = line.split(':').sublist(1).join(':').trim();
      map[module] = _DensityStatus(module: module);
      continue;
    }
    if (module == null) continue;
    final statusMatch = RegExp(r'\((.*?)\)').firstMatch(line);
    final status = statusMatch?.group(1)?.toLowerCase();
    if (line.startsWith('density:')) {
      map[module] = map[module]!.copyWith(
        densityStatus: status,
        severity: status == 'critical' ? 2 : 0,
      );
    } else if (line.startsWith('coherence:')) {
      map[module] = map[module]!.copyWith(coherenceStatus: status);
    } else if (line.startsWith('coverage:')) {
      map[module] = map[module]!.copyWith(coverageStatus: status);
    }
  }
  return map;
}

Map<String, _TapExplainCoverage> _parseTapExplainCoverage() {
  final file = File('release/_reports/tap_to_explain_coverage.txt');
  final map = <String, _TapExplainCoverage>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('=')) continue;
    final parts = trimmed.split('|').map((p) => p.trim()).toList();
    if (parts.length < 5) continue;
    final module = parts[0];
    final missing = int.tryParse(parts[3]) ?? 0;
    map[module] = _TapExplainCoverage(missing: missing);
  }
  return map;
}

Map<String, _TapExplainPriority> _parseTapExplainPriorityMap() {
  final file = File('release/_reports/tap_to_explain_priority_map.txt');
  final map = <String, _TapExplainPriority>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('=')) continue;
    final parts = trimmed.split('|').map((p) => p.trim()).toList();
    if (parts.length < 6) continue;
    final module = parts[1];
    final missing = int.tryParse(parts[3]) ?? 0;
    final heat = parts[5];
    final allowed = trimmed.toLowerCase().contains('allow');
    map[module] = _TapExplainPriority(
      heat: heat,
      missing: missing,
      allowed: allowed,
    );
  }
  return map;
}

Map<String, _TapExplainDraftStatus> _parseTapExplainDraftIndex() {
  final file = File('release/_reports/tap_to_explain_drafts/_index.txt');
  final map = <String, _TapExplainDraftStatus>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.isEmpty) continue;
    final module = parts[0];
    final missingPart = parts.length > 1 ? parts[1] : '';
    final missing = missingPart.isEmpty
        ? <String>[]
        : missingPart
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
    map[module] = _TapExplainDraftStatus(missingKeys: missing);
  }
  return map;
}

_SnapshotStatus _snapshotStatus(String module) {
  final basePath = 'release/_snapshots/$module';
  final required = [
    'theory.before.md',
    'explain.before.json',
    'drills.before.jsonl',
  ];
  final missing = <String>[];
  for (final name in required) {
    final file = File('$basePath/$name');
    if (!file.existsSync()) missing.add(name);
  }
  return _SnapshotStatus(missing: missing);
}

class _SequenceEntry {
  _SequenceEntry({required this.module});
  final String module;
}

class _PatchPlanIndex {
  _PatchPlanIndex({required this.actionable});
  final bool actionable;
}

class _PlanFile {
  _PlanFile({required this.actionable, required this.lineCount});
  final bool actionable;
  final int lineCount;
}

class _ConsistencyRow {
  _ConsistencyRow({required this.status});
  final String status;
}

class _DensityStatus {
  _DensityStatus({
    required this.module,
    this.densityStatus,
    this.coherenceStatus,
    this.coverageStatus,
    this.severity = 0,
  });

  final String module;
  final String? densityStatus;
  final String? coherenceStatus;
  final String? coverageStatus;
  final int severity;

  _DensityStatus copyWith({
    String? densityStatus,
    String? coherenceStatus,
    String? coverageStatus,
    int? severity,
  }) {
    return _DensityStatus(
      module: module,
      densityStatus: densityStatus ?? this.densityStatus,
      coherenceStatus: coherenceStatus ?? this.coherenceStatus,
      coverageStatus: coverageStatus ?? this.coverageStatus,
      severity: severity ?? this.severity,
    );
  }

  bool get isCritical =>
      densityStatus == 'critical' ||
      coherenceStatus == 'critical' ||
      coverageStatus == 'critical';
}

class _TapExplainCoverage {
  _TapExplainCoverage({required this.missing});
  final int missing;
}

class _TapExplainPriority {
  _TapExplainPriority({
    required this.heat,
    required this.missing,
    required this.allowed,
  });
  final String heat;
  final int missing;
  final bool allowed;
}

class _TapExplainDraftStatus {
  _TapExplainDraftStatus({required this.missingKeys});
  final List<String> missingKeys;
  bool get hasDrafts => missingKeys.isNotEmpty;
}

class _SnapshotStatus {
  _SnapshotStatus({required this.missing});
  final List<String> missing;
  bool get hasAll => missing.isEmpty;
  int get extraRisk => missing.isEmpty ? 0 : missing.length;
}
