import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_path_progress_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w1_rules_check_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/act0_source_choreography_test_wait_v1.dart';

// Catalog-wide checks for two learner-trust classes:
// - every graded task has one preferred answer or a pair of equivalent answers.
//   Grades, better-answer pointers and explanations agree with them;
// - a lesson opens only after everything before it is done (CUR-08.a).

final _worlds = Act0ShellStateV1.sample.worlds;

void main() {
  _runnerGradeTests();
  test('G1·38 keeps Day 7 single-answer and validates catalog grades', () {
    for (final entry in act0NewReviewTasksV1) {
      final grades = entry.task.runner.options.map((option) => option.quality);
      expect(
        grades,
        isNot(contains(Act0FeedbackQualityV1.coCorrect)),
        reason: entry.task.taskId,
      );
      expect(
        grades,
        isNot(contains(Act0FeedbackQualityV1.acceptable)),
        reason: entry.task.taskId,
      );
    }
    for (final entry in act0W1RulesReviewTasksV1) {
      expect(
        _hasValidPreferredGrades(
          entry.task.runner.options.map((o) => o.quality),
        ),
        isTrue,
        reason: entry.task.taskId,
      );
    }
    final problems = <String>[];
    var graded = 0;
    for (final w in _worlds) {
      for (final l in w.lessons) {
        for (final t in l.taskList) {
          final options = t.runner.options;
          if (options.isEmpty) continue;
          graded++;
          final id = 'W${w.worldNumber} ${t.taskId}';
          final preferred = options
              .where(act0RunnerOptionIsPreferredV1)
              .toList();
          if (!_hasValidPreferredGrades(
            options.map((option) => option.quality),
          )) {
            problems.add('$id: expected one correct or two coCorrect options');
          }
          final right = preferred.firstOrNull;
          final ids = options.map((o) => o.id).toList();
          if (ids.toSet().length != ids.length) {
            problems.add('$id: repeated option ids $ids');
          }
          final labels = options.map((o) => '${o.label}|${o.seatId}').toList();
          if (labels.toSet().length != labels.length) {
            problems.add('$id: repeated option labels $labels');
          }
          for (final o in options) {
            final at = '$id/${o.id}';
            if (o.isCorrect != o.quality.passes) {
              problems.add(
                '$at: correct flag disagrees with ${o.quality.name}',
              );
            }
            if (o.feedbackTitle.trim().isEmpty ||
                o.feedbackReason.trim().isEmpty) {
              problems.add('$at: no feedback title or explanation');
            }
            if (!o.quality.isPreferred && o.betterAnswerLabel != right?.label) {
              problems.add(
                '$at: better answer "${o.betterAnswerLabel}" is not the '
                'right answer "${right?.label}"',
              );
            }
          }
        }
      }
    }
    expect(graded, greaterThan(250), reason: 'catalog went missing');
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('G1·38 rejects missing, mixed, and extra preferred grades', () {
    const correct = Act0FeedbackQualityV1.correct;
    const coCorrect = Act0FeedbackQualityV1.coCorrect;
    const acceptable = Act0FeedbackQualityV1.acceptable;
    expect(_hasValidPreferredGrades([correct, acceptable]), isTrue);
    expect(
      _hasValidPreferredGrades([coCorrect, coCorrect, acceptable]),
      isTrue,
    );
    for (final invalid in [
      [acceptable],
      [coCorrect, acceptable],
      [correct, correct],
      [correct, coCorrect, coCorrect],
      [coCorrect, coCorrect, coCorrect],
    ]) {
      expect(_hasValidPreferredGrades(invalid), isFalse, reason: '$invalid');
    }
  });

  test('a lesson opens only after every course task before it is closed', () {
    final route = [
      for (final w in _worlds)
        for (final l in w.lessons) (world: w.worldId, lesson: l),
    ];
    Map<String, Act0LessonCardV1> project(Set<String> closed) => {
      for (final w in act0ProgressWorldsV1(
        _worlds,
        pathClosedTaskIds: closed,
        earnedTaskIds: closed,
      ))
        for (final l in w.lessons) l.lessonId: l,
    };
    final problems = <String>[];
    final before = <String>[];
    for (var k = 0; k < route.length; k++) {
      final target = route[k].lesson;
      final lessons = project(before.toSet());
      for (var j = 0; j < route.length; j++) {
        final l = lessons[route[j].lesson.lessonId]!;
        final open = l.isSelectable && !l.isLocked;
        final expected = j <= k;
        if (open != expected) {
          problems.add(
            'with lessons before ${target.lessonId} closed, '
            '${l.lessonId} is ${open ? 'open' : 'locked'}',
          );
        }
      }
      // Negative cases: missing any single earlier task keeps the lesson shut.
      for (final missing in before) {
        final l = project(before.toSet()..remove(missing))[target.lessonId]!;
        if (l.isSelectable || !l.isLocked) {
          problems.add('${target.lessonId} opens without $missing');
        }
      }
      before.addAll(target.courseTaskList.map((t) => t.taskId));
    }
    expect(route.length, greaterThan(50), reason: 'catalog went missing');
    expect(problems, isEmpty, reason: problems.take(40).join('\n'));
  });

  group('Q15 world checkpoint weak-spot gate', () {
    test(
      'checkpoint stays locked with Clear weak spots when world has open mistakes',
      () {
        final w1 = _worlds.firstWhere((w) => w.worldId == 'world_1');
        final checkpoint = w1.lessons.last;
        expect(act0LessonIsWorldCheckpointV1(w1, checkpoint), isTrue);

        final preCheckpointTaskIds = {
          for (final lesson in w1.lessons.take(w1.lessons.length - 1))
            for (final task in lesson.courseTaskList) task.taskId,
        };

        final gated = act0ProgressWorldsV1(
          _worlds,
          pathClosedTaskIds: preCheckpointTaskIds,
          earnedTaskIds: preCheckpointTaskIds,
          worldsWithOpenMistakes: const {'world_1'},
        ).firstWhere((w) => w.worldId == 'world_1');

        final gatedCheckpoint = gated.lessons.last;
        expect(gatedCheckpoint.lessonId, checkpoint.lessonId);
        expect(gatedCheckpoint.state, Act0LessonStateV1.locked);
        expect(gatedCheckpoint.primaryCtaLabel, 'Clear weak spots');
        expect(gatedCheckpoint.isSelectable, isFalse);
        expect(gatedCheckpoint.isLocked, isTrue);

        final cleared = act0ProgressWorldsV1(
          _worlds,
          pathClosedTaskIds: preCheckpointTaskIds,
          earnedTaskIds: preCheckpointTaskIds,
          worldsWithOpenMistakes: const <String>{},
        ).firstWhere((w) => w.worldId == 'world_1');

        final openCheckpoint = cleared.lessons.last;
        expect(openCheckpoint.state, Act0LessonStateV1.current);
        expect(openCheckpoint.primaryCtaLabel, 'Start');
        expect(openCheckpoint.isSelectable, isTrue);
        expect(openCheckpoint.isLocked, isFalse);
      },
    );

    test(
      'already-completed checkpoint stays completed and selectable despite open mistakes',
      () {
        final w1 = _worlds.firstWhere((w) => w.worldId == 'world_1');
        final allW1Tasks = {
          for (final lesson in w1.lessons)
            for (final task in lesson.courseTaskList) task.taskId,
        };

        final progressed = act0ProgressWorldsV1(
          _worlds,
          pathClosedTaskIds: allW1Tasks,
          earnedTaskIds: allW1Tasks,
          worldsWithOpenMistakes: const {'world_1'},
        ).firstWhere((w) => w.worldId == 'world_1');

        final checkpoint = progressed.lessons.last;
        expect(checkpoint.state, Act0LessonStateV1.completed);
        expect(checkpoint.primaryCtaLabel, 'Replay');
        expect(checkpoint.isSelectable, isTrue);
        expect(checkpoint.isLocked, isFalse);
      },
    );

    test('act0LessonIsWorldCheckpointV1 excludes non-checkpoint worlds', () {
      final w5 = _worlds.firstWhere((w) => w.worldId == 'world_5');
      final w8 = _worlds.firstWhere((w) => w.worldId == 'world_8');
      expect(act0LessonIsWorldCheckpointV1(w5, w5.lessons.last), isFalse);
      expect(act0LessonIsWorldCheckpointV1(w8, w8.lessons.last), isFalse);
    });
  });
}

bool _hasValidPreferredGrades(Iterable<Act0FeedbackQualityV1> grades) {
  final correct = grades
      .where((grade) => grade == Act0FeedbackQualityV1.correct)
      .length;
  final coCorrect = grades
      .where((grade) => grade == Act0FeedbackQualityV1.coCorrect)
      .length;
  return (correct == 1 && coCorrect == 0) || (correct == 0 && coCorrect == 2);
}

const _fixtureXp = 13;
const _fixtureTaskId = 'r1_grade_fixture';
const _fixtureOptionKeyPrefix = 'act0_shell_option_';

Act0ShellStateV1 _gradeFixture({bool coCorrect = false}) {
  final base = Act0ShellStateV1.sample;
  final source = base.selectedWorld.lessons.first.runner;
  final quality = coCorrect
      ? Act0FeedbackQualityV1.coCorrect
      : Act0FeedbackQualityV1.correct;
  const best = 'Check';
  Act0RunnerOptionV1 option(
    String id,
    String label,
    Act0FeedbackQualityV1 grade,
  ) => Act0RunnerOptionV1(
    id: id,
    label: label,
    quality: grade,
    isCorrect: grade.passes,
    preferredLabel: best,
    feedbackTitle: 'Read the pot before you act.',
    feedbackReason: 'The example has no bet to match.',
  );
  final runner = source.copyWith(
    phase: Act0LessonPhaseV1.drill,
    question: 'What is your move?',
    feedbackSignalId: '',
    table: source.table.copyWith(centerLabel: 'No bet yet'),
    teachingSteps: const [],
    options: [
      option('alternative', 'Call', Act0FeedbackQualityV1.acceptable),
      option('best', best, quality),
      if (coCorrect)
        option('equivalent', 'Fold', quality)
      else ...[
        option('needs_rep', 'Raise', Act0FeedbackQualityV1.suboptimal),
        option('miss', 'Fold', Act0FeedbackQualityV1.wrong),
      ],
    ],
  );
  final lesson = base.selectedWorld.lessons.first.copyWith(
    state: Act0LessonStateV1.current,
    isSelectable: true,
    isLocked: false,
    runner: runner,
    tasks: [
      Act0LessonTaskV1(
        taskId: _fixtureTaskId,
        title: 'Grade fixture',
        phase: Act0LessonPhaseV1.drill,
        runner: runner,
        rewardXp: _fixtureXp,
      ),
      Act0LessonTaskV1(
        taskId: '${_fixtureTaskId}_next',
        title: 'Next fixture hand',
        phase: Act0LessonPhaseV1.drill,
        runner: runner,
        rewardXp: _fixtureXp,
      ),
    ],
  );
  final world = base.selectedWorld.copyWith(lessons: [lesson]);
  return Act0ShellStateV1(
    courseTitle: base.courseTitle,
    courseSubtitle: base.courseSubtitle,
    levelLabel: base.levelLabel,
    xp: 0,
    xpTarget: base.xpTarget,
    streakDays: 0,
    dailyGoalLabel: base.dailyGoalLabel,
    dailyGoalValue: base.dailyGoalValue,
    pathProgressLabel: base.pathProgressLabel,
    selectedWorldId: world.worldId,
    worlds: [world],
    lessons: [lesson],
    review: base.review,
    profile: base.profile,
  );
}

void _runnerGradeTests() {
  testWidgets('coCorrect uses the Correct read label on the feedback card', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Act0FeedbackShellV1(
              title: 'Answer feedback',
              reason: 'Either action fits the exercise.',
              quality: Act0FeedbackQualityV1.coCorrect,
              sharkyLine: '',
              sharkyMood: Act0SharkyMoodV1.happy,
              selectedLabel: 'Check',
              preferredLabel: 'Check',
              betterLabel: 'Check',
              onContinue: () {},
            ),
          ),
        ),
      ),
    );
    expect(find.text('Correct read'), findsWidgets);
  });
  for (final (id, locale, grade, label, passes) in [
    ('alternative', 'en', 'acceptable', 'Also playable', true),
    ('alternative', 'ru', 'acceptable', 'Тоже можно', true),
    ('best', 'en', 'co_correct', 'CORRECT READ', true),
    ('equivalent', 'en', 'co_correct', 'CORRECT READ', true),
    ('needs_rep', 'en', 'suboptimal', "LET'S CHECK THE CLUE", false),
    ('miss', 'en', 'incorrect', 'MISSED CLUE', false),
  ]) {
    testWidgets(
      'fixture grade $grade ($id, $locale) records the correct outcome',
      (tester) async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'act0_welcome_completed_v1': true,
          'intake_completed_v1': true,
        });
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final fixture = _gradeFixture(coCorrect: grade == 'co_correct');

        Future<void> mount() async {
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(locale),
              supportedLocales: const [Locale('en'), Locale('ru')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              home: Act0ShellPreviewScreenV1(
                state: fixture,
                debugPersistFixtureProgress: true,
                initialPhase: Act0LessonPhaseV1.drill,
                showPlacementOnStart: false,
                enableBetaMetrics: false,
              ),
            ),
          );
          await tester.pumpAndSettle();
        }

        Future<void> tapKey(String key) async {
          final finder = find.byKey(Key(key)).hitTestable();
          expect(finder, findsOneWidget);
          await tester.tap(finder);
          await tester.pumpAndSettle();
        }

        const runnerType = Act0LessonRunnerShellV1;
        await mount();
        final launch = find
            .byKey(const Key('act0_academy_home_leaf_cta'))
            .hitTestable();
        await tapKey(
          launch.evaluate().isEmpty
              ? 'act0_shell_main_cta'
              : 'act0_academy_home_leaf_cta',
        );
        final runner = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(runnerType),
        );
        expect(runner.selectedTaskId, _fixtureTaskId);
        final choice = runner.runner.options.singleWhere(
          (option) => option.id == id,
        );
        expect(
          act0FirstValueSkillReceiptForRunnerV1(
            runner: runner.runner,
            option: choice,
            taskFamily: Act0TaskFamilyV1.decision,
          )?.outcome,
          passes
              ? Act0SkillReceiptOutcomeV1.learned
              : grade == 'suboptimal'
              ? Act0SkillReceiptOutcomeV1.needsRep
              : Act0SkillReceiptOutcomeV1.repairStarted,
        );
        await pumpSourceChoreographyToDecisionV1(tester, runner.runner.table);
        await tapKey('$_fixtureOptionKeyPrefix$id');
        expect(find.text(label), findsWidgets);
        if (grade == 'acceptable') {
          expect(
            find.text(locale == 'ru' ? 'ТОЖЕ МОЖНО' : 'ALSO PLAYABLE'),
            findsOneWidget,
          );
        }
        if (grade == 'acceptable') {
          final betterAnswer = locale == 'ru' ? 'Лучший ход' : 'Better answer';
          expect(
            find.textContaining(betterAnswer, findRichText: true),
            findsWidgets,
          );
          expect(find.textContaining('Check'), findsWidgets);
        }
        final prefs = await SharedPreferences.getInstance();
        Map<String, dynamic> saved() =>
            jsonDecode(prefs.getString('act0_shell_progress_v1')!)
                as Map<String, dynamic>;
        final feedback = saved();
        final history = feedback['learningEvidenceHistory'] as List;
        final decision = history.whereType<Map>().singleWhere(
          (record) => record['taskId'] == _fixtureTaskId,
        );
        expect(decision['resultKind'], grade);
        expect(decision['isCorrect'], passes);
        expect(decision['expectedChoiceId'], 'best');
        final mistakes = feedback['reviewMistakeHistory'] as List;
        expect(mistakes.isEmpty, passes);
        if (!passes) {
          expect(feedback['earnedXp'], 0);
          expect(feedback['completedTaskIds'], isEmpty);
        }
        final repairs = feedback['openRepairIntents'] as List;
        expect(repairs.isEmpty, passes);

        if (!passes) return;
        await tapKey('act0_shell_feedback_continue_cta');
        final before = saved();
        expect(before['earnedXp'], _fixtureXp);
        expect(before['completedTaskIds'], [_fixtureTaskId]);
        if (grade != 'acceptable') return;
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await mount();
        final shell =
            tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
        expect(shell.debugSelectedTaskIdV1(), '${_fixtureTaskId}_next');
        shell.debugPersistProgressV1();
        await tester.pumpAndSettle();
        final after = saved();
        expect(after['earnedXp'], _fixtureXp);
        expect(after['completedTaskIds'], [_fixtureTaskId]);
        expect(
          after['learningEvidenceHistory'],
          before['learningEvidenceHistory'],
        );
        expect(after['reviewMistakeHistory'], isEmpty);
        expect(after['openRepairIntents'], isEmpty);
      },
    );
  }
}
