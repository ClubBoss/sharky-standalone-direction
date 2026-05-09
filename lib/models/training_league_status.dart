/// Lightweight model for the user's training league state.
class TrainingLeagueStatus {
  final String leagueId;
  final bool joined;
  final int wins;
  final int losses;
  final String rank;

  const TrainingLeagueStatus({
    required this.leagueId,
    required this.joined,
    required this.wins,
    required this.losses,
    required this.rank,
  });

  int get totalMatches => wins + losses;
}
