import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../services/inline_theory_linker.dart';
import '../action_entry.dart';
import '../card_model.dart';
import '../copy_with_mixin.dart';
import '../evaluation_result.dart';
import '../inline_theory_entry.dart';
import '../spot_model.dart';
import '../theory_note_entry.dart';
import '../training_spot.dart';
import 'hand_data.dart';
import 'hero_position.dart';

class TrainingPackSpot
    with CopyWithMixin<TrainingPackSpot>
    implements SpotModel {
  final String id;
  String type;
  String title;
  String note;
  HandData hand;
  @override
  List<String> tags;
  List<String> categories;
  DateTime editedAt;
  DateTime createdAt;
  bool pinned;
  int priority;

  /// Ephemeral flag - used only in RAM to highlight freshly imported spots.
  /// Never written to / read from JSON.
  bool isNew;

  EvaluationResult? evalResult;
  String? correctAction;
  String? explanation;
  List<String> board;
  int street;
  String? villainAction;
  List<String> heroOptions;
  Map<String, dynamic> meta;

  /// Optional reference to the template spot that produced this variation.
  String? templateSourceId;

  /// Optional reference to a mini lesson matched by tags.
  ///
  /// When present, this value is serialized to `inlineLessonId` in YAML and
  /// links the spot to a [TheoryMiniLessonNode].
  String? inlineLessonId;

  /// Ephemeral reference to a full theory lesson matched by tags.
  ///
  /// Populated at runtime by [TheoryLinkAutoInjector] and never serialized.
  String? theoryId;

  /// Ephemeral reference to inline theory content matched by tags.
  ///
  /// Populated at runtime by [InlineTheoryLinkAutoInjector] and never serialized.
  InlineTheoryEntry? inlineTheory;

  /// Ephemeral link to a related theory lesson.
  ///
  /// This field is populated at runtime by [AutoSpotTheoryInjectorService]
  /// and is never serialized.
  InlineTheoryLink? theoryLink;

  /// Marks this spot as a lightweight theory note inserted by clustering.
  /// Never serialized to persistent storage.
  bool isTheoryNote;

  /// Ephemeral flag marking spots injected automatically (e.g. ICM scenarios).
  /// Never serialized to persistent storage.
  bool isInjected;

  /// Optional note metadata for inline theory clusters.
  TheoryNoteEntry? theoryNote;

  /// Ephemeral list of IDs for theory mini-lessons relevant to this spot.
  ///
  /// Populated at runtime by [TheoryLinkAutoInjector] and never serialized.
  List<String> theoryRefs;

  TrainingPackSpot({
    required this.id,
    HandData? hand,
    List<String>? tags,
    List<String>? categories,
    this.type = 'quiz',
    this.title = '',
    this.note = '',
    this.isNew = false,
    this.pinned = false,
    this.priority = 3,
    this.evalResult,
    this.correctAction,
    this.explanation,
    List<String>? board,
    this.street = 0,
    this.villainAction,
    List<String>? heroOptions,
    Map<String, dynamic>? meta,
    DateTime? editedAt,
    DateTime? createdAt,
    this.templateSourceId,
    this.inlineLessonId,
    this.theoryId,
    List<String>? theoryRefs,
    this.isTheoryNote = false,
    this.theoryNote,
    this.isInjected = false,
  }) : hand = hand ?? HandData(),
       tags = tags != null ? List<String>.from(tags) : <String>[],
       categories = categories != null
           ? List<String>.from(categories)
           : <String>[],
       board = board != null ? List<String>.from(board) : <String>[],
       heroOptions = heroOptions != null
           ? List<String>.from(heroOptions)
           : <String>[],
       meta = meta != null
           ? Map<String, dynamic>.from(meta)
           : <String, dynamic>{},
       editedAt = editedAt ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now(),
       theoryRefs = theoryRefs != null
           ? List<String>.from(theoryRefs)
           : <String>[];

  factory TrainingPackSpot.fromJson(Map<String, dynamic> j) => TrainingPackSpot(
    id: j['id']?.toString() ?? '',
    hand: j['hand'] != null
        ? HandData.fromJson(Map<String, dynamic>.from(j['hand'] as Map))
        : null,
    tags: (j['tags'] as List?)?.map((e) => e.toString()).toList(),
    categories: (j['categories'] as List?)?.map((e) => e.toString()).toList(),
    type: j['type']?.toString() ?? 'quiz',
    title: j['title']?.toString() ?? '',
    note: j['note']?.toString() ?? '',
    pinned: j['pinned'] == true,
    priority: (j['priority'] as num?)?.toInt() ?? 3,
    evalResult: j['evalResult'] != null
        ? EvaluationResult.fromJson(
            Map<String, dynamic>.from(j['evalResult'] as Map),
          )
        : null,
    correctAction: j['correctAction']?.toString(),
    explanation: j['explanation']?.toString(),
    board: (j['board'] as List?)?.map((c) => c.toString()).toList(),
    street: (j['street'] as num?)?.toInt() ?? 0,
    villainAction: j['villainAction']?.toString(),
    heroOptions: (j['heroOptions'] as List?)?.map((a) => a.toString()).toList(),
    meta: j['meta'] is Map ? Map<String, dynamic>.from(j['meta'] as Map) : null,
    editedAt: DateTime.tryParse(j['editedAt']?.toString() ?? ''),
    createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? ''),
    templateSourceId: j['templateSourceId']?.toString(),
    inlineLessonId:
        j['inlineLessonId']?.toString() ?? j['inlineTheoryId']?.toString(),
    isTheoryNote: j['isTheoryNote'] == true,
    theoryNote: j['theoryNote'] is Map
        ? TheoryNoteEntry(
            tag: j['theoryNote']['tag']?.toString() ?? '',
            text: j['theoryNote']['text']?.toString() ?? '',
          )
        : null,
  );

  factory TrainingPackSpot.fromTrainingSpot(
    TrainingSpot spot, {
    String? id,
    String? villainAction,
    List<String>? heroOptions,
  }) {
    final heroCards = spot.playerCards.length > spot.heroIndex
        ? spot.playerCards[spot.heroIndex]
        : <CardModel>[];
    final cardStr = heroCards.map((c) => '${c.rank}${c.suit}').join(' ');
    final actionsByStreet = <int, List<ActionEntry>>{};
    for (final a in spot.actions) {
      actionsByStreet.putIfAbsent(a.street, () => []).add(a);
    }
    final stacks = <String, double>{};
    for (var i = 0; i < spot.stacks.length; i++) {
      stacks['$i'] = spot.stacks[i].toDouble();
    }
    final boardList = [for (final c in spot.boardCards) '${c.rank}${c.suit}'];
    final handData = HandData(
      heroCards: cardStr,
      position: parseHeroPosition(spot.heroPosition ?? ''),
      heroIndex: spot.heroIndex,
      playerCount: spot.numberOfPlayers,
      actions: actionsByStreet,
      stacks: stacks,
      board: boardList,
    );
    return TrainingPackSpot(
      id: id ?? const Uuid().v4(),
      hand: handData,
      board: boardList,
      villainAction: villainAction,
      heroOptions: heroOptions,
    );
  }

  Map<String, dynamic> _serialize({bool includeInlineLessonId = false}) => {
    'id': id,
    'type': type,
    'title': title,
    'note': note,
    'hand': hand.toJson(),
    if (tags.isNotEmpty) 'tags': tags,
    if (categories.isNotEmpty) 'categories': categories,
    'editedAt': editedAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    if (pinned) 'pinned': true,
    if (priority != 3) 'priority': priority,
    if (evalResult != null) 'evalResult': evalResult!.toJson(),
    if (correctAction != null) 'correctAction': correctAction,
    if (explanation != null) 'explanation': explanation,
    if (board.isNotEmpty) 'board': board,
    if (street > 0) 'street': street,
    if (villainAction != null) 'villainAction': villainAction,
    if (heroOptions.isNotEmpty) 'heroOptions': heroOptions,
    if (meta.isNotEmpty) 'meta': meta,
    if (templateSourceId != null) 'templateSourceId': templateSourceId,
    if (includeInlineLessonId && inlineLessonId != null)
      'inlineLessonId': inlineLessonId,
  };

  @override
  Map<String, dynamic> toJson() => _serialize();

  /// Converts this spot to a YAML-compatible map.
  ///
  /// The returned map omits empty or null values, mirroring [toJson].
  Map<String, dynamic> toYaml() => _serialize(includeInlineLessonId: true);

  @override
  TrainingPackSpot copyWith(Map<String, dynamic> changes) {
    final data = _serialize(includeInlineLessonId: true);
    data.addAll(changes);
    return TrainingPackSpot.fromJson(data);
  }

  @override
  TrainingPackSpot Function(Map<String, dynamic> json) get fromJson =>
      TrainingPackSpot.fromJson;

  /// Creates a [TrainingPackSpot] from a YAML map.
  ///
  /// The method is tolerant to missing fields and invalid values to maintain
  /// backwards compatibility with older pack versions.
  factory TrainingPackSpot.fromYaml(Map<dynamic, dynamic> yaml) {
    final map = <String, dynamic>{};
    yaml.forEach((k, v) => map[k.toString()] = v);

    map['type'] = yaml['type']?.toString() ?? 'quiz';

    final board = (yaml['board'] as List?)?.map((c) => c.toString()).toList();
    if (board != null && board.length >= 3 && board.length <= 5) {
      map['board'] = board;
    }

    final street = (yaml['street'] as num?)?.toInt();
    if (street != null && street >= 1 && street <= 3) {
      map['street'] = street;
    }

    final villain = yaml['villainAction']?.toString();
    if (villain != null && ['none', 'check', 'bet'].contains(villain)) {
      map['villainAction'] = villain;
    }

    final heroOptions = (yaml['heroOptions'] as List?)
        ?.map((o) => o.toString())
        .toList();
    if (heroOptions != null && heroOptions.isNotEmpty) {
      map['heroOptions'] = heroOptions;
    }

    if (yaml['meta'] is Map) {
      map['meta'] = Map<String, dynamic>.from(yaml['meta'] as Map);
    }

    final inlineId =
        yaml['inlineLessonId']?.toString() ??
        yaml['inlineTheoryId']?.toString();
    if (inlineId?.isNotEmpty == true) {
      map['inlineLessonId'] = inlineId;
    }

    return TrainingPackSpot.fromJson(Map<String, dynamic>.from(map));
  }

  double? get heroEv {
    final acts = hand.actions[0] ?? [];
    for (final a in acts) {
      if (a.playerIndex == hand.heroIndex && a.ev != null) return a.ev;
    }
    return null;
  }

  double? get heroIcmEv {
    final acts = hand.actions[0] ?? [];
    for (final a in acts) {
      if (a.playerIndex == hand.heroIndex && a.icmEv != null) return a.icmEv;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingPackSpot &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          title == other.title &&
          note == other.note &&
          hand == other.hand &&
          const ListEquality<String>().equals(tags, other.tags) &&
          const ListEquality<String>().equals(categories, other.categories) &&
          pinned == other.pinned &&
          priority == other.priority &&
          isNew == other.isNew &&
          evalResult == other.evalResult &&
          correctAction == other.correctAction &&
          explanation == other.explanation &&
          const ListEquality<String>().equals(board, other.board) &&
          street == other.street &&
          villainAction == other.villainAction &&
          const ListEquality<String>().equals(heroOptions, other.heroOptions) &&
          const DeepCollectionEquality().equals(meta, other.meta) &&
          templateSourceId == other.templateSourceId &&
          inlineLessonId == other.inlineLessonId;

  @override
  int get hashCode => Object.hashAll([
    id,
    type,
    title,
    note,
    hand,
    const ListEquality<String>().hash(tags),
    const ListEquality<String>().hash(categories),
    pinned,
    priority,
    isNew,
    evalResult,
    correctAction,
    explanation,
    const ListEquality().hash(board),
    street,
    villainAction,
    const ListEquality<String>().hash(heroOptions),
    const DeepCollectionEquality().hash(meta),
    templateSourceId,
    inlineLessonId,
  ]);
}

extension TrainingPackSpotStreet on TrainingPackSpot {
  int get street {
    if (this.street > 0) return this.street;
    final n = hand.board.length;
    if (n >= 5) return 3;
    if (n == 4) return 2;
    if (n >= 3) return 1;
    return 0;
  }
}

@immutable
class HeroDecision {
  const HeroDecision({
    this.street = 0,
    this.villainAction,
    List<String>? options,
    this.correctAction,
    this.explanation,
  }) : options = options ?? const [];

  final int street;
  final String? villainAction;
  final List<String> options;
  final String? correctAction;
  final String? explanation;

  factory HeroDecision.fromJson(Map<String, Object?> json) => HeroDecision(
    street: (json['street'] as num?)?.toInt() ?? 0,
    villainAction: json['villainAction'] as String?,
    options: _stringList(json['heroOptions']),
    correctAction: json['correctAction'] as String?,
    explanation: json['explanation'] as String?,
  );

  Map<String, Object?> toJson() => {
    if (options.isNotEmpty) 'heroOptions': List<String>.from(options),
    if (correctAction != null) 'correctAction': correctAction,
    if (explanation != null) 'explanation': explanation,
    if (villainAction != null) 'villainAction': villainAction,
    if (street > 0) 'street': street,
  };

  HeroDecision copyWith({
    int? street,
    String? villainAction,
    List<String>? options,
    Object? correctAction = _sentinel,
    Object? explanation = _sentinel,
  }) {
    final correct = identical(correctAction, _sentinel)
        ? this.correctAction
        : correctAction as String?;
    final expl = identical(explanation, _sentinel)
        ? this.explanation
        : explanation as String?;
    return HeroDecision(
      street: street ?? this.street,
      villainAction: villainAction ?? this.villainAction,
      options: options ?? List<String>.from(this.options),
      correctAction: correct,
      explanation: expl,
    );
  }
}

@immutable
class TrainingPackSpotV2 {
  TrainingPackSpotV2({
    required this.id,
    required this.type,
    required this.title,
    required this.note,
    required this.hand,
    required List<String> tags,
    required List<String> categories,
    required this.createdAt,
    required this.editedAt,
    this.pinned = false,
    this.priority = 3,
    this.isNew = false,
    this.evaluation,
    required this.decision,
    Map<String, Object?>? meta,
    this.templateSourceId,
    this.inlineLessonId,
    this.theoryId,
    this.inlineTheory,
    this.theoryLink,
    this.isTheoryNote = false,
    this.theoryNote,
    this.isInjected = false,
    List<String>? theoryRefs,
  }) : tags = List.unmodifiable(tags),
       categories = List.unmodifiable(categories),
       meta = Map.unmodifiable(meta ?? <String, Object?>{}),
       theoryRefs = List.unmodifiable(theoryRefs ?? <String>[]);

  final String id;
  final String type;
  final String title;
  final String note;
  final HandData hand;
  final List<String> tags;
  final List<String> categories;
  final DateTime createdAt;
  final DateTime editedAt;
  final bool pinned;
  final int priority;
  final bool isNew;
  final EvaluationResult? evaluation;
  final HeroDecision decision;
  final Map<String, Object?> meta;
  final String? templateSourceId;
  final String? inlineLessonId;
  final String? theoryId;
  final InlineTheoryEntry? inlineTheory;
  final InlineTheoryLink? theoryLink;
  final bool isTheoryNote;
  final TheoryNoteEntry? theoryNote;
  final bool isInjected;
  final List<String> theoryRefs;

  factory TrainingPackSpotV2.fromJson(Map<String, Object?> json) {
    final handJson = json['hand'];
    final evalJson = json['evalResult'];
    final theoryNoteJson = json['theoryNote'];
    return TrainingPackSpotV2(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'quiz',
      title: json['title'] as String? ?? '',
      note: json['note'] as String? ?? '',
      hand: handJson is Map
          ? HandData.fromJson(Map<String, dynamic>.from(handJson))
          : HandData(),
      tags: _stringList(json['tags']),
      categories: _stringList(json['categories']),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      editedAt: _parseDate(json['editedAt']) ?? DateTime.now(),
      pinned: json['pinned'] == true,
      priority: (json['priority'] as num?)?.toInt() ?? 3,
      isNew: json['isNew'] == true,
      evaluation: evalJson is Map
          ? EvaluationResult.fromJson(Map<String, dynamic>.from(evalJson))
          : null,
      decision: HeroDecision.fromJson({
        'street': json['street'],
        'villainAction': json['villainAction'],
        'heroOptions': json['heroOptions'],
        'correctAction': json['correctAction'],
        'explanation': json['explanation'],
      }),
      meta: _metaFrom(json['meta']),
      templateSourceId: json['templateSourceId'] as String?,
      inlineLessonId:
          (json['inlineLessonId'] ?? json['inlineTheoryId']) as String?,
      theoryId: json['theoryId'] as String?,
      inlineTheory: null,
      theoryLink: null,
      isTheoryNote: json['isTheoryNote'] == true,
      theoryNote: theoryNoteJson is Map
          ? TheoryNoteEntry(
              tag: theoryNoteJson['tag']?.toString() ?? '',
              text: theoryNoteJson['text']?.toString() ?? '',
            )
          : null,
      isInjected: json['isInjected'] == true,
      theoryRefs: _stringList(json['theoryRefs']),
    );
  }

  Map<String, Object?> toJson() {
    final body = <String, Object?>{
      'id': id,
      'type': type,
      'title': title,
      'note': note,
      'hand': _encodeMap(hand.toJson()),
      'editedAt': editedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
    if (tags.isNotEmpty) body['tags'] = List<String>.from(tags);
    if (categories.isNotEmpty)
      body['categories'] = List<String>.from(categories);
    if (pinned) body['pinned'] = true;
    if (priority != 3) body['priority'] = priority;
    if (evaluation != null) body['evalResult'] = evaluation!.toJson();
    final decisionJson = decision.toJson();
    body.addAll(decisionJson);
    if (hand.board.isNotEmpty) body['board'] = List<String>.from(hand.board);
    if (meta.isNotEmpty) body['meta'] = Map<String, Object?>.from(meta);
    if (templateSourceId != null) body['templateSourceId'] = templateSourceId;
    if (inlineLessonId != null && inlineLessonId!.isNotEmpty) {
      body['inlineLessonId'] = inlineLessonId;
    }
    if (isTheoryNote) body['isTheoryNote'] = true;
    if (theoryNote != null) {
      body['theoryNote'] = {'tag': theoryNote!.tag, 'text': theoryNote!.text};
    }
    if (isInjected) body['isInjected'] = true;
    return body;
  }

  TrainingPackSpotV2 copyWith({
    String? type,
    String? title,
    String? note,
    HandData? hand,
    List<String>? tags,
    List<String>? categories,
    DateTime? createdAt,
    DateTime? editedAt,
    bool? pinned,
    int? priority,
    bool? isNew,
    HeroDecision? decision,
    Map<String, Object?>? meta,
    List<String>? theoryRefs,
    Object? evaluation = _sentinel,
    Object? templateSourceId = _sentinel,
    Object? inlineLessonId = _sentinel,
    Object? theoryId = _sentinel,
    Object? inlineTheory = _sentinel,
    Object? theoryLink = _sentinel,
    Object? theoryNote = _sentinel,
    bool? isTheoryNote,
    bool? isInjected,
  }) {
    final evalValue = identical(evaluation, _sentinel)
        ? this.evaluation
        : evaluation as EvaluationResult?;
    final templateSourceValue = identical(templateSourceId, _sentinel)
        ? this.templateSourceId
        : templateSourceId as String?;
    final inlineLessonValue = identical(inlineLessonId, _sentinel)
        ? this.inlineLessonId
        : inlineLessonId as String?;
    final theoryIdValue = identical(theoryId, _sentinel)
        ? this.theoryId
        : theoryId as String?;
    final inlineTheoryValue = identical(inlineTheory, _sentinel)
        ? this.inlineTheory
        : inlineTheory as InlineTheoryEntry?;
    final theoryLinkValue = identical(theoryLink, _sentinel)
        ? this.theoryLink
        : theoryLink as InlineTheoryLink?;
    final theoryNoteValue = identical(theoryNote, _sentinel)
        ? this.theoryNote
        : theoryNote as TheoryNoteEntry?;

    return TrainingPackSpotV2(
      id: id,
      type: type ?? this.type,
      title: title ?? this.title,
      note: note ?? this.note,
      hand: hand ?? this.hand,
      tags: tags ?? this.tags,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      pinned: pinned ?? this.pinned,
      priority: priority ?? this.priority,
      isNew: isNew ?? this.isNew,
      evaluation: evalValue,
      decision: decision ?? this.decision,
      meta: meta ?? this.meta,
      templateSourceId: templateSourceValue,
      inlineLessonId: inlineLessonValue,
      theoryId: theoryIdValue,
      inlineTheory: inlineTheoryValue,
      theoryLink: theoryLinkValue,
      isTheoryNote: isTheoryNote ?? this.isTheoryNote,
      theoryNote: theoryNoteValue,
      isInjected: isInjected ?? this.isInjected,
      theoryRefs: theoryRefs ?? this.theoryRefs,
    );
  }

  TrainingPackSpot toLegacy() {
    final spot = TrainingPackSpot(
      id: id,
      type: type,
      title: title,
      note: note,
      hand: hand,
      tags: List<String>.from(tags),
      categories: List<String>.from(categories),
      editedAt: editedAt,
      createdAt: createdAt,
      pinned: pinned,
      priority: priority,
      evalResult: evaluation,
      correctAction: decision.correctAction,
      explanation: decision.explanation,
      board: List<String>.from(hand.board),
      street: decision.street,
      villainAction: decision.villainAction,
      heroOptions: List<String>.from(decision.options),
      meta: meta.map(MapEntry.new),
      templateSourceId: templateSourceId,
      inlineLessonId: inlineLessonId,
      theoryId: theoryId,
      theoryRefs: List<String>.from(theoryRefs),
      isTheoryNote: isTheoryNote,
      theoryNote: theoryNote,
      isInjected: isInjected,
    )..isNew = isNew;
    spot.inlineTheory = inlineTheory;
    spot.theoryLink = theoryLink;
    return spot;
  }
}

extension TrainingPackSpotAdapters on TrainingPackSpot {
  TrainingPackSpotV2 toV2() => TrainingPackSpotV2(
    id: id,
    type: type,
    title: title,
    note: note,
    hand: hand,
    tags: List<String>.from(tags),
    categories: List<String>.from(categories),
    createdAt: createdAt,
    editedAt: editedAt,
    pinned: pinned,
    priority: priority,
    isNew: isNew,
    evaluation: evalResult,
    decision: HeroDecision(
      street: street,
      villainAction: villainAction,
      options: List<String>.from(heroOptions),
      correctAction: correctAction,
      explanation: explanation,
    ),
    meta: meta.map(MapEntry.new),
    templateSourceId: templateSourceId,
    inlineLessonId: inlineLessonId,
    theoryId: theoryId,
    inlineTheory: inlineTheory,
    theoryLink: theoryLink,
    isTheoryNote: isTheoryNote,
    theoryNote: theoryNote,
    isInjected: isInjected,
    theoryRefs: List<String>.from(theoryRefs),
  );
}

List<String> _stringList(Object? source) {
  if (source is List) {
    return source.map((e) => e.toString()).toList();
  }
  return const [];
}

Map<String, Object?> _metaFrom(Object? source) {
  if (source is Map) {
    return source.map((key, value) => MapEntry(key.toString(), value));
  }
  return const {};
}

DateTime? _parseDate(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}

Map<String, Object?> _encodeMap(Map<String, dynamic> source) =>
    source.map(MapEntry.new);

const Object _sentinel = Object();
