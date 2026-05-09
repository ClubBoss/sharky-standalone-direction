import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'spot/barrel.dart';

@immutable
class TrainingPackSpotV2 {
  TrainingPackSpotV2({
    required this.id,
    required this.level,
    required this.position,
    required List<String> tags,
    required this.hand,
    this.decision,
    this.evaluation,
    Map<String, double>? range,
    SpotMeta? meta,
    this.isNew = false,
  }) : tags = List.unmodifiable(tags),
       range = Map.unmodifiable(range ?? const {}),
       meta = meta ?? const SpotMeta.empty();

  factory TrainingPackSpotV2.fromJson(Map<String, Object?> json) =>
      TrainingPackSpotV2(
        id: json['id']?.toString() ?? '',
        level: (json['level'] as num?)?.toInt() ?? 0,
        position: json['position']?.toString() ?? '',
        tags: _stringList(json['tags']),
        hand: SpotHandData.fromJson(_map(json['hand'])),
        decision: json['decision'] is Map
            ? HeroDecision.fromJson(_map(json['decision']))
            : null,
        evaluation: json['evaluation'] is Map
            ? SpotEvaluationResult.fromJson(_map(json['evaluation']))
            : json['evalResult'] is Map
            ? SpotEvaluationResult.fromJson(_map(json['evalResult']))
            : null,
        range: _doubleMap(json['range']),
        meta: SpotMeta.fromJson(json['meta'] ?? json['extra']),
        isNew: json['isNew'] == true,
      );

  final String id;
  final int level;
  final String position;
  final List<String> tags;
  final bool isNew;
  final SpotHandData hand;
  final HeroDecision? decision;
  final SpotEvaluationResult? evaluation;
  final Map<String, double> range;
  final SpotMeta meta;

  Map<String, Object?> toJson() => {
    'id': id,
    'level': level,
    'position': position,
    if (tags.isNotEmpty) 'tags': List<String>.from(tags),
    'isNew': isNew,
    'hand': hand.toJson(),
    if (decision != null) 'decision': decision!.toJson(),
    if (evaluation != null) 'evaluation': evaluation!.toJson(),
    if (range.isNotEmpty) 'range': Map<String, double>.from(range),
    if (meta.toJson().isNotEmpty) 'meta': meta.toJson(),
  };

  TrainingPackSpotV2 copyWith({
    int? level,
    String? position,
    List<String>? tags,
    bool? isNew,
    SpotHandData? hand,
    HeroDecision? decision,
    SpotEvaluationResult? evaluation,
    Map<String, double>? range,
    SpotMeta? meta,
  }) => TrainingPackSpotV2(
    id: id,
    level: level ?? this.level,
    position: position ?? this.position,
    tags: tags ?? this.tags,
    isNew: isNew ?? this.isNew,
    hand: hand ?? this.hand,
    decision: decision ?? this.decision,
    evaluation: evaluation ?? this.evaluation,
    range: range ?? this.range,
    meta: meta ?? this.meta,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingPackSpotV2 &&
          id == other.id &&
          level == other.level &&
          position == other.position &&
          isNew == other.isNew &&
          const ListEquality<String>().equals(tags, other.tags) &&
          hand == other.hand &&
          decision == other.decision &&
          evaluation == other.evaluation &&
          const MapEquality<String, double>().equals(range, other.range) &&
          meta == other.meta;

  @override
  int get hashCode => Object.hash(
    id,
    level,
    position,
    const ListEquality<String>().hash(tags),
    isNew,
    hand,
    decision,
    evaluation,
    const MapEquality<String, double>().hash(range),
    meta,
  );
}

Map<String, Object?> _map(Object? source) {
  if (source is Map) {
    return source.map((key, value) => MapEntry(key.toString(), value));
  }
  return const {};
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
      final numValue = entry.value as num?;
      if (numValue != null) {
        result[entry.key.toString()] = numValue.toDouble();
      }
    }
    return result;
  }
  return const {};
}
