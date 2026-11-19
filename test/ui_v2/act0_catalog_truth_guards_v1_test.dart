import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_catalog_claims_v1.dart';
import '../support/act0_catalog_poker_facts_v1.dart';
import '../support/act0_catalog_reachability_v1.dart';
import '../support/act0_catalog_snapshot_v1.dart';
import '../support/act0_catalog_truth_audit_v1.dart';
import '../support/act0_source_choreography_test_wait_v1.dart';

// Regenerate only the reviewer-visible snapshot:
// G1_UPDATE_SNAPSHOT=1 flutter test test/ui_v2/act0_catalog_truth_guards_v1_test.dart --plain-name 'W1–W12 catalog snapshot'
const _snapshotPath = 'test/fixtures/act0_catalog_snapshot_v1.txt';
const _baselinePath = 'test/fixtures/act0_catalog_truth_exceptions_v1.json';
const _sourcePath = 'lib/ui_v2/act0_shell/act0_shell_state_v1.dart';

const _json = JsonEncoder.withIndent('  ');

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

  test('catalog truth debt admits only recorded findings', () {
    final audit = runCatalogAudit();
    auditCatalogReachability(File(_sourcePath).readAsStringSync(), audit);
    expect(audit.checks['2.starting_chart'], greaterThan(30));
    expect(audit.checks['8.street_board_count'], greaterThan(300));
    expect(audit.checks['4.reachability'], greaterThan(300));
    _verifyBaseline(audit, 'source', 'source');
  });

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
}
