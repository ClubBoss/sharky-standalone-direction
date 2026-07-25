import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _progressKey = 'act0_shell_progress_v1';
const _fixturePath =
    'tools/contracts/e2e_product_integrity_checkpoint_progressed_replay_v1.json';
const _contractPath =
    'tools/contracts/e2e_product_integrity_checkpoint_v1.json';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test(
    'progressed replay fixture is production-achievable and leaves Price fresh',
    () {
      final fixture = _fixture();
      final state = Act0ShellStateV1.sample;
      final progress = _persistedProgressForFixture(state, fixture);
      final completedLessonIds = progress['completedLessonIds'] as List<String>;
      final completedTaskIds = progress['completedTaskIds'] as List<String>;
      final target = fixture['target'] as Map<String, dynamic>;
      final replay = target['replay'] as Map<String, dynamic>;
      final current = target['current'] as Map<String, dynamic>;
      final currentLesson = state
          .worldById(current['world_id'] as String)
          .lessons
          .firstWhere((lesson) => lesson.lessonId == current['lesson_id']);

      expect(completedLessonIds, contains(replay['lesson_id']));
      expect(completedTaskIds, contains(replay['task_id']));
      expect(completedLessonIds, isNot(contains(current['lesson_id'])));
      expect(
        currentLesson.taskList.map((task) => task.taskId),
        isNot(contains(anyOf(completedTaskIds))),
      );
      expect(progress['openRepairIntents'], isNull);
      expect(progress['learningRun'], isNull);
    },
  );

  testWidgets(
    'completed Position is visibly replayable while Price remains current',
    (tester) async {
      final fixture = _fixture();
      SharedPreferences.setMockInitialValues(<String, Object>{
        'intake_completed_v1': true,
        'act0_welcome_completed_v1': true,
        _progressKey: jsonEncode(
          _persistedProgressForFixture(Act0ShellStateV1.sample, fixture),
        ),
      });
      await tester.pumpWidget(
        const MaterialApp(
          home: Act0ShellPreviewScreenV1(initialTab: Act0ShellTabV1.learn),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Call price'), findsWidgets);

      await tester.tap(find.byKey(const Key('act0_shell_levels_menu_button')));
      await tester.pumpAndSettle();
      final worldThree = find.byKey(const Key('act0_shell_world_3'));
      await tester.scrollUntilVisible(
        worldThree,
        240,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(worldThree);
      await tester.pumpAndSettle();

      final replayLesson = find.byKey(
        const Key('act0_shell_lesson_The 6 positions'),
      );
      await tester.ensureVisible(replayLesson);
      await tester.tap(replayLesson);
      await tester.pumpAndSettle();
      expect(find.text('Replay available'), findsWidgets);
    },
  );

  test(
    'contract keeps historical completion separate from current run outcomes',
    () {
      final contract =
          jsonDecode(File(_contractPath).readAsStringSync())
              as Map<String, dynamic>;
      expect(contract['schema'], 'act0_e2e_product_integrity_checkpoint_v1');
      expect(contract['fixture_id'], _fixture()['fixture_id']);
      final route = (contract['route'] as List<dynamic>).cast<String>();
      expect(route.first, 'Learn');
      expect(route, contains('explicit Learn to Home'));
      expect(
        (contract['required_invariants'] as List<dynamic>).cast<String>(),
        contains('Position and Price share one Learning Run run_id'),
      );
    },
  );

  test(
    'Darwin fixture contract maps every startup key through legacy prefix',
    () {
      final contract =
          jsonDecode(File(_contractPath).readAsStringSync())
              as Map<String, dynamic>;
      final storage =
          contract['darwin_legacy_shared_preferences_fixture']
              as Map<String, dynamic>;
      final entries = (storage['entries'] as List<dynamic>)
          .cast<Map<String, dynamic>>();

      expect(storage['storage_api'], 'SharedPreferences.getInstance');
      expect(storage['native_prefix'], 'flutter.');
      expect(
        entries.map((entry) => entry['native_key']),
        containsAll(<String>[
          'flutter.onboardingCompleted',
          'flutter.onboarding_complete',
          'flutter.intake_completed_v1',
          'flutter.act0_welcome_completed_v1',
          'flutter.act0_shell_progress_v1',
        ]),
      );
      expect(
        entries.where((entry) => entry['dart_key'] != 'act0_shell_progress_v1'),
        everyElement(
          allOf(
            containsPair('value_type', 'bool'),
            containsPair('value', true),
          ),
        ),
      );
      expect(
        entries.singleWhere(
          (entry) => entry['dart_key'] == 'act0_shell_progress_v1',
        )['value_type'],
        'string_json',
      );
    },
  );

  testWidgets('canonical root consumes the approved persisted fixture', (
    tester,
  ) async {
    final fixture = _fixture();
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'onboarding_complete': true,
      'intake_completed_v1': true,
      'act0_welcome_completed_v1': true,
      _progressKey: jsonEncode(
        _persistedProgressForFixture(Act0ShellStateV1.sample, fixture),
      ),
    });
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byKey(const Key('act0_shell_placement_screen')), findsNothing);
    expect(find.byKey(const Key('act0_shell_home_screen')), findsOneWidget);
    await tester.tap(find.text('Learn').last);
    await tester.pumpAndSettle();
    expect(find.text('Call price'), findsWidgets);
  });
}

Map<String, dynamic> _fixture() =>
    jsonDecode(File(_fixturePath).readAsStringSync()) as Map<String, dynamic>;

Map<String, Object> _persistedProgressForFixture(
  Act0ShellStateV1 state,
  Map<String, dynamic> fixture,
) {
  final lessonIdsByWorld =
      fixture['completed_lesson_ids_by_world'] as Map<String, dynamic>;
  final completedLessonIds = <String>[];
  final completedTaskIds = <String>[];
  for (final entry in lessonIdsByWorld.entries) {
    final world = state.worldById(entry.key);
    for (final lessonId in (entry.value as List<dynamic>).cast<String>()) {
      final lesson = world.lessons.firstWhere(
        (candidate) => candidate.lessonId == lessonId,
      );
      completedLessonIds.add(lessonId);
      completedTaskIds.addAll(lesson.taskList.map((task) => task.taskId));
    }
  }
  final current =
      (fixture['target'] as Map<String, dynamic>)['current']
          as Map<String, dynamic>;
  return <String, Object>{
    'schemaVersion': 16,
    'completedTaskIds': completedTaskIds,
    'skippedTaskIds': <String>[],
    'completedLessonIds': completedLessonIds,
    'selectedWorldId': current['world_id'] as String,
    'selectedLessonId': current['lesson_id'] as String,
    'selectedTaskId': current['task_id'] as String,
    'earnedXp': 0,
  };
}
