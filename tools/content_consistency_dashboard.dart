import 'dart:io';

void main() {
  final structure = _parseStructure();
  final theory = _parseTheory();
  final normalized = _parseNormalized();
  final tte = _parseTTE();
  final priority = _parsePriority();
  final consistency = _parseConsistency();
  final scorecards = _parseScorecards();
  final buffer = StringBuffer();
  buffer.writeln('==== CONSISTENCY MASTER OVERVIEW ====');
  final avgChars = structure['modules']! > 0 ? theory['avgChars']! : 0.0;
  final avgLines = structure['modules']! > 0 ? theory['avgLines']! : 0.0;
  final avgDensity = structure['modules']! > 0 ? theory['avgDensity']! : 0.0;
  final avgCoherence = normalized['avgCoherence'] ?? 0.0;
  final coverageValue = tte['coverage'] ?? 0.0;
  final missingValue = tte['missing']?.toInt() ?? 0;
  buffer.writeln(
    'Structure | modules=${structure['modules']} missing=${structure['missing']} extras=${structure['extras']} orderIssues=${structure['order']}',
  );
  buffer.writeln(
    'Density   | avgChars=${avgChars.toStringAsFixed(0)} avgLines=${avgLines.toStringAsFixed(0)} avgDensity=${avgDensity.toStringAsFixed(2)}',
  );
  buffer.writeln('Coherence | avg=${avgCoherence.toStringAsFixed(2)}');
  buffer.writeln(
    'Tap-to-Explain | coverage=${coverageValue.toStringAsFixed(2)} missing=$missingValue',
  );
  buffer.writeln('Priority Map | top10=${priority.length}');
  for (var i = 0; i < priority.length; i++) {
    final entry = priority[i];
    buffer.writeln(
      '${i + 1}. ${entry.module} score=${entry.priority.toStringAsFixed(1)} heat=${entry.heat}',
    );
  }
  buffer.writeln(
    'Consistency Heat | OK=${consistency['OK']} Warm=${consistency['Warm']} Hot=${consistency['Hot']}',
  );
  buffer.writeln(
    'Scorecards | modules=${scorecards['count']} heatOK=${scorecards['ok']} heatWarm=${scorecards['warm']} heatHot=${scorecards['hot']}',
  );
  final out = File('release/_reports/content_consistency_dashboard.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
}

Map<String, int> _parseStructure() {
  final file = File('release/_reports/content_structure_audit.txt');
  final map = {'modules': 0, 'missing': 0, 'extras': 0, 'order': 0};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final cols = line.split('|').map((p) => p.trim()).toList();
    if (cols.length < 5) continue;
    map['modules'] = map['modules']! + 1;
    if (cols[1] != 'none')
      map['missing'] = map['missing']! + cols[1].split(',').length;
    if (cols[3] != 'none')
      map['extras'] = map['extras']! + cols[3].split(',').length;
    if (cols[4] == 'order-bad') map['order'] = map['order']! + 1;
  }
  return map;
}

Map<String, double> _parseTheory() {
  final file = File('release/_reports/content_theory_density.txt');
  final map = {'avgChars': 0.0, 'avgLines': 0.0, 'avgDensity': 0.0};
  if (!file.existsSync()) return map;
  final lines = file.readAsLinesSync();
  var count = 0;
  for (final line in lines.skip(1)) {
    final cols = line.split('|').map((p) => p.trim()).toList();
    if (cols.length < 6) continue;
    final chars = double.tryParse(cols[1]) ?? 0;
    final linesNumber = double.tryParse(cols[2]) ?? 0;
    final density = double.tryParse(cols[3]) ?? 0;
    map['avgChars'] = map['avgChars']! + chars;
    map['avgLines'] = map['avgLines']! + linesNumber;
    map['avgDensity'] = map['avgDensity']! + density;
    count++;
  }
  if (count > 0) {
    map['avgChars'] = map['avgChars']! / count;
    map['avgLines'] = map['avgLines']! / count;
    map['avgDensity'] = map['avgDensity']! / count;
  }
  return map;
}

Map<String, double> _parseNormalized() {
  final file = File('release/_reports/theory_density_normalized.txt');
  final map = {'avgCoherence': 0.0};
  if (!file.existsSync()) return map;
  final lines = file.readAsLinesSync();
  var count = 0;
  for (final line in lines) {
    if (!line.startsWith('coherence:')) continue;
    final value =
        double.tryParse(line.split(':').last.split('(').first.trim()) ?? 0;
    map['avgCoherence'] = map['avgCoherence']! + value;
    count++;
  }
  if (count > 0) map['avgCoherence'] = map['avgCoherence']! / count;
  return map;
}

Map<String, double> _parseTTE() {
  final file = File('release/_reports/tap_to_explain_coverage.txt');
  final map = {'coverage': 0.0, 'missing': 0.0};
  if (!file.existsSync()) return map;
  final lines = file.readAsLinesSync();
  var totalCoverage = 0.0;
  var totalMissing = 0.0;
  var count = 0;
  for (var i = 1; i < lines.length; i++) {
    final cols = lines[i].split('|').map((p) => p.trim()).toList();
    if (cols.length < 5) continue;
    final coverage = double.tryParse(cols[4]) ?? 0;
    totalCoverage += coverage;
    totalMissing += double.tryParse(cols[3]) ?? 0;
    count++;
  }
  if (count > 0) {
    map['coverage'] = totalCoverage / count;
    map['missing'] = totalMissing;
  }
  return map;
}

List<_PriorityRow> _parsePriority() {
  final file = File('release/_reports/tap_to_explain_priority_map.txt');
  if (!file.existsSync()) return [];
  final rows = <_PriorityRow>[];
  final lines = file.readAsLinesSync();
  for (var i = 1; i < lines.length; i++) {
    final parts = lines[i].split('|').map((p) => p.trim()).toList();
    if (parts.length < 6) continue;
    rows.add(
      _PriorityRow(
        module: parts[1],
        priority: double.tryParse(parts[4]) ?? 0.0,
        heat: parts[5],
      ),
    );
  }
  rows.sort((a, b) => b.priority.compareTo(a.priority));
  return rows.take(10).toList();
}

Map<String, int> _parseConsistency() {
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

Map<String, int> _parseScorecards() {
  final file = File('release/_reports/scorecards/_index.txt');
  final counts = {'count': 0, 'ok': 0, 'warm': 0, 'hot': 0};
  if (!file.existsSync()) return counts;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 3) continue;
    counts['count'] = counts['count']! + 1;
    final heat = parts[1];
    if (heat == 'OK') counts['ok'] = counts['ok']! + 1;
    if (heat == 'Warm') counts['warm'] = counts['warm']! + 1;
    if (heat == 'Hot') counts['hot'] = counts['hot']! + 1;
  }
  return counts;
}

class _PriorityRow {
  _PriorityRow({
    required this.module,
    required this.priority,
    required this.heat,
  });

  final String module;
  final double priority;
  final String heat;
}
