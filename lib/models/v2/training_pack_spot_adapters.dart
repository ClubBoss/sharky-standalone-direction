import 'spot/barrel.dart';
import 'training_pack_spot_v2.dart';

TrainingPackSpotV2 fromLegacyJson(Map<String, Object?> json) {
  final handMap = json['hand'];
  final hand = handMap is Map
      ? SpotHandData.fromJson(
          handMap.map((key, value) => MapEntry(key.toString(), value)),
        )
      : const SpotHandData();
  final level = (json['priority'] as num?)?.toInt() ?? 0;
  final position = json['position']?.toString() ?? hand.position;
  final tags = _stringList(json['tags']);
  final range = _doubleMap(
    json['range'] ??
        (json['meta'] is Map ? (json['meta'] as Map)['range'] : null),
  );
  final decision = HeroDecision.fromJson({
    'action': json['correctAction'],
    'notes': json['explanation'],
    'options': json['heroOptions'],
    'villainAction': json['villainAction'],
    'street': json['street'],
  });
  final evaluation = json['evalResult'] is Map
      ? SpotEvaluationResult.fromJson(
          (json['evalResult'] as Map).map((k, v) => MapEntry(k.toString(), v)),
        )
      : null;

  final meta = SpotMeta.fromJson({
    'title': json['title'],
    'note': json['note'],
    'type': json['type'],
    'categories': json['categories'],
    'templateSourceId': json['templateSourceId'],
    'inlineLessonId': json['inlineLessonId'] ?? json['inlineTheoryId'],
    'theoryId': json['theoryId'],
    'theoryRefs': json['theoryRefs'],
    'theoryNote': json['theoryNote'],
    'isTheoryNote': json['isTheoryNote'],
    'isInjected': json['isInjected'],
    'createdAt': json['createdAt'],
    'editedAt': json['editedAt'],
    'pinned': json['pinned'],
    'meta': json['meta'],
  });

  return TrainingPackSpotV2(
    id: json['id']?.toString() ?? '',
    level: level,
    position: position,
    tags: tags,
    hand: hand,
    decision: decision,
    evaluation: evaluation,
    range: range,
    meta: meta,
    isNew: json['isNew'] == true,
  );
}

Map<String, Object?> toLegacyJson(TrainingPackSpotV2 spot) {
  final map = <String, Object?>{
    'id': spot.id,
    'priority': spot.level,
    'position': spot.position,
    'tags': spot.tags,
    'isNew': spot.isNew,
    'hand': spot.hand.toJson(),
    'range': spot.range,
  };
  final decision = spot.decision;
  if (decision != null) {
    map['correctAction'] = decision.action;
    map['explanation'] = decision.explanation;
    if (decision.options.isNotEmpty) {
      map['heroOptions'] = decision.options;
    }
    if (decision.villainAction != null) {
      map['villainAction'] = decision.villainAction;
    }
    if (decision.street != 0) {
      map['street'] = decision.street;
    }
  }
  final evaluation = spot.evaluation;
  if (evaluation != null) {
    map['evalResult'] = evaluation.toJson();
  }
  final extras = spot.meta.toJson();
  map.addAll({
    'title': extras['title'],
    'note': extras['note'],
    'type': extras['type'],
    'categories': extras['categories'],
    'templateSourceId': extras['templateSourceId'],
    'inlineLessonId': extras['inlineLessonId'],
    'inlineTheoryId': extras['inlineLessonId'],
    'theoryId': extras['theoryId'],
    'theoryRefs': extras['theoryRefs'],
    'theoryNote': extras['theoryNote'],
    'isTheoryNote': extras['isTheoryNote'],
    'isInjected': extras['isInjected'],
    'createdAt': extras['createdAt'],
    'editedAt': extras['editedAt'],
    'pinned': extras['pinned'],
    'meta': extras['meta'] is Map ? extras['meta'] : null,
  });
  map.removeWhere((key, value) => value == null);
  return map;
}

List<String> _stringList(Object? value) {
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return const [];
}

Map<String, double> _doubleMap(Object? source) {
  if (source is Map) {
    final result = <String, double>{};
    for (final entry in source.entries) {
      final number = entry.value as num?;
      if (number != null) {
        result[entry.key.toString()] = number.toDouble();
      }
    }
    return result;
  }
  return const {};
}
