/// Passive synthesis checker v1.
class SynthesisCheckerV1 {
  const SynthesisCheckerV1({
    required this.ra2Analysis,
    required this.turnAnalysis,
    required this.exploitAnalysis,
    required this.t2eAnalysis,
  });

  final Map<String, Object> ra2Analysis;
  final Map<String, Object> turnAnalysis;
  final Map<String, Object> exploitAnalysis;
  final Map<String, Object> t2eAnalysis;

  Map<String, Object> analyze() {
    bool _allTrue(Map<String, Object> data) =>
        data.values.every((v) => v is bool && v);

    final bool ra2Ok = _allTrue(ra2Analysis);
    final bool turnOk = _allTrue(turnAnalysis);
    final bool exploitOk = _allTrue(exploitAnalysis);
    final bool t2eOk = _allTrue(t2eAnalysis);
    final bool allPass = ra2Ok && turnOk && exploitOk && t2eOk;

    return <String, Object>{
      'all_pass': allPass,
      'ra2_ok': ra2Ok,
      'turn_ok': turnOk,
      'exploit_ok': exploitOk,
      't2e_ok': t2eOk,
    };
  }
}
