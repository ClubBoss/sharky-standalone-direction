Map<String, double> applyPersonaSRLink({
  required Map<String, double> baseScores,
  required Map<String, Object?> persona,
  required Map<String, List<Map<String, Object?>>> srQueues,
}) {
  final priorityIds = _queueIds(srQueues['priority']);
  final decayIds = _queueIds(srQueues['decay']);
  final itemLookup = <String, Map<String, Object?>>{};
  for (final queue in srQueues.values) {
    for (final item in queue) {
      final id = item['id'];
      if (id is String) {
        itemLookup[id] = item;
      }
    }
  }

  final riskAvoidant = persona['risk_avoidant'] == true;
  final patternSeeker = persona['pattern_seeker'] == true;
  final adjusted = <String, double>{};

  for (final entry in baseScores.entries) {
    var score = entry.value;
    final id = entry.key;
    if (priorityIds.contains(id)) {
      score += 0.2;
    }
    if (decayIds.contains(id)) {
      score -= 0.2;
    }

    final item = itemLookup[id];
    if (item != null) {
      if (riskAvoidant && _isIcmCandidate(item)) {
        score += 0.2;
      }
      if (patternSeeker && _hasTag(item, 'pattern')) {
        score += 0.2;
      }
    }

    adjusted[id] = score;
  }

  return adjusted;
}

Set<String> _queueIds(List<Map<String, Object?>>? queue) {
  if (queue == null) {
    return const {};
  }
  return queue.map((item) => item['id']).whereType<String>().toSet();
}

bool _isIcmCandidate(Map<String, Object?> item) {
  final source = item['source'];
  if (source is String && source.toLowerCase() == 'icm_l4') {
    return true;
  }
  final spot = item['spot_kind'];
  if (spot is String && spot.toLowerCase().contains('icm')) {
    return true;
  }
  return false;
}

bool _hasTag(Map<String, Object?> item, String tag) {
  final tags = item['tags'];
  if (tags is Iterable) {
    for (final raw in tags) {
      if (raw is String && raw.toLowerCase() == tag) {
        return true;
      }
    }
  }
  return false;
}
