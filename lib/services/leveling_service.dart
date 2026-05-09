import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'xp_service.dart';
import 'xp_trophy_service.dart';
import '../models/xp_trophy.dart';

/// Service for calculating player level based on total XP.
/// Level = floor(sqrt(XP / 10))
/// XP required for level N = 10 * N^2
class LevelingService {
  LevelingService._();

  static final LevelingService instance = LevelingService._();

  // Level milestone trophies (append-only)
  static const List<int> _levelMilestones = [1, 5, 10, 25, 50, 100];

  /// Calculate level from total XP.
  /// Formula: Level = floor(sqrt(XP / 10))
  int getLevel(int xp) {
    if (xp <= 0) return 0;
    return (math.sqrt(xp / 10)).floor();
  }

  /// Calculate XP required to reach a specific level.
  /// Formula: XP = 10 * level^2
  int getXpForLevel(int level) {
    if (level <= 0) return 0;
    return 10 * level * level;
  }

  /// Calculate XP needed to reach next level from current XP.
  int getXpToNextLevel(int currentXp) {
    final currentLevel = getLevel(currentXp);
    final nextLevelXp = getXpForLevel(currentLevel + 1);
    return nextLevelXp - currentXp;
  }

  /// Calculate XP already earned towards next level.
  int getXpInCurrentLevel(int currentXp) {
    final currentLevel = getLevel(currentXp);
    final currentLevelXp = getXpForLevel(currentLevel);
    return currentXp - currentLevelXp;
  }

  /// Calculate total XP needed for next level.
  int getXpRequiredForNextLevel(int currentXp) {
    final currentLevel = getLevel(currentXp);
    final nextLevel = currentLevel + 1;
    final currentLevelXp = getXpForLevel(currentLevel);
    final nextLevelXp = getXpForLevel(nextLevel);
    return nextLevelXp - currentLevelXp;
  }

  /// Calculate progress to next level as percentage (0.0 to 1.0).
  double getProgressToNextLevel(int currentXp) {
    final xpInLevel = getXpInCurrentLevel(currentXp);
    final xpRequired = getXpRequiredForNextLevel(currentXp);
    if (xpRequired <= 0) return 1.0;
    return (xpInLevel / xpRequired).clamp(0.0, 1.0);
  }

  /// Get current level from XpService.
  int getCurrentLevel() {
    final xp = XpService().getTotalXp();
    return getLevel(xp);
  }

  /// Get current progress to next level from XpService.
  double getCurrentProgress() {
    final xp = XpService().getTotalXp();
    return getProgressToNextLevel(xp);
  }

  /// Stream of level changes based on XP changes.
  Stream<int> watchLevel() => XpService().watchTotalXp().map(getLevel);

  /// Stream of progress changes based on XP changes.
  Stream<double> watchProgress() =>
      XpService().watchTotalXp().map(getProgressToNextLevel);

  /// Check and unlock level milestone trophies.
  /// Returns list of newly unlocked level trophies.
  Future<List<XpTrophy>> checkLevelTrophies() async {
    final currentLevel = getCurrentLevel();
    final trophyService = XpTrophyService.instance;
    final newlyUnlocked = <XpTrophy>[];

    // Check each milestone
    for (final milestone in _levelMilestones) {
      if (currentLevel >= milestone) {
        final trophy = _getTrophyForLevel(milestone);
        if (trophy != null && !trophyService.has(trophy)) {
          trophyService.unlock(trophy);
          newlyUnlocked.add(trophy);
          log(
            '[LevelingService] Unlocked trophy: $trophy for level $milestone',
          );
        }
      }
    }

    return newlyUnlocked;
  }

  /// Get trophy enum for a specific level milestone.
  XpTrophy? _getTrophyForLevel(int level) {
    switch (level) {
      case 1:
        return XpTrophy.level1;
      case 5:
        return XpTrophy.level5;
      case 10:
        return XpTrophy.level10;
      case 25:
        return XpTrophy.level25;
      case 50:
        return XpTrophy.level50;
      case 100:
        return XpTrophy.level100;
      default:
        return null;
    }
  }

  /// Check if a level is a milestone level.
  bool isMilestoneLevel(int level) => _levelMilestones.contains(level);

  /// Get next milestone level after current level.
  int? getNextMilestone(int currentLevel) {
    for (final milestone in _levelMilestones) {
      if (milestone > currentLevel) {
        return milestone;
      }
    }
    return null; // Already at or past highest milestone
  }

  /// Get formatted level string (e.g., "LVL 42").
  String formatLevel(int level, {required bool isRu}) =>
      isRu ? 'УРОВЕНЬ $level' : 'LVL $level';

  /// Get formatted progress string (e.g., "42/100 XP (42%)").
  String formatProgress(int currentXp, {required bool isRu}) {
    final xpInLevel = getXpInCurrentLevel(currentXp);
    final xpRequired = getXpRequiredForNextLevel(currentXp);
    final percentage = (getProgressToNextLevel(currentXp) * 100).toInt();

    if (isRu) {
      return '$xpInLevel/$xpRequired XP ($percentage%)';
    } else {
      return '$xpInLevel/$xpRequired XP ($percentage%)';
    }
  }

  /// Get milestone trophies list.
  static List<int> get milestones => List.unmodifiable(_levelMilestones);
}
