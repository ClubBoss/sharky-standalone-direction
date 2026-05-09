/// Passive draft generator for Cash L3 drills/demos v2.
class CashL3DrillsDemosDraftV2 {
  const CashL3DrillsDemosDraftV2({
    required this.drillsStruct,
    required this.demosStruct,
  });

  final List<String> drillsStruct;
  final List<String> demosStruct;

  Map<String, Object> draft() {
    final List<String> issues = <String>[];
    final List<String> drillsDraft = _process(drillsStruct, issues, 'drill');
    final List<String> demosDraft = _process(demosStruct, issues, 'demo');
    final bool draftReady = issues.isEmpty;

    return <String, Object>{
      'drills_draft': drillsDraft,
      'demos_draft': demosDraft,
      'draft_ready': draftReady,
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
      final int colon = trimmed.indexOf(':');
      if (colon <= 0) {
        issues.add('${label}_missing_id');
        continue;
      }
      final String id = trimmed.substring(0, colon).trim();
      final String content = trimmed.substring(colon + 1).trim();
      if (id.isEmpty || content.isEmpty) {
        issues.add('${label}_missing_parts');
        continue;
      }
      result.add('$id: $content');
    }
    return result;
  }
}
