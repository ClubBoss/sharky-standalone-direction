class StatGainEvent {
  const StatGainEvent({
    required this.statName,
    required this.deltaXp,
    required this.oldLevel,
    required this.newLevel,
    this.newRank,
  });

  final String statName;
  final double deltaXp;
  final int oldLevel;
  final int newLevel;
  final String? newRank;
}
