/// Minimal leaderboard entry used by the profile XP widget.
class LeaderboardEntry {
  final String uid;
  final String displayName;
  final int xp;
  final int rank;
  final bool isMe;

  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.xp,
    required this.rank,
    required this.isMe,
  });
}
