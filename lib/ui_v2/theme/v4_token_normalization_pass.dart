class V4TokenNormalizationPass {
  const V4TokenNormalizationPass({required this.input});

  final Map<String, Object> input;

  Map<String, Object> normalize() {
    final normalized = <String, Object>{};
    for (final entry in input.entries) {
      final key = entry.key
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll('-', '_');
      normalized[key] = entry.value;
    }
    return normalized;
  }
}
