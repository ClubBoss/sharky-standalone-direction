double scoreItem({
  required Map<String, Object?> srItem,
  required Map<String, Object?> persona,
}) {
  var score = 1.0;
  final difficulty = _parseDifficulty(srItem['difficulty']);
  final tags = _extractTags(srItem['tags']);
  final sources = _extractSources(srItem);

  if (difficulty >= 2) {
    score += 0.5;
  }
  if (difficulty == 3) {
    score += 1.0;
  }
  if (tags.contains('pressure') || tags.contains('premium')) {
    score += 0.3;
  }
  if (tags.contains('pattern')) {
    score += 0.2;
  }
  if (tags.contains('stack')) {
    score += 0.2;
  }

  if (persona['risk_avoidant'] == true && _isIcmCandidate(srItem, sources)) {
    score += 0.4;
  }
  if (persona['pattern_seeker'] == true && tags.contains('pattern')) {
    score += 0.4;
  }

  return score;
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

Set<String> _extractTags(Object? tags) {
  if (tags is Iterable) {
    return tags.whereType<String>().map((tag) => tag.toLowerCase()).toSet();
  }
  return const <String>{};
}

Set<String> _extractSources(Map<String, Object?> srItem) {
  final source = srItem['source'];
  if (source is String) {
    return {source.toLowerCase()};
  }
  return const <String>{};
}

bool _isIcmCandidate(Map<String, Object?> srItem, Set<String> sources) {
  if (sources.contains('icm_l4')) {
    return true;
  }
  final spotKind = srItem['spot_kind'];
  if (spotKind is String && spotKind.toLowerCase().contains('icm')) {
    return true;
  }
  return false;
}
