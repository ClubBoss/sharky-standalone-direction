// Capture and compare explicitly on the same Flutter host. Use --update-goldens
// for the first reviewed baseline. PNGs are local under .dart_tool.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_you_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w14_skill_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _captureKey = Key('act0_b38_golden_viewport');

Future<void> _show(WidgetTester tester, Widget app) =>
    tester.pumpWidget(RepaintBoundary(key: _captureKey, child: app));

Future<void> _capture(WidgetTester tester, String name) async {
  expect(tester.takeException(), isNull);
  await expectLater(
    find.byKey(_captureKey),
    matchesGoldenFile('../../.dart_tool/b38_goldens/$name.png'),
  );
}

void main() {
  for (final started in [false, true]) {
    final name = started ? 'you_in_progress' : 'you_first_run';
    testWidgets(name, (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final world = Act0ShellStateV1.sample.worlds.first;
      await _show(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0AcademyYouLeafV1(
              input: Act0AcademyYouLeafInputV1(
                levelLabel: started ? 'Level 2' : 'Level 1',
                xpLine: started ? '60 XP' : '0 XP',
                completedTaskCount: started ? 2 : 0,
                independentAnswers: started ? 1 : 0,
                repairedAnswers: started ? 1 : 0,
                worlds: [
                  world.copyWith(
                    progressLabel:
                        '1 of ${world.lessons.length} lessons complete',
                  ),
                ],
                skills: started
                    ? const [
                        Act0W14SkillStateV1(
                          label: 'Read the table',
                          lessonCount: 1,
                          taskCount: 3,
                          answeredTasks: 2,
                          independentTasks: 1,
                          helpedOrUnverifiedTasks: 1,
                          tasksToRevisit: 0,
                        ),
                      ]
                    : const [],
                onOpenSettings: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (started) {
        await tester.tap(find.text('Worlds'));
        await tester.pumpAndSettle();
      }
      await _capture(tester, name);
    });
  }

  for (final state in ['default', 'denied', 'delete_confirm']) {
    testWidgets('settings_$state', (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      const channel = MethodChannel('com.clubboss.sharky/practice_reminder_v1');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        channel,
        (call) async => call.method == 'permissionDenied' && state == 'denied',
      );
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      SharedPreferences.setMockInitialValues({
        'onboardingCompleted': true,
        'act0_welcome_completed_v1': true,
      });
      await _show(tester, const AppRoot(debugLegacyPlacementOnStart: true));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_nav_profile')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_academy_you_leaf_settings')));
      await tester.pumpAndSettle();
      if (state == 'delete_confirm') {
        final delete = find.byKey(const Key('act0_settings_delete_local_data'));
        await tester.ensureVisible(delete);
        await tester.tap(delete);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('act0_delete_data_confirm')),
          findsOneWidget,
        );
      }
      await _capture(tester, 'settings_$state');
    });
  }

  for (final resume in [false, true]) {
    final name = resume ? 'welcome_resume' : 'welcome_first_run';
    testWidgets(name, (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _show(
        tester,
        MaterialApp(
          home: Scaffold(
            body: Act0WelcomeShellV1(
              replayMode: resume,
              onClose: resume ? () {} : null,
              onCompleted: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _capture(tester, name);
    });
  }
}
