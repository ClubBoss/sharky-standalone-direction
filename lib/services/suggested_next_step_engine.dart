import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/v2/training_pack_template_v2.dart' as v2;
import '../models/action_entry.dart';
import '../models/card_model.dart';
import '../models/saved_hand.dart';
import '../models/training_pack.dart' show parseGameType;
import '../models/training_pack_template.dart' as legacy;
import '../models/v2/hand_data.dart';
import '../models/v2/hero_position.dart';
import '../models/v2/training_pack_spot.dart';
import '../core/training/engine/training_type_engine.dart';
import 'pack_unlocking_rules_engine.dart';
import 'template_storage_service.dart';
import 'tag_mastery_service.dart';
import 'training_path_progress_service.dart';

typedef TrainingPackTemplateV2 = v2.TrainingPackTemplateV2;

class SuggestedNextStepEngine {
  final TrainingPathProgressService path;
  final TagMasteryService mastery;
  final TemplateStorageService storage;

  SuggestedNextStepEngine({
    required this.path,
    required this.mastery,
    required this.storage,
  });

  Map<String, List<String>>? _stageCache;
  Map<String, Set<String>>? _completedCache;
  DateTime _cacheTime = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> _loadCache() async {
    if (_stageCache != null &&
        DateTime.now().difference(_cacheTime) < const Duration(minutes: 10)) {
      return;
    }
    _stageCache = await path.getStages();
    final prefs = await SharedPreferences.getInstance();
    _completedCache = {};
    for (final entry in _stageCache!.entries) {
      final done = <String>{};
      for (final id in entry.value) {
        if (prefs.getBool('training_path_completed_$id') ?? false) {
          done.add(id);
        }
      }
      _completedCache![entry.key] = done;
    }
    _cacheTime = DateTime.now();
  }

  bool _stageDone(List<String> ids, Set<String> completed) {
    for (final id in ids) {
      if (!completed.contains(id)) return false;
    }
    return true;
  }

  double _packScore(
    TrainingPackTemplateV2 pack,
    Map<String, double> masteryMap,
  ) {
    var score = 1.0;
    for (final t in pack.tags) {
      final m = masteryMap[t.toLowerCase()];
      if (m != null && m < score) score = m;
    }
    return score;
  }

  Future<TrainingPackTemplateV2?> suggestNext() async {
    await _loadCache();
    final stages = _stageCache ?? {};
    if (stages.isEmpty) return null;

    final masteryMap = await mastery.computeMastery();

    bool previousCompleted = true;
    for (final entry in stages.entries) {
      final packs = entry.value;
      final completed = _completedCache?[entry.key] ?? {};
      if (!previousCompleted) break;

      final incomplete = [
        for (final id in packs)
          if (!completed.contains(id)) id,
      ];
      if (incomplete.isEmpty) {
        previousCompleted = true;
        continue;
      }

      final candidates = <(TrainingPackTemplateV2, double)>[];
      for (final id in incomplete) {
        final tpl = storage.templates.firstWhereOrNull((t) => t.id == id);
        if (tpl == null) continue;
        final tplV2 = _legacyTemplateToV2(tpl);
        if (tplV2 == null) continue;
        tplV2.trainingType = TrainingTypeEngine().detectTrainingType(tplV2);
        if (!await PackUnlockingRulesEngine.instance.isUnlocked(tplV2)) {
          continue;
        }
        final score = _packScore(tplV2, masteryMap);
        candidates.add((tplV2, score));
      }

      if (candidates.isNotEmpty) {
        candidates.sort((a, b) => a.$2.compareTo(b.$2));
        return candidates.first.$1;
      }

      previousCompleted = _stageDone(packs, completed);
    }

    return null;
  }
}

TrainingPackTemplateV2? _legacyTemplateToV2(
  legacy.TrainingPackTemplate template,
) {
  final spots = [
    for (final hand in template.hands)
      if (_savedHandToSpot(hand) case final spot?) spot,
  ];
  if (spots.isEmpty) return null;

  final meta = <String, dynamic>{
    'legacyVersion': template.version,
    'legacyRevision': template.revision,
    'legacyDefaultColor': template.defaultColor,
  };
  if (template.author.isNotEmpty) meta['legacyAuthor'] = template.author;
  if (template.isBuiltIn) meta['legacyBuiltIn'] = true;
  if (template.pinned) meta['legacyPinned'] = true;

  final positions = <String>{for (final spot in spots) spot.hand.position.name}
    ..removeWhere((value) => value.isEmpty);

  return TrainingPackTemplateV2(
    id: template.id,
    name: template.name,
    description: template.description,
    tags: List<String>.from(template.tags),
    category: template.category,
    trainingType: TrainingType.pushFold,
    spots: spots,
    spotCount: spots.length,
    created: template.createdAt,
    gameType: parseGameType(template.gameType),
    bb: template.hands.isNotEmpty ? template.hands.first.anteBb : 0,
    positions: positions.toList(),
    meta: meta,
    recommended: false,
    requiresTheoryCompleted: false,
  );
}

TrainingPackSpot? _savedHandToSpot(SavedHand hand) {
  final heroCards =
      hand.playerCards.isNotEmpty &&
          hand.heroIndex >= 0 &&
          hand.heroIndex < hand.playerCards.length
      ? hand.playerCards[hand.heroIndex]
      : const <CardModel>[];
  final cardStrings = [
    for (final card in heroCards) '${card.rank}${card.suit}',
  ];
  final boardStrings = [
    for (final card in hand.boardCards) '${card.rank}${card.suit}',
  ];
  final stacks = <String, double>{
    for (final entry in hand.stackSizes.entries)
      entry.key.toString(): entry.value.toDouble(),
  };
  final actions = <int, List<ActionEntry>>{
    for (var street = 0; street < 4; street++) street: <ActionEntry>[],
  };
  for (final action in hand.actions) {
    actions
        .putIfAbsent(action.street, () => <ActionEntry>[])
        .add(action.copy());
  }
  final position = parseHeroPosition(hand.heroPosition);
  final tags = [
    for (final tag in hand.tags)
      if (tag.trim().isNotEmpty) tag.trim(),
  ];
  final categories = <String>[
    if (hand.category != null && hand.category!.trim().isNotEmpty)
      hand.category!.trim(),
  ];

  final id = hand.spotId?.isNotEmpty == true ? hand.spotId! : const Uuid().v4();
  return TrainingPackSpot(
    id: id,
    hand: HandData(
      heroCards: cardStrings.join(' '),
      position: position,
      heroIndex: hand.heroIndex,
      playerCount: hand.numberOfPlayers,
      stacks: stacks,
      actions: actions,
      board: boardStrings,
      anteBb: hand.anteBb,
    ),
    title: hand.name,
    tags: tags,
    categories: categories,
  );
}
