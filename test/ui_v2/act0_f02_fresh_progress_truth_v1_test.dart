import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  const progressKey = 'act0_shell_progress_v1';

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  Widget host({Act0ShellTabV1 tab = Act0ShellTabV1.home}) => MaterialApp(
    home: Act0ShellPreviewScreenV1(
      initialTab: tab,
      showPlacementOnStart: false,
    ),
  );

  Future<void> mount(
    WidgetTester tester, {
    Act0ShellTabV1 tab = Act0ShellTabV1.home,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(host(tab: tab));
    await tester.pumpAndSettle();
  }

  String snapshot({
    required int persistedStreakDays,
    required int dailyCompletedRepCount,
    Set<String> completedTaskIds = const <String>{},
  }) {
    final sample = Act0ShellStateV1.sample;
    return jsonEncode(<String, Object>{
      'schemaVersion': 17,
      'completedTaskIds': completedTaskIds.toList(),
      'completedLessonIds': <String>[],
      'selectedWorldId': sample.selectedWorldId,
      'selectedLessonId': sample.currentLesson.lessonId,
      'selectedTaskId': sample.currentLesson.taskList.first.taskId,
      'earnedXp': completedTaskIds.isEmpty ? 0 : 10,
      'lastActiveDay': DateTime.now().toIso8601String().substring(0, 10),
      'dailyCompletedRepCount': dailyCompletedRepCount,
      'persistedStreakDays': persistedStreakDays,
    });
  }

  testWidgets(
    'F02: ordinary fresh Home and Profile cannot earn sample streak',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await mount(tester);
      final home = tester.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
      expect(
        home.state.streakDays,
        0,
        reason: 'A fresh user cannot inherit sample 3d.',
      );
      expect(
        home.state.xp,
        0,
        reason: 'Fresh progress cannot inherit sample XP.',
      );
      expect(find.text('3d'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await mount(tester, tab: Act0ShellTabV1.profile);
      final profile = tester
          .widget<Act0ProfileShellV1>(find.byType(Act0ProfileShellV1))
          .profile;
      expect(profile.streakDays, 0);
      expect(profile.xpLine, '0 / 200 XP');
      expect(profile.accuracyLine, isNot(contains('82%')));
      expect(profile.consistencyActiveDays, 0);
      expect(profile.streakLast7, everyElement(isFalse));
      expect(
        profile.achievements
            .singleWhere((item) => item.id == 'three_day_streak')
            .locked,
        isTrue,
      );
    },
  );

  testWidgets(
    'F02: a legitimate restored five-day streak survives cold remount',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues(<String, Object>{
        progressKey: snapshot(
          persistedStreakDays: 5,
          dailyCompletedRepCount: 0,
        ),
      });
      await mount(tester);
      expect(
        tester
            .widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1))
            .state
            .streakDays,
        5,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await mount(tester, tab: Act0ShellTabV1.profile);
      final profile = tester
          .widget<Act0ProfileShellV1>(find.byType(Act0ProfileShellV1))
          .profile;
      expect(profile.streakDays, 5);
      expect(
        profile.achievements
            .singleWhere((item) => item.id == 'three_day_streak')
            .locked,
        isFalse,
      );
    },
  );

  testWidgets(
    'F02: one completed daily set earns just day one and restores it',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const completedTaskId = 'what_poker_is_find_hero';
      SharedPreferences.setMockInitialValues(<String, Object>{
        progressKey: snapshot(
          persistedStreakDays: 0,
          dailyCompletedRepCount: 3,
          completedTaskIds: const <String>{completedTaskId},
        ),
      });
      await mount(tester);
      expect(
        tester
            .widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1))
            .state
            .streakDays,
        1,
      );
      final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
      state.debugPersistProgressV1();
      await tester.pump(const Duration(milliseconds: 250));
      final prefs = await SharedPreferences.getInstance();
      final payload =
          jsonDecode(prefs.getString(progressKey)!) as Map<String, dynamic>;
      expect(payload['persistedStreakDays'], 1);
      expect(
        (payload['completedTaskIds'] as List<dynamic>),
        contains(completedTaskId),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await mount(tester, tab: Act0ShellTabV1.profile);
      final profile = tester
          .widget<Act0ProfileShellV1>(find.byType(Act0ProfileShellV1))
          .profile;
      expect(profile.streakDays, 1);
      expect(
        profile.achievements
            .singleWhere((item) => item.id == 'three_day_streak')
            .locked,
        isTrue,
      );
    },
  );

  testWidgets(
    'F02: empty persisted record must not reactivate sample milestone',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues(<String, Object>{
        progressKey: snapshot(
          persistedStreakDays: 0,
          dailyCompletedRepCount: 0,
        ),
      });
      await mount(tester, tab: Act0ShellTabV1.profile);
      final profile = tester
          .widget<Act0ProfileShellV1>(find.byType(Act0ProfileShellV1))
          .profile;
      expect(profile.streakDays, 0);
      expect(profile.xpLine, '0 / 200 XP');
      expect(profile.accuracyLine, isNot(contains('82%')));
      expect(profile.consistencyActiveDays, 0);
      expect(profile.streakLast7, everyElement(isFalse));
      expect(
        profile.achievements
            .singleWhere((item) => item.id == 'three_day_streak')
            .locked,
        isTrue,
      );
    },
  );
}
