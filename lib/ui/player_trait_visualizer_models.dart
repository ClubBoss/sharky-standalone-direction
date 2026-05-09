class TraitGainEvent {
  const TraitGainEvent({
    required this.name,
    required this.rarity,
    required this.description,
    required this.temporary,
  });

  final String name;
  final String rarity;
  final String description;
  final bool temporary;
}
