// Run explicitly against the unchanged renderer with --update-goldens first.
// Keep those PNGs under .dart_tool/b33_table_goldens/ for the comparison run.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_f7_scene_gate_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_table_choreography_contract_v1.dart';

const _captureKey = Key('b33_modern_table_capture');
const _heroCards = [
  Act0CardStateV1(rank: 'A', suit: 's'),
  Act0CardStateV1(rank: 'K', suit: 'd'),
];
const _river = [
  Act0CardStateV1(rank: 'A', suit: 'h'),
  Act0CardStateV1(rank: '7', suit: 'c'),
  Act0CardStateV1(rank: '2', suit: 'd'),
  Act0CardStateV1(rank: '9', suit: 's'),
  Act0CardStateV1(rank: 'J', suit: 'd'),
];

const _sb = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.post,
  label: 'SB 0.5 BB',
  amountLabel: '0.5 BB',
);
const _bb = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.post,
  label: 'BB 1 BB',
  amountLabel: '1 BB',
);
const _open = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.raise,
  label: 'Raise 3 BB',
  amountLabel: '3 BB',
);
const _threeBet = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.raise,
  label: 'Raise 10 BB',
  amountLabel: '10 BB',
);
const _flopBet = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.bet,
  label: 'Bet 2 BB',
  amountLabel: '2 BB',
);
const _allIn = Act0SeatBetStateV1(
  kind: Act0SeatBetKindV1.allIn,
  label: 'All-in 97 BB',
  amountLabel: '97 BB',
);

enum _Spot { open, threeBet, flopBet, riverAllIn }

void main() {
  const cases = [
    ('preflop_open_btn', _Spot.open, 'btn', 1.0),
    ('preflop_open_utg', _Spot.open, 'utg', 1.0),
    ('facing_three_bet_btn', _Spot.threeBet, 'btn', 1.0),
    ('facing_three_bet_utg', _Spot.threeBet, 'utg', 1.0),
    ('flop_bet_btn', _Spot.flopBet, 'btn', 1.0),
    ('flop_bet_bb', _Spot.flopBet, 'bb', 1.0),
    ('river_all_in_btn', _Spot.riverAllIn, 'btn', 1.0),
    ('river_all_in_bb_text_130', _Spot.riverAllIn, 'bb', 1.3),
  ];

  for (final (name, spot, hero, textScale) in cases) {
    testWidgets('Modern Table 6-max · $name', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      expect(
        await tester.runAsync(() => Act0F7SceneGateV1.premiumStore.warmUp()),
        isNotNull,
      );

      final table = _table(spot, hero);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: RepaintBoundary(
            key: _captureKey,
            child: Scaffold(
              body: SafeArea(
                child: Act0LessonRunnerShellV1(
                  runner: _runner(table, spot),
                  worldNumber: 1,
                  selectedTaskId: name,
                  selectedTaskFamily: Act0TaskFamilyV1.decision,
                  tableChoreographyMode: Act0TableChoreographyModeV1.settled,
                  onBack: () {},
                  onContinueTheory: () {},
                  onContinueReview: () {},
                  onChooseOption: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_f7_baked_room_cast_hero')),
        findsOneWidget,
      );
      for (final seat in table.seats) {
        expect(
          find.byKey(Key('act0_shell_seat_node_${seat.seatId}')),
          findsOneWidget,
        );
        if (seat.bet != null && !seat.isFolded) {
          expect(
            find.byKey(Key('act0_shell_bet_chip_owner_${seat.seatId}')),
            findsOneWidget,
          );
        }
      }
      if (table.boardCards.isNotEmpty) {
        expect(find.byKey(const Key('act0_f7_board')), findsOneWidget);
      }
      await expectLater(
        find.byKey(_captureKey),
        matchesGoldenFile('../../.dart_tool/b33_table_goldens/$name.png'),
      );
    });
  }
}

Act0RunnerStateV1 _runner(Act0TableStateV1 table, _Spot spot) {
  final opening = spot == _Spot.open;
  final action = opening ? 'Raise' : 'Call';
  return Act0RunnerStateV1(
    lessonId: 'b33_golden',
    lessonTitle: 'Read the table',
    lessonSubtitle: '',
    beatIndex: 0,
    beatCount: 1,
    phase: Act0LessonPhaseV1.drill,
    caption: '',
    hint: '',
    question: 'What would you do here?',
    options: [
      const Act0RunnerOptionV1(
        id: 'fold',
        label: 'Fold',
        isCorrect: false,
        preferredLabel: 'Continue',
        quality: Act0FeedbackQualityV1.wrong,
        feedbackTitle: '',
        feedbackReason: '',
      ),
      Act0RunnerOptionV1(
        id: action.toLowerCase(),
        label: action,
        amountLabel: opening
            ? '3 BB'
            : table.toCallLabel.replaceFirst('To call ', ''),
        isCorrect: true,
        preferredLabel: action,
        quality: Act0FeedbackQualityV1.correct,
        feedbackTitle: '',
        feedbackReason: '',
      ),
    ],
    feedbackTitle: '',
    feedbackReason: '',
    primaryCtaLabel: 'Continue',
    nextLessonId: null,
    returnTarget: 'learn',
    table: table,
  );
}

Act0TableStateV1 _table(_Spot spot, String hero) {
  final opponent = hero == 'bb' ? 'btn' : 'bb';
  final (street, board, bets, live, stacks, pot, price) = switch (spot) {
    _Spot.open => (
      'Preflop',
      const <Act0CardStateV1>[],
      {'sb': _sb, 'bb': _bb},
      hero == 'utg'
          ? {'utg', 'hj', 'co', 'btn', 'sb', 'bb'}
          : {'btn', 'sb', 'bb'},
      {'sb': '99.5 BB', 'bb': '99 BB'},
      '1.5',
      '1',
    ),
    _Spot.threeBet => (
      'Preflop',
      const <Act0CardStateV1>[],
      {hero: _open, 'bb': _threeBet, 'sb': _sb},
      {hero, 'bb'},
      {hero: '97 BB', 'bb': '90 BB', 'sb': '99.5 BB'},
      '13.5',
      '7',
    ),
    _Spot.flopBet => (
      'Flop',
      _river.take(3).toList(),
      {opponent: _flopBet},
      {hero, opponent},
      {hero: '97 BB', opponent: '95 BB', 'sb': '99.5 BB'},
      '8.5',
      '2',
    ),
    _Spot.riverAllIn => (
      'River',
      _river,
      {opponent: _allIn},
      {hero, opponent},
      {hero: '97 BB', opponent: '0 BB', 'sb': '99.5 BB'},
      '103.5',
      '97',
    ),
  };

  return Act0TableStateV1(
    scope: Act0TableScopeV1.playedHand,
    tableFormat: Act0TableFormatV1.sixMax,
    playerCount: 6,
    seats: [
      for (final position in act0CanonicalSeatOrderForFormatV1(
        Act0TableFormatV1.sixMax,
      ))
        Act0SeatStateV1(
          seatId: position.toLowerCase(),
          seatLabel: position,
          displayName: position.toLowerCase() == hero ? 'Hero' : position,
          isHero: position.toLowerCase() == hero,
          isDealerButton: position == 'BTN',
          isSmallBlind: position == 'SB',
          isBigBlind: position == 'BB',
          isActive: position.toLowerCase() == hero,
          isInHand: live.contains(position.toLowerCase()),
          isFolded: !live.contains(position.toLowerCase()),
          stackLabel: stacks[position.toLowerCase()] ?? '100 BB',
          holeCards: position.toLowerCase() == hero
              ? _heroCards
              : const [
                  Act0CardStateV1(rank: '', suit: ''),
                  Act0CardStateV1(rank: '', suit: ''),
                ],
          cardsVisibleMode: position.toLowerCase() == hero
              ? Act0CardsVisibleModeV1.faceUp
              : Act0CardsVisibleModeV1.faceDown,
          bet: bets[position.toLowerCase()],
        ),
    ],
    heroCards: _heroCards,
    boardCards: board,
    streetLabel: street,
    potLabel: 'Pot $pot BB',
    toCallLabel: 'To call $price BB',
    centerLabel: '',
    autoPlayHistory: false,
    activeSeatId: hero,
    decisionSeatId: hero,
    heroSeatId: hero,
    highlightedSeatIds: const [],
    highlightedCardIds: const [],
  );
}
