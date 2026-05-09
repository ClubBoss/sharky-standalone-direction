import 'dart:convert';

/// Passive normalization scaffold for Cash L3 drills and demos.
class CashL3NormalizationScaffoldV1 {
  const CashL3NormalizationScaffoldV1({
    required this.drillsLines,
    required this.demosLines,
  });

  final List<String> drillsLines;
  final List<String> demosLines;

  Map<String, Object> analyze() {
    final List<Map<String, Object?>> drillObjects = _parseLines(drillsLines);
    final List<Map<String, Object?>> demoObjects = _parseLines(demosLines);
    final bool drillsValidJson = drillObjects.length == drillsLines.length;
    final bool demosValidJson = demoObjects.length == demosLines.length;
    final bool uniqueIds = _hasUniqueIds(<Map<String, Object?>>[
      ...drillObjects,
      ...demoObjects,
    ]);
    return <String, Object>{
      'drills_count': drillsLines.length,
      'demos_count': demosLines.length,
      'drills_valid_json': drillsValidJson,
      'demos_valid_json': demosValidJson,
      'unique_ids': uniqueIds,
    };
  }

  List<Map<String, Object?>> _parseLines(List<String> lines) {
    final List<Map<String, Object?>> parsed = <Map<String, Object?>>[];
    for (final String line in lines) {
      try {
        final dynamic value = jsonDecode(line);
        if (value is Map<String, Object?>) {
          parsed.add(value);
        }
      } catch (_) {
        break;
      }
    }
    return parsed;
  }

  bool _hasUniqueIds(List<Map<String, Object?>> items) {
    final Set<Object?> ids = <Object?>{};
    for (final Map<String, Object?> item in items) {
      final Object? id = item['id'];
      if (id == null) continue;
      if (!ids.add(id)) return false;
    }
    return true;
  }
}
