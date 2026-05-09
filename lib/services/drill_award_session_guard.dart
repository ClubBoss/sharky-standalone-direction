/// Guards per-session XP awarding for drills so that each drill
/// within a module can award XP at most once per screen session.
class DrillAwardSessionGuard {
  final Map<String, Set<int>> _awardedByModule = {};

  /// Returns true if this [drillIndex] in [moduleId] has not yet been awarded
  /// in this session and marks it as awarded. Returns false otherwise.
  bool shouldAward(String moduleId, int drillIndex) {
    final set = _awardedByModule.putIfAbsent(moduleId, () => <int>{});
    if (set.contains(drillIndex)) return false;
    set.add(drillIndex);
    return true;
  }

  /// Checks whether the drill has been awarded in this session already.
  bool isAwarded(String moduleId, int drillIndex) {
    final set = _awardedByModule[moduleId];
    if (set == null) return false;
    return set.contains(drillIndex);
  }

  /// Clears all session state (used if needed when leaving a screen).
  void clearAll() => _awardedByModule.clear();
}
