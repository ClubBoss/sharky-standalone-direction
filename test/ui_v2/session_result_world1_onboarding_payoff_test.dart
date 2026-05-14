import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/constants/telemetry_events.dart';
import 'package:poker_analyzer/infra/telemetry.dart';
import 'package:poker_analyzer/ui_v2/screens/session_result_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'early World 1 act0 result surface names the next capability instead of generic campaign framing',
    (tester) async {
      final events = <Map<String, dynamic>>[];
      Telemetry.overrideLogHandler((name, payload) async {
        events.add(<String, dynamic>{'name': name, 'payload': payload ?? {}});
      });
      addTearDown(() {
        Telemetry.overrideLogHandler(null);
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;

      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        const MaterialApp(
          home: SessionResultScreen(
            correctCount: 3,
            totalCount: 3,
            moduleId: 'world1_act0_table_literacy',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final continuationFinder = find.byKey(
        const Key('session_result_continuation_line_v1'),
      );
      expect(continuationFinder, findsOneWidget);
      final continuationText =
          (tester.widget<Text>(continuationFinder).data ?? '').trim();
      expect(
        continuationText,
        'Next: use this same seat map to choose the first action before the flop.',
      );

      final whatsNextValueFinder = find.byKey(
        const Key('session_result_whats_next_value'),
      );
      expect(whatsNextValueFinder, findsOneWidget);
      final whatsNextValue =
          (tester.widget<Text>(whatsNextValueFinder).data ?? '').trim();
      expect(whatsNextValue, 'First action choices');

      final whyLineFinder = find.byKey(const Key('session_result_why_line_v1'));
      expect(whyLineFinder, findsOneWidget);
      final whyLine = (tester.widget<Text>(whyLineFinder).data ?? '').trim();
      expect(
        whyLine,
        'Real-table value: once Button and blinds are clear, your first preflop action is a reasoned choice, not a guess.',
      );

      final upNextHeadlineFinder = find.byKey(
        const Key('session_result_up_next_headline_v1'),
      );
      expect(upNextHeadlineFinder, findsOneWidget);
      final upNextHeadline =
          (tester.widget<Text>(upNextHeadlineFinder).data ?? '').trim();
      expect(upNextHeadline, 'Next up: First action choices');

      final summaryLineFinder = find.byKey(
        const Key('session_result_summary_line_secondary_v1'),
      );
      expect(summaryLineFinder, findsOneWidget);
      final summaryLine = (tester.widget<Text>(summaryLineFinder).data ?? '')
          .trim();
      expect(
        summaryLine,
        'Next lesson ready: World 1 · Pack 2 of 7 · First action choices.',
      );
      final sharkyFinder = find.byKey(
        const Key('session_result_sharky_reinforcement_line_v1'),
      );
      expect(sharkyFinder, findsOneWidget);
      final sharkyLine = (tester.widget<Text>(sharkyFinder).data ?? '').trim();
      expect(
        sharkyLine,
        'Sharky: Nice work. Keep seat map first and the next spot will read faster.',
      );
      expect(
        find.text(
          'Sharky: Nice work. Keep seat map first and the next spot will read faster.',
        ),
        findsOneWidget,
      );
      final eventNames = events
          .map((event) => event['name'] as String)
          .toList(growable: false);
      expect(
        eventNames.where(
          (name) => name == TelemetryEvents.firstSessionAhaImpressionV1,
        ),
        isNotEmpty,
      );

      expect(find.text('NEXT LESSON'), findsOneWidget);
      expect(
        find.byKey(const Key('session_result_next_module_cta')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
