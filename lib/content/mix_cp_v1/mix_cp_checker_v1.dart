import 'dart:convert';

/// Passive structure checker for Mixed Checkpoints v1.
class MixCPCheckerV1 {
  const MixCPCheckerV1({
    required this.theoryLines,
    required this.drillsLines,
    required this.demosLines,
    required this.checkpointLines,
  });

  final List<String> theoryLines;
  final List<String> drillsLines;
  final List<String> demosLines;
  final List<String> checkpointLines;

  Map<String, Object> analyze() {
    final List<Map<String, Object?>> drillObjects = _parse(drillsLines);
    final List<Map<String, Object?>> demoObjects = _parse(demosLines);
    final List<Map<String, Object?>> checkpointObjects = _parse(
      checkpointLines,
    );
    final bool drillsValidJson = drillObjects.length == drillsLines.length;
    final bool demosValidJson = demoObjects.length == demosLines.length;
    final bool checkpointsValidJson =
        checkpointObjects.length == checkpointLines.length;
    final bool uniqueIds = _unique(<Map<String, Object?>>[
      ...drillObjects,
      ...demoObjects,
      ...checkpointObjects,
    ]);
    return <String, Object>{
      'has_theory': theoryLines.isNotEmpty,
      'drills_valid_json': drillsValidJson,
      'demos_valid_json': demosValidJson,
      'checkpoints_valid_json': checkpointsValidJson,
      'unique_ids': uniqueIds,
    };
  }

  List<Map<String, Object?>> _parse(List<String> lines) {
    final List<Map<String, Object?>> parsed = <Map<String, Object?>>[];
    for (final String line in lines) {
      try {
        final dynamic value = jsonDecode(line);
        if (value is Map<String, Object?>) parsed.add(value);
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
