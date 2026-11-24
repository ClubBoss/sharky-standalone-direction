part of 'act0_imported_hand_v1.dart';

const _money = r'\$(\d{1,7}(?:\.\d{1,2})?)';
final _header = RegExp(
  r"^PokerStars Hand #([1-9]\d{0,19}): {1,2}Hold'em No Limit \(" +
      _money +
      '/' +
      _money +
      r' USD\) - (.+)$',
);
final _eastern = RegExp(
  r'^\d{4}/\d\d/\d\d \d\d:\d\d:\d\d [A-Z]{2,5} \[([^\[\]]+ ET)\]$',
);
final _table = RegExp(
  r"^Table '[^']+' ([2-9])-max Seat #([1-9]) is the button$",
);
final _seat = RegExp(r'^Seat ([1-9]): ([^:]+) \(' + _money + r' in chips\)$');
final _actor = RegExp(r'^([^:]+): (.+)$');
final _post = RegExp(r'^posts (small|big) blind ' + _money + r'$');
final _dealt = RegExp(r'^Dealt to ([^:]+) \[([^\]]+)\]$');
final _streetLine = RegExp(
  r'^\*\*\* (FLOP|TURN|RIVER) \*\*\* \[([^\]]+)\](?: \[([^\]]+)\])?$',
);
final _wager = RegExp(r'^(calls|bets) ' + _money + r'( and is all-in)?$');
final _raise = RegExp(
  r'^raises ' + _money + r' to ' + _money + r'( and is all-in)?$',
);
final _returned = RegExp(
  r'^Uncalled bet \(' + _money + r'\) returned to ([^:]+)$',
);
final _collected = RegExp(r'^([^:]+) collected ' + _money + r' from pot$');
final _show = RegExp(r'^shows \[([^\]]+)\](?: \([^)]+\))?$');
final _total = RegExp(r'^Total pot ' + _money + r' \| Rake ' + _money + r'$');
final _summaryBoard = RegExp(r'^Board \[([^\]]+)\]$');
final _summarySeat = RegExp(r'^Seat ([1-9]): (.+)$');
final _role = RegExp(r'^\((button|small blind|big blind)\) ');
final _summaryCollection = RegExp(r'^collected \(' + _money + r'\)$');
final _summaryShow = RegExp(
  r'^showed \[([^\]]+)\] and (?:won \(' + _money + r'\)|lost) with .+$',
);
final _summaryMuck = RegExp(r'^mucked(?: \[([^\]]+)\]| hand)?$');

typedef _SourceLine = ({int number, String text});

class _SinglePotCashParser {
  _SinglePotCashParser(String text) {
    if (text.length > 120000) {
      throw const Act0HandImportExceptionV1(
        Act0HandImportErrorV1.malformedHand,
      );
    }
    var number = 0;
    final source = text.startsWith('\uFEFF') ? text.substring(1) : text;
    for (final raw in const LineSplitter().convert(source)) {
      number++;
      final line = raw.trim();
      if (line.isNotEmpty) _lines.add((number: number, text: line));
    }
  }

  final _lines = <_SourceLine>[];
  int _index = 0;
  final _names = <String, int>{};
  final _seats = <Act0ImportedSeatV1>[];
  final _actions = <Act0ImportedActionV1>[];
  final _shown = <int, List<String>>{};
  final _mucked = <int>{};
  final _paid = <int, int>{};
  List<String> _board = const [];
  late final Act0HandBettingLedgerV1 _ledger;
  bool _showdown = false;
  bool _sawShowdownMarker = false;
  bool _declinedShow = false;

  String get _line => _index < _lines.length ? _lines[_index].text : '';

  Never _fail([
    Act0HandImportErrorV1 code = Act0HandImportErrorV1.malformedHand,
  ]) {
    final line = _index < _lines.length
        ? _lines[_index].number
        : _lines.lastOrNull?.number;
    throw Act0HandImportExceptionV1(code, line: line);
  }

  int _knownSeat(String name) => _names[name] ?? _fail();

  int _cents(String value) {
    final pieces = value.split('.');
    return int.parse(pieces[0]) * 100 +
        (pieces.length == 2 ? int.parse(pieces[1].padRight(2, '0')) : 0);
  }

  List<String> _cards(String value, int count) =>
      _readCards(value.split(' '), count) ?? _fail();

  void _action(int seat, Act0ImportedActionKindV1 kind, int cents) {
    final action = (
      street: _ledger.street,
      seat: seat,
      kind: kind,
      cents: cents,
    );
    if (_actions.length == _maxHandActions ||
        !_ledger.add(_bettingAction(action)))
      _fail();
    _actions.add(action);
  }

  String get room => 'pokerstars';
  String get showdownMarker => '*** SHOW DOWN ***';
  bool get allowsFoldOutMarker => false;
  RegExp get totalPattern => _total;
  RegExp get summaryCollection => _summaryCollection;

  RegExpMatch readHeader() =>
      _header.firstMatch(_line) ??
      _fail(Act0HandImportErrorV1.unsupportedFormat);

  String readTimestamp(String value) {
    final timestamp = _eastern.firstMatch(value)?[1] ?? value;
    if (!_validEt(timestamp)) _fail();
    return timestamp;
  }

  Act0ImportedHandV1 parse() {
    final header = readHeader();
    final timestamp = readTimestamp(header[4]!);
    _index++;
    final table = _table.firstMatch(_line) ?? _fail();
    final tableSize = int.parse(table[1]!);
    final buttonSeat = int.parse(table[2]!);
    _index++;
    final small = _cents(header[2]!);
    final big = _cents(header[3]!);
    if (small <= 0 || big <= small) _fail();

    while (true) {
      final row = _seat.firstMatch(_line);
      if (row == null) break;
      final number = int.parse(row[1]!);
      final name = row[2]!;
      final stack = _cents(row[3]!);
      if (number > tableSize ||
          stack <= 0 ||
          name.trim() != name ||
          _names.containsKey(name) ||
          _seats.any((seat) => seat.number == number)) {
        _fail();
      }
      _names[name] = number;
      _seats.add((number: number, stackCents: stack));
      _index++;
    }
    if (_seats.length < 2 || !_names.containsValue(buttonSeat)) _fail();
    _seats.sort((a, b) => a.number.compareTo(b.number));
    _ledger = Act0HandBettingLedgerV1(
      _seats,
      tableSize,
      buttonSeat,
      small,
      big,
    );
    for (final kind in [
      Act0ImportedActionKindV1.smallBlind,
      Act0ImportedActionKindV1.bigBlind,
    ]) {
      final actor = _actor.firstMatch(_line) ?? _fail();
      final post = _post.firstMatch(actor[2]!) ?? _fail();
      if (post[1] !=
          (kind == Act0ImportedActionKindV1.smallBlind ? 'small' : 'big')) {
        _fail();
      }
      _action(_knownSeat(actor[1]!), kind, _cents(post[2]!));
      _index++;
    }
    if (_line != '*** HOLE CARDS ***') _fail();
    _index++;
    final dealt = _dealt.firstMatch(_line) ?? _fail();
    final hero = _knownSeat(dealt[1]!);
    final heroCards = _cards(dealt[2]!, 2);
    _index++;
    while (_line != '*** SUMMARY ***') {
      _playLine();
      if (_ledger.complete && _ledger.hasSidePot) {
        _fail(Act0HandImportErrorV1.sidePot);
      }
      _index++;
    }
    _index++;
    final summary = totalPattern.firstMatch(_line) ?? _fail();
    final pot = _cents(summary[1]!);
    final rake = _cents(summary[2]!);
    _index++;
    if (_board.isNotEmpty) {
      final board = _summaryBoard.firstMatch(_line) ?? _fail();
      if (board[1] != _board.join(' ')) _fail();
      _index++;
    }
    final summarized = <int>{};
    while (_index < _lines.length) {
      final summarySeat = _summarySeat.firstMatch(_line) ?? _fail();
      final seat = int.parse(summarySeat[1]!);
      final name = _names.entries
          .where((row) => row.value == seat)
          .firstOrNull
          ?.key;
      final description = summarySeat[2]!;
      if (name == null ||
          !description.startsWith('$name ') ||
          !summarized.add(seat)) {
        _fail();
      }
      _checkSeatSummary(seat, description.substring(name.length + 1));
      _index++;
    }
    if (summarized.length != _seats.length) _fail();

    final hand = Act0ImportedHandV1._(
      sourceKey: sha256
          .convert(utf8.encode('$room-hand:${header[1]}'))
          .toString(),
      room: room,
      timeEt: timestamp,
      tableSize: tableSize,
      buttonSeat: buttonSeat,
      heroSeat: hero,
      smallBlindCents: small,
      bigBlindCents: big,
      seats: _seats,
      heroCards: heroCards,
      board: _board,
      actions: _actions,
      shownCards: _shown,
      payouts: _paid,
      showdown: _showdown,
      potCents: pot,
      rakeCents: rake,
    );
    if (!_validHand(hand)) _fail();
    return hand;
  }

  void _playLine() {
    if (_collected.firstMatch(_line) case final match?) {
      final seat = _knownSeat(match[1]!);
      if (!_ledger.complete || _paid.containsKey(seat) || _declinedShow)
        _fail();
      _paid[seat] = _cents(match[2]!);
      return;
    }
    if (_actor.firstMatch(_line) case final actor?) {
      final seat = _knownSeat(actor[1]!);
      final action = actor[2]!;
      if (_paid.isNotEmpty) {
        if (_showdown ||
            _declinedShow ||
            !_paid.containsKey(seat) ||
            action != "doesn't show hand") {
          _fail();
        }
        _declinedShow = true;
      } else if (_showdown) {
        if (!_ledger.liveSeats.contains(seat) ||
            _shown.containsKey(seat) ||
            _mucked.contains(seat)) {
          _fail();
        }
        if (_show.firstMatch(action) case final shown?) {
          _shown[seat] = _cards(shown[1]!, 2);
        } else if (action == 'mucks hand') {
          _mucked.add(seat);
        } else {
          _fail();
        }
      } else {
        if (_sawShowdownMarker) _fail();
        _decision(seat, action);
      }
      return;
    }
    if (_paid.isNotEmpty || _sawShowdownMarker) _fail();
    if (_line == showdownMarker) {
      final foldOut = allowsFoldOutMarker && _ledger.liveSeats.length == 1;
      if (!_ledger.complete ||
          (!foldOut && _ledger.street != PokerStreet.river)) {
        _fail();
      }
      _sawShowdownMarker = true;
      _showdown = !foldOut;
      return;
    }
    if (_streetLine.firstMatch(_line) case final next?) {
      if (!_ledger.advance() || _ledger.street.name.toUpperCase() != next[1]) {
        _fail();
      }
      if (_ledger.street == PokerStreet.flop && next[3] == null) {
        _board = _cards(next[2]!, 3);
      } else if (_ledger.street != PokerStreet.flop &&
          next[2] == _board.join(' ') &&
          next[3] != null) {
        _board = [..._board, ..._cards(next[3]!, 1)];
      } else {
        _fail();
      }
      return;
    }
    if (_returned.firstMatch(_line) case final refund?) {
      _action(
        _knownSeat(refund[2]!),
        Act0ImportedActionKindV1.uncalledReturn,
        _cents(refund[1]!),
      );
      return;
    }
    _fail();
  }

  void _decision(int seat, String action) {
    if (action == 'folds' || action == 'checks') {
      _action(
        seat,
        action == 'folds'
            ? Act0ImportedActionKindV1.fold
            : Act0ImportedActionKindV1.check,
        0,
      );
      return;
    }
    String? allIn;
    if (_wager.firstMatch(action) case final match?) {
      allIn = match[3];
      _action(
        seat,
        match[1] == 'calls'
            ? Act0ImportedActionKindV1.call
            : Act0ImportedActionKindV1.bet,
        _cents(match[2]!),
      );
    } else if (_raise.firstMatch(action) case final match?) {
      allIn = match[3];
      final to = _cents(match[2]!);
      if (to != _ledger.highest + _cents(match[1]!)) _fail();
      _action(
        seat,
        Act0ImportedActionKindV1.raise,
        to - _ledger.contributed(seat),
      );
    } else {
      _fail();
    }
    if ((allIn != null) != (_ledger.remaining[seat] == 0)) _fail();
  }

  void _checkSeatSummary(int seat, String description) {
    final roles = <String>{};
    while (true) {
      final role = _role.firstMatch(description);
      if (role == null) break;
      final expected = switch (role[1]) {
        'button' => _ledger.buttonSeat,
        'small blind' => _ledger.smallBlindSeat,
        'big blind' => _ledger.bigBlindSeat,
        _ => null,
      };
      if (expected != seat || !roles.add(role[1]!)) _fail();
      description = description.substring(role.end);
    }
    if (_ledger.folds[seat] case final street?) {
      final allowed = street == PokerStreet.preflop
          ? ["folded before Flop", "folded before Flop (didn't bet)"]
          : ['folded on the ${pokerStreetToString(street)}'];
      if (!allowed.contains(description)) _fail();
      return;
    }
    if (!_showdown) {
      final collected = summaryCollection.firstMatch(description) ?? _fail();
      if (_paid[seat] != _cents(collected[1]!)) _fail();
      return;
    }
    if (_shown[seat] case final cards?) {
      final shown = _summaryShow.firstMatch(description) ?? _fail();
      if (!_sameCards(_cards(shown[1]!, 2), cards) ||
          _paid[seat] != (shown[2] == null ? null : _cents(shown[2]!))) {
        _fail();
      }
      return;
    }
    if (!_mucked.contains(seat) || _paid.containsKey(seat)) _fail();
    final muck = _summaryMuck.firstMatch(description) ?? _fail();
    if (muck[1] case final cards?) _shown[seat] = _cards(cards, 2);
  }

  bool _sameCards(List<String> a, List<String> b) =>
      a.toSet().length == 2 && a.every(b.contains);
}
