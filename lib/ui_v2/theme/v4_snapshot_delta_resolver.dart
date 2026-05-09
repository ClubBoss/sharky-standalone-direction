class V4SnapshotDeltaResolver {
  const V4SnapshotDeltaResolver({required this.v3, required this.v4});

  final Map<String, Object> v3;
  final Map<String, Object> v4;

  Map<String, Object> buildDeltaReport() {
    final keys = <String>{...v3.keys, ...v4.keys};
    final items = <Map<String, String>>[];
    for (final key in keys) {
      final hasV3 = v3.containsKey(key);
      final hasV4 = v4.containsKey(key);
      String status;
      if (hasV3 && hasV4) {
        status = v3[key] == v4[key] ? 'same' : 'different';
      } else if (hasV3) {
        status = 'missing_in_v4';
      } else {
        status = 'missing_in_v3';
      }
      items.add(<String, String>{'key': key, 'status': status});
    }
    return <String, Object>{'items': items};
  }
}
