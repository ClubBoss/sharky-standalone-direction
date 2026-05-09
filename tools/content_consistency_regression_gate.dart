import 'dart:io';

void main() {
  final structure = _parseStructure();
  final density = _parseTheoryDensity();
  final normalized = _parseNormalized();
  final tte = _parseCoverage();
  final priority = _parseHotPriority();
  final consistency = _parseConsistencyHeat();
  final scorecardIndex = _parseScorecards();
  final patchIndex = _parsePatchPlans();
  final buffer = StringBuffer();
  buffer.writeln('==== CONTENT CONSISTENCY REGRESSION GATE ====');
  var fail = false;
  for (final entry in structure.entries) {
    if (entry.value.missing > 0) {
      buffer.writeln('FAIL | ${entry.key} missing required files');
      fail = true;
    }
  }
  final avgDensity = density['avgDensity'] ?? 0.0;
  final avgCoherence = normalized['avgCoherence'] ?? 0.0;
  if (avgDensity < 80 || avgDensity > 140) {
    buffer.writeln(
      'WARN | density out of ideal range: ${avgDensity.toStringAsFixed(2)}',
    );
  }
  if (avgCoherence < 0.8) {
    buffer.writeln('WARN | low coherence: ${avgCoherence.toStringAsFixed(2)}');
  }
  if (tte['coverage'] != null && tte['coverage']! < 0.9) {
    buffer.writeln(
      'FAIL | tap-to-explain coverage below 0.9: ${tte['coverage']!.toStringAsFixed(2)}',
    );
    fail = true;
  }
  if (priority.isNotEmpty) {
    buffer.writeln(
      'WARN | High priority modules detected: ${priority.join(', ')}',
    );
  }
  buffer.writeln(
    'Consistency heat | ${consistency['Hot']} Hot / ${consistency['Warm']} Warm / ${consistency['OK']} OK',
  );
  if (consistency['Hot']! > (consistency['OK'] ?? 0)) {
    buffer.writeln('FAIL | Consistency heat tipping toward Hot');
    fail = true;
  }
  buffer.writeln('Scorecards | ${scorecardIndex.length} entries');
  buffer.writeln('Patch plans | ${patchIndex.length} entries');
  final report = File(
    'release/_reports/content_consistency_regression_gate.txt',
  );
  report.parent.createSync(recursive: true);
  report.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
  if (fail) exit(1);
}

Map<String, _StructureRow> _parseStructure() {
  final file = File('release/_reports/content_structure_audit.txt');
  final map = <String, _StructureRow>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 5) continue;
    final missing = parts[1] == 'none' ? 0 : parts[1].split(',').length;
    map[parts[0]] = _StructureRow(module: parts[0], missing: missing);
  }
  return map;
}

Map<String, double> _parseTheoryDensity() {
  final file = File('release/_reports/content_theory_density.txt');
  final map = {'avgDensity': 0.0, 'avgChars': 0.0, 'avgLines': 0.0};
  if (!file.existsSync()) return map;
  var count = 0;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 6) continue;
    map['avgDensity'] = map['avgDensity']! + (double.tryParse(parts[3]) ?? 0);
    map['avgChars'] = map['avgChars']! + (double.tryParse(parts[1]) ?? 0);
    map['avgLines'] = map['avgLines']! + (double.tryParse(parts[2]) ?? 0);
    count++;
  }
  if (count > 0) {
    map['avgDensity'] = map['avgDensity']! / count;
    map['avgChars'] = map['avgChars']! / count;
    map['avgLines'] = map['avgLines']! / count;
  }
  return map;
}

Map<String, double> _parseNormalized() {
  final file = File('release/_reports/theory_density_normalized.txt');
  final map = {'avgCoherence': 0.0};
  if (!file.existsSync()) return map;
  var count = 0;
  final lines = file.readAsLinesSync();
  for (final line in lines) {
    if (!line.startsWith('coherence:')) continue;
    final value =
        double.tryParse(line.split(':').last.split('(').first.trim()) ?? 0.0;
    map['avgCoherence'] = map['avgCoherence']! + value;
    count++;
  }
  if (count > 0) map['avgCoherence'] = map['avgCoherence']! / count;
  return map;
}

Map<String, double> _parseCoverage() {
  final file = File('release/_reports/tap_to_explain_coverage.txt');
  final map = {'coverage': 0.0};
  if (!file.existsSync()) return map;
  var total = 0.0;
  var count = 0;
  final lines = file.readAsLinesSync();
  for (var i = 1; i < lines.length; i++) {
    final parts = lines[i].split('|').map((p) => p.trim()).toList();
    if (parts.length < 5) continue;
    total += double.tryParse(parts[4]) ?? 0.0;
    count++;
  }
  if (count > 0) map['coverage'] = total / count;
  return map;
}

List<String> _parseHotPriority() {
  final file = File('release/_reports/tap_to_explain_priority_map.txt');
  if (!file.existsSync()) return [];
  final hot = <String>[];
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 3) continue;
    if (parts[2] == 'CRITICAL' || parts[2] == 'HIGH') hot.add(parts[0]);
  }
  return hot;
}

Map<String, int> _parseConsistencyHeat() {
  final file = File('release/_reports/content_consistency_map.txt');
  final counts = {'OK': 0, 'Warm': 0, 'Hot': 0};
  if (!file.existsSync()) return counts;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 7) continue;
    final heat = parts[6];
    if (counts.containsKey(heat)) counts[heat] = counts[heat]! + 1;
  }
  return counts;
}

List<String> _parseScorecards() {
  final file = File('release/_reports/scorecards/_index.txt');
  if (!file.existsSync()) return [];
  final list = <String>[];
  for (final line in file.readAsLinesSync().skip(1)) {
    final module = line.split('|').first.trim();
    list.add(module);
  }
  return list;
}

List<String> _parsePatchPlans() {
  final file = File('release/_reports/patch_plans/_index.txt');
  if (!file.existsSync()) return [];
  final list = <String>[];
  for (final line in file.readAsLinesSync().skip(1)) {
    final module = line.split('|').first.trim();
    list.add(module);
  }
  return list;
}

class _StructureRow {
  _StructureRow({required this.module, required this.missing});

  final String module;
  final int missing;
}
