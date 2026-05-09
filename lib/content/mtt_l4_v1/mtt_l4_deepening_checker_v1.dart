import 'dart:convert';

/// Passive deepening checker for MTT L4 v1.
class MTTL4DeepeningCheckerV1 {
  const MTTL4DeepeningCheckerV1({
    required this.theoryLines,
    required this.drillsLines,
    required this.demosLines,
  });

  final List<String> theoryLines;
  final List<String> drillsLines;
  final List<String> demosLines;

  Map<String, Object> analyze() {
    final List<Map<String, Object?>> drillObjects = _parse(drillsLines);
    final List<Map<String, Object?>> demoObjects = _parse(demosLines);
    final bool drillsValidJson = drillObjects.length == drillsLines.length;
    final bool demosValidJson = demoObjects.length == demosLines.length;
    final bool uniqueIds = _unique(<Map<String, Object?>>[
      ...drillObjects,
      ...demoObjects,
    ]);
    return <String, Object>{
      'has_theory': theoryLines.isNotEmpty,
      'drills_valid_json': drillsValidJson,
      'demos_valid_json': demosValidJson,
      'unique_ids': uniqueIds,
    };
  }

  List<Map<String, Object?>> _parse(List<String> lines) {
    final List<Map<String, Object?>> parsed = <Map<String, Object?>>[];
    for (final String line in lines) {
      try {
        final dynamic v = jsonDecode(line);
        if (v is Map<String, Object?>) parsed.add(v);
      } catch (_) {
        break;
      }
    }
    return parsed;
  }

  bool _unique(List<Map<String, Object?>> items) {
    final Set<Object?> ids = <Object?>{};
    for (final Map<String, Object?> item in items) {
      final Object? id = item['id'];
      if (id == null) continue;
      if (!ids.add(id)) return false;
    }
    return true;
  }
}
