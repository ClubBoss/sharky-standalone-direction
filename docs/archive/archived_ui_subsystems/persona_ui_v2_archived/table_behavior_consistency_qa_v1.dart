/// Passive table behavior consistency QA V1 (Phi-75.4).
class TableBehaviorConsistencyQAV1 {
  const TableBehaviorConsistencyQAV1(
    this.tableBehaviorSpecV1Map, [
    this.tableBehaviorTraitsV1Map,
  ]);

  final Object tableBehaviorSpecV1Map;
  final Object? tableBehaviorTraitsV1Map;

  Map<String, Object> asReadOnlyMap() {
    final bool hasSpec =
        tableBehaviorSpecV1Map is Map &&
        (tableBehaviorSpecV1Map as Map).isNotEmpty;
    final bool hasTraits =
        tableBehaviorTraitsV1Map is Map &&
        (tableBehaviorTraitsV1Map as Map).isNotEmpty;
    final bool specNonEmpty = hasSpec;
    final bool traitsNonEmpty = hasTraits;
    final List<String> missing = <String>[];
    if (!hasSpec) missing.add('table_behavior_spec_v1');
    if (!hasTraits) missing.add('table_behavior_traits_v1');
    final List<String> conflicts = <String>[];
    final bool ready = missing.isEmpty && conflicts.isEmpty;
    return <String, Object>{
      'table_behavior_consistency_qa_v1': <String, Object>{
        'ready': ready,
        'missing': missing,
        'conflicts': conflicts,
        'qa': <String, Object>{
          'has_spec': hasSpec,
          'has_traits': hasTraits,
          'spec_non_empty': specNonEmpty,
          'traits_non_empty': traitsNonEmpty,
        },
      },
    };
  }
}
