import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

Act0LessonTaskV1 _task(String id) => [
  for (final w in Act0ShellStateV1.sample.worlds)
    for (final l in w.lessons) ...l.taskList,
].singleWhere((task) => task.taskId == id);

// Synthetic participation changes preserve the six physical seat slots.
Act0SeatStateV1 _fixtureSeat(
  Act0SeatStateV1 seat, {
  bool? folded,
  List<Act0CardStateV1>? cards,
}) => Act0SeatStateV1(
  seatId: seat.seatId,
  seatLabel: seat.seatLabel,
  displayName: seat.displayName,
  isHero: seat.isHero,
  isDealerButton: seat.isDealerButton,
  isSmallBlind: seat.isSmallBlind,
  isBigBlind: seat.isBigBlind,
  blindAmountLabel: seat.blindAmountLabel,
  isActive: seat.isActive,
  isTarget: seat.isTarget,
  isInHand: folded == null ? seat.isInHand : !folded,
  isFolded: folded ?? seat.isFolded,
  hasActed: seat.hasActed,
  isLastAggressor: seat.isLastAggressor,
  isOccupied: seat.isOccupied,
  stackLabel: seat.stackLabel,
  holeCards: cards ?? seat.holeCards,
  cardsVisibleMode: seat.cardsVisibleMode,
  currentBetLabel: seat.currentBetLabel,
  bet: seat.bet,
);

List<Act0SeatStateV1> _twoLiveSeats(Act0TableStateV1 table) => [
  for (final seat in table.seats)
    _fixtureSeat(seat, folded: !seat.isHero && seat.seatId != 'co'),
];

Future<void> _pump(
  WidgetTester tester,
  Act0RunnerStateV1 runner, {
  bool explanation = false,
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Act0LessonRunnerShellV1(
          // Widget-only consumer harness; omit teaching pagination, retain all
          // authored hand/choice facts. This is not native route or Human proof.
          runner: runner.copyWith(
            teachingSteps: const [],
            // Synthetic disclosure checks exercise explanation, not an
            // unassisted graded answer. Keep their solver validation live.
            phase: explanation ? Act0LessonPhaseV1.theory : runner.phase,
          ),
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onContinueReview: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('real incomplete showdown cannot announce a hand winner', (
    tester,
  ) async {
    final source = _task('showdown_best_hand_drill').runner;
    expect(
      source.table.seats.where((s) => s.isInHand && !s.isFolded),
      hasLength(6),
    );
    await _pump(tester, source, explanation: true);
    final board = find.byKey(const Key('act0_shell_card_board_0'));
    expect(board, findsOneWidget);
    await tester.ensureVisible(board);
    await tester.tap(board);
    await tester.pumpAndSettle();
    expect(
      find.textContaining(RegExp(r'(You win|[A-Za-z]+ wins) with')),
      findsNothing,
    );
  });

  for (final sourceCase in {
    'w6_kicker_showdown_compare': 'Hero A-K',
    'w6_checkpoint_table_best_five': 'Split the pot',
  }.entries) {
    testWidgets(
      'disclosed source exercise retains its authored choice: ${sourceCase.key}',
      (tester) async {
        // No card/seat/participation mutation: preserve the real exercise.
        // Its existing late-route scene hides the computed board-tap callout;
        // do not claim a visible comparison or change that presentation here.
        await _pump(tester, _task(sourceCase.key).runner);
        await tester.tap(find.byKey(const Key('act0_shell_card_board_0')));
        await tester.pumpAndSettle();
        expect(find.text(sourceCase.value), findsOneWidget);
        expect(find.textContaining('Split pot:'), findsNothing);
      },
    );
  }

  testWidgets(
    'explanation review cannot replay actions or change its stated pot',
    (tester) async {
      final source = _task(
        'what_poker_is_all_in_meaning',
      ).runner.copyWith(phase: Act0LessonPhaseV1.review);
      await _pump(tester, source);
      expect(
        find.byKey(const Key('act0_shell_action_trail_replay_controls')),
        findsNothing,
      );
      expect(find.textContaining('Pot 41.5 BB'), findsWidgets);
    },
  );

  testWidgets(
    'complete physical fixture permits a best-hand comparison, never a payout',
    (tester) async {
      // A deliberately synthetic heads-up fixture. Marking unknown seats out
      // tests a consumer boundary and is NOT evidence about the source hand.
      final source = _task('showdown_best_hand_drill').runner;
      final twoSeats = _twoLiveSeats(source.table);
      final table = source.table.copyWith(seats: twoSeats);
      await _pump(tester, source.copyWith(table: table), explanation: true);
      await tester.tap(find.byKey(const Key('act0_shell_card_board_0')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Best shown hand: You'), findsOneWidget);
      expect(find.textContaining('You win with'), findsNothing);
      expect(find.textContaining('Split pot:'), findsNothing);
    },
  );

  testWidgets('the same two physical Hero cards may be ordered differently', (
    tester,
  ) async {
    final source = _task('showdown_best_hand_drill').runner;
    final table = source.table.copyWith(
      seats: [
        for (final seat in _twoLiveSeats(source.table))
          seat.isHero
              ? _fixtureSeat(
                  seat,
                  cards: source.table.heroCards.reversed.toList(),
                )
              : seat,
      ],
    );
    await _pump(tester, source.copyWith(table: table), explanation: true);
    await tester.tap(find.byKey(const Key('act0_shell_card_board_0')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Best shown hand: You'), findsOneWidget);
  });

  for (final invalid in [
    'one-card-reveal',
    'placeholder-reveal',
    'duplicate-card',
    'hero-mismatch',
    'hero-seat-duplicate',
    'hero-id-conflict',
    'extra-board',
    'diagram',
    'unclassified',
    'folded-hero',
  ]) {
    testWidgets('showdown comparison fails closed: $invalid', (tester) async {
      final source = _task('showdown_best_hand_drill').runner;
      var table = source.table.copyWith(seats: _twoLiveSeats(source.table));
      if (invalid == 'one-card-reveal' ||
          invalid == 'placeholder-reveal' ||
          invalid == 'duplicate-card') {
        final cards = invalid == 'one-card-reveal'
            ? const [Act0CardStateV1(rank: 'K', suit: 'h')]
            : invalid == 'placeholder-reveal'
            ? const [
                Act0CardStateV1(rank: '?', suit: ''),
                Act0CardStateV1(rank: 'J', suit: 'h'),
              ]
            : [
                table.heroCards.first,
                const Act0CardStateV1(rank: 'J', suit: 'h'),
              ];
        table = table.copyWith(
          seats: [
            for (final seat in table.seats)
              seat.seatId == 'co' ? _fixtureSeat(seat, cards: cards) : seat,
          ],
        );
      } else if (invalid == 'hero-mismatch') {
        table = table.copyWith(
          // copyWith(heroCards:) now owns both Hero representations. Build
          // a genuinely malformed disclosure explicitly, rather than relying
          // on that former accidental divergence to manufacture the fixture.
          seats: [
            for (final seat in table.seats)
              seat.isHero ? _fixtureSeat(seat, cards: const [
                Act0CardStateV1(rank: '3', suit: 's'),
                Act0CardStateV1(rank: '5', suit: 'h'),
              ]) : seat,
          ],
        );
      } else if (invalid == 'hero-seat-duplicate') {
        table = table.copyWith(
          seats: [
            for (final seat in table.seats)
              seat.isHero
                  ? _fixtureSeat(
                      seat,
                      cards: [table.heroCards.first, table.heroCards.first],
                    )
                  : seat,
          ],
        );
      } else if (invalid == 'hero-id-conflict') {
        table = table.copyWith(heroSeatId: 'co');
      } else if (invalid == 'extra-board') {
        table = table.copyWith(
          boardCards: [
            ...table.boardCards,
            const Act0CardStateV1(rank: '3', suit: 's'),
          ],
        );
      } else if (invalid == 'diagram' || invalid == 'unclassified') {
        table = table.copyWith(
          scope: invalid == 'diagram'
              ? Act0TableScopeV1.explanation
              : Act0TableScopeV1.unclassified,
        );
      } else {
        table = table.copyWith(
          seats: [
            for (final seat in table.seats)
              seat.isHero ? _fixtureSeat(seat, folded: true) : seat,
          ],
        );
      }
      await _pump(tester, source.copyWith(table: table), explanation: true);
      final board = find.byKey(const Key('act0_shell_card_board_0'));
      await tester.ensureVisible(board);
      await tester.tap(board);
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          RegExp(
            r'(You win|[A-Za-z]+ wins) with|Best shown hand:|Tied best hands:',
          ),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'physical board-play tie is a comparison, not a split-pot claim',
    (tester) async {
      final source = _task('showdown_best_hand_drill').runner;
      final table = source.table.copyWith(
        seats: _twoLiveSeats(source.table),
        boardCards: const [
          Act0CardStateV1(rank: 'A', suit: 's'),
          Act0CardStateV1(rank: 'K', suit: 's'),
          Act0CardStateV1(rank: 'Q', suit: 's'),
          Act0CardStateV1(rank: 'J', suit: 's'),
          Act0CardStateV1(rank: 'T', suit: 's'),
        ],
        // Source Hero owns Qs, so change the fixture's board suit to diamonds.
      );
      final physical = table.copyWith(
        boardCards: table.boardCards
            .map((c) => Act0CardStateV1(rank: c.rank, suit: 'd'))
            .toList(),
      );
      await _pump(tester, source.copyWith(table: physical), explanation: true);
      await tester.tap(find.byKey(const Key('act0_shell_card_board_0')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Tied best hands:'), findsOneWidget);
      expect(find.textContaining('Split pot:'), findsNothing);
    },
  );
}
