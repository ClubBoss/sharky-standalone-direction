class PersonalizationMemory {
  final Object statePlaceholder;
  final String profilePlaceholder;

  final List<String> accuracySignals;
  final List<String> speedSignals;
  final List<String> pressureResponseSignals;
  final List<String> streetMisreadSignals;
  final List<String> densityReadSignals;
  final List<String> blockerAwarenessSignals;
  final List<String> fragilityReadSignals;
  final List<String> exploitWindowReadSignals;

  final String lastProfile;

  const PersonalizationMemory({
    this.statePlaceholder = const Object(),
    this.profilePlaceholder = '',
  }) : accuracySignals = const [],
       speedSignals = const [],
       pressureResponseSignals = const [],
       streetMisreadSignals = const [],
       densityReadSignals = const [],
       blockerAwarenessSignals = const [],
       fragilityReadSignals = const [],
       exploitWindowReadSignals = const [],
       lastProfile = profilePlaceholder;

  void clearAll() {}
  void clearSignals() {}
  void updateLastProfile() {}
}
