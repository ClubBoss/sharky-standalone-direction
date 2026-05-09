class TableV4TextHintRefinementV1 {
  static Map<String, Object> build({
    required Map<String, Object?> labelSurfaceMap,
    Map<String, Object?>? emotionMap,
    Map<String, Object?>? spacingMap,
  }) {
    final String potLabelRaw = labelSurfaceMap['pot_label']?.toString() ?? '';
    final Map<String, Object?> seatLabels =
        (labelSurfaceMap['seat_labels'] as Map<String, Object?>?) ??
        (labelSurfaceMap['seat_labels'] is Map
            ? (labelSurfaceMap['seat_labels'] as Map).cast<String, Object?>()
            : <String, Object?>{});
    final String statusLabelRaw =
        labelSurfaceMap['status_label']?.toString() ?? '';
    final String mood = (emotionMap?['mood']?.toString() ?? '')
        .toLowerCase()
        .trim();
    final bool emotionReady = emotionMap?['ready'] == true;
    final String potHint = 'Pot: ${_normalize(potLabelRaw)}';
    final List<String> seatHints =
        seatLabels.entries
            .map(
              (entry) =>
                  'Seat ${_ascii(entry.key)}: ${_normalize(entry.value?.toString() ?? '')}',
            )
            .toList()
          ..sort();
    String statusHint = 'Status: ${_normalize(statusLabelRaw)}';
    if (emotionReady && mood.isNotEmpty && mood != 'none') {
      statusHint = '$statusHint • ${_ascii(mood)}';
    }
    final bool ready =
        potLabelRaw.isNotEmpty &&
        statusLabelRaw.isNotEmpty &&
        seatLabels.isNotEmpty;
    return <String, Object>{
      'text_hint_refinement_v1': <String, Object>{
        'pot_hint': potHint,
        'seat_hints': seatHints,
        'status_hint': statusHint,
        'ready': ready,
      },
    };
  }

  static String _normalize(String raw) {
    final String trimmed = raw.trim();
    return _ascii(trimmed);
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
