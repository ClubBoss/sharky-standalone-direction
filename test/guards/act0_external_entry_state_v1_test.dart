import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_accessibility_semantics_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_growth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_replay_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Extends the production AppRoot harness from act0_e35_external_entry_v1_test.dart.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final ios = TargetPlatformVariant.only(TargetPlatform.iOS);
  const learnLink = 'sharky://open/v1/learn';
  const homeLink = 'sharky://open/v1/home';
  const reminderChannel = MethodChannel(
    'com.clubboss.sharky/practice_reminder_v1',
  );
  int takes = 0;

  setUp(() {
    takes = 0;
    SharedPreferences.setMockInitialValues({});
    messenger.setMockMethodCallHandler(reminderChannel, (_) async => false);
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(reminderChannel, null);
    messenger.setMockMethodCallHandler(act0GrowthChannelV1, null);
  });

  Future<void> mount(
    WidgetTester tester, {
    String? pending,
    bool legacyPlacement = false,
  }) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    messenger.setMockMethodCallHandler(act0GrowthChannelV1, (call) async {
      expect(call.method, 'takeLink');
      takes++;
      final link = pending;
      pending = null;
      return link;
    });
    // AppRoot uses the production InkRipple theme and the real entry gate.
    await tester.pumpWidget(
      AppRoot(debugLegacyPlacementOnStart: legacyPlacement),
    );
    await tester.pumpAndSettle();
    expect(takes, 1);
  }

  Future<void> openLink(WidgetTester tester, [String link = learnLink]) async {
    await messenger.handlePlatformMessage(
      act0GrowthChannelV1.name,
      const StandardMethodCodec().encodeMethodCall(
        MethodCall('openLink', link),
      ),
      null,
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    expect(finder.hitTestable(), findsOneWidget);
    await tester.tap(finder.hitTestable());
    await tester.pumpAndSettle();
  }

  final basics = find.byKey(const Key('act0_shell_w1_start_basics'));
  final back = find.byKey(const Key('act0_shell_runner_back'));
  final runnerFinder = find.byType(Act0LessonRunnerShellV1);
  Act0LessonRunnerShellV1 runner(WidgetTester tester) =>
      tester.widget<Act0LessonRunnerShellV1>(runnerFinder);
  String selectedTab(WidgetTester tester) => tester
      .widgetList<Act0SemanticActionV1>(
        find.descendant(
          of: find.byKey(const Key('act0_shell_bottom_nav')),
          matching: find.byType(Act0SemanticActionV1),
        ),
      )
      .singleWhere((tab) => tab.selected == true)
      .label;

  Future<void> closeRunnerAndExpectTab(
    WidgetTester tester,
    String tab, {
    Map<String, dynamic>? saved,
    Act0LessonRunnerShellV1? before,
  }) async {
    await tap(tester, back);
    expect(selectedTab(tester), tab);
    expect(takes, 1, reason: 'The queued link must not be fetched again.');
    if (saved != null && before != null) {
      final after = await _savedProgress(tester);
      expect(
        _learnerTruth(after, includeFocus: false),
        _learnerTruth(saved, includeFocus: false),
      );
      expect(
        after['lessonResume'],
        containsPair('taskId', before.selectedTaskId),
      );
      expect(
        after['lessonResume'],
        containsPair('selectedOptionId', before.runner.selectedOptionId),
      );
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  Future<Act0LessonRunnerShellV1> answerFirstTask(WidgetTester tester) async {
    await tap(tester, basics);
    await tester.pump(const Duration(seconds: 1));
    await tap(tester, find.text('Next'));
    await tap(tester, find.text('The shared cards in the middle'));
    final before = runner(tester);
    expect(before.runner.selectedOptionId, isNotNull);
    expect(before.runner.phase, Act0LessonPhaseV1.review);
    return before;
  }

  void expectSameAnswer(WidgetTester tester, Act0LessonRunnerShellV1 before) {
    final after = runner(tester);
    expect(after.selectedWorldId, before.selectedWorldId);
    expect(after.selectedLessonId, before.selectedLessonId);
    expect(after.selectedTaskId, before.selectedTaskId);
    expect(after.runner.phase, before.runner.phase);
    expect(after.runner.teachingStepIndex, before.runner.teachingStepIndex);
    expect(after.runner.selectedOptionId, before.runner.selectedOptionId);
    expect(after.runner.reviewQuality, before.runner.reviewQuality);
    expect(find.text('Try same clue'), findsOneWidget);
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  for (final (link, destination) in [
    (learnLink, 'Learn'),
    (homeLink, 'Home'),
  ]) {
    testWidgets('E35 cold $destination link waits for first-start gate', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await mount(tester, pending: link);
        expect(basics, findsOneWidget);
        expect(runnerFinder, findsNothing);
        expect(
          find.byKey(const Key('act0_shell_bottom_nav')).hitTestable(),
          findsNothing,
        );
        await tap(tester, basics);
        expect(runnerFinder, findsOneWidget);
        await closeRunnerAndExpectTab(tester, destination);
      } finally {
        semantics.dispose();
      }
    }, variant: ios);

    testWidgets('E35 warm $destination link preserves answer and checkpoint', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await mount(tester);
        final before = await answerFirstTask(tester);
        final saved = await _savedProgress(tester);
        await openLink(tester, link);
        expectSameAnswer(tester, before);
        expect(
          _learnerTruth(await _savedProgress(tester)),
          _learnerTruth(saved),
        );
        await closeRunnerAndExpectTab(
          tester,
          destination,
          saved: saved,
          before: before,
        );
      } finally {
        semantics.dispose();
      }
    }, variant: ios);
  }

  testWidgets('E35 warm link during placement is not dropped', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await mount(tester, legacyPlacement: true);
      final placement = find.byKey(const Key('act0_shell_placement_intro_cta'));
      expect(placement, findsOneWidget);
      await openLink(tester);
      expect(placement, findsOneWidget);
      expect(runnerFinder, findsNothing);
      await tap(
        tester,
        find.byKey(const Key('act0_shell_placement_skip_intro')),
      );
      expect(placement, findsNothing);
      expect(selectedTab(tester), 'Learn');
      expect(takes, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  }, variant: ios);

  // No notification-tap method is registered on main: the only entry is
  // ordinary app launch/resume. Simulate that boundary, not an invented event.
  testWidgets('E35 cold ordinary launch keeps notification-open at the gate', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await mount(tester);
      expect(basics, findsOneWidget);
      expect(runnerFinder, findsNothing);
      expect(
        find.byKey(const Key('act0_shell_bottom_nav')).hitTestable(),
        findsNothing,
      );
      await unmount(tester);
    } finally {
      semantics.dispose();
    }
  }, variant: ios);

  testWidgets('E35 warm ordinary resume preserves the active answer', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await mount(tester);
      final before = await answerFirstTask(tester);
      final saved = await _savedProgress(tester);
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.hidden,
        AppLifecycleState.inactive,
        AppLifecycleState.resumed,
      ]) {
        tester.binding.handleAppLifecycleStateChanged(state);
      }
      await tester.pumpAndSettle();
      expectSameAnswer(tester, before);
      final after = await _savedProgress(tester);
      expect(_learnerTruth(after), _learnerTruth(saved));
      expect(
        after['lessonResume'],
        containsPair('taskId', before.selectedTaskId),
      );
      await unmount(tester);
    } finally {
      semantics.dispose();
    }
  }, variant: ios);

  final importButton = find.text('Import own hand');
  final ownHands = find.byKey(const Key('act0_review_open_own_hands'));
  final review = find.byKey(const Key('act0_shell_nav_review'));

  void expectImportUnavailable() {
    expect(importButton.hitTestable(), findsNothing);
    expect(ownHands.hitTestable(), findsNothing);
    expect(find.byType(Act0AttemptArchiveScreenV1), findsNothing);
    expect(find.byType(Act0AttemptReplayScreenV1), findsNothing);
  }

  testWidgets('E35 cold hand-history input cannot bypass first-start gate', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await mount(tester);
      expect(basics, findsOneWidget);
      expect(review.hitTestable(), findsNothing);
      expectImportUnavailable();
      await unmount(tester);
    } finally {
      semantics.dispose();
    }
  }, variant: ios);

  testWidgets(
    'E35 warm hand-history entry waits for explicit exit and retains learner progress',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await mount(tester);
        final before = await answerFirstTask(tester);
        expect(review.hitTestable(), findsNothing);
        expectImportUnavailable();
        expectSameAnswer(tester, before);
        // Positive control: the import is only reachable through Review after
        // exiting the runner; it must not overwrite the attempt archive/progress.
        await tap(tester, back);
        await tap(tester, review);
        if (ownHands.evaluate().isEmpty) {
          await tester.scrollUntilVisible(
            ownHands,
            150,
            scrollable: find.byType(Scrollable).first,
          );
        }
        await tester.ensureVisible(ownHands);
        await tap(tester, ownHands);
        await tap(tester, importButton);
        final saved = await _savedProgress(tester);
        final fixture = File(
          'test/fixtures/hand_history/pokerstars_nlhe_usd_fold.txt',
        ).readAsStringSync();
        await tester.enterText(find.byType(TextField), fixture);
        await tap(tester, find.text('Import hand'));
        expect(find.byType(Act0AttemptReplayScreenV1), findsOneWidget);
        final after = await _savedProgress(tester);
        expect(_learnerTruth(after), _learnerTruth(saved));
        expect(after['lessonResume'], saved['lessonResume']);
        final oldArchive = saved['attemptArchive'] as Map;
        final newArchive = after['attemptArchive'] as Map;
        expect(oldArchive['entries'], isA<List>());
        expect(newArchive['entries'], oldArchive['entries']);
        expect(newArchive['importedHands'], hasLength(1));
        await unmount(tester);
      } finally {
        semantics.dispose();
      }
    },
    variant: ios,
  );

  final shells = find.byType(Act0ShellPreviewScreenV1, skipOffstage: false);

  testWidgets('E35 cold platform named route keeps one gated learner shell', (
    tester,
  ) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/home';
    addTearDown(
      tester.binding.platformDispatcher.clearDefaultRouteNameTestValue,
    );
    await mount(tester);
    expect(shells, findsOneWidget);
    expect(basics, findsOneWidget);
    await unmount(tester);
  }, variant: ios);

  testWidgets(
    'E35 warm platform named route preserves active runner and learner truth',
    (tester) async {
      await mount(tester);
      final before = await answerFirstTask(tester);
      final saved = await _savedProgress(tester);
      final state = tester.state(shells);
      await tester.binding.handlePushRoute('/home');
      await tester.pumpAndSettle();
      expect(shells, findsOneWidget);
      expect(tester.state(shells), same(state));
      expectSameAnswer(tester, before);
      expect(_learnerTruth(await _savedProgress(tester)), _learnerTruth(saved));
      await unmount(tester);
    },
    variant: ios,
  );

  test('E35 external ingress inventory ratchet', _checkExternalEntryInventory);
  test('E35 detector recognizes new handlers in old and new files', () {
    const path = 'lib/ui_v2/act0_shell/act0_shell_preview_growth_v1.dart';
    const registration = 'channel.setMethodCallHandler(handleIncoming);';
    final existing = _entrySignatures(path, registration);
    expect(existing, hasLength(1));
    expect(
      _entrySignatures(path, '$registration\n$registration'),
      hasLength(2),
    );
    expect(
      _entrySignatures(
        'lib/new_entry.dart',
        'links.uriLinkStream.listen(open);',
      ),
      hasLength(1),
    );
    expect(
      _entrySignatures(
        'ios/Runner/AppDelegate.swift',
        'case "newNotificationTap":',
      ),
      hasLength(1),
    );
    expect(
      _entrySignatures(
        'android/app/src/main/AndroidManifest.xml',
        '<action android:name="android.intent.action.SEND"/>',
      ),
      hasLength(1),
    );
  });
}

const _progressKey = 'act0_shell_progress_v1';

// Same shared queue/production checkpoint boundary as MAIN01 (no debug API).
Future<Map<String, dynamic>> _savedProgress(WidgetTester tester) async {
  await tester.pumpAndSettle();
  final payload = await tester.runAsync(() async {
    await Act0ProgressStoreV1(
      key: _progressKey,
      isValidPayload: (_) => false,
    ).flush().timeout(const Duration(seconds: 2));
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    final checkpoint = preferences.getString('${_progressKey}_recovery');
    expect(checkpoint, isNotNull);
    expect(preferences.getString('${_progressKey}_backup'), checkpoint);
    expect(preferences.getString('${_progressKey}_head'), checkpoint);
    final envelope = jsonDecode(checkpoint!) as Map<String, dynamic>;
    return jsonDecode(envelope['payload'] as String) as Map<String, dynamic>;
  });
  return payload!;
}

Map<String, Object?> _learnerTruth(
  Map<String, dynamic> payload, {
  bool includeFocus = true,
}) => {
  for (final field in [
    if (includeFocus) ...[
      'selectedWorldId',
      'selectedLessonId',
      'selectedTaskId',
    ],
    'earnedXp',
    'completedTaskIds',
    'completedLessonIds',
    'skippedTaskIds',
    'learningEvidenceHistory',
    'learningEvidenceLineage',
    'openRepairIntents',
    'reviewMistakeHistory',
    'reviewResolutionReceipts',
    'repairOutcomeProjection',
  ])
    field: payload[field],
};

// A deliberately bounded ingress-surface census, not a Dart naming lint. New
// registrations in an existing file also change the multiset (no file allowlist
// loophole). Review every candidate, including those established as outbound.
final _entryMarker = RegExp(
  r'\b(?:MethodChannel|EventChannel|BasicMessageChannel|setMethodCallHandler|'
  r'setMessageHandler|receiveBroadcastStream|setMockMethodCallHandler|'
  r'AppLifecycleListener|WidgetsBindingObserver|didChangeAppLifecycleState|'
  r'didPushRoute(?:Information)?|onGenerate(?:Initial)?Routes?|initialRoute|'
  r'AppLinks|appLinks|uriLinkStream|linkStream|getInitial(?:Link|Uri|Message)|'
  r'onLink|onLinkReceived|onIncomingLink|onDeepLink|onAppLink|handleDeepLink|takeLink|'
  r'onNotificationTap|onNotificationOpenedApp|onMessageOpenedApp|onDidReceiveNotificationResponse|'
  r'onSelectNotification|getNotificationAppLaunchDetails|'
  r'ReceiveSharingIntent|getInitialMedia|getMediaStream|onShareReceived|onNewIntent|'
  r'didReceiveRemoteNotification|didReceiveLocalNotification|'
  r'FilePicker|pickFiles|onDrop|onDragDone|onOpenFile|'
  r'FlutterMethodChannel|FlutterEventChannel|FlutterBasicMessageChannel|'
  r'didFinishLaunchingWithOptions|launchOptions|openURL|openURLContexts|'
  r'continueUserActivity|userActivity|didReceiveNotificationResponse|'
  r'UNNotificationResponse|onActivityResult|onReceive|'
  r'CFBundleURL(?:Types|Schemes|Name)|NSExtension|associated-domains|'
  r'importPokerStars|importHandHistory|importGGPoker|onOwnHandsChanged|onOpenOwnHands|'
  r'_maybeHandleDeepLink|DEEPLINK_TARGET)\b|'
  r'\bUri\.base\b|\bClipboard\.getData\b|\bcall\.method\s*==|'
  r'\b(?:onResume|onHide|onPause):|\bonPressed:\s*_import\b|'
  r'name:\s*"com\.clubboss\.|'
  r'\binvokeMethod\s*\(\s*"|\bopen\s+url\s*:\s*URL|'
  r'<intent-filter\b|android\.intent\.action\.(?:VIEW|SEND(?:_MULTIPLE)?|MAIN)|'
  r'android\.intent\.category\.BROWSABLE|android:scheme=|'
  r'\b(?:app_links|uni_links|firebase_messaging|receive_sharing_intent|'
  r'flutter_local_notifications|file_picker|share_plus):',
);

List<String> _entrySignatures(String path, String source) => [
  for (final line in const LineSplitter().convert(source))
    if (!line.trimLeft().startsWith('//') &&
        !line.trimLeft().startsWith('*') &&
        !line.trimLeft().startsWith('<!--') &&
        (_entryMarker.hasMatch(line) ||
            (path.endsWith('AppDelegate.swift') &&
                RegExp(r'\bcase\s+"[^"]+"\s*:').hasMatch(line))))
      '$path | ${line.trim().replaceAll(RegExp(r'\s+'), ' ')}',
];

List<String> _externalEntrySignatures() {
  const shell = 'lib/ui_v2/act0_shell';
  final dartFiles = <String>{
    'lib/main.dart',
    'lib/ui_v2/app_root.dart',
    for (final file in Directory(shell).listSync(recursive: true))
      if (file is File && file.path.endsWith('.dart')) file.path,
  };
  // Include current direct project-owned import/export seams, even if a new
  // handler is factored outside act0_shell. Do not crawl dormant subsystems.
  final importPattern = RegExp(r'''(?:import|export)\s+['"]([^'"]+)['"]''');
  final directSeams = <String>{};
  for (final path in dartFiles) {
    final source = File(path).readAsStringSync();
    for (final match in importPattern.allMatches(source)) {
      final target = match.group(1)!;
      String? seam;
      if (target.startsWith('package:poker_analyzer/')) {
        seam = 'lib/${target.substring('package:poker_analyzer/'.length)}';
      } else if (!target.contains(':')) {
        seam = Uri.parse(path).resolve(target).path;
      }
      if (seam != null && seam.startsWith('lib/') && File(seam).existsSync()) {
        directSeams.add(seam);
      }
    }
  }
  final files = <String>{
    ...dartFiles,
    ...directSeams,
    'pubspec.yaml',
    for (final root in [
      'ios/Runner',
      'android/app/src/main',
      'macos/Runner',
      'linux/runner',
      'windows/runner',
      'web',
    ])
      for (final file in Directory(root).listSync(recursive: true))
        if (file is File &&
            RegExp(
              r'\.(swift|m|mm|h|kt|java|xml|plist|entitlements|cc|cpp|html|js)$',
            ).hasMatch(file.path) &&
            !file.path.contains('GeneratedPluginRegistrant'))
          file.path,
  };
  return [
    for (final path in files)
      ..._entrySignatures(path, File(path).readAsStringSync()),
  ]..sort();
}

void _checkExternalEntryInventory() {
  final inventory = File(
    'docs/_reviews/b108_external_entries_v1.md',
  ).readAsStringSync();
  final baseline = RegExp(
    r'<!-- ingress-signatures:start -->\n```text\n([\s\S]*?)\n```\n<!-- ingress-signatures:end -->',
  ).firstMatch(inventory);
  expect(baseline, isNotNull, reason: 'Missing reviewed ingress signatures.');
  final expected = baseline!.group(1)!.split('\n')..sort();
  final actual = _externalEntrySignatures();
  expect(
    actual,
    expected,
    reason:
        'External ingress changed. Classify the new/changed handler in the B108 inventory and add cold/warm state coverage before updating signatures.',
  );
}
