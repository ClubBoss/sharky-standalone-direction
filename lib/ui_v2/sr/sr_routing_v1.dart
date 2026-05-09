import 'sr_session_loop_v1.dart';

Map<String, Object?>? routeNextItemOrNull(
  List<Map<String, Object?>> items, {
  required Map<String, String> personaTraits,
  required Map<String, String> personaInsights,
}) {
  final base = nextSRItemOrNull(items);
  if (base == null) return null;

  final riskAvoidant = personaTraits.values.any(
    (trait) =>
        trait.toLowerCase().contains('risk_avoidant') ||
        trait.toLowerCase().contains('risk avoidant'),
  );
  final hasIcmInsight = personaInsights.values.any(
    (insight) => insight.toLowerCase().contains('icm'),
  );

  final candidatePool = <Map<String, Object?>>[base];
  candidatePool.addAll(items.where((item) => item != base));

  Map<String, Object?> best = base;
  for (final item in candidatePool) {
    final tension = _asDouble(item['tension']);
    final currentTension = _asDouble(best['tension']);
    if (riskAvoidant && tension < currentTension) {
      best = item;
      continue;
    }
    final tags = _asTags(item['tags']);
    final bestTags = _asTags(best['tags']);
    final hasPreferredTag =
        hasIcmInsight &&
        tags.any((tag) => tag.contains('icm') || tag.contains('premium'));
    final bestHasPreferred =
        hasIcmInsight &&
        bestTags.any((tag) => tag.contains('icm') || tag.contains('premium'));
    if (hasPreferredTag && !bestHasPreferred) {
      best = item;
      continue;
    }
    final seen = _asInt(item['seen']);
    final bestSeen = _asInt(best['seen']);
    if (seen < bestSeen) {
      best = item;
      continue;
    }
    if (seen == bestSeen) {
      final id = _asString(item['id']);
      final bestId = _asString(best['id']);
      if (_isAscii(id) && _isAscii(bestId) && id.compareTo(bestId) < 0) {
        best = item;
      }
    }
  }

  return best;
}

double _asDouble(Object? value) {
  if (value is double) return value.isFinite ? value : double.maxFinite;
  if (value is num) return value.toDouble();
  return double.maxFinite;
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is double) return value.truncate();
  if (value is String) {
    final parsedInt = int.tryParse(value);
    if (parsedInt != null) return parsedInt;
    final parsedDouble = double.tryParse(value);
    if (parsedDouble != null) return parsedDouble.toInt();
  }
  return 0;
}

String _asString(Object? value) {
  if (value is String && value.isNotEmpty) return value;
  if (value != null) return value.toString();
  return '';
}

Set<String> _asTags(Object? value) {
  if (value is Iterable) {
    return value.whereType<String>().map((tag) => tag.toLowerCase()).toSet();
  }
  return const <String>{};
}

bool _isAscii(String text) {
  for (final code in text.codeUnits) {
    if (code < 0 || code > 127) return false;
  }
  return true;
}
