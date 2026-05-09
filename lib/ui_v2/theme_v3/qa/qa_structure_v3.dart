class QAStructureV3 {
  final Object binder;
  final Object structureMap;
  final Object cohesionRules;

  const QAStructureV3({
    this.binder = const _PlaceholderBinder(),
    this.structureMap = const _PlaceholderStructureMap(),
    this.cohesionRules = const _PlaceholderCohesion(),
  });

  void validateHierarchy() {}
  void validateComponentTree() {}
  void validateNaming() {}
  void report() {}
}

class _PlaceholderBinder {
  const _PlaceholderBinder();
}

class _PlaceholderStructureMap {
  const _PlaceholderStructureMap();
}

class _PlaceholderCohesion {
  const _PlaceholderCohesion();
}
