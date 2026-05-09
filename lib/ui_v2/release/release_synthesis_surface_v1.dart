class ReleaseSynthesisSurfaceV1 {
  const ReleaseSynthesisSurfaceV1({
    this.bridge = const <String, Object>{},
    this.normalizer = const <String, Object>{},
    this.consistency = const <String, Object>{},
    this.stability = const <String, Object>{},
    this.flags = const <String, Object>{},
    this.personaAlignment = const <String, Object>{},
    this.v4ToV3 = const <String, Object>{},
    this.preRCSweep = const <String, Object>{},
  });

  ReleaseSynthesisSurfaceV1.fromInputs({
    Map<String, Object?>? bridge,
    Map<String, Object?>? normalizer,
    Map<String, Object?>? consistency,
    Map<String, Object?>? stability,
    Map<String, Object?>? flags,
    Map<String, Object?>? personaAlignment,
    Map<String, Object?>? v4ToV3,
    Map<String, Object?>? preRCSweep,
  }) : this(
         bridge: _sanitize(bridge),
         normalizer: _sanitize(normalizer),
         consistency: _sanitize(consistency),
         stability: _sanitize(stability),
         flags: _sanitize(flags),
         personaAlignment: _sanitize(personaAlignment),
         v4ToV3: _sanitize(v4ToV3),
         preRCSweep: _sanitize(preRCSweep),
       );

  final Map<String, Object> bridge;
  final Map<String, Object> normalizer;
  final Map<String, Object> consistency;
  final Map<String, Object> stability;
  final Map<String, Object> flags;
  final Map<String, Object> personaAlignment;
  final Map<String, Object> v4ToV3;
  final Map<String, Object> preRCSweep;

  Map<String, Object> build() {
    final Map<String, bool> sectionsOk = <String, bool>{
      'bridge': _ready(bridge),
      'normalizer': _ready(normalizer),
      'consistency': _ready(consistency),
      'stability': _ready(stability),
      'flags': _ready(flags),
      'persona_alignment': _ready(personaAlignment),
      'v4_to_v3': _ready(v4ToV3),
      'pre_rc_sweep': _ready(preRCSweep),
    };
    final List<String> missingSections =
        sectionsOk.entries
            .where((entry) => !entry.value)
            .map((entry) => entry.key)
            .toList()
          ..sort();
    final List<String> signature = _sortedKeys(<String, Object>{
      ...bridge,
      ...normalizer,
      ...consistency,
      ...stability,
      ...flags,
    });
    final Map<String, Object> merged = <String, Object>{
      'bridge': _ordered(bridge),
      'normalizer': _ordered(normalizer),
      'consistency': _ordered(consistency),
      'stability': _ordered(stability),
      'flags': _ordered(flags),
      'persona_alignment': _ordered(personaAlignment),
      'v4_to_v3': _ordered(v4ToV3),
      'pre_rc_sweep': _ordered(preRCSweep),
    };
    return <String, Object>{
      'synthesis_surface_v1': merged,
      'ready': false,
      'sections_ok': sectionsOk,
      'missing_sections': missingSections,
      'signature': signature,
    };
  }

  static Map<String, Object> _sanitize(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> result = <String, Object>{};
    for (final entry in source.entries) {
      final String key = _ascii(entry.key);
      final Object value = entry.value ?? '';
      result[key] = value is String ? _ascii(value) : value;
    }
    return result;
  }

  static Map<String, Object> _ordered(Map<String, Object> map) {
    final Map<String, Object> ordered = <String, Object>{};
    for (final key in _sortedKeys(map)) {
      ordered[key] = map[key]!;
    }
    return ordered;
  }

  static bool _ready(Map<String, Object> map) {
    final Object? ready = map['ready'];
    return ready is bool && ready;
  }

  static List<String> _sortedKeys(Map<String, Object> map) {
    final List<String> keys = map.keys.toList()..sort();
    return keys;
  }

  static String _ascii(String input) =>
      String.fromCharCodes(input.codeUnits.where((c) => c >= 0 && c < 128));
}
