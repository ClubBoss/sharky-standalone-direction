import 'dart:convert';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_welcome_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_placement_shell_v1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/services/app_settings_service.dart';
import 'package:poker_analyzer/ui/settings/privacy_terms.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_settings_quiet_control_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_profile_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/audio/ui_sound_v1.dart';
import 'package:poker_analyzer/ui_v2/visual/ui_haptics_v1.dart';
import 'act0_review_v4_test.dart' as fixtures;

Future<void> mount(WidgetTester t) async {
  final f = fixtures.reviewV4Fixture('both');
  final p = jsonDecode(f['act0_shell_progress_v1'] as String);
  p['earnedXp'] = 30;
  p['completedTaskIds'] = ['what_poker_is_theory', 'what_poker_is_find_hero'];
  f['act0_shell_progress_v1'] = jsonEncode(p);
  SharedPreferences.setMockInitialValues(f);
  await AppSettingsService.instance.load();
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
}

Future<void> open(WidgetTester t) async {
  await t.tap(find.byKey(const Key('you_settings')));
  await t.pumpAndSettle();
  expect(find.byType(Act0SettingsQuietControlV1), findsOneWidget);
  expect(t.takeException(), isNull);
}

Map<String, Object?> progress(SharedPreferences prefs) =>
    jsonDecode(prefs.getString('act0_shell_progress_v1')!)
        as Map<String, Object?>;

void main() {
  testWidgets(
    'You gear opens once; Back and reopen preserve the source profile',
    (t) async {
      await mount(t);
      final before = t
          .widget<Act0ProfileShellV1>(find.byType(Act0ProfileShellV1))
          .profile;
      await t.tap(find.byKey(const Key('you_settings')));
      await t.tap(find.byKey(const Key('you_settings')), warnIfMissed: false);
      await t.pumpAndSettle();
      expect(find.byType(Act0SettingsQuietControlV1), findsOneWidget);
      expect(find.text('Delete Data / Account'), findsNothing);
      expect(find.text('Contact support'), findsNothing);
      await t.tap(find.byKey(const Key('settings_back')));
      await t.pumpAndSettle();
      expect(find.byType(Act0SettingsQuietControlV1), findsNothing);
      expect(
        t
            .widget<Act0ProfileShellV1>(find.byType(Act0ProfileShellV1))
            .profile
            .xpLine,
        before.xpLine,
      );
      await open(t);
    },
    skip: !kAct0SettingsQuietControlPreviewV1 || !kAct0YouV23Preview,
  );

  testWidgets(
    'switches use persisted service and real cue gates after reload',
    (t) async {
      await mount(t);
      await open(t);
      var sounds = 0;
      var haptics = 0;
      UiSoundV1.overrideHandler((_) => sounds++);
      UiHapticsV1.setHandler(UiHapticEventV1.success, () async {
        haptics++;
      });
      addTearDown(UiSoundV1.resetHandler);
      addTearDown(UiHapticsV1.resetHandlers);
      await t.tap(find.byKey(const Key('settings_sound')));
      await t.tap(find.byKey(const Key('settings_haptics')));
      await t.pumpAndSettle();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('settings_sound_enabled'), false);
      expect(prefs.getBool('haptics_enabled'), false);
      await AppSettingsService.instance.load();
      UiSoundV1.fire(UiSoundEventV1.success);
      await UiHapticsV1.fire(UiHapticEventV1.success);
      expect(sounds, 0);
      expect(haptics, 0);
      await t.tap(find.byKey(const Key('settings_back')));
      await t.pumpAndSettle();
      await open(t);
      expect(
        t.widget<Switch>(find.byKey(const Key('settings_sound'))).value,
        false,
      );
      expect(
        t.widget<Switch>(find.byKey(const Key('settings_haptics'))).value,
        false,
      );
      await t.tap(find.byKey(const Key('settings_sound')));
      await t.tap(find.byKey(const Key('settings_haptics')));
      await t.pumpAndSettle();
      await AppSettingsService.instance.load();
      UiSoundV1.fire(UiSoundEventV1.success);
      await UiHapticsV1.fire(UiHapticEventV1.success);
      expect(sounds, 1);
      expect(haptics, 1);
    },
    skip: !kAct0SettingsQuietControlPreviewV1 || !kAct0YouV23Preview,
  );

  for (final privacy in [true, false]) {
    testWidgets(
      '${privacy ? 'Privacy' : 'Terms'} scrolls through complete selectable text and returns to Settings',
      (t) async {
        await mount(t);
        await open(t);
        final label = privacy ? 'Privacy Policy' : 'Terms of Use';
        final list = find.byKey(const Key('settings_scroll'));
        await t.scrollUntilVisible(
          find.text(label),
          120,
          scrollable: find.descendant(
            of: list,
            matching: find.byType(Scrollable),
          ),
        );
        await Scrollable.ensureVisible(
          t.element(find.text(label)),
          alignment: 0.5,
        );
        await t.pumpAndSettle();
        await t.tap(find.text(label));
        await t.pumpAndSettle();
        expect(
          find.byKey(Key(privacy ? 'privacy_screen_v1' : 'terms_screen_v1')),
          findsOneWidget,
        );
        expect(find.byType(SelectionArea), findsOneWidget);
        final bottom = find.text(
          privacy
              ? 'Publication and changes'
              : 'Rights, contact and public release',
        );
        await t.scrollUntilVisible(bottom, 500);
        await t.pumpAndSettle();
        expect(
          t.getRect(bottom).overlaps(const Rect.fromLTWH(0, 59, 393, 759)),
          true,
        );
        expect(find.textContaining('[VERIFY]'), findsNothing);
        await t.pageBack();
        await t.pumpAndSettle();
        expect(find.byType(Act0SettingsQuietControlV1), findsOneWidget);
        expect(t.takeException(), isNull);
      },
      skip: !kAct0SettingsQuietControlPreviewV1 || !kAct0YouV23Preview,
    );
  }

  for (final welcome in [true, false]) {
    testWidgets(
      '${welcome ? 'Welcome' : 'Placement'} uses real shell callback with XP and completed IDs intact',
      (t) async {
        await mount(t);
        final prefs = await SharedPreferences.getInstance();
        final dynamic owner = t.state(find.byType(Act0ShellPreviewScreenV1));
        owner.debugPersistProgressV1();
        await t.pumpAndSettle();
        final before = progress(prefs);
        await open(t);
        final label = welcome ? 'Replay Welcome' : 'Retake Placement';
        await t.ensureVisible(find.text(label));
        await Scrollable.ensureVisible(
          t.element(find.text(label)),
          alignment: 0.5,
        );
        await t.pumpAndSettle();
        await t.tap(find.text(label));
        await t.pumpAndSettle();
        expect(find.byType(Act0SettingsQuietControlV1), findsNothing);
        expect(
          welcome
              ? find.byType(Act0WelcomeShellV1)
              : find.byType(Act0PlacementShellV1),
          findsOneWidget,
        );
        final dynamic shell = t.state(find.byType(Act0ShellPreviewScreenV1));
        shell.debugPersistProgressV1();
        await t.pumpAndSettle();
        final after = progress(prefs);
        for (final key in [
          'earnedXp',
          'completedTaskIds',
          'completedLessonIds',
          'openRepairIntents',
          'reviewMistakeHistory',
        ]) {
          expect(
            after[key],
            key.endsWith('Ids')
                ? unorderedEquals(before[key] as List)
                : before[key],
            reason: key,
          );
        }
        if (welcome) {
          await t.tap(find.byKey(const Key('act0_shell_welcome_close')));
          await t.pumpAndSettle();
          expect(find.byType(Act0ProfileShellV1), findsOneWidget);
        }
        expect(t.takeException(), isNull);
      },
      skip: !kAct0SettingsQuietControlPreviewV1 || !kAct0YouV23Preview,
    );
  }

  testWidgets(
    'default OFF keeps existing You tools',
    (t) async {
      await mount(t);
      await t.tap(find.byKey(const Key('you_settings')));
      await t.pumpAndSettle();
      expect(find.byType(Act0SettingsQuietControlV1), findsNothing);
      expect(find.byType(BottomSheet), findsOneWidget);
    },
    skip: kAct0SettingsQuietControlPreviewV1 || !kAct0YouV23Preview,
  );
}
