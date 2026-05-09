class PersonaEmotionalQAV3 {
  // constructor
  PersonaEmotionalQAV3();

  // baseline
  final String baselineMood = '';
  final String baselineArousal = '';
  final String baselineEngagement = '';
  final String baselineCue = '';

  Map<String, dynamic> _lastSnapshot = {};

  // snapshot
  String buildSnapshotMood() => '';
  String buildSnapshotArousal() => '';
  String buildSnapshotEngagement() => '';
  String buildSnapshotCue() => '';

  void ingestSnapshot(Map<String, dynamic> snapshot) {
    _lastSnapshot = snapshot;
  }

  Map<String, dynamic> get latestSnapshot => _lastSnapshot;

  // compare
  String compareMood() => '';
  String compareArousal() => '';
  String compareEngagement() => '';
  String compareCue() => '';

  // report
  String buildReport() => '';
  String runQA() => '';
}
