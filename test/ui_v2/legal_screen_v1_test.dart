import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/models/learning_path_progress_snapshot.dart';
import 'package:poker_analyzer/services/learning_path_progress_snapshot_service.dart';
import 'package:poker_analyzer/services/training_session_fingerprint_logger_service.dart';
import 'package:poker_analyzer/ui/telemetry_test_harness.dart';
import 'package:poker_analyzer/ui_v2/settings/legal_screen_v1.dart';

void main() {
  late TelemetryTestHarness harness;

  setUp(() {
    harness = TelemetryTestHarness();
    Telemetry.overrideLogHandler(harness.logEvent);
  });

  tearDown(() {
    Telemetry.overrideLogHandler(null);
    LegalScreenV1.overrideSnapshotService = null;
    LegalScreenV1.overrideSessionFingerprintService = null;
    LegalScreenV1.overrideProgressService = null;
  });

  testWidgets('Delete data flow clears prefs and emits telemetry', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'settings_sound_enabled': true,
      'haptics_enabled': true,
      'learning_completed_pack1': true,
      'learning_intro_seen': true,
      'custom_path_started': true,
      'custom_path_completed': true,
    });

    final snapshotService = LearningPathProgressSnapshotService(
      storage: PrefsProgressSnapshotStorage(),
    );
    await snapshotService.save(
      'legal',
      const LearningPathProgressSnapshot(pathId: 'legal', stageId: 'stage'),
    );

    final fingerprintService = TrainingSessionFingerprintLoggerService();
    await fingerprintService.logSession(
      TrainingSessionFingerprint(packId: 'test-pack'),
    );

    LegalScreenV1.overrideSnapshotService = snapshotService;
    LegalScreenV1.overrideSessionFingerprintService = fingerprintService;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const LegalScreenV1(),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Delete Data / Account'));
    await tester.pump();
    await tester.tap(find.text('Confirm'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(harness.hasEvent(TelemetryEvents.legalOpened), isTrue);
    expect(
      harness.eventsByName(TelemetryEvents.deleteDataRequested),
      hasLength(1),
    );
    expect(
      harness.eventsByName(TelemetryEvents.deleteDataConfirmed),
      hasLength(1),
    );
    expect(
      harness.eventsByName(TelemetryEvents.deleteDataCompleted),
      hasLength(1),
    );

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('learning_completed_pack1'), isFalse);
    expect(prefs.containsKey('learning_intro_seen'), isFalse);
    expect(prefs.containsKey('custom_path_started'), isFalse);
    expect(prefs.containsKey('custom_path_completed'), isFalse);
    expect(prefs.containsKey('training_session_fingerprints'), isFalse);
    expect(
      prefs.getKeys().any((key) => key.startsWith('lp_snapshot_')),
      isFalse,
    );
  });

  testWidgets('Privacy and terms open in-app legal surfaces', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const LegalScreenV1(),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('privacy_screen_v1')), findsOneWidget);
    expect(harness.eventsByName(TelemetryEvents.privacyOpened), hasLength(1));

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Terms of Use'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('terms_screen_v1')), findsOneWidget);
    expect(harness.eventsByName(TelemetryEvents.termsOpened), hasLength(1));
    expect(tester.takeException(), isNull);
  });
}
