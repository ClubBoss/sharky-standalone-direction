import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'xp_history_service.dart';
import '../models/xp_league.dart';
import '../widgets/league_level_up_popup.dart';
import 'xp_milestone_service.dart';
import 'xp_trophy_service.dart';
import 'rank_service.dart';
import 'challenge_service.dart';
import 'internal_goals_service.dart';
import 'league_history_service.dart';
import 'goal_orchestrator.dart';
import 'review_reminder_service.dart';
import 'leveling_service.dart';
import '../models/xp_trophy.dart';
import '../widgets/session_medal_popup.dart';
import '../widgets/session_recap_popup.dart';
import 'post_session_review_service.dart';
import 'review_launcher_service.dart';
import 'streak_tracker_service.dart';
import 'booster_service.dart';
import 'session_medal_service.dart';

/// XpService tracks experience points earned per module and in total.
///
/// XP rules:
/// - Viewing theory tab: +1 XP
/// - Completing a drill: +5 XP
/// - Completing a module: +10 XP (awarded only once per module)
class XpService {
  static const String _xpByModuleKey = 'xp_by_module';
  static const String _completedBonusKey = 'xp_completed_bonus';
  static const String _totalXpKey = 'xp_total';
  static const Map<String, double> _sessionMultipliers = {
    'play': 1 / 3,
    'study': 1 / 5,
    'review': 1 / 4,
  };
  static const Map<String, String> _tagRuleMap = {
    'play': 'play',
    'cash': 'play',
    'mtt': 'play',
    'live': 'play',
    'study': 'study',
    'theory': 'study',
    'solver': 'study',
    'review': 'review',
  };

  SharedPreferences? _prefs;
  bool _initialized = false;

  final Map<String, int> _xpByModule = {};
  final Set<String> _completedBonusAwarded = {};
  int _totalXp = 0;

  // Reactive streams
  final StreamController<int> _totalXpController =
      StreamController<int>.broadcast();
  final Map<String, StreamController<int>> _moduleXpControllers = {};

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();

      // Load XP by module
      final xpMapStr = _prefs!.getString(_xpByModuleKey);
      if (xpMapStr != null && xpMapStr.isNotEmpty) {
        final Map<String, dynamic> decoded =
            json.decode(xpMapStr) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          _xpByModule[key] = (value as num).toInt();
        });
      }

      // Load completed bonus set
      final completedList = _prefs!.getStringList(_completedBonusKey) ?? [];
      _completedBonusAwarded.addAll(completedList);

      // Load total or compute
      _totalXp =
          _prefs!.getInt(_totalXpKey) ??
          _xpByModule.values.fold(0, (a, b) => a + b);

      // Prime streams
      _emitTotal();
      for (final id in _xpByModule.keys) {
        _emitModule(id);
      }

      _initialized = true;
    } catch (e) {
      // Fail gracefully
      _initialized = true;
    }
  }

  bool get isInitialized => _initialized;

  int getTotalXp() => _totalXp;
  int getXpForModule(String moduleId) => _xpByModule[moduleId] ?? 0;

  Stream<int> watchTotalXp() => _totalXpController.stream;

  Stream<int> watchXpForModule(String moduleId) {
    final controller = _moduleXpControllers.putIfAbsent(
      moduleId,
      StreamController<int>.broadcast,
    );
    // Emit current value immediately
    scheduleMicrotask(() => controller.add(getXpForModule(moduleId)));
    return controller.stream;
  }

  Future<void> awardTheoryView(String moduleId) async {
    // Determine comeback eligibility (last XP >=5 days ago)
    final history = await XpHistoryService().getHistory();
    DateTime? last;
    for (final e in history) {
      if (last == null || e.timestamp.isAfter(last)) last = e.timestamp;
    }
    final now = DateTime.now();
    final isComebackEligible = last != null && now.difference(last).inDays >= 5;

    await _addXp(moduleId, 1);
    // Log to XP history
    await XpHistoryService().addEvent(type: 'theory_view', amount: 1);

    final updatedHistory = await XpHistoryService().getHistory();
    final weekXp = await _calculateWeeklyXp(now, history: updatedHistory);
    await _checkXpTrophyUnlocks(getTotalXp(), weekXp, updatedHistory);
    if (isComebackEligible) XpTrophyService.instance.unlock(XpTrophy.comeback);
  }

  Future<void> awardDrillCompleted(String moduleId) async {
    final history = await XpHistoryService().getHistory();
    DateTime? last;
    for (final e in history) {
      if (last == null || e.timestamp.isAfter(last)) last = e.timestamp;
    }
    final now = DateTime.now();
    final isComebackEligible = last != null && now.difference(last).inDays >= 5;

    await _addXp(moduleId, 5);
    // Log to XP history
    await XpHistoryService().addEvent(type: 'drill_completed', amount: 5);

    // Update internal goals for drill completion
    InternalGoalsService.instance.onDrillCompleted();

    final updatedHistory = await XpHistoryService().getHistory();
    final weekXp = await _calculateWeeklyXp(now, history: updatedHistory);
    await _checkXpTrophyUnlocks(getTotalXp(), weekXp, updatedHistory);
    if (isComebackEligible) XpTrophyService.instance.unlock(XpTrophy.comeback);
  }

  /// Returns true if the +10 XP bonus was newly awarded, false if it was already granted before.
  Future<bool> awardModuleCompleted(String moduleId) async {
    if (_completedBonusAwarded.contains(moduleId)) {
      return false;
    }
    _completedBonusAwarded.add(moduleId);
    await _saveCompletedSet();
    final history = await XpHistoryService().getHistory();
    DateTime? last;
    for (final e in history) {
      if (last == null || e.timestamp.isAfter(last)) last = e.timestamp;
    }
    final now = DateTime.now();
    final isComebackEligible = last != null && now.difference(last).inDays >= 5;

    await _addXp(moduleId, 10);
    // Log to XP history
    await XpHistoryService().addEvent(type: 'module_completed', amount: 10);

    // Update internal goals for module completion
    InternalGoalsService.instance.onModuleCompleted();

    final updatedHistory = await XpHistoryService().getHistory();
    final weekXp = await _calculateWeeklyXp(now, history: updatedHistory);
    await _checkXpTrophyUnlocks(getTotalXp(), weekXp, updatedHistory);
    if (isComebackEligible) XpTrophyService.instance.unlock(XpTrophy.comeback);
    return true;
  }

  Future<void> awardChallengeXp(String challengeId, int amount) async {
    if (amount <= 0) return;
    await _addXp('challenge_$challengeId', amount);
    await XpHistoryService().addEvent(type: 'challenge', amount: amount);
  }

  Future<void> clearAllXp() async {
    _xpByModule.clear();
    _completedBonusAwarded.clear();
    _totalXp = 0;
    await _prefs?.remove(_xpByModuleKey);
    await _prefs?.remove(_completedBonusKey);
    await _prefs?.remove(_totalXpKey);
    _emitTotal();
  }

  static Future<int> computeSessionXp(int minutes, {List<String>? tags}) async {
    final clampedMinutes = minutes.clamp(1, 480).toInt();
    final normalized = tags?.map((t) => t.toLowerCase()).toList() ?? const [];
    final key = normalized
        .map((tag) => _tagRuleMap[tag])
        .whereType<String>()
        .firstWhere((_) => true, orElse: () => 'play');
    final multiplier = _sessionMultipliers[key] ?? _sessionMultipliers['play']!;
    var xp = (clampedMinutes * multiplier).floor();
    if (xp < 1) xp = 1;

    // Apply booster multiplier if active and tags match
    final boosterService = BoosterService.getInstance();
    await boosterService.init();
    final activeBooster = await boosterService.getActive();
    if (activeBooster != null &&
        boosterService.matchesTags(activeBooster.type, normalized)) {
      xp = (xp * boosterService.multiplier).round();
    }

    return xp;
  }

  Future<int> awardSessionXp({
    required int durationMinutes,
    List<String>? tags,
  }) async {
    if (durationMinutes <= 0) return 0;
    if (!_initialized) {
      await initialize();
    }
    final xp = await computeSessionXp(durationMinutes, tags: tags);
    await _addXp('session_log', xp);
    await XpHistoryService().addEvent(type: 'session_log', amount: xp);

    // Award session medal and persist to history
    await SessionMedalService.instance.awardMedal(
      sessionXp: xp,
      durationMinutes: durationMinutes,
    );

    // Session Medals popup (non-persistent): compute and show after award
    // Defer to next microtask to ensure overlay can mount
    unawaited(
      Future.microtask(
        () => SessionMedalPopup.maybeShowAfterSession(
          sessionXp: xp,
          durationMinutes: durationMinutes,
        ),
      ),
    );

    // Post-session recap popup after medals (about 2.3s later)
    unawaited(
      Future.delayed(const Duration(milliseconds: 2300), () async {
        try {
          // Compute medals again to include in recap
          int currentStreak = 0;
          try {
            final stats = await StreakTrackerService().compute();
            currentStreak = stats.currentStreak;
          } catch (_) {}
          final medals = SessionMedalRules.compute(
            sessionXp: xp,
            durationMinutes: durationMinutes,
            currentStreak: currentStreak,
          );
          bool showReviewCTA = false;
          try {
            // Check if there are mistakes from the most recent session
            final postSessionService = PostSessionReviewService.instance;
            if (postSessionService.shouldShowCTA()) {
              showReviewCTA = true;
            } else {
              // Fallback to periodic review reminders
              final reviewService = ReviewReminderService();
              showReviewCTA = await reviewService.shouldPromptReview();
              if (showReviewCTA) {
                unawaited(reviewService.scheduleReviewNotification());
              }
            }
          } catch (_) {}
          unawaited(
            SessionRecapPopup.show(
              sessionXp: xp,
              durationMinutes: durationMinutes,
              tags: tags,
              currentStreak: currentStreak,
              medals: medals,
              showReviewReminder: showReviewCTA,
              onReviewRequested: () async {
                final postSessionService = PostSessionReviewService.instance;
                final mistakeSpotIds = postSessionService.getMistakeSpots();

                if (mistakeSpotIds.isEmpty) {
                  log('[PostSessionReview] No mistakes to review');
                  return;
                }

                // Launch review session with mistake spots
                try {
                  final entries = mistakeSpotIds
                      .map(
                        (id) => ReviewModuleEntry(
                          moduleId: id,
                          title: id, // Spot ID used as title
                        ),
                      )
                      .toList();

                  final context =
                      SessionRecapPopup.navigatorKey?.currentContext;
                  if (context != null) {
                    await ReviewLauncherService.instance.launchMultiple(
                      context,
                      entries,
                    );

                    // Clear mistakes after launching review
                    postSessionService.clearMistakes();
                    log(
                      '[PostSessionReview] Launched review for ${mistakeSpotIds.length} mistakes',
                    );
                  }
                } catch (e) {
                  log('[PostSessionReview] Error launching review: $e');
                }
              },
            ),
          );
        } catch (_) {}
      }),
    );
    return xp;
  }

  Future<void> _checkStreakTrophy() async {
    final stats = await StreakTrackerService().compute();
    if (stats.currentStreak >= 7) {
      final service = XpTrophyService.instance;
      await service.init();
      if (!service.has(XpTrophy.streakMaster)) {
        service.unlock(XpTrophy.streakMaster);
      }
    }
  }

  Future<void> _addXp(String moduleId, int amount) async {
    if (!_initialized) {
      await initialize();
    }
    final previousXp = _totalXp;
    final previousLeague = XpLeagueExt.fromXp(previousXp);

    _xpByModule[moduleId] = (_xpByModule[moduleId] ?? 0) + amount;
    _totalXp += amount;
    await _saveXpMap();
    await _saveTotal();
    _emitModule(moduleId);
    _emitTotal();

    // Update daily goal progress through orchestrator facade
    unawaited(GoalOrchestrator.instance.incrementProgress(amount));

    // Re-evaluate XP-related trophies after this addition
    try {
      final history = await XpHistoryService().getHistory();
      final now = DateTime.now();
      final weekXp = await _calculateWeeklyXp(now, history: history);
      await _checkXpTrophyUnlocks(_totalXp, weekXp, history);
    } catch (_) {}
    await _checkStreakTrophy();

    // Check level milestone trophies
    unawaited(LevelingService.instance.checkLevelTrophies());

    _checkMilestones();

    // Update rank based on new total XP
    await RankService.instance.updateRank(_totalXp);

    // Update weekly challenge progress
    await ChallengeService.instance.onXpAwarded(amount: amount);

    // Update internal goals progress
    InternalGoalsService.instance.onXpAwarded(amount);

    final newLeague = XpLeagueExt.fromXp(_totalXp);
    if (newLeague != previousLeague && _totalXp > 0) {
      LeagueLevelUpPopup.show(newLeague);
      await LeagueHistoryService.instance.recordPromotion(
        newLeague,
        DateTime.now(),
      );
    }
  }

  // Check if new milestones have been reached (background tracking only)
  void _checkMilestones() {
    // Fire-and-forget milestone check
    // UI will query XpMilestoneService separately for display
    XpMilestoneService().getUnlockedButUnclaimedMilestones(_totalXp);
  }

  Future<void> _saveXpMap() async {
    try {
      final mapStr = json.encode(_xpByModule);
      await _prefs?.setString(_xpByModuleKey, mapStr);
    } catch (_) {}
  }

  Future<void> _saveCompletedSet() async {
    try {
      await _prefs?.setStringList(
        _completedBonusKey,
        _completedBonusAwarded.toList(),
      );
    } catch (_) {}
  }

  Future<void> _saveTotal() async {
    try {
      await _prefs?.setInt(_totalXpKey, _totalXp);
    } catch (_) {}
  }

  Future<int> _calculateWeeklyXp(DateTime now, {List<XpEvent>? history}) async {
    final weekHistory = history ?? await XpHistoryService().getHistory();
    final weekday = now.weekday; // 1 = Monday
    final monday = now.subtract(Duration(days: weekday - 1));
    final mondayNormalized = DateTime(monday.year, monday.month, monday.day);
    int total = 0;
    for (final e in weekHistory) {
      final eventDate = DateTime(
        e.timestamp.year,
        e.timestamp.month,
        e.timestamp.day,
      );
      if (!eventDate.isBefore(mondayNormalized)) total += e.amount;
    }
    return total;
  }

  Future<void> _checkXpTrophyUnlocks(
    int totalXp,
    int weekXp,
    List<XpEvent> history,
  ) async {
    final service = XpTrophyService.instance;
    await service.init();
    int drillCount = 0;
    int theoryCount = 0;
    int moduleCount = 0;
    for (final event in history) {
      switch (event.type) {
        case 'drill_completed':
          drillCount++;
          break;
        case 'theory_view':
          theoryCount++;
          break;
        case 'module_completed':
          moduleCount++;
          break;
      }
    }
    if (totalXp > 0 && !service.has(XpTrophy.firstXp)) {
      service.unlock(XpTrophy.firstXp);
    }
    if (totalXp >= 25 && !service.has(XpTrophy.milestone25)) {
      service.unlock(XpTrophy.milestone25);
    }
    if (totalXp >= 1000 && !service.has(XpTrophy.xp1000)) {
      service.unlock(XpTrophy.xp1000);
    }
    if (totalXp >= 5000 && !service.has(XpTrophy.xp5000)) {
      service.unlock(XpTrophy.xp5000);
    }
    if (totalXp >= 10000 && !service.has(XpTrophy.xp10000)) {
      service.unlock(XpTrophy.xp10000);
    }
    if (weekXp >= 5 && !service.has(XpTrophy.weekly5)) {
      service.unlock(XpTrophy.weekly5);
    }
    if (moduleCount >= 1 && !service.has(XpTrophy.firstModule)) {
      service.unlock(XpTrophy.firstModule);
    }
    if (drillCount >= 10 && !service.has(XpTrophy.tenDrills)) {
      service.unlock(XpTrophy.tenDrills);
    }
    if (theoryCount >= 5 && !service.has(XpTrophy.theoryReader)) {
      service.unlock(XpTrophy.theoryReader);
    }
  }

  void _emitTotal() {
    if (!_totalXpController.isClosed) {
      _totalXpController.add(_totalXp);
    }
  }

  void _emitModule(String moduleId) {
    final c = _moduleXpControllers[moduleId];
    if (c != null && !c.isClosed) {
      c.add(getXpForModule(moduleId));
    }
  }

  Future<void> dispose() async {
    for (final c in _moduleXpControllers.values) {
      await c.close();
    }
    await _totalXpController.close();
  }
}
