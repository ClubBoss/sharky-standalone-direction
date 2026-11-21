// Report: ACT0_ATLAS_REPORT=/absolute/path/atlas_status.md flutter test \
//   test/guards/act0_atlas_dod_v1_test.dart
// Use the absolute l0-audit/wave4 path when publishing to the other streams.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_atlas_concepts_v1.dart';
import '../support/act0_atlas_practice_v1.dart';
import '../support/act0_catalog_poker_facts_v1.dart';
import '../support/act0_catalog_quality_audit_v1.dart';
import '../support/act0_catalog_snapshot_v1.dart';
import '../support/act0_day7_coverage_v1.dart';

const _baseline = 'test/fixtures/act0_atlas_dod_baseline_v1.json';

typedef _Metric = ({
  String id,
  String scope,
  String current,
  String target,
  num debt,
  bool manual,
});

final _ws = RegExp(r'\s+');
final _word = RegExp(r"[A-Za-z]+(?:['’][A-Za-z]+)?|\d+");
final _sentence = RegExp(r'(?<!\d)[.!?]+|[.!?]+(?=\s|$)');
final _vowels = RegExp(r'[aeiouy]+');

String _pct(num n) => '${(n * 100).toStringAsFixed(1)}%';
double _share(int count, int total) => total == 0 ? 0 : count / total;
String _norm(String text) => text.trim().toLowerCase().replaceAll(_ws, ' ');

String _location(CatalogTask row) =>
    'W${row.world.worldNumber}/${row.lesson.lessonId}/${row.task.taskId}';

bool _hand(CatalogTask row) =>
    row.task.runner.table.scope == Act0TableScopeV1.playedHand;

bool _checkpoint(List<CatalogTask> rows) =>
    rows.first.lesson.lessonId.contains('checkpoint');

Iterable<String> _reading(CatalogTask row) sync* {
  final runner = row.task.runner;
  yield runner.caption;
  yield catalogQuestion(row.task);
  for (final step in runner.teachingSteps) {
    yield step.body;
  }
}

final _firstPostflopAction = RegExp(
  r'^(?:flop|turn|river): ([a-z0-9]+) (?:checks|bets|raises|calls|all-in|folds)',
  caseSensitive: false,
);
final _enteredPreflop = RegExp(
  r'^([a-z0-9]+) (?:calls|raises|opens|all-in|limps)',
  caseSensitive: false,
);

int _confirmedPostflopSeats(Act0TableStateV1 table) {
  final active = table.seats
      .where((seat) => seat.isOccupied && seat.isInHand && !seat.isFolded)
      .map((seat) => seat.seatId.toLowerCase())
      .toSet();
  final known = {
    (table.heroSeatId ?? table.heroSeat.seatId).toLowerCase(),
    for (final action in table.actionTrail)
      if ((_firstPostflopAction.firstMatch(action.label) ??
              _enteredPreflop.firstMatch(action.label))
          case final match?)
        match[1]!.toLowerCase(),
  };
  return active.intersection(known).length;
}

Map<String, String> _priorChecklist(File report) {
  final input = Platform.environment['ACT0_ATLAS_CHECKLIST'];
  final checklist = File(
    input ?? '${report.absolute.parent.parent.path}/dod_checklist_20261121.md',
  );
  if (!checklist.existsSync()) return {};
  return {
    for (final row in checklist.readAsLinesSync())
      if (row.startsWith('| ☐ |'))
        row.split('|')[2].trim(): row.split('|')[4].trim(),
  };
}

// Optional machine receipt for P3. From a clean checkout, capture:
//   flutter test test/ui_v2/act0_w1_long_session_v1_test.dart \
//     --dart-define=ACT0_LONG_SESSION_FULL_ROUTE=true --reporter=json \
//     > "/tmp/act0-full-route-$(git rev-parse HEAD).jsonl"
// Pass that file as ACT0_ATLAS_ROUTE_EVENTS when generating the atlas.
bool _fullRoutePassed() {
  final path = Platform.environment['ACT0_ATLAS_ROUTE_EVENTS'];
  if (path == null || path.isEmpty) return false;
  final sha = Process.runSync('git', ['rev-parse', 'HEAD']);
  final tree = Process.runSync('git', [
    'status',
    '--porcelain',
    '--untracked-files=no',
  ]);
  if (sha.exitCode != 0 ||
      tree.exitCode != 0 ||
      tree.stdout.toString().trim().isNotEmpty) {
    return false;
  }
  final file = File(path);
  if (file.uri.pathSegments.last !=
          'act0-full-route-${sha.stdout.toString().trim()}.jsonl' ||
      !file.existsSync()) {
    return false;
  }
  int? routeSuite;
  final names = <int, String>{};
  final passed = <String>{};
  var done = false;
  for (final line in file.readAsLinesSync()) {
    if (!line.startsWith('{')) continue;
    final event = jsonDecode(line) as Map<String, dynamic>;
    switch (event['type']) {
      case 'suite':
        final suite = event['suite'] as Map<String, dynamic>;
        if ((suite['path'] as String).endsWith(
          '/test/ui_v2/act0_w1_long_session_v1_test.dart',
        )) {
          routeSuite = suite['id'] as int;
        }
      case 'testStart':
        final test = event['test'] as Map<String, dynamic>;
        if (test['suiteID'] == routeSuite) {
          names[test['id'] as int] = test['name'] as String;
        }
      case 'testDone':
        final name = names[event['testID']];
        if (event['result'] == 'success' &&
            event['skipped'] != true &&
            name != null) {
          passed.add(name);
        }
      case 'done':
        done = event['success'] == true;
    }
  }
  return done &&
      const {
        'a fresh learner finishes W1–W12 with mistakes, retries and restarts',
        'a fresh learner finishes W2–W12 with mistakes, retries and restarts',
        'W1 save resumes a drill from before the lesson split',
        'pre-Q8 save keeps Position Thinking credit',
        'pre-Q9 save keeps World 2 credit and opens the new lesson',
        'pre-Q10 save keeps World 6 credit and opens the new lesson',
      }.every(passed.contains);
}

double _flesch(Iterable<String> texts) {
  var words = 0;
  var syllables = 0;
  var sentences = 0;
  for (final text in texts) {
    final tokens = _word.allMatches(text).map((match) => match[0]!).toList();
    if (tokens.isEmpty) continue;
    words += tokens.length;
    final fragments = text.split(_sentence);
    sentences += fragments.where(_word.hasMatch).length;
    for (final token in tokens) {
      final spelling = token.toLowerCase();
      final stem = spelling.endsWith('e') && !spelling.endsWith('le')
          ? spelling.substring(0, spelling.length - 1)
          : spelling;
      syllables += math.max(1, _vowels.allMatches(stem).length);
    }
  }
  if (words == 0 || sentences == 0) return 0;
  return 206.835 - 1.015 * words / sentences - 84.6 * syllables / words;
}

/// Atlas pace estimate (clean route): 160 words/minute, six seconds per
/// graded decision and three seconds per screen transition. Read the rendered
/// teaching text, caption, question, and choice labels. A theory step and a
/// decision are separate screens when both are present. No hint or redo time.
double _minutes(List<CatalogTask> lesson) {
  var words = 0;
  var decisions = 0;
  var screens = 0;
  for (final row in lesson) {
    final runner = row.task.runner;
    words += _word.allMatches(catalogTitle(row.task)).length;
    for (final copy in [
      ..._reading(row),
      for (final step in runner.teachingSteps) step.title,
      for (final option in runner.options) option.label,
    ]) {
      words += _word.allMatches(copy).length;
    }
    final graded = atlasIsGradedV1(row);
    if (graded) decisions++;
    screens += math.max(1, runner.teachingSteps.length + (graded ? 1 : 0));
  }
  return words / 160 + (6 * decisions + 3 * screens) / 60;
}

void main() {
  test('Act0 atlas checklist and optional ratchet', () {
    final metrics = <_Metric>[];
    final details = <String>[];
    void add(
      String id,
      String scope,
      String current,
      String target,
      num debt, {
      bool manual = false,
    }) {
      metrics.add((
        id: id,
        scope: scope,
        current: current,
        target: target,
        debt: debt,
        manual: manual,
      ));
    }

    void maximum(String id, String scope, num n, int limit, [String? value]) =>
        add(id, scope, value ?? '$n', '≤ $limit', math.max(0, n - limit));
    void minimum(String id, String scope, num n, int limit, [String? value]) =>
        add(id, scope, value ?? '$n', '≥ $limit', math.max(0, limit - n));

    final route = catalogTasks.where((row) => !row.task.repairOnly).toList();
    final graded = route.where(atlasIsGradedV1).toList();
    final played = graded.where(_hand).toList();
    final lessons = <String, List<CatalogTask>>{};
    final format = {
      for (final row in graded)
        row.task.taskId: classifyCatalogScoredFormatV1(row.task),
    };
    String kind(CatalogTask row) => format[row.task.taskId] ?? '';
    for (final row in route) {
      final key = 'W${row.world.worldNumber}/${row.lesson.lessonId}';
      lessons.putIfAbsent(key, () => []).add(row);
    }

    final coverage = auditAtlasConceptsV1(route);
    final newConcepts = <String, List<String>>{};
    for (final entry in coverage.entries) {
      if (entry.value.explained case final explained?) {
        final key =
            'W${explained.world.worldNumber}/${explained.lesson.lessonId}';
        newConcepts.putIfAbsent(key, () => []).add(entry.key);
      }
    }
    final dense = newConcepts.entries.where((entry) => entry.value.length >= 4);
    maximum('D1', 'Курс', dense.length, 0);
    for (final entry in dense) {
      details.add('D1 · ${entry.key} · ${entry.value.join(', ')}');
    }

    final blindLesson = lessons.containsKey('W3/w3_play_from_blinds');
    final blindDecisions = {'sb': 0, 'bb': 0};
    final multiway = <String>[];
    final street = {'turn': 0, 'river': 0};
    for (final row in played) {
      final table = row.task.runner.table;
      if (kind(row) == 'actionDecision' || kind(row) == 'betSize') {
        final hero = table.heroSeatId ?? table.heroSeat.seatId;
        if (blindDecisions.containsKey(hero)) {
          blindDecisions[hero] = blindDecisions[hero]! + 1;
        }
        final name = table.streetLabel.toLowerCase();
        if (street.containsKey(name)) street[name] = street[name]! + 1;
      }
      if (table.boardCards.length >= 3 && _confirmedPostflopSeats(table) >= 3) {
        multiway.add(_location(row));
      }
    }
    minimum('U2', 'SB', blindDecisions['sb']!, 3);
    minimum('U2', 'BB', blindDecisions['bb']!, 3);
    add(
      'U2',
      'W3',
      blindLesson ? '1' : '0',
      'Урок из блайндов',
      blindLesson ? 0 : 1,
    );
    minimum('U3', 'Курс', multiway.length, 3);
    details.addAll(multiway.map((id) => 'U3 · $id'));
    minimum('U4', 'Тёрн', street['turn']!, 15);
    minimum('U4', 'Ривер', street['river']!, 6);

    final isolation = RegExp(
      r'\b(?:isolat\w*|rais\w*|bet\w*)\b',
      caseSensitive: false,
    );
    final limp = RegExp(r'\blimp\w*\b', caseSensitive: false);
    final station = RegExp(
      r'call(?:ing)? station|calls? too (?:much|often)|rarely folds',
      caseSensitive: false,
    );
    final bluff = RegExp(r'\bbluffs?\b', caseSensitive: false);
    final raised = RegExp(r'\braises?\b|raised to', caseSensitive: false);
    final attempts = <String, List<CatalogTask>>{
      'Изоляция': played.where((row) {
        final runner = row.task.runner;
        final prompt =
            '${runner.caption} ${catalogQuestion(row.task)} ${runner.table.actionTrail.map((item) => item.label).join(' ')}';
        return runner.table.boardCards.isEmpty &&
            limp.hasMatch(prompt) &&
            runner.options
                .where((option) => option.isCorrect)
                .any((option) => isolation.hasMatch(option.label));
      }).toList(),
      'Top pair против рейза на тёрне': played.where((row) {
        final table = row.task.runner.table;
        return kind(row) == 'actionDecision' &&
            table.streetLabel.toLowerCase() == 'turn' &&
            CatalogPokerFacts(table).pairType == 'top pair' &&
            table.actionTrail.any(
              (item) =>
                  raised.hasMatch(item.label) &&
                  (item.label.toLowerCase().contains('turn') ||
                      item.displayLabel?.toLowerCase().contains('turn') ==
                          true),
            );
      }).toList(),
      'Блеф против коллинг-станции': played.where((row) {
        final runner = row.task.runner;
        final prompt = '${runner.caption} ${catalogQuestion(row.task)}';
        return station.hasMatch(prompt) &&
            bluff.hasMatch(
              '$prompt ${runner.options.map((option) => option.label).join(' ')}',
            );
      }).toList(),
    };
    for (final entry in attempts.entries) {
      minimum(
        'U6',
        entry.key,
        entry.value.length,
        entry.key.startsWith('Блеф') ? 2 : 1,
      );
      details.addAll(
        entry.value.map((row) => 'U6 · ${entry.key} · ${_location(row)}'),
      );
    }
    final roll = coverage['Bankroll']!;
    final rollTeach = roll.explained?.world.worldNumber == 11;
    final rollTasks = roll.assessed
        .where((row) => row.world.worldNumber == 11)
        .length;
    add(
      'U7',
      'W11',
      '${rollTeach ? 1 : 0} правило, $rollTasks заданий',
      '1 правило и ≥ 2 задания',
      (rollTeach ? 0 : 1) + math.max(0, 2 - rollTasks),
    );

    final g1 = runCatalogQualityAudit(rows: route);
    int findings(String prefix, {Set<String>? taskIds}) => g1.findings
        .where(
          (value) =>
              value.startsWith(prefix) &&
              (taskIds == null || taskIds.contains(value.split('|').last)),
        )
        .length;
    maximum('M3', 'Курс', findings('13.'), 0);
    minimum(
      'M4',
      'Решения',
      graded.where((r) => kind(r) == 'actionDecision').length,
      100,
    );
    minimum(
      'M4',
      'Числа',
      graded.where((r) => kind(r) == 'numeric').length,
      30,
    );
    final wrongReasons = <String, int>{};
    final extreme = catalogExtremeOptionPatternV1;
    var wrong = 0;
    var extremeWrong = 0;
    var extremeCorrect = 0;
    var tone = 0;
    var longestSignal = 0.0;
    var longestChance = 0.0;
    var positionGap = 0.0;
    final groups = <int, List<int>>{};
    for (final row in graded) {
      final options = row.task.runner.options;
      final correct = options.indexWhere((o) => o.isCorrect);
      if (correct < 0) continue;
      final n = options.length;
      final counts = groups.putIfAbsent(n, () => List.filled(n, 0));
      counts[correct]++;
      final lengths = options
          .map((o) => _word.allMatches(o.label).length)
          .toList();
      final longest = lengths.reduce(math.max);
      final tied = lengths.where((length) => length == longest).length;
      if (lengths[correct] == longest) longestSignal += 1 / tied;
      longestChance += 1 / n;
      final bestExtreme = extreme.hasMatch(options[correct].label);
      if (bestExtreme) extremeCorrect++;
      var toneMarked = false;
      for (final option in options.where((o) => !o.isCorrect)) {
        wrong++;
        if (extreme.hasMatch(option.label)) {
          extremeWrong++;
          toneMarked = true;
        }
        final reason = _norm(option.feedbackReason);
        if (reason.length >= 20) {
          wrongReasons.update(reason, (count) => count + 1, ifAbsent: () => 1);
        }
      }
      if (toneMarked && !bestExtreme) {
        tone++;
        details.add('A3 · ${_location(row)}');
      }
    }
    final duplicateReasons = wrongReasons.values.fold<int>(
      0,
      (total, n) => total + n - 1,
    );
    maximum('M5', 'Курс', duplicateReasons, 5);
    for (final entry in groups.entries) {
      final count = entry.value.reduce((a, b) => a + b);
      final expected = 1 / entry.key;
      if (count >= 20) {
        for (final n in entry.value) {
          positionGap = math.max(positionGap, (n / count - expected).abs());
        }
      }
    }
    add(
      'A1',
      'Курс',
      groups.entries.map((e) => '${e.key}: ${e.value.join('/')}').join('; '),
      '±10 п.п. от равномерного, n ≥ 20',
      math.max(0.0, positionGap - 0.10),
    );
    final longestRate = longestSignal / math.max(1, graded.length);
    final chanceRate = longestChance / math.max(1, graded.length);
    add(
      'A2',
      'Курс',
      '${_pct(longestRate)} против ${_pct(chanceRate)} случайно',
      '±10 п.п. от случая',
      math.max(0.0, (longestRate - chanceRate).abs() - 0.10),
    );
    final wrongRate = _share(extremeWrong, wrong);
    final correctRate = _share(extremeCorrect, graded.length);
    add(
      'A3',
      'Курс',
      '${_pct(wrongRate)} / ${_pct(correctRate)}; $tone задач',
      'Неверные ≤ верных; 0 заданий с маркером',
      tone + math.max(0, wrongRate - correctRate),
    );

    for (final MapEntry(key: id, value: names)
        in atlasChecklistConceptsV1.entries) {
      for (final name in names) {
        final concept = coverage[name]!;
        final explanation = concept.explained;
        final assessed = concept.assessed;
        final first = concept.used;
        final learned = explanation == null ? '—' : _location(explanation);
        final firstUse = first == null ? '—' : _location(first);
        final debt = switch (id) {
          'C1' => (explanation == null ? 1 : 0) + (assessed.isEmpty ? 1 : 0),
          'C2' => concept.explainedBeforeUse ? 0 : 1,
          _ => assessed.isEmpty ? 1 : 0,
        };
        add(
          id,
          name,
          '${assessed.length} заданий; TEACH $learned; первое $firstUse',
          switch (id) {
            'C1' => 'Объяснение и ≥ 1 задание',
            'C2' => 'Объяснение до первого использования',
            _ => '≥ 1 задание',
          },
          debt,
        );
      }
    }
    for (final (name, after, limit) in [
      ('Out', 5, 3),
      ('One in N', 5, 3),
      ('SPR', 8, 2),
    ]) {
      final worlds =
          coverage[name]!.assessed
              .map((row) => row.world.worldNumber)
              .where((world) => world > after)
              .toSet()
              .toList()
            ..sort();
      minimum(
        'C4',
        name,
        worlds.length,
        limit,
        '${worlds.length} миров: ${worlds.map((w) => 'W$w').join(', ')}',
      );
    }

    final baselineExceptions =
        jsonDecode(
              File(
                'test/fixtures/act0_catalog_truth_exceptions_v1.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final reachableIds = {
      for (final row in [
        ...catalogTasks,
        ...rulesCheckCatalogTasks,
        ...day7CatalogTasks,
      ]) ...[row.task.taskId, row.lesson.lessonId],
    };
    final reachableExceptions = baselineExceptions.values
        .where((value) => reachableIds.contains(value['task_id']))
        .length;
    maximum('P1', 'Курс', reachableExceptions, 0);

    final lessonMinutes = <String, double>{
      for (final entry in lessons.entries) entry.key: _minutes(entry.value),
    };
    final long = lessonMinutes.entries.where((e) => e.value > 6);
    final short = lessonMinutes.entries.where((e) => e.value < 2);
    maximum('T1', 'Курс', long.length, 0);
    maximum('T2', 'Курс', short.length, 3);
    final ratchetActive = File(_baseline).existsSync();
    add(
      'T3',
      'Новые уроки',
      ratchetActive ? 'Порог активен' : 'Только отчёт',
      'Новые уроки 2–6 мин',
      0,
      manual: !ratchetActive,
    );
    for (final entry in [...long, ...short]) {
      details.add(
        'T1–T3 · ${entry.key} · ${entry.value.toStringAsFixed(2)} мин',
      );
    }

    final betWidgets = <int, int>{};
    final seatWidgets = <int, int>{};
    final courseExceptions = <String>[];
    var oneFormatLessons = 0;
    var longestStreak = 0;
    for (final world in Act0ShellStateV1.sample.worlds) {
      final number = world.worldNumber;
      final name = 'W$number';
      final tasks = route.where((r) => r.world.worldNumber == number).toList();
      final worldGraded = tasks.where(atlasIsGradedV1).toList();
      final worldLessons = lessons.entries
          .where((e) => e.key.startsWith('$name/'))
          .toList();
      final tableTasks = catalogTasks
          .where(
            (row) =>
                row.world.worldNumber == number &&
                row.task.runner.table.seats.isNotEmpty,
          )
          .toList();
      final btn = tableTasks.where((row) {
        final table = row.task.runner.table;
        return (table.heroSeatId ??
                table.seats.where((s) => s.isHero).firstOrNull?.seatId) ==
            'btn';
      }).length;
      final btnShare = _share(btn, tableTasks.length);
      add(
        'U1',
        name,
        '$btn/${tableTasks.length} (${_pct(btnShare)})',
        '≤ 50%',
        math.max(0, btnShare - 0.5),
      );
      if (number <= 5) {
        final two = worldGraded
            .where((r) => r.task.runner.options.length == 2)
            .length;
        final share = _share(two, worldGraded.length);
        final exceptions = worldGraded
            .where(
              (r) =>
                  r.task.runner.options.length == 2 &&
                  !catalogIsHeadsUpAllInCallFoldV1(r.task.runner),
            )
            .map(_location);
        courseExceptions.addAll(exceptions);
        add(
          'M1',
          name,
          '$two/${worldGraded.length} (${_pct(share)})',
          '≤ 30%',
          math.max(0, share - 0.30),
        );
      }
      if (number >= 9) {
        final queens = tasks
            .where((r) => CatalogPokerFacts(r.task.runner.table).code == 'QQ')
            .toList();
        maximum('U8', name, queens.length, 1);
        details.addAll(queens.map((row) => 'U8 · ${_location(row)}'));
        final ids = tasks.map((row) => row.task.taskId).toSet();
        final theoryCopies = worldLessons.map(
          (e) => findings(
            '14.',
            taskIds: e.value.map((row) => row.task.taskId).toSet(),
          ),
        );
        maximum(
          'M6',
          name,
          theoryCopies.fold(0, math.max),
          1,
          '${theoryCopies.fold(0, math.max)} макс./урок; ${findings('14.', taskIds: ids)} всего',
        );
        final almost = worldGraded
            .where(
              (row) => row.task.runner.options.any(
                (o) => o.quality == Act0FeedbackQualityV1.suboptimal,
              ),
            )
            .length;
        final almostShare = _share(almost, worldGraded.length);
        add(
          'M7',
          name,
          '$almost/${worldGraded.length} (${_pct(almostShare)})',
          '≤ 40%',
          math.max(0, almostShare - 0.40),
        );
        maximum(
          'M8',
          name,
          g1.findings
              .where(
                (v) => v.startsWith('15.') && ids.contains(v.split('|')[1]),
              )
              .length,
          0,
        );
        final flesch = _flesch(tasks.expand(_reading));
        minimum('M9', name, flesch, 75, flesch.toStringAsFixed(1));
        final decisions = worldGraded
            .where(
              (row) =>
                  _hand(row) &&
                  (kind(row) == 'actionDecision' || kind(row) == 'betSize'),
            )
            .length;
        final decisionShare = _share(decisions, worldGraded.length);
        add(
          'S2',
          name,
          '${tasks.length} заданий; $decisions/${worldGraded.length} решений',
          '27–33 задания; ≥ 1/3 решений',
          math.max(0, (tasks.length - 30).abs() - 3) +
              math.max(0, 1 / 3 - decisionShare),
        );
      }
      if (number == 7) {
        final checkpoint = worldLessons
            .where((e) => _checkpoint(e.value))
            .length;
        final regular = worldLessons.length - checkpoint;
        add(
          'S1',
          name,
          '$regular уроков, $checkpoint чекпоинтов, ${tasks.length} заданий',
          '≥ 2 урока и ≥ 1 чекпоинт',
          math.max(0, 2 - regular) + math.max(0, 1 - checkpoint),
        );
      }
      if (number == 11) {
        final hands = worldLessons
            .where((e) => _checkpoint(e.value))
            .expand((e) => e.value)
            .where(atlasIsGradedV1)
            .where(_hand)
            .toList();
        final distinct = hands
            .map((row) => day7HandKeyV1(row.task.runner.table))
            .toSet();
        add(
          'S3',
          name,
          '${distinct.length} отдельных раздач',
          '4–5 новых раздач в чекпоинте',
          distinct.length < 4
              ? 4 - distinct.length
              : math.max(0, distinct.length - 5),
          manual: distinct.length >= 4 && distinct.length <= 5,
        );
      }
      if (number == 12) {
        final expectedValue = coverage['Expected value (EV)']!.assessed
            .where(
              (r) =>
                  r.world.worldNumber == 12 &&
                  _hand(r) &&
                  r.task.runner.table.streetLabel.toLowerCase() == 'river',
            )
            .toList();
        minimum(
          'S3',
          name,
          expectedValue.length,
          1,
          '${expectedValue.length} задач EV на ривере',
        );
        add(
          'S3',
          'W12 · Связь навыков',
          'Нужно чтение разбора',
          'Цена W4 и ауты W5',
          0,
          manual: true,
        );
      }
      final formats = worldGraded.map(kind).toSet();
      if (number >= 2) {
        minimum(
          'V3',
          name,
          formats.length,
          3,
          '${formats.length} · ${formats.join(', ')}',
        );
      }
      var longest = 0;
      var streak = 0;
      var last = '';
      for (final row in worldGraded) {
        final current = kind(row);
        streak = current == last ? streak + 1 : 1;
        longest = math.max(longest, streak);
        last = current;
      }
      longestStreak = math.max(longestStreak, longest);
      maximum('V2', name, longest, 5);
      final oneFormat = worldLessons.where((e) {
        final rows = e.value.where(atlasIsGradedV1);
        return rows.length >= 4 && rows.map(kind).toSet().length < 2;
      }).toList();
      oneFormatLessons += oneFormat.length;
      maximum('V1', name, oneFormat.length, 0);
      details.addAll(oneFormat.map((entry) => 'V1 · ${entry.key}'));
      if ([6, 8, 10].contains(number)) {
        betWidgets[number] = worldGraded
            .where((r) => kind(r) == 'betSize')
            .length;
      }
      if ([4, 8, 10, 11].contains(number)) {
        seatWidgets[number] = worldGraded
            .where((r) => kind(r) == 'seatTap')
            .length;
      }
      final families = act0Day7MissSourcesV1.keys.where(
        (k) => k.$1 == world.worldId,
      );
      final verified = families.where(atlasDay7CoversV1).length;
      add(
        'B1',
        name,
        '$verified/${families.length}',
        '100% семей с новой раздачей',
        families.length - verified,
      );
      for (final key in families.where((key) => !atlasDay7CoversV1(key))) {
        details.add('B1 · $name/${key.$2}/${key.$3}');
      }

      for (final review in act0NewReviewTasksV1.where(
        (entry) => entry.worldId == world.worldId,
      )) {
        final mismatch = atlasDay7SkillMismatchV1(
          review.conceptFamilyId,
          review.task,
        );
        if (mismatch != null) {
          details.add(
            'B1 · $name/${review.lessonId}/${review.task.taskId} · $mismatch',
          );
        }
      }

      final practice = auditAtlasPracticeWorldV1(world);
      add(
        'S4',
        name,
        '${practice.steps} шагов, ${practice.gaps.length} пропусков',
        'Каждые 2–3 урока и перед чекпоинтом',
        practice.gaps.length,
      );
      details.addAll(practice.gaps.map((gap) => 'S4 · $name · $gap'));

      final xp = tasks.fold<int>(0, (sum, r) => sum + r.task.rewardXp);
      details.add(
        'P3 · $name · ${tasks.length} обязательных, $xp XP по каталогу',
      );
    }
    maximum('V1', 'Курс', oneFormatLessons, 0);
    maximum('V2', 'Курс', longestStreak, 5);
    details.addAll(courseExceptions.map((id) => 'M1 · два варианта · $id'));
    for (final (id, counts, minimumTotal) in [
      ('V4', betWidgets, 8),
      ('V5', seatWidgets, 10),
    ]) {
      final total = counts.values.fold<int>(0, (sum, n) => sum + n);
      final missing = counts.values.where((n) => n == 0).length;
      add(
        id,
        'Целевые миры',
        '$total · ${counts.entries.map((e) => 'W${e.key}: ${e.value}').join(', ')}',
        '≥ $minimumTotal, хотя бы одно в каждом целевом мире',
        math.max(0, minimumTotal - total) + missing,
      );
    }
    final numerics = graded.where((r) => kind(r) == 'numeric').length;
    final statement = graded.where((r) => kind(r) == 'statement').length;
    final statementShare = _share(statement, graded.length);
    minimum('V6', 'Числа', numerics, 20);
    add(
      'V6',
      'Утверждения',
      '$statement/${graded.length} (${_pct(statementShare)})',
      '≤ 35%',
      math.max(0, statementShare - 0.35),
    );

    final routeXp = route.fold<int>(0, (sum, r) => sum + r.task.rewardXp);
    add(
      'P3',
      'Курс',
      '${route.length} обязательных, $routeXp XP',
      'FULL_ROUTE, точный XP и старые сохранения',
      0,
      manual: !_fullRoutePassed(),
    );

    final output = Platform.environment['ACT0_ATLAS_REPORT'];
    final writeBaseline =
        Platform.environment['ACT0_ATLAS_UPDATE_BASELINE'] == '1';
    final file = File(_baseline);
    // Key by criterion + scope so healthy worlds cannot mask regressions in
    // another world. Persist debt only. Missing baseline means report-only.
    final debt = {for (final m in metrics) '${m.id}|${m.scope}': m.debt};
    for (final lesson in lessonMinutes.entries) {
      final minutes = lesson.value;
      debt['T3|${lesson.key}'] = math.max(
        0,
        math.max(2 - minutes, minutes - 6),
      );
    }
    if (writeBaseline) {
      const indent = JsonEncoder.withIndent('  ');
      file.writeAsStringSync('${indent.convert(debt)}\n');
    }
    if (output != null && output.isNotEmpty) {
      final byId = <String, List<_Metric>>{};
      for (final metric in metrics) {
        byId.putIfAbsent(metric.id, () => []).add(metric);
      }
      String rowStatus(_Metric m) => m.debt > 0 ? '❌' : (m.manual ? '◐' : '✅');
      String groupStatus(List<_Metric> rows) {
        if (rows.every((m) => m.debt == 0 && !m.manual)) return '✅';
        if (rows.every((m) => m.debt > 0)) return '❌';
        return '◐';
      }

      final statuses = byId.map((id, rows) => MapEntry(id, groupStatus(rows)));
      final sha = Process.runSync('git', ['rev-parse', 'HEAD']);
      final worktree = Process.runSync('git', [
        'status',
        '--porcelain',
        '--untracked-files=no',
      ]);
      final provenance = sha.exitCode == 0
          ? '${sha.stdout.toString().trim()}'
                '${worktree.stdout.toString().trim().isEmpty ? '' : ' + локальные изменения'}'
          : 'неизвестно';
      final destination = File(output)..parent.createSync(recursive: true);
      final prior = _priorChecklist(destination);
      final unmeasured = prior.keys.where((id) => !statuses.containsKey(id));
      final report = <String>[
        '# Атлас Act0 · машинная проверка',
        '',
        'Источник: `$provenance`. Курс W1–W12, обязательные задания, если не указано иначе.',
        '',
        for (final mark in ['✅', '◐', '❌'])
          '- $mark ${statuses.values.where((value) => value == mark).length} · ${statuses.entries.where((entry) => entry.value == mark).map((entry) => entry.key).join(', ')}',
        '',
        if (unmeasured.isNotEmpty)
          '- Вне этого прогона (${unmeasured.length}) · ${unmeasured.join(', ')}',
        '',
        '| Пункт | Разрез | Было 21.11 (пункт целиком) | Сейчас | Цель | Статус |',
        '| --- | --- | --- | --- | --- | --- |',
        for (final m in metrics)
          '| ${m.id} | ${m.scope} | ${prior[m.id] ?? '—'} | ${m.current} | ${m.target} | ${rowStatus(m)} |',
        '',
        '## Как читать',
        '',
        '- U1 считает все таблицы G1, включая repair-only. U2–U4 считаются по оцениваемым раздачам. U3 требует подтверждённых участников в истории действий.',
        '- C1–C4 и D1 опираются на словарь и совпадения в TEACH, заданиях и разборах. Смысл заданий, честность двух вариантов и оправданность «почти» проверяются чтением.',
        '- M9 — Flesch Reading Ease по английским подписям, вопросам и теории. Слоги оценены по группам гласных. T1–T3 — оценка темпа без ошибок и повторов.',
        '- A1–A2 используют допуск 10 п.п. как рабочее определение «на уровне случая». A3 измеряет маркеры лексики.',
        '- B1 сверяет ключи семейства и новизну раздачи. Известные взаимоисключающие задания исключены. Спорные формулировки требуют чтения.',
        '- S4 считает отдельный обязательный шаг в Learn. Home Practice и Review перед заблокированным чекпоинтом проверяются отдельными тестами.',
        '- P3 показывает объём по каталогу и проверяет приложенный JSONL FULL_ROUTE на том же коммите.',
        '',
        '## Места для проверки',
        '',
        for (final item in details) '- ${item.replaceAll('|', r'\|')}',
      ].join('\n');
      destination.writeAsStringSync('$report\n');
    }

    if (file.existsSync() && !writeBaseline) {
      final prior =
          (jsonDecode(file.readAsStringSync()) as Map<String, dynamic>);
      final regressions = [
        for (final entry in debt.entries)
          if (entry.value > (prior[entry.key] as num? ?? 0) + 1e-9)
            '${entry.key}: ${prior[entry.key] ?? 0} → ${entry.value}',
      ];
      expect(regressions, isEmpty, reason: regressions.join('\n'));
    }
  });
}
