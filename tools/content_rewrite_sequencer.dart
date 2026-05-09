import 'dart:io';

void main() {
  final complexity = _parseComplexity();
  final priority = _parsePriority();
  final execution = _parseExecutionPlan();
  final modules = <String>{}
    ..addAll(complexity.keys)
    ..addAll(priority.keys)
    ..addAll(execution.keys);
  final entries = <_Entry>[];
  for (final module in modules) {
    final tier = complexity[module]?.tier ?? 'TIER 1';
    final score = complexity[module]?.score ?? 0.0;
    final priorityBand = priority[module] ?? 'LOW';
    final execOrder = execution[module] ?? 999;
    final effort = (score / 25).clamp(1, 5).toInt();
    final parallel = priorityBand == 'LOW' ? 'yes' : 'no';
    entries.add(
      _Entry(
        module: module,
        tier: tier,
        priority: priorityBand,
        effort: effort,
        parallel: parallel,
        order: execOrder,
        score: score,
      ),
    );
  }
  entries.sort((a, b) {
    final tierOrder = _tierValue(b.tier).compareTo(_tierValue(a.tier));
    if (tierOrder != 0) return tierOrder;
    final prioOrder = _priorityValue(
      a.priority,
    ).compareTo(_priorityValue(b.priority));
    if (prioOrder != 0) return prioOrder;
    return a.order.compareTo(b.order);
  });
  final buffer = StringBuffer();
  buffer.writeln('==== REWRITE SEQUENCE ====');
  buffer.writeln('seq | module | tier | priority | effort | parallel');
  for (var i = 0; i < entries.length; i++) {
    final entry = entries[i];
    buffer.writeln(
      '${(i + 1).toString().padLeft(3)} | ${entry.module.padRight(30)} | ${entry.tier.padRight(6)} | ${entry.priority.padRight(6)} | ${entry.effort} | ${entry.parallel}',
    );
  }
  final out = File('release/_reports/rewrite_sequence.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
}

Map<String, _ComplexityRow> _parseComplexity() {
  final file = File('release/_reports/rewrite_complexity_index.txt');
  final map = <String, _ComplexityRow>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 3) continue;
    map[parts[0]] = _ComplexityRow(
      module: parts[0],
      score: double.tryParse(parts[1]) ?? 0.0,
      tier: parts[2],
    );
  }
  return map;
}

Map<String, String> _parsePriority() {
  final file = File('release/_reports/autofix_priority_index.txt');
  final map = <String, String>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 3) continue;
    map[parts[0]] = parts[2];
  }
  return map;
}

Map<String, int> _parseExecutionPlan() {
  final file = File('release/_reports/correction_engine/_execution_plan.txt');
  final map = <String, int>{};
  if (!file.existsSync()) return map;
  final lines = file.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty || !line.contains('|')) continue;
    final module = line.split('|').first.trim();
    map[module] = i;
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

int _priorityValue(String priority) {
  switch (priority) {
    case 'CRITICAL':
      return 4;
    case 'HIGH':
      return 3;
    case 'MEDIUM':
      return 2;
    default:
      return 1;
  }
}

class _Entry {
  _Entry({
    required this.module,
    required this.tier,
    required this.priority,
    required this.effort,
    required this.parallel,
    required this.order,
    required this.score,
  });
  final String module;
  final String tier;
  final String priority;
  final int effort;
  final String parallel;
  final int order;
  final double score;
}

class _ComplexityRow {
  _ComplexityRow({
    required this.module,
    required this.score,
    required this.tier,
  });
  final String module;
  final double score;
  final String tier;
}
