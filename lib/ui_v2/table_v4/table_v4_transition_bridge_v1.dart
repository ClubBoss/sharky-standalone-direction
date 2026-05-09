class TableV4TransitionBridgeV1 {
  static Map<String, Object> build({
    Map<String, Object?>? onboardingMap,
    Map<String, Object?>? emotionMap,
    Map<String, Object?>? textHintMap,
  }) {
    final String mood = (emotionMap?['mood'] as String? ?? '').toLowerCase();
    final String hint =
        (textHintMap?['text_hint_refinement_v1']
                as Map<String, Object?>?)?['status_hint']
            as String? ??
        '';
    final String asciiMood = _ascii(mood);
    final String asciiHint = _ascii(hint);
    final bool ready = asciiMood.isNotEmpty && asciiHint.isNotEmpty;
    return <String, Object>{
      'transition_bridge_v1': <String, Object>{
        'fade_in_ms': 220,
        'delay_ms': 90,
        'mood_tag': asciiMood,
        'hint_tag': asciiHint,
        'ready': ready,
      },
    };
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
