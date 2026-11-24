import 'package:poker_analyzer/ui_v2/act0_shell/act0_replay_skill_drill_v1.dart';
import 'package:test/test.dart';

const _goodPrice = (lessonId: 'call_price', taskId: 'w4_good_price_call');
const _badPrice = (lessonId: 'call_price', taskId: 'w4_bad_price_fold');
const _cheapPrice = (
  lessonId: 'call_price',
  taskId: 'w4_cheap_price_marginal_call',
);
const _position = (lessonId: 'positions', taskId: 'positions_utg');
const _winningRivers = (
  lessonId: 'w7_visible_cards_and_price',
  taskId: 'w7_count_winning_rivers',
);
const _boardDrill = (
  lessonId: 'w7_visible_cards_and_price',
  taskId: 'w7_clean_outs_lower_price',
);
const _unknown = (lessonId: 'retired_lesson', taskId: 'retired_task');

void main() {
  test('uses the first wrong decision and its task-level skill override', () {
    final result = resolveReplaySkillDrillV1(
      (
        task: _goodPrice,
        decisions: [
          (task: _goodPrice, isCorrect: true),
          (task: _winningRivers, isCorrect: false),
          (task: _position, isCorrect: false),
        ],
      ),
      [_badPrice, _position, _boardDrill],
      [],
    );
    expect(result, (
      skillId: 'Board reading',
      taskId: _boardDrill.taskId,
      reason: 'same_skill',
    ));
  });

  test(
    'falls back to the replay task skill when all decisions are correct',
    () {
      final result = resolveReplaySkillDrillV1(
        (task: _goodPrice, decisions: [(task: _position, isCorrect: true)]),
        [_position, _badPrice],
        [],
      );
      expect(result.skillId, 'Betting decisions');
      expect(result.taskId, _badPrice.taskId);
    },
  );

  test('filters the replay task and drills on other skills', () {
    final result = resolveReplaySkillDrillV1(
      (task: _goodPrice, decisions: []),
      [_goodPrice, _position],
      [],
    );
    expect(result, (
      skillId: 'Betting decisions',
      taskId: null,
      reason: 'no_drill_for_skill',
    ));
  });

  test('ranks by the last sighting and prefers unseen drills', () {
    const attempt = (task: _goodPrice, decisions: <Act0ReplayDecisionV1>[]);
    const pool = [_badPrice, _cheapPrice];
    const history = [
      (taskId: 'w4_bad_price_fold', createdOrder: 7),
      (taskId: 'w4_cheap_price_marginal_call', createdOrder: 4),
      (taskId: 'w4_bad_price_fold', createdOrder: 1),
    ];
    expect(
      resolveReplaySkillDrillV1(attempt, pool, history).taskId,
      _cheapPrice.taskId,
    );
    expect(
      resolveReplaySkillDrillV1(attempt, pool, history.take(1)).taskId,
      _cheapPrice.taskId,
    );
  });

  test('returns no drill for an empty completed pool', () {
    expect(
      resolveReplaySkillDrillV1((task: _goodPrice, decisions: []), [], []),
      (
        skillId: 'Betting decisions',
        taskId: null,
        reason: 'no_drill_for_skill',
      ),
    );
  });

  test(
    'returns unknown skill for the first wrong decision without a mapping',
    () {
      expect(
        resolveReplaySkillDrillV1(
          (
            task: _goodPrice,
            decisions: [
              (task: _unknown, isCorrect: false),
              (task: _goodPrice, isCorrect: false),
            ],
          ),
          [_badPrice],
          [],
        ),
        (skillId: null, taskId: null, reason: 'unknown_skill'),
      );
    },
  );

  test('breaks recency ties by task ID regardless of input order', () {
    const attempt = (task: _goodPrice, decisions: <Act0ReplayDecisionV1>[]);
    const pool = [_cheapPrice, _badPrice];
    const history = [
      (taskId: 'w4_cheap_price_marginal_call', createdOrder: 3),
      (taskId: 'w4_bad_price_fold', createdOrder: 3),
    ];
    final result = resolveReplaySkillDrillV1(attempt, pool, history);
    expect(result.taskId, _badPrice.taskId);
    expect(
      resolveReplaySkillDrillV1(attempt, pool.reversed, history.reversed),
      result,
    );
  });
}
