import 'dart:convert';

/// Passive advanced alignment checker for Range Advantage 2.0 v1.
class RA2AlignmentCheckerV1 {
  const RA2AlignmentCheckerV1({
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
    final bool jsonValid =
        drillObjects.length == drillsLines.length &&
        demoObjects.length == demosLines.length;
    final bool uniqueIds = _unique(<Map<String, Object?>>[
      ...drillObjects,
      ...demoObjects,
    ]);
    final String theoryText = theoryLines.join('\n').toLowerCase();
    final bool minSections = theoryText.split('## ').length - 1 >= 2;
    final bool hasTurnRefs =
        theoryText.contains('turn') || theoryText.contains('barrel');
    final bool hasExploitRefs =
        theoryText.contains('exploit') || theoryText.contains('counter');
    return <String, Object>{
      'has_theory': theoryLines.isNotEmpty,
      'json_valid': jsonValid,
      'unique_ids': uniqueIds,
      'min_sections': minSections,
      'has_turn_refs': hasTurnRefs,
      'has_exploit_refs': hasExploitRefs,
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
