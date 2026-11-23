import 'package:poker_analyzer/ui_v2/act0_shell/act0_goal_route_v1.dart';
import 'package:test/test.dart';

class _World implements Act0GoalRouteWorldV1 {
  _World(this.worldNumber, {String? id}) : worldId = id ?? 'world_$worldNumber';

  @override
  final int worldNumber;
  @override
  final String worldId;
  int get xp => worldNumber * 10;
}

void main() {
  final catalog = [
    for (var number = 1; number <= 36; number++) _World(number),
    _World(37, id: 'live_room'),
  ];
  const placement = (
    worldId: 'world_1',
    lessonId: 'your_first_hand',
    taskId: 'placement-task',
  );
  const expectedEmphasis = {
    Act0LearnerGoalV1.onlineCash: <int>[],
    Act0LearnerGoalV1.homeGame: [10],
    Act0LearnerGoalV1.liveCash: [30, 37],
    Act0LearnerGoalV1.mtt: [9, 26, 28, 32, 36],
  };
  const expectedTags = {
    Act0LearnerGoalV1.homeGame: Act0GoalEmphasisV1.loosePassiveOpponents,
    Act0LearnerGoalV1.liveCash: Act0GoalEmphasisV1.liveCash,
    Act0LearnerGoalV1.mtt: Act0GoalEmphasisV1.tournament,
  };
  int xp(Iterable<_World> worlds) =>
      worlds.fold(0, (sum, world) => sum + world.xp);

  for (final goal in Act0LearnerGoalV1.values) {
    for (final pilotEnabled in [false, true]) {
      test('${goal.id}, W13+ flag $pilotEnabled', () {
        final visible = pilotEnabled ? catalog : catalog.take(12).toList();
        final emphasized = visible
            .where(
              (world) => expectedEmphasis[goal]!.contains(world.worldNumber),
            )
            .toList();
        final result = act0GoalRouteV1(
          goal: goal,
          placement: placement,
          catalog: catalog,
          w13PlusEnabled: pilotEnabled,
        );
        expect(result.worlds.take(4), catalog.take(4));
        expect(result.worlds, [
          ...visible.take(4),
          ...emphasized,
          ...visible.skip(4).where((world) => !emphasized.contains(world)),
        ]);
        expect(result.emphasisByWorldId, {
          for (final world in emphasized) world.worldId: expectedTags[goal],
        });
        expect(result.placement, placement);
        expect(xp(result.worlds), xp(visible));
      });
    }
  }

  test('missing or unknown profile goal reads as online cash', () {
    for (final value in [null, '', 'unknown', 1]) {
      expect(
        Act0LearnerGoalV1.fromStorage(value),
        Act0LearnerGoalV1.onlineCash,
      );
    }
    for (final goal in Act0LearnerGoalV1.values) {
      expect(Act0LearnerGoalV1.fromStorage(goal.id), goal);
    }
  });
}
