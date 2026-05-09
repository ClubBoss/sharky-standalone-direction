import 'dart:io';

void main() {
  final sequence = _parseSequence();
  final complexity = _parseComplexity();
  final consistency = _parseConsistency();
  final patchPlans = _parsePatchPlans();
  final buffer = StringBuffer();
  buffer.writeln('==== CONTENT REWRITE REGRESSION GATE ====');
  var fail = false;
  final seen = <String>{};
  String previousTier = 'TIER 4';
  for (var i = 0; i < sequence.length; i++) {
    final entry = sequence[i];
    final tier = complexity[entry.module]?.tier ?? 'TIER 1';
    if (!complexity.containsKey(entry.module)) {
      buffer.writeln('FAIL | missing complexity entry for ${entry.module}');
      fail = true;
      continue;
    }
    if (seen.contains(entry.module)) {
      buffer.writeln('FAIL | duplicate module ${entry.module} in sequence');
      fail = true;
    }
    seen.add(entry.module);
    if (_tierValue(tier) > _tierValue(previousTier)) {
      buffer.writeln('FAIL | tier increase detected at ${entry.module}');
      fail = true;
    }
    previousTier = tier;
    final heat = consistency[entry.module]?.heat ?? 'Warm';
    if ((_heatValue(heat) >= 3) && (entry.rank > 40)) {
      buffer.writeln(
        'FAIL | high-heat module ${entry.module} scheduled too late',
      );
      fail = true;
    }
    if (!patchPlans.containsKey(entry.module)) {
      buffer.writeln('FAIL | missing patch plan for ${entry.module}');
      fail = true;
    }
    if ((consistency[entry.module]?.missing ?? 0) > 0) {
      buffer.writeln('FAIL | module ${entry.module} has missing assets');
      fail = true;
    }
  }
  final missingPlans = complexity.keys
      .where((module) => !patchPlans.containsKey(module))
      .toList();
  if (missingPlans.isNotEmpty) {
    buffer.writeln('FAIL | missing patch plans: ${missingPlans.join(', ')}');
    fail = true;
  }
  if (!fail) buffer.writeln('Status | PASS');
  final out = File('release/_reports/rewrite_regression_gate.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
  if (fail) exit(1);
}

List<_SequenceEntry> _parseSequence() {
  final file = File('release/_reports/rewrite_sequence.txt');
  if (!file.existsSync()) return [];
  final lines = file.readAsLinesSync();
  final list = <_SequenceEntry>[];
  for (var i = 1; i < lines.length; i++) {
    final parts = lines[i].split('|').map((p) => p.trim()).toList();
    if (parts.length < 6) continue;
    final rank = int.tryParse(parts[0]) ?? i;
    list.add(_SequenceEntry(module: parts[1], rank: rank));
  }
  return list;
}

Map<String, _ComplexityRow> _parseComplexity() {
  final file = File('release/_reports/rewrite_complexity_index.txt');
  final map = <String, _ComplexityRow>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 3) continue;
    map[parts[0]] = _ComplexityRow(module: parts[0], tier: parts[2]);
  }
  return map;
}

Map<String, _ConsistencyRow> _parseConsistency() {
  final file = File('release/_reports/content_consistency_map.txt');
  final map = <String, _ConsistencyRow>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 7) continue;
    final heat = parts[6];
    final missing = parts[2] == 'ok' ? 0 : 1;
    map[parts[1]] = _ConsistencyRow(heat: heat, missing: missing);
  }
  return map;
}

Map<String, _PatchPlan> _parsePatchPlans() {
  final file = File('release/_reports/patch_plans/_index.txt');
  final map = <String, _PatchPlan>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 2) continue;
    map[parts[0]] = _PatchPlan(action: parts[2]);
  }
  return map;
}

int _tierValue(String tier) {
  switch (tier) {
    case 'TIER 4':
      return 4;
    case 'TIER 3':
      return 3;
    case 'TIER 2':
      return 2;
    default:
      return 1;
  }
}

int _heatValue(String heat) {
  switch (heat) {
    case 'Hot':
      return 3;
    case 'Warm':
      return 2;
    default:
      return 1;
  }
}

class _SequenceEntry {
  _SequenceEntry({required this.module, required this.rank});
  final String module;
  final int rank;
}

class _ComplexityRow {
  _ComplexityRow({required this.module, required this.tier});
  final String module;
  final String tier;
}

class _ConsistencyRow {
  _ConsistencyRow({required this.heat, required this.missing});
  final String heat;
  final int missing;
}

class _PatchPlan {
  _PatchPlan({required this.action});
  final String action;
}
