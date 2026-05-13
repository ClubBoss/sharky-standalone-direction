class PersonaStateModelV3 {
  final Object mood;
  final Object engagement;
  final Object context;
  final String stateSnapshot;

  const PersonaStateModelV3({
    this.mood = const Object(),
    this.engagement = const Object(),
    this.context = const Object(),
    this.stateSnapshot = '',
  });

  void resetState() {}
  void updateMood() {}
  void updateEngagement() {}
  void updateContextFlags() {}
  String snapshotState() => '';
}
