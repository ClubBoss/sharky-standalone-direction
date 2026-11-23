/// Stable learner-profile values.
enum Act0LearnerGoalV1 {
  onlineCash('online_cash'),
  homeGame('home_game'),
  liveCash('live_cash'),
  mtt('mtt');

  const Act0LearnerGoalV1(this.id);

  final String id;

  static Act0LearnerGoalV1 fromStorage(Object? value) =>
      values.firstWhere((goal) => goal.id == value, orElse: () => onlineCash);
}

abstract interface class Act0GoalRouteWorldV1 {
  String get worldId;
  int get worldNumber;
}

typedef Act0GoalRoutePlacementV1 = ({
  String worldId,
  String lessonId,
  String taskId,
});

enum Act0GoalEmphasisV1 { loosePassiveOpponents, liveCash, tournament }

typedef Act0GoalRouteV1<T extends Act0GoalRouteWorldV1> = ({
  List<T> worlds,
  Map<String, Act0GoalEmphasisV1> emphasisByWorldId,
  Act0GoalRoutePlacementV1? placement,
});

Act0GoalEmphasisV1? _emphasisForV1(
  Act0LearnerGoalV1 goal,
  Act0GoalRouteWorldV1 world,
) => switch (goal) {
  Act0LearnerGoalV1.homeGame when world.worldNumber == 10 =>
    Act0GoalEmphasisV1.loosePassiveOpponents,
  Act0LearnerGoalV1.liveCash
      when world.worldId == 'live_room' || world.worldNumber == 30 =>
    Act0GoalEmphasisV1.liveCash,
  Act0LearnerGoalV1.mtt
      when const {9, 26, 28, 32, 36}.contains(world.worldNumber) =>
    Act0GoalEmphasisV1.tournament,
  _ => null,
};

/// Stable ordering of the visible catalog. Placement remains a separate core
/// entry recommendation. World objects retain their original gating and XP.
Act0GoalRouteV1<T> act0GoalRouteV1<T extends Act0GoalRouteWorldV1>({
  required Act0LearnerGoalV1 goal,
  required Act0GoalRoutePlacementV1? placement,
  required List<T> catalog,
  required bool w13PlusEnabled,
}) {
  final core = <T>[];
  final emphasized = <T>[];
  final remaining = <T>[];
  final tags = <String, Act0GoalEmphasisV1>{};
  for (final world in catalog) {
    if (world.worldNumber <= 4 && world.worldId != 'live_room') {
      core.add(world);
      continue;
    }
    if (!w13PlusEnabled && world.worldNumber >= 13) {
      continue;
    }
    final emphasis = _emphasisForV1(goal, world);
    if (emphasis != null) {
      tags[world.worldId] = emphasis;
      emphasized.add(world);
    } else {
      remaining.add(world);
    }
  }
  return (
    worlds: List.unmodifiable([...core, ...emphasized, ...remaining]),
    emphasisByWorldId: Map.unmodifiable(tags),
    placement: core.any((world) => world.worldId == placement?.worldId)
        ? placement
        : null,
  );
}

/// Home and Map consume the same ordered route, with source-owned card state.
class Act0GoalRouteViewModelV1<T extends Act0GoalRouteWorldV1> {
  const Act0GoalRouteViewModelV1({
    required this.goal,
    required this.route,
    required this.nextSteps,
    required this.onGoalChanged,
  });

  final Act0LearnerGoalV1 goal;
  final Act0GoalRouteV1<T> route;
  final List<T> nextSteps;
  final void Function(Act0LearnerGoalV1) onGoalChanged;
}
