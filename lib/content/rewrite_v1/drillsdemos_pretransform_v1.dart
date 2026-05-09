import 'dart:convert';

/// Passive pre-transform diagnostics for drills and demos.
class DrillsDemosPreTransformV1 {
  const DrillsDemosPreTransformV1({
    required this.drillsLines,
    required this.demosLines,
  });

  final List<String> drillsLines;
  final List<String> demosLines;

  Map<String, Object> analyze() {
    final List<Map<String, Object?>> drills = _parse(drillsLines);
    final List<Map<String, Object?>> demos = _parse(demosLines);
    final bool allDrillsJson = drills.length == drillsLines.length;
    final bool allDemosJson = demos.length == demosLines.length;
    final bool uniqueIds = _unique(<Map<String, Object?>>[...drills, ...demos]);
    final bool hasSizingKeys = _hasAnyKey(drills, demos, <String>{
      'bet',
      'size',
      'sizing',
    });
    final bool hasActionKeys = _hasAnyKey(drills, demos, <String>{
      'action',
      'move',
    });
    final bool templateReady =
        allDrillsJson &&
        allDemosJson &&
        uniqueIds &&
        hasSizingKeys &&
        hasActionKeys;
    return <String, Object>{
      'drills_count': drillsLines.length,
      'demos_count': demosLines.length,
      'all_drills_json': allDrillsJson,
      'all_demos_json': allDemosJson,
      'unique_ids': uniqueIds,
      'has_sizing_keys': hasSizingKeys,
      'has_action_keys': hasActionKeys,
      'template_ready': templateReady,
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

  bool _hasAnyKey(
    List<Map<String, Object?>> first,
    List<Map<String, Object?>> second,
    Set<String> keys,
  ) {
    for (final Map<String, Object?> item in <Map<String, Object?>>[
      ...first,
      ...second,
    ]) {
      for (final String key in keys) {
        if (item.containsKey(key)) return true;
      }
    }
    return false;
  }
}
