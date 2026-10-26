// All preferences and safe-area insets are widget fixtures; no native claim.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_north_star_preview_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';

void main() {
  testWidgets(
    '393x852 widget geometry and source-owned earned-versus-skipped progress',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      Future<void> mount(
        Map<String, Object> prefs, {
        bool sample = false,
      }) async {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        SharedPreferences.setMockInitialValues(prefs);
        await tester.pumpWidget(
          MaterialApp(
            home: Act0ShellPreviewScreenV1(
              key: UniqueKey(),
              showPlacementOnStart: false,
              state: sample ? Act0ShellStateV1.sample : null,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await mount({}, sample: true);
      final regions = <String, Object>{};
      for (final entry in <String, String>{
        'header': 'act0_shell_home_identity_row',
        'recall': 'act0_home_north_star_stage_1',
        'learn': 'act0_home_north_star_stage_2',
        'apply': 'act0_home_north_star_stage_3',
        'next_action': 'act0_shell_home_mission_command_card',
        'cta': 'act0_shell_home_v6_primary_cta',
        'progress': 'act0_home_north_star_course_progress',
        'navigation': 'act0_shell_bottom_nav',
      }.entries) {
        final finder = find.byKey(Key(entry.value));
        if (finder.evaluate().isEmpty) {
          regions[entry.key] = 'NOT_BUILT_OFFSCREEN';
          continue;
        }
        final r = tester.getRect(finder);
        regions[entry.key] = {
          'x': r.left,
          'y': r.top,
          'w': r.width,
          'h': r.height,
        };
      }
      print(jsonEncode(regions));
      final cta = tester.getRect(find.byKey(const Key('act0_shell_main_cta')));
      final nav = tester.getRect(
        find.byKey(const Key('act0_shell_bottom_nav')),
      );
      expect(cta.height, greaterThanOrEqualTo(44));
      expect(cta.bottom, lessThanOrEqualTo(nav.top));
      // Entering Home directly with no saved record is a debug bypass that
      // retains sample route completions. Use an explicit zero-earned snapshot
      // for this presentation assertion; this is not a first-install proof.
      final zero = <String, Object>{
        'act0_shell_progress_v1': jsonEncode({
          'schemaVersion': 18,
          'completedTaskIds': <String>[],
          'completedLessonIds': <String>[],
          'skippedTaskIds': <String>[],
          'selectedWorldId': 'world_1',
          'selectedLessonId': 'what_poker_is',
          'selectedTaskId': 'first_table_guide_route_roles',
          'earnedXp': 0,
          'persistedStreakDays': 0,
        }),
      };
      await mount(zero);
      expect(
        tester
            .widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1))
            .earnedLessonCount,
        0,
      );
      expect(
        find.byKey(const Key('act0_home_north_star_streak')),
        findsNothing,
      );
      final sample = Act0ShellStateV1.sample;
      final skipped = sample
          .worldById('world_1')
          .lessons
          .expand((l) => l.taskList)
          .map((t) => t.taskId)
          .toList();
      final prefs = <String, Object>{
        'act0_shell_progress_v1': jsonEncode({
          'schemaVersion': 18,
          'completedTaskIds': <String>[],
          'completedLessonIds': <String>[],
          'skippedTaskIds': skipped,
          'selectedWorldId': 'world_1',
          'selectedLessonId': sample.currentLesson.lessonId,
          'selectedTaskId': sample.currentLesson.taskList.first.taskId,
          'earnedXp': 0,
          'persistedStreakDays': 0,
        }),
      };
      await mount(prefs);
      final home = tester.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
      expect(home.earnedLessonCount, 0);
      expect(home.courseLessonCount, greaterThan(0));
      await tester.drag(
        find.byKey(const Key('act0_shell_home_screen')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('0 of ${home.courseLessonCount} lessons complete'),
        findsOneWidget,
      );
      final raw =
          jsonDecode(
                File(
                  'test/ui_v2/fixtures/s09_c_native_w1_complete_open_intent_prefs_v1.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      await mount({for (final e in raw.entries) e.key: e.value as Object});
      expect(
        tester
            .widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1))
            .earnedLessonCount,
        1,
      );
      await tester.drag(
        find.byKey(const Key('act0_shell_home_screen')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 of 9 lessons complete'), findsOneWidget);
    },
    skip: !kAct0HomeNorthStarPreviewV1,
  );
}
