class PlayerProfileData {
  const PlayerProfileData({
    required this.stats,
    required this.traits,
    required this.generatedAt,
    required this.showTutorial,
  });

  final List<PlayerStatProfile> stats;
  final List<PlayerTraitProfile> traits;
  final String generatedAt;
  final bool showTutorial;

  bool get hasStats => stats.isNotEmpty;
  bool get hasTraits => traits.isNotEmpty;
}

class PlayerStatProfile {
  const PlayerStatProfile({
    required this.id,
    required this.displayName,
    required this.level,
    required this.xp,
    required this.progress,
    required this.rank,
  });

  final String id;
  final String displayName;
  final int level;
  final double xp;
  final double progress;
  final String rank;
}

class PlayerTraitProfile {
  const PlayerTraitProfile({
    required this.name,
    required this.description,
    required this.rarity,
    required this.bonus,
    required this.color,
    required this.temporary,
  });

  final String name;
  final String description;
  final String rarity;
  final String bonus;
  final String color;
  final bool temporary;
}
