import 'package:poker_analyzer/ui_v2/act0_shell/act0_curriculum_pilot_v1.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';
import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_decision_ledger_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_decision_reasoning_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_timeline_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_summary_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_catalog_chart_audit_v1.dart';
import '../support/act0_catalog_claims_v1.dart';
import '../support/act0_catalog_decision_copy_v1.dart';
import '../support/act0_catalog_learner_copy_v1.dart';
import '../support/act0_catalog_poker_facts_v1.dart';
import '../support/act0_catalog_quality_audit_v1.dart';
import '../support/act0_catalog_reachability_v1.dart';
import '../support/act0_catalog_reasoning_audit_v1.dart';
import '../support/act0_catalog_rubric_guards_v1.dart';
import '../support/act0_starting_chart_checks_v1.dart';
import '../support/act0_catalog_snapshot_v1.dart';
import '../support/act0_catalog_truth_audit_v1.dart';
import '../support/act0_table_chip_labels_v1.dart';
import '../support/act0_day7_coverage_v1.dart';
import '../support/act0_error_atlas_v1.dart';
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

Act0RunnerOptionV1 _withOptionReason(
  Act0RunnerOptionV1 option,
  String reason, {
  Act0FeedbackQualityV1? quality,
}) => Act0RunnerOptionV1(
  id: option.id,
  label: option.label,
  amountLabel: option.amountLabel,
  seatId: option.seatId,
  isCorrect: quality?.passes ?? option.isCorrect,
  preferredLabel: option.preferredLabel,
  betterAnswerLabel: option.betterAnswerLabel,
  quality: quality ?? option.quality,
  feedbackTitle: option.feedbackTitle,
  feedbackReason: reason,
  repairFocusSeatIds: option.repairFocusSeatIds,
  repairFocusCardIds: option.repairFocusCardIds,
  repairFocusLabels: option.repairFocusLabels,
);

CatalogTask _withDecisionCopy(CatalogTask row, Map<String, String> copy) =>
    _withRunner(
      row,
      row.task.runner.copyWith(
        options: [
          for (final option in row.task.runner.options)
            _withOptionReason(option, copy[option.id] ?? option.feedbackReason),
        ],
      ),
    );

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

// B21 decisions whose tables omit authored starting stacks. Keep these visible
// in G1 until the source facts are available.
const _w1W4HistoryGaps = {
  'hand_discipline_buckets_trash',
  'fold_discipline_early_fold',
  'weak_ace_warning_w3_dominated_intro',
  'continue_or_let_go_medium_open',
  'discipline_checkpoint_checkpoint_table_discipline',
  'button_advantage_button_open',
  'early_vs_late_late_info_choice',
  'same_hand_different_seat_w3_same_hand_open',
  'same_hand_different_seat_same_hand_early_fold',
  'same_hand_different_seat_same_hand_late_open',
  'position_apply_btn_open',
  'position_apply_late_open',
  'position_apply_recap',
  'position_checkpoint_position_checkpoint_late_open',
  'position_checkpoint_position_checkpoint_early_fold',
  'position_checkpoint_position_checkpoint_table_notice',
  'position_checkpoint_position_checkpoint_review',
  'w4_purpose_intro',
  'w4_bad_bluff',
  'w4_protection_intro',
  'w4_protection_bet',
  'w4_checkpoint_value',
  'w4_checkpoint_table_purpose_price',
};

void main() {
  test(
    'G1·51 history gaps and complete timelines agree with authored truth',
    () {
      final covered = <String, Act0HandHistoryCoverageV1>{};
      final observedGaps = <String>{};
      for (final row in [...catalogTasks, ...day7CatalogTasks]) {
        final task = row.task;
        final table = task.runner.table;
        final timeline = table.handTimelinePrefix;
        final isW1W4 =
            row.world.worldNumber <= 4 &&
            catalogTasks.any((entry) => identical(entry.task, task));
        if (isW1W4 && table.actionTrail.isNotEmpty && timeline == null) {
          observedGaps.add(task.taskId);
        }
        if (timeline == null) {
          expect(table.handHistoryCoverage, Act0HandHistoryCoverageV1.missing);
          continue;
        }
        if (!isW1W4) covered[task.taskId] = timeline.coverage;
        final reason = 'History gap in ${task.taskId}';
        final summary = Act0StreetSummaryV1(timeline);
        expect(summary.heroSeat, table.heroSeatId ?? table.heroSeat.seatId);
        expect(summary.coverage, timeline.coverage);
        expect(
          summary.streets.map((row) => row.name),
          PokerStreet.values.take(timeline.street.index),
          reason: reason,
        );
        expect(summary.frameAt(timeline.street), isNull, reason: reason);
        expect(
          pokerStreetToString(timeline.street),
          table.streetLabel,
          reason: reason,
        );
        expect(timeline.board, [
          for (final card in table.boardCards) card.label,
        ], reason: reason);
        if (timeline.coverage == Act0HandHistoryCoverageV1.partialDrill) {
          expect(summary.amountsAtDecision(), isNull, reason: reason);
          expect(
            summary.streets.every(
              (row) =>
                  row.potAfterBb == null && (isW1W4 || row.actions.isEmpty),
            ),
            isTrue,
            reason: reason,
          );
          expect(
            () => timeline.contributions,
            throwsStateError,
            reason: reason,
          );
          continue;
        }
        final actor = (table.decisionSeatId ?? table.activeSeatId)!;
        expect(timeline.decisionError(actor), isNull, reason: reason);
        final contributions = timeline.contributions;
        final authored = table.handContributions!;
        final totals = summary.amountsAtDecision(actorSeat: actor)!;
        final expectedStreetPots = switch (task.taskId) {
          'w11_trigger_bad_price_fold' => [6.0, 10.0],
          'w12_river_draw_missed' => [5.0, 10.0, 14.0],
          _ => null,
        };
        if (expectedStreetPots != null) {
          expect(
            summary.streets.map((row) => row.potAfterBb),
            expectedStreetPots,
            reason: reason,
          );
        }
        double labelAmount(String label) =>
            double.parse(RegExp(r'(\d+(?:\.\d+)?) BB$').firstMatch(label)![1]!);
        expect(
          totals.potBb,
          closeTo(labelAmount(table.potLabel), 1e-9),
          reason: reason,
        );
        expect(
          totals.toCallBb,
          closeTo(
            table.toCallLabel.isEmpty ? 0 : labelAmount(table.toCallLabel),
            1e-9,
          ),
          reason: reason,
        );
        if (isW1W4) {
          Map<(PokerStreet, String, Act0ContributionKindV1), double> bySeat(
            Act0HandContributionsV1 ledger,
          ) {
            final totals =
                <(PokerStreet, String, Act0ContributionKindV1), double>{};
            for (final entry in ledger.entries) {
              final key = (entry.street, entry.seatId, entry.kind);
              totals.update(
                key,
                (amount) => amount + entry.amountBb,
                ifAbsent: () => entry.amountBb,
              );
            }
            return totals;
          }

          expect(bySeat(contributions), bySeat(authored), reason: reason);
          for (final entry in authored.startingStackBbBySeat.entries) {
            expect(
              contributions.startingStackBbBySeat[entry.key],
              entry.value,
              reason: reason,
            );
          }
          for (final seat in table.seats) {
            final stack = seat.stackLabel;
            if (stack == null) continue;
            final paid = contributions.entries
                .where((e) => e.seatId == seat.seatId)
                .fold(0.0, (sum, entry) => sum + entry.amountBb);
            expect(
              contributions.startingStackBbBySeat[seat.seatId]! - paid,
              closeTo(labelAmount(stack), 1e-9),
              reason: reason,
            );
          }
        } else {
          expect(
            contributions.startingStackBbBySeat,
            authored.startingStackBbBySeat,
            reason: reason,
          );
          expect(
            contributions.entries.map(
              (e) => (e.street, e.seatId, e.kind, e.amountBb),
            ),
            authored.entries.map(
              (e) => (e.street, e.seatId, e.kind, e.amountBb),
            ),
            reason: reason,
          );
        }
        expect(
          timeline.events
              .whereType<Act0HandActionV1>()
              .where((action) => action.verb == Act0HandVerbV1.fold)
              .map((action) => action.seat)
              .toSet(),
          table.seats
              .where((seat) => seat.isFolded)
              .map((seat) => seat.seatId)
              .toSet(),
          reason: reason,
        );
      }
      expect(observedGaps, _w1W4HistoryGaps);
      expect(covered, {
        'w11_trigger_bad_price_fold': Act0HandHistoryCoverageV1.complete,
        'w12_river_draw_missed': Act0HandHistoryCoverageV1.complete,
        'spaced_review_w8_effective_stack_fold_v1':
            Act0HandHistoryCoverageV1.partialDrill,
      });
    },
  );

  testWidgets(
    'W4 turn decision retains the authored price and answer options',
    (tester) async {
      final row = catalogTasks.singleWhere(
        (row) => row.task.taskId == 'w4_good_price_call',
      );
      final task = row.task;
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: task.entryPhase,
                teachingStepIndex: task.runner.teachingSteps.length,
              ),
              worldNumber: 4,
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
      final runner = tester
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .runner;
      expect(
        runner.table.handHistoryCoverage,
        Act0HandHistoryCoverageV1.complete,
      );
      expect(runner.table.toCallLabel, 'To call 1 BB');
      expect(runner.options, task.runner.options);
      expect(tester.takeException(), isNull);
    },
  );

  test('hand timeline exposes only pre-decision actions and cards', () {
    final events = [
      Act0HandDealV1(PokerStreet.flop, ['As', '2h', '3d']),
      const Act0HandActionV1(
        PokerStreet.flop,
        'BB',
        Act0HandVerbV1.check,
        0,
        streetTotal: 0,
      ),
      const Act0HandActionV1(
        PokerStreet.flop,
        'BTN',
        Act0HandVerbV1.bet,
        500,
        streetTotal: 500,
      ),
      Act0HandDealV1(PokerStreet.turn, ['4s']),
      Act0HandDealV1(PokerStreet.river, ['5s']),
    ];
    final prefix = Act0HandTimelineV1(
      coverage: Act0HandHistoryCoverageV1.partialDrill,
      startingStacks: const {'BB': 10000, 'BTN': 10000},
      button: 'BTN',
      smallBlind: 50,
      bigBlind: 100,
      events: events,
      decisionIndex: 2,
    ).beforeDecision;
    events.clear();
    expect(prefix.events, hasLength(2));
    expect(prefix.board, ['As', '2h', '3d']);
    expect(prefix.eventsOn(PokerStreet.turn), isEmpty);
    expect(prefix.eventsOn(PokerStreet.river), isEmpty);
    expect(
      prefix.events.whereType<Act0HandActionV1>().single.verb,
      Act0HandVerbV1.check,
    );
    expect(() => prefix.events.clear(), throwsUnsupportedError);
    final restored = Act0HandTimelinePrefixV1.tryParse(
      jsonDecode(jsonEncode(prefix.toPayload())),
    );
    expect(restored?.toPayload(), prefix.toPayload());
  });

  test(
    'complete timelines reject wrong order and a raise over one short all-in',
    () {
      Act0HandTimelinePrefixV1 prefix(List<Act0HandDeltaV1> actions) =>
          Act0HandTimelineV1.fromDeltas(
            coverage: Act0HandHistoryCoverageV1.complete,
            startingStacks: const {'BTN': 2000, 'SB': 350, 'BB': 2000},
            button: 'BTN',
            smallBlind: 50,
            bigBlind: 100,
            board: const [],
            actions: actions,
          ).beforeDecision;
      const start = [
        (
          street: PokerStreet.preflop,
          seat: 'SB',
          verb: Act0HandVerbV1.smallBlind,
          chipsAdded: 50,
        ),
        (
          street: PokerStreet.preflop,
          seat: 'BB',
          verb: Act0HandVerbV1.bigBlind,
          chipsAdded: 100,
        ),
        (
          street: PokerStreet.preflop,
          seat: 'BTN',
          verb: Act0HandVerbV1.raise,
          chipsAdded: 300,
        ),
        (
          street: PokerStreet.preflop,
          seat: 'SB',
          verb: Act0HandVerbV1.raise,
          chipsAdded: 300,
        ),
        (
          street: PokerStreet.preflop,
          seat: 'BB',
          verb: Act0HandVerbV1.call,
          chipsAdded: 250,
        ),
      ];
      final legal = prefix(start);
      expect(
        prefix(start.skip(1).toList()).decisionError('BTN'),
        contains('event 1'),
      );
      expect(legal.decisionError('BTN'), isNull);
      expect(
        legal.events.whereType<Act0HandActionV1>().elementAt(3).allIn,
        isTrue,
      );
      expect(
        prefix([start[0], start[1], start[3]]).decisionError('BTN'),
        contains('event 3'),
      );
      expect(
        prefix([
          ...start,
          (
            street: PokerStreet.preflop,
            seat: 'BTN',
            verb: Act0HandVerbV1.raise,
            chipsAdded: 250,
          ),
        ]).decisionError('BB'),
        contains('event 6'),
      );
      expect(
        () => prefix([
          ...start,
          (
            street: PokerStreet.preflop,
            seat: 'BTN',
            verb: Act0HandVerbV1.raise,
            chipsAdded: 1800,
          ),
        ]),
        throwsFormatException,
      );
    },
  );

  test('learner catalog copy uses full-ring chart seat names', () {
    expect(nonChartSeatTokensV1('UTG+1 opens.'), isEmpty);
    expect(nonChartSeatTokensV1('«UTG+2» opens.'), ['UTG+2']);
    expect(
      catalogTasks.expand((row) => catalogSeatNameFindingsV1(row.task)),
      isEmpty,
    );
  });

  registerAct0StartingChartChecksV1();
  registerAct0ErrorAtlasV1();
  group('G1 catalog rubric', () {
    test('E11/E17/E18/E20 across course and both review banks', () {
      final rows = [
        ...catalogTasks,
        ...rulesCheckCatalogTasks,
        ...day7CatalogTasks,
      ];
      final findings = [
        for (final row in rows) ...catalogRubricFindingsV1(row.task),
      ];
      // These inherited Day 7 labels can only disappear from the baseline.
      const terminology = {
        'spaced_review_w5_flush_draws_board_cards_v1|hole card',
        'spaced_review_w5_turn_river_changes_board_cards_v1|hole card',
        'spaced_review_w6_range_board_fit_hero_cards_board_pot_v1|hole card',
        'spaced_review_w6_range_pressure_lines_hero_cards_board_pot_v1|hole card',
        'spaced_review_w8_same_hand_different_depth_pot_to_call_v1|shove',
        'spaced_review_w8_format_pressure_hero_cards_board_pot_v1|shove',
        'w11_day7_review_repair|shove',
        'spaced_review_w11_table_trigger_reads_board_cards_v1|hole card',
        'w12_day7_tilt_badbeat|shove',
        'w12_day7_tilt_after_error|shove',
        'w12_day7_fatigue_no_bluff|shove',
      };
      final added = findings.where(
        (hit) =>
            hit.rule != 'E11' ||
            !terminology.contains('${hit.task}|${hit.detail}'),
      );
      expect(added, isEmpty, reason: added.join('\n'));
    });

    test('rejects hidden premises, explicit answers, filler and jargon', () {
      final source = _catalogRow(
        'w3_play_from_blinds_small_blind_medium_raise',
      );
      final correct = source.task.runner.options.firstWhere((o) => o.isCorrect);
      final wrong = source.task.runner.options.firstWhere((o) => !o.isCorrect);
      const assumption = 'the opponent folds every second time';
      final bad = _withDecisionCopy(source, {
        correct.id: 'Assume $assumption. This is a donk bet.',
        wrong.id: 'On seat BTN.',
      });
      final leak = _withRunner(
        bad,
        bad.task.runner.copyWith(
          question: 'The best answer is ${correct.label}.',
          teachingSteps: [
            Act0TeachingStepV1(
              title: 'Decision',
              body: 'Choose ${correct.label}.',
            ),
          ],
        ),
      );
      expect(
        catalogRubricFindingsV1(leak.task).map((hit) => hit.rule),
        unorderedEquals(['E11', 'E17', 'E18', 'E18', 'E20']),
      );
      final visible = _withRunner(
        bad,
        bad.task.runner.copyWith(
          caption: 'In this example $assumption.',
          question: 'Is ${correct.label} the right decision?',
        ),
      );
      expect(
        catalogRubricFindingsV1(visible.task).map((hit) => hit.rule),
        unorderedEquals(['E11', 'E20']),
      );
      final empty = _withDecisionCopy(source, {wrong.id: '  '});
      expect(catalogRubricFindingsV1(empty.task).map((hit) => hit.rule), [
        'E20',
      ]);
    });

    test('E19 rejects relabeling with the original grade', () {
      const previous = '''
TASK river [decision] River
  + [best] Fold — Fold. Explanation.
  - [wrong] Call 2 BB — Call. Explanation.
''';
      const relabeled = '''
TASK river [decision] River
  + [best] Fold — Fold. New explanation.
  - [wrong] Call 6 BB — Call. Explanation.
''';
      expect(
        catalogOptionLabelChangesV1(previous, relabeled).single.rule,
        'E19',
      );
      expect(
        catalogOptionLabelChangesV1(previous, '''
TASK river [decision] River
  + [best] Call 2 BB — Call. Explanation.
  - [wrong] Fold — Fold. Explanation.
'''),
        isEmpty,
      );
      expect(
        catalogOptionLabelChangesV1(
          previous,
          previous.replaceFirst('Fold —', 'Fold! —'),
        ),
        isEmpty,
      );
    });

    test('E19 compares option labels with the previous catalog snapshot', () {
      final previous = previousCatalogSnapshotV1();
      if (previous == null) return;
      // B78 is an approved wording repair, not a change in choice meaning.
      // Permit only the exact old/new labels at the same task and grade.
      // The assessment census separately pins the option IDs and grades.
      const b78ApprovedCopy = {
        (
          'w7_low_spr_commit',
          'correct: one bet can commit the hand → one bet can use much of your stack',
        ),
        (
          'w7_high_spr_room',
          'wrong: immediate commitment → putting most of your stack in now',
        ),
        (
          'w7_spr4_middle',
          'correct: middle ground: some room, some commitment → some room, but big bets use chips quickly',
        ),
        (
          'w7_spr4_middle',
          'wrong: automatic commitment right now → you must put your whole stack in now',
        ),
        (
          'w7_top_pair_spr2_transfer',
          'correct: less room, more commitment pressure → a bet leaves fewer chips for later',
        ),
      };
      final findings =
          catalogOptionLabelChangesV1(previous, renderCatalogSnapshot())
              .where(
                (finding) =>
                    !b78ApprovedCopy.contains((finding.task, finding.detail)),
              )
              .toList();
      expect(findings, isEmpty, reason: findings.join('\n'));
    });
  });
  test('G1 relative seat copy and world codes across learner surfaces', () {
    final rows = [
      ...catalogTasks,
      ...rulesCheckCatalogTasks,
      ...day7CatalogTasks,
    ];
    expect(
      rows.expand((row) => catalogRelativeSeatFindingsV1(row.task)),
      isEmpty,
    );
    expect(rows.expand((row) => catalogWorldCodeFindingsV1(row.task)), isEmpty);
  });

  test('G1 rejects non-adjacent raise and out-of-order check claims', () {
    for (final (id, source, display) in [
      (
        'hand_rankings_find_the_match',
        'BTN raises to 2.75 BB',
        'The player before you raises to 2.75 BB',
      ),
      (
        'hand_rankings_compare_ace_straights',
        'CO raises to 2.75 BB',
        'The player before you raises to 2.75 BB',
      ),
      (
        'hand_rankings_compare_ace_straights',
        'CO checks',
        'The player before you checks',
      ),
    ]) {
      final row = _catalogRow(id);
      final runner = row.task.runner;
      expect(
        runner.table.actionTrail.any((item) => item.label == source),
        isTrue,
      );
      final task = _withRunner(
        row,
        runner.copyWith(
          table: runner.table.copyWith(
            handContributions: runner.table.handContributions,
            actionTrail: [
              for (final item in runner.table.actionTrail)
                if (item.label == source)
                  Act0ActionTrailItemV1(label: source, displayLabel: display)
                else
                  item,
            ],
          ),
        ),
      ).task;
      expect(
        catalogRelativeSeatFindingsV1(task),
        isNotEmpty,
        reason: '$id: $source',
      );
    }
  });

  test('G1 checks intervening action even when the seats are adjacent', () {
    final row = _catalogRow('first_table_guide_first_decision');
    final runner = row.task.runner;
    expect(catalogRelativeSeatFindingsV1(row.task), isEmpty);
    final task = _withRunner(
      row,
      runner.copyWith(
        table: runner.table.copyWith(
          handContributions: runner.table.handContributions,
          actionTrail: [
            ...runner.table.actionTrail,
            const Act0ActionTrailItemV1(label: 'BTN folds'),
          ],
        ),
      ),
    ).task;
    expect(catalogRelativeSeatFindingsV1(task), isNotEmpty);
  });

  test('G1 rejects internal world codes in learner copy', () {
    final row = _catalogRow('w12_river_price_call');
    final mutated = _withRunner(
      row,
      row.task.runner.copyWith(
        caption: 'Recall the outs from W5.',
        teachingSteps: const [
          Act0TeachingStepV1(
            title: 'River price',
            body: 'Use W4’s call price.',
          ),
        ],
        question: 'What did W12 ask?',
        feedbackReason: 'We covered the call in W4.',
      ),
    ).task;
    expect(catalogWorldCodeFindingsV1(mutated), hasLength(5));
  });

  test('W1–W12 catalog snapshot', () {
    final fixture = File(_snapshotPath);
    final current = renderCatalogSnapshot(
      excludePilot: act0CurriculumPilotEnabledV1,
    );
    expect(catalogTasks.map((row) => row.world.worldNumber).toSet(), {
      for (var world = 1; world <= act0LastCurriculumWorldV1; world++) world,
    });
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

  test('W13–W14 pilot catalog snapshot', () {
    final fixture = File('test/fixtures/act0_catalog_snapshot_w13_w14_v1.txt');
    final current = renderCatalogSnapshot(worlds: {13, 14});
    if (Platform.environment['G1_UPDATE_SNAPSHOT'] == '1') {
      fixture.writeAsStringSync(current);
      return;
    }
    expect(current, fixture.readAsStringSync());
  }, skip: !act0CurriculumPilotEnabledV1);

  test('W15–W16 pilot catalog snapshot', () {
    final fixture = File('test/fixtures/act0_catalog_snapshot_w15_w16_v1.txt');
    final current = renderCatalogSnapshot(worlds: {15, 16});
    if (Platform.environment['G1_UPDATE_SNAPSHOT'] == '1') {
      fixture.writeAsStringSync(current);
      return;
    }
    expect(current, fixture.readAsStringSync());
  }, skip: !act0CurriculumPilotEnabledV1);

  test('W17–W18 pilot catalog snapshot', () {
    final fixture = File('test/fixtures/act0_catalog_snapshot_w17_w18_v1.txt');
    final current = renderCatalogSnapshot(worlds: {17, 18});
    if (Platform.environment['G1_UPDATE_SNAPSHOT'] == '1') {
      fixture.writeAsStringSync(current);
      return;
    }
    expect(current, fixture.readAsStringSync());
  }, skip: !act0CurriculumPilotEnabledV1);

  test('W19–W20 pilot catalog snapshot', () {
    final fixture = File('test/fixtures/act0_catalog_snapshot_w19_w20_v1.txt');
    final current = renderCatalogSnapshot(worlds: {19, 20});
    if (Platform.environment['G1_UPDATE_SNAPSHOT'] == '1') {
      fixture.writeAsStringSync(current);
      return;
    }
    expect(current, fixture.readAsStringSync());
  }, skip: !act0CurriculumPilotEnabledV1);

  test('W21–W22 pilot catalog snapshot', () {
    final fixture = File('test/fixtures/act0_catalog_snapshot_w21_w22_v1.txt');
    final current = renderCatalogSnapshot(worlds: {21, 22});
    if (Platform.environment['G1_UPDATE_SNAPSHOT'] == '1') {
      fixture.writeAsStringSync(current);
      return;
    }
    expect(current, fixture.readAsStringSync());
  }, skip: !act0CurriculumPilotEnabledV1);

  test('W23–W24 pilot catalog snapshot', () {
    final fixture = File('test/fixtures/act0_catalog_snapshot_w23_w24_v1.txt');
    final current = renderCatalogSnapshot(worlds: {23, 24});
    if (Platform.environment['G1_UPDATE_SNAPSHOT'] == '1') {
      fixture.writeAsStringSync(current);
      return;
    }
    expect(current, fixture.readAsStringSync());
  }, skip: !act0CurriculumPilotEnabledV1);

  test(
    'W3 blind lesson charges the amount still due and checks its decisions',
    () {
      const frames = <String, (String, double, String)>{
        'w3_play_from_blinds_small_blind_fold': ('sb', 2, 'fold'),
        'w3_play_from_blinds_small_blind_raise': ('sb', 2, 'raise'),
        'w3_play_from_blinds_small_blind_medium_raise': ('sb', 2, 'raise'),
        'w3_play_from_blinds_small_blind_medium_fold': ('sb', 2, 'fold'),
        'w3_play_from_blinds_big_blind_price': ('bb', 1.5, 'one_five'),
        'w3_play_from_blinds_big_blind_defend': ('bb', 1.5, 'call'),
        'w3_play_from_blinds_bvb_sb_open': ('sb', .5, 'raise'),
        'w3_play_from_blinds_bvb_bb_call': ('bb', 2, 'call'),
        'w3_play_from_blinds_bvb_bb_repeat': ('bb', 2, 'fold'),
      };
      for (final MapEntry(key: id, value: (seat, price, correct))
          in frames.entries) {
        final runner = _catalogRow(id).task.runner;
        final table = runner.table;
        expect(table.heroSeatId, seat, reason: id);
        expect(table.decisionSeatId, seat, reason: id);
        final amounts = table.handContributions!.amounts(
          actorSeatId: seat,
          seatIds: table.seats.map((s) => s.seatId).toSet(),
        );
        expect(
          amounts.potBb,
          id.endsWith('_bvb_sb_open') ? 1.5 : 4,
          reason: id,
        );
        expect(amounts.toCallBb, price, reason: id);
        expect(
          runner.options.singleWhere(act0RunnerOptionIsAuthoredCorrectV1).id,
          correct,
          reason: id,
        );
      }
    },
  );

  test('G1 Day 7 covers every pre-beta review family and lesson', () {
    final missing = act0Day7MissSourcesV1.keys.toSet().difference(
      act0Day7CoverageV1,
    );
    expect(missing.where(day7MustBeCoveredV1), isEmpty);
    // These two existing review IDs still resolve for pre-split due items.
    // Newly authored families must have a current course or Rules check source.
    expect(
      act0Day7CoverageV1.difference(act0Day7MissSourcesV1.keys.toSet()),
      const {
        ('world_1', 'what_poker_is', 'hero_cards_board_pot'),
        ('world_1', 'what_poker_is', 'pot_to_call'),
      },
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
    const bankrollExceptionId =
        'w11_day7_bankroll'; // Bankroll is not a hand decision.

    final courseIds = [
      ...catalogTasks,
      ...rulesCheckCatalogTasks,
    ].map((row) => row.task.taskId).toSet();
    final courseHands = [...catalogTasks, ...rulesCheckCatalogTasks]
        .map((row) => row.task.runner.table)
        .where((table) => table.seats.isNotEmpty)
        .map(day7HandKeyV1)
        .toSet();
    for (final row in day7CatalogTasks) {
      final task = row.task;
      final runner = task.runner;
      final table = runner.table;
      final id = task.taskId;
      expect(seen.add(id), isTrue, reason: id);
      expect(courseIds.contains(id), isFalse, reason: id);

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
      if (id == bankrollExceptionId) {
        expect(row.world.worldId, 'world_11');
        expect(row.lesson.lessonId, 'session_plan_bankroll_followup');
        expect(table.scope, Act0TableScopeV1.explanation);
        expect(table.heroCards, isEmpty);
        expect(table.boardCards, isEmpty);
        expect(table.actionTrail, isEmpty);
        expect(table.handContributions, isNull);
        continue;
      }
      expect(courseHands.contains(day7HandKeyV1(table)), isFalse, reason: id);
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
    expect(seen, contains(bankrollExceptionId));
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

  group('G1 chip label falsifiers', () {
    const entries = [
      Act0ContributionV1(
        PokerStreet.preflop,
        'sb',
        Act0ContributionKindV1.blind,
        0.5,
      ),
      Act0ContributionV1(
        PokerStreet.preflop,
        'bb',
        Act0ContributionKindV1.blind,
        1,
      ),
      Act0ContributionV1(
        PokerStreet.preflop,
        'co',
        Act0ContributionKindV1.wager,
        3,
      ),
      Act0ContributionV1(
        PokerStreet.preflop,
        'bb',
        Act0ContributionKindV1.wager,
        2,
      ),
      Act0ContributionV1(
        PokerStreet.flop,
        'co',
        Act0ContributionKindV1.wager,
        7,
      ),
    ];
    const ledger = Act0HandContributionsV1(
      throughStreet: PokerStreet.flop,
      startingStackBbBySeat: {'sb': 100, 'bb': 100, 'co': 10},
      entries: entries,
    );

    Act0TableStateV1 frame({
      String bbStack = '97 BB',
      String coBet = '7 BB',
      String raise = 'CO raises to 3 BB',
      String call = 'BB calls 2 BB more',
      String? foldedBet,
      String coStack = '0 BB',
      bool spellAllIn = true,
    }) {
      final template = _catalogRow(
        'what_poker_is_all_in_meaning',
      ).task.runner.table;
      return template.copyWith(
        streetLabel: 'Flop',
        handContributions: ledger,
        seats: [
          Act0SeatStateV1(
            seatId: 'sb',
            seatLabel: 'SB',
            displayName: 'SB',
            stackLabel: '99.5 BB',
            isFolded: true,
            isInHand: false,
            currentBetLabel: foldedBet,
          ),
          Act0SeatStateV1(
            seatId: 'bb',
            seatLabel: 'BB',
            displayName: 'BB',
            stackLabel: bbStack,
          ),
          Act0SeatStateV1(
            seatId: 'co',
            seatLabel: 'CO',
            displayName: 'CO',
            stackLabel: coStack,
            bet: Act0SeatBetStateV1(
              kind: Act0SeatBetKindV1.allIn,
              label: 'All-in',
              amountLabel: coBet,
            ),
          ),
        ],
        actionTrail: [
          const Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
          const Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
          Act0ActionTrailItemV1(label: raise),
          const Act0ActionTrailItemV1(label: 'SB folds'),
          Act0ActionTrailItemV1(label: 'BB calls 3 BB', displayLabel: call),
          Act0ActionTrailItemV1(
            label: spellAllIn ? 'Flop: CO all-in 7 BB' : 'Flop: CO bets 7 BB',
          ),
        ],
      );
    }

    Set<(String, String)> fails(Act0TableStateV1 table) => {
      for (final finding in auditAct0TableChipLabelsV1(
        'fixture',
        'question',
        table,
      ))
        if (finding.passes == false) (finding.rule, finding.anchor),
    };

    test('reconciles a late street with earlier bets and a previous fold', () {
      expect(fails(frame()), isEmpty);
    });
    test('rejects a wrong stack after deducting earlier contributions', () {
      expect(fails(frame(bbStack: '99 BB')), {('22.stack', 'bb')});
    });
    test('rejects a seat chip label with the wrong current contribution', () {
      expect(fails(frame(coBet: '10 BB')), {('22.seat_wager', 'co')});
    });
    test('rejects wrong numeric amounts on both action label channels', () {
      expect(
        fails(frame(raise: 'CO raises to 4 BB', call: 'BB calls 3 BB more')),
        {
          ('22.action_amount', '2/label'),
          ('22.action_amount', '4/displayLabel'),
        },
      );
    });
    test('rejects a chip image on a street after the seat folded', () {
      expect(
        fails(frame(foldedBet: '0.5 BB')),
        contains(('22.folded_wager', 'sb')),
      );
    });
    test('all-in must have a zero stack and an all-in action', () {
      expect(fails(frame(coStack: '1 BB')), contains(('22.all_in', 'co')));
      expect(fails(frame(spellAllIn: false)), {('22.all_in', 'co')});
    });
  });

  test(
    'G1 reconciles table stack, wager and action labels with contributions',
    () {
      final evidence = auditAct0CatalogChipLabelsV1().toList();
      if (Platform.environment['G1_REPORT_DIR'] case final directory?) {
        Directory(directory).createSync(recursive: true);
        File('$directory/chip-labels.json').writeAsStringSync(
          _json.convert([
            for (final row in evidence)
              [
                row.task,
                row.frame,
                row.rule,
                row.anchor,
                row.passes,
                row.detail,
              ],
          ]),
        );
      }
      expect(evidence.where((row) => row.passes == true), isNotEmpty);
      final failed = evidence
          .where((row) => row.passes == false)
          .map(
            (row) =>
                '${row.task}|${row.frame}|${row.rule}|${row.anchor}|${row.detail}',
          );
      expect(failed, isEmpty, reason: failed.join('\n'));
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

  test('G1·11–G1·25 catalog quality baseline admits no regressions', () {
    final report = runCatalogQualityAudit();
    final duplicateLabels = report.findings.where(
      (key) => key.startsWith('$catalogDuplicateOptionLabelRuleV1|'),
    );
    expect(duplicateLabels, isEmpty, reason: 'G1·45 duplicate option labels');
    expect(
      report.findings.where(
        (key) => key.startsWith('$catalogActionQuestionRuleV1|'),
      ),
      isEmpty,
      reason:
          'G1·46 the named actions must be available and include the answer',
    );
    expect(
      report.findings.where(
        (key) => key.startsWith('$catalogBankrollThresholdRuleV1|'),
      ),
      isEmpty,
      reason: 'G1·48 cash bankroll thresholds must use the course rule',
    );
    expect(
      report.findings.where(
        (key) => key.startsWith('$catalogSharedFeedbackBodyRuleV1|'),
      ),
      isEmpty,
      reason: 'G1·49 scored options need distinct feedback bodies',
    );
    final baselineFile = File(_qualityBaselinePath);
    if (Platform.environment['G1_UPDATE_QUALITY_BASELINE'] == '1') {
      final existing = baselineFile.existsSync()
          ? jsonDecode(baselineFile.readAsStringSync()) as Map<String, dynamic>
          : <String, dynamic>{};
      baselineFile.createSync(recursive: true);
      baselineFile.writeAsStringSync(
        '${_json.convert({...existing, ...report.toBaselineJson()})}\n',
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

  test('G1·47 correct feedback stays within the word limit', () {
    final report = runCatalogQualityAudit();
    final baseline =
        jsonDecode(File(_qualityBaselinePath).readAsStringSync())
            as Map<String, dynamic>;
    final limits =
        (baseline['correct_feedback_word_limits_v1'] as Map<String, dynamic>? ??
                const {})
            .cast<String, int>();
    expect(
      report.correctFeedbackOverLimit,
      limits,
      reason:
          'Only the individual word counts locked in the fixture may exceed '
          '$catalogCorrectFeedbackWordLimitV1 words. Ratchet down any shorter copy.',
    );
  });

  test('G1·26–G1·37 reasoning baseline admits no regressions', () {
    final file = File(_qualityBaselinePath);
    final baseline =
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final current = catalogReasoningBaselineV1();
    if (Platform.environment['G1_UPDATE_REASONING_BASELINE'] == '1') {
      baseline['reasoning_v1'] = current;
      file.writeAsStringSync('${_json.convert(baseline)}\n');
      return;
    }
    final expected = baseline['reasoning_v1'] as Map<String, dynamic>;
    final currentWorlds =
        current['findings_by_world'] as Map<String, Map<String, List<String>>>;
    final expectedWorlds =
        expected['findings_by_world'] as Map<String, dynamic>;
    for (final world in {...currentWorlds.keys, ...expectedWorlds.keys}) {
      final old = expectedWorlds[world] as Map<String, dynamic>? ?? {};
      final now = currentWorlds[world] ?? {};
      for (final rule in {...old.keys, ...now.keys}) {
        final previous = (old[rule] as List<dynamic>? ?? [])
            .cast<String>()
            .toSet();
        final findings = (now[rule] ?? []).toSet();
        expect(
          findings.difference(previous),
          isEmpty,
          reason: 'New G1·$rule findings in $world',
        );
        expect(
          previous.difference(findings),
          isEmpty,
          reason: 'Ratchet down G1·$rule baseline for $world',
        );
      }
    }
    expect(current['short_stacks_by_world'], expected['short_stacks_by_world']);
    expect(
      current['stack_matters_by_world'],
      expected['stack_matters_by_world'],
    );
  });

  group('decision ledger', () {
    test('100 BB against 25 BB has a 25 BB effective stack', () {
      const ledger = Act0HandContributionsV1(
        throughStreet: PokerStreet.preflop,
        startingStackBbBySeat: {'btn': 100, 'bb': 25},
        entries: [
          Act0ContributionV1(
            PokerStreet.preflop,
            'bb',
            Act0ContributionKindV1.blind,
            1,
          ),
        ],
      );
      expect(
        act0EffectiveStacksV1(
          ledger,
          heroSeatId: 'btn',
          activeSeatIds: {'btn', 'bb'},
        ),
        {'bb': 25},
      );
    });

    test(
      'multiway stacks use previous streets and include live street wagers',
      () {
        const ledger = Act0HandContributionsV1(
          throughStreet: PokerStreet.flop,
          startingStackBbBySeat: {'btn': 100, 'sb': 25, 'bb': 50, 'co': 10},
          minimumStartingStackBbBySeat: {'hj': 30},
          entries: [
            Act0ContributionV1(
              PokerStreet.preflop,
              'btn',
              Act0ContributionKindV1.wager,
              2.5,
            ),
            Act0ContributionV1(
              PokerStreet.preflop,
              'sb',
              Act0ContributionKindV1.wager,
              2.5,
            ),
            Act0ContributionV1(
              PokerStreet.preflop,
              'bb',
              Act0ContributionKindV1.wager,
              2.5,
            ),
            Act0ContributionV1(
              PokerStreet.flop,
              'bb',
              Act0ContributionKindV1.wager,
              3,
            ),
          ],
        );
        expect(
          act0EffectiveStacksV1(
            ledger,
            heroSeatId: 'btn',
            activeSeatIds: {'btn', 'sb', 'bb', 'hj'},
          ),
          {'sb': 22.5, 'bb': 47.5},
        );
      },
    );

    test(
      'SB 10 BB and BB 30 BB all-in called by BTN forms 30 and 40 BB pots',
      () {
        const ledger = Act0HandContributionsV1(
          throughStreet: PokerStreet.preflop,
          entries: [
            Act0ContributionV1(
              PokerStreet.preflop,
              'sb',
              Act0ContributionKindV1.wager,
              10,
            ),
            Act0ContributionV1(
              PokerStreet.preflop,
              'bb',
              Act0ContributionKindV1.wager,
              30,
            ),
            Act0ContributionV1(
              PokerStreet.preflop,
              'btn',
              Act0ContributionKindV1.wager,
              30,
            ),
          ],
        );
        final pots = act0PotEligibilityV1(
          ledger,
          activeSeatIds: {'sb', 'bb', 'btn'},
        )!;
        expect(pots.map((pot) => pot.amountBb), [30, 40]);
        expect(pots.first.eligibleSeatIds, {'sb', 'bb', 'btn'});
        expect(pots.last.eligibleSeatIds, {'bb', 'btn'});
        expect(pots.fold(0.0, (total, pot) => total + pot.amountBb), 70);
      },
    );
    test('W8 side-pot drill derives eligibility from the authored table', () {
      final table = _catalogRow('short_stack_spots_side_pot').task.runner.table;
      final source = table.handContributions!;
      final active = {'sb', 'bb', 'btn'};
      final price = source.amounts(
        seatIds: table.seats.map((seat) => seat.seatId).toSet(),
        actorSeatId: 'btn',
      );
      expect(price.potBb, 42.5);
      expect(price.toCallBb, 27.5);
      final matched = Act0HandContributionsV1(
        throughStreet: source.throughStreet,
        startingStackBbBySeat: source.startingStackBbBySeat,
        entries: [
          ...source.entries,
          Act0ContributionV1(
            PokerStreet.preflop,
            'btn',
            Act0ContributionKindV1.wager,
            price.toCallBb!,
          ),
        ],
      );
      final pots = act0PotEligibilityV1(matched, activeSeatIds: active)!;
      expect(pots.map((pot) => pot.amountBb), [30, 40]);
      expect(pots.first.eligibleSeatIds, active);
      expect(pots.last.eligibleSeatIds, {'bb', 'btn'});
    });
  });

  group('G1 reasoning falsifiers', () {
    final row = _catalogRow('w11_trigger_bad_price_fold');
    final runner = row.task.runner;
    final taskId = row.task.taskId;
    final correct = runner.options.firstWhere((option) => option.isCorrect);
    final call = runner.options.firstWhere(
      (option) => option.label.startsWith('Call'),
    );

    Act0DecisionReasoningV1 reasoning({
      String principle = 'price_vs_equity',
      String? alternative,
      String? opponent = 'Big turn bets favor made hands.',
      String? assumption,
      double? edge,
      bool stackMatters = false,
      Map<String, Act0SuboptimalKindV1> suboptimalKinds = const {},
    }) => Act0DecisionReasoningV1(
      taskId: taskId,
      kind: Act0DecisionKindV1.table,
      principleId: principle,
      bestAlternativeOptionId: alternative ?? call.id,
      edgeMechanism: Act0EdgeMechanismV1.equityBelowPrice,
      opponentRead: opponent,
      preChoiceAssumption: assumption,
      edgeBb: edge,
      stackMatters: stackMatters,
      suboptimalKinds: suboptimalKinds,
    );

    CatalogReasoningResultV1 audit(
      Act0DecisionReasoningV1 fields, {
      Map<String, String> copy = const {},
      Map<String, Act0FeedbackQualityV1> grades = const {},
    }) => auditCatalogReasoningV1(
      _withRunner(
        row,
        runner.copyWith(
          options: [
            for (final option in runner.options)
              _withOptionReason(
                option,
                copy[option.id] ??
                    (option.isCorrect
                        ? 'Fold because an 8 BB call costs too much and CO continues with strong hands.'
                        : 'Fold to save chips.'),
                quality: grades[option.id],
              ),
          ],
        ),
      ),
      reasoning: {taskId: fields},
    )!;

    test('26 rejects a missing or later principle', () {
      expect(
        auditCatalogReasoningV1(row, reasoning: const {})!.findings,
        contains(26),
      );
      expect(
        audit(reasoning(principle: 'process_over_outcome')).findings,
        contains(26),
      );
      expect(audit(reasoning()).findings, isNot(contains(26)));
    });
    test('27 rejects another task ID or the correct option', () {
      expect(
        audit(reasoning(alternative: 'no_such_option')).findings,
        contains(27),
      );
      expect(audit(reasoning(alternative: correct.id)).findings, contains(27));
      expect(audit(reasoning()).findings, isNot(contains(27)));
    });
    test('28 needs a real table fact and a causal link', () {
      expect(
        audit(
          reasoning(),
          copy: {correct.id: 'Fold because 999 BB is too expensive.'},
        ).findings,
        contains(28),
      );
      expect(
        audit(
          reasoning(),
          copy: {correct.id: 'Fold. The call costs 8 BB.'},
        ).findings,
        contains(28),
      );
      expect(audit(reasoning()).findings, isNot(contains(28)));
    });
    test('29 needs the alternative action in feedback', () {
      expect(
        audit(
          reasoning(),
          copy: {correct.id: 'Fold because CO continues with strong hands.'},
        ).findings,
        contains(29),
      );
      expect(audit(reasoning()).findings, isNot(contains(29)));
    });
    test('30 requires opponent read and response when facing a wager', () {
      expect(audit(reasoning(opponent: null)).findings, contains(30));
      expect(
        audit(
          reasoning(),
          copy: {correct.id: 'Fold because an 8 BB call costs too much.'},
        ).findings,
        contains(30),
      );
      expect(audit(reasoning()).findings, isNot(contains(30)));
    });
    test('31 rejects wrong feedback without a better action or cost', () {
      expect(
        audit(reasoning(), copy: {call.id: 'Look again.'}).findings[31],
        contains(call.id),
      );
      expect(audit(reasoning()).findings, isNot(contains(31)));
    });
    test('32 requires the claimed assumption before choosing', () {
      expect(
        audit(reasoning(assumption: 'CO always folds to a minraise.')).findings,
        contains(32),
      );
      expect(
        audit(
          reasoning(assumption: 'KQ wins 15% against this betting range'),
        ).findings,
        isNot(contains(32)),
      );
    });
    test('33 rejects a wrong alternative with zero edge', () {
      expect(audit(reasoning(edge: 0)).findings[33], contains(call.id));
      expect(audit(reasoning(edge: 0.1)).findings, isNot(contains(33)));
    });
    test('34 distinguishes concealed cards from disclosed hand groups', () {
      expect(
        audit(
          reasoning(),
          copy: {call.id: 'CO has AdQh, so fold.'},
        ).findings[34],
        contains(call.id),
      );
      expect(
        audit(
          reasoning(),
          copy: {call.id: 'CO has A-Q, so fold.'},
        ).findings[34],
        contains(call.id),
      );
      expect(
        audit(
          reasoning(),
          copy: {call.id: 'CO can have A-Q or sets, so fold.'},
        ).findings,
        isNot(contains(34)),
      );
    });
    test('35 counts a short decision only with stackMatters true', () {
      expect(audit(reasoning()).eligibleShortStack, isTrue);
      expect(audit(reasoning()).stackMatters, isFalse);
      expect(audit(reasoning(stackMatters: true)).stackMatters, isTrue);
    });

    test('36 requires a meaning for each suboptimal option', () {
      const grade = Act0FeedbackQualityV1.suboptimal;
      expect(
        audit(reasoning(), grades: {call.id: grade}).findings[36],
        contains(call.id),
      );
      expect(
        audit(
          reasoning(
            suboptimalKinds: {call.id: Act0SuboptimalKindV1.clearlyWorse},
          ),
          grades: {call.id: grade},
        ).findings,
        isNot(contains(36)),
      );
    });
    test('37 acceptable explains that it works and names the best action', () {
      final grades = {call.id: Act0FeedbackQualityV1.acceptable};
      expect(
        audit(
          reasoning(),
          grades: grades,
          copy: {call.id: 'Also playable. You save chips.'},
        ).findings[37],
        contains(call.id),
      );
      expect(
        audit(
          reasoning(),
          grades: grades,
          copy: {call.id: 'Fold is a bit better.'},
        ).findings[37],
        contains(call.id),
      );
      expect(
        audit(
          reasoning(),
          grades: grades,
          copy: {call.id: 'Also works. Fold is a bit better.'},
        ).findings,
        isNot(contains(37)),
      );
    });
    test('37 each co-correct option names the other action', () {
      final grades = {
        correct.id: Act0FeedbackQualityV1.coCorrect,
        call.id: Act0FeedbackQualityV1.coCorrect,
      };
      final copy = {
        correct.id: 'Calling also works at this price.',
        call.id: 'Both work here.',
      };
      expect(
        audit(reasoning(edge: 0), grades: grades, copy: copy).findings[37],
        {call.id},
      );
      copy[call.id] = 'Folding also works here.';
      expect(
        audit(reasoning(edge: 0), grades: grades, copy: copy).findings,
        isNot(contains(37)),
      );
    });
  });

  test('G1·29 distinguishes the size when both choices bet', () {
    final row = _catalogRow('w4_protection_small_denial');
    final options = row.task.runner.options;
    final correct = options.firstWhere((option) => option.isCorrect);
    final alternative = options.firstWhere(
      (option) => option.label == 'Bet 4 BB',
    );
    final reasoning = {
      row.task.taskId: Act0DecisionReasoningV1(
        taskId: row.task.taskId,
        kind: Act0DecisionKindV1.table,
        principleId: 'smallest_size_same_job',
        bestAlternativeOptionId: alternative.id,
        edgeMechanism: Act0EdgeMechanismV1.cheaperSameResult,
      ),
    };
    bool flags(String text) => auditCatalogReasoningV1(
      _withDecisionCopy(row, {correct.id: text}),
      reasoning: reasoning,
    )!.findings.containsKey(29);

    expect(flags('Bet 2 BB here.'), isTrue);
    expect(flags('Bet 2 BB instead of 4 BB.'), isFalse);
  });

  test('G1·39–40 decision copy agrees with position and sizing', () {
    final findings = reasoningCatalogRowsV1.expand(auditDecisionCopyV1);
    expect(findings, isEmpty);
  });

  test('G1·39–40 catches the W3 hero mismatches, not chart references', () {
    final ato = _catalogRow('same_hand_different_seat_same_hand_late_open');
    final kto = _catalogRow('position_apply_late_open');
    final findings = [
      ...auditDecisionCopyV1(
        _withDecisionCopy(ato, {
          'call': 'A 1 BB limp from CO gives up raise pressure.',
          'fold':
              'Folding from CO gives up the blinds with only BTN, SB and BB left to act.',
        }),
      ),
      ...auditDecisionCopyV1(
        _withDecisionCopy(kto, {
          'call':
              'Calling 1 BB from CO gives up the pressure of a 2.5 BB open.',
          'fold':
              'Folding this hand first in from CO gives up the chart open with three players left to act.',
        }),
      ),
    ];
    expect(findings.map((f) => (f.rule, f.taskId, f.optionId)).toSet(), {
      (39, ato.task.taskId, 'call'),
      (39, ato.task.taskId, 'fold'),
      (39, kto.task.taskId, 'call'),
      (39, kto.task.taskId, 'fold'),
      (40, kto.task.taskId, 'call'),
    });
    expect(
      auditDecisionCopyV1(
        _withDecisionCopy(kto, {
          'call': 'Calling 1 BB from BTN gives up the pressure of a 3 BB open.',
          'fold':
              'The chart opens ATo from HJ. UTG has five players behind. Folding from BTN with two players left to act gives up the blinds.',
        }),
      ),
      isEmpty,
    );
    expect(
      auditDecisionCopyV1(
        _withDecisionCopy(kto, {
          'call': 'Calling from BTN keeps three players left to act.',
          'fold': 'Fold from BTN.',
        }),
      ).single.rule,
      39,
    );
  });

  test('G1·44 checks opening-range comparisons against the starting chart', () {
    final claims = reasoningCatalogRowsV1.expand(openingRangeClaimsV1);
    expect(claims, isNotEmpty);
    expect(reasoningCatalogRowsV1.expand(auditOpeningRangeClaimsV1), isEmpty);

    final kqo = _catalogRow('weak_ace_warning_w3_strong_continue');
    final tt = _catalogRow('w2_narrow_three_bet_strong');
    for (final (row, copy) in [
      (kqo, 'HJ can raise weaker unpaired hands.'),
      (kqo, 'HJ can open weaker kings such as KJs and KTs.'),
      (kqo, 'CO can open weaker suited hands such as KJs and K9s.'),
      (tt, 'HJ can raise lower pairs and unpaired hands.'),
      (tt, 'HJ can raise with lower pocket pairs like 99.'),
    ]) {
      final result = auditOpeningRangeClaimsV1(
        _withDecisionCopy(row, {'call': copy}),
      ).single;
      expect(result.rule, 'G1·44');
      expect(result.id, row.task.taskId);
      expect(result.detail, contains('call:'));
    }
    for (final (row, copy) in [
      (kqo, 'CO can open weaker suited hands such as KJs and KTs.'),
      (tt, 'CO can open lower pairs.'),
      (tt, 'HJ can open AQ, AJ and KQ along with TT and higher pairs.'),
    ]) {
      expect(
        auditOpeningRangeClaimsV1(_withDecisionCopy(row, {'call': copy})),
        isEmpty,
        reason: copy,
      );
    }
  });

  test('G1·39 checks that the hero turn names the same seat as the table', () {
    final late = _catalogRow('early_vs_late_late_info_choice');
    final runner = late.task.runner;
    expect(runner.table.heroSeat.seatId, 'co');
    expect(runner.table.activeSeatId, 'co');
    final buttonTable = _catalogRow(
      'position_apply_late_open',
    ).task.runner.table;
    final wrongSeat = _withRunner(
      late,
      runner.copyWith(
        table: buttonTable.copyWith(
          activeSeatId: 'co',
          actionTrail: runner.table.actionTrail,
        ),
      ),
    );
    final finding = auditDecisionCopyV1(wrongSeat).single;
    expect(finding.rule, 39);
    expect(finding.optionId, 'table');
    expect(finding.quote, 'Seat BTN · Active CO');

    final observer = _catalogRow('w4_checkpoint_table_purpose_price');
    expect(observer.task.runner.table.activeSeatId, 'bb');
    expect(auditDecisionCopyV1(observer), isEmpty);
  });

  test('G1·39 catches an inherited UTG explanation in a CO seat read', () {
    final row = _catalogRow(
      'position_checkpoint_position_checkpoint_table_notice',
    );
    final copied = _withDecisionCopy(row, {
      'acts_last': 'UTG is first and has five players left to act.',
      'late_free_pass':
          'The first-in raise still faces the players behind UTG.',
    });
    expect(
      auditDecisionCopyV1(copied).map((f) => (f.rule, f.optionId)).toSet(),
      {(39, 'acts_last'), (39, 'late_free_pass')},
    );
    expect(
      auditDecisionCopyV1(
        _withDecisionCopy(row, {'acts_last': 'Five players left.'}),
      ).single.rule,
      39,
    );
    expect(
      auditDecisionCopyV1(
        _withRunner(
          copied,
          copied.task.runner.copyWith(question: 'Where does UTG act?'),
        ),
      ),
      isEmpty,
    );
    expect(auditDecisionCopyV1(row), isEmpty);
  });

  group('G1 decision copy numbers', () {
    final row = _catalogRow('w11_trigger_bad_price_fold');
    final runner = row.task.runner;

    Set<String> numericFindings(Act0RunnerStateV1 candidate) =>
        runCatalogQualityAudit(rows: [_withRunner(row, candidate)]).findings
            .where((finding) => RegExp(r'^2[2-5]\.').hasMatch(finding))
            .toSet();

    test('accepts correct copy even if the display strings disagree', () {
      expect(
        numericFindings(
          runner.copyWith(
            table: runner.table.copyWith(
              potLabel: 'Pot 99 BB',
              toCallLabel: 'To call 9 BB',
            ),
            hint: 'Need 31% to call. CO bet 8 into 10.',
          ),
        ),
        isEmpty,
      );
    });

    test('rejects the after-bet pot in bet-into phrasing', () {
      expect(
        numericFindings(runner.copyWith(caption: 'CO bets 8 BB into 18 BB.')),
        contains(
          '22.bet_into_pot|world_11|w11_trigger_bad_price_fold|caption|'
          'bets 8 BB into 18|before bet expected 10.0',
        ),
      );
    });

    test('uses the street ledger with the collected pot carried forward', () {
      final partial = _catalogRow('w12_revenge_raise_trap');
      final runner = partial.task.runner.copyWith(
        caption: 'CO bet 2 into 8.',
        hint: 'You need about 17% equity.',
        options: const [],
        feedbackReason: 'CO’s bet brings the pot to 10 BB.',
      );
      final report = runCatalogQualityAudit(
        rows: [_withRunner(partial, runner)],
      );
      expect(
        report.findings.where(
          (finding) => RegExp(r'^2[2-5]\.').hasMatch(finding),
        ),
        isEmpty,
      );
      expect(report.checks['22.bet_into_pot'], 2);
      expect(report.checks['23.pot_with_bet'], 1);
      expect(report.checks['24.call_equity'], 1);
    });

    test('rejects the before-bet pot in pot-now phrasing', () {
      expect(
        numericFindings(
          runner.copyWith(feedbackReason: 'The pot is now 10 BB.'),
        ),
        contains(
          '23.pot_with_bet|world_11|w11_trigger_bad_price_fold|feedbackReason|'
          'pot is now 10 BB|expected 18.0',
        ),
      );
    });

    test('rejects an equity threshold calculated with the before-bet pot', () {
      expect(
        numericFindings(runner.copyWith(hint: 'You need about 50% equity.')),
        contains(startsWith('24.call_equity|world_11|')),
      );
    });

    test(
      'uses the smaller stack before the facing wager for effective depth',
      () {
        expect(
          numericFindings(
            runner.copyWith(hint: 'Use the 32.5 BB effective stack.'),
          ),
          isEmpty,
        );
        expect(
          numericFindings(
            runner.copyWith(hint: 'Use the 21 BB effective stack.'),
          ),
          contains(startsWith('25.street_stack|world_11|')),
        );
      },
    );

    test('rejects a previous-street stack in the theory for this decision', () {
      expect(
        numericFindings(
          runner.copyWith(
            teachingSteps: const [
              Act0TeachingStepV1(
                title: 'Read your stack',
                body: 'You have 34.5 BB behind.',
              ),
            ],
          ),
        ),
        contains(
          '25.street_stack|world_11|w11_trigger_bad_price_fold|theory[0].body|'
          '34.5 BB behind|expected 32.5',
        ),
      );
    });
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
    test('rejects a Day 7 reason reused from course or in the same review', () {
      final base = _catalogRow('hand_discipline_buckets_premium');
      const wrongReason =
          'A loose call here pays a raise with a dominated hand.';
      Act0RunnerOptionV1 choice(String id, bool correct, String reason) =>
          Act0RunnerOptionV1(
            id: id,
            label: id,
            isCorrect: correct,
            preferredLabel: 'fold',
            quality: correct
                ? Act0FeedbackQualityV1.correct
                : Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Read the table.',
            feedbackReason: reason,
          );
      CatalogTask row(String id, String right, String wrong) => syntheticRow(
        base,
        id: id,
        runner: base.task.runner.copyWith(
          options: [choice('fold', true, right), choice('call', false, wrong)],
        ),
      );
      final findings = <String>{};
      auditDuplicateWrongReasonsV1(
        course: [row('course', 'Fold to the tighter opener.', wrongReason)],
        day7: [
          row('reused', 'Folding preserves the stack.', wrongReason),
          row('binary', 'Recheck your price.', '  Recheck your price. '),
          row('distinct', 'Keep your stack.', 'The deeper stack calls behind.'),
        ],
        count: (_) {},
        findings: findings,
      );
      expect(findings, {
        '21.duplicate_wrong_reason|reused|call',
        '21.duplicate_wrong_reason|binary|call',
      });
    });

    test('G1·45 rejects the old duplicate Day 7 percentage label', () {
      final base = day7CatalogTasks.firstWhere(
        (row) =>
            row.task.taskId ==
            'spaced_review_w9_survival_pressure_basics_pot_to_call_v1',
      );
      final options = [...base.task.runner.options];
      options[0] = const Act0RunnerOptionV1(
        id: 'different_id',
        label: '65.3%',
        isCorrect: false,
        preferredLabel: '39.5%',
        quality: Act0FeedbackQualityV1.wrong,
        feedbackTitle: 'Look again.',
        feedbackReason: 'Count the whole final pot, including the call.',
      );
      final duplicate = _withRunner(
        base,
        base.task.runner.copyWith(options: options),
      );
      Iterable<String> labelFindings(CatalogTask row) =>
          runCatalogQualityAudit(rows: [row]).findings.where(
            (key) => key.startsWith('$catalogDuplicateOptionLabelRuleV1|'),
          );
      expect(labelFindings(base), isEmpty);
      expect(labelFindings(duplicate), [
        '$catalogDuplicateOptionLabelRuleV1|${base.task.taskId}|65.3%',
      ]);
    });

    test('G1·21 checks each Day 7 option in a scoped catalog audit', () {
      final base = day7CatalogTasks.firstWhere(
        (row) =>
            row.task.taskId == 'spaced_review_w4_value_bets_board_cards_v1',
      );
      final options = base.task.runner.options;
      const sharedReason = 'Bet 3 BB to get paid by a weaker king.';
      Act0RunnerOptionV1 withReason(
        Act0RunnerOptionV1 option,
        String reason, {
        String? id,
      }) => Act0RunnerOptionV1(
        id: id ?? option.id,
        label: option.label,
        isCorrect: option.isCorrect,
        preferredLabel: option.preferredLabel,
        quality: option.quality,
        feedbackTitle: option.feedbackTitle,
        feedbackReason: reason,
      );
      Iterable<String> reasonFindings(List<Act0RunnerOptionV1> choices) =>
          runCatalogQualityAudit(
            rows: [
              _withRunner(base, base.task.runner.copyWith(options: choices)),
            ],
          ).findings.where((key) => key.startsWith('21.'));

      expect(reasonFindings(options), isEmpty);
      expect(
        reasonFindings([
          for (final option in options) withReason(option, sharedReason),
        ]),
        unorderedEquals([
          '21.duplicate_wrong_reason|${base.task.taskId}|choice_1',
          '21.duplicate_wrong_reason|${base.task.taskId}|fold',
        ]),
      );
      expect(
        reasonFindings([
          options[0],
          withReason(options[1], sharedReason),
          withReason(options[2], sharedReason, id: options[1].id),
        ]),
        ['21.duplicate_wrong_reason|${base.task.taskId}|choice_1'],
      );
    });

    test('G1·50 rejects a decision-loss explanation for naming a seat', () {
      final row = day7CatalogTasks.singleWhere(
        (row) =>
            row.task.taskId == 'spaced_review_w3_position_six_seats_seat_v1',
      );
      final runner = row.task.runner;
      final co = runner.options.singleWhere((option) => option.label == 'CO');
      final altered = Act0RunnerOptionV1(
        id: co.id,
        label: co.label,
        isCorrect: co.isCorrect,
        preferredLabel: co.preferredLabel,
        quality: co.quality,
        feedbackTitle: co.feedbackTitle,
        feedbackReason:
            'CO follows HJ. Choosing CO gives up the information CO gets from seeing HJ act first.',
      );
      Iterable<String> findingsFor(CatalogTask task) =>
          runCatalogQualityAudit(rows: [task]).findings.where(
            (key) => key.startsWith('$catalogSeatRecognitionFeedbackRuleV1|'),
          );
      expect(catalogIsSeatRecognitionV1(row.task), isTrue);
      expect(findingsFor(row), isEmpty);
      final choices = [
        for (final option in runner.options)
          option.id == co.id ? altered : option,
      ];
      expect(findingsFor(_withRunner(row, runner.copyWith(options: choices))), [
        '$catalogSeatRecognitionFeedbackRuleV1|${row.task.taskId}|${co.id}',
      ]);
      final action = _withRunner(
        row,
        runner.copyWith(question: 'Call or fold from CO?', options: choices),
      );
      expect(findingsFor(action), isEmpty);
    });

    test('G1·49 rejects a shared body despite different verdict titles', () {
      final row = day7CatalogTasks.singleWhere(
        (row) =>
            row.task.taskId ==
            'spaced_review_w5_outs_improvement_hero_cards_board_pot_v1',
      );
      final runner = row.task.runner;
      final shared = runner.options.first.feedbackReason;
      final altered = _withRunner(
        row,
        runner.copyWith(
          options: [
            for (final option in runner.options)
              Act0RunnerOptionV1(
                id: option.id,
                label: option.label,
                isCorrect: option.isCorrect,
                preferredLabel: option.preferredLabel,
                quality: option.quality,
                feedbackTitle: option.feedbackTitle,
                feedbackReason: option.isCorrect ? shared : '  $shared  ',
              ),
          ],
        ),
      );
      Iterable<String> findingsFor(CatalogTask task) =>
          runCatalogQualityAudit(rows: [task]).findings.where(
            (key) => key.startsWith('$catalogSharedFeedbackBodyRuleV1|'),
          );
      expect(findingsFor(row), isEmpty);
      expect(findingsFor(altered), [
        '$catalogSharedFeedbackBodyRuleV1|${row.task.taskId}',
      ]);
      expect(
        findingsFor(
          rulesCheckCatalogTasks.singleWhere(
            (row) => row.task.taskId == 'w1_rules_check_forced_bets',
          ),
        ),
        isEmpty,
      );
    });

    test('G1·46 rejects Bet or check when Day 7 only offers bets', () {
      final row = day7CatalogTasks.firstWhere(
        (row) =>
            row.task.taskId ==
            'spaced_review_w10_adjust_one_lever_board_cards_v1',
      );
      Iterable<String> findingsFor(CatalogTask task) =>
          runCatalogQualityAudit(rows: [task]).findings.where(
            (key) => key.startsWith('$catalogActionQuestionRuleV1|'),
          );
      expect(findingsFor(row), isEmpty);
      expect(
        findingsFor(
          _withRunner(row, row.task.runner.copyWith(question: 'Bet or check?')),
        ),
        ['$catalogActionQuestionRuleV1|${row.task.taskId}|missing check'],
      );
    });

    test('G1·48 rejects the old NL10 thresholds and checks other copy', () {
      final row = _catalogRow('w11_y5d_stay_at_nl10');
      Iterable<String> findingsFor(Act0RunnerStateV1 runner) =>
          runCatalogQualityAudit(
            rows: [_withRunner(row, runner)],
          ).findings.where(
            (key) => key.startsWith('$catalogBankrollThresholdRuleV1|'),
          );
      final runner = row.task.runner;
      final prefix = '$catalogBankrollThresholdRuleV1|${row.task.taskId}';
      expect(findingsFor(runner), isEmpty);
      expect(
        findingsFor(
          runner.copyWith(
            caption:
                r'Your bankroll is $475. A buy-in costs $10 at NL10 and $25 at NL25. '
                'Move up at 30 buy-ins for the next stake. Move down below 20 at the current stake.',
            hint: 'The thirty-buy-in floor applies to cash games.',
          ),
        ),
        unorderedEquals([
          '$prefix|caption|30',
          '$prefix|caption|20',
          '$prefix|hint|30',
        ]),
      );
      expect(
        findingsFor(
          runner.copyWith(
            hint:
                'You have 19 buy-ins at NL25, 21 buy-ins short of the buffer.',
          ),
        ),
        isEmpty,
      );
    });

    List<String> bankrollSpecFindings(Object? document) {
      if (document is! Map || document['tasks'] is! List) {
        throw const FormatException('Expected a spec document with tasks.');
      }
      Iterable<(String, String)> textFields(
        Object? node,
        String surface,
      ) sync* {
        if (node is String) {
          yield (surface, node);
        } else if (node is Map) {
          for (final entry in node.entries) {
            yield* textFields(entry.value, '$surface.${entry.key}');
          }
        } else if (node is List) {
          for (final (index, value) in node.indexed) {
            yield* textFields(value, '$surface[$index]');
          }
        }
      }

      return [
        for (final task in document['tasks'] as List)
          for (final threshold in bankrollThresholdsInCopyV1(
            copy: textFields(task, task['id'] as String),
            preChoice: [
              for (final field in ['caption', 'question', 'teach'])
                if (task[field] case final String text) text,
            ],
          ))
            if (!threshold.isPersonal &&
                threshold.buyIns != act0CashBankrollBuyInsV1)
              '${threshold.surface}: ${threshold.buyIns} buy-ins',
      ];
    }

    test('G1·48 rejects an implicit move-down line in a YAML spec', () {
      final spec = loadYaml("""
tasks:
  - id: downswing
    caption: Your bankroll falls from 42 buy-ins to 34. Your written move-down line is 36 at this stake.
  - id: explicit_personal
    caption: Your personal bankroll rule says move down below 32 buy-ins.
    options:
      - feedback: Under your personal rule, move down below 32 buy-ins.
      - feedback: Move up at 32 buy-ins.
  - id: standard
    caption: Your personal bankroll rule says move down below 32 buy-ins.
    options:
      - feedback: The Sharky course says move down below 32 buy-ins.
  - id: undeclared
    caption: Your current bankroll has 33 buy-ins.
    options:
      - feedback: Your personal move-down line is 36 at this stake.
""");
      expect(bankrollSpecFindings(spec), [
        'downswing.caption: 36 buy-ins',
        'explicit_personal.options[1].feedback: 32 buy-ins',
        'standard.options[0].feedback: 32 buy-ins',
        'undeclared.options[0].feedback: 36 buy-ins',
      ]);
    });

    test('G1·48 catalog allows an explicitly stated personal rule', () {
      final row = _catalogRow('w11_y5d_stay_at_nl10');
      final comparison = _withRunner(
        row,
        row.task.runner.copyWith(
          caption:
              'Your personal bankroll rule says move down below 32 buy-ins.',
          hint: 'Move up at 32 buy-ins.',
        ),
      );
      final findings = runCatalogQualityAudit(rows: [comparison]).findings;
      expect(
        findings.where(
          (key) => key.startsWith('$catalogBankrollThresholdRuleV1|'),
        ),
        ['$catalogBankrollThresholdRuleV1|${row.task.taskId}|hint|32'],
      );
    });

    // Author specs live outside Git. Run this gate with ACT0_BANKROLL_SPEC_DIR
    // set to the l0-audit/specs directory, including any nested spec types.
    final specDirectory = Platform.environment['ACT0_BANKROLL_SPEC_DIR'];
    test(
      'G1·48 scans external author YAML specs',
      () {
        final files =
            Directory(specDirectory!)
                .listSync(recursive: true)
                .whereType<File>()
                .where((file) => file.path.endsWith('_spec.yaml'))
                .toList()
              ..sort((a, b) => a.path.compareTo(b.path));
        expect(files, isNotEmpty);
        final findings = [
          for (final file in files)
            for (final finding in bankrollSpecFindings(
              loadYaml(file.readAsStringSync()),
            ))
              '${file.path}: $finding',
        ];
        expect(findings, isEmpty, reason: findings.join('\n'));
      },
      skip: specDirectory == null ? 'Author spec checkout is external.' : false,
    );

    for (final (price, oldText, oldCount) in [
      (
        10,
        'River Td: SB receives 60 BB. Stacks You 70, SB 130. Call EV 2.27 BB; Fold 0. The earlier 20 BB is sunk. '
            'SB bets 10 BB with aces. Nine hearts win out of 44 unknown cards, so calling at 16.7% gains 2.27 BB over folding. '
            'On the turn, count the cards that win at showdown. Here the other four folded players gave no clues. The prior bet is gone in either choice.',
        81,
      ),
      (
        40,
        'Fold: SB gets 40 BB back and takes 40 BB. No river is played. Stacks You 80, SB 120. '
            'Call EV -15.45 BB; Fold 0. The earlier 20 BB is sunk. '
            'SB bets 40 BB with aces. Nine hearts win out of 44 unknown cards, so the 33.3% price makes calling lose 15.45 BB.',
        62,
      ),
    ]) {
      test('G1·47 rejects the old $price BB correct feedback', () {
        final row = _catalogRow('asm05_new_known_holes_turn_call_$price');
        final correct = row.task.runner.options.singleWhere((o) => o.isCorrect);
        expect(
          catalogCorrectFeedbackWordCountV1(correct),
          lessThanOrEqualTo(40),
        );
        final old = Act0RunnerOptionV1(
          id: correct.id,
          label: correct.label,
          isCorrect: true,
          preferredLabel: correct.preferredLabel,
          quality: correct.quality,
          feedbackTitle: 'Correct decision. Judge the choice, not the result.',
          feedbackReason: oldText,
        );
        final report = runCatalogQualityAudit(
          rows: [
            _withRunner(
              row,
              row.task.runner.copyWith(
                options: [
                  for (final option in row.task.runner.options)
                    if (option.isCorrect) old else option,
                ],
              ),
            ),
          ],
        );
        expect(report.correctFeedbackOverLimit, {
          '${row.task.taskId}|${correct.id}': oldCount,
        });
      });
    }
  });

  test(
    'offline practice generators satisfy G1, C1 contributions, and quality guards',
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
      const generatedPerSkill = 8;
      final postflop = {
        for (final skill in PostflopPracticeSkillV1.values)
          skill: generatePostflopPracticeV1(
            skill,
            count: generatedPerSkill,
            seed: 19,
          ),
      };
      for (final batch in postflop.values) {
        final correctOptions = [
          for (final item in batch)
            item.task.runner.options.singleWhere((option) => option.isCorrect),
        ];
        expect(
          correctOptions.where((option) => option.id == 'first'),
          hasLength(4),
        );
        expect(
          correctOptions.where((option) => option.id == 'second'),
          hasLength(4),
        );
      }
      final allGenerated = [
        ...openFold,
        ...turnDecision,
        ...turnNumeric,
        ...postflop.values.expand((batch) => batch),
      ];
      expect(allGenerated, hasLength(32 + generatedPerSkill * postflop.length));

      final rows = [for (final item in allGenerated) item.toCatalogRow()];
      final truthAudit = runCatalogAudit(rows: rows.take(32));
      final unexpectedTruth = [
        ...truthAudit.findings.keys,
        for (final row in rows.skip(32))
          ...runCatalogAudit(rows: [row]).findings.keys,
      ].where((key) => !key.startsWith('10.')).toList();
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
