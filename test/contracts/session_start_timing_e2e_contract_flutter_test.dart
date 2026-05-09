import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedantic/pedantic.dart';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/l10n/app_localizations.dart';
import 'package:poker_analyzer/main.dart' show navigatorKey;
import 'package:poker_analyzer/models/v2/training_pack_spot.dart';
import 'package:poker_analyzer/models/v2/training_pack_template_v2.dart';
import 'package:poker_analyzer/core/training/engine/training_type_engine.dart';
import 'package:poker_analyzer/services/session_start_timing_service_v1.dart';
import 'package:poker_analyzer/services/training_session_launcher.dart';
import 'package:poker_analyzer/services/training_session_outcome.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Training session launch emits single session_start_timing_v1 event',
    (tester) async {
      final captured = <MapEntry<String, Map<String, dynamic>?>>[];
      Telemetry.overrideLogHandler((name, props) async {
        captured.add(MapEntry(name, props));
      });
      TrainingSessionLauncher.overrideLaunchHandler((
        template, {
        int startIndex = 0,
        List<String>? sessionTags,
        String? source,
        TrainingSessionEndCallback? onSessionEnd,
      }) async {
        SessionStartTimingServiceV1.instance.start(
          source: source ?? 'session_start_timing_e2e_test',
        );
        final navigatorState = navigatorKey.currentState;
        if (navigatorState != null) {
          await navigatorState.push(
            MaterialPageRoute<void>(
              builder: (_) => const _SessionStartTimingProbeScreen(),
            ),
          );
        }
        onSessionEnd?.call(TrainingSessionEndReasonV1.completed);
      });
      addTearDown(() {
        Telemetry.overrideLogHandler(null);
        TrainingSessionLauncher.overrideLaunchHandler(null);
      });

      final template = TrainingPackTemplateV2(
        id: 'session_start_timing_e2e',
        name: 'Session Start Timing E2E',
        trainingType: TrainingType.pushFold,
        spots: [TrainingPackSpot(id: 'session_timing_spot')],
        tags: const ['test'],
      );

      var launched = false;
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              if (!launched) {
                launched = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  unawaited(
                    TrainingSessionLauncher().launch(
                      template,
                      source: 'session_start_timing_e2e_test',
                    ),
                  );
                });
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1));

      final events = captured
          .where((entry) => entry.key == TelemetryEvents.sessionStartTiming)
          .toList();
      expect(events, hasLength(1));
      final props = events.first.value;
      expect(props, isNotNull);
      expect(props!['elapsed_ms'], isA<int>());
      expect((props['elapsed_ms'] as int) >= 0, isTrue);

      await tester.pump(const Duration(milliseconds: 1));
      expect(
        captured.where(
          (entry) => entry.key == TelemetryEvents.sessionStartTiming,
        ),
        hasLength(1),
      );
    },
  );
}

class _SessionStartTimingProbeScreen extends StatefulWidget {
  const _SessionStartTimingProbeScreen({Key? key}) : super(key: key);

  @override
  State<_SessionStartTimingProbeScreen> createState() =>
      _SessionStartTimingProbeScreenState();
}

class _SessionStartTimingProbeScreenState
    extends State<_SessionStartTimingProbeScreen> {
  bool _marked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_marked) return;
      _marked = true;
      SessionStartTimingServiceV1.instance.markFirstFrameRendered();
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('session start timing probe')),
    );
  }
}
