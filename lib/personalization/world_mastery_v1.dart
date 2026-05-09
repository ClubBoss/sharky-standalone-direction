enum WorldMasteryLevelV1 { bronze, silver, gold }

class WorldMasteryV1 {
  const WorldMasteryV1({required this.level, required this.reason});

  final WorldMasteryLevelV1 level;
  final String reason;
}

WorldMasteryV1 computeWorldMasteryV1({
  required int accuracyPercent,
  required int mistakesCount,
  required bool reviewCleared,
}) {
  final safeAccuracy = accuracyPercent.clamp(0, 100);
  final safeMistakes = mistakesCount < 0 ? 0 : mistakesCount;
  if (safeAccuracy >= 90 && safeMistakes == 0 && reviewCleared) {
    return const WorldMasteryV1(
      level: WorldMasteryLevelV1.gold,
      reason: '90%+ and clean run',
    );
  }
  if (safeAccuracy >= 75 && safeMistakes <= 2) {
    return const WorldMasteryV1(
      level: WorldMasteryLevelV1.silver,
      reason: 'Good accuracy, minor mistakes',
    );
  }
  return const WorldMasteryV1(
    level: WorldMasteryLevelV1.bronze,
    reason: 'Needs more practice',
  );
}
