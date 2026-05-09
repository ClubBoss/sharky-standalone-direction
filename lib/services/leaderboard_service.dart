import 'package:flutter/foundation.dart';
import '../models/leaderboard_entry.dart';
import '../services/xp_tracker_service.dart';

/// Service for managing leaderboard data and rankings.
///
/// Currently returns mock data. Backend integration pending.
///
/// Features:
/// - Global leaderboard (all users)
/// - Friends leaderboard (friends only)
/// - Regional leaderboard (same region)
///
/// TODO: Integrate with Firebase/backend for real-time rankings.
class LeaderboardService extends ChangeNotifier {
  final XPTrackerService _xpService;

  LeaderboardService(this._xpService);

  // Mock data - will be replaced with backend calls
  List<LeaderboardEntry> get globalLeaderboard => _generateMockGlobal();
  List<LeaderboardEntry> get friendsLeaderboard => _generateMockFriends();
  List<LeaderboardEntry> get regionalLeaderboard => _generateMockRegional();

  /// Generates mock global leaderboard data.
  List<LeaderboardEntry> _generateMockGlobal() {
    final currentUserXP = _xpService.xp;
    final currentUserLevel = _xpService.level;

    final entries = <LeaderboardEntry>[
      const LeaderboardEntry(
        rank: 1,
        displayName: 'PokerPro_Alex',
        xp: 15420,
        level: 12,
        isCurrentUser: false,
      ),
      const LeaderboardEntry(
        rank: 2,
        displayName: 'CardShark_Maria',
        xp: 14850,
        level: 11,
        isCurrentUser: false,
      ),
      const LeaderboardEntry(
        rank: 3,
        displayName: 'BluffMaster_John',
        xp: 13200,
        level: 11,
        isCurrentUser: false,
      ),
      const LeaderboardEntry(
        rank: 4,
        displayName: 'ChipLeader_Sarah',
        xp: 12100,
        level: 10,
        isCurrentUser: false,
      ),
      const LeaderboardEntry(
        rank: 5,
        displayName: 'AceHunter_Mike',
        xp: 11500,
        level: 10,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        rank: 6,
        displayName: 'You',
        xp: currentUserXP,
        level: currentUserLevel,
        isCurrentUser: true,
      ),
      const LeaderboardEntry(
        rank: 7,
        displayName: 'RiverRat_Tom',
        xp: 9800,
        level: 9,
        isCurrentUser: false,
      ),
      const LeaderboardEntry(
        rank: 8,
        displayName: 'FlopWizard_Emma',
        xp: 9200,
        level: 9,
        isCurrentUser: false,
      ),
      const LeaderboardEntry(
        rank: 9,
        displayName: 'TurnTitan_David',
        xp: 8500,
        level: 8,
        isCurrentUser: false,
      ),
      const LeaderboardEntry(
        rank: 10,
        displayName: 'ShowdownKing_Leo',
        xp: 7900,
        level: 8,
        isCurrentUser: false,
      ),
    ];

    return entries;
  }

  /// Generates mock friends leaderboard data.
  List<LeaderboardEntry> _generateMockFriends() {
    final currentUserXP = _xpService.xp;
    final currentUserLevel = _xpService.level;

    return [
      const LeaderboardEntry(
        rank: 1,
        displayName: 'CardShark_Maria',
        xp: 14850,
        level: 11,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        rank: 2,
        displayName: 'You',
        xp: currentUserXP,
        level: currentUserLevel,
        isCurrentUser: true,
      ),
      const LeaderboardEntry(
        rank: 3,
        displayName: 'RiverRat_Tom',
        xp: 9800,
        level: 9,
        isCurrentUser: false,
      ),
      const LeaderboardEntry(
        rank: 4,
        displayName: 'TurnTitan_David',
        xp: 8500,
        level: 8,
        isCurrentUser: false,
      ),
    ];
  }

  /// Generates mock regional leaderboard data.
  List<LeaderboardEntry> _generateMockRegional() {
    final currentUserXP = _xpService.xp;
    final currentUserLevel = _xpService.level;

    return [
      const LeaderboardEntry(
        rank: 1,
        displayName: 'BluffMaster_John',
        xp: 13200,
        level: 11,
        isCurrentUser: false,
      ),
      const LeaderboardEntry(
        rank: 2,
        displayName: 'ChipLeader_Sarah',
        xp: 12100,
        level: 10,
        isCurrentUser: false,
      ),
      LeaderboardEntry(
        rank: 3,
        displayName: 'You',
        xp: currentUserXP,
        level: currentUserLevel,
        isCurrentUser: true,
      ),
      const LeaderboardEntry(
        rank: 4,
        displayName: 'FlopWizard_Emma',
        xp: 9200,
        level: 9,
        isCurrentUser: false,
      ),
      const LeaderboardEntry(
        rank: 5,
        displayName: 'ShowdownKing_Leo',
        xp: 7900,
        level: 8,
        isCurrentUser: false,
      ),
    ];
  }

  /// Refreshes leaderboard data from backend.
  ///
  /// TODO: Implement backend API call.
  Future<void> refresh() async {
    // Mock delay to simulate network request
    await Future<void>.delayed(const Duration(seconds: 1));
    notifyListeners();
  }

  /// Fetches user's current global rank.
  ///
  /// TODO: Implement backend API call.
  Future<int> getCurrentRank() async {
    return 6; // Mock rank
  }

  // ==================== Stage 23: Enhanced Leaderboard Support ====================

  /// Get leaderboard status for health dashboard (Stage 23)
  Future<Map<String, dynamic>> getLeaderboardStatus() async {
    try {
      final entries = globalLeaderboard;
      final hasCached = entries.isNotEmpty;

      return {
        'topCount': entries.length,
        'synced': false, // Mock data, not synced with backend
        'cached': hasCached,
        'pass': hasCached,
      };
    } catch (_) {
      return {'topCount': 0, 'synced': false, 'cached': false, 'pass': false};
    }
  }

  /// Submit profile score (Stage 23)
  /// Currently stores in mock data, will integrate with backend
  Future<bool> submitProfileScore({
    required String profileId,
    required String nickname,
    required int totalXp,
    required int level,
    required int achievementCount,
  }) async {
    try {
      // In production, this would submit to Firebase/backend
      // For now, just return success
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Get top N entries (Stage 23)
  Future<List<LeaderboardEntry>> getTopEntries({int limit = 10}) async {
    try {
      return globalLeaderboard.take(limit).toList();
    } catch (_) {
      return [];
    }
  }

  /// Get premium leaderboard (Stage 24)
  ///
  /// Filters leaderboard entries for premium players only.
  /// In production, premium status would be synced from backend.
  /// For now, uses mock data where top 3 players are considered premium.
  Future<List<LeaderboardEntry>> getPremiumLeaderboard({int limit = 10}) async {
    try {
      // Mock: Consider top 3 players as premium for demonstration
      // In production, entries would have isPremium field from backend
      final premiumEntries = globalLeaderboard.take(3).toList();
      return premiumEntries.take(limit).toList();
    } catch (_) {
      return [];
    }
  }
}
