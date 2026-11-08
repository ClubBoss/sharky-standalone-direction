import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_solver/poker_solver.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_causal_feedback_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import '../support/act0_alternative_answer_oracle_v1.dart';

final _sources = [
  for (final w in Act0ShellStateV1.sample.worlds)
    for (final l in w.lessons)
      for (final t in l.taskList)
        (world: w.worldId, lesson: l.lessonId, task: t),
];
final _assessed = _sources
    .where(
      (s) =>
          s.task.phase != Act0LessonPhaseV1.theory &&
          s.task.runner.options.isNotEmpty,
    )
    .toList();
Act0LessonTaskV1 _task(String id) =>
    _sources.singleWhere((s) => s.task.taskId == id).task;
Act0RunnerOptionV1 _choice(String task, String choice) =>
    _task(task).runner.options.singleWhere((o) => o.id == choice);

void main() {
  test(
    'ASM03 finite source-choice-feedback trace across every assessed family',
    () {
      expect(_sources.length, 367);
      expect(_assessed.length, 275);
      final rows = <Map<String, Object?>>[];
      final facts = <Map<String, Object?>>[];
      final families = <String, int>{};
      for (final s in _assessed) {
        final task = s.task;
        families.update(
          task.resolvedTaskFamily.name,
          (n) => n + 1,
          ifAbsent: () => 1,
        );
        for (final choice in task.runner.options) {
          final runner = task.runner.copyWith(
            phase: Act0LessonPhaseV1.review,
            selectedOptionId: choice.id,
          );
          final feedback = Act0CausalFeedbackV1.fromStructured(
            quality: runner.reviewQuality,
            authoredReason: runner.reviewReason,
            chosenAction: runner.reviewSelectedLabel,
            preferredAction: runner.reviewPreferredLabel,
            betterAction: runner.reviewBetterLabel,
          );
          final key = '${task.taskId}/${choice.id}';
          expect(feedback.chosenAction, choice.label, reason: key);
          expect(feedback.whyChosen, choice.feedbackReason, reason: key);
          expect(feedback.classification, switch (choice.quality) {
            Act0FeedbackQualityV1.correct => 'correct',
            Act0FeedbackQualityV1.wrong => 'incorrect',
            Act0FeedbackQualityV1.suboptimal => 'suboptimal',
          }, reason: key);
          final fact = asm03AnswerFact(task, choice);
          final row = <String, Object?>{
            'world': s.world,
            'lesson': s.lesson,
            'task': task.taskId,
            'family': task.resolvedTaskFamily.name,
            'choice': choice.id,
            'label': choice.label,
            'source_grade': choice.quality.name,
            'source_correct': choice.isCorrect, 'reason': choice.feedbackReason,
            'projected_grade': feedback.classification,
            'projected_reason': feedback.whyChosen,
            'oracle_answer_supported': fact?.supported,
            'oracle_basis': fact?.basis,
            'oracle_rationale': fact?.reason,
            // Answer truth alone cannot prove wrong vs suboptimal. Missing oracle
            // stays explicit; a green projection test must never award the DoD.
            'full_grade_proven': false,
            'status': fact == null
                ? 'NEEDS_AUTHOR_OR_ORACLE'
                : 'FACT_CHECKED_RUBRIC_PENDING',
          };
          rows.add(row);
          if (fact != null) {
            facts.add(row);
            expect(
              choice.isCorrect,
              fact.supported,
              reason: '$key: ${fact.reason}',
            );
          }
        }
      }
      expect(rows.length, 712);
      expect(families, {
        'decision': 166,
        'transfer': 72,
        'repair': 13,
        'review': 9,
        'compare': 7,
        'counting': 4,
        'sizing': 3,
        'recognition': 1,
      });
      expect(facts.length, greaterThan(100));
      final dir = Directory('output/asm03')..createSync(recursive: true);
      File('${dir.path}/source-choice-feedback.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert({
          'tasks': 367,
          'assessed': 275,
          'alternatives': 712,
          'families': families,
          'fact_checked_alternatives': facts.length,
          'full_grade_proven': 0,
          'rows': rows,
        }),
      );
    },
  );

  test(
    'ASM03 wrong setup distractor actually contradicts the folded CO source',
    () {
      final t = _task('first_table_guide_one_clear_choice');
      final o = _choice(t.taskId, 'co_still_acting');
      expect(
        t.runner.table.seats.singleWhere((s) => s.seatId == 'co').isFolded,
        isTrue,
      );
      expect(asm03AnswerFact(t, o)!.supported, isFalse);
      expect(o.feedbackReason, contains('not still acting'));
    },
  );

  test('ASM03 an internally consistent false grade fails the factual oracle', () {
    final t = _task('first_table_guide_one_clear_choice');
    const forged = Act0RunnerOptionV1(
      id: 'co_still_acting',
      label: 'CO/cutoff already folded, so You at BTN act next',
      isCorrect: false,
      preferredLabel: 'You are BTN, blinds are posted, and no board is out yet',
      quality: Act0FeedbackQualityV1.wrong,
      feedbackTitle: 'Name the full setup.',
      feedbackReason: 'CO/cutoff already folded and action is on You now.',
    );
    expect(act0RunnerOptionIsAuthoredCorrectV1(forged), isFalse);
    expect(
      asm03AnswerFact(t, forged)!.supported,
      isTrue,
      reason:
          'All grading flags can agree while the alleged wrong statement is true.',
    );
  });

  test(
    'ASM03 stable IDs and green flags cannot make false public labels true',
    () {
      const forgedCall = Act0RunnerOptionV1(
        id: 'check',
        label: 'Call',
        isCorrect: true,
        preferredLabel: 'Call',
        quality: Act0FeedbackQualityV1.correct,
        feedbackTitle: 'Correct',
        feedbackReason: 'Calling is the answer.',
      );
      expect(act0RunnerOptionIsAuthoredCorrectV1(forgedCall), isTrue);
      expect(
        asm03AnswerFact(_task('actions_check_drill'), forgedCall)!.supported,
        isFalse,
      );
      const forgedCount = Act0RunnerOptionV1(
        id: 'sixteen',
        label: '6 combos',
        isCorrect: true,
        preferredLabel: '6 combos',
        quality: Act0FeedbackQualityV1.correct,
        feedbackTitle: 'Correct',
        feedbackReason: 'Six combos.',
      );
      expect(act0RunnerOptionIsAuthoredCorrectV1(forgedCount), isTrue);
      expect(
        asm03AnswerFact(_task('w6_ak_combos'), forgedCount)!.supported,
        isFalse,
      );
    },
  );

  test('ASM03 straight out explanation separates private and board cards', () {
    final t = _task('outs_improvement_w5_straight_out');
    expect(t.runner.table.boardCards.map((c) => c.rank), ['8', '7', '2']);
    expect(t.runner.table.heroCards.map((c) => c.rank), ['6', '5']);
    expect(
      asm03StraightCompletingRanks([
        ...t.runner.table.heroCards,
        ...t.runner.table.boardCards,
      ]),
      {4, 9},
    );
    expect(
      _choice(t.taskId, 'nine').feedbackReason,
      contains('between your hand and the board'),
    );
    expect(
      _choice(t.taskId, 'nine').feedbackReason,
      isNot(contains('5-6-7-8 on board')),
    );
  });

  test(
    'ASM03 shared pair is a made hand even when Hero did not pair a hole card',
    () {
      final t = _task('w6_turn_pressure_shift_transfer');
      final hand = Hand.solveHand(
        [
          ...t.runner.table.heroCards,
          ...t.runner.table.boardCards,
        ].map(asm03Card).toList(),
      );
      expect(hand.name, 'Pair');
      expect(
        _choice(t.taskId, 'bet_value').feedbackReason,
        contains('shared pair of twos'),
      );
      expect(
        _choice(t.taskId, 'bet_value').feedbackReason,
        isNot(contains('no made hand')),
      );
    },
  );

  test(
    'ASM03 missed J-T is not zero equity: legal backdoor straight beats aces',
    () {
      final t = _task('w6_missed_dry_board');
      final board = [...t.runner.table.boardCards.map(asm03Card), 'Qh', '9h'];
      final hero = Hand.solveHand([
        ...t.runner.table.heroCards.map(asm03Card),
        ...board,
      ]);
      final villain = Hand.solveHand(['As', 'Ad', ...board]);
      expect(
        {
          ...t.runner.table.heroCards.map(asm03Card),
          'As',
          'Ad',
          ...board,
        }.length,
        9,
      );
      expect(hero.name, 'Straight');
      expect(Hand.winners([hero, villain]), [hero]);
      expect(
        _choice(t.taskId, 'bluff').feedbackReason,
        isNot(contains('no equity')),
      );
      expect(
        _choice(t.taskId, 'bluff').feedbackReason,
        contains('no pair or immediate draw'),
      );
    },
  );

  test('ASM03 reports source blockers without requiring them to persist', () {
    final qjs = _task('hand_discipline_buckets_borderline');
    final turn = _task('w6_turn_shift_bucket');
    final wet = _task('w6_wet_board_repair');
    final blockers = [
      if (qjs.runner.question.contains('QJs') &&
          qjs.runner.table.heroCards.map((c) => c.suit).toSet().length == 2)
        {
          'task': qjs.taskId,
          'choices': qjs.runner.options.map((o) => o.id).toList(),
          'source_fact':
              'Question says QJs; actual private cards Qh Js are offsuit.',
          'smallest_owner_decision':
              'Confirm QJs with a matching suit, or QJo with a newly justified bucket; do not guess the intended hand.',
        },
      if (turn.runner.caption.toLowerCase().contains('turn') &&
          turn.runner.table.boardCards.length == 3)
        {
          'task': turn.taskId,
          'choices': turn.runner.options.map((o) => o.id).toList(),
          'source_fact':
              'Caption asserts a paired brick turn; displayed board is 8h 7h 6c with Qh Qs, still a flop.',
          'smallest_owner_decision':
              'Supply intended Hero cards and fourth board card plus why the bluff candidate loses pressure.',
        },
      if (wet.runner.caption.toLowerCase().contains('turn') &&
          wet.runner.table.boardCards.length == 3)
        {
          'task': wet.taskId,
          'choices': wet.runner.options.map((o) => o.id).toList(),
          'source_fact':
              'Caption/feedback asserts a connected turn and one-pair thin value; displayed Kd Qc on 8h 7h 6c is unpaired on the flop.',
          'smallest_owner_decision':
              'Supply intended flop-to-turn snapshot and Hero hand; no invented sequence.',
        },
    ];
    final dir = Directory('output/asm03')..createSync(recursive: true);
    File(
      '${dir.path}/source-blockers.json',
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(blockers));
  });

  test('ASM03 price and pair alone cannot establish the authored fold grade', () {
    final task = _task('w4_big_price_marginal_fold');
    // Deliberately hypothetical, legal countermodels. The task does not name
    // either range. No claim that these are authored opponents or real history.
    final versusValue = asm03RiverCheckdownEquity(task.runner.table, [
      'Ac',
      'Qd',
    ]);
    final versusBluff = asm03RiverCheckdownEquity(task.runner.table, [
      '7c',
      '6c',
    ]);
    expect(versusValue, lessThan(6 / (9 + 6 + 6)));
    expect(versusBluff, greaterThan(6 / (9 + 6)));
    // Both pot conventions lead to opposite calls under these two ranges.
    // Author must supply a range/profile and price convention before grading
    // strategic alternatives. A hand label is not an independent EV oracle.
    File('output/asm03/price-countermodels.json').writeAsStringSync(
      jsonEncode({
        'task': task.taskId,
        'choices': task.runner.options.map((o) => o.id).toList(),
        'hero': task.runner.table.heroCards.map(asm03Card).toList(),
        'board': task.runner.table.boardCards.map(asm03Card).toList(),
        'hypothetical_value': ['Ac', 'Qd'],
        'value_equity': versusValue,
        'hypothetical_bluff': ['7c', '6c'],
        'bluff_equity': versusBluff,
        'pot_before_bet_threshold': 6 / (9 + 6 + 6),
        'pot_including_bet_threshold': 6 / (9 + 6),
        'evidence_kind':
            'HYPOTHETICAL_CHECKDOWN_COUNTEREXAMPLES_NOT_SOURCE_HISTORY',
        'smallest_owner_decision':
            'Provide intended betting range/profile, future-action assumptions and whether displayed Pot includes the current bet.',
      }),
    );
  });

  test(
    'ASM03 changed explanations retain old history but cannot certify current source',
    () {
      // Frozen from 6bb24d74aeaedd146e91036014ac14f53a74970d before fixes.
      // Synthetic compatibility fixtures, never represented as real user history.
      final old =
          jsonDecode(
                File(
                  'test/ui_v2/fixtures/asm03_base_source_fingerprints_v1.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      for (final entry in old.entries) {
        final s = _sources.singleWhere((s) => s.task.taskId == entry.key);
        final choice = s.task.runner.options.first;
        final record = _record(
          s.world,
          s.lesson,
          s.task,
          choice,
          entry.value as String,
          Act0DecisionAssistanceV1.none,
        );
        final restored = Act0LearningEvidenceRecordV1.tryParse(
          record.toPayload(),
        );
        expect(restored, isNotNull);
        expect(restored!.toPayload(), record.toPayload());
        expect(
          act0CurrentAuthoredSourceProofForTaskV1(
            record: restored,
            worldId: s.world,
            lessonId: s.lesson,
            task: s.task,
          ),
          isNull,
          reason:
              '${entry.key}: old source is readable history, not current validation.',
        );
      }
    },
  );

  test(
    'ASM03 correct with help or unknown assistance is never independent proof',
    () {
      final s = _sources.singleWhere(
        (s) => s.task.taskId == 'actions_check_drill',
      );
      final choice = s.task.runner.options.singleWhere((o) => o.id == 'check');
      final fingerprint = act0AuthoredSourceFingerprintV1(
        worldId: s.world,
        lessonId: s.lesson,
        task: s.task,
      )!;
      for (final help in Act0DecisionAssistanceV1.values) {
        final record = _record(
          s.world,
          s.lesson,
          s.task,
          choice,
          fingerprint,
          help,
        );
        expect(
          record.isIndependentCorrect,
          help == Act0DecisionAssistanceV1.none,
        );
        final restored = Act0LearningEvidenceRecordV1.tryParse(
          record.toPayload(),
        )!;
        expect(restored.assistanceKind, help);
        expect(
          restored.isIndependentCorrect,
          help == Act0DecisionAssistanceV1.none,
        );
      }
    },
  );
}

Act0LearningEvidenceRecordV1 _record(
  String world,
  String lesson,
  Act0LessonTaskV1 task,
  Act0RunnerOptionV1 choice,
  String fingerprint,
  Act0DecisionAssistanceV1 help,
) => Act0LearningEvidenceRecordV1(
  recordId: 'fixture:${task.taskId}:${choice.id}',
  createdOrder: 1,
  worldId: world,
  lessonId: lesson,
  taskId: task.taskId,
  choiceId: choice.id,
  expectedChoiceId: task.runner.options.firstWhere((o) => o.isCorrect).id,
  isCorrect: choice.isCorrect,
  errorType: choice.isCorrect ? 'none' : 'missed_action_read',
  repairFocusId: '',
  skillAtomId: task.taskId,
  decisionTimeBucket: '3_to_10s',
  resultKind: choice.isCorrect ? 'correct' : 'incorrect',
  assistanceKind: help,
  authoredSourceFingerprint: fingerprint,
);
