class MixedCheckpointLoaderV1 {
  const MixedCheckpointLoaderV1();

  /// Placeholder load API (no logic).
  Map<String, Object> loadCheckpointById(String id) {
    return const <String, Object>{
      'id': 'placeholder',
      'status': 'unimplemented',
    };
  }

  /// Placeholder list API (no logic).
  List<Map<String, Object>> listAllCheckpoints() {
    return const <Map<String, Object>>[
      {'id': 'placeholder', 'status': 'unimplemented'},
    ];
  }
}
