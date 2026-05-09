class TableState {
  final List<String> heroCards;
  final List<String> communityCards;
  final int potSize;
  final int heroStack;
  final String villainAction;

  const TableState({
    required this.heroCards,
    required this.communityCards,
    required this.potSize,
    required this.heroStack,
    required this.villainAction,
  });
}
