import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/app_root.dart';

Future<void> _completeIntakeBase(WidgetTester tester) async {
  const expectedSeats = <String>['btn', 'sb', 'bb', 'hj', 'co', 'btn', 'bb'];
  for (final seatId in expectedSeats) {
    await tester.tap(
      find.byKey(Key('intake_seat_$seatId')),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 70));
    await tester.tap(
      find.byKey(const Key('intake_check_cta')),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 120));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'placement band and microtest keep learner-facing today summary free of internal ids',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      addTearDown(() {
        ProgressService.debugNowOverride = null;
      });
      ProgressService.debugNowOverride = () => DateTime.utc(2026, 2, 14, 12, 0);

      await tester.pumpWidget(const AppRoot());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 280));

      expect(find.byKey(const Key('intake_runner')), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('intake_skill_band_intermediate')),
        warnIfMissed: false,
      );
      await tester.pump(const Duration(milliseconds: 80));

      await _completeIntakeBase(tester);
      await tester.pump(const Duration(milliseconds: 120));

      expect(find.byKey(const Key('placement_stage_header')), findsOneWidget);
      for (final seat in <String>['btn', 'sb', 'bb']) {
        await tester.tap(
          find.byKey(Key('intake_seat_$seat')),
          warnIfMissed: false,
        );
        await tester.pump(const Duration(milliseconds: 70));
        await tester.tap(
          find.byKey(const Key('intake_check_cta')),
          warnIfMissed: false,
        );
        await tester.pump(const Duration(milliseconds: 120));
      }
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('today_plan_screen')), findsOneWidget);
      final summaryValueFinder = find.byKey(
        const Key('today_plan_top_leak_value'),
      );
      expect(summaryValueFinder, findsOneWidget);
      final summaryValue = tester.widget<Text>(summaryValueFinder);
      expect(summaryValue.data, 'Table map');
      expect(find.textContaining('world1_act0_table_literacy'), findsNothing);
      expect(find.byKey(const Key('today_plan_start_cta')), findsOneWidget);
      expect(await ProgressService.getSkillBandV1(), 'intermediate');
      expect(await ProgressService.getPlacementScoreV1(), 3);
      expect(tester.takeException(), isNull);
    },
  );
}
