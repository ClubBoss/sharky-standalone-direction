class EmotionEngineTierAV1 {
  const EmotionEngineTierAV1({
    required this.calm,
    required this.focus,
    required this.tension,
  });

  factory EmotionEngineTierAV1.fromMap(Map<String, Object?> data) {
    double _asDouble(String key) {
      final value = data[key];
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    return EmotionEngineTierAV1(
      calm: _asDouble('calm'),
      focus: _asDouble('focus'),
      tension: _asDouble('tension'),
    );
  }

  final double calm;
  final double focus;
  final double tension;

  Map<String, Object> asMap() => Map<String, Object>.unmodifiable({
    'calm': calm,
    'focus': focus,
    'tension': tension,
  });
}
