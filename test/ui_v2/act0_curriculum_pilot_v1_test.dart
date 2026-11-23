import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_curriculum_pilot_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import '../support/act0_catalog_snapshot_v1.dart';
import '../support/act0_table_truth_v1.dart';

void main() {
  test(
    'flag off preserves the ordered W1–W12 learner route and XP',
    () {
      final worlds = Act0ShellStateV1.sample.worlds;
      expect(
        worlds.map((world) => world.worldNumber),
        List.generate(12, (i) => i + 1),
      );
      final route = [
        for (final world in worlds)
          for (final lesson in world.lessons)
            for (final task in lesson.courseTaskList)
              [world.worldId, lesson.lessonId, task.taskId, task.rewardXp],
      ];
      // N3 baseline, including task order and each task's award.
      expect(
        sha256.convert(utf8.encode(jsonEncode(route))).toString(),
        '58a0269a4fb9bc31cf3f172af93cd766b22e330ad54070b995284c0338907380',
      );
    },
    skip: act0CurriculumPilotEnabledV1,
  );

  test(
    'pilot keeps lesson identities distinct and passes C1 for every dealt frame',
    () {
      final worlds = Act0ShellStateV1.sample.worlds;
      final lessons = worlds.expand((world) => world.lessons).toList();
      expect(lessons.map((l) => l.lessonId).toSet(), hasLength(lessons.length));
      expect(
        worlds
            .singleWhere((w) => w.worldNumber == 14)
            .lessons
            .singleWhere((l) => l.lessonId == 'w14_spr_and_commitment')
            .authoredLessonId,
        'spr_and_commitment',
      );
      expect(
        worlds
            .singleWhere((w) => w.worldNumber == 15)
            .lessons
            .singleWhere((l) => l.lessonId == 'w15_protection_and_denial')
            .authoredLessonId,
        'protection_and_denial',
      );
      expect(worlds.map((w) => w.worldNumber), List.generate(16, (i) => i + 1));
      final options = catalogTasks
          .where((row) => row.world.worldNumber >= 13)
          .expand((row) => row.task.runner.options)
          .where(
            (option) => option.quality == Act0FeedbackQualityV1.acceptable,
          );
      expect(options, hasLength(3));
      expect(options.every(act0RunnerOptionIsAuthoredCorrectV1), isTrue);
      expect(options.any(act0RunnerOptionIsPreferredV1), isFalse);
      final played = catalogTasks.where(
        (row) =>
            row.world.worldNumber >= 13 &&
            row.task.runner.table.scope == Act0TableScopeV1.playedHand,
      );
      expect(played, hasLength(96));
      for (final row in played) {
        final checks = auditTableContributionsV1(
          row.task.taskId,
          'decision',
          row.task.runner.table,
        );
        expect(
          checks.map((check) => check.invariant),
          contains('D2.pot_feasibility'),
        );
        expect(
          checks.map((check) => check.result),
          everyElement('PASS'),
          reason: row.task.taskId,
        );
      }
    },
    skip: !act0CurriculumPilotEnabledV1,
  );
}
