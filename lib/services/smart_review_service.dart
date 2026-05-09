import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/training/engine/training_type_engine.dart';
import '../models/game_type.dart';
import '../models/mistake_profile.dart';
import '../models/training_spot.dart';
import '../models/v2/hero_position.dart';
import '../models/v2/training_pack_spot.dart';
import '../models/v2/training_pack_template.dart' as tpl_v2;
import '../models/v2/training_pack_template_v2.dart';
import '../screens/training_session_screen.dart';
import 'smart_mistake_review_strategy.dart';
import 'tag_mastery_service.dart';
import 'template_storage_service.dart';
import 'training_pack_template_builder.dart';
import 'training_session_service.dart';
import 'package:uuid/uuid.dart';

/// Stores IDs of spots where the user made a mistake for future review.
class SmartReviewService {
  SmartReviewService._();

  /// Singleton instance.
  static final SmartReviewService instance = SmartReviewService._();

  static const _prefsKey = 'smart_review_spots';
  static const _resultsKey = 'smart_review_results';
  static const _spotKeyPrefix = 'smart_review_spot_';

  final Set<String> _ids = <String>{};
  final List<List<double>> _results = [];

  List<double>? _parseResult(String s) {
    final parts = s.split(',');
    if (parts.length != 3) return null;
    final a = double.tryParse(parts[0]);
    final e = double.tryParse(parts[1]);
    final i = double.tryParse(parts[2]);
    if (a == null || e == null || i == null) return null;
    return [a, e, i];
  }

  /// Loads stored mistake spot IDs from [SharedPreferences].
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _ids
      ..clear()
      ..addAll(prefs.getStringList(_prefsKey) ?? <String>[]);
    _results
      ..clear()
      ..addAll(
        [
          for (final r in prefs.getStringList(_resultsKey) ?? <String>[])
            _parseResult(r),
        ].whereType<List<double>>(),
      );
  }

  /// Records a mistake for the given [spot].
  ///
  /// Only the spot ID is persisted to avoid storing duplicate data.
  Future<void> recordMistake(TrainingPackSpot spot) async {
    final prefs = await SharedPreferences.getInstance();
    final added = _ids.add(spot.id);
    if (added) {
      await prefs.setStringList(_prefsKey, _ids.toList());
    }
    await prefs.setString(
      '$_spotKeyPrefix${spot.id}',
      jsonEncode(spot.toJson()),
    );
  }

  /// Returns the list of spots corresponding to recorded mistakes.
  Future<List<TrainingPackSpot>> getMistakeSpots(
    dynamic templates, {
    BuildContext? context,
  }) async {
    if (_ids.isEmpty) return <TrainingPackSpot>[];
    final prefs = await SharedPreferences.getInstance();
    final templateMap = _buildTemplateSpotMap(templates);
    var result = <TrainingPackSpot>[];
    for (final id in _ids) {
      final cached = _loadStoredSpot(prefs, id);
      if (cached != null) {
        result.add(cached);
        continue;
      }
      final templateSpot = templateMap[id];
      if (templateSpot != null) {
        final cloned = TrainingPackSpot.fromJson(templateSpot.toJson());
        result.add(cloned);
        await prefs.setString(
          '$_spotKeyPrefix$id',
          jsonEncode(cloned.toJson()),
        );
      }
    }

    final strategy = SmartMistakeReviewStrategy();
    final decision = await strategy.decide();
    if (decision.type != ReviewStrategyType.repeatSameSpots &&
        decision.targetTag != null) {
      final tag = decision.targetTag!.toLowerCase();
      final filtered = [
        for (final s in result)
          if (s.tags.any((t) => t.toLowerCase() == tag)) s,
      ];
      if (filtered.isNotEmpty) result = filtered;
    }

    if (context != null && result.length > 5) {
      final builder = TrainingPackTemplateBuilder();
      final mastery = context.read<TagMasteryService>();
      final tplV2 = await builder.buildSimplifiedPack(result, mastery);
      final runtimeTpl = _convertV2ToRuntimeTemplate(tplV2);
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Мы подобрали для вас упрощённую тренировку'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      await context.read<TrainingSessionService>().startSession(
        runtimeTpl,
        persist: false,
      );
      await Navigator.push(
        context,
        canonicalLegacyTrainingImplicitRouteV1(
          input:
              const CanonicalLegacyTrainingImplicitLaunchInputV1.activeSession(),
        ),
      );
      await clearMistakes();
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('🎯 Отлично! Ошибки проработаны'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return [];
    }

    return result;
  }

  /// Builds a [MistakeProfile] based on recorded mistakes.
  Future<MistakeProfile> getMistakeProfile(dynamic templates) async {
    final spots = await getMistakeSpots(templates);
    final counts = <String, int>{};
    for (final s in spots) {
      for (final t in s.tags) {
        final key = t.trim().toLowerCase();
        if (key.isEmpty) continue;
        counts.update(key, (v) => v + 1, ifAbsent: () => 1);
      }
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final weak = entries.take(3).map((e) => e.key).toSet();
    return MistakeProfile(weakTags: weak);
  }

  /// Builds and starts a training pack from recorded mistakes.
  Future<void> buildMistakePack(BuildContext context) async {
    final templates = context.read<TemplateStorageService>();
    final spots = await getMistakeSpots(templates);
    if (spots.isEmpty) return;
    final tpl = _buildRuntimeTemplateFromSpots(
      spots,
      id: const Uuid().v4(),
      name: 'Повтор ошибок',
    );
    await context.read<TrainingSessionService>().startSession(
      tpl,
      persist: false,
    );
    await Navigator.push(
      context,
      canonicalLegacyTrainingImplicitRouteV1(
        input:
            const CanonicalLegacyTrainingImplicitLaunchInputV1.activeSession(),
      ),
    );
  }

  /// Clears all stored mistakes.
  Future<void> clearMistakes() async {
    final prefs = await SharedPreferences.getInstance();
    for (final id in _ids) {
      await prefs.remove('$_spotKeyPrefix$id');
    }
    _ids.clear();
    await prefs.remove(_prefsKey);
  }

  /// Returns true if there are recorded mistakes.
  bool hasMistakes() => _ids.isNotEmpty;

  /// Returns true if a mistake for [spotId] is recorded.
  bool hasMistake(String spotId) => _ids.contains(spotId);

  Future<void> registerCompletion(
    double accuracy,
    double evPct,
    double icmPct, {
    BuildContext? context,
  }) async {
    _results.add([accuracy, evPct, icmPct]);
    while (_results.length > 3) {
      _results.removeAt(0);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_resultsKey, [
      for (final r in _results) '${r[0]},${r[1]},${r[2]}',
    ]);

    final ready =
        _results.length >= 3 &&
        _results.every((r) => r[0] >= 0.9 && r[1] >= 0.85 && r[2] >= 0.85);
    if (ready && context != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Хотите попробовать более сложный уровень?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Нет'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Да'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        final builder = TrainingPackTemplateBuilder();
        final mastery = context.read<TagMasteryService>();
        final tplV2 = await builder.buildAdvancedPack(mastery);
        final runtimeTpl = _convertV2ToRuntimeTemplate(tplV2);
        await context.read<TrainingSessionService>().startSession(
          runtimeTpl,
          persist: false,
        );
        await Navigator.push(
          context,
          canonicalLegacyTrainingImplicitRouteV1(
            input:
                const CanonicalLegacyTrainingImplicitLaunchInputV1.activeSession(),
          ),
        );
      }
      _results.clear();
      await prefs.remove(_resultsKey);
      return;
    }

    final weakReady =
        _results.length >= 3 &&
        _results.every((r) => r[0] <= 0.7 || r[1] < 0.6 || r[2] < 0.6);
    if (weakReady && context != null) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Хотите поработать над уязвимыми зонами?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Нет'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Да'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        final builder = TrainingPackTemplateBuilder();
        final mastery = context.read<TagMasteryService>();
        final tplV2 = await builder.buildWeaknessPack(mastery);
        final runtimeTpl = _convertV2ToRuntimeTemplate(tplV2);
        await context.read<TrainingSessionService>().startSession(
          runtimeTpl,
          persist: false,
        );
        await Navigator.push(
          context,
          canonicalLegacyTrainingImplicitRouteV1(
            input:
                const CanonicalLegacyTrainingImplicitLaunchInputV1.activeSession(),
          ),
        );
      }
      _results.clear();
      await prefs.remove(_resultsKey);
    }
  }

  TrainingPackSpot? _loadStoredSpot(SharedPreferences prefs, String id) {
    final raw = prefs.getString('$_spotKeyPrefix$id');
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic>) {
        return TrainingPackSpot.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {}
    return null;
  }

  Map<String, TrainingPackSpot> _buildTemplateSpotMap(dynamic templates) {
    final map = <String, TrainingPackSpot>{};
    for (final tpl in templates.templates) {
      for (final hand in tpl.hands) {
        final key = hand.spotId ?? hand.name;
        if (key.isEmpty || map.containsKey(key)) continue;
        try {
          final spot = TrainingPackSpot.fromTrainingSpot(
            TrainingSpot.fromSavedHand(hand),
            id: key,
          );
          map[key] = spot;
        } catch (_) {}
      }
    }
    return map;
  }

  int _heroStackFromSpot(TrainingPackSpot spot) {
    final heroKey = spot.hand.heroIndex.toString();
    final value = spot.hand.stacks[heroKey];
    if (value != null) return value.round();
    if (spot.hand.stacks.isNotEmpty) {
      return spot.hand.stacks.values.first.round();
    }
    return 10;
  }

  List<int> _playerStacksFromSpot(TrainingPackSpot? spot, int fallback) {
    if (spot == null || spot.hand.stacks.isEmpty) {
      return [fallback, fallback];
    }
    final keys = spot.hand.stacks.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    final values = <int>[];
    for (final key in keys) {
      final v = spot.hand.stacks[key];
      if (v != null) values.add(v.round());
    }
    return values.isNotEmpty ? values : [fallback, fallback];
  }

  tpl_v2.TrainingPackTemplate _convertV2ToRuntimeTemplate(
    TrainingPackTemplateV2 pack,
  ) {
    final spotCopies = <TrainingPackSpot>[
      for (final s in pack.spots) TrainingPackSpot.fromJson(s.toJson()),
    ];
    final heroSpot = spotCopies.isNotEmpty ? spotCopies.first : null;
    final heroStack = heroSpot != null ? _heroStackFromSpot(heroSpot) : 10;
    final playerStacks = _playerStacksFromSpot(heroSpot, heroStack);
    final ante = heroSpot?.hand.anteBb ?? 0;
    final heroPos = heroSpot?.hand.position ?? HeroPosition.sb;
    final tags = <String>{...pack.tags};
    final metaTags = pack.meta['tags'];
    if (metaTags is List) {
      for (final t in metaTags) {
        tags.add(t.toString());
      }
    }
    return tpl_v2.TrainingPackTemplate(
      id: pack.id,
      name: pack.name,
      description: pack.description,
      goal: pack.goal,
      category: pack.category ?? (tags.isNotEmpty ? tags.first : ''),
      gameType: pack.gameType,
      spots: spotCopies,
      tags: tags.toList(),
      focusTags: const [],
      focusHandTypes: const [],
      requiredBoardClusters: const [],
      excludedBoardClusters: const [],
      difficulty: pack.meta['difficulty']?.toString(),
      heroBbStack: heroStack,
      playerStacksBb: playerStacks,
      heroPos: heroPos,
      spotCount: spotCopies.length,
      bbCallPct: pack.meta['bbCallPct'] is int
          ? pack.meta['bbCallPct'] as int
          : 20,
      anteBb: ante,
      minEvForCorrect:
          (pack.meta['minEvForCorrect'] as num?)?.toDouble() ?? 0.01,
      heroRange: (pack.meta['heroRange'] as List?)?.cast<String>(),
      createdAt: pack.created,
      meta: Map<String, dynamic>.from(pack.meta),
      goalAchieved: false,
      goalTarget: pack.meta['goalTarget'] is int
          ? pack.meta['goalTarget'] as int
          : 0,
      goalProgress: 0,
      targetStreet: pack.targetStreet,
      streetGoal: pack.meta['streetGoal'] is int
          ? pack.meta['streetGoal'] as int
          : 0,
      isDraft: false,
      isBuiltIn: false,
      png: pack.meta['png']?.toString(),
      isFavorite: false,
      isPinned: false,
      trending: pack.meta['trending'] == true,
      recommended: pack.recommended,
    );
  }

  tpl_v2.TrainingPackTemplate _buildRuntimeTemplateFromSpots(
    List<TrainingPackSpot> spots, {
    required String id,
    required String name,
    String description = '',
  }) {
    final cloned = <TrainingPackSpot>[
      for (final s in spots) TrainingPackSpot.fromJson(s.toJson()),
    ];
    final tags = <String>{};
    for (final s in cloned) {
      for (final t in s.tags) {
        if (t.trim().isNotEmpty) tags.add(t.trim());
      }
    }
    final positions = <String>{for (final s in cloned) s.hand.position.name};
    final packV2 = TrainingPackTemplateV2(
      id: id,
      name: name,
      description: description,
      trainingType: TrainingType.pushFold,
      tags: tags.toList(),
      spots: cloned,
      spotCount: cloned.length,
      created: DateTime.now(),
      gameType: GameType.tournament,
      positions: positions.toList(),
      meta: const {'origin': 'smart-review'},
    );
    final engine = TrainingTypeEngine();
    packV2.trainingType = engine.detectTrainingType(packV2);
    return _convertV2ToRuntimeTemplate(packV2);
  }
}
