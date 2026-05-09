import 'dart:convert';

/// Passive migration skeleton for Cash L3 drills and demos v2.
class CashL3DrillsDemosMigrationSkeletonV1 {
  const CashL3DrillsDemosMigrationSkeletonV1({
    required this.drillsLines,
    required this.demosLines,
  });

  final List<String> drillsLines;
  final List<String> demosLines;

  Map<String, Object> analyze() {
    final List<Map<String, Object?>> drills = _parse(drillsLines);
    final List<Map<String, Object?>> demos = _parse(demosLines);
    final bool validDrillsJson = drills.length == drillsLines.length;
    final bool validDemosJson = demos.length == demosLines.length;
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
        validDrillsJson &&
        validDemosJson &&
        uniqueIds &&
        hasSizingKeys &&
        hasActionKeys;
    return <String, Object>{
      'drills_count': drillsLines.length,
      'demos_count': demosLines.length,
      'valid_drills_json': validDrillsJson,
      'valid_demos_json': validDemosJson,
      'unique_ids': uniqueIds,
      'has_sizing_keys': hasSizingKeys,
      'has_action_keys': hasActionKeys,
      'migration_map': <String, String>{
        'drills': 'drills_v2',
        'demos': 'demos_v2',
      },
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
