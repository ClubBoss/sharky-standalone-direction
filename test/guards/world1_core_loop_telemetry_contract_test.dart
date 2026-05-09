import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui/telemetry_test_harness.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('learning effect slice helper stays deterministic for world1', () {
    final marker = world1LearningEffectSliceMarkerV1(
      moduleId: 'intro_welcome',
      mode: kWorld1RunnerModeDailyRun,
    );
    expect(marker, kWorld1LearningEffectSliceIdV1);

    final summary = computeWorld1LearningEffectSummaryV1(
      moduleId: 'intro_welcome',
      mode: kWorld1RunnerModeDailyRun,
      events: const <World1TelemetrySampleV1>[
        World1TelemetrySampleV1(
          name: 'correct',
          payload: <String, Object?>{
            'module_id': 'intro_welcome',
            'mode': 'daily_run',
            'step_index': 0,
            'correct': true,
            'error_type': 'none',
          },
        ),
        World1TelemetrySampleV1(
          name: 'time_to_decision',
          payload: <String, Object?>{
            'module_id': 'intro_welcome',
            'mode': 'daily_run',
            'step_index': 0,
            'time_to_decision_ms': 900,
          },
        ),
        World1TelemetrySampleV1(
          name: 'correct',
          payload: <String, Object?>{
            'module_id': 'intro_welcome',
            'mode': 'daily_run',
            'step_index': 1,
            'correct': false,
            'error_type': 'incorrect_seat',
          },
        ),
      ],
    );

    expect(summary['slice_marker'], kWorld1LearningEffectSliceIdV1);
    expect(summary['total_decisions'], 2);
    expect(summary['correct_decisions'], 1);
    expect(summary['accuracy_percent'], 50);
    expect(summary['correct_time_to_decision_samples'], 1);
    expect(summary['correct_time_to_decision_avg_ms'], 900);
    expect(summary['error_type_distribution'], <String, int>{
      'incorrect_seat': 1,
    });
  });

  testWidgets('daily run emits start choice correct time and end events', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final harness = TelemetryTestHarness();
    Telemetry.overrideLogHandler(harness.logEvent);
    addTearDown(() => Telemetry.overrideLogHandler(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'intro_welcome',
          moduleTitle: 'Welcome to Poker',
          mode: kWorld1RunnerModeDailyRun,
        ),
      ),
    );
    await tester.pump();

    expect(harness.hasEvent('session_start'), isTrue);
    final sessionStartPayload = harness
        .eventsByName('session_start')
        .last
        .payload;
    expect(sessionStartPayload['module_id'], 'intro_welcome');
    expect(sessionStartPayload['mode'], kWorld1RunnerModeDailyRun);

    await tester.tap(find.byKey(const Key('microtask_seat_btn')));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const Key('microtask_check_cta')));
    await tester.pump(const Duration(milliseconds: 1200));

    final choice = harness.eventsByName('user_choice');
    expect(choice, isNotEmpty);
    expect(choice.last.payload['choice'], 'btn');

    final evals = harness.eventsByName('correct');
    expect(evals, isNotEmpty);
    expect(evals.last.payload['correct'], isTrue);
    expect(evals.last.payload['error_type'], 'none');

    final timing = harness.eventsByName('time_to_decision');
    expect(timing, isNotEmpty);
    expect(
      timing.last.payload['time_to_decision_ms'] as int,
      greaterThanOrEqualTo(0),
    );

    expect(harness.hasEvent('session_end'), isTrue);
    expect(harness.hasEvent('session_abort'), isFalse);
    expect(harness.eventsByName('session_end').length, 1);
    expect(harness.eventsByName('session_abort').length, 0);
    var emotionEvents = harness.eventsByName('emotion_tag_v1');
    for (var i = 0; i < 5 && emotionEvents.isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      emotionEvents = harness.eventsByName('emotion_tag_v1');
    }
    expect(emotionEvents, hasLength(1));
    final emotionPayload = emotionEvents.single.payload;
    expect(emotionPayload.keys.toList(growable: false), <String>[
      'schemaVersion',
      'tag',
      'reasons',
      'recommendedWorldIds',
      'masteryBadges',
    ]);
    final expectedA = await ProgressService.getEmotionTagTelemetryPayloadV1();
    final expectedB = await ProgressService.getEmotionTagTelemetryPayloadV1();
    expect(jsonEncode(expectedA), jsonEncode(expectedB));
    expect(jsonEncode(emotionPayload), jsonEncode(expectedA));
    final masteryBadges = Map<String, dynamic>.from(
      emotionPayload['masteryBadges'] as Map,
    );
    final sortedBadgeKeys = masteryBadges.keys.toList(growable: false)..sort();
    expect(masteryBadges.keys.toList(growable: false), sortedBadgeKeys);
    final phraseEvents = harness.eventsByName('emotion_phrase_shown_v1');
    expect(phraseEvents.length, greaterThanOrEqualTo(2));
    final beforePhrase = phraseEvents.firstWhere(
      (event) => event.payload['context'] == 'beforeSession',
    );
    final afterPhrase = phraseEvents.lastWhere(
      (event) => event.payload['context'] == 'afterOutcome',
    );
    expect(beforePhrase.payload.keys.toList(growable: false), <String>[
      'schemaVersion',
      'phraseId',
      'context',
      'tag',
      'text',
    ]);
    final expectedAfterA =
        await ProgressService.getEmotionPhraseTelemetryPayloadForContextV1(
          context: EmotionPhraseContextV1.afterOutcome,
        );
    final expectedAfterB =
        await ProgressService.getEmotionPhraseTelemetryPayloadForContextV1(
          context: EmotionPhraseContextV1.afterOutcome,
        );
    expect(jsonEncode(expectedAfterA), jsonEncode(expectedAfterB));
    expect(jsonEncode(afterPhrase.payload), jsonEncode(expectedAfterA));
    expect(beforePhrase.payload['context'], 'beforeSession');
    expect(afterPhrase.payload['context'], 'afterOutcome');

    expect(tester.takeException(), isNull);
  });

  testWidgets('incorrect answer emits error_type without time_to_decision', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final harness = TelemetryTestHarness();
    Telemetry.overrideLogHandler(harness.logEvent);
    addTearDown(() => Telemetry.overrideLogHandler(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'intro_welcome',
          moduleTitle: 'Welcome to Poker',
          mode: kWorld1RunnerModeFoundationsCheck,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('microtask_seat_sb')));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const Key('microtask_check_cta')));
    await tester.pump(const Duration(milliseconds: 120));

    final choice = harness.eventsByName('user_choice');
    expect(choice, isNotEmpty);
    expect(choice.last.payload['choice'], 'sb');

    final evals = harness.eventsByName('correct');
    expect(evals, isNotEmpty);
    expect(evals.last.payload['correct'], isFalse);
    expect(evals.last.payload['error_type'], 'incorrect_seat');

    expect(harness.eventsByName('time_to_decision'), isEmpty);
    expect(harness.eventsByName('session_end'), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dispose before completion emits session_abort', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final harness = TelemetryTestHarness();
    Telemetry.overrideLogHandler(harness.logEvent);
    addTearDown(() => Telemetry.overrideLogHandler(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: World1FoundationsMicroTaskRunnerScreen(
          moduleId: 'intro_welcome',
          moduleTitle: 'Welcome to Poker',
          mode: kWorld1RunnerModeFoundationsCheck,
        ),
      ),
    );
    await tester.pump();

    expect(harness.hasEvent('session_start'), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(harness.hasEvent('session_abort'), isTrue);
    expect(harness.hasEvent('session_end'), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'campaign handloop supports incorrect path, keeps call visible, and shows why',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
      });
      final harness = TelemetryTestHarness();
      Telemetry.overrideLogHandler(harness.logEvent);
      addTearDown(() => Telemetry.overrideLogHandler(null));

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'world1_spine_campaign_v1',
            moduleTitle: 'World 1 Spine',
            mode: kWorld1RunnerModeCampaignSpine,
          ),
        ),
      );
      await tester.pumpAndSettle();

      Finder actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      for (var i = 0; i < 8 && actionBar.evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 120));
        actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      }
      expect(actionBar, findsOneWidget);
      expect(
        find.descendant(
          of: actionBar,
          matching: find.widgetWithText(OutlinedButton, 'CALL'),
        ),
        findsOneWidget,
      );

      final foldButton = find.descendant(
        of: actionBar,
        matching: find.widgetWithText(OutlinedButton, 'FOLD'),
      );
      expect(foldButton, findsOneWidget);
      await tester.tap(foldButton.first, warnIfMissed: false);
      for (var i = 0; i < 20 && harness.eventsByName('correct').isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 120));
      }

      final evals = harness.eventsByName('correct');
      expect(evals, isNotEmpty);
      expect(evals.last.payload['correct'], isFalse);
      expect(evals.last.payload['error_type'], 'range');

      expect(
        find.textContaining(
          'Action is valid but does not match expected strategy action',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Street ->'), findsNothing);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'demo handloop enforces deterministic Check/Call invariants by toCall',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        const MaterialApp(
          home: World1FoundationsMicroTaskRunnerScreen(
            moduleId: 'season1_demo_multistreet_v1',
            moduleTitle: 'Demo Multi Street',
            mode: kWorld1RunnerModeDemoHandLoopV1,
          ),
        ),
      );
      await tester.pumpAndSettle();

      Finder actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      for (var i = 0; i < 8 && actionBar.evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 120));
        actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      }
      expect(actionBar, findsOneWidget);

      final callStep1 = find.descendant(
        of: actionBar,
        matching: find.widgetWithText(OutlinedButton, 'CALL'),
      );
      final checkStep1 = find.descendant(
        of: actionBar,
        matching: find.widgetWithText(OutlinedButton, 'CHECK'),
      );
      expect(callStep1, findsOneWidget);
      expect(checkStep1, findsNothing);

      await tester.tap(find.byKey(const Key('microtask_seat_co')));
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(callStep1.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));

      final continueCta = find.byKey(const Key('microtask_continue_cta'));
      expect(continueCta, findsOneWidget);
      await tester.tap(continueCta.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 240));

      actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      for (var i = 0; i < 8 && actionBar.evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 120));
        actionBar = find.byKey(const Key('microtask_campaign_action_bar'));
      }
      expect(actionBar, findsOneWidget);

      final checkStep2 = find.descendant(
        of: actionBar,
        matching: find.widgetWithText(OutlinedButton, 'CHECK'),
      );
      final callStep2 = find.descendant(
        of: actionBar,
        matching: find.widgetWithText(OutlinedButton, 'CALL'),
      );
      expect(checkStep2, findsOneWidget);
      expect(callStep2, findsNothing);
      expect(
        find.descendant(
          of: actionBar,
          matching: find.widgetWithText(OutlinedButton, 'BET 1/2'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: actionBar,
          matching: find.widgetWithText(OutlinedButton, 'BET POT'),
        ),
        findsOneWidget,
      );

      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
