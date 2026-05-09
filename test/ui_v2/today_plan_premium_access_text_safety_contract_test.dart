import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'today premium access messaging stays readable with compact height and larger text scale',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 780);
      tester.view.devicePixelRatio = 1.0;

      final nowEpochMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingCompleted': true,
        'intake_completed_v1': true,
        'chips_balance_v1': 5,
        'premium_is_active': false,
        'trial_entitlement_v1': jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs - 1000,
          'durationDays': 7,
        }),
        'spine_campaign_active_pack_id_v1': '',
        'spine_campaign_next_hand_index_v1': 0,
        'spine_campaign_completed_packs_v1': '',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 780),
              textScaler: TextScaler.linear(1.35),
            ),
            child: const UniversalIntakePlanScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final status = find.byKey(const Key('today_plan_trial_status_v1'));
      final previewCta = find.byKey(
        const Key('today_plan_premium_preview_cta_v1'),
      );
      expect(status, findsOneWidget);
      expect(previewCta, findsOneWidget);

      await tester.ensureVisible(previewCta);
      await tester.tap(previewCta, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('today_plan_premium_preview_title_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('today_plan_premium_preview_status_line_v1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('today_plan_premium_preview_restore_cta_v1')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
