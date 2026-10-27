import 'dart:convert';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_settings_quiet_control_v1.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_cross_session_profile_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'act0_review_v4_test.dart' as reviewFixtures;

Future<void> mount(WidgetTester t, String mode) async {
  final f = reviewFixtures.reviewV4Fixture(
    mode == 'progressed' ? 'both' : mode,
  );
  if (mode == 'progressed') {
    final old = jsonDecode(
      File(
        'test/ui_v2/fixtures/s09_c_native_w1_complete_open_intent_prefs_v1.json',
      ).readAsStringSync(),
    );
    final p = jsonDecode(f['act0_shell_progress_v1'] as String);
    final prior = jsonDecode(old['act0_shell_progress_v1']);
    p['learningEvidenceHistory'] = prior['learningEvidenceHistory'];
    p['completedTaskIds'] = prior['completedTaskIds'];
    p['earnedXp'] = 30;
    f['act0_shell_progress_v1'] = jsonEncode(p);
  }
  final out = Directory('output/you_v23_20261028/fixtures')
    ..createSync(recursive: true);
  File('${out.path}/$mode.json').writeAsStringSync(jsonEncode(f));
  SharedPreferences.setMockInitialValues(f);
  t.view.physicalSize = const Size(393, 852);
  t.view.devicePixelRatio = 1;
  t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  addTearDown(t.view.resetPadding);
  await t.pumpWidget(
    const MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.profile,
        showPlacementOnStart: false,
      ),
    ),
  );
  await t.pumpAndSettle();
  expect(t.takeException(), isNull);
}

void main() {
  for (final mode in ['fresh', 'progressed', 'due', 'single', 'zero'])
    testWidgets('$mode source gateway, saved facts and native fixture export', (
      t,
    ) async {
      await mount(t, mode);
      final p = t.widget<Act0ProfileShellV1>(find.byType(Act0ProfileShellV1));
      expect(p.youDueCount, ['progressed', 'due'].contains(mode) ? 1 : 0);
      expect(p.youRepairCount, ['progressed', 'single'].contains(mode) ? 1 : 0);
      if (!kAct0YouV23Preview) return;
      expect(find.textContaining('Accuracy'), findsNothing);
      if (mode == 'progressed') {
        expect(p.profile.completedTaskCount, 6);
        expect(find.text('6 tasks completed'), findsOneWidget);
        expect(t.getBottomLeft(find.text('Your record')).dy, lessThan(740));
        expect(
          t.getBottomLeft(find.byKey(const Key('you_v23_learn'))).dy,
          lessThan(766),
        );
      }
      expect(
        find.byKey(const Key('you_v23_review')),
        p.youDueCount + p.youRepairCount > 0 ? findsOneWidget : findsNothing,
      );
      if (mode == 'fresh') {
        expect(find.text('Not earned yet'), findsOneWidget);
        expect(find.byKey(const Key('you_v23_streak')), findsNothing);
      }
      final key = Key(
        p.youDueCount + p.youRepairCount > 0
            ? 'you_v23_review'
            : 'you_v23_learn',
      );
      await t.ensureVisible(find.byKey(key));
      await t.pumpAndSettle();
      await t.tap(find.byKey(key));
      await t.pumpAndSettle();
      expect(find.byType(Act0ProfileShellV1), findsNothing);
      expect(
        p.youDueCount + p.youRepairCount > 0
            ? find.byKey(const Key('act0_shell_review_screen'))
            : find.byType(Act0LearnPathShellV1),
        findsOneWidget,
      );
    });
  for (var count = 1; count <= 3; count++)
    testWidgets(
      '$count earned moments retain exact ids without horizontal scroll',
      (t) async {
        t.view.physicalSize = const Size(393, 852);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        final list = List.generate(
          count,
          (i) => Act0AchievementMomentViewModelV1(
            seedId: [
              'first_correct_read_v1',
              'first_repair_note_v1',
              'first_session_complete_v1',
            ][i],
            label: [
              'First correct read',
              'Back to the spot',
              'First session complete',
            ][i],
          ),
        );
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Act0ProfileShellV1(
                profile: Act0ShellStateV1.sample.profile,
                achievementSeedConsumer: Act0AchievementSeedConsumerV1(
                  moments: list,
                ),
                onRetakePlacement: () {},
                onGoToLearn: () {},
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        if (!kAct0YouV23Preview) return;
        for (final m in list)
          expect(
            find.byKey(Key('act0_shell_profile_earned_moment_${m.seedId}')),
            findsOneWidget,
          );
        expect(t.takeException(), isNull);
      },
      skip: !kAct0YouV23Preview,
    );
  for (final banked in [0, 2])
    testWidgets('long name, scaled text and banked $banked preserve layout', (
      t,
    ) async {
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(1.3)),
            child: child!,
          ),
          home: Scaffold(
            body: Act0ProfileShellV1(
              profile: const Act0ProfileStateV1(
                playerName: 'A very long source-owned learner name',
                level: 'Level 2',
                xpLine: '30 / 200 XP',
                lessonsLine: '1 of 180 tasks complete',
                accuracyLine: '',
                consistencyActiveDays: 3,
                streakDays: 3,
                achievements: [],
              ),
              crossSessionProof: Act0CrossSessionProfileProofV1(
                totalBankedFixCount: banked,
                reinforcedFixCount: banked == 0 ? 0 : 1,
              ),
              onRetakePlacement: () {},
              onGoToLearn: () {},
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      if (!kAct0YouV23Preview) return;
      expect(find.text('3 days · Learning streak'), findsOneWidget);
      if (banked > 0)
        await t.scrollUntilVisible(
          find.byKey(const Key('you_v23_banked')),
          120,
        );
      expect(
        find.byKey(const Key('you_v23_banked')),
        banked == 0 ? findsNothing : findsOneWidget,
      );
      expect(
        find.byKey(const Key('you_v23_reinforced')),
        banked == 0 ? findsNothing : findsOneWidget,
      );
      await t.scrollUntilVisible(find.text('Learning details'), 120);
      await t.pumpAndSettle();
      await t.tap(find.text('Learning details'));
      await t.pumpAndSettle();
      await t.scrollUntilVisible(find.byKey(const Key('you_v23_tasks')), 150);
      expect(find.text('1 of 180 tasks complete'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  testWidgets('grouped details preserve source modal and Home actions', (
    t,
  ) async {
    await mount(t, 'progressed');
    if (!kAct0YouV23Preview) return;
    await t.scrollUntilVisible(find.text('Learning details'), 120);
    await t.tap(find.text('Learning details'));
    await t.pumpAndSettle();
    expect(find.text('6 of 367 tasks complete'), findsOneWidget);
    for (final label in [
      'Table sense',
      'View all skills',
      'View achievements',
      if (!kAct0SettingsQuietControlPreviewV1) 'Intro & placement',
    ]) {
      final target = find.text(label);
      await t.scrollUntilVisible(target, 100);
      await t.pumpAndSettle();
      await t.tap(target);
      await t.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      Navigator.of(t.element(find.byType(BottomSheet))).pop();
      await t.pumpAndSettle();
    }
    if (kAct0SettingsQuietControlPreviewV1) {
      await t.scrollUntilVisible(find.text('Settings'), 100);
      await t.pumpAndSettle();
      await t.tap(find.text('Settings'));
      await t.pumpAndSettle();
      expect(find.byType(Act0SettingsQuietControlV1), findsOneWidget);
      await t.tap(find.byKey(const Key('settings_back')));
      await t.pumpAndSettle();
    }
    await t.scrollUntilVisible(find.text('Open Home'), 100);
    await t.pumpAndSettle();
    await t.tap(find.text('Open Home'));
    await t.pumpAndSettle();
    expect(find.byType(Act0ProfileShellV1), findsNothing);
    expect(t.takeException(), isNull);
  });
  test('unknown due target does not count as routable', () {
    expect(
      act0YouV23TargetExists(
        Act0ShellStateV1.sample,
        'world_1',
        'missing',
        'missing',
      ),
      isFalse,
    );
  });
}
