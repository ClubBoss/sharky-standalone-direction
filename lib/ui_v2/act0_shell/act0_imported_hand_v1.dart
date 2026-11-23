import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:poker_analyzer/models/card_model.dart';
import 'package:poker_analyzer/models/poker_street.dart';
import 'package:poker_analyzer/services/hand_evaluator.dart';

import 'act0_hand_betting_ledger_v1.dart' show Act0HandBettingLedgerV1;
import 'act0_hand_contributions_v1.dart';
import 'act0_hand_timeline_v1.dart';

part 'act0_pokerstars_hand_history_v1.dart';
part 'act0_imported_hand_ledger_v1.dart';

enum Act0HandImportErrorV1 {
  unsupportedFormat,
  malformedHand,
  conflictingSource,
  archiveFull,
  sidePot,
}

const act0OwnHandArchiveFullMessageV1 =
    'Own hands is full. Remove a hand before adding another.';
const act0OwnHandSidePotMessageV1 =
    'Side pots are unsupported. A short all-in call must leave one pot.';

class Act0HandImportExceptionV1 implements Exception {
  const Act0HandImportExceptionV1(this.code, {this.line});

  final Act0HandImportErrorV1 code;
  final int? line;

  @override
  String toString() =>
      'Hand history import: ${code.name}${line == null ? '' : ' at line $line'}';
}

enum Act0ImportedActionKindV1 {
  smallBlind('Small blind'),
  bigBlind('Big blind'),
  fold('Fold'),
  check('Check'),
  call('Call'),
  bet('Bet'),
  raise('Raise'),
  uncalledReturn('Uncalled return');

  const Act0ImportedActionKindV1(this.label);
  final String label;
}

typedef Act0ImportedSeatV1 = ({int number, int stackCents});
typedef Act0ImportedActionV1 = ({
  PokerStreet street,
  int seat,
  Act0ImportedActionKindV1 kind,
  int cents,
});

/// A private, ungraded source hand. Seats are numeric aliases, and all money
/// is in integer USD cents. The source's Eastern time is preserved verbatim.
class Act0ImportedHandV1 {
  Act0ImportedHandV1._({
    required this.sourceKey,
    this.isManual = false,
    required this.timeEt,
    required this.tableSize,
    required this.buttonSeat,
    required this.heroSeat,
    required this.smallBlindCents,
    required this.bigBlindCents,
    required List<Act0ImportedSeatV1> seats,
    required List<String> heroCards,
    required List<String> board,
    required List<Act0ImportedActionV1> actions,
    required Map<int, List<String>> shownCards,
    required Map<int, int> payouts,
    required this.showdown,
    required this.potCents,
    required this.rakeCents,
  }) : seats = List.unmodifiable(seats),
       heroCards = List.unmodifiable(heroCards),
       board = List.unmodifiable(board),
       actions = List.unmodifiable(actions),
       shownCards = Map.unmodifiable({
         for (final entry in shownCards.entries)
           entry.key: List<String>.unmodifiable(entry.value),
       }),
       payouts = Map.unmodifiable(payouts);

  static const format = 'pokerstars-usd-nlhe-v1';
  static const manualFormat = 'manual-usd-nlhe-v1';
  final bool isManual;
  final String sourceKey;

  static Act0ImportedHandV1 manual({
    Act0ImportedHandV1? previous,
    required int tableSize,
    required int buttonSeat,
    required int heroSeat,
    required int smallBlindCents,
    required int bigBlindCents,
    required List<Act0ImportedSeatV1> seats,
    required List<String> heroCards,
    required List<String> board,
    required List<Act0ImportedActionV1> actions,
    required Map<int, List<String>> shownCards,
    required Map<int, int> payouts,
    required int rakeCents,
  }) {
    if (previous != null && !previous.isManual) {
      throw const FormatException('Only manually entered hands can be edited.');
    }
    final random = Random.secure();
    final hand = Act0ImportedHandV1._(
      sourceKey:
          previous?.sourceKey ??
          sha256
              .convert(List.generate(32, (_) => random.nextInt(256)))
              .toString(),
      isManual: true,
      timeEt: '',
      tableSize: tableSize,
      buttonSeat: buttonSeat,
      heroSeat: heroSeat,
      smallBlindCents: smallBlindCents,
      bigBlindCents: bigBlindCents,
      seats: [...seats]..sort((a, b) => a.number.compareTo(b.number)),
      heroCards: heroCards,
      board: board,
      actions: actions,
      shownCards: shownCards,
      payouts: payouts,
      showdown:
          seats.length -
              actions
                  .where(
                    (action) => action.kind == Act0ImportedActionKindV1.fold,
                  )
                  .length >
          1,
      potCents: actions.fold(
        0,
        (pot, action) =>
            pot +
            (action.kind == Act0ImportedActionKindV1.uncalledReturn
                ? -action.cents
                : action.cents),
      ),
      rakeCents: rakeCents,
    );
    final error = _handError(hand);
    if (error != null) throw FormatException(error);
    return hand;
  }

  /// Completed imports can expose their entire shared timeline.
  late final Act0HandTimelineV1 timeline = Act0HandTimelineV1.fromDeltas(
    coverage: Act0HandHistoryCoverageV1.complete,
    startingStacks: {
      for (final seat in seats) '${seat.number}': seat.stackCents,
    },
    button: '$buttonSeat',
    smallBlind: smallBlindCents,
    bigBlind: bigBlindCents,
    board: board,
    actions: [
      for (final action in actions)
        (
          street: action.street,
          seat: '${action.seat}',
          verb: Act0HandVerbV1.values.byName(action.kind.name),
          chipsAdded: action.kind == Act0ImportedActionKindV1.uncalledReturn
              ? -action.cents
              : action.cents,
        ),
    ],
  );

  Act0HandContributionsV1 contributions(
    PokerStreet street,
    Iterable<Act0ImportedActionV1> recordedActions, {
    bool includeStackLimits = true,
  }) => Act0HandContributionsV1(
    throughStreet: street,
    startingStackBbBySeat: {
      if (includeStackLimits)
        for (final seat in seats)
          seat.number.toString(): seat.stackCents / bigBlindCents,
    },
    entries: [
      for (final action in recordedActions)
        if (action.cents > 0)
          act0TimelineContributionV1(
            action.street,
            '${action.seat}',
            Act0HandVerbV1.values.byName(action.kind.name),
            action.cents / bigBlindCents,
          ),
    ],
  );

  Set<String> get seatIds => {for (final seat in seats) seat.number.toString()};

  /// The recorded decision faced a price. This describes the spot only.
  late final String? practiceLessonId = _findPracticeLesson();

  String? _findPracticeLesson() {
    final ledger = Act0HandBettingLedgerV1(
      seats,
      tableSize,
      buttonSeat,
      smallBlindCents,
      bigBlindCents,
    );
    for (final action in actions) {
      while (ledger.street.index < action.street.index) {
        if (!ledger.advance()) return null;
      }
      final facesPrice =
          action.seat == heroSeat &&
          ledger.highest > ledger.contributed(heroSeat);
      if (facesPrice &&
          const {
            Act0ImportedActionKindV1.fold,
            Act0ImportedActionKindV1.call,
            Act0ImportedActionKindV1.raise,
          }.contains(action.kind)) {
        return 'call_price';
      }
      if (!ledger.add(_bettingAction(action))) return null;
    }
    return null;
  }

  final String timeEt;
  final int tableSize, buttonSeat, heroSeat, smallBlindCents, bigBlindCents;
  final List<Act0ImportedSeatV1> seats;
  final List<String> heroCards, board;
  final List<Act0ImportedActionV1> actions;
  final Map<int, List<String>> shownCards;
  final Map<int, int> payouts;
  final bool showdown;
  final int potCents, rakeCents;

  /// Parse one complete English PokerStars USD NLHE cash record. This version
  /// supports the single-pot two-blind format, including fold-outs and
  /// showdowns. Unsupported source variants fail without returning a hand.
  static Act0ImportedHandV1 parsePokerStars(String text) =>
      _PokerStarsParser(text).parse();

  Map<String, Object?> toPayload() => {
    'format': isManual ? manualFormat : format,
    'sourceKey': sourceKey,
    'timeEt': timeEt,
    'tableSize': tableSize,
    'buttonSeat': buttonSeat,
    'heroSeat': heroSeat,
    'blinds': [smallBlindCents, bigBlindCents],
    'seats': [
      for (final row in seats) [row.number, row.stackCents],
    ],
    'heroCards': heroCards,
    'board': timeline.beforeDecision.board,
    'actions': [
      for (final action
          in timeline.beforeDecision.events.whereType<Act0HandActionV1>())
        [
          action.street.name,
          int.parse(action.seat),
          action.verb.name,
          action.chipsAdded.abs(),
        ],
    ],
    'shownCards': [
      for (final seat in seats)
        if (shownCards[seat.number] case final cards?) [seat.number, cards],
    ],
    'payouts': [
      for (final seat in seats)
        if (payouts[seat.number] case final cents?) [seat.number, cents],
    ],
    'showdown': showdown,
    'potCents': potCents,
    'rakeCents': rakeCents,
  };

  bool hasSameRecord(Act0ImportedHandV1 other) =>
      jsonEncode(toPayload()) == jsonEncode(other.toPayload());

  static Act0ImportedHandV1? tryParse(Object? data) {
    if (data case {
      'format': final String sourceFormat,
      'sourceKey': final String sourceKey,
      'timeEt': final String timeEt,
      'tableSize': final int tableSize,
      'buttonSeat': final int buttonSeat,
      'heroSeat': final int heroSeat,
      'blinds': [final int smallBlind, final int bigBlind],
      'seats': final List<Object?> rawSeats,
      'heroCards': final List<Object?> rawHero,
      'board': final List<Object?> rawBoard,
      'actions': final List<Object?> rawActions,
      'shownCards': final List<Object?> rawShown,
      'payouts': final List<Object?> rawPayouts,
      'showdown': final bool showdown,
      'potCents': final int pot,
      'rakeCents': final int rake,
    }) {
      final isManual = sourceFormat == manualFormat;
      if ((sourceFormat != format && !isManual) ||
          !_sourceKey.hasMatch(sourceKey) ||
          (isManual ? timeEt.isNotEmpty : !_validEt(timeEt)) ||
          rawSeats.length > 9 ||
          rawBoard.length > 5 ||
          rawActions.length > _maxHandActions ||
          rawShown.length > 9 ||
          rawPayouts.length > 9) {
        return null;
      }
      final seats = <Act0ImportedSeatV1>[];
      for (final row in rawSeats) {
        if (row case [final int number, final int stack]) {
          seats.add((number: number, stackCents: stack));
        } else {
          return null;
        }
      }
      final hero = _readCards(rawHero, 2);
      final board = _readCards(rawBoard, rawBoard.length);
      if (hero == null || board == null) return null;
      final actions = <Act0ImportedActionV1>[];
      for (final row in rawActions) {
        if (row case [
          final String streetName,
          final int seat,
          final String kindName,
          final int cents,
        ]) {
          final street = PokerStreet.values
              .where((s) => s.name == streetName)
              .firstOrNull;
          final kind = Act0ImportedActionKindV1.values
              .where((k) => k.name == kindName)
              .firstOrNull;
          if (street == null || kind == null) return null;
          actions.add((street: street, seat: seat, kind: kind, cents: cents));
        } else {
          return null;
        }
      }
      final shown = <int, List<String>>{};
      for (final row in rawShown) {
        if (row case [final int seat, final List<Object?> cards]) {
          final parsed = _readCards(cards, 2);
          if (parsed == null || shown.containsKey(seat)) return null;
          shown[seat] = parsed;
        } else {
          return null;
        }
      }
      final payouts = <int, int>{};
      for (final row in rawPayouts) {
        if (row case [final int seat, final int cents]) {
          if (payouts.containsKey(seat)) return null;
          payouts[seat] = cents;
        } else {
          return null;
        }
      }
      final hand = Act0ImportedHandV1._(
        sourceKey: sourceKey,
        isManual: isManual,
        timeEt: timeEt,
        tableSize: tableSize,
        buttonSeat: buttonSeat,
        heroSeat: heroSeat,
        smallBlindCents: smallBlind,
        bigBlindCents: bigBlind,
        seats: seats,
        heroCards: hero,
        board: board,
        actions: actions,
        shownCards: shown,
        payouts: payouts,
        showdown: showdown,
        potCents: pot,
        rakeCents: rake,
      );
      if (_validHand(hand)) return hand;
    }
    return null;
  }
}

({PokerStreet street, int seat, Act0HandVerbV1 kind, int cents}) _bettingAction(
  Act0ImportedActionV1 action,
) => (
  street: action.street,
  seat: action.seat,
  kind: Act0HandVerbV1.values.byName(action.kind.name),
  cents: action.cents,
);

const _maxHandActions = 150;
final _sourceKey = RegExp(r'^[a-f0-9]{64}$');
final _card = RegExp(r'^[2-9TJQKA][cdhs]$');
final _timestamp = RegExp(r'^(\d{4})/(\d\d)/(\d\d) (\d\d):(\d\d):(\d\d) ET$');

List<String>? _readCards(List<Object?> tokens, int count) {
  if (tokens.length != count ||
      tokens.any((token) => token is! String || !_card.hasMatch(token))) {
    return null;
  }
  return tokens.cast<String>();
}

bool _validEt(String value) {
  final match = _timestamp.firstMatch(value);
  if (match == null) return false;
  final [year, month, day, hour, minute, second] = [
    for (var n = 1; n <= 6; n++) int.parse(match[n]!),
  ];
  final time = DateTime.utc(year, month, day, hour, minute, second);
  return year >= 2000 &&
      time.month == month &&
      time.day == day &&
      time.hour == hour &&
      time.minute == minute &&
      time.second == second;
}
