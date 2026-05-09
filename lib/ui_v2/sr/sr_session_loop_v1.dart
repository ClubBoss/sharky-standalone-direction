Map<String, Object?>? nextSRItemOrNull(List<Map<String, Object?>> items) {
  if (items.isEmpty) return null;
  Map<String, Object?>? candidate;
  for (final item in items) {
    final seen = _asInt(item['seen']);
    if (candidate == null) {
      candidate = item;
      continue;
    }
    final candidateSeen = _asInt(candidate['seen']);
    if (seen < candidateSeen) {
      candidate = item;
      continue;
    }
    if (seen == candidateSeen) {
      final id = _asString(item['id']);
      final candidateId = _asString(candidate['id']);
      if (id.isNotEmpty &&
          candidateId.isNotEmpty &&
          id.compareTo(candidateId) < 0) {
        candidate = item;
      }
    }
  }
  return candidate;
}

Map<String, Object?> recordSRAnswer(Map<String, Object?> item, String answer) {
  final seen = _asInt(item['seen']);
  final updated = <String, Object?>{};
  updated.addAll(item);
  updated['seen'] = seen + 1;
  updated['last_answer'] = answer;
  return updated;
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
  }
  return 0;
}

String _asString(Object? value) {
  if (value is String) return value;
  if (value is Object) return value.toString();
  return '';
}
