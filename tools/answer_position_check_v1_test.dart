// Generate a fresh snapshot with tools/export_catalog_v1_test.dart using
// --dart-define=ANSWER_POSITIONS=true, then run this file with dart test.
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

typedef _Task = ({
  int world,
  String lesson,
  String id,
  bool repairOnly,
  bool multipleChoice,
  List<bool> options,
});

typedef _Run = (int position, List<String> ids);
typedef _Pair = (String original, String variant);
typedef _Lesson = (int world, String id);
typedef _WorldBaseline = ({int tasks, List<int> slotCounts, int longestRun});

Map<int, _WorldBaseline> _readBaseline() {
  final file = File('tools/answer_position_baseline_v1.json');
  final worlds = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return worlds.map((world, value) {
    final row = value as Map<String, dynamic>;
    return MapEntry(int.parse(world), (
      tasks: row['tasks'] as int,
      slotCounts: (row['slotCounts'] as List).cast<int>(),
      longestRun: row['longestRun'] as int,
    ));
  });
}

bool _exceedsSlotBaseline(
  _WorldBaseline? baseline,
  int position,
  int count,
  int total,
) {
  if (baseline == null || baseline.tasks < 10) return true;
  final previous = position <= baseline.slotCounts.length
      ? baseline.slotCounts[position - 1]
      : 0;
  return count * baseline.tasks > previous * total;
}

_Task _decodeTask(Map<String, dynamic> row) => (
  world: row['world'] as int,
  lesson: row['lesson'] as String,
  id: row['id'] as String,
  repairOnly: row['repairOnly'] as bool,
  multipleChoice: row['multipleChoice'] as bool,
  options: (row['options'] as List).cast<bool>(),
);

Set<int> _positions(_Task task) => {
  if (task.multipleChoice && task.options.length >= 3)
    for (final (index, correct) in task.options.indexed)
      if (correct) index + 1,
};

String _rate(int count, int total) =>
    total == 0 ? 'n/a' : '${(100 * count / total).toStringAsFixed(1)}%';

List<_Run> _runs(List<_Task> tasks, int position) {
  final runs = <_Run>[];
  var current = <String>[];
  for (final task in tasks) {
    if (_positions(task).contains(position)) {
      current.add(task.id);
    } else if (current.isNotEmpty) {
      runs.add((position, current));
      current = [];
    }
  }
  if (current.isNotEmpty) runs.add((position, current));
  return runs;
}

({String report, List<String> failures}) _audit(
  List<_Task> tasks,
  List<_Pair> pairs, {
  Map<int, _WorldBaseline> baseline = const {},
}) {
  // A task contributes once to each slot holding a preferred choice.
  // A shared slot counts even when either task has several preferred choices.
  final report = StringBuffer();
  final failures = <String>[];
  final worlds = <int, List<_Task>>{};
  final lessons = <_Lesson, List<_Task>>{};
  final byId = <String, _Task>{};
  var maxPosition = 0;

  for (final task in tasks) {
    if (byId.containsKey(task.id)) {
      throw FormatException('Duplicate task ID: ${task.id}');
    }
    byId[task.id] = task;
    final world = worlds.putIfAbsent(task.world, () => []);
    if (!task.repairOnly) {
      lessons.putIfAbsent((task.world, task.lesson), () => []).add(task);
    }
    if (!task.multipleChoice || task.options.length < 3) continue;
    if (_positions(task).isEmpty) {
      throw FormatException('No preferred correct choice: ${task.id}');
    }
    world.add(task);
    if (task.options.length > maxPosition) maxPosition = task.options.length;
  }

  final positions = List.generate(maxPosition, (index) => index + 1);
  report.writeln(
    '| World | Tasks | ${positions.map((p) => 'Slot $p').join(' | ')} |',
  );
  report.writeln('| --- | --- | ${positions.map((_) => '---').join(' | ')} |');
  for (final (label, eligible, world) in [
    for (final entry in worlds.entries)
      ('W${entry.key}', entry.value, entry.key),
    ('Overall', worlds.values.expand((tasks) => tasks).toList(), null),
  ]) {
    final cells = <String>[];
    for (final position in positions) {
      final ids = [
        for (final task in eligible)
          if (_positions(task).contains(position)) task.id,
      ];
      final rate = _rate(ids.length, eligible.length);
      cells.add('${ids.length} ($rate)');
      if (world != null &&
          eligible.length >= 10 &&
          ids.length * 2 > eligible.length &&
          _exceedsSlotBaseline(
            baseline[world],
            position,
            ids.length,
            eligible.length,
          )) {
        failures.add(
          '$label slot $position: ${ids.length}/${eligible.length} ($rate) — ${ids.join(', ')}',
        );
      }
    }
    report.writeln('| $label | ${eligible.length} | ${cells.join(' | ')} |');
  }

  report.writeln('\n| World / lesson | Longest run | Slot(s) |');
  report.writeln('| --- | --- | --- |');
  for (final MapEntry(key: (world, lesson), value: ordered)
      in lessons.entries) {
    final runs = [
      for (final position in positions) ..._runs(ordered, position),
    ];
    var longest = 0;
    for (final (position, ids) in runs) {
      if (ids.length > longest) longest = ids.length;
      if (ids.length >= 4 && ids.length > (baseline[world]?.longestRun ?? 0)) {
        failures.add(
          'W$world $lesson slot $position run of ${ids.length} — ${ids.join(' → ')}',
        );
      }
    }
    final slots = [
      for (final (position, ids) in runs)
        if (ids.length == longest) position,
    ].toSet();
    report.writeln(
      '| W$world / $lesson | $longest | ${slots.isEmpty ? '—' : slots.join(', ')} |',
    );
  }

  report.writeln('\n| Repeat cohort | Same slot | Eligible pairs | Share |');
  report.writeln('| --- | --- | --- | --- |');
  var matched = 0;
  var eligible = 0;
  final repeatedIds = <String>[];
  final excludedPairs = <String>[];
  for (final (original, variant) in pairs.toSet()) {
    final first = byId[original];
    final second = byId[variant];
    if (first == null || second == null) {
      throw FormatException('Missing repeat endpoint: $original → $variant');
    }
    final firstSlots = _positions(first);
    final secondSlots = _positions(second);
    if (firstSlots.isEmpty || secondSlots.isEmpty) {
      excludedPairs.add('$original → $variant');
      continue;
    }
    eligible++;
    if (firstSlots.intersection(secondSlots).isNotEmpty) {
      matched++;
      repeatedIds.add('$original → $variant');
    }
  }
  report.writeln(
    '| Authored distinct repeat / recheck | $matched | $eligible | ${_rate(matched, eligible)} |',
  );
  // Day 2 can reopen the exact source ID. This is a source-order comparison,
  // not an estimate of which tasks will actually become due.
  final day2 = tasks
      .where((task) => !task.repairOnly && _positions(task).isNotEmpty)
      .length;
  report.writeln(
    '| Day 2 exact-source replay candidates | $day2 | $day2 | ${_rate(day2, day2)} |',
  );
  final total = day2 + eligible;
  final same = day2 + matched;
  report.writeln(
    '| Combined distinct pairs and replay candidates | $same | $total | ${_rate(same, total)} |',
  );
  report.writeln();
  if (matched * 5 > eligible * 3) {
    report.writeln('WARNING: >60% of distinct pairs share a preferred slot.');
  }
  if (repeatedIds.isNotEmpty) {
    report.writeln('Same-slot pairs: ${repeatedIds.join(', ')}');
  }
  if (excludedPairs.isNotEmpty) {
    report.writeln(
      'Pairs outside the eligible choice format: ${excludedPairs.join(', ')}',
    );
  }

  if (day2 > 0) {
    report.writeln(
      'WARNING: Day 2 exact-source replays retain the authored slots (>60%).',
    );
  }
  if (same * 5 > total * 3) {
    report.writeln(
      'WARNING: >60% of combined comparisons share a preferred slot.',
    );
  }
  if (failures.isNotEmpty) {
    report.writeln('\nThreshold failures:\n${failures.join('\n')}');
  }
  return (report: report.toString(), failures: failures);
}

List<_Task> _fixture(List<int> slots, {String lesson = 'fixture'}) => [
  for (final (index, slot) in slots.indexed)
    (
      world: 1,
      lesson: lesson,
      id: '$lesson-$index',
      repairOnly: false,
      multipleChoice: true,
      options: List.generate(3, (i) => i + 1 == slot),
    ),
];

void main() {
  test('Real catalog answer positions stay within the baseline ratchet', () {
    final baseline = _readBaseline();
    final file = File('output/b43/answer_positions.json');
    final snapshot =
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final tasks = (snapshot['tasks'] as List)
        .cast<Map<String, dynamic>>()
        .map(_decodeTask)
        .toList();
    expect({
      for (final task in tasks)
        if (task.multipleChoice && task.options.length >= 3) task.world,
    }, containsAll(baseline.keys));
    final pairs = [
      for (final pair in (snapshot['pairs'] as List).cast<List>())
        (pair[0] as String, pair[1] as String),
    ];
    final result = _audit(tasks, pairs, baseline: baseline);
    stdout.write(result.report);
    expect(result.failures, isEmpty);
  });

  test('skewed fixture fails both hard thresholds and lists task IDs', () {
    final tasks = _fixture([1, 1, 1, 1, 2, 1, 3, 1, 2, 3]);
    final result = _audit(tasks, [('fixture-0', 'fixture-1')]);
    expect(result.failures, [
      contains('W1 slot 1: 6/10'),
      contains('run of 4 — fixture-0 → fixture-1 → fixture-2 → fixture-3'),
    ]);
    expect(result.report, contains('WARNING: >60% of distinct pairs'));
  });

  test('ratchet accepts existing skew and rejects regression', () {
    const baseline = {
      1: (tasks: 10, slotCounts: [6, 2, 2], longestRun: 4),
    };
    final existing = _fixture([1, 1, 1, 1, 2, 1, 3, 1, 2, 3]);
    final worse = _fixture([1, 1, 1, 1, 1, 1, 3, 1, 2, 3]);
    expect(_audit(existing, [], baseline: baseline).failures, isEmpty);
    expect(_audit(worse, [], baseline: baseline).failures, [
      contains('W1 slot 1: 7/10'),
      contains('run of 6'),
    ]);

    final newWorld = [
      for (final task in existing)
        (
          world: 13,
          lesson: task.lesson,
          id: task.id,
          repairOnly: task.repairOnly,
          multipleChoice: task.multipleChoice,
          options: task.options,
        ),
    ];
    expect(_audit(newWorld, [], baseline: baseline).failures, [
      contains('W13 slot 1: 6/10'),
      contains('W13 fixture slot 1 run of 4'),
    ]);
  });

  test('balanced fixture passes at 50% and runs stop at lesson boundaries', () {
    final tasks = [
      ..._fixture([2, 3, 1, 1, 1]),
      ..._fixture([1, 1, 2, 3, 2], lesson: 'next'),
    ];
    final result = _audit(tasks, [('fixture-2', 'next-0')]);
    expect(result.failures, isEmpty);
    expect(result.report, contains('5 (50.0%)'));
    expect(result.report, contains('WARNING: >60% of distinct pairs'));
  });
}
