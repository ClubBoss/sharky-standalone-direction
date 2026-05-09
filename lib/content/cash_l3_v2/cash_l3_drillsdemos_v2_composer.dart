/// Passive composer for Cash L3 drills/demos V2 final assembly.
class CashL3DrillsDemosV2Composer {
  const CashL3DrillsDemosV2Composer({
    required this.drillsDraft,
    required this.demosDraft,
  });

  final List<String> drillsDraft;
  final List<String> demosDraft;

  Map<String, Object> compose() {
    final List<String> issues = <String>[];
    final List<String> drills = _finalize(drillsDraft, issues, 'drill');
    final List<String> demos = _finalize(demosDraft, issues, 'demo');
    final bool finalReady =
        issues.isEmpty && drills.isNotEmpty && demos.isNotEmpty;

    return <String, Object>{
      'drills_v2': drills,
      'demos_v2': demos,
      'final_ready': finalReady,
      'issues': issues,
    };
  }

  List<String> _finalize(
    List<String> entries,
    List<String> issues,
    String label,
  ) {
    final List<String> result = <String>[];
    for (final String raw in entries) {
      final String oneLine = raw
          .replaceAll('\n', ' ')
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .trimRight();
      if (oneLine.isEmpty) {
        issues.add('${label}_empty');
        continue;
      }
      if (!oneLine.contains(':')) {
        issues.add('${label}_missing_id');
        continue;
      }
      result.add(oneLine);
    }
    return result;
  }
}
