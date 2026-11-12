import 'package:poker_analyzer/ui_v2/act0_shell/act0_hlp02_tool_math_v1.dart';
import 'package:test/test.dart';

void main() {
  group('HLP-02 exact improving-card chance, not equity', () {
    test('nine outs: flop one card, flop both cards, turn one card', () {
      final next = hlp02OutsChanceV1(
        street: Hlp02OutsStreetV1.flop,
        outs: 9,
        cardsToCome: 1,
      )!;
      final both = hlp02OutsChanceV1(
        street: Hlp02OutsStreetV1.flop,
        outs: 9,
        cardsToCome: 2,
      )!;
      final turn = hlp02OutsChanceV1(
        street: Hlp02OutsStreetV1.turn,
        outs: 9,
        cardsToCome: 1,
      )!;
      expect(next.unseenCards, 47);
      expect(next.probability, closeTo(9 / 47, 1e-12));
      expect(next.oddsAgainst, closeTo(38 / 9, 1e-12));
      // Independent outcome count: of 1081 unordered turn/river pairs,
      // 378 contain at least one of the nine specified improving cards.
      expect(both.probability, closeTo(378 / 1081, 1e-12));
      expect(both.percent, closeTo(34.96762257169288, 1e-10));
      expect(turn.unseenCards, 46);
      expect(turn.probability, closeTo(9 / 46, 1e-12));
    });

    test('excludes supplied dirty outs rather than treating them as clean', () {
      final result = hlp02OutsChanceV1(
        street: Hlp02OutsStreetV1.flop,
        outs: 9,
        dirtyOuts: 2,
        cardsToCome: 2,
      )!;
      expect(result.outs, 9);
      expect(result.dirtyOuts, 2);
      expect(result.cleanOuts, 7);
      // Seven clean cards occur in 301 of 1081 unordered runouts.
      expect(result.probability, closeTo(301 / 1081, 1e-12));
      expect(result.oddsAgainst, closeTo(780 / 301, 1e-12));
    });

    test('zero or all dirty outs has no chance and no finite odds against', () {
      for (final outs in <int>[0, 9]) {
        final result = hlp02OutsChanceV1(
          street: Hlp02OutsStreetV1.flop,
          outs: outs,
          dirtyOuts: outs,
          cardsToCome: 2,
        )!;
        expect(result.probability, 0);
        expect(result.percent, 0);
        expect(result.oddsAgainst, isNull);
      }
    });

    test('mathematical count boundaries do not invent feasible poker outs', () {
      for (final outs in <int>[46, 47]) {
        final result = hlp02OutsChanceV1(
          street: Hlp02OutsStreetV1.flop,
          outs: outs,
          cardsToCome: 2,
        )!;
        expect(result.probability, 1);
        expect(result.oddsAgainst, 0);
      }
      expect(
        hlp02OutsChanceV1(
          street: Hlp02OutsStreetV1.turn,
          outs: 46,
          cardsToCome: 1,
        )!.probability,
        1,
      );
    });

    test('river explicitly has no improvement window', () {
      expect(
        hlp02OutsChanceV1(
          street: Hlp02OutsStreetV1.river,
          outs: 0,
          cardsToCome: 0,
        ),
        isNull,
      );
    });

    test('rejects impossible outs, dirty counts and draw windows', () {
      for (final invalid in <int>[-1, 48]) {
        expect(
          () => hlp02OutsChanceV1(
            street: Hlp02OutsStreetV1.flop,
            outs: invalid,
            cardsToCome: 1,
          ),
          throwsArgumentError,
        );
      }
      expect(
        () => hlp02OutsChanceV1(
          street: Hlp02OutsStreetV1.turn,
          outs: 47,
          cardsToCome: 1,
        ),
        throwsArgumentError,
      );
      for (final dirty in <int>[-1, 10]) {
        expect(
          () => hlp02OutsChanceV1(
            street: Hlp02OutsStreetV1.flop,
            outs: 9,
            dirtyOuts: dirty,
            cardsToCome: 1,
          ),
          throwsArgumentError,
        );
      }
      for (final window in <int>[-1, 0, 3]) {
        expect(
          () => hlp02OutsChanceV1(
            street: Hlp02OutsStreetV1.flop,
            outs: 9,
            cardsToCome: window,
          ),
          throwsArgumentError,
        );
      }
      for (final street in <Hlp02OutsStreetV1>[
        Hlp02OutsStreetV1.turn,
        Hlp02OutsStreetV1.river,
      ]) {
        expect(
          () => hlp02OutsChanceV1(street: street, outs: 9, cardsToCome: 2),
          throwsArgumentError,
        );
      }
    });
  });

  group('HLP-02 169 classes and physical combinations', () {
    final allClasses = <String>[
      for (var row = 0; row < 13; row++)
        for (var column = 0; column < 13; column++)
          hlp02RangeClassAtV1(row: row, column: column),
    ];

    test('grid preserves AA/AKs/AKo orientation and every class once', () {
      expect(hlp02RangeClassAtV1(row: 0, column: 0), 'AA');
      expect(hlp02RangeClassAtV1(row: 0, column: 1), 'AKs');
      expect(hlp02RangeClassAtV1(row: 1, column: 0), 'AKo');
      expect(hlp02RangeClassAtV1(row: 12, column: 12), '22');
      expect(allClasses.toSet(), hasLength(169));
      expect(allClasses.where((hand) => hand.length == 2), hasLength(13));
      expect(allClasses.where((hand) => hand.endsWith('s')), hasLength(78));
      expect(allClasses.where((hand) => hand.endsWith('o')), hasLength(78));
      expect(() => hlp02RangeClassAtV1(row: -1, column: 0), throwsRangeError);
      expect(() => hlp02RangeClassAtV1(row: 0, column: 13), throwsRangeError);
    });

    test('pair/suited/offsuit have 6/4/12 unordered distinct combinations', () {
      final result = hlp02RangeSummaryV1(classes: <String>['AA', 'AKs', 'AKo']);
      expect(result.combosByClass, <String, int>{'AA': 6, 'AKs': 4, 'AKo': 12});
      expect(result.classCount, 3);
      expect(result.comboCount, 22);
      expect(result.availableCombos, 1326);
      expect(result.fraction, closeTo(22 / 1326, 1e-12));
      expect(
        hlp02RangeSummaryV1(classes: <String>['AA']).combinations,
        <String>{'Ac Ad', 'Ac Ah', 'Ac As', 'Ad Ah', 'Ad As', 'Ah As'},
      );
      expect(
        hlp02RangeSummaryV1(classes: <String>['AKs']).combinations,
        <String>{'Ac Kc', 'Ad Kd', 'Ah Kh', 'As Ks'},
      );
    });

    test('full grid covers 1326 once, never 169 equally weighted hands', () {
      final result = hlp02RangeSummaryV1(classes: allClasses);
      expect(result.classCount, 169);
      expect(result.availableClassCount, 169);
      expect(result.comboCount, 1326);
      expect(result.combinations, hasLength(1326));
      expect(result.fraction, 1);
    });

    test('blockers remove physical cards with no double subtraction', () {
      final blocked = hlp02RangeSummaryV1(
        classes: <String>['AA', 'AKs', 'AKo'],
        knownCards: <String>['As', 'Ks'],
      );
      expect(blocked.combosByClass, <String, int>{'AA': 3, 'AKs': 3, 'AKo': 6});
      expect(blocked.comboCount, 12);
      expect(blocked.availableCombos, 1225);
      expect(blocked.fraction, closeTo(12 / 1225, 1e-12));
      expect(blocked.combinations.any((hand) => hand.contains('As')), isFalse);
      expect(blocked.combinations.any((hand) => hand.contains('Ks')), isFalse);
      final differentSuits = hlp02RangeSummaryV1(
        classes: <String>['AKs', 'AKo'],
        knownCards: <String>['As', 'Kd'],
      );
      expect(differentSuits.combosByClass, <String, int>{'AKs': 2, 'AKo': 7});
    });

    test('repeated classes and cards are counted exactly once', () {
      final result = hlp02RangeSummaryV1(
        classes: <String>['AA', 'AA', 'AKs', 'AKs'],
        knownCards: <String>['As', 'As'],
      );
      expect(result.knownCardCount, 1);
      expect(result.classCount, 2);
      expect(result.combosByClass, <String, int>{'AA': 3, 'AKs': 3});
      expect(result.comboCount, 6);
      expect(result.availableCombos, 1275);
    });

    test('fully blocked classes remain selected but contain no hands', () {
      final result = hlp02RangeSummaryV1(
        classes: <String>['AA', 'AKs', 'AKo'],
        knownCards: <String>['Ac', 'Ad', 'Ah', 'As'],
      );
      expect(result.classCount, 3);
      expect(result.availableClassCount, 0);
      expect(result.comboCount, 0);
      expect(result.availableCombos, 1128);
      expect(result.fraction, 0);
      final full = hlp02RangeSummaryV1(
        classes: allClasses,
        knownCards: <String>['Ac', 'Ad', 'Ah', 'As'],
      );
      expect(full.comboCount, 1128);
      expect(full.availableClassCount, 144);
      expect(full.fraction, 1);
    });

    test('empty range differs from no possible unknown hand', () {
      final empty = hlp02RangeSummaryV1(classes: const <String>[]);
      expect(empty.comboCount, 0);
      expect(empty.classCount, 0);
      expect(empty.availableCombos, 1326);
      expect(empty.fraction, 0);
      final deck = <String>[
        for (final rank in hlp02RangeRanksV1)
          for (final suit in <String>['c', 'd', 'h', 's']) '$rank$suit',
      ];
      for (final remaining in <int>[0, 1]) {
        final result = hlp02RangeSummaryV1(
          classes: allClasses,
          knownCards: deck.skip(remaining),
        );
        expect(result.comboCount, 0);
        expect(result.availableCombos, 0);
        expect(result.fraction, isNull);
      }
    });

    test('rejects malformed/ambiguous class and card inputs', () {
      for (final hand in <String>[
        '',
        'AK',
        'AAs',
        'KAs',
        'AAo',
        'AsKs',
        'AKx',
        'aa',
        'AKs ',
        'A1s',
      ]) {
        expect(
          () => hlp02RangeSummaryV1(classes: <String>[hand]),
          throwsArgumentError,
          reason: hand,
        );
      }
      for (final card in <String>['', 'AS', '10s', '1s', 'As ', '??', 'AhKd']) {
        expect(
          () => hlp02RangeSummaryV1(
            classes: <String>['AA'],
            knownCards: <String>[card],
          ),
          throwsArgumentError,
          reason: card,
        );
      }
    });

    test('result collections cannot be mutated by a UI consumer', () {
      final result = hlp02RangeSummaryV1(classes: <String>['AA']);
      expect(() => result.combosByClass['AA'] = 1326, throwsUnsupportedError);
      expect(() => result.combinations.clear(), throwsUnsupportedError);
    });
  });
}
