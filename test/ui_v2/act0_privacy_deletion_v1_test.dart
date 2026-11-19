import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_beta_metrics_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_local_data_deletion_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_reminder_v1.dart';
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
      expect(fresh.firstVisitUtc, afterErase);
      expect(fresh.returnedDay2, isFalse);
      expect(fresh.returnedDay7, isFalse);
      expect(fresh.answers, everyElement(isNull));
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
      await tester.pumpWidget(const AppRoot());
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
      await tester.pumpWidget(const AppRoot());
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
      await tester.pumpWidget(const AppRoot());
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('act0_shell_placement_intro_cta')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
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
    expect(Act0PracticeReminderV1.enabled.value, isFalse);
    expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
  });
}
