class RecapLoaderV1 {
  const RecapLoaderV1();

  Map<String, Object> loadRecapById(String id) => _placeholder(id);

  List<Map<String, Object>> listAllRecaps() => const <Map<String, Object>>[];

  Map<String, Object> diagnostics() => const <String, Object>{
    'loader': 'recap_loader_v1',
    'status': 'initialized',
  };

  static Map<String, Object> _placeholder(String id) => <String, Object>{
    'recap_id': id,
    'kind': 'recap',
    'version': 'v1',
    'recap_ready': false,
    'payload': <String, Object>{},
  };
}
