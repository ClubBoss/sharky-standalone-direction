import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_play_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';

void main() {
  for (final earnedXp in [0, 37]) {
    testWidgets(
      'daily count alone cannot claim improvement; saved total XP $earnedXp stays factual',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(393, 852));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final today = DateTime.now().toIso8601String().substring(0, 10);
        // Restoration fixture only: a completed daily set without independent
        // decision evidence must never become an improvement verdict.
        final saved = {
          'schemaVersion': 18,
          'completedTaskIds': ['what_poker_is_find_hero'],
          'completedLessonIds': <String>[],
          'selectedWorldId': 'world_1',
          'selectedLessonId': 'what_poker_is',
          'selectedTaskId': 'what_poker_is_find_hero',
          'earnedXp': earnedXp,
          'lastActiveDay': today,
          'lastEarnedDailyDay': today,
          'dailyCompletedRepCount': 3,
          'persistedStreakDays': 1,
        };
        SharedPreferences.setMockInitialValues({
          'intake_completed_v1': true,
          'act0_welcome_completed_v1': true,
          'act0_shell_progress_v1': jsonEncode(saved),
        });
        await tester.pumpWidget(
          MaterialApp(
            home: Act0ShellPreviewScreenV1(showPlacementOnStart: false),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Practice').last);
        await tester.pumpAndSettle();
        final daily = tester
            .widget<Act0PlayShellV1>(find.byType(Act0PlayShellV1))
            .groups
            .singleWhere((group) => group.groupId == 'daily');
        expect(daily.title, 'Daily short reps complete');
        expect(daily.subtitle, isNot(contains('Table read improved')));
        expect(daily.subtitle, contains('$earnedXp total XP earned'));
        expect(
          daily.subtitle,
          contains('Completion alone does not verify independent improvement'),
        );
        final prefs = await SharedPreferences.getInstance();
        final restored =
            jsonDecode(prefs.getString('act0_shell_progress_v1')!)
                as Map<String, dynamic>;
        expect(restored['earnedXp'], earnedXp);
        expect(restored['completedTaskIds'], saved['completedTaskIds']);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
