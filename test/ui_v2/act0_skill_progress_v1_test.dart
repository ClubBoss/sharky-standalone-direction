import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_leak_dashboard_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_skill_progress_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _world = 'world_1';
const _lesson = 'what_poker_is';
const _source = 'what_poker_is_find_hero';
const _target = 'first_table_guide_one_clear_choice';
final _worlds = Act0ShellStateV1.sample.worlds;

Act0ArchivedAttemptV1 _attempt(
  int order, {
  bool correct = false,
  bool repaired = false,
  bool helped = false,
  String world = _world,
  String lesson = _lesson,
  String taskId = _source,
  String? revision,
  String runKind = '',
}) {
  final task = Act0ShellStateV1.sample
      .lessonById(lesson)
      .taskList
      .singleWhere((task) => task.taskId == taskId);
  final right = task.runner.options.firstWhere((option) => option.isCorrect);
  final wrong = task.runner.options.firstWhere((option) => !option.isCorrect);
  return Act0ArchivedAttemptV1.fromRecordedDecision(
    Act0LearningEvidenceRecordV1(
      recordId: 'b83-$order',
      createdOrder: order,
      worldId: world,
      lessonId: lesson,
      taskId: taskId,
      choiceId: correct || repaired ? right.id : wrong.id,
      expectedChoiceId: right.id,
      isCorrect: correct || repaired,
      errorType: correct || repaired ? 'none' : 'confused_table_identity',
      repairFocusId: 'hero_button',
      skillAtomId: 'table_position_read',
      decisionTimeBucket: 'under_3s',
      resultKind: repaired
          ? 'repaired'
          : correct
          ? 'correct'
          : 'incorrect',
      authoredSourceFingerprint:
          revision ??
          act0AuthoredSourceFingerprintV1(
            worldId: world,
            lessonId: lesson,
            task: task,
          )!,
      recordedAtUtc: DateTime.utc(2026, 11, 24),
      assistanceKind: helped
          ? Act0DecisionAssistanceV1.quickHint
          : Act0DecisionAssistanceV1.none,
      runKind: runKind,
    ),
  )!;
}

Act0AttemptArchiveV1 _archive(Iterable<Act0ArchivedAttemptV1> attempts) =>
    attempts.fold(const Act0AttemptArchiveV1.empty(), (a, b) => a.add(b));

List<Act0SkillProgressV1> _progress(Act0AttemptArchiveV1 archive) =>
    Act0SkillProgressV1.fromArchive(archive: archive, worlds: _worlds);

void main() {
  test('empty and sparse archive has all skills but no weak ranking', () {
    final empty = _progress(const Act0AttemptArchiveV1.empty());
    expect(
      empty.map((skill) => skill.skill),
      containsAll([
        'Table sense',
        'Board reading',
        'Position play',
        'Mental game',
      ]),
    );
    expect(
      empty.every(
        (skill) =>
            skill.attempts == 0 &&
            skill.status == 'Not enough answers yet (8 more)',
      ),
      isTrue,
    );
    final sparse = _progress(_archive([_attempt(1), _attempt(2)]));
    final table = sparse.singleWhere((skill) => skill.skill == 'Table sense');
    expect(table.attempts, 2);
    expect(table.status, 'Not enough answers yet (6 more)');
    expect(Act0SkillProgressV1.topNeedsWork(sparse), isEmpty);
  });

  test(
    'counts current independent, repaired, helped and missed answers separately',
    () {
      final archive = _archive([
        for (var i = 1; i <= 5; i++) _attempt(i),
        _attempt(
          6,
          correct: true,
          world: 'world_4',
          lesson: 'call_price',
          taskId: 'w4_cheap_price_marginal_call',
        ),
        _attempt(7, repaired: true),
        _attempt(8, correct: true, helped: true),
        _attempt(9),
        _attempt(10, revision: 'a' * 64),
        _attempt(11, runKind: act0PlacementAssessmentRunKindV1),
      ]);
      final progress = _progress(archive);
      final table = progress.singleWhere(
        (skill) => skill.skill == 'Table sense',
      );
      expect(table.attempts, 8);
      expect(table.missedAnswers, 6);
      expect(table.independentCorrect, 0);
      expect(table.repaired, 1);
      expect(table.status, 'Needs work');
      final betting = progress.singleWhere(
        (skill) => skill.skill == 'Betting decisions',
      );
      expect(betting.independentCorrect, 1);
      expect(Act0SkillProgressV1.topNeedsWork(progress), contains(table));
      expect(
        _progress(
          archive.remove('b83-9'),
        ).singleWhere((skill) => skill.skill == 'Table sense').answersNeeded,
        1,
      );
    },
  );

  test('ranking excludes sparse rows and caps at three deterministically', () {
    Act0SkillProgressV1 row(String name, int attempts, int misses) =>
        Act0SkillProgressV1(
          skill: name,
          attempts: attempts,
          independentCorrect: attempts - misses,
          repaired: 0,
          missedAnswers: misses,
          minimumAnswers: 8,
        );
    expect(
      Act0SkillProgressV1.topNeedsWork([
        row('sparse', 7, 7),
        row('D', 8, 1),
        row('B', 8, 4),
        row('A', 8, 7),
        row('C', 16, 8),
        row('clean', 8, 0),
      ]).map((skill) => skill.skill),
      ['A', 'C', 'B'],
    );
  });

  for (final enabled in [false, true]) {
    testWidgets('Skills empty state and dashboard link: $enabled', (
      tester,
    ) async {
      var builds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0AcademyYouLeafV1(
              input: Act0AcademyYouLeafInputV1(
                completedTaskCount: 0,
                skillProgress: _progress(const Act0AttemptArchiveV1.empty()),
                openLeakDashboard: enabled
                    ? () {
                        builds++;
                        return Act0LeakDashboardV1.aggregate(
                          observations: [],
                          nowUtc: DateTime.utc(2026),
                          practiceForMiss: (_) => [],
                        );
                      }
                    : null,
              ),
            ),
          ),
        ),
      );
      // Tap the header, not the center of the expanded tile and its rows.
      final all = find.descendant(
        of: find.byKey(const Key('act0_you_skill_see_all')),
        matching: find.widgetWithText(ListTile, 'See all'),
      );
      await tester.ensureVisible(all);
      await tester.pumpAndSettle();
      expect(find.text('Not enough answers yet'), findsOneWidget);
      expect(all.hitTestable(), findsOneWidget);
      await tester.tap(all, warnIfMissed: true);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Not enough answers yet (8 more)'),
        findsWidgets,
      );
      expect(find.textContaining('0%'), findsNothing);
      await tester.ensureVisible(all);
      await tester.pumpAndSettle();
      expect(all.hitTestable(), findsOneWidget);
      await tester.tap(all, warnIfMissed: true);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Not enough answers yet (8 more)'),
        findsNothing,
      );
      final link = find.byKey(const Key('act0_you_skill_leak_dashboard'));
      expect(link, enabled ? findsOneWidget : findsNothing);
      expect(builds, 0);
      if (enabled) {
        await tester.ensureVisible(link);
        await tester.pumpAndSettle();
        expect(link.hitTestable(), findsOneWidget);
        await tester.tap(link, warnIfMissed: true);
        await tester.pumpAndSettle();
        expect(builds, 1);
        expect(find.byType(BottomSheet), findsOneWidget);
        expect(
          find.text(Act0LeakDashboardV1.insufficientDataLabel),
          findsOneWidget,
        );
      }
    });
  }

  testWidgets(
    'You opens the least recently seen completed drill for a weak skill',
    (tester) async {
      final archive = _archive([for (var i = 1; i <= 8; i++) _attempt(i)]);
      final history = Act0LearningEvidenceHistoryV1(
        records: archive.attempts.map((attempt) => attempt.evidence).toList(),
      );
      SharedPreferences.setMockInitialValues({
        'act0_welcome_completed_v1': true,
        'intake_completed_v1': true,
        'act0_shell_progress_v1': jsonEncode({
          'schemaVersion': 20,
          'completedTaskIds': ['what_poker_is_theory', _source, _target],
          'completedLessonIds': <String>[],
          'skippedTaskIds': <String>[],
          'earnedXp': 15,
          'selectedWorldId': _world,
          'selectedLessonId': _lesson,
          'selectedTaskId': _target,
          'pendingDecisionAssistance': <Object>[],
          'learningEvidenceHistory': history.toPayload(),
          'learningEvidenceLineage': history.lineagePayload(),
          'attemptArchive': archive.toPayload(snapshotRecords: history.records),
        }),
      });
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          home: const Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.profile,
            showPlacementOnStart: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final leaf = tester.widget<Act0AcademyYouLeafV1>(
        find.byType(Act0AcademyYouLeafV1),
      );
      expect(leaf.input.openLeakDashboard != null, leakDashboardV1);
      final row = find.byKey(const Key('act0_you_skill_top_Table sense'));
      await tester.scrollUntilVisible(row, 200);
      await tester.tap(row);
      await tester.pumpAndSettle();
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.selectedTaskId, _target);
    },
  );
}
