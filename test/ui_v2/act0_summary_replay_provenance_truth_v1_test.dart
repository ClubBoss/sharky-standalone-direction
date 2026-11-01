import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Session Summary next-action truth and durable exact-replay provenance on
/// the real First Table Guide route (iPhone 14 Pro portrait, EN).
///
/// Native evidence: every Guide task answered correctly, `what_poker_is`
/// persisted complete and Home counting it, yet Summary read
/// "Almost there - replay to unlock". The lesson-run evidence boundary was
/// null (prior progress in the lesson) and the Summary then discarded every
/// scored result, reporting 0/N.

const _progressKey = 'act0_shell_progress_v1';
const _guideLessonId = 'what_poker_is';
const _falseUnlockTitle = 'Almost there - replay to unlock';

final _guideLesson = Act0ShellStateV1.sample
    .worldById('world_1')
    .lessons
    .firstWhere((lesson) => lesson.lessonId == _guideLessonId);
final _guideDrillTaskIds = <String>[
  for (final task in _guideLesson.taskList)
    if (task.phase == Act0LessonPhaseV1.drill) task.taskId,
];

Map<String, Object?> _record({
  required String recordId,
  required int createdOrder,
  required String lessonId,
  required String taskId,
  bool isCorrect = true,
  String skillAtomId = 'table_read',
  String reviewKind = 'alternateSameSignal',
  String assistanceKind = 'none',
}) => <String, Object?>{
  'schemaVersion': 1,
  'recordId': recordId,
  'createdOrder': createdOrder,
  'worldId': 'world_1',
  'lessonId': lessonId,
  'taskId': taskId,
  'sourceTaskId': taskId,
  'choiceId': isCorrect ? 'right' : 'wrong',
  'expectedChoiceId': 'right',
  'isCorrect': isCorrect,
  'errorType': isCorrect ? 'none' : 'missed_table_read',
  'conceptFamilyId': '',
  'repairFocusId': '',
  'skillAtomId': skillAtomId,
  'decisionTimeBucket': 'under_3s',
  'resultKind': isCorrect ? 'correct' : 'incorrect',
  'assistanceKind': assistanceKind,
  'runId': 'run_v1|world_1|$lessonId|lesson|1',
  'runKind': 'lesson',
  'runOrdinal': 1,
  'sourceWorldId': 'world_1',
  'sourceLessonId': lessonId,
  'startedBy': 'learn_route',
  'sessionId': 'session_v1|1',
  'recordedAtUtc': '2026-11-01T00:00:00.000Z',
  'reviewKind': reviewKind,
};

Future<void> _pumpGuide(
  WidgetTester tester, {
  List<String> completedTaskIds = const <String>[],
  List<Map<String, Object?>> history = const <Map<String, Object?>>[],
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues(<String, Object>{
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
    _progressKey: jsonEncode(<String, Object?>{
      'schemaVersion': 18,
      'completedTaskIds': completedTaskIds,
      'completedLessonIds': <String>[],
      'selectedWorldId': 'world_1',
      'selectedLessonId': _guideLessonId,
      'selectedTaskId': _guideLesson.taskList.first.taskId,
      'earnedXp': 0,
      if (history.isNotEmpty) 'learningEvidenceHistory': history,
    }),
  });
  await _mountRoot(tester);
}

Future<void> _mountRoot(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.play,
        initialPhase: Act0LessonPhaseV1.theory,
        showPlacementOnStart: false,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Plays the real lesson route with each task's authored correct choice
/// (independent: no hint or theory recall) until the Session Summary.
Future<List<String>> _answerGuideToSummary(WidgetTester tester) async {
  final answered = <String>[];
  for (var step = 0; step < 80; step++) {
    if (find
        .byKey(const Key('act0_shell_block_summary_title'))
        .evaluate()
        .isNotEmpty) {
      return answered;
    }
    final runners = find.byType(Act0LessonRunnerShellV1);
    if (runners.evaluate().isNotEmpty) {
      final runner = tester.widget<Act0LessonRunnerShellV1>(runners);
      final correct = runner.runner.options.where((o) => o.isCorrect);
      if (correct.isNotEmpty) {
        final choice = correct.first;
        final seat = find.byKey(Key('act0_shell_seat_tap_${choice.seatId}'));
        final option = find.byKey(Key('act0_shell_option_${choice.id}'));
        final target = seat.evaluate().isNotEmpty ? seat : option;
        if (target.evaluate().isNotEmpty) {
          answered.add(runner.selectedTaskId ?? '');
          await tester.ensureVisible(target.first);
          await tester.tap(target.first);
          await tester.pumpAndSettle();
          continue;
        }
      }
    }
    final forward = <String>[
      'act0_shell_theory_continue_cta',
      'act0_shell_continue_cta',
      'act0_shell_feedback_continue_cta',
    ].map((key) => find.byKey(Key(key))).where((f) => f.evaluate().isNotEmpty);
    expect(forward, isNotEmpty, reason: 'no forward route at step $step');
    await tester.ensureVisible(forward.first.first);
    await tester.tap(forward.first.first);
    await tester.pumpAndSettle();
  }
  fail('Session Summary not reached');
}

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data ?? '';

Future<Map<String, dynamic>> _persisted() async {
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString(_progressKey)!) as Map<String, dynamic>;
}

Future<void> _openTab(WidgetTester tester, String label) async {
  final tab = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text(label),
  );
  await tester.ensureVisible(tab);
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

Future<void> _leaveSummary(WidgetTester tester) async {
  final map = find.byKey(const Key('act0_shell_block_summary_map_cta'));
  if (map.evaluate().isNotEmpty) {
    await tester.ensureVisible(map);
    await tester.tap(map);
    await tester.pumpAndSettle();
  }
  final back = find.byKey(const Key('act0_shell_runner_back'));
  if (back.evaluate().isNotEmpty) {
    await tester.tap(back);
    await tester.pumpAndSettle();
  }
}

void main() {
  test('completed 75% permits next lesson without mastery', () {
    const completed = Act0BlockCompletionSummaryV1(
      lessonTitle: 'First Table Guide',
      xpEarned: 0,
      errorCount: 1,
      independentProvenanceKnown: false,
      curriculumCompleted: true,
      taskCount: 4,
      correctCount: 3,
      startLevel: 1,
      endLevel: 1,
      startXp: 0,
      endXp: 0,
      xpTarget: 100,
      nextLessonTitle: 'Blinds and action order',
    );
    expect(completed.accuracyPercent, 75);
    expect(completed.needsMorePractice, isTrue);
    expect(completed.qualifiesForNextLesson, isTrue);
    expect(completed.masteryStatus, Act0MasteryStatusV1.needsReview);
    expect(completed.milestoneTitle, 'Lesson complete');
    expect(completed.primaryCtaKind, Act0MilestoneCtaKindV1.continueForward);
    expect(completed.primaryCtaLabel, 'Open next lesson');
    expect(completed.gateMessage, contains('A focused replay can help'));
    expect(completed.gateMessage, isNot(contains('replay to unlock')));
  });

  test('legacy zero-evidence completion is not mastery', () {
    const legacy = Act0BlockCompletionSummaryV1(
      lessonTitle: 'First Table Guide',
      xpEarned: 0,
      errorCount: 0,
      independentProvenanceKnown: false,
      curriculumCompleted: true,
      taskCount: 4,
      correctCount: 0,
      startLevel: 1,
      endLevel: 1,
      startXp: 0,
      endXp: 0,
      xpTarget: 100,
      nextLessonTitle: 'Blinds and action order',
    );
    expect(legacy.qualifiesForNextLesson, isTrue);
    expect(legacy.needsMorePractice, isTrue);
    expect(legacy.masteryStatus, Act0MasteryStatusV1.needsReview);
    expect(legacy.milestoneTitle, 'Lesson complete');
    expect(legacy.habitRewardTitle, isNot('Clean read'));
    expect(legacy.habitRewardDetail, isNot(contains('Clean run')));
    expect(legacy.gateMessage, contains('A focused replay can help'));
  });

  test('unfinished low-accuracy lessons cannot claim completed progress', () {
    const unfinished = Act0BlockCompletionSummaryV1(
      lessonTitle: 'First Table Guide',
      xpEarned: 0,
      errorCount: 1,
      curriculumCompleted: false,
      taskCount: 4,
      correctCount: 3,
      startLevel: 1,
      endLevel: 1,
      startXp: 0,
      endXp: 0,
      xpTarget: 100,
      nextLessonTitle: 'Blinds and action order',
    );
    expect(unfinished.qualifiesForNextLesson, isFalse);
    expect(unfinished.milestoneTitle, 'Almost there - replay to unlock');
    expect(unfinished.masteryStatus, Act0MasteryStatusV1.needsReview);
  });

  group('Session Summary next action follows persisted completion truth', () {
    testWidgets('prior theory-only progress keeps a clean independent run', (
      tester,
    ) async {
      // A completed theory step carries no scored evidence, so it must not
      // make this run's assessment provenance unknown.
      await _pumpGuide(
        tester,
        completedTaskIds: <String>[_guideLesson.taskList.first.taskId],
      );
      final answered = await _answerGuideToSummary(tester);
      expect(answered, containsAll(_guideDrillTaskIds));

      expect(
        _text(tester, 'act0_shell_block_summary_title'),
        isNot(_falseUnlockTitle),
      );
      expect(
        _text(tester, 'act0_shell_block_summary_accuracy'),
        '100% accuracy (assessed) · '
        '${_guideDrillTaskIds.length}/${_guideDrillTaskIds.length} correct '
        '· 0 errors',
      );
      final persisted = await _persisted();
      expect(persisted['completedLessonIds'], contains(_guideLessonId));
      expect(
        (persisted['lessonRunEvidenceBoundaries'] as Map)[_guideLessonId],
        isNotNull,
      );
    });

    testWidgets(
      'prior assessed evidence: lesson complete, proof unverified, one valid '
      'next action; Home and You agree',
      (tester) async {
        // Native shape: an earlier repair-route answer inside the Guide.
        await _pumpGuide(
          tester,
          history: <Map<String, Object?>>[
            _record(
              recordId: 'prior_repair',
              createdOrder: 1,
              lessonId: _guideLessonId,
              taskId: 'what_poker_is_table_read_recheck',
            ),
          ],
        );
        await _answerGuideToSummary(tester);

        expect(
          _text(tester, 'act0_shell_block_summary_title'),
          'Lesson complete',
        );
        // Provenance is not invented: the run is not a verified clean pass.
        expect(
          _text(tester, 'act0_shell_block_summary_accuracy'),
          '${_guideDrillTaskIds.length}/${_guideDrillTaskIds.length} assessed '
          'correct · full-lesson proof unverified · 0 errors',
        );
        expect(find.text('One clean read'), findsNothing);
        final cta = find.byKey(
          const Key('act0_shell_block_summary_continue_cta'),
        );
        expect(cta, findsOneWidget);
        expect(
          find.descendant(of: cta, matching: find.text('Open next lesson')),
          findsOneWidget,
        );
        expect(find.text('Replay before next lesson'), findsNothing);

        final persisted = await _persisted();
        expect(persisted['completedLessonIds'], contains(_guideLessonId));
        expect(
          persisted['completedTaskIds'],
          containsAll(_guideLesson.taskList.map((t) => t.taskId)),
        );

        await _leaveSummary(tester);
        await _openTab(tester, 'Home');
        final home = tester.widget<Act0HomeShellV1>(
          find.byType(Act0HomeShellV1),
        );
        expect(home.pathProgressLabel, startsWith('1 of '));
        await _openTab(tester, 'You');
        final you = tester.widget<Act0ProfileShellV1>(
          find.byType(Act0ProfileShellV1),
        );
        expect(you.profile.completedTaskCount, _guideLesson.taskList.length);
      },
    );

    testWidgets('genuine earlier mistake stays counted, never a clean pass', (
      tester,
    ) async {
      await _pumpGuide(
        tester,
        history: <Map<String, Object?>>[
          _record(
            recordId: 'prior_wrong',
            createdOrder: 1,
            lessonId: _guideLessonId,
            taskId: 'what_poker_is_table_read_recheck',
            isCorrect: false,
            reviewKind: 'initialAssessment',
          ),
        ],
      );
      await _answerGuideToSummary(tester);

      final n = _guideDrillTaskIds.length;
      expect(
        _text(tester, 'act0_shell_block_summary_accuracy'),
        '${n - 1}/$n assessed correct · full-lesson proof unverified · 1 error',
      );
      expect(
        _text(tester, 'act0_shell_block_summary_title'),
        'Lesson complete',
      );
      expect(find.text('One clean read'), findsNothing);
      final continueCta = find.byKey(
        const Key('act0_shell_block_summary_continue_cta'),
      );
      expect(continueCta, findsOneWidget);
      expect(
        find.descendant(
          of: continueCta,
          matching: find.text('Open next lesson'),
        ),
        findsOneWidget,
      );
      final persisted = await _persisted();
      expect(persisted['completedLessonIds'], contains(_guideLessonId));
      await _leaveSummary(tester);
      await _openTab(tester, 'Home');
      final home = tester.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
      expect(home.pathProgressLabel, startsWith('1 of '));
    });

    testWidgets('earlier assisted answer is not independent completion', (
      tester,
    ) async {
      await _pumpGuide(
        tester,
        history: <Map<String, Object?>>[
          _record(
            recordId: 'prior_assisted',
            createdOrder: 1,
            lessonId: _guideLessonId,
            taskId: 'what_poker_is_table_read_recheck',
            assistanceKind: 'theoryRecall',
          ),
        ],
      );
      await _answerGuideToSummary(tester);
      expect(find.text('One clean read'), findsNothing);
      expect(find.text('Practice recorded'), findsOneWidget);
    });
  });

  testWidgets(
    'restart + over 200 later records: Learn replay stays exactReplay with '
    'no XP, completion, due or transfer gain',
    (tester) async {
      await _pumpGuide(tester);
      await _answerGuideToSummary(tester);
      // Process ends; the persisted snapshot then gains later evidence.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      final first = await _persisted();
      final firstRecords = (first['learningEvidenceHistory'] as List)
          .cast<Map<String, dynamic>>();
      // First genuine answers: the first in a family is the initial
      // assessment; a distinct task in an already practised family is an
      // unseen transfer. Neither is a replay.
      expect(firstRecords.first['reviewKind'], 'initialAssessment');
      expect(<String>{
        'initialAssessment',
        'unseenTransfer',
      }, containsAll(firstRecords.map((r) => r['reviewKind']).toSet()));
      final xpAfterFirst = first['earnedXp'] as int;
      final completedAfterFirst = (first['completedTaskIds'] as List).toSet();
      final family = firstRecords.first['skillAtomId'] as String;

      // 201 later records in the same concept family on another lesson evict
      // every Guide record from the 200-record history.
      final maxOrder = firstRecords
          .map((r) => r['createdOrder'] as int)
          .reduce((a, b) => a > b ? a : b);
      first['learningEvidenceHistory'] = <Map<String, Object?>>[
        for (var i = 1; i <= 201; i++)
          _record(
            recordId: 'later_$i',
            createdOrder: maxOrder + i,
            lessonId: 'fold_check_call_raise',
            taskId: 'actions_check_drill',
            skillAtomId: family,
            reviewKind: 'initialAssessment',
          ),
      ].sublist(1);
      first['selectedLessonId'] = _guideLessonId;
      first['selectedTaskId'] = _guideLesson.taskList.first.taskId;
      first.remove('lessonRunEvidenceBoundaries');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_progressKey, jsonEncode(first));

      // Process restart, then replay the completed Guide.

      await _mountRoot(tester);
      // Learn > completed Guide > Replay: the real Learn callbacks behind
      // the completed task's Replay CTA (no direct completion calls).
      await _leaveSummary(tester);
      await _openTab(tester, 'Learn');
      final learn = tester.widget<Act0LearnPathShellV1>(
        find.byType(Act0LearnPathShellV1),
      );
      final firstTaskId = _guideLesson.taskList.first.taskId;
      learn.onSelectTask(_guideLessonId, firstTaskId);
      await tester.pumpAndSettle();
      tester
          .widget<Act0LearnPathShellV1>(find.byType(Act0LearnPathShellV1))
          .onStartTask(_guideLessonId, firstTaskId);
      await tester.pumpAndSettle();
      final replayed = await _answerGuideToSummary(tester);
      expect(replayed, containsAll(_guideDrillTaskIds));

      final after = await _persisted();
      final replayRecords = (after['learningEvidenceHistory'] as List)
          .cast<Map<String, dynamic>>()
          .where((r) => _guideDrillTaskIds.contains(r['taskId']))
          .toList();
      expect(replayRecords, isNotEmpty);
      expect(
        replayRecords.map((r) => r['reviewKind']).toSet(),
        <String>{'exactReplay'},
        reason: 'neither a fresh assessment nor an unseen transfer',
      );
      expect(after['earnedXp'], xpAfterFirst, reason: 'replay earns no XP');
      expect(
        (after['completedTaskIds'] as List).toSet(),
        completedAfterFirst,
        reason: 'no duplicate or extra completion',
      );
      final root =
          tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      final retention = (root.debugDurableRetentionPayloadV1() as List)
          .cast<Map<String, Object?>>();
      for (final family in retention) {
        expect(family['spacedSuccessStage'] ?? 0, 0, reason: '$family');
      }
    },
  );
}
