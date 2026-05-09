/// Represents a player entry on the training league leaderboard.
class TrainingLeagueMember {
  final int rank;
  final String displayName;
  final int xp;
  final bool isMe;

  const TrainingLeagueMember({
    required this.rank,
    required this.displayName,
    required this.xp,
    required this.isMe,
  });
}
