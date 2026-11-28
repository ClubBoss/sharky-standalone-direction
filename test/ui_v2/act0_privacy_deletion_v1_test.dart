import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_settings_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_beta_metrics_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_growth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_local_data_deletion_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_reminder_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w1_rules_check_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _Paths extends PathProviderPlatform {
  _Paths(this.path);
  final String path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
}

class _Disk extends SharedPreferencesStorePlatform {
  _Disk(this.values);
  final Map<String, Object> values;
  int? cutAt;
  int removals = 0;
  bool lie = false;
  @override
  Future<Map<String, Object>> getAll() async => Map.of(values);
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    if (++removals == cutAt) throw StateError('process cut / denied write');
    if (!lie) values.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async => throw StateError('unordered clear forbidden');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late PathProviderPlatform originalPaths;
  late SharedPreferencesStorePlatform originalPrefs;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('sharky-privacy-test-');
    originalPaths = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(directory.path);
    SharedPreferences.setMockInitialValues({});
    originalPrefs = SharedPreferencesStorePlatform.instance;
  });
  tearDown(() async {
    // Complete intentionally interrupted erasures before the next fixture.
    SharedPreferences.setMockInitialValues({});
    await Act0LocalDataDeletionV1.erase();
    PathProviderPlatform.instance = originalPaths;
    SharedPreferencesStorePlatform.instance = originalPrefs;
    await directory.delete(recursive: true);
  });

  test(
    'erase removes checkpoints, damaged copy, old preferences and trace; old writer stays fenced',
    () async {
      final old = Act0ProgressStoreV1(
        key: 'act0_shell_progress_v1',
        isValidPayload: (_) => true,
      );
      expect(await old.save('{"xp":20}'), isTrue);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'act0_shell_progress_v1_damaged_copy_v1',
        'private raw copy',
      );
      await prefs.setString('old_learning_history', 'private old history');
      await prefs.setBool('haptics_enabled', false);
      final trace = File('${directory.path}/act0_hnp_trace_v1.jsonl');
      await trace.writeAsString('private diagnostic history');
      await Act0LocalDataDeletionV1.erase();
      await prefs.reload();
      expect(prefs.getKeys(), isEmpty);
      expect(await trace.exists(), isFalse);
      expect(await old.save('{"xp":999}'), isFalse);
      final fresh = Act0ProgressStoreV1(
        key: old.key,
        isValidPayload: (_) => true,
      );
      expect(await fresh.load(), isNull);
      expect(await fresh.save('{"xp":0}'), isTrue);
    },
  );

  test(
    'beta returns and survey are erased and queued writes stay fenced',
    () async {
      final first = DateTime.utc(2026, 11, 19, 12);
      await Act0BetaMetricsStoreV1.recordVisit(first);
      await Act0BetaMetricsStoreV1.setAnswer(0, Act0BetaSurveyAnswerV1.yes);
      await Act0BetaMetricsStoreV1.recordLesson(first, 'what_poker_is');
      await Act0BetaMetricsStoreV1.recordPracticeStep(first);
      await Act0BetaMetricsStoreV1.recordRulesCheckStarted();
      final write = Act0BetaMetricsStoreV1.recordVisit(
        first.add(const Duration(days: 6)),
      );
      Act0LocalDataDeletionV1.blockOldWriters();
      await Act0BetaMetricsStoreV1.flush();
      await write;
      await Act0LocalDataDeletionV1.erase();
      expect(await Act0BetaMetricsStoreV1.read(), isNull);

      final afterErase = first.add(const Duration(days: 8));
      await Act0BetaMetricsStoreV1.recordVisit(afterErase);
      final fresh = (await Act0BetaMetricsStoreV1.read())!;
      expect(fresh.lessonDays, isEmpty);
      expect(fresh.practiceSteps, everyElement(0));
      expect(fresh.rulesCheckStarted, isFalse);
      expect(fresh.firstVisitUtc, afterErase);
      expect(fresh.returnedDay2, isFalse);
      expect(fresh.returnedDay7, isFalse);
      expect(fresh.answers, everyElement(isNull));
    },
  );

  test(
    'an in-flight StoreKit callback cannot restore a preference after deletion',
    () async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final nativeStarted = Completer<void>();
      final nativeResult = Completer<bool>();
      messenger.setMockMethodCallHandler(act0GrowthChannelV1, (call) async {
        expect(call.method, 'requestReview');
        nativeStarted.complete();
        return nativeResult.future;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(act0GrowthChannelV1, null),
      );

      final request = Act0StoreReviewV1().requestAfterMilestone(
        now: DateTime.utc(2026, 11, 28),
        canPresent: () => true,
      );
      await nativeStarted.future;
      await Act0LocalDataDeletionV1.erase();
      nativeResult.complete(true);
      await request;

      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      expect(prefs.getKeys(), isEmpty);
    },
  );

  for (var cut = 1; cut <= 5; cut++) {
    test(
      'interrupted deletion at removal $cut resumes before exposing old history',
      () async {
        final disk = _Disk({
          'flutter.act0_shell_progress_v1': 'old data',
          'flutter.act0_shell_progress_v1_backup': 'old twin',
          'flutter.act0_shell_progress_v1_damaged_copy_v1': 'old archive',
          'flutter.haptics_enabled': false,
        })..cutAt = cut;
        SharedPreferencesStorePlatform.instance = disk;
        await expectLater(Act0LocalDataDeletionV1.erase(), throwsStateError);
        expect(
          disk.values['flutter.${Act0LocalDataDeletionV1.pendingKey}'],
          true,
        );
        expect(Act0LocalDataDeletionV1.blocked, isTrue);
        disk.cutAt = null;
        await Act0LocalDataDeletionV1.resumePending();
        expect(disk.values, isEmpty);
        expect(Act0LocalDataDeletionV1.blocked, isFalse);
      },
    );
  }

  test(
    'acknowledged but ineffective removal is not reported as deletion',
    () async {
      final disk = _Disk({'flutter.private_history': 'secret'})..lie = true;
      SharedPreferencesStorePlatform.instance = disk;
      await expectLater(Act0LocalDataDeletionV1.erase(), throwsStateError);
      expect(Act0LocalDataDeletionV1.blocked, isTrue);
      expect(disk.values['flutter.private_history'], 'secret');
      disk.lie = false;
      await Act0LocalDataDeletionV1.resumePending();
      expect(disk.values, isEmpty);
    },
  );

  testWidgets(
    'pending erase at boot blocks the learner route until Retry finishes',
    (tester) async {
      final disk = _Disk({
        'flutter.${Act0LocalDataDeletionV1.pendingKey}': true,
        'flutter.onboardingCompleted': true,
        'flutter.private_old_history': 'old data',
      })..cutAt = 1;
      SharedPreferencesStorePlatform.instance = disk;
      await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
      await tester.pumpAndSettle();
      expect(find.text('Data deletion unfinished'), findsOneWidget);
      expect(find.text('You'), findsNothing);
      expect(disk.values['flutter.private_old_history'], 'old data');
      disk.cutAt = null;
      await tester.tap(find.text('Retry deletion'));
      for (var i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 20));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        if (find
            .byKey(const Key('act0_shell_placement_intro_cta'))
            .evaluate()
            .isNotEmpty)
          break;
      }
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_placement_intro_cta')),
        findsOneWidget,
      );
      expect(disk.values['flutter.private_old_history'], isNull);
      expect(
        disk.values['flutter.${Act0LocalDataDeletionV1.pendingKey}'],
        isNull,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Learn owns the learner rules check and returns on back', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({'onboardingCompleted': true});

    await tester.pumpWidget(const AppRoot());
    await tester.pumpAndSettle();
    await tester.tap(find.text('You').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_academy_you_leaf_settings')));
    await tester.pumpAndSettle();

    final settings = tester.widget<Act0AcademySettingsLeafV1>(
      find.byType(Act0AcademySettingsLeafV1),
    );
    expect(settings.input.onReplayWelcome, isNull);
    expect(settings.input.onRetakePlacement, isNull);
    await tester.tap(find.byKey(const Key('act0_academy_settings_leaf_back')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_nav_learn')));
    await tester.pumpAndSettle();
    final rulesCheck = find.byKey(const Key('act0_shell_w1_rules_map'));
    expect(find.text('Check W1 rules'), findsOneWidget);
    expect(
      find.text('Pass to unlock W2 and skip the W1 lessons.'),
      findsOneWidget,
    );
    await tester.ensureVisible(rulesCheck);
    await tester.pumpAndSettle();
    expect(rulesCheck.hitTestable(), findsOneWidget);
    await tester.tap(rulesCheck);
    await tester.pumpAndSettle();
    expect(find.text(act0W1RulesQuestionsV1.first.question), findsWidgets);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(rulesCheck, findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_placement_intro_cta')),
      findsNothing,
    );
  });

  testWidgets(
    'Settings cancellation preserves data; confirmed erase starts fresh and cannot resurrect on remount',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({
        'onboardingCompleted': true,
        'act0_welcome_completed_v1': true,
        'private_old_history': 'old data',
        'haptics_enabled': false,
      });
      await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('You').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_academy_you_leaf_settings')));
      await tester.pumpAndSettle();
      final delete = find.byKey(const Key('act0_settings_delete_local_data'));
      await tester.scrollUntilVisible(
        delete,
        200,
        scrollable: find.descendant(
          of: find.byKey(const Key('act0_academy_settings_leaf_scroll')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      expect(delete.hitTestable(), findsOneWidget);
      await tester.tap(delete);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_delete_data_cancel')));
      await tester.pumpAndSettle();
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      expect(prefs.getString('private_old_history'), 'old data');
      await tester.tap(find.byKey(const Key('act0_academy_you_leaf_settings')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        delete,
        200,
        scrollable: find.descendant(
          of: find.byKey(const Key('act0_academy_settings_leaf_scroll')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      expect(delete.hitTestable(), findsOneWidget);
      await tester.tap(delete);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_delete_data_confirm')));
      for (var i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 20));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        if (find
            .byKey(const Key('act0_shell_placement_intro_cta'))
            .evaluate()
            .isNotEmpty)
          break;
      }
      await tester.pumpAndSettle();
      expect(find.text('Data deletion unfinished'), findsNothing);
      await prefs.reload();
      expect(prefs.getString('private_old_history'), isNull);
      expect(prefs.getBool('haptics_enabled'), isNull);
      expect(prefs.getBool('act0_welcome_completed_v1'), isNull);
      expect(
        find.byKey(const Key('act0_shell_placement_intro_cta')),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_placement_intro_cta')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Settings refreshes the iOS denial banner when the app resumes',
    (tester) async {
      const channel = MethodChannel('com.clubboss.sharky/practice_reminder_v1');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      var denied = false;
      var promptCount = 0;
      messenger.setMockMethodCallHandler(channel, (call) async {
        switch (call.method) {
          case 'permissionDenied':
            return denied;
          case 'setEnabled':
            promptCount++;
            denied = true;
            return false;
          default:
            return false;
        }
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      SharedPreferences.setMockInitialValues({
        'onboardingCompleted': true,
        'act0_welcome_completed_v1': true,
      });
      await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_nav_profile')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_academy_you_leaf_settings')));
      await tester.pumpAndSettle();

      final reminder = find.byKey(
        const Key('act0_academy_settings_practice_reminder'),
      );
      final banner = find.text(
        'Allow Sharky Poker notifications in iPhone Settings.',
      );
      expect(banner, findsNothing);
      expect(promptCount, 0);
      await tester.tap(reminder);
      await tester.pumpAndSettle();
      expect(promptCount, 1);
      expect(banner, findsOneWidget);
      expect(tester.widget<Switch>(reminder).value, isFalse);

      denied = false;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(banner, findsNothing);
      expect(promptCount, 1);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'reminder time is editable while off and only the toggle requests opt-in',
    (tester) async {
      const channel = MethodChannel('com.clubboss.sharky/practice_reminder_v1');
      final messenger = tester.binding.defaultBinaryMessenger;
      final calls = <MethodCall>[];
      var enabled = false;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        if (call.method == 'getTime') return [9, 15];
        if (call.method == 'permissionDenied') return false;
        if (call.method == 'setEnabled') {
          enabled = call.arguments['enabled'] as bool;
        }
        return enabled;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      SharedPreferences.setMockInitialValues({
        'onboardingCompleted': true,
        'act0_welcome_completed_v1': true,
      });
      await tester.pumpWidget(const AppRoot(debugLegacyPlacementOnStart: true));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_nav_profile')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_academy_you_leaf_settings')));
      await tester.pumpAndSettle();
      final reminder = find.byKey(
        const Key('act0_academy_settings_practice_reminder'),
      );
      expect(tester.widget<Switch>(reminder).value, isFalse);
      expect(calls.where((call) => call.method == 'setEnabled'), isEmpty);
      final time = find.byKey(const Key('act0_practice_reminder_time'));
      await tester.tap(time);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TimePickerDialog>(find.byType(TimePickerDialog))
            .initialTime,
        const TimeOfDay(hour: 9, minute: 15),
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      final saved = calls.singleWhere((call) => call.method == 'setTime');
      expect(saved.arguments['hour'], 9);
      expect(saved.arguments['minute'], 15);
      expect(calls.where((call) => call.method == 'setEnabled'), isEmpty);
      expect(tester.widget<Switch>(reminder).value, isFalse);
      await tester.tap(reminder);
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(reminder).value, isTrue);
      await tester.tap(reminder);
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(reminder).value, isFalse);
      expect(
        calls
            .where((call) => call.method == 'setEnabled')
            .map((call) => call.arguments['enabled']),
        [true, false],
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  test('reminders need explicit opt-in and deletion disables them', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    const channel = MethodChannel('com.clubboss.sharky/practice_reminder_v1');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];
    var optIn = false;
    var granted = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'setEnabled') {
        optIn = call.arguments['enabled'] == true && granted;
      }
      if (!granted) optIn = false;
      return optIn;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    SharedPreferences.setMockInitialValues({'local_test_setting': true});

    expect(
      await Act0PracticeReminderV1.sync(Act0PracticeReminderScheduleV1.none),
      isFalse,
    );
    expect(calls.single.method, 'sync');
    expect(calls.single.arguments['schedule'], 'none');
    expect(await Act0PracticeReminderV1.setEnabled(true), isFalse);
    granted = true;
    expect(await Act0PracticeReminderV1.setEnabled(true), isTrue);
    expect(
      await Act0PracticeReminderV1.sync(
        Act0PracticeReminderScheduleV1.tomorrowEvening,
      ),
      isTrue,
    );
    expect(calls.last.arguments['schedule'], 'tomorrowEvening');

    granted = false; // iOS settings revoked permission while the app was away.
    expect(
      await Act0PracticeReminderV1.sync(
        Act0PracticeReminderScheduleV1.nextEvening,
      ),
      isFalse,
    );
    granted = true;
    await Act0PracticeReminderV1.setEnabled(true);
    await Act0LocalDataDeletionV1.erase();
    expect(calls.last.method, 'setEnabled');
    expect(calls.last.arguments['enabled'], isFalse);
    expect(calls.last.arguments['reset'], isTrue);
    expect(Act0PracticeReminderV1.enabled.value, isFalse);
    expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
  });
}
