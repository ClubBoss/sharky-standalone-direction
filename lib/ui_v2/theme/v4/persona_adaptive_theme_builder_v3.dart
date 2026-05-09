class PersonaAdaptiveThemeBuilderV3 {
  const PersonaAdaptiveThemeBuilderV3({
    required this.themeV4Snapshot,
    required this.builderV2Snapshot,
    required this.cohesionV1Snapshot,
    required this.blendV2Snapshot,
    required this.proxyV2Snapshot,
    required this.personaSnapshot,
    required this.toneV2Snapshot,
    required this.tierASnapshot,
    required this.tierBSnapshot,
  });

  final Map<String, Object> themeV4Snapshot;
  final Map<String, Object> builderV2Snapshot;
  final Map<String, Object> cohesionV1Snapshot;
  final Map<String, Object> blendV2Snapshot;
  final Map<String, Object> proxyV2Snapshot;
  final Map<String, Object> personaSnapshot;
  final Map<String, Object> toneV2Snapshot;
  final Map<String, Object> tierASnapshot;
  final Map<String, Object> tierBSnapshot;

  Map<String, Object> toReadOnlyMap() {
    final builderV3Ok =
        themeV4Snapshot.isNotEmpty &&
        builderV2Snapshot.isNotEmpty &&
        cohesionV1Snapshot.isNotEmpty &&
        blendV2Snapshot.isNotEmpty &&
        proxyV2Snapshot.isNotEmpty &&
        personaSnapshot.isNotEmpty &&
        toneV2Snapshot.isNotEmpty &&
        tierASnapshot.isNotEmpty &&
        tierBSnapshot.isNotEmpty;
    return Map<String, Object>.unmodifiable({
      'builder_v3_ok': builderV3Ok,
      'builder_v3': themeV4Snapshot,
      'weights': <String, Object>{
        'builder_v2': builderV2Snapshot,
        'cohesion_v1': cohesionV1Snapshot,
        'blend_v2': blendV2Snapshot,
        'proxy_v2': proxyV2Snapshot,
        'persona': personaSnapshot,
        'tone_v2': toneV2Snapshot,
        'tier_a': tierASnapshot,
        'tier_b': tierBSnapshot,
      },
      'cohesion_notes': const <String>[],
      'persona_signal_map': proxyV2Snapshot,
    });
  }
}
