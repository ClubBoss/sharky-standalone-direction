import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Isolated personal-hand data. Never a graded task, TrainingSpot, or XP source.
const hst06Formats = <String>[
  'Manual structured No-Limit Holdem',
  'PokerStars English plain-text No-Limit Holdem',
];

String? hst06Amount(String? value) {
  final s = value?.trim() ?? '';
  if (s.isEmpty) return null;
  final simple = RegExp(r'^(?:0|[1-9][0-9]*)(?:\.[0-9]{1,4})?$');
  final grouped = RegExp(r'^[1-9][0-9]{0,2}(?:,[0-9]{3})+(?:\.[0-9]{1,4})?$');
  if (!simple.hasMatch(s) && !grouped.hasMatch(s)) {
    throw FormatException('Invalid amount: $s');
  }
  final parts = s.replaceAll(',', '').split('.');
  if (parts.length == 1) return parts.first;
  final fraction = parts.last.replaceFirst(RegExp(r'0+$'), '');
  return fraction.isEmpty ? parts.first : parts.first + '.' + fraction;
}

List<String>? hst06Cards(String input) {
  if (input.trim().isEmpty) return null;
  final cards = <String>[];
  for (final token in input.trim().split(RegExp(r'\s+'))) {
    final m = RegExp(r'^(10|[2-9TJQKA])([shdc])$', caseSensitive: false)
        .firstMatch(token);
    if (m == null) throw FormatException('Invalid card: $token');
    final rank = m.group(1)!.toUpperCase() == '10'
        ? 'T'
        : m.group(1)!.toUpperCase();
    cards.add(rank + m.group(2)!.toLowerCase());
  }
  return cards;
}

class Hst06Player {
  final int seat;
  final String name;
  /// Source currency, not big blinds. Null means unknown; zero stays zero.
  final String? stack;
  const Hst06Player(this.seat, this.name, this.stack);

  Map<String, Object?> toJson() => {'seat': seat, 'name': name, 'stack': stack};
  factory Hst06Player.fromJson(Map<String, dynamic> m) =>
      Hst06Player(m['seat'] as int, m['name'] as String, m['stack'] as String?);
}

class Hst06Action {
  /// 0 preflop, 1 flop, 2 turn, 3 river.
  final int street;
  final int seat;
  final String kind;
  final String? amount;
  /// "to" for raises; "additional" for bets/calls.
  final String? meaning;

  const Hst06Action(this.street, this.seat, this.kind,
      {this.amount, this.meaning});
  Map<String, Object?> toJson() => {
    'street': street, 'seat': seat, 'kind': kind,
    'amount': amount, 'meaning': meaning,
  };
  factory Hst06Action.fromJson(Map<String, dynamic> m) => Hst06Action(
    m['street'] as int, m['seat'] as int, m['kind'] as String,
    amount: m['amount'] as String?, meaning: m['meaning'] as String?,
  );
}

class Hst06Hand {
  final String localId;
  final int revision;
  final String origin;
  final String? roomHandId;
  final String sourceDigest;
  final String title;
  final String? unit;
  final List<Hst06Player> players;
  final int? heroSeat;
  final int? buttonSeat;
  final List<String>? heroCards;
  final List<String>? boardCards;
  final List<Hst06Action> actions;
  final String? totalPot;
  /// Seats explicitly named as collecting the pot; null = not established.
  final List<int>? collectors;
  final List<String> notes;

  const Hst06Hand({
    this.localId = '',
    this.revision = 0,
    required this.origin,
    this.roomHandId,
    this.sourceDigest = '',
    required this.title,
    required this.players,
    this.unit,
    this.heroSeat,
    this.buttonSeat,
    this.heroCards,
    this.boardCards,
    this.actions = const [],
    this.totalPot,
    this.collectors,
    this.notes = const [],
  });

  Map<String, Object?> get _facts => {
    'origin': origin, 'roomHandId': roomHandId, 'title': title, 'unit': unit,
    'players': [for (final p in players) p.toJson()],
    'heroSeat': heroSeat, 'buttonSeat': buttonSeat,
    'heroCards': heroCards, 'boardCards': boardCards,
    'actions': [for (final a in actions) a.toJson()],
    'totalPot': totalPot, 'collectors': collectors,
  };
  String get contentDigest => sha256.convert(utf8.encode(jsonEncode(_facts))).toString();
  String get identity => roomHandId == null
      ? 'manual:' + contentDigest : origin + ':' + roomHandId!;

  Hst06Hand persisted(String id, int rev) => Hst06Hand(
    localId: id, revision: rev, origin: origin, roomHandId: roomHandId,
    sourceDigest: sourceDigest.isEmpty ? contentDigest : sourceDigest,
    title: title, unit: unit, players: players,
    heroSeat: heroSeat, buttonSeat: buttonSeat, heroCards: heroCards,
    boardCards: boardCards, actions: actions, totalPot: totalPot,
    collectors: collectors, notes: notes,
  );

  Map<String, Object?> toJson() => {
    ..._facts, 'localId': localId, 'revision': revision,
    'sourceDigest': sourceDigest, 'notes': notes,
  };

  factory Hst06Hand.fromJson(Map<String, dynamic> m) => Hst06Hand(
    localId: m['localId'] as String, revision: m['revision'] as int,
    origin: m['origin'] as String, roomHandId: m['roomHandId'] as String?,
    sourceDigest: m['sourceDigest'] as String, title: m['title'] as String,
    unit: m['unit'] as String?,
    players: [for (final p in m['players'] as List)
      Hst06Player.fromJson(Map<String, dynamic>.from(p as Map))],
    heroSeat: m['heroSeat'] as int?, buttonSeat: m['buttonSeat'] as int?,
    heroCards: (m['heroCards'] as List?)?.cast<String>(),
    boardCards: (m['boardCards'] as List?)?.cast<String>(),
    actions: [for (final a in m['actions'] as List)
      Hst06Action.fromJson(Map<String, dynamic>.from(a as Map))],
    totalPot: m['totalPot'] as String?,
    collectors: (m['collectors'] as List?)?.cast<int>(),
    notes: (m['notes'] as List).cast<String>(),
  );
}

class Hst06Preview {
  final Hst06Hand? hand;
  final List<String> errors;
  final List<String> warnings;
  const Hst06Preview(this.hand, this.errors, this.warnings);
  bool get canSave => hand != null && errors.isEmpty;
}

Hst06Preview hst06Inspect(Hst06Hand hand, [List<String> parsingErrors = const []]) {
  final errors = <String>[...parsingErrors];
  final warnings = <String>[...hand.notes];
  if (hand.title.trim().isEmpty) errors.add('Hand title is required.');
  if (hand.unit != null &&
      !const ['USD', 'EUR', 'GBP', 'chips', 'BB'].contains(hand.unit)) {
    errors.add('Unsupported amount unit.');
  }
  if (hand.players.length < 2 || hand.players.length > 10) {
    errors.add('Need 2-10 named players.');
  }
  final seats = <int>{}, names = <String>{};
  for (final p in hand.players) {
    if (p.seat < 1 || p.seat > 10 || !seats.add(p.seat)) {
      errors.add('Repeated or invalid seat ' + p.seat.toString());
    }
    if (p.name.trim().isEmpty || !names.add(p.name.trim().toLowerCase())) {
      errors.add('Repeated or missing player name.');
    }
    if (p.stack != null) {
      try { hst06Amount(p.stack); }
      on FormatException catch (e) { errors.add(e.message); }
    }
  }
  if (hand.heroSeat != null && !seats.contains(hand.heroSeat)) {
    errors.add('Hero is not seated.');
  }
  if (hand.buttonSeat != null && !seats.contains(hand.buttonSeat)) {
    errors.add('Button is not seated.');
  }
  if (hand.heroCards != null && hand.heroCards!.length != 2) {
    errors.add('Hero requires exactly 2 known cards.');
  }
  if (hand.boardCards != null &&
      !const [3, 4, 5].contains(hand.boardCards!.length)) {
    errors.add('Board must contain 3, 4 or 5 known cards.');
  }
  final seenCards = <String>{};
  for (final c in [...?hand.heroCards, ...?hand.boardCards]) {
    final parsed = hst06Cards(c);
    if (parsed == null || parsed.length != 1 || parsed.first != c ||
        !seenCards.add(c)) {
      errors.add('Invalid or repeated card: $c');
    }
  }
  for (final a in hand.actions) {
    if (!seats.contains(a.seat) || a.street < 0 || a.street > 3 ||
        !const ['fold','check','call','bet','raise'].contains(a.kind)) {
      errors.add('Action has invalid actor, street or kind.');
    }
    if (a.amount != null) {
      try { hst06Amount(a.amount); }
      on FormatException catch (e) { errors.add(e.message); }
    }
    if (const ['fold','check'].contains(a.kind) && a.amount != null) {
      errors.add('Check/fold cannot carry a wager.');
    }
    if (a.kind == 'raise' && a.amount != null && a.meaning != 'to') {
      errors.add('Raise amount must mean raise-to.');
    }
    if (const ['call','bet','raise'].contains(a.kind) && a.amount == null) {
      warnings.add('Wager amount unknown, not zero.');
    }
  }
  if (hand.totalPot != null) {
    try { hst06Amount(hand.totalPot); }
    on FormatException catch (e) { errors.add(e.message); }
  }
  if (hand.collectors != null &&
      hand.collectors!.any((s) => !seats.contains(s))) {
    errors.add('Collector is not seated.');
  }
  if (hand.heroSeat == null) warnings.add('Hero unknown.');
  if (hand.players.any((p) => p.stack == null)) warnings.add('One or more stacks unknown.');
  if (hand.heroCards == null) warnings.add('Hero cards unknown.');
  if (hand.boardCards == null) warnings.add('Board unknown.');
  if (hand.collectors == null) warnings.add('Winner unknown.');
  if (hand.actions.isEmpty) {
    warnings.add('No actions captured; this does not prove none occurred.');
  }
  if (hand.unit == null &&
      (hand.players.any((p) => p.stack != null) || hand.totalPot != null ||
       hand.actions.any((a) => a.amount != null))) {
    warnings.add('Unit unknown; no chips/BB conversion.');
  }
  return Hst06Preview(hand, errors.toSet().toList(), warnings.toSet().toList());
}

Hst06Preview hst06Manual({
  required String title,
  required List<Hst06Player> players,
  String? unit,
  int? heroSeat,
  int? buttonSeat,
  String hole = '',
  String board = '',
  List<Hst06Action> actions = const [],
  String pot = '',
}) {
  final errors = <String>[];
  List<String>? heroCards, boardCards;
  String? totalPot;
  try { heroCards = hst06Cards(hole); }
  on FormatException catch (e) { errors.add(e.message); }
  try { boardCards = hst06Cards(board); }
  on FormatException catch (e) { errors.add(e.message); }
  try { totalPot = hst06Amount(pot); }
  on FormatException catch (e) { errors.add(e.message); }
  final hand = Hst06Hand(
    origin: 'manual', title: title.trim(), players: players,
    heroSeat: heroSeat, buttonSeat: buttonSeat, unit: unit,
    heroCards: heroCards, boardCards: boardCards, actions: actions,
    totalPot: totalPot,
  );
  return hst06Inspect(hand, errors);
}

enum Hst06SaveKind { saved, duplicate, conflict }
class Hst06SaveResult {
  final Hst06SaveKind kind;
  final Hst06Hand? stored;
  const Hst06SaveResult(this.kind, this.stored);
}

/// Device-local personal ledger only. Never calls TrainingPackStorageService
/// (which can sync to cloud) or any assessment, XP or progression API.
class Hst06PersonalStore {
  static const storageKey = 'hst06_private_hands_v1';
  final Future<SharedPreferences> Function() _getPrefs;
  Hst06PersonalStore({Future<SharedPreferences> Function()? preferences})
      : _getPrefs = preferences ?? SharedPreferences.getInstance;

  Future<List<Hst06Hand>> load() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(storageKey);
    if (raw == null) return [];
    final data = jsonDecode(raw);
    if (data is! Map || data['schema'] != 1 || data['hands'] is! List) {
      throw const FormatException('Personal-hand storage schema mismatch.');
    }
    final hands = <Hst06Hand>[
      for (final e in data['hands'] as List)
        Hst06Hand.fromJson(Map<String, dynamic>.from(e as Map))
    ];
    for (final h in hands) {
      if (h.localId.isEmpty || h.revision < 1 || !hst06Inspect(h).canSave) {
        throw const FormatException('Personal-hand storage is damaged.');
      }
    }
    return hands;
  }

  Future<Hst06SaveResult> confirm(Hst06Preview preview) async {
    if (!preview.canSave || preview.hand == null) {
      throw const FormatException('Resolve preview errors before saving.');
    }
    final candidate = preview.hand!;
    final hands = await load(); // Corrupt data fail closed: no overwrite.
    for (final existing in hands) {
      if (existing.identity == candidate.identity) {
        return Hst06SaveResult(
          existing.contentDigest == candidate.contentDigest
              ? Hst06SaveKind.duplicate : Hst06SaveKind.conflict, existing);
      }
      if (existing.contentDigest == candidate.contentDigest) {
        return Hst06SaveResult(Hst06SaveKind.duplicate, existing);
      }
    }
    final stored = candidate.persisted(const Uuid().v4(), 1);
    await _persist([...hands, stored]);
    return Hst06SaveResult(Hst06SaveKind.saved, stored);
  }

  Future<Hst06SaveResult> revise(
      Hst06Preview preview, String id, int expectedRevision) async {
    if (!preview.canSave || preview.hand == null) {
      throw const FormatException('Resolve preview errors before saving.');
    }
    final hands = await load();
    final index = hands.indexWhere((h) => h.localId == id);
    if (index == -1 || hands[index].revision != expectedRevision) {
      return const Hst06SaveResult(Hst06SaveKind.conflict, null);
    }
    final candidate = preview.hand!;
    if (hands.any((h) => h.localId != id &&
        (h.identity == candidate.identity ||
         h.contentDigest == candidate.contentDigest))) {
      return const Hst06SaveResult(Hst06SaveKind.conflict, null);
    }
    final revised = candidate.persisted(id, expectedRevision + 1);
    hands[index] = revised;
    await _persist(hands);
    return Hst06SaveResult(Hst06SaveKind.saved, revised);
  }

  Future<void> _persist(List<Hst06Hand> hands) async {
    final prefs = await _getPrefs();
    final success = await prefs.setString(storageKey, jsonEncode({
      'schema': 1, 'hands': [for (final h in hands) h.toJson()]
    }));
    if (!success) throw const FormatException('Local save failed.');
  }
}
