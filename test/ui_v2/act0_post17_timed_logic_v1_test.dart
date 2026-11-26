import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_curriculum_pilot_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_timed_decision_v1.dart';

import '../support/act0_catalog_snapshot_v1.dart';

const _limit = Duration(seconds: 10);
const _before = Duration(milliseconds: 9999);
const _after = Duration(milliseconds: 10001);

// These six authored harder scenarios have actual generated Daily Practice
// variants. The other four have no generator recipe on this baseline.
const _variantSources = {
  'harder_dirty_flush',
  'harder_straight_price_rises',
  'harder_remove_missed_hearts',
  'harder_leave_misses_unblocked',
  'harder_river_value_added',
  'harder_paired_river_boats',
};

Act0RunnerOptionV1 _preferred(Act0LessonTaskV1 task) =>
    task.runner.options.singleWhere(act0RunnerOptionIsPreferredV1);

void main() {
  final base = catalogTasks
      .singleWhere((row) => row.task.taskId == 'w4_good_price_call')
      .task;
  Act0TimedDecisionV1 attempt() =>
      Act0TimedDecisionV1(task: base, timeLimit: _limit);

  test('expiry without submission is an incorrect miss, not a pass', () {
    final timed = attempt();
    expect(timed.resolve(elapsed: _before), isNull);
    final grade = timed.resolve(elapsed: _limit)!;
    expect(grade, Act0FeedbackQualityV1.wrong);
    expect(grade.resultKind, 'incorrect');
    expect(grade.passes, isFalse);
    expect(
      timed.resolve(elapsed: _after, optionId: _preferred(base).id),
      Act0FeedbackQualityV1.wrong,
    );
  });

  test('deadline beats an otherwise correct simultaneous or late answer', () {
    for (final elapsed in [_limit, _after]) {
      expect(
        attempt().resolve(elapsed: elapsed, optionId: _preferred(base).id),
        Act0FeedbackQualityV1.wrong,
      );
    }
  });

  test('before expiry the authored grade is used and never overwritten', () {
    for (final option in base.runner.options) {
      final timed = attempt();
      expect(
        timed.resolve(elapsed: _before, optionId: option.id),
        option.quality,
      );
      expect(timed.resolve(elapsed: _limit), option.quality);
      expect(
        timed.resolve(elapsed: _after, optionId: _preferred(base).id),
        option.quality,
      );
    }
  });

  test('W1–W12 snapshot bytes agree with the unchanged release fixture', () {
    expect(
      utf8.encode(renderCatalogSnapshot(excludePilot: true)),
      File('test/fixtures/act0_catalog_snapshot_v1.txt').readAsBytesSync(),
    );
  });

  test('harder scenarios and their generator recipes stay pilot-only', () {
    final harder = catalogTasks.where(
      (row) => row.lesson.lessonId == 'slightly_harder',
    );
    expect(harder, hasLength(act0CurriculumPilotEnabledV1 ? 10 : 0));
    for (final id in _variantSources) {
      final template = act0DailyDealTemplateForSourceV1(id);
      if (act0CurriculumPilotEnabledV1) {
        expect(template, isNotNull, reason: id);
      } else {
        expect(template, isNull, reason: id);
      }
    }
  });

  test(
    'source-linked harder practice variants preserve the preferred action',
    () {
      for (final sourceId in _variantSources) {
        final row = catalogTasks.singleWhere((r) => r.task.taskId == sourceId);
        final template = act0DailyDealTemplateForSourceV1(sourceId)!;
        final preferred = _preferred(row.task).id;
        final boards = <String>{};
        for (var day = 20780; day < 20788; day++) {
          final recipe = (
            day: day,
            template: template,
            lessonId: row.lesson.lessonId,
            sourceTaskId: sourceId,
          );
          final id = act0DailyDealIdV1(recipe);
          final decoded = act0DailyDealRecipeV1(id);
          expect(decoded, recipe, reason: id);
          final variant = act0GenerateDailyDealV1(
            taskId: id,
            lessonId: decoded!.lessonId,
            template: decoded.template,
            seed: day * 31 + template.index,
            sourceTaskId: decoded.sourceTaskId,
          );
          expect(variant, isNotNull, reason: id);
          expect(variant!.taskId, id);
          expect(_preferred(variant).id, preferred, reason: id);
          expect(variant.rewardXp, 0, reason: id);
          expect(
            act0PilotDailyDealTableIsValidV1(variant.runner.table),
            isTrue,
          );
          boards.add(
            variant.runner.table.boardCards.map((c) => c.label).join(' '),
          );
        }
        expect(boards.length, greaterThan(1), reason: sourceId);
      }
    },
    skip: !act0CurriculumPilotEnabledV1,
  );
}
