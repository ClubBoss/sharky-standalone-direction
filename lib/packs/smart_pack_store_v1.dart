class SmartPackStoreV1 {
  const SmartPackStoreV1();

  Map<String, Object> asReadOnlyBundle() => const <String, Object>{
    'available_packs': <String>[],
    'recommended_packs': <String>[],
    'drivers': <String>[],
    'conflicts': <String>[],
    'ok': false,
  };
}
