import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/ui_v2/screens/universal_intake_plan_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingCompleted': true,
      'intake_completed_v1': true,
      'chips_balance_v1': 5,
      'spine_campaign_active_pack_id_v1': '',
      'spine_campaign_next_hand_index_v1': 0,
      'spine_campaign_completed_packs_v1': '',
      'intake_profile_v1': jsonEncode(<String, Object?>{
        'focusLabel': 'position',
        'errorClass': 'late_position_confusion',
      }),
    });
  });

  testWidgets(
    'today plan keeps critical text and start CTA visible on compact text-scaled layout',
    (tester) async {
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      tester.view.physicalSize = const Size(390, 780);
      tester.view.devicePixelRatio = 1.0;

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

      final screen = find.byKey(const Key('today_plan_screen'));
      final title = find.byKey(const Key('today_plan_first_session_title_v1'));
      final promise = find.byKey(
        const Key('today_plan_first_session_product_promise_v1'),
      );
      final cta = find.byKey(const Key('today_plan_start_cta'));

      expect(screen, findsOneWidget);
      expect(title, findsOneWidget);
      expect(promise, findsOneWidget);
      expect(cta, findsOneWidget);

      await tester.ensureVisible(title);
      await tester.ensureVisible(promise);
      await tester.ensureVisible(cta);
      await tester.pumpAndSettle();

      expect(tester.getRect(title).height, greaterThan(0));
      expect(tester.getRect(cta).height, greaterThan(0));
      expect(tester.takeException(), isNull);
    },
  );
}
