class QAComponentsV3 {
  QAComponentsV3();

  String validateComponents(Map<String, String> styleMap) {
    final buffer = StringBuffer('=== COMPONENT FAMILY QA ===');
    styleMap.forEach((key, style) {
      final segments = style.split('|');
      String status = 'OK';
      if (segments.length != 6) {
        status = 'FAIL(invalid segment count)';
      } else if (!segments[0].startsWith('surface.')) {
        status = 'FAIL(bad surface token)';
      } else if (!segments[1].startsWith('motion.')) {
        status = 'FAIL(bad motion token)';
      } else if (!segments[2].startsWith('fusion.')) {
        status = 'FAIL(bad fusion token)';
      }
      buffer.writeln();
      buffer.writeln('$key: $status');
    });
    return buffer.toString().trimRight();
  }
}
