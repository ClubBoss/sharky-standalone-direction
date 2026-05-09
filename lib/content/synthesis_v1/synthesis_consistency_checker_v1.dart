/// Passive consistency checker for Advanced Synthesis Layer v1.
class SynthesisConsistencyCheckerV1 {
  const SynthesisConsistencyCheckerV1({
    required this.ra2Analysis,
    required this.turnAnalysis,
    required this.exploitAnalysis,
    required this.t2eAnalysis,
    required this.mixcpAnalysis,
  });

  final Map<String, Object> ra2Analysis;
  final Map<String, Object> turnAnalysis;
  final Map<String, Object> exploitAnalysis;
  final Map<String, Object> t2eAnalysis;
  final Map<String, Object> mixcpAnalysis;

  Map<String, Object> analyze() {
    bool _hasBool(Map<String, Object> data, String key) => data[key] is bool;

    final bool validStructure =
        _hasBool(ra2Analysis, 'has_theory') &&
        _hasBool(turnAnalysis, 'has_theory') &&
        _hasBool(exploitAnalysis, 'has_theory') &&
        _hasBool(t2eAnalysis, 'drill_refs_ok') &&
        _hasBool(t2eAnalysis, 'demo_refs_ok') &&
        _hasBool(mixcpAnalysis, 'unique_ids');
    final bool validIds = mixcpAnalysis['unique_ids'] == true;
    final dynamic dangling = t2eAnalysis['dangling_refs'];
    final bool t2eLinksOk = dangling is List ? dangling.isEmpty : false;
    final bool crossRefsOk =
        ra2Analysis['has_theory'] == true &&
        turnAnalysis['has_theory'] == true &&
        exploitAnalysis['has_theory'] == true;
    final bool allConsistent =
        validStructure && validIds && t2eLinksOk && crossRefsOk;

    return <String, Object>{
      'valid_structure': validStructure,
      'valid_ids': validIds,
      't2e_links_ok': t2eLinksOk,
      'cross_refs_ok': crossRefsOk,
      'all_consistent': allConsistent,
    };
  }
}
