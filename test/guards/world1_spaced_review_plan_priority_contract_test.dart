import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/map/progress_map_world1_determinism.dart';
import 'package:poker_analyzer/services/progress_service.dart';
import 'package:poker_analyzer/ui_v2/screens/world1_foundations_microtask_runner_screen.dart';
import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';

import '_harness/ui_v2_guard_harness_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'mistake schedules review and Today Plan prioritizes Review when due',
    (tester) async {
      addTearDown(() {
        ProgressService.debugNowOverride = null;
        ProgressService.intakeFlowActiveInSession = false;
      });
      final t0 = DateTime.utc(2026, 1, 1, 12, 0, 0);
      SharedPreferences.setMockInitialValues(<String, Object>{});
      ProgressService.debugNowOverride = () => t0;
      ProgressService.intakeFlowActiveInSession = true;
      await ProgressService.saveIntakeProfile(<String, Object?>{
        'version': 'v1',
        'completedAt': t0.toIso8601String(),
        'steps': 7,
        'wrongAttempts': 1,
        'errorClass': 'wrong_action',
        'focusLabel': 'range',
      });

      await pumpToSessionResult(
        tester,
        correctCount: 0,
        totalCount: 1,
        moduleId: kWorld1CanonicalModuleOrder.first,
      );

      final reviewAt = await ProgressService.getFocusReviewAt('range');
      expect(reviewAt, isNotNull);
      expect(reviewAt, t0.add(const Duration(hours: 24)));

      ProgressService.debugNowOverride = () =>
          t0.add(const Duration(hours: 25));

      await tester.pumpWidget(
        const MaterialApp(home: UniversalIntakePlanScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('today_plan_screen')), findsOneWidget);
      expect(
        find.byKey(
          const Key('today_plan_recommended_value'),
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          '(world1_act0_action_literacy)',
          skipOffstage: false,
        ),
        findsWidgets,
      );

      await tester.tap(
        find.byKey(const Key('today_plan_start_cta')),
        warnIfMissed: false,
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
        findsOneWidget,
      );
      final runner = tester.widget<World1FoundationsMicroTaskRunnerScreen>(
        find.byType(World1FoundationsMicroTaskRunnerScreen),
      );
      expect(runner.moduleId, 'world1_act0_action_literacy');

      expect(tester.takeException(), isNull);
    },
  );
}
