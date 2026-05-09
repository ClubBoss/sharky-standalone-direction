/// Passive rewrite migration skeleton for Cash L3 drills/demos v2.
class CashL3DrillsDemosRewriteMigrationV1 {
  const CashL3DrillsDemosRewriteMigrationV1({
    required this.drills,
    required this.demos,
  });

  final List<String> drills;
  final List<String> demos;

  Map<String, Object> migrate() {
    final List<String> normalizedDrills = <String>[];
    final List<String> normalizedDemos = <String>[];
    final List<String> idSet = <String>[];
    final List<String> malformedEntries = <String>[];

    void process(List<String> source, List<String> target) {
      for (final String entry in source) {
        final String trimmed = entry.trim();
        if (trimmed.isEmpty) continue;
        final String? id = _extractId(trimmed);
        if (id == null || id.isEmpty) {
          malformedEntries.add(trimmed);
          continue;
        }
        target.add(trimmed);
        idSet.add(id);
      }
    }

    process(drills, normalizedDrills);
    process(demos, normalizedDemos);

    final List<String> duplicateIds = <String>[];
    final Set<String> seen = <String>{};
    for (final String id in idSet) {
      if (!seen.add(id) && !duplicateIds.contains(id)) {
        duplicateIds.add(id);
      }
    }

    final bool migrationReady =
        duplicateIds.isEmpty &&
        malformedEntries.isEmpty &&
        normalizedDrills.isNotEmpty &&
        normalizedDemos.isNotEmpty;

    return <String, Object>{
      'normalized_drills': normalizedDrills,
      'normalized_demos': normalizedDemos,
      'id_set': idSet,
      'duplicate_ids': duplicateIds,
      'malformed_entries': malformedEntries,
      'migration_ready': migrationReady,
    };
  }

  String? _extractId(String entry) {
    final int colon = entry.indexOf(':');
    final int space = entry.indexOf(' ');
    final int splitIndex = colon > 0 ? colon : (space > 0 ? space : -1);
    if (splitIndex == -1) return null;
    return entry.substring(0, splitIndex).trim();
  }
}
