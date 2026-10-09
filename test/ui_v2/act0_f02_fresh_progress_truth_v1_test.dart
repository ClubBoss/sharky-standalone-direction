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
    String? lastActiveDay,
    String? lastEarnedDailyDay,
  }) {
    final sample = Act0ShellStateV1.sample;
    return jsonEncode(<String, Object>{
      'schemaVersion': lastEarnedDailyDay == null ? 17 : 18,
      'completedTaskIds': completedTaskIds.toList(),
      'completedLessonIds': <String>[],
      'selectedWorldId': sample.selectedWorldId,
      'selectedLessonId': sample.currentLesson.lessonId,
      'selectedTaskId': sample.currentLesson.taskList.first.taskId,
      'earnedXp': completedTaskIds.isEmpty ? 0 : 10,
      'lastActiveDay':
          lastActiveDay ?? DateTime.now().toIso8601String().substring(0, 10),
      if (lastEarnedDailyDay != null) 'lastEarnedDailyDay': lastEarnedDailyDay,
      'dailyCompletedRepCount': dailyCompletedRepCount,
      'persistedStreakDays': persistedStreakDays,
    });
  }

  String dayKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

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
      expect(profile.consistencyActiveDays, -1);
      expect(profile.streakLast7, isEmpty);
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
          lastEarnedDailyDay: dayKey(
            DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day - 1,
            ),
          ),
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
      // A streak count does not establish lifetime activity or dated week cells.
      expect(profile.consistencyActiveDays, -1);
      expect(profile.streakLast7, isEmpty);
      expect(
        find.byKey(const Key('act0_shell_profile_rhythm_strip')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_profile_rhythm_week_button')),
        findsNothing,
      );
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
          lastEarnedDailyDay: dayKey(DateTime.now()),
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
    'F02: migrated legacy 3/3 after midnight must not mint earned day',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final today = dayKey(DateTime.now());
      // Old runtime completed 3/3 yesterday, stayed open past midnight,
      // then autosaved stale 3/3 with today's ordinary activity date.
      SharedPreferences.setMockInitialValues(<String, Object>{
        progressKey: snapshot(
          persistedStreakDays: 5,
          dailyCompletedRepCount: 3,
          lastActiveDay: today,
          // No independent date of the earned daily set.
        ),
      });
      await mount(tester);
      var home = tester.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
      expect(home.state.streakDays, 0);
      final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
      state.debugPersistProgressV1();
      await tester.pump(const Duration(milliseconds: 250));
      final prefs = await SharedPreferences.getInstance();
      final payload =
          jsonDecode(prefs.getString(progressKey)!) as Map<String, dynamic>;
      expect(payload['lastEarnedDailyDay'], '');
      expect(payload['persistedStreakDays'], 0);
      expect(payload['dailyCompletedRepCount'], 0);
      await tester.pumpWidget(const SizedBox.shrink());
      await mount(tester);
      home = tester.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
      expect(home.state.streakDays, 0);
    },
  );

  testWidgets(
    'F02: legacy undated 2/3 cannot be reused as today after midnight',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues(<String, Object>{
        progressKey: snapshot(
          persistedStreakDays: 5,
          dailyCompletedRepCount: 2,
          lastActiveDay: dayKey(DateTime.now()),
          // Historical record has NO lastEarnedDailyDay field.
        ),
      });
      await mount(tester);
      final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
      state.debugPersistProgressV1();
      await tester.pump(const Duration(milliseconds: 250));
      final prefs = await SharedPreferences.getInstance();
      final payload =
          jsonDecode(prefs.getString(progressKey)!) as Map<String, dynamic>;
      expect(payload['dailyCompletedRepCount'], 0);
      expect(payload['lastEarnedDailyDay'], '');
      expect(payload['persistedStreakDays'], 0);
    },
  );

  testWidgets(
    'F02: proven-format fresh partial 2/3 still resumes after restart',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues(<String, Object>{
        progressKey: snapshot(
          persistedStreakDays: 0,
          dailyCompletedRepCount: 2,
          lastActiveDay: dayKey(DateTime.now()),
          lastEarnedDailyDay: '',
        ),
      });
      await mount(tester);
      final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
      state.debugPersistProgressV1();
      await tester.pump(const Duration(milliseconds: 250));
      final prefs = await SharedPreferences.getInstance();
      final payload =
          jsonDecode(prefs.getString(progressKey)!) as Map<String, dynamic>;
      expect(payload['dailyCompletedRepCount'], 2);
      expect(payload['lastEarnedDailyDay'], '');
      expect(payload['persistedStreakDays'], 0);
    },
  );

  testWidgets(
    'F02: legacy partial save without earned-day proof cannot certify streak',
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
      final home = tester.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
      expect(home.state.streakDays, 0);
      final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
      state.debugPersistProgressV1();
      await tester.pump(const Duration(milliseconds: 250));
      final prefs = await SharedPreferences.getInstance();
      final payload =
          jsonDecode(prefs.getString(progressKey)!) as Map<String, dynamic>;
      expect(payload['lastEarnedDailyDay'], '');
      expect(payload['persistedStreakDays'], 0);
    },
  );

  testWidgets(
    'F02: an unfinished intervening day cannot extend an earned streak',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final today = DateTime.now();
      final yesterday = dayKey(
        DateTime(today.year, today.month, today.day - 1),
      );
      final twoDaysAgo = dayKey(
        DateTime(today.year, today.month, today.day - 2),
      );
      SharedPreferences.setMockInitialValues(<String, Object>{
        progressKey: snapshot(
          persistedStreakDays: 5,
          dailyCompletedRepCount: 0,
          lastActiveDay: yesterday,
          lastEarnedDailyDay: twoDaysAgo,
        ),
      });
      await mount(tester);
      final home = tester.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
      expect(
        home.state.streakDays,
        0,
        reason: 'Opening yesterday without 3/3 did not save the streak.',
      );
      final dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
      state.debugPersistProgressV1();
      await tester.pump(const Duration(milliseconds: 250));
      final prefs = await SharedPreferences.getInstance();
      final payload =
          jsonDecode(prefs.getString(progressKey)!) as Map<String, dynamic>;
      expect(payload['lastActiveDay'], dayKey(today));
      expect(payload['lastEarnedDailyDay'], twoDaysAgo);
      expect(payload['persistedStreakDays'], 0);
    },
  );

  testWidgets(
    'F02: partial today preserves yesterday earned anchor; 3/3 earns once',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final today = dayKey(DateTime.now());
      final yesterday = dayKey(
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day - 1,
        ),
      );
      SharedPreferences.setMockInitialValues(<String, Object>{
        progressKey: snapshot(
          persistedStreakDays: 5,
          dailyCompletedRepCount: 2,
          lastActiveDay: today,
          lastEarnedDailyDay: yesterday,
        ),
      });
      await mount(tester);
      var home = tester.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
      expect(home.state.streakDays, 5);
      dynamic state = tester.state(find.byType(Act0ShellPreviewScreenV1));
      state.debugPersistProgressV1();
      await tester.pump(const Duration(milliseconds: 250));
      final prefs = await SharedPreferences.getInstance();
      var payload =
          jsonDecode(prefs.getString(progressKey)!) as Map<String, dynamic>;
      expect(payload['lastActiveDay'], today);
      expect(payload['lastEarnedDailyDay'], yesterday);
      expect(payload['persistedStreakDays'], 5);
      await tester.pumpWidget(const SizedBox.shrink());
      await mount(tester);
      home = tester.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
      expect(home.state.streakDays, 5);

      // Recreate the durable post-third-rep state using the same day's
      // persisted partial record (no invented older earned day).
      await tester.pumpWidget(const SizedBox.shrink());
      payload['dailyCompletedRepCount'] = 3;
      await prefs.setString(progressKey, jsonEncode(payload));
      await mount(tester);
      home = tester.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
      expect(home.state.streakDays, 6);
      state = tester.state(find.byType(Act0ShellPreviewScreenV1));
      state.debugPersistProgressV1();
      await tester.pump(const Duration(milliseconds: 250));
      payload =
          jsonDecode(prefs.getString(progressKey)!) as Map<String, dynamic>;
      expect(payload['lastEarnedDailyDay'], today);
      expect(payload['persistedStreakDays'], 6);
      await tester.pumpWidget(const SizedBox.shrink());
      await mount(tester);
      home = tester.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
      expect(home.state.streakDays, 6);
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
      expect(profile.consistencyActiveDays, -1);
      expect(profile.streakLast7, isEmpty);
      expect(
        profile.achievements
            .singleWhere((item) => item.id == 'three_day_streak')
            .locked,
        isTrue,
      );
    },
  );
}
