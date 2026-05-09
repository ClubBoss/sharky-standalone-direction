class EmotionPreflightV4 {
  const EmotionPreflightV4({
    this.synthesis,
    this.hasMood,
    this.hasTone,
    this.hasArousal,
    this.hasValence,
  });

  final Map<String, Object?>? synthesis;
  final bool? hasMood;
  final bool? hasTone;
  final bool? hasArousal;
  final bool? hasValence;

  Map<String, Object?> asReadOnlyMap() {
    final map = <String, Object?>{};
    if (synthesis != null) map['synthesis'] = synthesis;
    if (hasMood != null) map['hasMood'] = hasMood;
    if (hasTone != null) map['hasTone'] = hasTone;
    if (hasArousal != null) map['hasArousal'] = hasArousal;
    if (hasValence != null) map['hasValence'] = hasValence;
    return map;
  }
}
