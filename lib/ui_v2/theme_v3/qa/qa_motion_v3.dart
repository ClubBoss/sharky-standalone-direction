class QAMotionV3 {
  const QAMotionV3();

  static const List<String> requiredFusions = [
    'surface.base.1|motion.entry.1',
    'surface.base.2|motion.entry.2',
    'surface.container.1|motion.exit.1',
    'surface.container.2|motion.exit.2',
    'surface.overlay.1|motion.emphasis.1',
    'surface.highlight.1|motion.tempo.1',
  ];

  List<String> validate() {
    final failures = <String>[];
    for (final fusion in requiredFusions) {
      if (fusion.runes.any((code) => code > 127)) {
        failures.add('Non-ASCII fusion entry: $fusion');
      }
    }
    return failures;
  }

  String report() {
    final failures = validate();
    if (failures.isEmpty) {
      return 'OK: Motion Fusion QA passed';
    }
    final buffer = StringBuffer('FAIL: Motion Fusion QA issues');
    for (final failure in failures) {
      buffer.writeln();
      buffer.writeln(failure);
    }
    return buffer.toString();
  }
}
