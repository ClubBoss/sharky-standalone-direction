Map<String, List<Map<String, Object?>>> buildQueues(
  List<Map<String, Object?>> items,
) {
  final fresh = <Map<String, Object?>>[];
  final priority = <Map<String, Object?>>[];
  final decay = <Map<String, Object?>>[];

  final priorityTags = {'pressure', 'premium', 'stack'};
  final decayTags = {'decay', 'risk'};

  for (final raw in items) {
    final difficulty = _parseDifficulty(raw['difficulty']);
    final tags = _extractTags(raw['tags']);

    if (difficulty == 1 || difficulty == 0) {
      fresh.add(raw);
    }
    if (difficulty >= 2 || tags.any(priorityTags.contains)) {
      priority.add(raw);
    }
    if (difficulty == 3 || tags.any(decayTags.contains)) {
      decay.add(raw);
    }
  }

  return {'fresh': fresh, 'priority': priority, 'decay': decay};
}

int _parseDifficulty(Object? difficulty) {
  if (difficulty is int) {
    return difficulty;
  }
  if (difficulty is String) {
    return int.tryParse(difficulty) ?? 0;
  }
  return 0;
}

List<String> _extractTags(Object? tags) {
  if (tags is List) {
    return tags.whereType<String>().toList();
  }
  return const <String>[];
}
