import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_catalog_claims_v1.dart';
import '../support/act0_catalog_poker_facts_v1.dart';
import '../support/act0_catalog_quality_audit_v1.dart';
import '../support/act0_catalog_reachability_v1.dart';
import '../support/act0_catalog_snapshot_v1.dart';
import '../support/act0_catalog_truth_audit_v1.dart';
import '../support/act0_day7_coverage_v1.dart';
import '../support/act0_practice_generator_v1.dart';
import '../support/act0_shell_source_files_v1.dart';
import '../support/act0_table_truth_v1.dart';
import '../support/act0_source_choreography_test_wait_v1.dart';

// Regenerate only the reviewer-visible snapshot:
// G1_UPDATE_SNAPSHOT=1 flutter test test/ui_v2/act0_catalog_truth_guards_v1_test.dart --plain-name 'W1–W12 catalog snapshot'
const _snapshotPath = 'test/fixtures/act0_catalog_snapshot_v1.txt';
const _baselinePath = 'test/fixtures/act0_catalog_truth_exceptions_v1.json';
const _qualityBaselinePath =
    'test/fixtures/act0_catalog_quality_baseline_v1.json';

const _json = JsonEncoder.withIndent('  ');

final _praiseAtStart = RegExp(
  r'^(?:(?:almost (?:got it|there|right)|clean execution|'
  r'close (?:call|count|idea|on the ladder|read|start)|'
  r'excellent spot|getting warmer|good (?:direction|instinct|read|spot|start)|'
  r'nearly there|nice (?:count|read|work)|on the right track|one more step|'
  r'playable (?:instinct|move|start|thought)|sharp read|solid understanding|'
  r'spot on|strong choice|very close|well done)\b|(?:close|good)[.!?,])',
  caseSensitive: false,
);

CatalogTask _catalogRow(String id) =>
    catalogTasks.singleWhere((row) => row.task.taskId == id);

CatalogTask _withRunner(
  CatalogTask row,
  Act0RunnerStateV1 runner, {
  String? id,
}) {
  final task = row.task;
  return (
    world: row.world,
    lesson: row.lesson,
    lessonIndex: row.lessonIndex,
    task: Act0LessonTaskV1(
      taskId: id ?? task.taskId,
      title: task.title,
      phase: task.phase,
      runner: runner,
      rewardXp: task.rewardXp,
      stepKind: task.stepKind,
      taskFamily: task.taskFamily,
      repairOnly: task.repairOnly,
    ),
  );
}

void _verifyBaseline(CatalogAudit audit, String prefix, String reportName) {
  final log = Platform.environment['G1_REPORT_DIR'];
  if (log != null) {
    Directory(log).createSync(recursive: true);
    File(
      '$log/$reportName.json',
    ).writeAsStringSync(_json.convert(audit.toJson()) + '\n');
  }
  final baseline =
      jsonDecode(File(_baselinePath).readAsStringSync())
          as Map<String, dynamic>;
  final expected = baseline.entries.where(
    (entry) => entry.key.startsWith('6.rendered_') == (prefix == 'render'),
  );
  for (final hit in expected) {
    final entry = hit.value as Map;
    expect(entry['task_id'], hit.key.split('|')[1]);
    expect(entry['reason'], isNotEmpty);
    expect(entry['target'], isIn(['P8', 'L2', 'после беты']));
    final world = entry['world'];
    if (world is int) {
      expect(
        entry['target'],
        world <= 4
            ? 'P8'
            : world <= 8
            ? 'L2'
            : 'после беты',
      );
    }
  }
  final allowed = expected.map((entry) => entry.key).toSet();
  final actual = audit.findings.keys.toSet();
  final added = actual.difference(allowed).toList()..sort();
  final removed = allowed.difference(actual).toList()..sort();
  expect(
    added,
    isEmpty,
    reason: 'New G1 findings:\n' + added.take(30).join('\n'),
  );
  expect(
    removed,
    isEmpty,
    reason: 'Remove resolved G1 exceptions:\n' + removed.take(30).join('\n'),
  );
}

String _day7HandKey(Act0TableStateV1 t) =>
    '${t.heroSeatId ?? t.heroSeat.seatId}|${(t.heroCards.map(cardIdentity).toList()..sort()).join(',')}|'
    '${t.boardCards.map(cardIdentity).join(',')}';

void main() {
  test('W1–W12 catalog snapshot', () {
    final fixture = File(_snapshotPath);
    final current = renderCatalogSnapshot();
    expect(
      catalogTasks.map((row) => row.world.worldNumber).toSet(),
      hasLength(12),
    );
    if (Platform.environment['G1_UPDATE_SNAPSHOT'] == '1') {
      fixture.createSync(recursive: true);
      fixture.writeAsStringSync(current);
      return;
    }
    final expected = fixture.readAsLinesSync();
    final lines = current.trimRight().split('\n');
    final changed = lines.indexed
        .where(
          (line) => line.$1 >= expected.length || line.$2 != expected[line.$1],
        )
        .firstOrNull;
    expect(
      changed,
      isNull,
      reason:
          'Refresh the snapshot explicitly and review the diff. First changed line: ' +
          (changed == null ? '?' : (changed.$1 + 1).toString()),
    );
    expect(lines.length, expected.length);
  });

  test('G1 Day 7 covers every pre-beta review family and lesson', () {
    final missing = act0Day7MissSourcesV1.keys.toSet().difference(
      act0Day7CoverageV1,
    );
    expect(missing.where(day7MustBeCoveredV1), isEmpty);
    expect(
      act0Day7CoverageV1.difference(act0Day7MissSourcesV1.keys.toSet()),
      isEmpty,
    );
    final log = Platform.environment['G1_REPORT_DIR'];
    if (log != null) {
      Directory(log).createSync(recursive: true);
      File('$log/day7.json').writeAsStringSync(
        _json.convert([
              for (final key in missing)
                {
                  'world': key.$1,
                  'lesson': key.$2,
                  'family': key.$3,
                  'target': 'до беты · Q1',
                },
            ]) +
            '\n',
      );
    }
  });

  test('G1 Day 7 uses new scenes with valid tables and one scored answer', () {
    final seen = <String>{};
    final courseIds = [
      ...catalogTasks,
      ...rulesCheckCatalogTasks,
    ].map((row) => row.task.taskId).toSet();
    final courseHands = [
      ...catalogTasks,
      ...rulesCheckCatalogTasks,
    ].map((row) => _day7HandKey(row.task.runner.table)).toSet();
    for (final row in day7CatalogTasks) {
      final task = row.task;
      final runner = task.runner;
      final table = runner.table;
      final id = task.taskId;
      expect(seen.add(id), isTrue, reason: id);
      expect(courseIds.contains(id), isFalse, reason: id);
      expect(courseHands.contains(_day7HandKey(table)), isFalse, reason: id);
      expect(task.rewardXp, 0, reason: id);
      expect(runner.hint, isEmpty, reason: id);
      expect(runner.teachingSteps, isEmpty, reason: id);
      expect(table.highlightedSeatIds, isEmpty, reason: id);
      expect(table.highlightedCardIds, isEmpty, reason: id);
      expect(
        runner.options.where(act0RunnerOptionIsAuthoredCorrectV1),
        hasLength(1),
        reason: id,
      );
      expect(
        runner.options.every((option) => option.feedbackReason.isNotEmpty),
        isTrue,
        reason: id,
      );
      final cards = [
        ...table.heroCards,
        ...table.boardCards,
        for (final seat in table.seats)
          if (!seat.isHero &&
              seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp)
            ...seat.holeCards,
      ].map(cardIdentity);
      expect(cards.toSet(), hasLength(cards.length), reason: id);
      final contributions = auditTableContributionsV1(id, 'day7', table);
      expect(
        contributions
            .where((row) => row.result != 'PASS')
            .map((row) => row.key),
        isEmpty,
        reason: id,
      );
      expect(
        contributions.any((row) => row.invariant == 'D2.pot_feasibility'),
        isTrue,
        reason: id,
      );
    }
    final audit = runCatalogAudit(rows: [...catalogTasks, ...day7CatalogTasks]);
    final day7Findings = audit.findings.keys.where(
      (key) => seen.contains(key.split('|')[1]),
    );
    expect(day7Findings, isEmpty, reason: day7Findings.join('\n'));
  });

  test('wrong catalog feedback starts without praise', () {
    final violations = <String>[];
    final coachViolations = <String>{};
    for (final row in [...catalogTasks, ...rulesCheckCatalogTasks]) {
      final runner = row.task.runner;
      for (final option in runner.options) {
        if (option.quality != Act0FeedbackQualityV1.wrong) continue;
        final coachLine = runner.sharky.wrongReaction;
        if (_praiseAtStart.hasMatch(coachLine.trimLeft())) {
          coachViolations.add('Sharky wrong reaction: $coachLine');
        }
        for (final (field, text) in [
          ('title', option.feedbackTitle),
          ('reason', option.feedbackReason),
        ]) {
          if (_praiseAtStart.hasMatch(text.trimLeft())) {
            violations.add('${row.task.taskId}/${option.id} $field: $text');
          }
        }
      }
    }
    violations.addAll(coachViolations);
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  testWidgets('shared wrong-answer coaching starts without praise', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            for (var seed = 0; seed < 4; seed++) {
              final line = act0RuntimeFeedbackCoachLineV1(
                context,
                authoredLine: Act0SharkyCueV1.beginner.wrongReaction,
                title: 'Not quite.',
                quality: Act0FeedbackQualityV1.wrong,
                variationSeed: '$seed',
              );
              expect(line, isNot(matches(_praiseAtStart)));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  test('claim audit rejects a set presented as a pair and an absent card', () {
    final source = catalogTasks
        .singleWhere((row) => row.task.taskId == 'w4_protection_intro')
        .task
        .runner
        .table;
    List<CatalogClaim> claims(String text, Act0TableStateV1 table) =>
        catalogClaims(text, table, titleOrLabel: false);
    expect(
      claims('You have top pair on Q-9-4.', source).map((c) => c.matches),
      [true, true],
    );
    final set = source.copyWith(
      heroCards: const [
        Act0CardStateV1(rank: 'Q', suit: 's'),
        Act0CardStateV1(rank: 'Q', suit: 'd'),
      ],
    );
    expect(CatalogPokerFacts(set).rank, 'set');
    expect(claims('You have top pair on Q-9-4.', set).first.matches, isFalse);
    expect(
      claims('The ace of hearts is on the table.', source).single.matches,
      isFalse,
    );
    expect(
      claims(
        'If you have an ace of hearts, compare suits.',
        source,
      ).single.matches,
      isNull,
    );
  });

  test(
    'draw assertions count physical completion cards and reject off-by-one',
    () {
      final table = catalogTasks
          .singleWhere((row) => row.task.taskId == 'w4_protection_intro')
          .task
          .runner
          .table
          .copyWith(
            heroCards: const [
              Act0CardStateV1(rank: '8', suit: 'h'),
              Act0CardStateV1(rank: '7', suit: 'h'),
            ],
            boardCards: const [
              Act0CardStateV1(rank: '9', suit: 'h'),
              Act0CardStateV1(rank: '6', suit: 'h'),
              Act0CardStateV1(rank: '2', suit: 'c'),
            ],
          );
      final facts = CatalogPokerFacts(table);
      expect(facts.openEnded, isTrue);
      expect(facts.completionCards, hasLength(15)); // 9 + 8 − 2.
      bool? claim(String text) =>
          catalogClaims(text, table, titleOrLabel: false).single.matches;
      expect(claim('You have 8 straight outs.'), isTrue);
      expect(claim('You have 9 flush outs.'), isTrue);
      expect(claim('You have 16 outs.'), isFalse);
      expect(claim('You have 15 clean outs.'), isNull);
    },
  );

  group('G1 rejects changed catalog rows', () {
    test('G1·5 a paraphrase still repeats the same seat-order exercise', () {
      final original = _catalogRow('blinds_postflop_button');
      final duplicate = _withRunner(
        original,
        original.task.runner.copyWith(
          question: 'Which seat acts latest after the flop?',
        ),
        id: 'duplicate_order',
      );
      final audit = runCatalogAudit(rows: [original, duplicate]);
      expect(
        audit.findings,
        contains('5.semantic_repeat|duplicate_order|question'),
      );
    });

    test('G1·6 answer seat in focus and a synonymous board cue', () {
      final seat = _catalogRow('blinds_postflop_button');
      final correctSeat = seat.task.runner.options
          .singleWhere(act0RunnerOptionIsAuthoredCorrectV1)
          .seatId!;
      final highlighted = _withRunner(
        seat,
        seat.task.runner.copyWith(
          table: seat.task.runner.table.copyWith(
            highlightedSeatIds: [correctSeat],
          ),
        ),
      );
      final board = _catalogRow('cards_ranks_suits_private_board');
      final revealed = _withRunner(
        board,
        board.task.runner.copyWith(
          caption: '',
          table: board.task.runner.table.copyWith(centerLabel: 'Shared board'),
        ),
      );
      final audit = runCatalogAudit(rows: [highlighted, revealed]);
      expect(
        audit.findings,
        contains('6.authored_seat_cue|${seat.task.taskId}|$correctSeat'),
      );
      expect(
        audit.findings,
        contains('6.answer_copy|${board.task.taskId}|center'),
      );
    });

    test('G1·6 comparative captions cannot state the seat order', () {
      final row = _catalogRow('button_advantage_button_vs_cutoff');
      for (final caption in [
        'CO is late, but BTN still acts after CO.',
        'The cutoff goes before the button.',
      ]) {
        final revealed = _withRunner(
          row,
          row.task.runner.copyWith(caption: caption),
        );
        expect(
          runCatalogAudit(rows: [revealed]).findings,
          contains('6.answer_copy|${row.task.taskId}|caption'),
        );
      }
      expect(
        runCatalogAudit(rows: [row]).findings,
        isNot(contains('6.answer_copy|${row.task.taskId}|caption')),
      );
    });

    test('G1·7 tap targets contain an extra seat', () {
      final row = _catalogRow('blinds_postflop_button');
      final runner = row.task.runner;
      final choices = runner.options.map((choice) => choice.seatId!).toSet();
      final extra = runner.table.seats.firstWhere(
        (seat) => !choices.contains(seat.seatId),
      );
      final mutated = _withRunner(
        row,
        runner.copyWith(
          table: runner.table.copyWith(
            selectableSeatIds: [...choices, extra.seatId],
          ),
        ),
      );
      expect(
        runCatalogAudit(rows: [mutated]).findings,
        contains('7.selectable_seats|${row.task.taskId}|table'),
      );
    });

    test('G1·8 flop without cards and an absent highlighted card', () {
      final row = _catalogRow('blinds_postflop_button');
      final runner = row.task.runner;
      final mutated = _withRunner(
        row,
        runner.copyWith(
          table: runner.table.copyWith(
            boardCards: const [],
            highlightedCardIds: const ['board_2'],
          ),
        ),
      );
      final findings = runCatalogAudit(rows: [mutated]).findings;
      expect(
        findings,
        contains('8.street_board_count|${row.task.taskId}|table'),
      );
      expect(
        findings,
        contains('8.card_focus_exists|${row.task.taskId}|board_2'),
      );
    });

    test('G1·9 a different hand inherits a context-specific reason', () {
      final source = _catalogRow('continue_or_let_go_premium_continue');
      final target = _catalogRow('discipline_checkpoint_checkpoint_premium');
      const wrongReason = 'This hand is a pocket pair of queens.';
      final audit = runCatalogAudit(
        rows: [
          _withRunner(
            source,
            source.task.runner.copyWith(feedbackReason: wrongReason),
          ),
          _withRunner(
            target,
            target.task.runner.copyWith(feedbackReason: wrongReason),
          ),
        ],
      );
      expect(
        audit.findings,
        contains('9.inherited_copy|${target.task.taskId}|feedback'),
      );
    });

    test('G1·10 a valid repair placed after its source is rejected', () {
      final source = _catalogRow('button_advantage_find_button');
      final target = _catalogRow(
        'position_six_seats_position_repair_seat_id_btn',
      );
      final laterTarget = (
        world: target.world,
        lesson: target.lesson,
        lessonIndex: source.lessonIndex + 1,
        task: target.task,
      );
      expect(
        runCatalogAudit(rows: [source, laterTarget]).findings,
        contains('10.repair_order|${source.task.taskId}|co'),
      );
    });
  });

  test(
    'W1 rules check uses ten independent decisions with G1 source checks',
    () {
      expect(rulesCheckCatalogTasks, hasLength(10));
      final questions = catalogTasks
          .map((row) => catalogQuestion(row.task))
          .toSet();
      for (final row in rulesCheckCatalogTasks) {
        expect(
          questions.add(catalogQuestion(row.task)),
          isTrue,
          reason: row.task.taskId,
        );
        expect(
          row.task.runner.options.where((option) => option.isCorrect),
          hasLength(1),
        );
        expect(row.task.runner.hintPolicy, Act0HintPolicyV1.hidden);
        expect(row.task.rewardXp, 0);
      }
      final findings = runCatalogAudit(
        rows: [...catalogTasks, ...rulesCheckCatalogTasks],
      ).findings;
      expect(
        findings.entries.where(
          (entry) =>
              entry.key.contains('|w1_rules_check_') &&
              !entry.key.startsWith('10.'),
        ),
        isEmpty,
      );
    },
  );

  test('catalog truth debt admits only recorded findings', () {
    final audit = runCatalogAudit();
    auditCatalogReachabilitySources(
      readAct0ShellStateCatalogSourcesV1(),
      audit,
    );
    expect(audit.checks['2.starting_chart'], greaterThan(30));
    final streetFrames = catalogTasks.where(
      (row) => const {
        'Preflop',
        'Flop',
        'Turn',
        'River',
      }.contains(row.task.runner.table.streetLabel),
    );
    expect(audit.checks['8.street_board_count'], streetFrames.length);
    expect(audit.checks['4.reachability'], greaterThan(300));
    _verifyBaseline(audit, 'source', 'source');
  });

  testWidgets(
    'first-lesson rehearsal and standalone choice hide the board answer',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final id in [
        'first_table_guide_shared_cards_repair',
        'cards_ranks_suits_private_board',
      ]) {
        final row = _catalogRow(id);
        final runner = row.task.runner;
        await tester.pumpWidget(
          MaterialApp(
            key: ValueKey(id),
            locale: const Locale('en'),
            home: Scaffold(
              body: Act0LessonRunnerShellV1(
                runner: runner.copyWith(
                  phase: row.task.entryPhase,
                  teachingStepIndex: runner.teachingSteps.length,
                ),
                worldNumber: 1,
                selectedWorldId: row.world.worldId,
                selectedLessonId: row.lesson.lessonId,
                selectedTaskId: id,
                selectedTaskTitle: row.task.title,
                selectedTaskFamily: row.task.resolvedTaskFamily,
                compositionFamily: row.task.resolvedCompositionFamily,
                tablePresentation: row.task.tablePresentation,
                onBack: () {},
                onContinueTheory: () {},
                onChooseOption: (_) {},
                onContinueReview: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await pumpSourceChoreographyToDecisionV1(tester, runner.table);
        expect(find.text('Which cards can everyone use?'), findsWidgets);
        expect(find.text('Board cards'), findsOneWidget);
        expect(find.text('Shared board', findRichText: true), findsNothing);
        expect(tester.takeException(), isNull, reason: id);
      }
    },
  );

  testWidgets('rendered pre-choice seat cues and controls', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final audit = CatalogAudit();
    for (final row in catalogTasks) {
      final task = row.task;
      final r = task.runner;
      final correct = r.options
          .where(act0RunnerOptionIsAuthoredCorrectV1)
          .firstOrNull;
      if (correct == null || correct.seatId == null) continue;
      final answer = correct.seatId!;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          key: ValueKey(task.taskId),
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: r.copyWith(
                phase: task.entryPhase,
                teachingStepIndex: r.teachingSteps.length,
              ),
              worldNumber: row.world.worldNumber,
              selectedWorldId: row.world.worldId,
              selectedLessonId: row.lesson.lessonId,
              selectedTaskId: task.taskId,
              selectedTaskTitle: task.title,
              selectedTaskFamily: task.resolvedTaskFamily,
              compositionFamily: task.resolvedCompositionFamily,
              tablePresentation: task.tablePresentation,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await pumpSourceChoreographyToDecisionV1(tester, r.table);
      final focus = [
        'act0_shell_seat_state_' + answer + '_activeFocus',
        'act0_shell_seat_state_' + answer + '_targetFocus',
      ].where((key) => find.byKey(Key(key)).evaluate().isNotEmpty).toList();
      audit.check(
        '6.rendered_seat_cue',
        row,
        answer,
        focus.isEmpty,
        'The pre-choice Runner marks the answer seat: $focus.',
      );
      final support = find.byKey(const Key('act0_learning_scene_v3_support'));
      final captions = tester
          .widgetList<Text>(support)
          .map((text) => text.data ?? '');
      if (task.taskId == 'button_advantage_button_vs_cutoff') {
        final question = find.byKey(const Key('act0_integrated_scene_prompt'));
        expect(question, findsOneWidget);
        final bounds = tester.getRect(question);
        expect(bounds.height, greaterThan(0));
        expect((Offset.zero & const Size(393, 852)).overlaps(bounds), isTrue);
      }
      audit.check(
        '6.rendered_seat_order_copy',
        row,
        'caption',
        !captions.any((caption) => revealsComparativeSeatOrder(row, caption)),
        'The visible pre-choice caption discloses the seat order: $captions.',
      );
      final tapIds = [
        for (final seat in r.table.seats)
          if (find
              .byKey(Key('act0_shell_seat_tap_' + seat.seatId))
              .evaluate()
              .isNotEmpty)
            seat.seatId,
      ].toSet();
      if (tapIds.isNotEmpty && r.options.every((o) => o.seatId != null)) {
        final expected = r.options.map((o) => o.seatId!).toSet();
        audit.check(
          '6.rendered_seat_controls',
          row,
          'table',
          tapIds.length == expected.length && tapIds.containsAll(expected),
          'Rendered tap targets $tapIds differ from choices $expected.',
        );
      }
      expect(tester.takeException(), isNull, reason: task.taskId);
    }
    expect(audit.checks['6.rendered_seat_cue'], greaterThan(15));
    expect(audit.checks['6.rendered_seat_controls'], greaterThan(10));
    _verifyBaseline(audit, 'render', 'render');
  });

  test('G1·11–G1·19 catalog quality baseline admits no regressions', () {
    final report = runCatalogQualityAudit();
    final baselineFile = File(_qualityBaselinePath);
    if (Platform.environment['G1_UPDATE_QUALITY_BASELINE'] == '1') {
      baselineFile.createSync(recursive: true);
      baselineFile.writeAsStringSync(
        '${_json.convert(report.toBaselineJson())}\n',
      );
      return;
    }

    expect(
      baselineFile.existsSync(),
      isTrue,
      reason: 'Missing quality baseline $_qualityBaselinePath',
    );
    final baseline =
        jsonDecode(baselineFile.readAsStringSync()) as Map<String, dynamic>;
    final baselineBtn =
        (baseline['btn_share_by_world'] as Map<String, dynamic>? ?? const {});
    for (final entry in report.btnShareByWorld.entries) {
      final recorded = baselineBtn[entry.key] as Map<String, dynamic>?;
      expect(
        recorded,
        isNotNull,
        reason: 'New world > 50% BTN: ${entry.key} (${entry.value})',
      );
      final recordedBtn = recorded!['btn_count'] as int;
      final recordedTotal = recorded['table_tasks'] as int;
      expect(
        entry.value.btnCount,
        lessThanOrEqualTo(recordedBtn),
        reason:
            'BTN task count regressed in ${entry.key}: ${entry.value.btnCount} > $recordedBtn',
      );
      expect(
        entry.value.btnCount * recordedTotal,
        lessThanOrEqualTo(recordedBtn * entry.value.tableTasks),
        reason:
            'BTN share regressed in ${entry.key}: ${entry.value.btnCount}/${entry.value.tableTasks} > $recordedBtn/$recordedTotal',
      );
    }
    for (final entry in baselineBtn.entries) {
      final current = report.btnShareByWorld[entry.key];
      final recordedBtn =
          (entry.value as Map<String, dynamic>)['btn_count'] as int;
      expect(
        current,
        isNotNull,
        reason:
            'Remove cleared world from quality baseline btn_share_by_world: ${entry.key}',
      );
      expect(
        current!.btnCount,
        recordedBtn,
        reason:
            'Ratchet down btn_count in quality baseline for ${entry.key}: ${current.btnCount} < $recordedBtn',
      );
    }

    final allowedFindings =
        ((baseline['findings'] as List<dynamic>?) ?? const [])
            .cast<String>()
            .toSet();
    final actualFindings = report.findings;
    final added = actualFindings.difference(allowedFindings).toList()..sort();
    final removed = allowedFindings.difference(actualFindings).toList()..sort();
    expect(
      added,
      isEmpty,
      reason: 'New G1 quality regressions:\n${added.take(30).join('\n')}',
    );
    expect(
      removed,
      isEmpty,
      reason:
          'Remove resolved G1 quality findings from baseline:\n${removed.take(30).join('\n')}',
    );
  });

  group('G1 quality guards reject regressions', () {
    CatalogTask syntheticRow(
      CatalogTask base, {
      String? id,
      Act0LessonPhaseV1? phase,
      Act0RunnerStateV1? runner,
      String? lessonId,
    }) {
      final task = _withRunner(base, runner ?? base.task.runner, id: id);
      return (
        world: base.world,
        lesson: lessonId == null
            ? base.lesson
            : Act0LessonCardV1(
                lessonId: lessonId,
                title: base.lesson.title,
                subtitle: base.lesson.subtitle,
                state: base.lesson.state,
                phaseLabel: base.lesson.phaseLabel,
                primaryCtaLabel: base.lesson.primaryCtaLabel,
                isSelectable: base.lesson.isSelectable,
                isLocked: base.lesson.isLocked,
                rewardXp: base.lesson.rewardXp,
                runner: runner ?? base.task.runner,
              ),
        lessonIndex: base.lessonIndex,
        task: phase == null
            ? task.task
            : Act0LessonTaskV1(
                taskId: task.task.taskId,
                title: task.task.title,
                phase: phase,
                runner: task.task.runner,
                rewardXp: task.task.rewardXp,
                stepKind: task.task.stepKind,
                taskFamily: task.task.taskFamily,
                repairOnly: task.task.repairOnly,
              ),
      );
    }

    test(
      'rejects BTN > 50%, two-option W1–W5, long intro, duplicate theory, jargon, extreme wrong option, single-format streak, length corridor, and duplicate QQ',
      () {
        final w2Base = _catalogRow('hand_discipline_buckets_premium');
        final tableBtn = w2Base.task.runner.table.copyWith(heroSeatId: 'btn');
        final longBody = List.filled(105, 'word').join(' ');
        const dupTheory =
            'This exact paragraph repeats inside the same lesson unnecessarily.';
        final stmtOptions = <Act0RunnerOptionV1>[
          const Act0RunnerOptionV1(
            id: 'right_stmt',
            label: 'Because position lets you see actions first',
            isCorrect: true,
            preferredLabel: 'Because position lets you see actions first',
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Position matters.',
            feedbackReason: 'Acting later gives you extra information.',
          ),
          const Act0RunnerOptionV1(
            id: 'wrong_stmt',
            label: 'Always raise regardless of seat',
            isCorrect: false,
            preferredLabel: 'Because position lets you see actions first',
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Check position.',
            feedbackReason: 'Early seats act before the rest of the table.',
          ),
          const Act0RunnerOptionV1(
            id: 'other_stmt',
            label: 'Cards change strength each street',
            isCorrect: false,
            preferredLabel: 'Because position lets you see actions first',
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Different factor.',
            feedbackReason: 'Focus on turn order.',
          ),
        ];
        final qqCards = const <Act0CardStateV1>[
          Act0CardStateV1(rank: 'Q', suit: 's'),
          Act0CardStateV1(rank: 'Q', suit: 'h'),
        ];

        final rows = <CatalogTask>[
          syntheticRow(
            w2Base,
            id: 'syn_intro_long',
            phase: Act0LessonPhaseV1.theory,
            lessonId: 'syn_short_lesson',
            runner: w2Base.task.runner.copyWith(
              table: tableBtn.copyWith(heroCards: qqCards),
              teachingSteps: [
                Act0TeachingStepV1(title: 'Too long', body: longBody),
              ],
              options: const [],
            ),
          ),
          syntheticRow(
            w2Base,
            id: 'syn_two_opt',
            lessonId: 'syn_streak_lesson',
            runner: w2Base.task.runner.copyWith(
              table: tableBtn.copyWith(heroCards: qqCards),
              caption: 'Exploit baseline heuristic.',
              teachingSteps: const [
                Act0TeachingStepV1(title: 'A', body: dupTheory),
              ],
              options: stmtOptions.take(2).toList(),
            ),
          ),
          for (var i = 0; i < 6; i++)
            syntheticRow(
              w2Base,
              id: 'syn_streak_$i',
              lessonId: 'syn_streak_lesson',
              runner: w2Base.task.runner.copyWith(
                table: tableBtn,
                teachingSteps: i == 0
                    ? const [Act0TeachingStepV1(title: 'Dup', body: dupTheory)]
                    : const [],
                options: stmtOptions,
              ),
            ),
          syntheticRow(
            w2Base,
            id: 'syn_bloated_task',
            lessonId: 'syn_long_lesson',
            runner: w2Base.task.runner.copyWith(
              table: tableBtn,
              caption: List.filled(1000, 'chips').join(' '),
              options: stmtOptions,
            ),
          ),
          syntheticRow(
            w2Base,
            id: 'syn_allin_two_opt_ok',
            lessonId: 'syn_allin_lesson',
            runner: w2Base.task.runner.copyWith(
              table: tableBtn.copyWith(
                seats: [
                  for (final seat in tableBtn.seats)
                    seat.isHero
                        ? seat
                        : Act0SeatStateV1(
                            seatId: seat.seatId,
                            seatLabel: seat.seatLabel,
                            displayName: seat.displayName,
                            stackLabel: '0 BB',
                            isHero: false,
                            holeCards: seat.holeCards,
                            cardsVisibleMode: seat.cardsVisibleMode,
                            bet: seat.seatId == 'co'
                                ? const Act0SeatBetStateV1(
                                    kind: Act0SeatBetKindV1.allIn,
                                    label: 'All-in',
                                    amountLabel: '8 BB',
                                  )
                                : seat.bet,
                          ),
                ],
              ),
              options: const [
                Act0RunnerOptionV1(
                  id: 'call',
                  label: 'Call',
                  isCorrect: true,
                  preferredLabel: 'Call',
                  quality: Act0FeedbackQualityV1.correct,
                  feedbackTitle: 'Profitable call.',
                  feedbackReason: 'You get enough equity.',
                ),
                Act0RunnerOptionV1(
                  id: 'fold',
                  label: 'Fold',
                  isCorrect: false,
                  preferredLabel: 'Call',
                  quality: Act0FeedbackQualityV1.wrong,
                  feedbackTitle: 'Too tight.',
                  feedbackReason: 'The call is cheap enough.',
                ),
              ],
            ),
          ),
        ];

        final report = runCatalogQualityAudit(rows: rows);
        expect(report.btnShareByWorld, contains('world_2'));
        expect(
          report.findings,
          containsAll([
            '11.btn_share_per_world|world_2',
            '12.two_option_w1_w5|syn_two_opt',
            '13.intro_over_100_words|syn_intro_long',
            '14.duplicate_theory_in_lesson|syn_streak_lesson|syn_streak_0',
            '15.internal_jargon|syn_two_opt|exploit',
            '15.internal_jargon|syn_two_opt|baseline',
            '15.internal_jargon|syn_two_opt|heuristic',
            '16.extreme_wrong_option|syn_two_opt|wrong_stmt',
            '17.single_format_lesson|syn_streak_lesson|statement',
            '18.same_format_streak|world_2|syn_two_opt|statement',
            '19.lesson_length_corridor|syn_short_lesson|too_short',
            '19.lesson_length_corridor|syn_long_lesson|too_long',
            '20.hero_qq_per_world|world_2|syn_two_opt',
            '21.duplicate_wrong_reason|syn_streak_0|wrong_stmt',
          ]),
        );
        expect(
          report.findings,
          isNot(contains('12.two_option_w1_w5|syn_allin_two_opt_ok')),
        );
      },
    );

    test(
      'rejects duplicate wrong-option feedbackReason across non-repair tasks',
      () {
        final base = _catalogRow('hand_discipline_buckets_premium');
        const dupReason =
            'Calling 2.5 BB into a 4 BB pot with a weak ace loses to stronger aces.';
        final duplicateOptions = const <Act0RunnerOptionV1>[
          Act0RunnerOptionV1(
            id: 'fold',
            label: 'Fold',
            isCorrect: true,
            preferredLabel: 'Fold',
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Clean fold.',
            feedbackReason: 'Folding saves 2.5 BB with a dominated hand.',
          ),
          Act0RunnerOptionV1(
            id: 'call',
            label: 'Call',
            isCorrect: false,
            preferredLabel: 'Fold',
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Too loose.',
            feedbackReason: dupReason,
          ),
        ];
        final uniqueOptions = const <Act0RunnerOptionV1>[
          Act0RunnerOptionV1(
            id: 'fold',
            label: 'Fold',
            isCorrect: true,
            preferredLabel: 'Fold',
            quality: Act0FeedbackQualityV1.correct,
            feedbackTitle: 'Clean fold.',
            feedbackReason: 'Folding protects your stack from UTG.',
          ),
          Act0RunnerOptionV1(
            id: 'raise',
            label: 'Raise',
            isCorrect: false,
            preferredLabel: 'Fold',
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Too early.',
            feedbackReason:
                'Raising from UTG into a 1.5 BB pot risks chips with five players behind.',
          ),
        ];

        final rows = <CatalogTask>[
          syntheticRow(
            base,
            id: 'syn_dup_wrong_a',
            runner: base.task.runner.copyWith(options: duplicateOptions),
          ),
          syntheticRow(
            base,
            id: 'syn_dup_wrong_b',
            runner: base.task.runner.copyWith(options: duplicateOptions),
          ),
          syntheticRow(
            base,
            id: 'syn_unique_wrong_c',
            runner: base.task.runner.copyWith(options: uniqueOptions),
          ),
        ];

        final report = runCatalogQualityAudit(rows: rows);
        expect(
          report.findings,
          contains('21.duplicate_wrong_reason|syn_dup_wrong_b|call'),
        );
        expect(
          report.findings,
          isNot(contains('21.duplicate_wrong_reason|syn_dup_wrong_a|call')),
        );
        expect(
          report.findings,
          isNot(contains('21.duplicate_wrong_reason|syn_unique_wrong_c|raise')),
        );
      },
    );
  });

  test(
    'offline 2-template practice generator satisfies G1, C1 contributions, and quality guards',
    () {
      final openFold = generateOpenFoldByChartTasksV1(count: 12, seed: 7);
      final turnDecision = generateTurnCallPriceWithOutsTasksV1(
        count: 12,
        seed: 7,
        mode: TurnOutsModeV1.callOrFoldAllIn,
      );
      final turnNumeric = generateTurnCallPriceWithOutsTasksV1(
        count: 8,
        seed: 19,
        mode: TurnOutsModeV1.outsPriceNumeric,
      );
      final allGenerated = [...openFold, ...turnDecision, ...turnNumeric];
      expect(allGenerated, hasLength(32));

      final rows = [for (final item in allGenerated) item.toCatalogRow()];
      final truthAudit = runCatalogAudit(rows: rows);
      final unexpectedTruth = truthAudit.findings.keys
          .where((key) => !key.startsWith('10.'))
          .toList();
      expect(unexpectedTruth, isEmpty, reason: unexpectedTruth.join('\n'));
      expect(truthAudit.checks['2.starting_chart'], openFold.length);

      for (final item in allGenerated) {
        final r = item.task.runner;
        final table = r.table;
        expect(actorFlagsConsistent(table), isTrue, reason: item.task.taskId);
        final contrib = auditTableContributionsV1(
          item.task.taskId,
          'generated',
          table,
        );
        final contribMap = {for (final c in contrib) c.invariant: c.result};
        expect(
          contribMap['D2.pot_feasibility'],
          'PASS',
          reason: item.task.taskId,
        );
        expect(
          contribMap['D3.to_call_completeness'],
          'PASS',
          reason: item.task.taskId,
        );
        for (final o in r.options.where((o) => !o.isCorrect)) {
          expect(
            _praiseAtStart.hasMatch(o.feedbackTitle.trim()),
            isFalse,
            reason: '${item.task.taskId}/${o.id}: ${o.feedbackTitle}',
          );
        }
      }

      final quality = runCatalogQualityAudit(rows: rows);
      expect(quality.btnShareByWorld, isEmpty);
      final disallowedQuality = quality.findings
          .where(
            (key) => const {
              '12.',
              '13.',
              '14.',
              '15.',
              '16.',
              '20.',
            }.any(key.startsWith),
          )
          .toList();
      expect(disallowedQuality, isEmpty, reason: disallowedQuality.join('\n'));

      expect(
        renderGeneratedSummaryMarkdownV1(openFold),
        contains('gen_open_fold_'),
      );
      expect(
        renderGeneratedDay7DartV1(turnDecision),
        contains('generatedPracticeCandidatesV1'),
      );
    },
  );
}
