/// Passive skeleton for the unified rewrite engine v1.
class RewriteEngineSkeletonV1 {
  const RewriteEngineSkeletonV1({
    required this.theoryScan,
    required this.drillsDemosScan,
  });

  final Map<String, Object> theoryScan;
  final Map<String, Object> drillsDemosScan;

  Map<String, Object> analyze() {
    final bool theoryReady = theoryScan['template_ready'] == true;
    final bool drillsDemosReady = drillsDemosScan['template_ready'] == true;
    final bool fullyReady = theoryReady && drillsDemosReady;
    final List<String> missing = <String>[];
    if (!theoryReady) missing.add('theory');
    if (!drillsDemosReady) missing.add('drills_demos');
    return <String, Object>{
      'theory_ready': theoryReady,
      'drillsdemos_ready': drillsDemosReady,
      'fully_ready': fullyReady,
      'missing_requirements': missing,
    };
  }
}
