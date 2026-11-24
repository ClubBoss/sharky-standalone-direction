import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_daily_practice_coverage_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_path_progress_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w14_skill_state_v1.dart';

void main() {
  final today = DateTime.utc(2026, 11, 24);
  final yesterday = today.subtract(const Duration(days: 1));
  final laterToday = today.add(const Duration(hours: 1));

  test('counts eligible drills and reports latest completion by key skill', () {
    final coverage = dailyPracticeCoverageV1(
      {
        'a': ['Board reading', 'Board reading', 'Position play'],
        'b': ['Board reading'],
        'c': ['Board reading'],
        'd': ['Position play', 'Hand reading'],
        'e': ['Table sense'],
      },
      {'b': today, 'a': yesterday, 'retired': laterToday},
      ['Board reading', 'Position play', 'Hand reading', 'Blind play'],
    );

    expect(coverage, {
      'Board reading': (
        eligibleDrillCount: 3,
        lastSeen: today,
        status: Act0DailyPracticeCoverageStatusV1.covered,
      ),
      'Position play': (
        eligibleDrillCount: 2,
        lastSeen: yesterday,
        status: Act0DailyPracticeCoverageStatusV1.thin,
      ),
      'Hand reading': (
        eligibleDrillCount: 1,
        lastSeen: null,
        status: Act0DailyPracticeCoverageStatusV1.thin,
      ),
      'Blind play': (
        eligibleDrillCount: 0,
        lastSeen: null,
        status: Act0DailyPracticeCoverageStatusV1.missing,
      ),
    });
  });

  test('fresh pools recommend unseen drills first', () {
    final result = exhaustionV1(
      ['a', 'c', 'b', 'd'],
      {'a': today, 'd': yesterday, 'retired': today},
      todayStartedAt: today,
    );
    expect(result.status, Act0DailyPracticeExhaustionStatusV1.fresh);
    expect(result.recommendedDrillIds, ['b', 'c', 'd']);
  });

  test('recycling recommends the least recently seen with stable ties', () {
    final history = {'c': today, 'b': yesterday, 'a': yesterday};
    for (final ids in [history.keys, history.keys.toList().reversed]) {
      final result = exhaustionV1(ids, history, todayStartedAt: today);
      expect(result.status, Act0DailyPracticeExhaustionStatusV1.recycling);
      expect(result.recommendedDrillIds, ['a', 'b', 'c']);
    }
  });

  test('an exhausted day still recommends distinct drills for replay', () {
    final result = exhaustionV1(
      ['b', 'a', 'a'],
      {'b': laterToday, 'a': today},
      todayStartedAt: today,
    );
    expect(result.status, Act0DailyPracticeExhaustionStatusV1.exhausted);
    expect(result.recommendedDrillIds, ['a', 'b']);
  });

  test('an empty pool is exhausted and has no replay candidates', () {
    final result = exhaustionV1([], {'a': today}, todayStartedAt: today);
    expect(result.status, Act0DailyPracticeExhaustionStatusV1.exhausted);
    expect(result.recommendedDrillIds, isEmpty);
  });

  test(
    'fully completed W1–W12 Daily Practice has no missing or thin skills',
    () {
      final worlds = Act0ShellStateV1.sample.worlds
          .where((world) => world.worldNumber >= 1 && world.worldNumber <= 12)
          .toList();
      final keySkills = act0W14SkillStatesV1(
        worlds: worlds,
        history: const Act0LearningEvidenceHistoryV1(),
      ).map((skill) => skill.label);
      final completed = {
        for (final world in worlds)
          for (final lesson in world.lessons)
            for (final task in lesson.courseTaskList) task.taskId,
      };
      final progressed = act0ProgressWorldsV1(
        worlds,
        pathClosedTaskIds: completed,
        earnedTaskIds: completed,
      );
      final pool = {
        for (final world in progressed.where((world) => world.isSelectable))
          for (final lesson in world.lessons.where(
            (lesson) => lesson.isSelectable,
          ))
            for (final task in lesson.taskList)
              if (task.phase == Act0LessonPhaseV1.drill &&
                  completed.contains(task.taskId))
                task.taskId: act0SkillsForTaskV1(lesson.lessonId, task.taskId),
      };
      final coverage = dailyPracticeCoverageV1(pool, {}, keySkills);
      expect(coverage, isNotEmpty);
      final missing = [
        for (final entry in coverage.entries)
          if (entry.value.status == Act0DailyPracticeCoverageStatusV1.missing)
            entry.key,
      ]..sort();
      final thin = [
        for (final entry in coverage.entries)
          if (entry.value.status == Act0DailyPracticeCoverageStatusV1.thin)
            entry.key,
      ]..sort();
      expect(missing, <String>[], reason: 'Missing key skills: $missing');
      expect(thin, <String>[], reason: 'Thin key skills: $thin');
    },
  );
}
