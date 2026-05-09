import 'dart:io';

void main() {
  final sequence = _loadSequence();
  final plans = _loadPatchPlans();
  final snapshots = _loadSnapshots();
  final buffer = StringBuffer();
  buffer.writeln('==== CONTENT REWRITE DRY RUN ====');
  var validCount = 0;
  var missingSnapshot = 0;
  var missingPlan = 0;
  var severity = 0;
  for (var i = 0; i < sequence.length; i++) {
    final module = sequence[i];
    final plan = plans[module];
    final snap = snapshots[module];
    final hasPlan = plan != null && plan.actions.isNotEmpty;
    final hasSnapshot = snap != null && snap.isNotEmpty;
    if (!hasPlan) {
      missingPlan++;
      severity += 2;
    }
    if (!hasSnapshot) {
      missingSnapshot++;
      severity += 1;
    }
    if (hasPlan && hasSnapshot) validCount++;
    buffer.writeln('module: $module');
    buffer.writeln(
      '  plan: ${hasPlan ? 'ok' : 'missing/empty'} actions=${plan?.actions.length ?? 0}',
    );
    buffer.writeln(
      '  snapshot: ${hasSnapshot ? 'present' : 'missing'} files=${snap?.join(', ') ?? 'n/a'}',
    );
    buffer.writeln('  risk: ${hasPlan && hasSnapshot ? 'low' : 'elevated'}');
  }
  buffer.writeln('==== GLOBAL SUMMARY ====');
  buffer.writeln('total modules      | ${sequence.length}');
  buffer.writeln('valid dry-run      | $validCount');
  buffer.writeln('missing snapshots  | $missingSnapshot');
  buffer.writeln('missing plans      | $missingPlan');
  buffer.writeln('severity index     | ${severity.clamp(0, 4)}');
  final out = File('release/_reports/rewrite_dry_run.txt');
  out.parent.createSync(recursive: true);
  out.writeAsStringSync(buffer.toString());
  stdout.write(buffer);
}

List<String> _loadSequence() {
  final file = File('release/_reports/rewrite_sequence.txt');
  if (!file.existsSync()) return [];
  final lines = file.readAsLinesSync();
  return lines
      .skip(1)
      .map((line) => line.split('|').map((p) => p.trim()).toList()[1])
      .toList();
}

Map<String, _PatchPlan> _loadPatchPlans() {
  final file = File('release/_reports/patch_plans/_index.txt');
  final map = <String, _PatchPlan>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map<String>((p) => p.trim()).toList();
    if (parts.length < 3) continue;
    final parsed = List<String>.from(
      parts[2].split(',').map((s) => s.trim()).where((s) => s.isNotEmpty),
    );
    map[parts[0]] = _PatchPlan(actions: parsed);
  }
  return map;
}

Map<String, List<String>> _loadSnapshots() {
  final file = File('release/_snapshots/_index.txt');
  final map = <String, List<String>>{};
  if (!file.existsSync()) return map;
  for (final line in file.readAsLinesSync().skip(1)) {
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length < 2) continue;
    final files = parts[1] == 'none'
        ? <String>[]
        : parts[1]
              .split(',')
              .map((f) => f.trim())
              .where((f) => f.isNotEmpty)
              .toList()
              .cast<String>();
    map[parts[0]] = files;
  }
  return map;
}

class _PatchPlan {
  _PatchPlan({required this.actions});
  final List<String> actions;
}
