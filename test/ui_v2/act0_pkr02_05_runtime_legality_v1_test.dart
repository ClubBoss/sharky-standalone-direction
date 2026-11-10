// Runtime fault-injection controls and explicitly named canonical-source cases.
// Widget evidence only; this is not a native-device or Human acceptance receipt.
// Original fixture baseline: 198fefc7. Runtime repair base: 724d569e.
// Exact composition/run receipt must be supplied by the sole Runner integrator.
//
// This exercises the real Act0LessonRunnerShellV1 option button, its emitted
// Act0CompletedDecisionV1 and its user_choice/decision_made/task_result events.
// It does not call the authored-correctness predicate as a legality oracle.
//
// Synthetic tables and options are labeled SYNTHETIC. In those negative cases
// the option
// deliberately contains a false author claim: isCorrect=true / quality=correct
// despite an impossible numeric amount. A failure proves that this runtime
// boundary trusts that malformed claim. It does NOT establish that an actual
// catalog task contains that defect, nor require a second poker engine.
// Rejection or withholding a correct result is acceptable for these narrow
// malformed-source falsifiers; full catalog DoD is separate.
//
// Oracle: ordinary no-limit hold'em, 0.5/1 BB blinds, no ante/rake/straddle.
// Every seat starts with 100 BB; stackLabel below is the exact amount remaining.
// Calls and raises in the trail are street-total commitments. Hero has enough
// chips for every full legal price, so no short-all-in exception applies.
// Minimum ordinary opening bet: 1 BB. Minimum unopened preflop raise-to: 2 BB.
// After BB bets 2 BB on flop, BTN has committed 0 and owes exactly 2 BB.
// Primary rule sources are in oracle_vectors_and_source_map.json.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

enum _Spot { flopBet, preflopOpen, flopCall }

const _beforeButton = <String>[
  'SB blind 0.5 BB',
  'BB blind 1 BB',
  'UTG folds',
  'HJ folds',
  'CO folds',
];

const _headsUpFlop = <String>[
  ..._beforeButton,
  'BTN raises 3 BB',
  'SB folds',
  'BB calls 3 BB',
];

const _heroCards = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: 'K', suit: 'd'),
];

const _flop = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h'),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'd'),
];

Act0TableStateV1 _table(_Spot spot, {String? heroStack}) {
  final preflop = spot == _Spot.preflopOpen;
  final facingBet = spot == _Spot.flopCall;
  final live = preflop
      ? const <String>{'btn', 'sb', 'bb'}
      : const <String>{'btn', 'bb'};
  final trail = preflop
      ? _beforeButton
      : <String>[
          ..._headsUpFlop,
          facingBet ? 'Flop: BB bets 2 BB' : 'Flop: BB checks',
        ];
  final behind = <String, String>{
    'utg': '100 BB',
    'hj': '100 BB',
    'co': '100 BB',
    'btn': heroStack ?? (preflop ? '100 BB' : '97 BB'),
    'sb': '99.5 BB',
    'bb': preflop ? '99 BB' : (facingBet ? '95 BB' : '97 BB'),
  };
  return Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: <Act0SeatStateV1>[
      for (final label in const <String>['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'])
        Act0SeatStateV1(
          seatId: label.toLowerCase(),
          seatLabel: label,
          displayName: label == 'BTN' ? 'Hero' : label,
          isHero: label == 'BTN',
          isDealerButton: label == 'BTN',
          isSmallBlind: label == 'SB',
          isBigBlind: label == 'BB',
          isActive: label == 'BTN',
          isInHand: live.contains(label.toLowerCase()),
          isFolded: !live.contains(label.toLowerCase()),
          stackLabel: behind[label.toLowerCase()],
          holeCards: label == 'BTN' ? _heroCards : const <Act0CardStateV1>[],
          cardsVisibleMode: label == 'BTN'
              ? Act0CardsVisibleModeV1.faceUp
              : Act0CardsVisibleModeV1.faceDown,
          currentBetLabel: preflop
              ? (label == 'SB' ? '0.5 BB' : (label == 'BB' ? '1 BB' : null))
              : (facingBet && label == 'BB' ? '2 BB' : null),
        ),
    ],
    heroCards: _heroCards,
    boardCards: preflop ? const <Act0CardStateV1>[] : _flop,
    streetLabel: preflop ? 'Preflop' : 'Flop',
    // Gross contributions: preflop 0.5+1; reached flop 0.5+3+3;
    // facing a flop bet 0.5+3+3+2. No uncalled refund is due here.
    potLabel: preflop
        ? 'Pot 1.5 BB'
        : (facingBet ? 'Pot 8.5 BB' : 'Pot 6.5 BB'),
    toCallLabel: preflop ? 'To call 1 BB' : (facingBet ? 'To call 2 BB' : ''),
    centerLabel: 'Synthetic 0.5/1 BB hand; no ante or rake',
    actionTrail: <Act0ActionTrailItemV1>[
      for (final label in trail) Act0ActionTrailItemV1(label: label),
    ],
    activeSeatId: 'btn',
    heroSeatId: 'btn',
    highlightedSeatIds: const <String>[],
    highlightedCardIds: const <String>[],
  );
}

Act0RunnerStateV1 _runner(_Spot spot, String amount, {String? heroStack}) {
  final action = switch (spot) {
    _Spot.flopBet => 'bet',
    _Spot.preflopOpen => 'raise',
    _Spot.flopCall => 'call',
  };
  final label = switch (spot) {
    _Spot.flopBet => 'Bet',
    _Spot.preflopOpen => 'Raise to',
    _Spot.flopCall => 'Call',
  };
  return Act0RunnerStateV1(
    lessonId: 'synthetic_pkr_${spot.name}_$amount',
    lessonTitle: 'Synthetic numeric legality probe',
    lessonSubtitle: 'Independent evidence fixture',
    beatIndex: 0,
    beatCount: 1,
    phase: Act0LessonPhaseV1.drill,
    caption: 'Synthetic table with complete contribution history.',
    hint: '',
    question: switch (spot) {
      _Spot.flopBet => 'Choose the minimum ordinary opening bet.',
      _Spot.preflopOpen => 'Choose the minimum legal opening raise-to total.',
      _Spot.flopCall => 'Call the full amount due.',
    },
    options: <Act0RunnerOptionV1>[
      Act0RunnerOptionV1(
        id: action,
        label: label,
        amountLabel: '$amount BB',
        isCorrect: true,
        preferredLabel: '$label $amount BB',
        quality: Act0FeedbackQualityV1.correct,
        feedbackTitle: 'Synthetic authored success marker',
        feedbackReason: 'Fixture claims this choice is correct.',
      ),
    ],
    feedbackTitle: '',
    feedbackReason: '',
    primaryCtaLabel: 'Continue',
    nextLessonId: null,
    returnTarget: 'learn',
    table: _table(spot, heroStack: heroStack),
  );
}

class _Observed {
  int backCalls = 0;
  int sizingConfirms = 0;
  final decisions = <Act0CompletedDecisionV1>[];
  final forwarded = <Act0RunnerOptionV1>[];
  final assistance = <String>[];
  final sink = Act0InMemoryTelemetrySinkV1();
  bool optionWasOffered = false;

  Map<String, int> get correctCredits => <String, int>{
    'completed_decision_correct': decisions.where((d) => d.isCorrect).length,
    'telemetry_correct': sink.events.where((event) {
      if (!const <String>{
        'user_choice',
        'decision_made',
        'task_result',
      }.contains(event.name)) {
        return false;
      }
      return event.fields['correct'] == true;
    }).length,
  };
}

Future<_Observed> _submit(
  WidgetTester tester,
  _Spot spot,
  String amount, {
  String? heroStack,
  bool sizing = false,
  List<String>? trailOverride,
  Act0RunnerStateV1? sourceRunner,
  String? sourceOptionId,
  String? sourceTaskId,
  Act0TaskFamilyV1? sourceTaskFamily,
}) async {
  final base = sourceRunner ?? _runner(spot, amount, heroStack: heroStack);
  final original = trailOverride == null
      ? base
      : base.copyWith(
          table: base.table.copyWith(
            actionTrail: [
              for (final label in trailOverride)
                Act0ActionTrailItemV1(label: label),
            ],
          ),
        );
  final chosen = sourceOptionId == null
      ? original.options.single
      : original.options.singleWhere((o) => o.id == sourceOptionId);
  final runner = sizing
      ? original.copyWith(
          sizingConfig: Act0SizingConfigV1(
            mode: Act0SizingUiModeV1.presetsOnly,
            presets: [
              Act0SizingPresetV1(
                id: chosen.id,
                label: 'Bet $amount BB',
                potFraction: double.parse(amount) / 6.5,
              ),
            ],
          ),
          selectedPresetId: chosen.id,
        )
      : original;
  final observed = _Observed();
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const <Locale>[Locale('en')],
      home: Scaffold(
        body: Act0LessonRunnerShellV1(
          key: ValueKey<String>(runner.lessonId),
          runner: runner,
          selectedWorldId: 'synthetic_pkr_oracle',
          selectedLessonId: runner.lessonId,
          selectedTaskId: sourceTaskId ?? runner.lessonId,
          selectedTaskFamily:
              sourceTaskFamily ??
              (sizing ? Act0TaskFamilyV1.sizing : Act0TaskFamilyV1.decision),
          telemetrySink: observed.sink,
          evidenceRunId: 'synthetic_pkr_runtime_evidence',
          // Production settled-mode seam isolates grading from animation time.
          // This is widget evidence, not native animation or device evidence.
          tableChoreographyMode: Act0TableChoreographyModeV1.settled,
          onBack: () {
            observed.backCalls++;
          },
          onContinueTheory: () {},
          onChooseOption: observed.forwarded.add,
          onChoiceAssistance: (value) => observed.assistance.add(value.name),
          onSelectSizingPreset: (_) {},
          onConfirmSizingPreset: () {
            observed.sizingConfirms++;
          },
          onCompletedDecision: observed.decisions.add,
          onContinueReview: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  final target = find.byKey(
    Key(
      sizing
          ? 'act0_shell_sizing_confirm_cta'
          : 'act0_shell_option_${chosen.id}',
    ),
  );
  observed.optionWasOffered = target.evaluate().isNotEmpty;
  if (observed.optionWasOffered) {
    expect(target, findsOneWidget);
    // This is an actual offered choice amount, not a toCallLabel mutation.
    if (!sizing && chosen.amountLabel.isNotEmpty) {
      expect(
        find.descendant(of: target, matching: find.text('$amount BB')),
        findsOneWidget,
      );
    }
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }
  print(
    'PKR0205_RUNNER ${jsonEncode(<String, Object?>{'source': sourceRunner == null ? 'synthetic' : 'canonical_task', 'fixture': runner.lessonId, 'option': chosen.id, 'amount': chosen.amountLabel, 'pot': runner.table.potLabel, 'to_call': runner.table.toCallLabel, 'offered': observed.optionWasOffered, 'forwarded': observed.forwarded.length, ...observed.correctCredits})}',
  );
  return observed;
}

void _setTestViewport(WidgetTester tester) => _setPkrEnReferenceV1(tester);

void main() {
  testWidgets(
    'canonical early fold offers genuine correct feedback without a stack guess',
    (tester) async {
      _setTestViewport(tester);
      final task = Act0ShellStateV1.sample.worlds
          .expand((w) => w.lessons)
          .expand((l) => l.taskList)
          .singleWhere((t) => t.taskId == 'fold_discipline_early_fold');
      final observed = await _submit(
        tester,
        _Spot.preflopOpen,
        '',
        sourceRunner: task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const [],
        ),
        sourceOptionId: 'fold',
        sourceTaskId: task.taskId,
        sourceTaskFamily: task.resolvedTaskFamily,
      );
      expect(observed.optionWasOffered, isTrue);
      expect(observed.forwarded.single.id, 'fold');
      expect(observed.decisions.single.isCorrect, isTrue);
      expect(
        find.byKey(const Key('act0_betting_price_unavailable')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'canonical early raise distractor keeps wrong teaching, not a legal bet',
    (tester) async {
      _setTestViewport(tester);
      final task = Act0ShellStateV1.sample.worlds
          .expand((w) => w.lessons)
          .expand((l) => l.taskList)
          .singleWhere((t) => t.taskId == 'apply_utg_fold');
      final observed = await _submit(
        tester,
        _Spot.preflopOpen,
        '',
        sourceRunner: task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const [],
        ),
        sourceOptionId: 'raise',
        sourceTaskId: task.taskId,
        sourceTaskFamily: task.resolvedTaskFamily,
      );
      expect(observed.optionWasOffered, isTrue);
      expect(observed.forwarded.single.id, 'raise');
      expect(observed.decisions.single.isCorrect, isFalse);
      expect(
        find.byKey(const Key('act0_betting_price_unavailable')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'real W1 check-definition question is not blocked by missing hand ledger',
    (tester) async {
      _setTestViewport(tester);
      final task = Act0ShellStateV1.sample.worlds
          .expand((w) => w.lessons)
          .expand((l) => l.taskList)
          .singleWhere((t) => t.taskId == 'actions_legal_context');
      final result = await _submit(
        tester,
        _Spot.flopBet,
        '',
        sourceRunner: task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const [],
        ),
        sourceTaskId: task.taskId,
        sourceOptionId: 'check',
      );
      expect(result.optionWasOffered, isTrue);
      expect(result.forwarded.single.id, 'check');
      expect(result.decisions.single.isCorrect, isTrue);
      expect(
        find.byKey(const Key('act0_betting_price_unavailable')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'real W1 wrong fold-definition answer still teaches without fake source',
    (tester) async {
      _setTestViewport(tester);
      final task = Act0ShellStateV1.sample.worlds
          .expand((w) => w.lessons)
          .expand((l) => l.taskList)
          .singleWhere((t) => t.taskId == 'actions_check_drill');
      final result = await _submit(
        tester,
        _Spot.flopBet,
        '',
        sourceRunner: task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const [],
        ),
        sourceTaskId: task.taskId,
        sourceOptionId: 'fold',
      );
      expect(result.optionWasOffered, isTrue);
      expect(result.forwarded.single.id, 'fold');
      expect(result.decisions.single.isCorrect, isFalse);
      expect(
        find.byKey(const Key('act0_betting_price_unavailable')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'real W4 half-pot arithmetic answer remains accessible without stack fiction',
    (tester) async {
      _setTestViewport(tester);
      final task = Act0ShellStateV1.sample.worlds
          .expand((w) => w.lessons)
          .expand((l) => l.taskList)
          .singleWhere((t) => t.taskId == 'w4_half_pot_bet');
      expect(task.runner.sizingConfig.isEnabled, isFalse);
      expect(task.runner.table.potLabel, 'Pot 6 BB');
      final observed = await _submit(
        tester,
        _Spot.flopBet,
        '',
        sourceRunner: task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const [],
        ),
        sourceTaskId: task.taskId,
        sourceTaskFamily: Act0TaskFamilyV1.sizing,
        sourceOptionId: 'three',
      );
      expect(observed.optionWasOffered, isTrue);
      expect(observed.forwarded.single.id, 'three');
      expect(observed.decisions.single.isCorrect, isTrue);
      expect(
        find.byKey(const Key('act0_betting_price_unavailable')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'real W4 incorrect pot fraction still teaches rather than blocking',
    (tester) async {
      _setTestViewport(tester);
      final task = Act0ShellStateV1.sample.worlds
          .expand((w) => w.lessons)
          .expand((l) => l.taskList)
          .singleWhere((t) => t.taskId == 'w4_pot_bet');
      final observed = await _submit(
        tester,
        _Spot.flopBet,
        '',
        sourceRunner: task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const [],
        ),
        sourceTaskId: task.taskId,
        sourceTaskFamily: Act0TaskFamilyV1.sizing,
        sourceOptionId: 'two',
      );
      expect(observed.optionWasOffered, isTrue);
      expect(observed.forwarded.single.id, 'two');
      expect(observed.decisions.single.isCorrect, isFalse);
      expect(
        find.byKey(const Key('act0_betting_price_unavailable')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'SYNTHETIC typed sizing with unknown or conflicting units is withheld',
    (tester) async {
      _setTestViewport(tester);
      for (final claim in [('0.5BB', ''), ('1 BB', '0.5 BB')]) {
        final runner = _runner(_Spot.flopBet, '0.5').copyWith(
          options: [
            Act0RunnerOptionV1(
              id: 'bet',
              label: claim.$1,
              amountLabel: claim.$2,
              isCorrect: true,
              preferredLabel: '1 BB',
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: 'Synthetic malformed sizing success',
              feedbackReason:
                  'Unknown or conflicting units cannot establish a wager.',
            ),
          ],
        );
        final observed = await _submit(
          tester,
          _Spot.flopBet,
          '0.5',
          sizing: true,
          sourceRunner: runner,
        );
        expect(observed.optionWasOffered, isTrue);
        expect(observed.sizingConfirms, 0);
        expect(observed.decisions, isEmpty);
        expect(
          find.byKey(const Key('act0_betting_price_unavailable')),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      }
    },
  );

  testWidgets(
    'canonical conceptual distractor keeps its authored feedback route',
    (tester) async {
      _setTestViewport(tester);
      final task = Act0ShellStateV1.sample.worlds
          .expand((w) => w.lessons)
          .expand((l) => l.taskList)
          .singleWhere(
            (t) => t.taskId == 'turn_river_changes_w5_street_repair',
          );
      final observed = await _submit(
        tester,
        _Spot.flopBet,
        '',
        sourceRunner: task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingSteps: const [],
        ),
        sourceTaskId: task.taskId,
        sourceOptionId: 'small_same_story',
      );
      expect(observed.optionWasOffered, isTrue);
      expect(observed.forwarded.single.id, 'small_same_story');
      expect(observed.decisions.single.isCorrect, isFalse);
      expect(
        find.byKey(const Key('act0_betting_price_unavailable')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'SYNTHETIC illegal wrong distractor retains teaching on valid source',
    (tester) async {
      _setTestViewport(tester);
      final runner = _runner(_Spot.preflopOpen, '1.5').copyWith(
        options: const [
          Act0RunnerOptionV1(
            id: 'raise',
            label: 'Raise to',
            amountLabel: '1.5 BB',
            isCorrect: false,
            preferredLabel: 'Raise to 2 BB',
            quality: Act0FeedbackQualityV1.wrong,
            feedbackTitle: 'Minimum full raise',
            feedbackReason:
                'With chips behind, the full opening raise is at least 2 BB.',
          ),
        ],
      );
      final observed = await _submit(
        tester,
        _Spot.preflopOpen,
        '1.5',
        sourceRunner: runner,
      );
      expect(observed.optionWasOffered, isTrue);
      expect(observed.forwarded, hasLength(1));
      expect(observed.decisions.single.isCorrect, isFalse);
      expect(observed.correctCredits, {
        'completed_decision_correct': 0,
        'telemetry_correct': 0,
      });
      expect(
        find.byKey(const Key('act0_betting_price_unavailable')),
        findsNothing,
      );
    },
  );

  testWidgets(
    'real authored calls retain their different strategic grades and once-only callbacks',
    (tester) async {
      _setTestViewport(tester);
      final tasks = Act0ShellStateV1.sample.worlds
          .expand((w) => w.lessons)
          .expand((l) => l.taskList);
      for (final amount in [10, 40]) {
        final task = tasks.singleWhere(
          (t) => t.taskId == 'asm05_new_known_holes_turn_call_$amount',
        );
        final call = task.runner.options.singleWhere((o) => o.label == 'Call');
        final observed = await _submit(
          tester,
          _Spot.flopCall,
          '$amount',
          sourceRunner: task.runner.copyWith(
            phase: Act0LessonPhaseV1.drill,
            teachingSteps: const [],
          ),
          sourceOptionId: call.id,
        );
        expect(observed.forwarded.single.id, call.id);
        expect(observed.decisions.single.isCorrect, amount == 10);
        expect(observed.assistance, ['none']);
        await tester.tap(find.byKey(Key('act0_shell_option_${call.id}')));
        await tester.pumpAndSettle();
        expect(observed.decisions, hasLength(1));
        expect(observed.forwarded, hasLength(1));
      }
    },
  );

  testWidgets(
    'real incomplete W4 source withholds both correct and wrong answers without error debt',
    (tester) async {
      _setTestViewport(tester);
      final task = Act0ShellStateV1.sample.worlds
          .expand((w) => w.lessons)
          .expand((l) => l.taskList)
          .singleWhere((t) => t.taskId == 'w4_big_price_marginal_fold');
      for (final option in task.runner.options) {
        final amount = option.amountLabel.split(' ').first;
        final observed = await _submit(
          tester,
          _Spot.flopCall,
          amount,
          sourceRunner: task.runner.copyWith(
            phase: Act0LessonPhaseV1.drill,
            teachingSteps: const [],
          ),
          sourceOptionId: option.id,
        );
        expect(observed.optionWasOffered, isTrue);
        expect(observed.forwarded, isEmpty);
        expect(observed.decisions, isEmpty);
        expect(observed.assistance, isEmpty);
        expect(
          observed.sink.events.where(
            (e) => [
              'user_choice',
              'decision_made',
              'task_result',
            ].contains(e.name),
          ),
          isEmpty,
        );
        expect(
          find.byKey(const Key('act0_betting_price_unavailable')),
          findsOneWidget,
        );
        // The previous notice must expire before the next genuine pointer tap.
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      }
    },
  );

  testWidgets(
    'SYNTHETIC missing prefix withholds grading without consuming the attempt',
    (tester) async {
      _setTestViewport(tester);
      final observed = await _submit(
        tester,
        _Spot.flopBet,
        '1',
        trailOverride: const ['Flop: BB checks'],
      );
      expect(observed.optionWasOffered, isTrue);
      expect(observed.forwarded, isEmpty);
      expect(observed.decisions, isEmpty);
      expect(observed.correctCredits, <String, int>{
        'completed_decision_correct': 0,
        'telemetry_correct': 0,
      });
      expect(
        find.byKey(const Key('act0_betting_price_unavailable')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();
      expect(observed.backCalls, 1);
    },
  );

  testWidgets('SYNTHETIC controls: legal bet 1, open 2 and full call 2', (
    tester,
  ) async {
    _setTestViewport(tester);
    for (final probe in const <(_Spot, String)>[
      (_Spot.flopBet, '1'),
      (_Spot.preflopOpen, '2'),
      (_Spot.flopCall, '2'),
    ]) {
      final observed = await _submit(tester, probe.$1, probe.$2);
      expect(observed.optionWasOffered, isTrue);
      expect(observed.forwarded, hasLength(1));
      expect(observed.correctCredits, <String, int>{
        'completed_decision_correct': 1,
        'telemetry_correct': 3,
      });
    }
  });

  for (final probe in const <(_Spot, String, String)>[
    (_Spot.flopBet, '0.5', 'ordinary bet 0.5 BB is below the 1 BB minimum'),
    (
      _Spot.preflopOpen,
      '1.5',
      'ordinary open 1.5 BB is below the 2 BB minimum',
    ),
    (_Spot.flopCall, '1', 'offered call 1 BB cannot cover the actual 2 BB due'),
  ]) {
    testWidgets('SYNTHETIC rejection: ${probe.$3}', (tester) async {
      _setTestViewport(tester);
      final observed = await _submit(tester, probe.$1, probe.$2);
      expect(observed.forwarded, isEmpty);
      expect(observed.decisions, isEmpty);
      expect(
        find.byKey(const Key('act0_betting_price_unavailable')),
        findsOneWidget,
      );
      // A malformed source answer neither consumes the attempt nor traps Back.
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();
      expect(observed.backCalls, 1);
      expect(
        observed.correctCredits,
        <String, int>{'completed_decision_correct': 0, 'telemetry_correct': 0},
        reason:
            '${probe.$3}; a malformed authored correctness flag must not '
            'become a correct runtime learning result. This synthetic boundary '
            'test makes no claim about catalog prevalence.',
      );
    });
  }
  testWidgets('SYNTHETIC short-all-in controls remain actionable', (
    tester,
  ) async {
    _setTestViewport(tester);
    for (final probe in const <(_Spot, String, String)>[
      (_Spot.flopBet, '0.5', '0.5 BB'),
      (_Spot.preflopOpen, '1.5', '1.5 BB'),
      (_Spot.flopCall, '0.5', '0.5 BB'),
    ]) {
      final observed = await _submit(
        tester,
        probe.$1,
        probe.$2,
        heroStack: probe.$3,
      );
      expect(observed.optionWasOffered, isTrue);
      expect(observed.forwarded, hasLength(1));
      expect(observed.decisions.single.isCorrect, isTrue);
    }
  });

  testWidgets(
    'SYNTHETIC sizing submit also rejects malformed authored success',
    (tester) async {
      _setTestViewport(tester);
      final invalid = await _submit(tester, _Spot.flopBet, '0.5', sizing: true);
      expect(invalid.optionWasOffered, isTrue);
      expect(invalid.sizingConfirms, 0);
      expect(invalid.decisions, isEmpty);
      expect(invalid.correctCredits, <String, int>{
        'completed_decision_correct': 0,
        'telemetry_correct': 0,
      });
      expect(
        find.byKey(const Key('act0_betting_price_unavailable')),
        findsOneWidget,
      );
    },
  );
  testWidgets('SYNTHETIC legal sizing submit preserves callback and evidence', (
    tester,
  ) async {
    _setTestViewport(tester);
    final valid = await _submit(tester, _Spot.flopBet, '1', sizing: true);
    expect(valid.optionWasOffered, isTrue);
    expect(valid.sizingConfirms, 1);
    expect(valid.decisions.single.isCorrect, isTrue);
    expect(
      valid.decisions.single.decisionKind,
      Act0CompletedDecisionKindV1.sizing,
    );
    expect(valid.correctCredits, <String, int>{
      'completed_decision_correct': 1,
      'telemetry_correct': 3,
    });
  });
  testWidgets(
    'SYNTHETIC missing call display keeps real submission and attempt scope',
    (tester) async {
      _setTestViewport(tester);
      const runId = 'synthetic_pkr_missing_display_evidence';
      const worldId = 'synthetic_pkr_oracle';
      const lessonId = 'synthetic_pkr_missing_display_call';
      const valid = Act0RunnerOptionV1(
        id: 'call',
        label: 'Call',
        amountLabel: '1 BB',
        isCorrect: true,
        preferredLabel: 'Call 1 BB',
        quality: Act0FeedbackQualityV1.correct,
        feedbackTitle: 'Synthetic legal call',
        feedbackReason: 'Explicit ordinary 0.5/1 BB source.',
      );
      const malformed = Act0RunnerOptionV1(
        id: 'call_bad',
        label: 'Call',
        amountLabel: '1.5 BB',
        isCorrect: true,
        preferredLabel: 'Call 1.5 BB',
        quality: Act0FeedbackQualityV1.correct,
        feedbackTitle: 'Synthetic malformed authored success',
        feedbackReason:
            'Numeric contradiction must be withheld before grading.',
      );
      final runner = _runner(_Spot.preflopOpen, '1').copyWith(
        lessonId: lessonId,
        question: 'Call the full amount due.',
        options: const [valid, malformed],
        table: _table(_Spot.preflopOpen).copyWith(toCallLabel: ''),
      );
      final observed = _Observed();
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: const <Locale>[Locale('en')],
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              key: const ValueKey('synthetic_missing_display_same_runner'),
              runner: runner,
              selectedWorldId: worldId,
              selectedLessonId: lessonId,
              selectedTaskId: lessonId,
              selectedTaskFamily: Act0TaskFamilyV1.decision,
              evidenceRunId: runId,
              telemetrySink: observed.sink,
              onBack: () {
                observed.backCalls++;
              },
              onContinueTheory: () {},
              onChooseOption: observed.forwarded.add,
              onCompletedDecision: observed.decisions.add,
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Wait for normal production choreography; never force readiness.
      final beats =
          act0TableChoreographyPlanForTableV1(runner.table)?.beats.length ?? 0;
      for (var beat = 0; beat <= beats; beat++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpAndSettle();
      final mountedRunner = tester.state(find.byType(Act0LessonRunnerShellV1));
      final badButton = find.byKey(const Key('act0_shell_option_call_bad'));
      final validButton = find.byKey(const Key('act0_shell_option_call'));
      expect(badButton, findsOneWidget);
      expect(validButton, findsOneWidget);
      await tester.ensureVisible(badButton);
      await tester.tap(badButton);
      await tester.pumpAndSettle();
      expect(observed.decisions, isEmpty);
      expect(observed.forwarded, isEmpty);
      expect(observed.correctCredits, {
        'completed_decision_correct': 0,
        'telemetry_correct': 0,
      });
      expect(
        find.byKey(const Key('act0_betting_price_unavailable')),
        findsOneWidget,
      );
      expect(
        identical(
          tester.state(find.byType(Act0LessonRunnerShellV1)),
          mountedRunner,
        ),
        isTrue,
      );
      // The rejected tap must not consume attempt 1 in this same mounted scope.
      // Let the production feedback expire before tapping the covered option.
      final feedback = tester.widget<SnackBar>(find.byType(SnackBar));
      await tester.pump(feedback.duration);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_betting_price_unavailable')),
        findsNothing,
      );
      await tester.ensureVisible(validButton);
      await tester.tap(validButton);
      await tester.pumpAndSettle();
      expect(observed.forwarded, hasLength(1));
      expect(observed.decisions, hasLength(1));
      final decision = observed.decisions.single;
      expect(decision.selectedId, 'call');
      expect(decision.expectedId, 'call');
      expect(decision.isCorrect, isTrue);
      expect(decision.decisionKind, Act0CompletedDecisionKindV1.actionList);
      expect(decision.assistanceKind.name, 'none');
      expect(
        decision.attemptKey,
        'v2|$runId|$worldId|$lessonId|$lessonId|actionList|call|1',
      );
      expect(observed.correctCredits, {
        'completed_decision_correct': 1,
        'telemetry_correct': 3,
      });
      await tester.tap(validButton);
      await tester.pumpAndSettle();
      expect(
        observed.decisions,
        hasLength(1),
        reason: 'Submitted attempt must not complete twice.',
      );
      expect(observed.forwarded, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );
}

// Only the admitted EN widget reference; no production MediaQuery override.
void _setPkrEnReferenceV1(WidgetTester tester) {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.localeTestValue = const Locale('en');
  tester.platformDispatcher.localesTestValue = const <Locale>[Locale('en')];
  tester.platformDispatcher.textScaleFactorTestValue = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearLocaleTestValue();
    tester.platformDispatcher.clearLocalesTestValue();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}
