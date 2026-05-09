import 'dart:math';

/// Engine for simulating weekly competitive leagues.
///
/// Generates fake opponents and ranks all players by XP, assigning
/// promotion/demotion status based on league cutoffs.
///
/// Inspired by Duolingo's league system with client-only logic.
class LeagueEngine {
  final Random _random;

  /// Creates a league engine with optional seed for deterministic testing.
  LeagueEngine({int? seed}) : _random = Random(seed);

  /// Simulates a weekly league with 49 fake users + the current user.
  ///
  /// Returns a sorted list of 50 entries by XP descending.
  /// Top 10 are marked for promotion, bottom 10 for demotion.
  ///
  /// Parameters:
  /// - [userXp]: Current user's total XP
  /// - [userId]: User identifier (defaults to "user")
  /// - [weekSeed]: Optional seed for reproducible opponent generation
  List<LeagueEntry> simulateWeeklyLeague({
    required int userXp,
    String userId = 'user',
    int? weekSeed,
  }) {
    final effectiveRandom = weekSeed != null ? Random(weekSeed) : _random;

    // Generate 49 fake opponents
    final entries = <LeagueEntry>[];
    for (int i = 0; i < 49; i++) {
      final xp = _generateOpponentXp(userXp, effectiveRandom);
      entries.add(
        LeagueEntry(
          name: 'Игрок ${1000 + effectiveRandom.nextInt(9000)}',
          xp: xp,
          rank: 0, // Will be assigned after sorting
          isUser: false,
        ),
      );
    }

    // Add current user
    entries.add(LeagueEntry(name: 'Вы', xp: userXp, rank: 0, isUser: true));

    // Sort by XP descending
    entries.sort((a, b) => b.xp.compareTo(a.xp));

    // Assign ranks and promotion/demotion status
    for (int i = 0; i < entries.length; i++) {
      final rank = i + 1;
      final status = _determineStatus(rank);

      entries[i] = LeagueEntry(
        name: entries[i].name,
        xp: entries[i].xp,
        rank: rank,
        isUser: entries[i].isUser,
        status: status,
      );
    }

    return entries;
  }

  /// Generates a fake opponent's XP around the user's XP level.
  ///
  /// Distribution:
  /// - 40% slightly below user (-50 to -10 XP)
  /// - 30% slightly above user (+10 to +100 XP)
  /// - 20% significantly above user (+100 to +300 XP)
  /// - 10% significantly below user (-200 to -50 XP)
  int _generateOpponentXp(int userXp, Random random) {
    final roll = random.nextDouble();

    if (roll < 0.4) {
      // Slightly below
      return (userXp - 50 - random.nextInt(40))
          .clamp(10, double.infinity)
          .toInt();
    } else if (roll < 0.7) {
      // Slightly above
      return userXp + 10 + random.nextInt(90);
    } else if (roll < 0.9) {
      // Significantly above
      return userXp + 100 + random.nextInt(200);
    } else {
      // Significantly below
      return (userXp - 200 + random.nextInt(150))
          .clamp(10, double.infinity)
          .toInt();
    }
  }

  /// Determines promotion/demotion/safe status based on rank.
  LeagueStatus _determineStatus(int rank) {
    if (rank <= 10) {
      return LeagueStatus.promoted;
    } else if (rank >= 41) {
      return LeagueStatus.demoted;
    } else {
      return LeagueStatus.safe;
    }
  }
}

/// Represents a single entry in the league standings.
class LeagueEntry {
  final String name;
  final int xp;
  final int rank;
  final bool isUser;
  final LeagueStatus status;

  LeagueEntry({
    required this.name,
    required this.xp,
    required this.rank,
    required this.isUser,
    this.status = LeagueStatus.safe,
  });
}

/// Status of a player in the league (promotion/demotion/safe).
enum LeagueStatus {
  promoted, // Top 10: advance to higher league
  safe, // Middle 30: stay in current league
  demoted, // Bottom 10: drop to lower league
}
