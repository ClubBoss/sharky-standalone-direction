class SpacedRepetitionLoaderV1 {
  const SpacedRepetitionLoaderV1();

  Map<String, Object> loadScheduleById(String id) => _placeholder(id);

  List<Map<String, Object>> listAllSchedules() => const <Map<String, Object>>[];

  Map<String, Object> diagnostics() => const <String, Object>{
    'loader': 'spaced_repetition_loader_v1',
    'status': 'initialized',
  };

  static Map<String, Object> _placeholder(String id) => <String, Object>{
    'schedule_id': id,
    'kind': 'spaced_repetition',
    'version': 'v1',
    'schedule_ready': false,
    'entries': <Object>[],
  };
}
