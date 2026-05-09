class TrainingProgressSnapshot {
  final String label;
  final int completedModules;
  final int totalModules;

  const TrainingProgressSnapshot({
    required this.label,
    required this.completedModules,
    required this.totalModules,
  });

  double asPercentage() =>
      totalModules == 0 ? 0 : completedModules / totalModules;

  static List<TrainingProgressSnapshot> fromScopeProgress(
    Iterable<TrainingScopeProgress> scopes,
  ) => scopes
      .where((scope) => scope.total > 0)
      .map(
        (scope) => TrainingProgressSnapshot(
          label: scope.label,
          completedModules: scope.completed,
          totalModules: scope.total,
        ),
      )
      .toList(growable: false);
}

class TrainingScopeProgress {
  final String label;
  final int completed;
  final int total;

  const TrainingScopeProgress({
    required this.label,
    required this.completed,
    required this.total,
  });
}
