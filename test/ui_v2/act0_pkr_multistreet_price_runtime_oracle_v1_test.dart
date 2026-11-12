// SYNTHETIC authored histories/cards, not catalog, native or personal-hand proof.
// Fixed oracle: six players start100 BB; blinds0.5/1; no ante/rake/refund.
// Ordered preflop contributions SB0.5 + BTN3 + BB3 = pot6.5.
// Flop BB bets2: pot8.5, BTN this-street commitment0, full call2.
// Flop BTN calls2 then Turn BB bets4: pot14.5, BTN new-street commitment0,
// full call4. These expectations are literal independent arithmetic, never
// generated from the production ledger. Wrong options deliberately claim
// authored success, so runtime must withhold both callbacks and every grade.
// This file owns no production behavior and does not close W4's nine-family
// catalog denominator, reopening, side-pot settlement or full PKR02/05 DoD.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_betting_price_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

const _world = 'synthetic_multistreet_oracle';
const _grades = <String>['user_choice', 'decision_made', 'task_result'];
const _preflop = <String>[
  'SB blind 0.5 BB',
  'BB blind 1 BB',
  'UTG folds',
  'HJ folds',
  'CO folds',
  'BTN raises 3 BB',
  'SB folds',
  'BB calls 3 BB',
];
const _hero = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: 'K', suit: 'd'),
];
const _flop = <Act0CardStateV1>[
  Act0CardStateV1(rank: 'A', suit: 'h'),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'd'),
];

enum _Mutation { none, undercall, wrongPot, brokenHistory }

class _Street {
  const _Street(
    this.name,
    this.pot,
    this.due,
    this.under,
    this.wrongPot,
    this.heroBehind,
    this.bbBehind,
    this.trail,
  );
  final String name, pot, due, under, wrongPot, heroBehind, bbBehind;
  final List<String> trail;
}

const _streets = <_Street>[
  _Street('Flop', '8.5', '2', '1', '9.5', '97', '95', [
    ..._preflop,
    'Flop: BB bets 2 BB',
  ]),
  _Street('Turn', '14.5', '4', '2', '10.5', '95', '91', [
    ..._preflop,
    'Flop: BB bets 2 BB',
    'Flop: BTN calls 2 BB',
    'Turn: BB bets 4 BB',
  ]),
];

Act0TableStateV1 _table(_Street street, {String? pot, List<String>? trail}) {
  final behind = <String, String>{
    'UTG': '100',
    'HJ': '100',
    'CO': '100',
    'BTN': street.heroBehind,
    'SB': '99.5',
    'BB': street.bbBehind,
  };
  return Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: <Act0SeatStateV1>[
      for (final seat in const ['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'])
        Act0SeatStateV1(
          seatId: seat.toLowerCase(),
          seatLabel: seat,
          displayName: seat == 'BTN' ? 'Hero' : seat,
          isHero: seat == 'BTN',
          isDealerButton: seat == 'BTN',
          isSmallBlind: seat == 'SB',
          isBigBlind: seat == 'BB',
          isActive: seat == 'BTN',
          isInHand: seat == 'BTN' || seat == 'BB',
          isFolded: seat != 'BTN' && seat != 'BB',
          stackLabel: '${behind[seat]} BB',
          holeCards: seat == 'BTN' ? _hero : const [],
          cardsVisibleMode: seat == 'BTN'
              ? Act0CardsVisibleModeV1.faceUp
              : Act0CardsVisibleModeV1.faceDown,
          currentBetLabel: seat == 'BB' ? '${street.due} BB' : null,
        ),
    ],
    heroCards: _hero,
    boardCards: <Act0CardStateV1>[
      ..._flop,
      if (street.name == 'Turn') const Act0CardStateV1(rank: '5', suit: 's'),
    ],
    streetLabel: street.name,
    potLabel: 'Pot ${pot ?? street.pot} BB',
    toCallLabel: 'To call ${street.due} BB',
    centerLabel: 'SYNTHETIC 0.5/1 BB, all start100, no ante/rake',
    actionTrail: [
      for (final action in trail ?? street.trail)
        Act0ActionTrailItemV1(label: action),
    ],
    activeSeatId: 'btn',
    heroSeatId: 'btn',
    highlightedSeatIds: const [],
    highlightedCardIds: const [],
  );
}

Act0RunnerOptionV1 _call(String amount) => Act0RunnerOptionV1(
  id: 'call',
  label: 'Call',
  amountLabel: '$amount BB',
  isCorrect: true,
  preferredLabel: 'Call $amount BB',
  quality: Act0FeedbackQualityV1.correct,
  feedbackTitle: 'Synthetic authored success marker',
  feedbackReason:
      'The fixture claims success; the numeric guard must validate it.',
);

Map<String, Object?> _price(Act0BettingPriceResultV1 value) => {
  'sourceReady': value.sourceReady,
  'truth': value.truth.name,
  'reason': value.reason,
  'pot': value.potBeforeActionBb,
  'due': value.callCostBb,
  'streetToMatch': value.amountToMatchBb,
  'actorCommitted': value.actorCommittedBb,
  'additional': value.additionalCostBb,
};

void _trace(String stage, Map<String, Object?> fields) =>
    debugPrint('PKR_MULTISTREET ${jsonEncode({'stage': stage, ...fields})}');

void _assertIntactSource(_Street street, Act0TableStateV1 table) {
  // A known full-call control proves source readiness separately from the
  // chosen option's legality. Never apply this sentinel to corrupted inputs.
  final ready = act0BettingPriceForOptionV1(table, _call(street.due));
  _trace('intact-source', {
    'street': street.name,
    'price': _price(ready),
    'actor': table.activeSeatId,
    'hero': table.heroSeatId,
    'history': table.actionTrail.map((item) => item.label).toList(),
    'stacks': {for (final seat in table.seats) seat.seatId: seat.stackLabel},
  });
  expect(ready.sourceReady, isTrue, reason: 'INTACT_SOURCE ${ready.reason}');
  expect(ready.truth, Act0BettingPriceTruthV1.consistent);
  expect(ready.potBeforeActionBb, double.parse(street.pot));
  expect(ready.callCostBb, double.parse(street.due));
  expect(ready.actorCommittedBb, 0);
  expect(ready.amountToMatchBb, double.parse(street.due));
  expect(ready.additionalCostBb, double.parse(street.due));
  expect(table.activeSeatId, 'btn');
  expect(table.heroSeatId, 'btn');
  expect(table.streetLabel, street.name);
  expect(table.seats.singleWhere((s) => s.isActive).seatId, 'btn');
  expect(
    table.seats.where((s) => s.isInHand).map((s) => s.seatId),
    unorderedEquals(['btn', 'bb']),
  );
}

void main() {
  for (final street in _streets) {
    for (final mutation in _Mutation.values) {
      final legal = mutation == _Mutation.none;
      testWidgets('SYNTHETIC ${street.name}/${mutation.name}: fixed call price '
          'and real runner accepted=$legal', (tester) async {
        await tester.binding.setSurfaceSize(const Size(393, 852));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final intact = _table(street);
        _assertIntactSource(street, intact);
        final amount = mutation == _Mutation.undercall
            ? street.under
            : street.due;
        final history = List<String>.of(street.trail);
        if (mutation == _Mutation.brokenHistory) {
          // Preserve every other claim/stack/amount: do not reconstruct the
          // absent blind or the turn fixture's missing earlier flop bet.
          final removed = street.name == 'Flop'
              ? 'SB blind 0.5 BB'
              : 'Flop: BB bets 2 BB';
          expect(history.where((event) => event == removed), hasLength(1));
          history.remove(removed);
        }
        final table = _table(
          street,
          pot: mutation == _Mutation.wrongPot ? street.wrongPot : street.pot,
          trail: history,
        );
        final option = _call(amount);
        final submittedPrice = act0BettingPriceForOptionV1(table, option);
        final id = 'synthetic_multistreet_${street.name}_${mutation.name}';
        final runner = Act0RunnerStateV1(
          lessonId: id,
          lessonTitle: 'Synthetic cross-street price oracle',
          lessonSubtitle: 'Fixed arithmetic, not catalog proof',
          beatIndex: 0,
          beatCount: 1,
          phase: Act0LessonPhaseV1.drill,
          caption: 'Synthetic authored source; corruption is deliberate.',
          hint: '',
          question: 'Call the full amount due.',
          options: [option],
          feedbackTitle: '',
          feedbackReason: '',
          primaryCtaLabel: 'Continue',
          nextLessonId: null,
          returnTarget: 'learn',
          table: table,
        );
        final sink = Act0InMemoryTelemetrySinkV1();
        final choices = <Act0RunnerOptionV1>[];
        final decisions = <Act0CompletedDecisionV1>[];
        var backCalls = 0;
        Map<String, Object?> observations() => {
          'id': id,
          'street': table.streetLabel,
          'actor': table.activeSeatId,
          'hero': table.heroSeatId,
          'expectedLegal': legal,
          'amount': amount,
          'claimedPot': table.potLabel,
          'claimedDue': table.toCallLabel,
          'history': table.actionTrail.map((item) => item.label).toList(),
          'price': _price(submittedPrice),
          'choices': choices.length,
          'decisions': decisions
              .map(
                (d) => {
                  'attempt': d.attemptKey,
                  'task': d.taskId,
                  'sourceTask': d.sourceTaskId,
                  'world': d.worldId,
                  'lesson': d.lessonId,
                  'selected': d.selectedId,
                  'expected': d.expectedId,
                  'correct': d.isCorrect,
                },
              )
              .toList(),
          'events': sink.events
              .map((e) => {'name': e.name, 'fields': e.fields})
              .toList(),
          'backCalls': backCalls,
        };
        _trace('before-mount', observations());
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('en'),
            home: Scaffold(
              body: Act0LessonRunnerShellV1(
                key: ValueKey(id),
                runner: runner,
                selectedWorldId: _world,
                selectedLessonId: id,
                selectedTaskId: id,
                selectedTaskFamily: Act0TaskFamilyV1.decision,
                telemetrySink: sink,
                evidenceRunId: 'synthetic_multistreet_runtime',
                // Existing settled-mode seam isolates grading from animation;
                // it does not establish native timing or learner integration.
                tableChoreographyMode: Act0TableChoreographyModeV1.settled,
                onBack: () {
                  backCalls++;
                },
                onContinueTheory: () {},
                onChooseOption: choices.add,
                onCompletedDecision: decisions.add,
                onContinueReview: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final button = find.byKey(const Key('act0_shell_option_call'));
        expect(button, findsOneWidget, reason: 'Actual amount must be offered');
        expect(
          find.descendant(of: button, matching: find.text('$amount BB')),
          findsOneWidget,
        );
        expect(choices, isEmpty);
        expect(decisions, isEmpty);
        expect(sink.events.where((e) => _grades.contains(e.name)), isEmpty);
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        expect(button.hitTestable(), findsOneWidget);
        await tester.tap(button);
        await tester.pumpAndSettle();
        _trace(
          'after-real-tap',
          observations(),
        ); // Raw before outcome assertions.
        final gradeEvents = sink.events
            .where((e) => _grades.contains(e.name))
            .toList();
        final corrupted =
            mutation == _Mutation.wrongPot ||
            mutation == _Mutation.brokenHistory;
        expect(
          submittedPrice.sourceReady,
          !corrupted,
          reason: 'Corruption is not an intact-fixture sentinel failure',
        );
        if (legal) {
          expect(choices, hasLength(1));
          expect(choices.single.id, 'call');
          expect(choices.single.amountLabel, '${street.due} BB');
          expect(decisions, hasLength(1));
          final decision = decisions.single;
          expect(decision.worldId, _world);
          expect(decision.lessonId, id);
          expect(decision.taskId, id);
          expect(decision.sourceTaskId, id);
          expect(decision.selectedId, 'call');
          expect(decision.expectedId, 'call');
          expect(decision.isCorrect, isTrue);
          expect(gradeEvents, hasLength(3));
          for (final name in _grades) {
            final event = gradeEvents.singleWhere((e) => e.name == name);
            expect(event.fields['correct'], isTrue);
          }
          expect(
            find.byKey(const Key('act0_betting_price_unavailable')),
            findsNothing,
          );
          expect(backCalls, 0);
        } else {
          expect(choices, isEmpty);
          expect(decisions, isEmpty);
          expect(gradeEvents, isEmpty); // No incorrect or correct grade either.
          expect(
            find.byKey(const Key('act0_betting_price_unavailable')),
            findsOneWidget,
          );
          final back = find.byKey(const Key('act0_shell_runner_back'));
          expect(back, findsOneWidget);
          await tester.ensureVisible(back);
          await tester.pumpAndSettle();
          expect(back.hitTestable(), findsOneWidget);
          await tester.tap(back);
          await tester.pumpAndSettle();
          _trace('after-back', observations());
          expect(backCalls, 1);
          expect(choices, isEmpty);
          expect(decisions, isEmpty);
          expect(sink.events.where((e) => _grades.contains(e.name)), isEmpty);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
