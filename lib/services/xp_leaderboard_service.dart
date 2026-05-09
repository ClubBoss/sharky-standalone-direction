import '../models/xp_leaderboard_entry.dart' as xp;

/// Mock XP leaderboard service used by the profile widget.
class XpLeaderboardService {
  XpLeaderboardService._();

  static List<xp.LeaderboardEntry>? _overrideEntries;

  /// Overrides the default mock leaderboard for tests/dev tooling.
  static void setMockLeaderboardEntries(List<xp.LeaderboardEntry>? entries) {
    _overrideEntries = entries == null ? null : List.unmodifiable(entries);
  }

  /// Returns the injected leaderboard when available, otherwise a default list.
  static List<xp.LeaderboardEntry> fetchTop5() =>
      _overrideEntries ?? _defaultTopFive;

  static List<xp.LeaderboardEntry> get _defaultTopFive => const [
    xp.LeaderboardEntry(
      uid: 'uid_alex',
      displayName: 'Alex P.',
      xp: 15420,
      rank: 1,
      isMe: false,
    ),
    xp.LeaderboardEntry(
      uid: 'uid_maria',
      displayName: 'Maria S.',
      xp: 14850,
      rank: 2,
      isMe: false,
    ),
    xp.LeaderboardEntry(
      uid: 'uid_john',
      displayName: 'John K.',
      xp: 13200,
      rank: 3,
      isMe: false,
    ),
    xp.LeaderboardEntry(
      uid: 'uid_you',
      displayName: 'Player One',
      xp: 12540,
      rank: 4,
      isMe: true,
    ),
    xp.LeaderboardEntry(
      uid: 'uid_emma',
      displayName: 'Emma L.',
      xp: 11980,
      rank: 5,
      isMe: false,
    ),
  ];
}
