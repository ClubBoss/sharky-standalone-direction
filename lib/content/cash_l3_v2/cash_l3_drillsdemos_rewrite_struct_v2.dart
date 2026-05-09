/// Passive structural rewrite for Cash L3 drills/demos v2.
class CashL3DrillsDemosRewriteStructV2 {
  const CashL3DrillsDemosRewriteStructV2({
    required this.normalizedDrills,
    required this.normalizedDemos,
  });

  final List<String> normalizedDrills;
  final List<String> normalizedDemos;

  Map<String, Object> rewrite() {
    final List<String> issues = <String>[];
    final List<String> drillsStruct = _process(
      normalizedDrills,
      issues,
      'drill',
    );
    final List<String> demosStruct = _process(normalizedDemos, issues, 'demo');
    final bool structReady = issues.isEmpty;

    return <String, Object>{
      'drills_struct': drillsStruct,
      'demos_struct': demosStruct,
      'struct_ready': structReady,
      'issues': issues,
    };
  }

  List<String> _process(
    List<String> entries,
    List<String> issues,
    String label,
  ) {
    final List<String> result = <String>[];
    for (final String raw in entries) {
      final String trimmed = raw.trim().replaceAll(RegExp(r'\s{2,}'), ' ');
      if (trimmed.isEmpty) {
        issues.add('${label}_empty');
        continue;
      }
      final int sepIndex = trimmed.indexOf(':');
      if (sepIndex <= 0) {
        issues.add('${label}_missing_id');
        continue;
      }
      final String id = trimmed.substring(0, sepIndex).trim();
      final String content = trimmed.substring(sepIndex + 1).trim();
      if (id.isEmpty || content.isEmpty) {
        issues.add('${label}_missing_parts');
        continue;
      }
      final String oneLine = '$id: $content';
      result.add(oneLine);
    }
    return result;
  }
}
