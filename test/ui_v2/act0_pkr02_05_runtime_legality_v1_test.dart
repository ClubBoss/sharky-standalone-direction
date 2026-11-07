// Independent SYNTHETIC runtime fault-injection evidence. Not production.
// Original fixture baseline: 198fefc7. Runtime repair base: 724d569e.
// Exact composition/run receipt must be supplied by the sole Runner integrator.
//
// This exercises the real Act0LessonRunnerShellV1 option button, its emitted
// Act0CompletedDecisionV1 and its user_choice/decision_made/task_result events.
// It does not call the authored-correctness predicate as a legality oracle.
//
// Every table and option here is synthetic. In the negative cases the option
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
}) async {
  final base = _runner(spot, amount, heroStack: heroStack);
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
  final runner = sizing
      ? original.copyWith(
          sizingConfig: Act0SizingConfigV1(
            mode: Act0SizingUiModeV1.presetsOnly,
            presets: [
              Act0SizingPresetV1(
                id: original.options.single.id,
                label: 'Bet $amount BB',
                potFraction: double.parse(amount) / 6.5,
              ),
            ],
          ),
          selectedPresetId: original.options.single.id,
        )
      : original;
  final observed = _Observed();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Act0LessonRunnerShellV1(
          key: ValueKey<String>(runner.lessonId),
          runner: runner,
          selectedWorldId: 'synthetic_pkr_oracle',
          selectedLessonId: runner.lessonId,
          selectedTaskId: runner.lessonId,
          selectedTaskFamily: Act0TaskFamilyV1.decision,
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
          : 'act0_shell_option_${runner.options.single.id}',
    ),
  );
  observed.optionWasOffered = target.evaluate().isNotEmpty;
  if (observed.optionWasOffered) {
    expect(target, findsOneWidget);
    // This is an actual offered choice amount, not a toCallLabel mutation.
    if (!sizing) {
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
    'SYNTHETIC_PKR0205_RUNTIME ${jsonEncode(<String, Object?>{'fixture': runner.lessonId, 'amount': runner.options.single.amountLabel, 'pot': runner.table.potLabel, 'to_call': runner.table.toCallLabel, 'offered': observed.optionWasOffered, 'forwarded': observed.forwarded.length, ...observed.correctCredits})}',
  );
  return observed;
}

void _setTestViewport(WidgetTester tester) {
  // Owner-authorized EN 393x852 reference viewport; still widget, not native.
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('SYNTHETIC missing prefix does not block an unproved source', (
    tester,
  ) async {
    _setTestViewport(tester);
    final observed = await _submit(
      tester,
      _Spot.flopBet,
      '1',
      trailOverride: const ['Flop: BB checks'],
    );
    expect(observed.optionWasOffered, isTrue);
    expect(observed.forwarded, hasLength(1));
    expect(observed.decisions, hasLength(1));
    expect(observed.correctCredits, <String, int>{
      'completed_decision_correct': 1,
      'telemetry_correct': 3,
    });
    expect(
      find.byKey(const Key('act0_betting_price_unavailable')),
      findsNothing,
    );
  });

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
}
