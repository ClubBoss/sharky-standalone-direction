import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../services/room_hand_history_importer.dart';
import 'personal_hand_v1.dart';

/// Conservative, source-aware front end to the existing room importer.
/// The old SavedHand adapter fills missing hero/positions/stacks with defaults;
/// NONE of those guesses cross the personal-hand boundary.
class Hst06PokerStarsPreview {
  final RoomHandHistoryImporter _importer;

  Hst06PokerStarsPreview({RoomHandHistoryImporter? importer})
      : _importer = importer ?? RoomHandHistoryImporter();

  List<Hst06Preview> parse(String input) {
    if (input.trim().isEmpty) {
      return const [Hst06Preview(null, ['Paste a hand history.'], [])];
    }
    if (utf8.encode(input).length > 262144) {
      return const [Hst06Preview(null, ['Maximum input size is 256 KiB.'], [])];
    }
    final source = input.replaceAll('\r\n', '\n').trim();
    final pieces = source.split(
      RegExp(r'(?=^(?:PokerStars Hand #|GGPoker Hand #|Hand #|Winamax))',
          multiLine: true),
    ).where((s) => s.trim().isNotEmpty).toList();
    if (pieces.length > 50) {
      return const [Hst06Preview(null, ['Maximum 50 records per preview.'], [])];
    }
    return [for (final piece in pieces) _parseOne(piece.trim())];
  }

  Hst06Preview _parseOne(String source) {
    final lines = source.split('\n').map((line) => line.trim()).toList();
    if (RegExp(r'\bTournament\s*#', caseSensitive: false)
        .hasMatch(lines.first)) {
      return const Hst06Preview(null, [
        'Tournament hand histories are not supported by this import.',
      ], []);
    }
    final header = RegExp(
      r"^PokerStars Hand #([0-9]+):.*(?:Hold'em No Limit|No Limit Hold'em)",
      caseSensitive: false,
    ).firstMatch(lines.first);
    if (header == null) {
      return const Hst06Preview(null, [
        'Unsupported format. Use PokerStars English No-Limit Holdem or manual entry.',
      ], []);
    }
    final errors = <String>[], notes = <String>[];
    final handId = header.group(1)!;
    final currency = RegExp(r'\b(USD|EUR|GBP)\b', caseSensitive: false)
        .firstMatch(lines.first)?.group(1)?.toUpperCase();

    final players = <Hst06Player>[];
    final seatPattern = RegExp(r'^Seat ([0-9]+):\s*(.+?)(?:\s+\(([^)]*)\))?$');
    final stackPattern =
        RegExp(r'^([$\u20AC\u00A3]?)([0-9,.]+) in chips$', caseSensitive: false);
    for (final line in lines) {
      if (line.startsWith('***')) break;
      final match = seatPattern.firstMatch(line);
      if (match == null) {
        if (RegExp(r'^Seat [0-9]+:').hasMatch(line)) {
          errors.add('Unreadable player seat record.');
        }
        continue;
      }
      String? stack;
      final rawStack = match.group(3) ?? '';
      final stackMatch = stackPattern.firstMatch(rawStack);
      if (stackMatch == null) {
        if (RegExp(r'[0-9-]').hasMatch(rawStack)) {
          errors.add('Invalid stack at seat ' + match.group(1)!);
        } else {
          notes.add('Stack unknown at seat ' + match.group(1)!);
        }
      } else {
        _checkSymbol(stackMatch.group(1)!, currency, errors);
        try {
          stack = hst06Amount(stackMatch.group(2));
        } on FormatException catch (e) {
          errors.add(e.message);
        }
      }
      players.add(Hst06Player(
        int.parse(match.group(1)!),
        match.group(2)!.trim(),
        stack,
      ));
    }
    players.sort((a, b) => a.seat.compareTo(b.seat));
    if (players.isEmpty) errors.add('No readable player seat records.');
    final nameToSeat = <String, int>{
      for (final player in players) player.name.toLowerCase(): player.seat,
    };

    final buttonRaw = RegExp(
      r'Seat #?([0-9]+) is the button',
      caseSensitive: false,
    ).firstMatch(source)?.group(1);
    int? heroSeat;
    List<String>? heroCards;
    for (final line in lines) {
      final dealt = RegExp(
        r'^Dealt to (.+?) \[([^\]]+)\]$',
        caseSensitive: false,
      ).firstMatch(line);
      if (dealt == null) continue;
      heroSeat = nameToSeat[dealt.group(1)!.trim().toLowerCase()];
      if (heroSeat == null) errors.add('Dealt-to player not present in seats.');
      try {
        heroCards = hst06Cards(dealt.group(2)!);
      } on FormatException catch (e) {
        errors.add(e.message);
      }
      break;
    }

    final actions = <Hst06Action>[];
    List<String>? board;
    int? street;
    bool inActions = false;
    String? pot;
    final collectors = <int>{};

    for (var lineNo = 0; lineNo < lines.length; lineNo++) {
      final line = lines[lineNo];
      if (line.startsWith('*** HOLE CARDS')) {
        street = 0;
        inActions = true;
        continue;
      }
      final streetMarker = RegExp(
        r'^\*\*\* (FLOP|TURN|RIVER) \*\*\*(.*)$',
        caseSensitive: false,
      ).firstMatch(line);
      if (streetMarker != null) {
        final kind = streetMarker.group(1)!.toUpperCase();
        street = const {'FLOP': 1, 'TURN': 2, 'RIVER': 3}[kind]!;
        inActions = true;
        final sections = RegExp(r'\[([^\]]+)\]')
            .allMatches(streetMarker.group(2)!).toList();
        final tokens = sections.expand((m) => m.group(1)!
            .split(RegExp(r'\s+'))).where((s) => s.isNotEmpty).toList();
        try {
          final next = hst06Cards(tokens.join(' '));
          if (next == null || next.length != street + 2) {
            errors.add('Wrong $kind board length.');
          } else {
            if (board != null &&
                next.take(board.length).join(' ') != board.join(' ')) {
              errors.add('Previously shown board cards changed.');
            }
            board = next;
          }
        } on FormatException catch (e) {
          errors.add(e.message);
        }
        continue;
      }
      if (line.startsWith('***') &&
          !line.startsWith('*** SUMMARY') &&
          !line.startsWith('*** SHOW')) {
        errors.add('Unsupported or damaged street section.');
        street = null;
        inActions = false;
        continue;
      }
      if (line.startsWith('*** SUMMARY') || line.startsWith('*** SHOW')) {
        inActions = false;
      }
      final summaryBoard = RegExp(
        r'^Board \[([^\]]+)\]$', caseSensitive: false,
      ).firstMatch(line);
      if (summaryBoard != null) {
        try {
          final reported = hst06Cards(summaryBoard.group(1)!);
          if (reported != null) {
            if (board != null && board.join(' ') != reported.join(' ')) {
              errors.add('Summary and street board disagree.');
            }
            board ??= reported;
          }
        } on FormatException catch (e) {
          errors.add(e.message);
        }
      }
      final potMatch = RegExp(
        r'^Total pot ([$\u20AC\u00A3]?)([0-9,.]+)(?=\s|$)', caseSensitive: false,
      ).firstMatch(line);
      if (potMatch == null &&
          line.toLowerCase().startsWith('total pot ')) {
        errors.add('Invalid total pot amount.');
      }
      if (potMatch != null) {
        _checkSymbol(potMatch.group(1)!, currency, errors);
        try {
          pot = hst06Amount(potMatch.group(2));
        } on FormatException catch (e) {
          errors.add(e.message);
        }
      }
      final collectMatch = RegExp(
        r'^(?:Seat [0-9]+:\s*)?(.+?) collected [$\u20AC\u00A3]?[0-9,.]+',
        caseSensitive: false,
      ).firstMatch(line);
      if (collectMatch != null) {
        final seat = nameToSeat[collectMatch.group(1)!.trim().toLowerCase()];
        if (seat != null) collectors.add(seat);
      }

      if (!inActions || street == null) continue;
      final action = RegExp(
        r'^(.+?): (folds|checks|calls|bets|raises)\b(.*)$',
        caseSensitive: false,
      ).firstMatch(line);
      if (action == null) {
        final actor = RegExp(r'^(.+?):').firstMatch(line)?.group(1);
        if (actor != null &&
            nameToSeat.containsKey(actor.toLowerCase()) &&
            !RegExp(r': (posts|shows|mucks|doesn.t show|collected)',
                    caseSensitive: false).hasMatch(line)) {
          notes.add('Unparsed action at line ' + (lineNo + 1).toString());
        }
        continue;
      }
      final seat = nameToSeat[action.group(1)!.trim().toLowerCase()];
      if (seat == null) {
        notes.add('Unknown action actor at line ' + (lineNo + 1).toString());
        continue;
      }
      final kind = const {
        'folds': 'fold', 'checks': 'check', 'calls': 'call',
        'bets': 'bet', 'raises': 'raise',
      }[action.group(2)!.toLowerCase()]!;
      String? wager, meaning;
      final rest = action.group(3)!;
      _checkSymbol(rest, currency, errors);
      if (kind == 'call' || kind == 'bet') {
        final m = RegExp(r'^\s*([$\u20AC\u00A3]?)([0-9,.]+)').firstMatch(rest);
        if (m != null) {
          _checkSymbol(m.group(1)!, currency, errors);
          try {
            wager = hst06Amount(m.group(2));
          } on FormatException catch (e) {
            errors.add(e.message);
          }
          meaning = 'additional';
        }
      }
      if (kind == 'raise') {
        final m = RegExp(
          r'^\s*[$\u20AC\u00A3]?[0-9,.]+\s+to\s+([$\u20AC\u00A3]?)([0-9,.]+)',
        ).firstMatch(rest);
        if (m != null) {
          _checkSymbol(m.group(1)!, currency, errors);
          try {
            wager = hst06Amount(m.group(2));
          } on FormatException catch (e) {
            errors.add(e.message);
          }
          meaning = 'to';
        }
      }
      if (const ['call','bet','raise'].contains(kind) && wager == null) {
        notes.add('Unparsed wager at line ' + (lineNo + 1).toString());
      }
      actions.add(Hst06Action(
        street, seat, kind, amount: wager, meaning: meaning,
      ));
    }

    if (!lines.any((s) => s.startsWith('*** HOLE CARDS'))) {
      notes.add('HOLE CARDS section missing; preflop actions unknown.');
    }
    notes.add('Blinds, position order and pot are never reconstructed.');
    // Reuse existing adapter to detect a mismatch, but its default-filled
    // SavedHand is NEVER persisted or used to assert a known fact.
    try {
      if (_importer.parse(source).length != 1) {
        notes.add('Legacy room importer could not map this record.');
      }
    } catch (_) {
      notes.add('Legacy room importer rejected the record.');
    }
    final record = Hst06Hand(
      origin: 'pokerstars',
      roomHandId: handId,
      sourceDigest: sha256.convert(utf8.encode(source)).toString(),
      title: 'PokerStars #' + handId,
      players: players,
      unit: currency,
      heroSeat: heroSeat,
      buttonSeat: buttonRaw == null ? null : int.tryParse(buttonRaw),
      heroCards: heroCards,
      boardCards: board,
      actions: actions,
      totalPot: pot,
      collectors: collectors.isEmpty ? null : (collectors.toList()..sort()),
      notes: notes,
    );
    return hst06Inspect(record, errors);
  }

  static void _checkSymbol(
    String raw, String? currency, List<String> errors,
  ) {
    if (currency == null) return;
    final expected = const {'USD': r'$', 'EUR': '\u20AC', 'GBP': '\u00A3'}[currency];
    for (final symbol in const [r'$', '\u20AC', '\u00A3']) {
      if (raw.contains(symbol) && symbol != expected) {
        errors.add('Currency symbol conflicts with header unit.');
      }
    }
  }
}
