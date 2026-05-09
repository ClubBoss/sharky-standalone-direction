class TableV4QAFrameDiagnosticsV1 {
  const TableV4QAFrameDiagnosticsV1();

  static Map<String, Object> build({
    required Map<String, Object?> layoutFrameMap,
    Map<String, Object?>? paletteMap,
    Map<String, Object?>? accessibilityMap,
  }) {
    final List<String> issues = <String>[];
    final Object? anchor = layoutFrameMap['anchor'];
    final bool anchorOk = anchor is String && anchor.isNotEmpty;
    if (!anchorOk) {
      issues.add('missing_anchor');
    }
    final double padding = _toDouble(layoutFrameMap['padding_px'], -1.0);
    final bool paddingOk = padding >= 0.0;
    if (!paddingOk) {
      issues.add('invalid_padding');
    }
    final double maxWidth = _toDouble(layoutFrameMap['max_width_px'], 0.0);
    final double maxHeight = _toDouble(layoutFrameMap['max_height_px'], 0.0);
    final bool maxSizeOk = maxWidth > 0.0 && maxHeight > 0.0;
    if (!maxSizeOk) {
      issues.add('invalid_max_size');
    }
    issues.sort();
    return <String, Object>{
      'qa_frame_diagnostics_v1': <String, Object>{
        'anchor_ok': anchorOk,
        'padding_ok': paddingOk,
        'max_size_ok': maxSizeOk,
        'issues': issues,
        'ready': false,
      },
    };
  }

  static double _toDouble(Object? value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return fallback;
  }
}
