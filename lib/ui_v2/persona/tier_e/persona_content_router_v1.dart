class PersonaContentRouterV1 {
  const PersonaContentRouterV1({
    this.personaTableAdapterMap = const <String, Object>{},
    this.cSeriesRuntimeEntrySurface = const <String, Object>{},
    this.mttRuntimeEntrySurface = const <String, Object>{},
  });

  PersonaContentRouterV1.fromInputs({
    Map<String, Object?>? personaTableAdapterMap,
    Map<String, Object?>? cSeriesRuntimeEntrySurface,
    Map<String, Object?>? mttRuntimeEntrySurface,
  }) : this(
         personaTableAdapterMap: _safe(personaTableAdapterMap),
         cSeriesRuntimeEntrySurface: _safe(cSeriesRuntimeEntrySurface),
         mttRuntimeEntrySurface: _safe(mttRuntimeEntrySurface),
       );

  final Map<String, Object> personaTableAdapterMap;
  final Map<String, Object> cSeriesRuntimeEntrySurface;
  final Map<String, Object> mttRuntimeEntrySurface;

  Map<String, Object> build() {
    final Map<String, Object?> adapterBody =
        personaTableAdapterMap['persona_table_adapter_v1']
            as Map<String, Object?>? ??
        <String, Object?>{};
    final String tag =
        (adapterBody['table_persona_tag'] as String? ?? 'adaptive_neutral')
            .toLowerCase();
    String route = 'neutral';
    if (tag.contains('cseries')) {
      route = 'c_series';
    } else if (tag.contains('mtt')) {
      route = 'mtt';
    }
    final String reason =
        'from_tag_${tag.replaceAll(RegExp(r'[^a-z0-9_]'), '')}';
    return <String, Object>{
      'persona_content_router_v1': <String, Object>{
        'route': _ascii(route),
        'reason': _ascii(reason),
        'ready': true,
      },
    };
  }

  static Map<String, Object> _safe(Map<String, Object?>? source) {
    if (source == null) return const <String, Object>{};
    final Map<String, Object> result = <String, Object>{};
    for (final MapEntry<String, Object?> entry in source.entries) {
      result[entry.key] = entry.value ?? '';
    }
    return result;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
