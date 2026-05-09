import 'recommendation_scoring_v1.dart';

List<Map<String, Object?>> generateRecommendations({
  required List<Map<String, Object?>> srItems,
  required Map<String, Object?> persona,
  int limit = 10,
}) {
  final scored = srItems
      .map((item) => MapEntry(item, scoreItem(srItem: item, persona: persona)))
      .toList();

  scored.sort((a, b) => b.value.compareTo(a.value));

  return scored.take(limit).map((entry) {
    final result = Map<String, Object?>.from(entry.key);
    result['score'] = entry.value;
    return result;
  }).toList();
}
