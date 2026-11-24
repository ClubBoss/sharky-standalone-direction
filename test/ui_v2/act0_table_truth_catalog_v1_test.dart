import 'package:poker_analyzer/ui_v2/act0_shell/act0_number_entry_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_number_entry_runner_v1.dart';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_timeline_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hand_contributions_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import '../support/act0_y5d_catalog_contract_v1.dart';
import '../support/act0_wave6_contract_v1.dart';
import '../support/act0_y5b_catalog_contract_v1.dart';
import '../support/act0_y5c_catalog_contract_v1.dart';
import '../support/act0_w11_wave4_contract_v1.dart';
import '../support/act0_w12_wave4_contract_v1.dart';
import '../support/act0_catalog_decision_v1.dart';
import '../support/act0_catalog_decision_copy_v1.dart';
import '../support/act0_pot_showdown_truth_v1.dart';
import '../support/act0_catalog_snapshot_v1.dart';
import '../support/act0_catalog_truth_audit_v1.dart';
import '../support/act0_table_truth_v1.dart';
import '../support/act0_w2_catalog_contract_v1.dart';

Act0LessonTaskV1 _nineSeatCatalogTask(
  Act0RunnerStateV1 base, {
  int playersBehind = 6,
  String decisionSeat = 'mp',
}) {
  final order = act0CanonicalSeatOrderForFormatV1(Act0TableFormatV1.nineMax);
  final timeline = Act0HandTimelineV1.fromDeltas(
    coverage: Act0HandHistoryCoverageV1.complete,
    startingStacks: {for (final label in order) label.toLowerCase(): 10000},
    button: 'btn',
    heroSeat: 'mp',
    smallBlind: 50,
    bigBlind: 100,
    board: const [],
    actions: [
      for (final (seat, verb, chips) in const [
        ('sb', Act0HandVerbV1.smallBlind, 50),
        ('bb', Act0HandVerbV1.bigBlind, 100),
        ('utg', Act0HandVerbV1.fold, 0),
        ('utg+1', Act0HandVerbV1.raise, 200),
      ])
        (
          street: PokerStreet.preflop,
          seat: seat,
          verb: verb,
          chipsAdded: chips,
        ),
    ],
  ).beforeDecision;
  final table = Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: Act0TableFormatV1.nineMax,
    playerCount: 9,
    seats: [
      for (final position in order)
        Act0SeatStateV1(
          seatId: position.toLowerCase(),
          seatLabel: position,
          displayName: position,
          isHero: position == 'MP',
          isActive: position == 'MP',
          isDealerButton: position == 'BTN',
          isSmallBlind: position == 'SB',
          isBigBlind: position == 'BB',
          isFolded: position == 'UTG',
          isInHand: position != 'UTG',
        ),
    ],
    heroCards: const [],
    boardCards: const [],
    streetLabel: 'Preflop',
    potLabel: 'Pot 3.5 BB',
    toCallLabel: 'To call 2 BB',
    centerLabel: '',
    activeSeatId: 'mp',
    decisionSeatId: decisionSeat,
    heroSeatId: 'mp',
    highlightedSeatIds: const [],
    highlightedCardIds: const [],
    actionTrail: const [
      Act0ActionTrailItemV1(label: 'SB blind 0.5 BB'),
      Act0ActionTrailItemV1(label: 'BB blind 1 BB'),
      Act0ActionTrailItemV1(label: 'UTG folds'),
      Act0ActionTrailItemV1(label: 'UTG+1 raises to 2 BB'),
      Act0ActionTrailItemV1(label: 'MP acts'),
    ],
    handContributions: timeline.contributions,
    handTimelinePrefix: timeline,
  );
  return Act0LessonTaskV1(
    taskId: 'f2_nine_seat_catalog_fixture',
    title: 'Full ring action order',
    phase: Act0LessonPhaseV1.drill,
    runner: base.copyWith(
      phase: Act0LessonPhaseV1.drill,
      question: 'How do you respond to the raise?',
      caption: '',
      hint: '',
      table: table,
      teachingSteps: const [],
      options: [
        Act0RunnerOptionV1(
          id: 'fold',
          label: 'Fold',
          isCorrect: true,
          preferredLabel: 'Fold',
          quality: Act0FeedbackQualityV1.correct,
          feedbackTitle: 'Correct',
          feedbackReason: 'There are $playersBehind players left to act.',
        ),
        const Act0RunnerOptionV1(
          id: 'call',
          label: 'Call',
          isCorrect: false,
          preferredLabel: 'Fold',
          quality: Act0FeedbackQualityV1.wrong,
          feedbackTitle: 'Try again',
          feedbackReason: 'Count the seats after you.',
        ),
      ],
    ),
    rewardXp: 1,
  );
}

void main() {
  final preview = Act0ShellStateV1.learnerCatalog(nineSeatPreview: true);
  final nineSeatWorlds = [
    for (final world in preview.worlds)
      if ({4, 8, 9}.contains(world.worldNumber))
        world.copyWith(
          lessons: [
            for (final lesson in world.lessons)
              if (act0RunnerRequiresNineSeatPreviewV1(lesson.runner)) lesson,
          ],
        ),
  ];

  test(
    'B15 only adds the authored nine-seat lessons under the preview gate',
    () {
      final regular = Act0ShellStateV1.learnerCatalog(nineSeatPreview: false);
      expect(
        nineSeatWorlds.map((world) => world.lessons.single.taskList.length),
        [5, 6, 6],
      );
      for (final (index, world) in preview.worlds.indexed) {
        final original = regular.worlds[index];
        expect(world.worldId, original.worldId);
        expect(
          world.lessons.where(
            (lesson) => !act0RunnerRequiresNineSeatPreviewV1(lesson.runner),
          ),
          original.lessons,
        );
      }
      expect(identical(preview.liveRoom, regular.liveRoom), isTrue);
      final rows = [
        for (final world in preview.worlds)
          for (final (index, lesson) in world.lessons.indexed)
            if (act0RunnerRequiresNineSeatPreviewV1(lesson.runner))
              for (final task in lesson.taskList)
                (world: world, lesson: lesson, task: task, lessonIndex: index),
      ];
      expect(
        renderCatalogTaskSectionV1(rows).join('\n'),
        File(
          'test/fixtures/act0_catalog_snapshot_ninemax_v1.txt',
        ).readAsStringSync(),
      );
      expect(runCatalogAudit(rows: rows).findings, isEmpty);
    },
  );

  test('B15 nine-seat frames pass the contribution and roster checks', () {
    final rows = auditTableTruth(worlds: nineSeatWorlds);
    const exceptions = <String, (double, double, double, double)>{
      'w04_9m_already_raised': (1.5, 4, 2.5, 38.5),
      'w09_9m_cover_map': (1.5, 3.5, 2, 36.4),
      'w09_9m_individual_ante': (2.4, 2.4, 1, 29.4),
      'w09_9m_bubble_call': (11.5, 36, 24.5, 40.5),
      'w09_9m_transfer_orbit': (2.4, 2.4, 1, 29.4),
    };
    for (final world in nineSeatWorlds) {
      for (final task in world.lessons.single.taskList) {
        final (potBeforeWager, pot, toCall, pricePct) =
            exceptions[task.taskId] ?? (1.5, 1.5, 1.0, 40.0);
        final table = task.runner.table;
        final ledger = table.handContributions!;
        final amounts = ledger.amounts(
          seatIds: table.seats.map((seat) => seat.seatId).toSet(),
          actorSeatId: table.heroSeatId,
        );
        final currentWager = ledger.entries
            .where(
              (entry) =>
                  entry.street == ledger.throughStreet &&
                  entry.kind == Act0ContributionKindV1.wager,
            )
            .lastOrNull;
        expect(
          amounts.potBb - (currentWager?.amountBb ?? 0),
          closeTo(potBeforeWager, 1e-9),
          reason: task.taskId,
        );
        expect(amounts.potBb, closeTo(pot, 1e-9), reason: task.taskId);
        expect(amounts.toCallBb, toCall, reason: task.taskId);
        expect(
          (1000 * amounts.toCallBb! / (amounts.potBb + amounts.toCallBb!))
                  .round() /
              10,
          pricePct,
          reason: task.taskId,
        );
        final checks = rows.where((row) => row.taskId == task.taskId);
        expect(
          checks.map((row) => row.invariant),
          containsAll([
            'D2.pot_feasibility',
            'D3.to_call_completeness',
            'D6.nine_max_roster',
            'D6.history_support',
          ]),
        );
        expect(
          checks.where((row) => row.result != 'PASS').map((row) => row.key),
          isEmpty,
        );
      }
    }
  });

  for (final world in nineSeatWorlds) {
    testWidgets(
      'B15 W${world.worldNumber} renders nine seats and grades a miss',
      (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final lesson = world.lessons.single;
        final task = lesson.taskList.first;
        var runner = task.runner;
        final answers = <Act0CompletedDecisionV1>[];
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Act0NineSeatDebugScopeV1(
              enabled: true,
              child: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) => Act0LessonRunnerShellV1(
                    runner: runner,
                    worldNumber: world.worldNumber,
                    selectedWorldId: world.worldId,
                    selectedLessonId: lesson.lessonId,
                    selectedTaskId: task.taskId,
                    selectedTaskFamily: task.resolvedTaskFamily,
                    evidenceRunId: task.taskId,
                    tableChoreographyMode: Act0TableChoreographyModeV1.settled,
                    onBack: () {},
                    onContinueTheory: () {},
                    onContinueReview: () {},
                    onChooseOption: (option) => setState(() {
                      runner = runner.copyWith(
                        phase: Act0LessonPhaseV1.review,
                        selectedOptionId: option.id,
                      );
                    }),
                    onCompletedDecision: answers.add,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('act0_nine_seat_debug_table')),
          findsOneWidget,
        );
        final centers = {
          for (final seat in runner.table.seats)
            tester.getCenter(
              find.byKey(Key('act0_shell_seat_node_${seat.seatId}')),
            ),
        };
        expect(centers, hasLength(9));
        final wrong = find.byKey(const Key('act0_shell_option_alternative'));
        await tester.ensureVisible(wrong);
        await tester.tap(wrong);
        await tester.pumpAndSettle();
        expect(answers.single.selectedId, 'alternative');
        expect(answers.single.expectedId, 'answer');
        expect(answers.single.resultKind, 'incorrect');
      },
    );
  }

  test('nine-seat source passes Table Truth and G1 position checks', () {
    final world = Act0ShellStateV1.authoredCatalog.worldById('world_8');
    final source = world.lessons.first;
    final task = _nineSeatCatalogTask(source.runner);
    List<TableTruthRow> inspect(Act0LessonTaskV1 task) => auditTableTruth(
      worlds: [
        world.copyWith(
          lessons: [
            source.copyWith(tasks: [task]),
          ],
        ),
      ],
    );

    final findings = inspect(task);
    expect(findings.where((row) => row.result != 'PASS'), isEmpty);
    expect(
      findings.map((row) => row.invariant),
      containsAll([
        'D1.explicit_next_actor',
        'D2.pot_feasibility',
        'D3.to_call_completeness',
        'D6.history_support',
        'D6.nine_max_roster',
      ]),
    );
    expect(
      inspect(
        _nineSeatCatalogTask(source.runner, decisionSeat: 'co'),
      ).singleWhere((row) => row.invariant == 'D6.history_support').result,
      'FAIL',
    );
    expect(
      potTruthParseActionV1(task.runner.table, 'UTG+1 raises to 2 BB')?.actor,
      'UTG+1',
    );
    CatalogTask row(Act0LessonTaskV1 task) =>
        (world: world, lesson: source, task: task, lessonIndex: 0);
    expect(auditDecisionCopyV1(row(task)), isEmpty);
    expect(
      auditDecisionCopyV1(
        row(_nineSeatCatalogTask(source.runner, playersBehind: 5)),
      ).single.rule,
      39,
    );
  });

  testWidgets('the learner route skips an authored nine-seat task', (
    tester,
  ) async {
    final sample = Act0ShellStateV1.authoredCatalog;
    final original = sample.currentLesson;
    final blocked = _nineSeatCatalogTask(original.runner);
    final source = original.copyWith(tasks: [blocked, ...original.taskList]);
    final world = sample.selectedWorld.copyWith(
      lessons: [
        for (final lesson in sample.selectedWorld.lessons)
          identical(lesson, original) ? source : lesson,
      ],
    );
    final catalog = Act0ShellStateV1(
      courseTitle: sample.courseTitle,
      courseSubtitle: sample.courseSubtitle,
      levelLabel: sample.levelLabel,
      xp: sample.xp,
      xpTarget: sample.xpTarget,
      streakDays: sample.streakDays,
      dailyGoalLabel: sample.dailyGoalLabel,
      dailyGoalValue: sample.dailyGoalValue,
      pathProgressLabel: sample.pathProgressLabel,
      selectedWorldId: world.worldId,
      worlds: [world, ...sample.worlds.skip(1)],
      lessons: world.lessons,
      review: sample.review,
      profile: sample.profile,
    );
    expect(catalog.currentLesson.taskList.first, blocked);
    expect(catalog.forLearners().currentLesson.taskList, original.taskList);
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final next = original.courseTaskList.first;
    await tester.pumpWidget(
      MaterialApp(
        home: Act0NineSeatDebugScopeV1(
          enabled: false,
          child: Act0ShellPreviewScreenV1(
            state: catalog,
            initialTab: Act0ShellTabV1.play,
            initialPhase: next.entryPhase,
            showPlacementOnStart: false,
            enableBetaMetrics: false,
          ),
        ),
      ),
    );
    await tester.pump();
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, next.taskId);
    expect(runner.runner.table.tableFormat, Act0TableFormatV1.sixMax);
    expect(find.text(blocked.title), findsNothing);
  });

  test('W4 number-entry answers and bands agree with C1 and Table Truth', () {
    const expected = {
      'w4_good_price_call': (8.0, 1.0),
      'w4_bad_price_fold': (14.0, 7.0),
      'w4_cheap_price_marginal_call': (10.0, 1.0),
      'w4_big_price_marginal_fold': (13.0, 6.0),
      'w4_protection_short_shove_price': (12.0, 6.0),
      'w4_checkpoint_price': (10.0, 3.0),
      'w4_checkpoint_table_price': (7.0, 2.0),
      'w4_checkpoint_table_purpose_price': (8.0, 2.0),
    };
    expect(act0W4NumberEntriesV1.keys, unorderedEquals(expected.keys));
    for (final row in expected.entries) {
      final catalog = catalogTasks.singleWhere(
        (task) => task.task.taskId == row.key,
      );
      final table = catalog.task.runner.table;
      final entry = Act0NumberEntryRunnerV1.fromTask(row.key, table);
      expect(entry, isNotNull, reason: row.key);
      final (pot, price) = row.value;
      expect(CatalogDecisionLedgerV1(table).callBb, price, reason: row.key);
      expect(entry!.pot, pot, reason: row.key);
      expect(entry.price, price, reason: row.key);
      expect(entry.threshold, closeTo(100 * price / (pot + price), 1e-9));
      final spec = entry.spec;
      expect(
        spec.answer,
        closeTo(spec.isPrice ? price : entry.threshold, 1e-9),
      );
      expect(spec.exactTolerance, spec.isPrice ? 0 : .005);
      expect(spec.acceptableTolerance, spec.isPrice ? .1 : 1);
      expect(entry.expected.quality, Act0FeedbackQualityV1.correct);
      for (final direction in [-1, 1]) {
        expect(
          spec.grade(spec.answer + direction * spec.exactTolerance),
          Act0NumberGradeV1.correct,
        );
        expect(
          spec.grade(spec.answer + direction * spec.acceptableTolerance),
          Act0NumberGradeV1.acceptable,
        );
        expect(
          spec.grade(
            spec.answer + direction * (spec.acceptableTolerance + .001),
          ),
          Act0NumberGradeV1.mistake,
        );
      }
    }
  });

  test('W4 number entry parses only the authored forms', () {
    final threshold = act0W4NumberEntriesV1['w4_bad_price_fold']!;
    const forms = Act0NumberFormV1.values;
    expect(threshold.parse('33%', forms[1]), 33);
    expect(threshold.parse('1 / 3', forms[2]), closeTo(100 / 3, 1e-9));
    expect(threshold.parse('1 in 3', forms[3]), closeTo(100 / 3, 1e-9));
    expect(threshold.parse('3', forms[3]), closeTo(100 / 3, 1e-9));
    expect(threshold.grade(33), Act0NumberGradeV1.acceptable);
    expect(threshold.grade(100 / 3), Act0NumberGradeV1.correct);
    expect(threshold.parse('33 BB', forms[0]), isNull);
    expect(threshold.parse('1/0', forms[2]), isNull);
    expect(threshold.parse('1 in 0', forms[3]), isNull);
    expect(
      threshold.grade(threshold.parse('101%', forms[1])!),
      Act0NumberGradeV1.mistake,
    );
    expect(threshold.parse('-1%', forms[1]), isNull);
    expect(threshold.parse('NaN', forms[1]), isNull);
    final price = act0W4NumberEntriesV1['w4_checkpoint_table_price']!;
    expect(price.parse('2.0 BB', forms[0]), 2);
    expect(price.parse('2', forms[0]), 2);
    expect(price.parse('2%', forms[1]), isNull);
  });

  test('W11 all-in decision projects both pots after the hero calls', () {
    const taskId = 'w11_y5d_two_pot_call';
    final row = catalogTasks.singleWhere((row) => row.task.taskId == taskId);
    final table = row.task.runner.table;
    final decision = CatalogDecisionLedgerV1(table);

    expect(decision.hasAllIn, isTrue);
    expect(table.potLabel, 'Pot 21.5 BB');
    expect(decision.callBb, 9);
    expect(decision.effectiveStacks, {'bb': 3, 'hj': 27});

    final pots = decision.pots!;
    expect(pots.map((pot) => pot.amountBb), [18.5, 12.0]);
    expect(pots.first.eligibleSeatIds, {'bb', 'hj', 'btn'});
    expect(pots.last.eligibleSeatIds, {'hj', 'btn'});

    final snapshot = renderCatalogSnapshot(worlds: {11});
    final task = snapshot.split('TASK $taskId ').last.split('\n\n').first;
    expect(task.split('\n').where((line) => line.startsWith('POTS:')), [
      'POTS: main 18.5 (BB, HJ, BTN) · side 12 (HJ, BTN)',
    ]);
  });

  test('contribution checks reject a changed pot or a missing price label', () {
    final source = Act0ShellStateV1.sample
        .worldById('world_11')
        .lessons
        .expand((lesson) => lesson.taskList)
        .singleWhere(
          (task) => task.taskId == 'w11_trigger_small_price_continue',
        );
    final table = source.runner.table;
    final wrong = table.copyWith(potLabel: 'Pot 11 BB', toCallLabel: '');
    final findings = auditTableContributionsV1(
      source.taskId,
      'mutation',
      wrong,
    );

    expect(
      {for (final row in findings) row.invariant: row.result},
      {'D2.pot_feasibility': 'FAIL', 'D3.to_call_completeness': 'FAIL'},
    );
    expect(table.copyWith(actionTrail: const []).handContributions, isNull);
  });

  test('an omitted call label cannot hide a missing effective stack', () {
    final source = Act0ShellStateV1.sample
        .worldById('world_9')
        .lessons
        .expand((lesson) => lesson.taskList)
        .singleWhere((task) => task.taskId == 'w9_bubble_table_risk_transfer');
    final table = source.runner.table;
    final ledger = table.handContributions!;
    final stacks = {...ledger.startingStackBbBySeat}..remove('btn');
    final findings = auditTableContributionsV1(
      source.taskId,
      'mutation',
      table.copyWith(
        toCallLabel: '',
        handContributions: Act0HandContributionsV1(
          throughStreet: ledger.throughStreet,
          entries: ledger.entries,
          startingStackBbBySeat: stacks,
        ),
      ),
    );

    expect(
      {for (final row in findings) row.invariant: row.result},
      {'D2.pot_feasibility': 'PASS', 'D3.to_call_completeness': 'FAIL'},
    );
  });

  test(
    'graded teaching frames fail when displayed amounts lose their ledger',
    () {
      for (final (id, rule) in [
        ('button_advantage_button_recap', 'D2.pot_feasibility'),
        ('what_poker_is_side_pot_intro', 'D2.pot_feasibility'),
        (
          'same_hand_different_seat_position_repair_same_hand_different_seat',
          'D3.to_call_completeness',
        ),
      ]) {
        final table = catalogTasks
            .singleWhere((row) => row.task.taskId == id)
            .task
            .runner
            .table;
        final withoutLedger = table.copyWith(actionTrail: table.actionTrail);
        expect(withoutLedger.handContributions, isNull);
        expect(
          auditTableContributionsV1(
            id,
            'decision',
            table,
          ).singleWhere((row) => row.invariant == rule).result,
          'PASS',
        );
        expect(
          auditTableContributionsV1(
            id,
            'decision',
            withoutLedger,
          ).singleWhere((row) => row.invariant == rule).result,
          'FAIL',
        );
      }
    },
  );

  test('a played preflop pot without contributions fails', () {
    final source = Act0ShellStateV1.sample
        .worldById('world_9')
        .lessons
        .expand((lesson) => lesson.taskList)
        .singleWhere(
          (task) => task.taskId == 'w9_m_ratio_table_window_transfer',
        );

    final findings = auditTableContributionsV1(
      source.taskId,
      'mutation/preflop',
      source.runner.table.copyWith(actionTrail: const []),
    );

    expect(findings.map((row) => (row.invariant, row.result)), [
      ('D2.pot_feasibility', 'FAIL'),
    ]);
  });

  test('W9 shows the wager, pot and exact call from the stack ledger', () {
    final task = Act0ShellStateV1.sample
        .worldById('world_9')
        .lessons
        .expand((lesson) => lesson.taskList)
        .singleWhere((task) => task.taskId == 'w9_bubble_table_risk_transfer');
    final table = task.runner.table;
    final ledger = table.handContributions!;
    final seats = table.seats.map((seat) => seat.seatId).toSet();
    expect(table.potLabel, 'Pot 21 BB');
    expect(table.toCallLabel, 'To call 15.5 BB');
    expect(ledger.startingStackBbBySeat['btn'], 18);
    expect(ledger.startingStackBbBySeat['bb'], 50);
    expect(ledger.amounts(seatIds: seats, actorSeatId: 'btn'), (
      potBb: 21.0,
      toCallBb: 15.5,
    ));
    for (final (startingStack, price) in [(12.0, 9.5), (18.0, 15.5)]) {
      final withStack = Act0HandContributionsV1(
        throughStreet: ledger.throughStreet,
        entries: ledger.entries,
        startingStackBbBySeat: {
          ...ledger.startingStackBbBySeat,
          'btn': startingStack,
        },
      );
      expect(withStack.amounts(seatIds: seats, actorSeatId: 'btn'), (
        potBb: 21.0,
        toCallBb: price,
      ));
    }
  });

  test('W10 uses the authored CO open and BB call before the check', () {
    final table = Act0ShellStateV1.sample
        .worldById('world_10')
        .lessons
        .expand((lesson) => lesson.taskList)
        .singleWhere(
          (task) => task.taskId == 'w10_table_value_vs_caller_transfer',
        )
        .runner
        .table;

    expect(table.potLabel, 'Pot 5.5 BB');
    expect(table.toCallLabel, isEmpty);
    expect(
      table.handContributions!.entries.map(
        (entry) => (entry.seatId, entry.amountBb),
      ),
      containsAll([('sb', 0.5), ('bb', 1.0), ('co', 2.5), ('bb', 1.5)]),
    );
    expect(
      table.handContributions!.amounts(
        seatIds: table.seats.map((seat) => seat.seatId).toSet(),
        actorSeatId: 'co',
      ),
      (potBb: 5.5, toCallBb: 0.0),
    );
  });

  test(
    'W11 and W12 full ledgers prove the effective stack at the decision',
    () {
      const expected = {
        'w11_checkpoint_mixed_table_line': (26.0, 26.0),
        'w12_pretty_hand_bad_price_fold': (90.75, 80.75),
        'w12_revenge_raise_trap': (36.75, 51.75),
        'w12_checkpoint_full_loop_line': (31.75, 56.75),
      };
      final tasks = Act0ShellStateV1.sample.worlds
          .expand((world) => world.lessons)
          .expand((lesson) => lesson.taskList);
      for (final task in tasks.where(
        (task) => expected.containsKey(task.taskId),
      )) {
        final table = task.runner.table;
        final ledger = table.handContributions!;
        final hero = table.heroSeatId!;
        final facing = table.toCallLabel.isNotEmpty;
        final bettor = facing
            ? ledger.entries.last.seatId
            : table.seats.singleWhere((s) => s.isInHand && !s.isHero).seatId;
        expect(ledger.fromStreet.name, 'preflop', reason: task.taskId);
        expect(
          ledger.minimumStartingStackBbBySeat,
          isEmpty,
          reason: task.taskId,
        );
        for (final seat in [hero, bettor]) {
          final invested = ledger.entries
              .take(ledger.entries.length - (facing ? 1 : 0))
              .where((entry) => entry.seatId == seat)
              .fold<double>(0, (sum, entry) => sum + entry.amountBb);
          expect(
            ledger.startingStackBbBySeat[seat]! - invested,
            seat == hero
                ? expected[task.taskId]!.$1
                : expected[task.taskId]!.$2,
            reason: task.taskId,
          );
        }
      }
    },
  );

  test('enumerates the live source and final runtime projections', () {
    final rows = auditTableTruth();
    final earlyWorldTasks = Act0ShellStateV1.sample.worlds
        .where((world) => world.worldNumber <= 4)
        .expand((world) => world.lessons)
        .expand((lesson) => lesson.taskList)
        .map((task) => task.taskId)
        .toSet();
    for (final (rule, count) in [
      ('D2.pot_feasibility', 218),
      ('D3.to_call_completeness', 129),
    ]) {
      final proof = rows.where(
        (row) => earlyWorldTasks.contains(row.taskId) && row.invariant == rule,
      );
      expect(
        proof.where((row) => row.result != 'PASS').map((row) => row.key),
        isEmpty,
        reason: rule,
      );
      expect(
        proof.map((row) => row.taskId).toSet(),
        hasLength(count),
        reason: rule,
      );
    }
    final middleWorldTasks = Act0ShellStateV1.sample.worlds
        .where((world) => world.worldNumber >= 5 && world.worldNumber <= 8)
        .expand((world) => world.lessons)
        .expand((lesson) => lesson.taskList)
        .map((task) => task.taskId)
        .toSet();
    for (final (rule, count) in [
      (
        'D2.pot_feasibility',
        119 +
            y5bNewChoicesV1.length -
            y5bFoundationTaskCountV1 +
            y5cTasksInWorldV1(7) +
            y5cTasksInWorldV1(8),
      ),
      (
        'D3.to_call_completeness',
        117 +
            y5bNewChoicesV1.length -
            y5bFoundationTaskCountV1 +
            y5cTasksInWorldV1(7) +
            y5cTasksInWorldV1(8),
      ),
    ]) {
      final proof = rows
          .where(
            (row) =>
                middleWorldTasks.contains(row.taskId) && row.invariant == rule,
          )
          .toList();
      expect(
        proof.map((row) => row.taskId).toSet(),
        hasLength(count),
        reason: rule,
      );
      expect(
        proof.map((row) => row.taskId).toSet(),
        containsAll([
          'w6_continuation_bet_intro',
          'w6_continuation_bet_dry_size',
          'w6_continuation_bet_wet_check',
          'w6_continuation_bet_value_size',
        ]),
        reason: rule,
      );
      expect(
        proof.where((row) => row.result != 'PASS').map((row) => row.key),
        isEmpty,
      );
    }
    for (final id in [
      'w11_trigger_small_price_continue',
      'w11_trigger_bad_price_fold',
    ]) {
      final proof = rows
          .where(
            (row) =>
                row.taskId == id &&
                (row.invariant == 'D2.pot_feasibility' ||
                    row.invariant == 'D3.to_call_completeness'),
          )
          .toList();
      expect(proof.map((row) => row.invariant).toSet(), {
        'D2.pot_feasibility',
        'D3.to_call_completeness',
      }, reason: id);
      expect(
        proof.map((row) => row.result).toSet(),
        {'PASS'},
        reason:
            '$id: ${proof.where((row) => row.result != 'PASS').map((row) => row.key).join('\n')}',
      );
    }
    const contributionRules = {'D2.pot_feasibility', 'D3.to_call_completeness'};
    expect(
      rows
          .where(
            (row) =>
                contributionRules.contains(row.invariant) &&
                row.result != 'PASS',
          )
          .map((row) => row.key),
      isEmpty,
      reason: 'Every applicable pot and call price needs contribution proof.',
    );
    const lateDecisionProof = {
      'w9_bubble_table_risk_transfer': ('PASS', 'PASS'),
      'w10_table_value_vs_caller_transfer': ('PASS', 'PASS'),
      'w11_checkpoint_mixed_table_line': ('PASS', null),
      'w12_checkpoint_full_loop_line': ('PASS', 'PASS'),
      'w12_pretty_hand_bad_price_fold': ('PASS', 'PASS'),
      'w12_revenge_raise_trap': ('PASS', 'PASS'),
      'asm05_new_known_holes_turn_call_10': ('PASS', 'PASS'),
      'asm05_new_known_holes_turn_call_40': ('PASS', 'PASS'),
    };
    for (final MapEntry(key: id, value: (pot, price))
        in lateDecisionProof.entries) {
      for (final (rule, verdict) in [
        ('D2.pot_feasibility', pot),
        ('D3.to_call_completeness', price),
      ]) {
        final proof = rows.where(
          (row) => row.taskId == id && row.invariant == rule,
        );
        expect(proof.map((row) => row.result).toSet(), {
          if (verdict != null) verdict,
        }, reason: '$id $rule');
      }
    }
    final tasks = Act0ShellStateV1.sample.worlds
        .expand((w) => w.lessons)
        .expand((l) => l.taskList)
        .toList();
    expect(tasks.map((t) => t.taskId).toSet().length, tasks.length);
    expect(
      rows.map((r) => r.taskId).toSet(),
      tasks.map((t) => t.taskId).toSet(),
    );
    final out = Directory(
      Platform.environment['TABLE_TRUTH_OUTPUT'] ?? 'output/table_truth',
    );
    out.createSync(recursive: true);
    File(
      '${out.path}/ledger.json',
    ).writeAsStringSync(jsonEncode(rows.map((r) => r.toJson()).toList()));
    final contract = <String, Object?>{
      for (final t in tasks)
        t.taskId: {
          'rewardXp': t.rewardXp,
          'family': t.resolvedTaskFamily.name,
          'options': [
            for (final o in t.runner.options)
              {
                'id': o.id,
                'correct': o.isCorrect,
                'quality': o.quality.name,
                'seat': o.seatId,
                'repairSeats': o.repairFocusSeatIds,
                'repairCards': o.repairFocusCardIds,
                'repairLabels': o.repairFocusLabels,
              },
          ],
        },
    };
    File(
      '${out.path}/learning-contract.json',
    ).writeAsStringSync(jsonEncode(contract));
    verifyWave6AndRestoreLearningV1(contract);
    const admittedAdditions = {
      'asm05_new_known_holes_turn_call_10',
      'asm05_new_known_holes_turn_call_40',
    };
    final baselineBytes = File(
      'test/ui_v2/fixtures/table_truth_learning_contract_v1.json',
    ).readAsBytesSync();
    expect(
      sha256.convert(baselineBytes).toString(),
      'da163eaa50ee1a19dcdceb09f3ac65af4be3b4c296c36c48ffa5ef7d6d77e7a4',
      reason: 'The historical contract fixture remains byte-for-byte frozen.',
    );
    final baselineContract = Map<String, Object?>.from(
      jsonDecode(utf8.decode(baselineBytes)) as Map,
    );
    final presentAdditions = contract.keys.toSet().intersection(
      admittedAdditions,
    );
    final w9Learning = {
      for (final entry in contract.entries)
        if (entry.key.startsWith('w9_') &&
            !y5cNewChoicesV1.containsKey(entry.key))
          entry.key: entry.value,
    };
    expect(
      sha256.convert(utf8.encode(jsonEncode(w9Learning))).toString(),
      'ac9ae86c5283e58913c0a71cdf2cb83cbf8db1869dce1af14e927f1aff5cb0a3',
    );
    final preAtlasW9 =
        jsonDecode(
              File(
                'test/fixtures/act0_w9_pre_atlas_identity_v1.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    for (final entry in y5dNewChoicesV1.entries) {
      final row = (contract[entry.key] as Map).cast<String, dynamic>();
      expect(row['rewardXp'], 8, reason: entry.key);
      expect(row['family'], 'decision', reason: entry.key);
      expect(
        (row['options'] as List).map((raw) {
          final option = raw as Map;
          return [option['id'], option['correct'], option['quality']];
        }).toList(),
        entry.value.map((choice) => [choice[0], choice[2], choice[3]]).toList(),
        reason: entry.key,
      );
    }
    final w10Learning = {
      for (final entry in contract.entries)
        if (entry.key.startsWith('w10_') &&
            !y5dNewChoicesV1.containsKey(entry.key))
          entry.key: entry.value,
    };
    expect(
      sha256.convert(utf8.encode(jsonEncode(w10Learning))).toString(),
      '30f317099467fc22ced9f7004fa009851f73348ad6ead65245d9d48449de11a5',
    );
    final preAtlasW10 =
        jsonDecode(
              File(
                'test/fixtures/act0_w10_pre_atlas_identity_v1.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    final historicalContract = Map<String, Object?>.from(contract)
      ..removeWhere(
        (id, _) =>
            y5dNewChoicesV1.containsKey(id) ||
            admittedAdditions.contains(id) ||
            (id.startsWith('w9_') && !y5cNewChoicesV1.containsKey(id)) ||
            id.startsWith('w10_'),
      )
      ..addAll((preAtlasW9['learning'] as Map).cast<String, Object?>())
      ..addAll((preAtlasW10['learning'] as Map).cast<String, Object?>());
    // Keep the historical fixture immutable. PR460 quality cells and the
    // exact owner-admitted W01 theory option contracts are checked separately;
    // persisted records are never rewritten by this comparison.
    final historicalComparison =
        jsonDecode(jsonEncode(historicalContract)) as Map<String, dynamic>;
    if (presentAdditions.isNotEmpty) {
      final setup =
          historicalComparison['first_table_guide_one_clear_choice']
              as Map<String, dynamic>;
      final options = (setup['options'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      for (final (id, current, prior) in <(String, String, String)>[
        ('co_still_acting', 'wrong', 'wrong'),
        ('hero_has_no_cards', 'wrong', 'suboptimal'),
      ]) {
        final option = options.singleWhere((option) => option['id'] == id);
        expect(
          option['quality'],
          current,
          reason: 'Exact reviewed MAIN01 grade: $id',
        );
        option['quality'] = prior;
      }
    }
    // Exact three-concept source correction admitted on Issue364 / PR475.
    // Literal expected values, never copied from live production at runtime.
    const reviewedW01TheoryOptions = {
      'blinds_theory': [
        {
          'id': 'button_is_not_a_blind',
          'correct': false,
          'quality': 'wrong',
          'seat': 'btn',
          'repairSeats': [],
          'repairCards': [],
          'repairLabels': [],
        },
        {
          'id': 'bb',
          'correct': true,
          'quality': 'correct',
          'seat': 'bb',
          'repairSeats': [],
          'repairCards': [],
          'repairLabels': [],
        },
        {
          'id': 'sb',
          'correct': false,
          'quality': 'wrong',
          'seat': 'sb',
          'repairSeats': [],
          'repairCards': [],
          'repairLabels': [],
        },
      ],
      'cards_ranks_suits_theory': [
        {
          'id': 'rank_only',
          'correct': false,
          'quality': 'wrong',
          'seat': null,
          'repairSeats': [],
          'repairCards': [],
          'repairLabels': [],
        },
        {
          'id': 'rank_and_suit',
          'correct': true,
          'quality': 'correct',
          'seat': null,
          'repairSeats': [],
          'repairCards': [],
          'repairLabels': [],
        },
        {
          'id': 'suit_only',
          'correct': false,
          'quality': 'wrong',
          'seat': null,
          'repairSeats': [],
          'repairCards': [],
          'repairLabels': [],
        },
      ],
      'hand_rankings_theory': [
        {
          'id': 'hand_strength',
          'correct': true,
          'quality': 'correct',
          'seat': null,
          'repairSeats': [],
          'repairCards': [],
          'repairLabels': [],
        },
        {
          'id': 'seat_position',
          'correct': false,
          'quality': 'wrong',
          'seat': null,
          'repairSeats': [],
          'repairCards': [],
          'repairLabels': [],
        },
      ],
    };
    final expectedComparison =
        jsonDecode(jsonEncode(baselineContract)) as Map<String, dynamic>;
    if (presentAdditions.isNotEmpty) {
      for (final entry in reviewedW01TheoryOptions.entries) {
        final expectedTask =
            expectedComparison[entry.key] as Map<String, dynamic>;
        expect(
          expectedTask['options'],
          hasLength(entry.value.length),
          reason:
              'Reviewed theory option cardinality stays frozen: ${entry.key}',
        );
        expectedTask['options'] = entry.value;
      }
    }
    // Exact active W24 context-answer revision. Keep the frozen fixture and
    // verify both literal contracts before reversing only these two choices.
    const contextTaskId = 'same_hand_different_seat_w3_same_hand_recap';
    const priorContextOptions = <Map<String, Object?>>[
      {
        'id': 'utg',
        'correct': false,
        'quality': 'wrong',
        'seat': 'utg',
        'repairSeats': <String>[],
        'repairCards': <String>[],
        'repairLabels': <String>[],
      },
      {
        'id': 'btn',
        'correct': true,
        'quality': 'correct',
        'seat': 'btn',
        'repairSeats': <String>[],
        'repairCards': <String>[],
        'repairLabels': <String>[],
      },
    ];
    const currentContextOptions = <Map<String, Object?>>[
      {
        'id': 'one_answer',
        'correct': false,
        'quality': 'wrong',
        'seat': null,
        'repairSeats': <String>[],
        'repairCards': <String>[],
        'repairLabels': <String>[],
      },
      {
        'id': 'framework',
        'correct': true,
        'quality': 'correct',
        'seat': null,
        'repairSeats': <String>[],
        'repairCards': <String>[],
        'repairLabels': <String>[],
      },
      {
        'id': 'seat_blind_only',
        'correct': false,
        'quality': 'wrong',
        'seat': null,
        'repairSeats': <String>[],
        'repairCards': <String>[],
        'repairLabels': <String>[],
      },
    ];
    final firstTableOptions =
        (expectedComparison['first_table_guide_one_clear_choice']
                as Map<String, dynamic>)['options']
            as List;
    for (final option in firstTableOptions.cast<Map<String, dynamic>>()) {
      option['repairLabels'] = const [
        'Your cards',
        'Shared cards',
        'Board space',
      ];
    }
    final context = historicalComparison[contextTaskId] as Map<String, dynamic>;
    expect(expectedComparison[contextTaskId], <String, Object?>{
      'rewardXp': 12,
      'family': 'review',
      'options': priorContextOptions,
    });
    if (presentAdditions.isNotEmpty) {
      expect(context, <String, Object?>{
        'rewardXp': 12,
        'family': 'review',
        'options': currentContextOptions,
      });
      context['options'] = priorContextOptions;
    } else {
      expect(context, <String, Object?>{
        'rewardXp': 12,
        'family': 'review',
        'options': priorContextOptions,
      });
    }
    // L1 revises the exact disputed answers while the frozen historical
    // fixture still guards XP, task IDs, unaffected choices and repair fields.
    const gradingCorrections = {
      'button_advantage_button_vs_cutoff': [
        ('co', false, 'co'),
        ('btn', true, 'btn'),
      ],
      'same_hand_different_seat_w3_same_hand_intro': [
        ('cards_and_seat', false, null),
        ('full_context', true, null),
      ],
      'same_hand_different_seat_w3_same_hand_call': [
        ('blinds_only', false, null),
        ('players_behind', true, null),
      ],
      'w4_cheap_price_marginal_call': [
        ('fold', false, null),
        ('call', true, null),
      ],
      'w4_big_price_marginal_fold': [
        ('call', false, null),
        ('fold', true, null),
      ],
      'w4_checkpoint_table_price': [
        ('fold', false, null),
        ('call', true, null),
      ],
    };
    for (final entry in gradingCorrections.entries) {
      final expectedTask =
          expectedComparison[entry.key] as Map<String, dynamic>;
      expectedTask['options'] = [
        for (final (id, correct, seat) in entry.value)
          {
            'id': id,
            'correct': correct,
            'quality': correct ? 'correct' : 'wrong',
            'seat': seat,
            'repairSeats': <String>[],
            'repairCards': <String>[],
            'repairLabels': <String>[],
          },
      ];
    }
    for (final id in [
      'actions_theory',
      'actions_raise_drill',
      'actions_review',
    ]) {
      final row = expectedComparison[id] as Map<String, dynamic>;
      final choice = (row['options'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((option) => option['id'] == 'call');
      choice['quality'] = 'wrong';
      choice['repairLabels'] = [
        'Matches 1 BB',
        'Sets a higher price',
        'Button',
      ];
    }
    for (final id in [
      'apply_btn_open',
      'button_advantage_button_open',
      'position_apply_btn_open',
    ]) {
      final row = expectedComparison[id] as Map<String, dynamic>;
      for (final choice
          in (row['options'] as List).cast<Map<String, dynamic>>()) {
        choice['repairSeats'] = <String>[];
        choice['repairCards'] = <String>[];
        choice['repairLabels'] = <String>[];
      }
    }
    final checkpointPrice =
        expectedComparison['w4_checkpoint_price'] as Map<String, dynamic>;
    for (final choice
        in (checkpointPrice['options'] as List).cast<Map<String, dynamic>>()) {
      final isCall = choice['id'] == 'call';
      choice['correct'] = isCall;
      choice['quality'] = isCall ? 'correct' : 'wrong';
    }
    // P6 updates the learner label for the two first-hand card exercises.
    // Keep the underlying card focus, choices and grading from the fixture.
    for (final id in [
      'your_first_hand_preflop',
      'your_first_hand_private_cards_recheck',
    ]) {
      final row = expectedComparison[id] as Map<String, dynamic>;
      for (final option
          in (row['options'] as List).cast<Map<String, dynamic>>()) {
        expect(option['repairLabels'], ['Hero cards']);
        option['repairLabels'] = ['Your cards'];
      }
    }
    for (final id in [
      'actions_theory',
      'actions_raise_drill',
      'actions_review',
    ]) {
      final row = expectedComparison[id] as Map<String, dynamic>;
      final options = (row['options'] as List).cast<Map<String, dynamic>>();
      for (final choiceId in ['fold', 'raise']) {
        final option = options.singleWhere((value) => value['id'] == choiceId);
        final labels = (option['repairLabels'] as List).cast<String>();
        expect(labels, contains('Hero acts'));
        option['repairLabels'] = [
          for (final label in labels)
            label == 'Hero acts' ? 'Your turn' : label,
        ];
      }
    }
    final raiseDrill =
        expectedComparison['actions_raise_drill'] as Map<String, dynamic>;
    final raiseDrillFold = (raiseDrill['options'] as List)
        .cast<Map<String, dynamic>>()
        .singleWhere((option) => option['id'] == 'fold');
    expect(raiseDrillFold['repairLabels'], [
      'Your turn',
      'Blinds posted',
      'KTs',
    ]);
    raiseDrillFold['repairLabels'] = ['Your turn', 'Blinds posted', 'QJs'];

    const w1FactualGrades = {
      'what_poker_is_table_read_transfer': 'hand_first_only',
      'what_poker_is_table_read_recheck': 'hero_cards_only',
      'your_first_hand_private_cards_recheck': 'board_cards',
      'what_poker_is_all_in_meaning': 'largest_stack_only',
      'what_poker_is_matched_chips_transfer': 'nothing_until_showdown',
      'what_poker_is_win_ways': 'best_hand_showdown',
      'what_poker_is_showdown_win': 'hero_cards_only',
      'what_poker_is_live_win_transfer': 'hero_cards_decide_now',
    };
    for (final entry in w1FactualGrades.entries) {
      final task = expectedComparison[entry.key] as Map<String, dynamic>;
      final option = (task['options'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((row) => row['id'] == entry.value);
      expect(option['quality'], 'suboptimal', reason: entry.key);
      option['quality'] = 'wrong';
    }
    final qjs =
        expectedComparison['hand_discipline_buckets_borderline']
            as Map<String, dynamic>;
    final strongQJs = (qjs['options'] as List)
        .cast<Map<String, dynamic>>()
        .singleWhere((option) => option['id'] == 'strong');
    expect(strongQJs['quality'], 'suboptimal');
    strongQJs['quality'] = 'wrong';
    for (final (taskId, optionId) in [
      (
        'position_checkpoint_position_checkpoint_table_notice',
        'late_free_pass',
      ),
      (
        'same_hand_different_seat_position_repair_same_hand_different_seat',
        'position_unimportant',
      ),
      ('w4_bluff_pressure', 'check'),
      ('w4_checkpoint_table_purpose_price', 'random_size'),
    ]) {
      final task = expectedComparison[taskId] as Map<String, dynamic>;
      final option = (task['options'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((option) => option['id'] == optionId);
      expect(option['quality'], 'suboptimal', reason: '$taskId / $optionId');
      option['quality'] = 'wrong';
    }
    for (final (taskId, choiceId) in [
      ('w9_survival_stack_tradeoff', 'same_both'),
      ('w9_checkpoint_zone_line', 'same_zone'),
    ]) {
      final task = expectedComparison[taskId] as Map<String, dynamic>;
      final choice = (task['options'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((option) => option['id'] == choiceId);
      expect(choice['quality'], 'suboptimal', reason: taskId);
      choice['quality'] = 'wrong';
    }
    // P7–P8 classify false showdown outcomes and incomplete best fives as wrong.
    for (final id in [
      'showdown_review',
      'your_first_hand_showdown',
      'showdown_best_hand_drill',
    ]) {
      final showdown = expectedComparison[id] as Map<String, dynamic>;
      final winChoice = (showdown['options'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((choice) => choice['id'] == 'hero_cards_only');
      expect(winChoice['quality'], 'suboptimal');
      winChoice['quality'] = 'wrong';
    }
    expectedComparison['first_table_guide_shared_cards_repair'] = {
      'rewardXp': 0,
      'family': 'repair',
      'options': [
        for (final id in ['board', 'private'])
          {
            'id': id,
            'correct': id == 'board',
            'quality': id == 'board' ? 'correct' : 'wrong',
            'seat': null,
            'repairSeats': <String>[],
            'repairCards': <String>[],
            'repairLabels': <String>[],
          },
      ],
    };
    // P7 aligns the KQo call cue with the chart. Seat and card focus stay pinned.
    final mediumOpen =
        expectedComparison['continue_or_let_go_medium_open']
            as Map<String, dynamic>;
    final limpChoice = (mediumOpen['options'] as List)
        .cast<Map<String, dynamic>>()
        .singleWhere((choice) => choice['id'] == 'call');
    expect(limpChoice['repairLabels'], ['Limp legal', 'Raise sharper', 'BTN']);
    limpChoice['repairLabels'] = ['Call 1 BB', 'Chart says raise', 'BTN'];
    // L2·3 grades the new price drills and range comparisons explicitly.
    const l2DrawAndRangeOptions = {
      'outs_improvement_w5_table_outs_flush_transfer': [
        ('price_only', false),
        ('heart_outs', true),
      ],
      'outs_improvement_w5_table_outs_straight_transfer': [
        ('four_or_nine', true),
        ('blank_turn_killed', false),
      ],
      'turn_river_changes_w5_board_checkpoint': [
        ('just_outs', false),
        ('texture_draw_outs', true),
      ],
      'w6_value_wet_board': [
        ('bluff', false),
        ('value', true),
        ('missed', false),
      ],
      'w6_board_fit_recap': [
        ('caller', false),
        ('same', false),
        ('raiser', true),
      ],
    };
    for (final entry in l2DrawAndRangeOptions.entries) {
      final task = expectedComparison[entry.key] as Map<String, dynamic>;
      task['options'] = [
        for (final (id, correct) in entry.value)
          {
            'id': id,
            'correct': correct,
            'quality': correct ? 'correct' : 'wrong',
            'seat': null,
            'repairSeats': <String>[],
            'repairCards': <String>[],
            'repairLabels': <String>[],
          },
      ];
    }
    // Exact checkpoint grades replace the retired choice content.
    const l2CheckpointGrades = {
      'straight_draws_w5_gutshot_contrast_transfer': [
        ("gutshot", false, "suboptimal"),
        ("open_ended", true, "correct"),
        ("made_straight", false, "wrong"),
      ],
      'range_checkpoint_value': [
        ("value", true, "correct"),
        ("bluff", false, "suboptimal"),
        ("missed", false, "wrong"),
      ],
      'range_checkpoint_combos': [
        ("twelve", false, "wrong"),
        ("six", false, "wrong"),
        ("sixteen", true, "correct"),
      ],
      'w6_kicker_showdown_compare': [
        ("hero_ak", true, "correct"),
        ("villain_kq", false, "wrong"),
        ("tie", false, "wrong"),
      ],
      'w6_checkpoint_table_best_five': [
        ("hero_wins", false, "wrong"),
        ("split", true, "correct"),
        ("villain_wins", false, "wrong"),
      ],
      'w7_format_table_notice': [
        ("open_same", false, "wrong"),
        ("depth_only", false, "wrong"),
        ("tighten_early", true, "correct"),
      ],
    };
    for (final entry in l2CheckpointGrades.entries) {
      final task = expectedComparison[entry.key] as Map<String, dynamic>;
      task['options'] = [
        for (final (id, correct, quality) in entry.value)
          {
            'id': id,
            'correct': correct,
            'quality': quality,
            'seat': null,
            'repairSeats': <String>[],
            'repairCards': <String>[],
            'repairLabels': <String>[],
          },
      ];
    }
    for (final (taskId, choiceId) in [
      ('w6_ak_combos', 'twelve'),
      ('w6_pair_combos', 'twelve'),
      ('w6_combo_weight_compare', 'same_weight'),
    ]) {
      final task = expectedComparison[taskId] as Map<String, dynamic>;
      final option = (task['options'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((option) => option['id'] == choiceId);
      expect(option['quality'], 'suboptimal');
      option['quality'] = 'wrong';
    }
    final w6ValueOptions =
        (expectedComparison['w6_value_range_action']
                as Map<String, dynamic>)['options']
            as List;
    final oldFold = w6ValueOptions.cast<Map<String, dynamic>>().singleWhere(
      (option) => option['id'] == 'fold',
    );
    oldFold['id'] = 'bet_bluff'; // BB checked; folding is not an offered line.
    for (final entry in fixedDrawRangeAndStackChoicesV1.entries) {
      final task = expectedComparison[entry.key] as Map<String, dynamic>;
      final option = (task['options'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((option) => option['id'] == entry.value);
      expect(option['quality'], 'suboptimal', reason: entry.key);
      option['quality'] = 'wrong';
    }
    for (final entry in q3AppendedChoicesV1.entries) {
      final expected = expectedComparison[entry.key] as Map<String, dynamic>;
      (expected['options'] as List).add({
        'id': entry.value,
        'correct': false,
        'quality': 'wrong',
        'seat': null,
        'repairSeats': <String>[],
        'repairCards': <String>[],
        'repairLabels': <String>[],
      });
    }
    for (final entry in [
      ...w4AddedOptionQualityV1.entries,
      ...w5AddedOptionQualityV1.entries,
    ]) {
      final expected = expectedComparison[entry.key] as Map<String, dynamic>;
      final (id, quality) = entry.value;
      (expected['options'] as List).add({
        'id': id,
        'correct': false,
        'quality': quality,
        'seat': null,
        'repairSeats': <String>[],
        'repairCards': id == 'semi_wet'
            ? <String>['board_0', 'board_1', 'board_2']
            : <String>[],
        'repairLabels': <String>[],
      });
    }
    for (final entry in wave4CorrectOptionMovedLastV1.entries) {
      final task = expectedComparison[entry.key] as Map<String, dynamic>;
      final choices = (task['options'] as List).cast<Map<String, dynamic>>();
      expect(choices, hasLength(3), reason: entry.key);
      expect(choices[1]['id'], entry.value, reason: entry.key);
      expect(choices[1]['correct'], isTrue, reason: entry.key);
      choices.add(choices.removeAt(1));
    }
    for (final (taskId, family, correctChoice, choiceCount) in [
      ('w7_flop_bluff_one_player', 'decision', 1, 2),
      ('w7_flop_bluff_two_players', 'decision', 2, 2),
      ('w7_count_winning_rivers', 'counting', 2, 3),
      ('w7_clean_outs_lower_price', 'decision', 1, 2),
      ('w7_clean_outs_higher_price', 'decision', 2, 2),
      ('w7_river_one_bluff_of_six', 'transfer', 2, 2),
      ('w7_river_two_bluffs_of_six', 'transfer', 1, 2),
      ('w7_checkpoint_river_card_excludes_hand', 'transfer', 2, 2),
    ]) {
      expectedComparison[taskId] = {
        'rewardXp': 10,
        'family': family,
        'options': [
          for (var choice = 1; choice <= choiceCount; choice++)
            {
              'id': 'choice_$choice',
              'correct': choice == correctChoice,
              'quality': choice == correctChoice ? 'correct' : 'wrong',
              'seat': null,
              'repairSeats': <String>[],
              'repairCards': <String>[],
              'repairLabels': <String>[],
            },
        ],
      };
    }
    expectedComparison['w4_min_raise_preflop'] = {
      'rewardXp': 8,
      'family': 'decision',
      'options': [
        {
          'id': 'four_bb',
          'correct': false,
          'quality': 'wrong',
          'seat': null,
          'repairSeats': <String>[],
          'repairCards': <String>[],
          'repairLabels': <String>['Minimum raise'],
        },
        {
          'id': 'five_bb',
          'correct': true,
          'quality': 'correct',
          'seat': null,
          'repairSeats': <String>[],
          'repairCards': <String>[],
          'repairLabels': <String>['Minimum raise'],
        },
        {
          'id': 'six_bb',
          'correct': false,
          'quality': 'wrong',
          'seat': null,
          'repairSeats': <String>[],
          'repairCards': <String>[],
          'repairLabels': <String>['Minimum raise'],
        },
      ],
    };
    expectedComparison['w4_min_raise_postflop'] = {
      'rewardXp': 8,
      'family': 'decision',
      'options': [
        {
          'id': 'six_bb',
          'correct': false,
          'quality': 'wrong',
          'seat': null,
          'repairSeats': <String>[],
          'repairCards': <String>[],
          'repairLabels': <String>['Minimum raise'],
        },
        {
          'id': 'twelve_bb',
          'correct': false,
          'quality': 'wrong',
          'seat': null,
          'repairSeats': <String>[],
          'repairCards': <String>[],
          'repairLabels': <String>['Minimum raise'],
        },
        {
          'id': 'eight_bb',
          'correct': true,
          'quality': 'correct',
          'seat': null,
          'repairSeats': <String>[],
          'repairCards': <String>[],
          'repairLabels': <String>['Minimum raise'],
        },
      ],
    };
    Map<String, Object?> w2Choice(String id, {bool correct = false}) => {
      'id': id,
      'correct': correct,
      'quality': correct ? 'correct' : 'wrong',
      'seat': null,
      'repairSeats': <String>[],
      'repairCards': <String>[],
      'repairLabels': <String>[],
    };
    for (final entry in w2AppendedWrongChoicesV1.entries) {
      final task = expectedComparison[entry.key] as Map<String, dynamic>;
      (task['options'] as List).add(w2Choice(entry.value));
    }
    const w2ReasonChoices = {
      'apply_recap': (['fold', 'call', 'seat_guarantee'], 'fold'),
      'hand_discipline_buckets_recap': (
        ['suit_only', 'bucket_and_seat', 'blinds_only'],
        'bucket_and_seat',
      ),
      'fold_discipline_facing_fold': (
        ['call', 'fold', 'raise_for_pot'],
        'fold',
      ),
    };
    for (final MapEntry(key: id, value: (choices, correct))
        in w2ReasonChoices.entries) {
      final task = expectedComparison[id] as Map<String, dynamic>;
      task['options'] = [
        for (final id in choices) w2Choice(id, correct: id == correct),
      ];
    }
    for (final (id, xp, family, choices, correct) in [
      ('intro', 6, 'learn', <String>[], ''),
      ('premium', 9, 'decision', ['raise', 'call', 'fold'], 'raise'),
      ('strong', 9, 'decision', ['raise', 'call', 'fold'], 'call'),
      ('medium', 9, 'decision', ['premium', 'call', 'unopened'], 'call'),
      ('fold', 12, 'review', ['raise', 'call', 'fold'], 'fold'),
    ]) {
      expectedComparison['w2_narrow_three_bet_$id'] = {
        'rewardXp': xp,
        'family': family,
        'options': [
          for (final id in choices) w2Choice(id, correct: id == correct),
        ],
      };
    }
    Map<String, Object?> w3Option(
      String id, {
      String? seat,
      bool correct = false,
    }) => {
      'id': id,
      'correct': correct,
      'quality': correct ? 'correct' : 'wrong',
      'seat': seat,
      'repairSeats': <String>[],
      'repairCards': <String>[],
      'repairLabels': <String>[],
    };
    final applyRecap = expectedComparison['position_apply_recap'] as Map;
    final limpExplanation = (applyRecap['options'] as List)
        .cast<Map<String, dynamic>>()
        .singleWhere((option) => option['id'] == 'call');
    expect(limpExplanation['quality'], 'suboptimal');
    limpExplanation['quality'] = 'wrong';
    const w3AddedSeatChoices = {
      'position_six_seats_positions_utg': 'bb',
      'position_six_seats_hj_co_contrast': 'utg',
      'position_six_seats_positions_cutoff': 'btn',
      'position_six_seats_positions_button': 'sb',
      'position_six_seats_sb_recognition': 'btn',
      'position_six_seats_bb_recognition': 'utg',
      'position_six_seats_position_repair_seat_id_btn': 'bb',
      'position_six_seats_position_repair_seat_id_utg': 'sb',
      'button_advantage_button_intro': 'co',
      'button_advantage_find_button': 'sb',
      'button_advantage_button_last': 'bb',
      'button_advantage_button_vs_cutoff': 'hj',
      'button_advantage_position_repair_btn_last_postflop': 'bb',
      'early_vs_late_w2_position_intro': 'hj',
      'early_vs_late_w2_late_position': 'co',
      'early_vs_late_w2_early_position': 'co',
      'position_apply_intro': 'co',
      'position_checkpoint_position_checkpoint_intro': 'hj',
    };
    const w3AddedAnswerChoices = {
      'position_six_seats_positions_review': 'blinds_and_button_only',
      'early_vs_late_early_pressure_choice': 'position_returns_chips',
      'early_vs_late_position_repair_utg_players_behind': 'only_hj',
      'early_vs_late_late_info_choice': 'smaller_blinds',
      'same_hand_different_seat_w3_same_hand_intro': 'seat_and_action',
      'same_hand_different_seat_w3_same_hand_call': 'opener_and_button',
      'same_hand_different_seat_same_hand_early_fold': 'call',
      'same_hand_different_seat_same_hand_late_open': 'fold',
      'position_apply_late_open': 'fold',
      'position_apply_early_fold': 'call',
      'position_apply_hj_fold': 'call',
      'position_apply_recap': 'off_chart',
      'position_checkpoint_position_checkpoint_late_open': 'fold',
      'position_checkpoint_position_checkpoint_early_fold': 'call',
      'position_checkpoint_position_checkpoint_btn_call': 'raise',
      'position_checkpoint_position_checkpoint_review': 'fold',
    };
    for (final entry in w3AddedSeatChoices.entries) {
      final task = expectedComparison[entry.key] as Map<String, dynamic>;
      (task['options'] as List).add(w3Option(entry.value, seat: entry.value));
    }
    for (final entry in w3AddedAnswerChoices.entries) {
      final task = expectedComparison[entry.key] as Map<String, dynamic>;
      (task['options'] as List).add(w3Option(entry.value));
    }
    for (final (id, xp, family, choices, correct) in [
      (
        'position_six_seats_position_order_reason',
        6,
        'decision',
        ['cutoff_first', 'seat_order', 'button_before_cutoff'],
        'seat_order',
      ),
      (
        'button_advantage_button_order_reason',
        6,
        'decision',
        ['sees_first_action', 'smaller_price', 'owns_first_turn'],
        'sees_first_action',
      ),
      ('w3_play_from_blinds_intro', 6, 'learn', <String>[], ''),
      (
        'w3_play_from_blinds_bvb_sb_open',
        8,
        'decision',
        ['call', 'raise', 'fold'],
        'raise',
      ),
      (
        'w3_play_from_blinds_bvb_bb_call',
        8,
        'decision',
        ['fold', 'check', 'call'],
        'call',
      ),
      (
        'w3_play_from_blinds_bvb_bb_repeat',
        8,
        'decision',
        ['fold', 'call', 'check'],
        'fold',
      ),
      (
        'w3_play_from_blinds_small_blind_fold',
        8,
        'decision',
        ['call', 'fold', 'raise'],
        'fold',
      ),
      (
        'w3_play_from_blinds_small_blind_raise',
        8,
        'decision',
        ['raise', 'call', 'fold'],
        'raise',
      ),
      (
        'w3_play_from_blinds_small_blind_medium_raise',
        8,
        'decision',
        ['raise', 'call', 'fold'],
        'raise',
      ),
      (
        'w3_play_from_blinds_small_blind_medium_fold',
        8,
        'decision',
        ['call', 'fold', 'raise'],
        'fold',
      ),
      (
        'w3_play_from_blinds_big_blind_price',
        8,
        'decision',
        ['two_five', 'one', 'one_five'],
        'one_five',
      ),
      (
        'w3_play_from_blinds_big_blind_defend',
        10,
        'review',
        ['fold', 'call', 'posted_free'],
        'call',
      ),
    ]) {
      expectedComparison[id] = {
        'rewardXp': xp,
        'family': family,
        'options': [
          for (final option in choices)
            w3Option(option, correct: option == correct),
        ],
      };
    }
    for (final (id, xp, family, options, correct) in [
      ('intro', 6, 'learn', <String>[], ''),
      (
        'dry_size',
        9,
        'decision',
        ['bet_two', 'bet_six', 'bet_nine'],
        'bet_two',
      ),
      ('wet_check', 9, 'review', ['bet_small', 'check', 'bet_large'], 'check'),
    ]) {
      expectedComparison['w6_continuation_bet_$id'] = {
        'rewardXp': xp,
        'family': family,
        'options': [
          for (final option in options)
            w2Choice(option, correct: option == correct),
        ],
      };
    }
    expectedComparison['what_poker_is_side_pot_eligibility'] = {
      'rewardXp': 5,
      'family': 'decision',
      'options': [
        {
          ...w3Option('both_pots'),
          'repairLabels': ['Confused chip commitment eligibility'],
        },
        w3Option('main_pot_only', correct: true),
        {
          ...w3Option('side_pot_only'),
          'repairLabels': ['Confused chip commitment eligibility'],
        },
      ],
    };
    expectedComparison['first_table_guide_first_decision'] = {
      'rewardXp': 0,
      'family': 'decision',
      'options': [
        w3Option('fold'),
        {...w3Option('call'), 'quality': 'suboptimal'},
        w3Option('raise', correct: true),
      ],
    };
    expectedComparison['hand_rankings_compare_ace_straights'] = {
      'rewardXp': 7,
      'family': 'compare',
      'options': [
        w3Option('broadway', correct: true),
        w3Option('wheel'),
        w3Option('tie'),
      ],
    };
    expectedComparison['blinds_missing_post_amount'] = {
      'rewardXp': 5,
      'family': 'decision',
      'options': [
        for (final id in ['small_blind_only', 'big_blind_amount', 'both_posts'])
          {
            ...w3Option(id, correct: id == 'big_blind_amount'),
            'repairSeats': ['bb', 'sb'],
          },
      ],
    };
    expectedComparison['actions_call_chip_cost'] = {
      'rewardXp': 5,
      'family': 'decision',
      'options': [
        w3Option('free'),
        w3Option('match_bet', correct: true),
        w3Option('match_pot'),
      ],
    };
    expectedComparison['cards_ranks_suits_premium_decision'] = {
      'rewardXp': 5,
      'family': 'decision',
      'options': [
        {
          ...w3Option('call'),
          'quality': 'suboptimal',
          'repairLabels': ['Top starting pairs'],
        },
        {
          ...w3Option('raise', correct: true),
          'repairLabels': ['Top starting pairs'],
        },
        {
          ...w3Option('fold'),
          'repairLabels': ['Top starting pairs'],
        },
      ],
    };
    final w1Revision =
        jsonDecode(
              File('test/fixtures/act0_w1_revision_v1.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
    final metadataChanges = w1Revision.entries.where(
      (entry) => entry.value['tableMetadata'] != null,
    );
    expect(metadataChanges, hasLength(39));
    for (final revision in metadataChanges) {
      final change = revision.value['tableMetadata'];
      expect(
        historicalComparison[revision.key],
        change['current'],
        reason: revision.key,
      );
      historicalComparison[revision.key] = change['prior'];
    }
    expectedComparison['w4_price_find_bettor'] = {
      'rewardXp': 7,
      'family': 'decision',
      'options': [
        w3Option('bb', seat: 'bb'),
        w3Option('btn', seat: 'btn'),
        w3Option('co', seat: 'co', correct: true),
      ],
    };
    for (final (id, choices, correct) in [
      (
        'board_texture_basics_w5_texture_dry_value',
        ['check', 'two', 'six'],
        'two',
      ),
      (
        'board_texture_basics_w5_texture_wet_showdown',
        ['small', 'large', 'check'],
        'check',
      ),
      (
        'connected_boards_w5_connected_read_bet',
        ['fold', 'call', 'raise'],
        'fold',
      ),
    ]) {
      expectedComparison[id] = {
        'rewardXp': 8,
        'family': 'decision',
        'options': [
          for (final choice in choices)
            {
              ...w3Option(choice, correct: choice == correct),
              'repairCards': ['board_0', 'board_1', 'board_2'],
            },
        ],
      };
    }
    expectedComparison['w8_effective_stack_seat'] = {
      'rewardXp': 8,
      'family': 'compare',
      'options': [
        w3Option('co', seat: 'co'),
        w3Option('bb', seat: 'bb', correct: true),
        w3Option('sb', seat: 'sb'),
      ],
    };
    expectedComparison['w8_spr_value_size'] = {
      'rewardXp': 8,
      'family': 'sizing',
      'options': [
        {...w3Option('two'), 'quality': 'suboptimal'},
        w3Option('four', correct: true),
        w3Option('eight'),
      ],
    };
    expectedComparison['hand_rankings_find_the_match'] = {
      'rewardXp': 5,
      'family': 'decision',
      'options': [
        for (final choice in ['kings', 'queens', 'eights'])
          {
            ...w3Option(choice, correct: choice == 'eights'),
            'repairCards': ['board_0', 'board_1', 'board_2'],
          },
      ],
    };
    expectedComparison['blinds_pot_after_posts'] = {
      'rewardXp': 5,
      'family': 'decision',
      'options': [
        for (final choice in ['both', 'bb_only', 'equal_posts'])
          {
            ...w3Option(choice, correct: choice == 'both'),
            'repairLabels': ['Big blind'],
          },
      ],
    };
    expectedComparison['positions_read_first_check'] = {
      'rewardXp': 5,
      'family': 'decision',
      'options': [
        for (final choice in ['hj', 'bb', 'btn'])
          {
            ...w3Option(choice, correct: choice == 'bb'),
            'repairLabels': ['Hero on the Button'],
          },
      ],
    };
    expectedComparison['w4_purpose_collect_value'] = {
      'rewardXp': 7,
      'family': 'decision',
      'options': [
        for (final choice in ['bet_two', 'check', 'bet_four'])
          {
            ...w3Option(choice, correct: choice == 'bet_two'),
            'repairCards': ['board_0', 'board_1', 'board_2'],
          },
      ],
    };
    for (final entry in {...y5bNewChoicesV1, ...y5cNewChoicesV1}.entries) {
      expectedComparison[entry.key] = {
        'rewardXp': entry.value.isEmpty ? 6 : 8,
        'family': switch (entry.key) {
          'short_stack_spots_value_cap' ||
          'w7_read_visible_card_call' ||
          'w9_bubble_read_decision' => 'transfer',
          _ => entry.value.isEmpty ? 'learn' : 'decision',
        },
        'options': [
          for (final choice in entry.value)
            {
              ...w3Option(choice[0] as String, correct: choice[2] as bool),
              'quality': choice[3],
            },
        ],
      };
    }
    expectedComparison['w4_protection_small_denial'] = {
      'rewardXp': 7,
      'family': 'decision',
      'options': [
        for (final choice in ['check', 'bet_four', 'bet_two'])
          {
            ...w3Option(choice, correct: choice == 'bet_two'),
            if (choice == 'bet_four') 'quality': 'suboptimal',
            'repairCards': ['board_0', 'board_1', 'board_2'],
          },
      ],
    };
    expectedComparison['w1_shared_card_access'] = {
      'rewardXp': 5,
      'family': 'decision',
      'options': [
        for (final choice in ['private', 'shared', 'all'])
          {
            ...w3Option(choice, correct: choice == 'shared'),
            'repairCards': ['board_0', 'board_1', 'board_2'],
          },
      ],
    };
    expectedComparison['w1_chips_starting_pot'] = {
      'rewardXp': 5,
      'family': 'decision',
      'options': [
        for (final choice in ['only_big', 'both', 'only_small'])
          w3Option(choice, correct: choice == 'both'),
      ],
    };
    expectedComparison['w1_chips_matched_pot'] = {
      'rewardXp': 5,
      'family': 'decision',
      'options': [
        for (final choice in ['two_players', 'post_twice', 'total'])
          w3Option(choice, correct: choice == 'total'),
      ],
    };
    expectedComparison['w1_chips_read_middle'] = {
      'rewardXp': 5,
      'family': 'decision',
      'options': [
        for (final choice in ['pot', 'one_share', 'stack'])
          w3Option(choice, correct: choice == 'pot'),
      ],
    };
    expectedComparison.addAll(w11Wave4TableTruthContractV1());
    expectedComparison.addAll(w12Wave4TableTruthContractV1());
    for (final entry in [
      ...w11Wave4GradeCorrectionsV1.entries,
      ...w12Wave4GradeCorrectionsV1.entries,
    ]) {
      final task = historicalComparison[entry.key] as Map<String, dynamic>;
      final option = (task['options'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .singleWhere((option) => option['id'] == entry.value);
      expect(option['correct'], isFalse, reason: entry.key);
      expect(option['quality'], 'wrong', reason: entry.key);
      option['quality'] = 'suboptimal';
    }
    expectedComparison['w6_continuation_bet_value_size'] = {
      'rewardXp': 8,
      'family': 'decision',
      'options': [
        {...w3Option('bet_one_five'), 'quality': 'suboptimal'},
        w3Option('bet_six'),
        w3Option('bet_three', correct: true),
      ],
    };
    // The explicitly reordered W6 answers retain every choice field.
    for (final id in [
      'w6_table_bucket_notice',
      'w6_combo_weight_compare',
      'range_checkpoint_pressure',
    ]) {
      final row = expectedComparison[id] as Map<String, dynamic>;
      final options = row['options'] as List;
      final correct = options.indexWhere((option) => option['correct'] == true);
      expect(correct, isNonNegative, reason: id);
      options.add(options.removeAt(correct));
    }
    // W4's reviewed answer order is independent of the frozen identity fixture.
    for (final (id, correctId, index) in [
      ('w4_value_purpose', 'value', 2),
      ('w4_bad_price_fold', 'fold', 2),
      ('w4_checkpoint_table_price', 'call', 2),
      ('w4_bluff_purpose', 'bluff', 1),
      ('w4_value_missed', 'bet_half', 2),
      ('w4_bad_bluff', 'check', 1),
      ('w4_protection_check', 'free_card', 2),
    ]) {
      final options = (expectedComparison[id] as Map)['options'] as List;
      final correct = options.indexWhere((choice) => choice['id'] == correctId);
      expect(correct, isNonNegative, reason: id);
      options.insert(index, options.removeAt(correct));
    }
    expectedComparison['w4_value_worse_call_seat'] = {
      'rewardXp': 8,
      'family': 'decision',
      'options': [
        for (final choice in ['btn', 'bb', 'co'])
          {
            ...w3Option(choice, seat: choice, correct: choice == 'bb'),
            'repairCards': ['board_0', 'board_1', 'board_2'],
          },
      ],
    };
    expectedComparison['w4_bluff_target_seat'] = {
      'rewardXp': 8,
      'family': 'decision',
      'options': [
        for (final choice in ['btn', 'co', 'bb'])
          {
            ...w3Option(choice, seat: choice, correct: choice == 'bb'),
            'repairCards': ['board_0', 'board_1', 'board_2'],
          },
      ],
    };
    expectedComparison['w8_hero_stack_cap_seat'] = {
      'rewardXp': 8,
      'family': 'compare',
      'options': [
        for (final choice in ['hj', 'sb', 'bb'])
          w3Option(choice, seat: choice, correct: choice == 'hj'),
      ],
    };
    expectedComparison['w8_pot_bet_committed_seat'] = {
      'rewardXp': 8,
      'family': 'compare',
      'options': [
        for (final choice in ['co', 'bb', 'sb'])
          w3Option(choice, seat: choice, correct: choice == 'bb'),
      ],
    };
    expect(
      historicalComparison,
      expectedComparison,
      reason:
          'Only explicitly reviewed MAIN01, W01, W24, L1, L2, Q7, Q11 and the Worlds 2, 3, 6, 11 and 12 packets may '
          'differ. Other identity, XP, family, grading and repair fields stay pinned.',
    );
    const expectedAsmContracts = {
      'asm05_new_known_holes_turn_call_10': {
        'rewardXp': 0,
        'family': 'decision',
        'options': [
          {
            'id': 'fold',
            'correct': false,
            'quality': 'wrong',
            'seat': null,
            'repairSeats': [],
            'repairCards': [],
            'repairLabels': [],
          },
          {
            'id': 'call',
            'correct': true,
            'quality': 'correct',
            'seat': null,
            'repairSeats': [],
            'repairCards': [],
            'repairLabels': [],
          },
        ],
      },
      'asm05_new_known_holes_turn_call_40': {
        'rewardXp': 0,
        'family': 'decision',
        'options': [
          {
            'id': 'fold',
            'correct': true,
            'quality': 'correct',
            'seat': null,
            'repairSeats': [],
            'repairCards': [],
            'repairLabels': [],
          },
          {
            'id': 'call',
            'correct': false,
            'quality': 'wrong',
            'seat': null,
            'repairSeats': [],
            'repairCards': [],
            'repairLabels': [],
          },
        ],
      },
    };
    if (presentAdditions.isNotEmpty) {
      expect(
        presentAdditions,
        admittedAdditions,
        reason: 'The candidate must contain both exact ASM05 additions',
      );
      for (final id in admittedAdditions) {
        expect(contract[id], expectedAsmContracts[id], reason: id);
      }
    }
    final fingerprints = <String, Object?>{};
    final choiceIdentity = <String, Object?>{};
    for (final world in Act0ShellStateV1.sample.worlds) {
      for (final lesson in world.lessons) {
        for (final task in lesson.taskList) {
          final fingerprint = act0AuthoredSourceFingerprintV1(
            worldId: world.worldId,
            lessonId: lesson.lessonId,
            task: task,
          );
          expect(fingerprint, isNotNull, reason: task.taskId);
          fingerprints[task.taskId] = {
            'world_id': world.worldId,
            'lesson_id': lesson.lessonId,
            'fingerprint': fingerprint,
          };
          choiceIdentity[task.taskId] = [
            for (final option in task.runner.options)
              [
                option.id,
                option.label,
                option.isCorrect,
                option.quality.name,
                option.preferredLabel,
              ],
          ];
        }
      }
    }
    File(
      '${out.path}/source-fingerprints.json',
    ).writeAsStringSync(jsonEncode(fingerprints));
    File(
      '${out.path}/choice-identity.json',
    ).writeAsStringSync(jsonEncode(choiceIdentity));
    final snapshot = {
      for (final t in tasks)
        t.taskId: {
          'caption': t.runner.caption,
          'hint': t.runner.hint,
          'question': t.runner.question,
          'table': _table(t.runner.table),
          'teaching': [
            for (final step in t.runner.teachingSteps)
              {
                'title': step.title,
                'body': step.body,
                'table': step.table == null ? null : _table(step.table!),
                'seats': step.focusSeatIds,
                'cards': step.focusCardIds,
              },
          ],
          'options': [
            for (final o in t.runner.options)
              {
                'id': o.id,
                'label': o.label,
                'amount': o.amountLabel,
                'reason': o.feedbackReason,
                'preferred': o.preferredLabel,
              },
          ],
        },
    };
    File(
      '${out.path}/runtime-inputs.json',
    ).writeAsStringSync(jsonEncode(snapshot));
    final isCandidate = presentAdditions.isNotEmpty;
    final sourceReference = isCandidate
        ? const {
            'commit': '5b0dd2e300053e52b323e54df6c759ddb5f04b48',
            'state_sha256':
                'd9a78d57817c8eaef7dc1a376f53ade7774229be4a34063d5dc0cf152bb67221',
            'factory_sha256':
                'c9386ad268d84f7469727f6fb4dc4f6eb2e771fd8d3f91d4169d1d31f727016b',
          }
        : const {
            'commit': 'fa079b6c5880814e231981a7bd5ed97df192d215',
            'state_sha256':
                'e9f87d4bf73b75d77bd7b04ddf111cbf6b64e796259ffe42adadea9bbb3270e2',
            'factory_sha256': null,
          };
    final factory = File(
      'lib/ui_v2/act0_shell/act0_asm05_authored_decision_truth_v1.dart',
    );
    final producerReceipt = {
      'head': (Process.runSync('git', ['rev-parse', 'HEAD']).stdout as String)
          .trim(),
      'state_sha256': sha256
          .convert(
            File(
              'lib/ui_v2/act0_shell/act0_shell_state_v1.dart',
            ).readAsBytesSync(),
          )
          .toString(),
      'factory_sha256': isCandidate && factory.existsSync()
          ? sha256.convert(factory.readAsBytesSync()).toString()
          : null,
    };
    final artifactRecords = {
      for (final id in admittedAdditions)
        if (presentAdditions.contains(id))
          id: [
            contract[id],
            fingerprints[id],
            choiceIdentity[id],
            snapshot[id],
          ],
    };
    File('${out.path}/typed-cohort-v2.json').writeAsStringSync(
      jsonEncode({
        'schema': 2,
        'role': isCandidate ? 'candidate' : 'historical_baseline',
        'admitted_source_reference': sourceReference,
        'producer_receipt': producerReceipt,
        'historical_ids': baselineContract.keys.toList()..sort(),
        'new_authoring': [
          for (final world in Act0ShellStateV1.sample.worlds)
            for (final lesson in world.lessons)
              for (final task in lesson.taskList)
                if (presentAdditions.contains(task.taskId))
                  {
                    'task_id': task.taskId,
                    'world_id': world.worldId,
                    'lesson_id': lesson.lessonId,
                    'provenance': 'NEW_AUTHORING_ASM05',
                    'artifact_sha256': sha256
                        .convert(
                          utf8.encode(jsonEncode(artifactRecords[task.taskId])),
                        )
                        .toString(),
                    'source_binding_sha256': sha256
                        .convert(
                          utf8.encode(
                            jsonEncode([
                              sourceReference,
                              task.taskId,
                              artifactRecords[task.taskId],
                            ]),
                          ),
                        )
                        .toString(),
                  },
        ],
      }),
    );
    final failures = rows.where((r) => r.result == 'FAIL').toList();
    final byInvariant = <String, Set<String>>{};
    for (final r in failures) {
      byInvariant.putIfAbsent(r.invariant, () => <String>{}).add(r.taskId);
    }
    stdout.writeln(
      'TABLE_TRUTH tasks=${tasks.length} variants=${rows.map((r) => '${r.taskId}|${r.variant}').toSet().length} rows=${rows.length}',
    );
    stdout.writeln(
      jsonEncode({
        for (final e in byInvariant.entries) e.key: e.value.toList()..sort(),
      }),
    );
    if (Platform.environment['TABLE_TRUTH_CENSUS_ONLY'] != '1') {
      expect(
        failures.map((r) => r.key),
        isEmpty,
        reason: 'Confirmed invariants must have exact disposition',
      );
    }
  });
}

Map<String, Object?> _table(Act0TableStateV1 t) => {
  'scope': t.scope.name,
  'hero': t.heroCards.map(cardIdentity).toList(),
  'board': t.boardCards.map(cardIdentity).toList(),
  'street': t.streetLabel,
  'pot': t.potLabel,
  'call': t.toCallLabel,
  'center': t.centerLabel,
  'actor': t.activeSeatId,
  'heroSeat': t.heroSeatId,
  'focusSeats': t.highlightedSeatIds,
  'focusCards': t.highlightedCardIds,
  'trail': [
    for (final a in t.actionTrail) {'kind': a.kind.name, 'label': a.label},
  ],
  'seats': [
    for (final s in t.seats)
      {
        'id': s.seatId,
        'hero': s.isHero,
        'active': s.isActive,
        'inHand': s.isInHand,
        'folded': s.isFolded,
        'occupied': s.isOccupied,
        'acted': s.hasActed,
        'mode': s.cardsVisibleMode.name,
        'cards': s.holeCards.map(cardIdentity).toList(),
        'blind': s.blindAmountLabel,
        'currentBet': s.currentBetLabel,
        'bet': s.bet == null
            ? null
            : {
                'kind': s.bet!.kind.name,
                'label': s.bet!.label,
                'amount': s.bet!.amountLabel,
              },
      },
  ],
};
