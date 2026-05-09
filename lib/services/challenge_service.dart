import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/challenge_definition.dart';
import '../models/xp_trophy.dart';
import '../widgets/challenge_recap_popup.dart';
import '../widgets/booster_activation_popup.dart';
import 'booster_service.dart';
import 'xp_service.dart';
import 'xp_trophy_service.dart';
import 'internal_goals_service.dart';

const _dailyStateKey = 'challenge_state_daily';
const _weeklyStateKey = 'challenge_state_weekly';
const _dailyIndexKey = 'challenge_index_daily';
const _weeklyIndexKey = 'challenge_index_weekly';
const _dailyCompletionsKey = 'challenge_completions_daily';
const _weeklyCompletionsKey = 'challenge_completions_weekly';

@immutable
class ChallengeInstance {
  final ChallengeDefinition definition;
  final DateTime start;
  final int progress;
  final bool completed;

  const ChallengeInstance({
    required this.definition,
    required this.start,
    this.progress = 0,
    this.completed = false,
  });

  int get goal => definition.goal;

  double get progressRatio => goal == 0 ? 0 : (progress / goal).clamp(0.0, 1.0);

  Duration get timeLeft {
    final end = definition.duration == ChallengeDuration.daily
        ? start.add(const Duration(days: 1))
        : start.add(const Duration(days: 7));
    final remaining = end.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  ChallengeInstance copyWith({
    int? progress,
    bool? completed,
    DateTime? start,
    ChallengeDefinition? definition,
  }) => ChallengeInstance(
    definition: definition ?? this.definition,
    start: start ?? this.start,
    progress: progress ?? this.progress,
    completed: completed ?? this.completed,
  );

  Map<String, dynamic> toJson() => {
    'id': definition.id,
    'start': start.toIso8601String(),
    'progress': progress,
    'completed': completed,
  };

  static ChallengeInstance? fromJson(
    Map<String, dynamic> json,
    ChallengeDefinition definition,
  ) {
    final startStr = json['start'] as String?;
    final start = startStr != null
        ? DateTime.tryParse(startStr)
        : DateTime.now();
    if (start == null) return null;
    final progress = (json['progress'] as num?)?.toInt() ?? 0;
    final completed = json['completed'] as bool? ?? false;
    return ChallengeInstance(
      definition: definition,
      start: start,
      progress: progress,
      completed: completed,
    );
  }
}

class ChallengeService {
  ChallengeService._();

  static final ChallengeService instance = ChallengeService._();

  SharedPreferences? _prefs;
  bool _initialized = false;

  final Map<ChallengeDuration, ValueNotifier<ChallengeInstance?>> _notifiers = {
    ChallengeDuration.daily: ValueNotifier<ChallengeInstance?>(null),
    ChallengeDuration.weekly: ValueNotifier<ChallengeInstance?>(null),
  };

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    await _ensureActive(ChallengeDuration.daily);
    await _ensureActive(ChallengeDuration.weekly);
    _initialized = true;
  }

  Future<void> _ensureActive(ChallengeDuration duration) async {
    final prefs = _prefs;
    final stateKey = _stateKey(duration);
    final storedRaw = prefs?.getString(stateKey);
    ChallengeInstance? instance;
    if (storedRaw != null && storedRaw.isNotEmpty) {
      try {
        final map = jsonDecode(storedRaw) as Map<String, dynamic>;
        final def = _definitionById(duration, map['id'] as String?);
        if (def != null) {
          instance = ChallengeInstance.fromJson(map, def);
        }
      } catch (_) {}
    }

    if (instance == null ||
        _isExpired(duration, instance.start) ||
        instance.definition.duration != duration) {
      final newInstance = await _createNewInstance(duration);
      _setInstance(duration, newInstance);
      await _persist(duration, newInstance);
      return;
    }

    if (instance.progress > instance.goal) {
      instance = instance.copyWith(progress: instance.goal);
    }

    _setInstance(duration, instance);
  }

  Future<ChallengeInstance> _createNewInstance(
    ChallengeDuration duration,
  ) async {
    final definition = await _nextDefinition(duration);
    final start = _startForDuration(duration, DateTime.now());
    return ChallengeInstance(
      definition: definition,
      start: start,
      progress: 0,
      completed: false,
    );
  }

  Future<ChallengeDefinition> _nextDefinition(
    ChallengeDuration duration,
  ) async {
    final prefs = _prefs;
    final defs = _definitions[duration]!;
    final key = _indexKey(duration);
    final last = prefs?.getInt(key) ?? -1;
    final nextIndex = (last + 1) % defs.length;
    await prefs?.setInt(key, nextIndex);
    return defs[nextIndex];
  }

  ChallengeDefinition? _definitionById(ChallengeDuration duration, String? id) {
    if (id == null) return null;
    for (final def in _definitions[duration]!) {
      if (def.id == id) return def;
    }
    return null;
  }

  ValueListenable<ChallengeInstance?> listenTo(ChallengeDuration duration) {
    final notifier = _notifiers[duration]!;
    unawaited(init());
    unawaited(_ensureActive(duration));
    return notifier;
  }

  ChallengeInstance? getCurrent(ChallengeDuration duration) {
    unawaited(init());
    unawaited(_ensureActive(duration));
    return _notifiers[duration]!.value;
  }

  Future<void> onXpAwarded({required int amount}) =>
      trackProgress(ChallengeMetric.xp, amount);

  Future<void> trackProgress(ChallengeMetric metric, int amount) async {
    if (amount <= 0) return;
    await init();
    for (final entry in _notifiers.entries) {
      final duration = entry.key;
      final current = entry.value.value;
      if (current == null) {
        await _ensureActive(duration);
        continue;
      }
      if (current.definition.metric != metric) continue;
      if (_isExpired(duration, current.start)) {
        await _rotate(duration);
        continue;
      }
      if (current.completed) continue;
      final nextProgress = (current.progress + amount).clamp(0, current.goal);
      var updated = current.copyWith(progress: nextProgress);
      if (nextProgress >= current.goal) {
        updated = updated.copyWith(completed: true);
        await _handleCompletion(duration, updated);
      }
      _setInstance(duration, updated);
      await _persist(duration, updated);
    }
  }

  Future<void> _handleCompletion(
    ChallengeDuration duration,
    ChallengeInstance instance,
  ) async {
    await XpService().awardChallengeXp(
      instance.definition.id,
      instance.definition.rewardXp,
    );
    InternalGoalsService.instance.onChallengeCompleted();

    // Increment completion counters
    if (duration == ChallengeDuration.daily) {
      await _incrementDailyCompletions();
    } else if (duration == ChallengeDuration.weekly) {
      await _incrementWeeklyCompletions();
    }

    // Check and unlock challenge trophies
    final trophyService = XpTrophyService.instance;
    await trophyService.init();
    final previousTrophies = trophyService.unlocked.map((e) => e.type).toSet();

    await _checkChallengeTrophies();

    // Get newly unlocked trophies
    final currentTrophies = trophyService.unlocked.map((e) => e.type).toSet();
    final newlyUnlocked = currentTrophies.difference(previousTrophies).toList();

    // Legacy weekly champion trophy
    if (duration == ChallengeDuration.weekly) {
      if (!trophyService.has(XpTrophy.weeklyChampion)) {
        trophyService.unlock(XpTrophy.weeklyChampion);
        if (!newlyUnlocked.contains(XpTrophy.weeklyChampion)) {
          newlyUnlocked.add(XpTrophy.weeklyChampion);
        }
      }
    }

    // Show challenge recap popup
    unawaited(
      ChallengeRecapPopup.show(
        challengeTitle: instance.definition.title,
        awardedXp: instance.definition.rewardXp,
        unlockedTrophies: newlyUnlocked,
        timeUntilNext: instance.timeLeft,
      ),
    );

    // Offer an XP booster as a reward for completing a challenge
    unawaited(
      BoosterActivationPopup.show(
        type: BoosterType.play,
        source: BoosterRewardSource.challenge,
      ),
    );
  }

  Future<void> _rotate(ChallengeDuration duration) async {
    final newInstance = await _createNewInstance(duration);
    _setInstance(duration, newInstance);
    await _persist(duration, newInstance);
  }

  void _setInstance(ChallengeDuration duration, ChallengeInstance instance) {
    _notifiers[duration]!.value = instance;
  }

  Future<void> _persist(
    ChallengeDuration duration,
    ChallengeInstance instance,
  ) async {
    final prefs = _prefs;
    final key = _stateKey(duration);
    await prefs?.setString(key, jsonEncode(instance.toJson()));
  }

  static bool _isExpired(ChallengeDuration duration, DateTime start) {
    final now = DateTime.now();
    switch (duration) {
      case ChallengeDuration.daily:
        return !_isSameDay(start, now);
      case ChallengeDuration.weekly:
        return !_isSameWeek(start, now);
    }
  }

  static DateTime _startForDuration(
    ChallengeDuration duration,
    DateTime reference,
  ) {
    switch (duration) {
      case ChallengeDuration.daily:
        return DateTime(reference.year, reference.month, reference.day);
      case ChallengeDuration.weekly:
        final weekday = reference.weekday; // Monday = 1
        final monday = reference.subtract(Duration(days: weekday - 1));
        return DateTime(monday.year, monday.month, monday.day);
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _isSameWeek(DateTime a, DateTime b) {
    final startA = _startForDuration(ChallengeDuration.weekly, a);
    final startB = _startForDuration(ChallengeDuration.weekly, b);
    return startA.isAtSameMomentAs(startB);
  }

  String _stateKey(ChallengeDuration duration) {
    switch (duration) {
      case ChallengeDuration.daily:
        return _dailyStateKey;
      case ChallengeDuration.weekly:
        return _weeklyStateKey;
    }
  }

  String _indexKey(ChallengeDuration duration) {
    switch (duration) {
      case ChallengeDuration.daily:
        return _dailyIndexKey;
      case ChallengeDuration.weekly:
        return _weeklyIndexKey;
    }
  }

  /// Returns the number of completed daily challenges.
  int getDailyCompletionCount() => _prefs?.getInt(_dailyCompletionsKey) ?? 0;

  /// Returns the number of completed weekly challenges.
  int getWeeklyCompletionCount() => _prefs?.getInt(_weeklyCompletionsKey) ?? 0;

  /// Returns the total number of completed challenges (daily + weekly).
  int getTotalCompletionCount() =>
      getDailyCompletionCount() + getWeeklyCompletionCount();

  /// Increments the daily challenge completion counter.
  Future<void> _incrementDailyCompletions() async {
    final current = getDailyCompletionCount();
    await _prefs?.setInt(_dailyCompletionsKey, current + 1);
  }

  /// Increments the weekly challenge completion counter.
  Future<void> _incrementWeeklyCompletions() async {
    final current = getWeeklyCompletionCount();
    await _prefs?.setInt(_weeklyCompletionsKey, current + 1);
  }

  /// Checks and unlocks challenge trophies based on completion counts.
  Future<void> _checkChallengeTrophies() async {
    await XpTrophyService.instance.init();
    final service = XpTrophyService.instance;

    final dailyCount = getDailyCompletionCount();
    final weeklyCount = getWeeklyCompletionCount();
    final totalCount = getTotalCompletionCount();

    // Daily Grinder trophies: 7, 30, 100
    if (dailyCount >= 7 && !service.has(XpTrophy.dailyGrinderBronze)) {
      service.unlock(XpTrophy.dailyGrinderBronze);
    }
    if (dailyCount >= 30 && !service.has(XpTrophy.dailyGrinderSilver)) {
      service.unlock(XpTrophy.dailyGrinderSilver);
    }
    if (dailyCount >= 100 && !service.has(XpTrophy.dailyGrinderGold)) {
      service.unlock(XpTrophy.dailyGrinderGold);
    }

    // Weekly Warrior trophies: 4, 12, 52
    if (weeklyCount >= 4 && !service.has(XpTrophy.weeklyWarriorBronze)) {
      service.unlock(XpTrophy.weeklyWarriorBronze);
    }
    if (weeklyCount >= 12 && !service.has(XpTrophy.weeklyWarriorSilver)) {
      service.unlock(XpTrophy.weeklyWarriorSilver);
    }
    if (weeklyCount >= 52 && !service.has(XpTrophy.weeklyWarriorGold)) {
      service.unlock(XpTrophy.weeklyWarriorGold);
    }

    // Challenge Master trophies: 10, 50, 200
    if (totalCount >= 10 && !service.has(XpTrophy.challengeMasterBronze)) {
      service.unlock(XpTrophy.challengeMasterBronze);
    }
    if (totalCount >= 50 && !service.has(XpTrophy.challengeMasterSilver)) {
      service.unlock(XpTrophy.challengeMasterSilver);
    }
    if (totalCount >= 200 && !service.has(XpTrophy.challengeMasterGold)) {
      service.unlock(XpTrophy.challengeMasterGold);
    }
  }

  Future<void> refresh() async {
    await init();
    await _ensureActive(ChallengeDuration.daily);
    await _ensureActive(ChallengeDuration.weekly);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dailyStateKey);
    await prefs.remove(_weeklyStateKey);
    await prefs.remove(_dailyIndexKey);
    await prefs.remove(_weeklyIndexKey);
    _initialized = false;
    _prefs = null;
    for (final notifier in _notifiers.values) {
      notifier.value = null;
    }
  }

  @visibleForTesting
  Future<void> debugSetStart(ChallengeDuration duration, DateTime start) async {
    await init();
    final current = _notifiers[duration]!.value;
    if (current == null) return;
    final updated = current.copyWith(start: start);
    _setInstance(duration, updated);
    await _persist(duration, updated);
  }

  static final Map<ChallengeDuration, List<ChallengeDefinition>> _definitions =
      {
        ChallengeDuration.daily: const [
          ChallengeDefinition(
            id: 'daily_xp_50',
            title: 'Earn 50 XP today',
            description: 'Complete drills or study content to earn XP.',
            metric: ChallengeMetric.xp,
            goal: 50,
            rewardXp: 15,
            duration: ChallengeDuration.daily,
          ),
          ChallengeDefinition(
            id: 'daily_xp_30',
            title: 'Earn 30 XP today',
            description: 'Stay focused and accumulate 30 XP before midnight.',
            metric: ChallengeMetric.xp,
            goal: 30,
            rewardXp: 10,
            duration: ChallengeDuration.daily,
          ),
        ],
        ChallengeDuration.weekly: const [
          ChallengeDefinition(
            id: 'weekly_xp_250',
            title: 'Earn 250 XP this week',
            description: 'Play consistently across the week to reach 250 XP.',
            metric: ChallengeMetric.xp,
            goal: 250,
            rewardXp: 60,
            duration: ChallengeDuration.weekly,
          ),
          ChallengeDefinition(
            id: 'weekly_xp_400',
            title: 'Earn 400 XP this week',
            description: 'Push yourself for a strong training week.',
            metric: ChallengeMetric.xp,
            goal: 400,
            rewardXp: 90,
            duration: ChallengeDuration.weekly,
          ),
        ],
      };
}
