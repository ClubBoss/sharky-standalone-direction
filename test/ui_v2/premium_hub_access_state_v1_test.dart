import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:poker_analyzer/services/premium_service.dart';
import 'package:poker_analyzer/ui_v2/ui_v2_premium_hub.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await PremiumService().clear();
  });

  testWidgets(
    'premium hub keeps trial distinct from premium and refreshes after upgrade',
    (tester) async {
      final nowEpochMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      SharedPreferences.setMockInitialValues(<String, Object>{
        'premium_is_active': false,
        'trial_entitlement_v1': jsonEncode(<String, int>{
          'schemaVersion': 1,
          'startEpochMs': nowEpochMs - 1000,
          'durationDays': 7,
        }),
      });

      await tester.pumpWidget(const MaterialApp(home: UiV2PremiumHub()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(const Key('premium_hub_status_label_v1')),
        findsOneWidget,
      );
      expect(
        find.text(
          'Trial active: premium-target Today routes and World 5+ stay open during the active trial.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Your account is on trial now. Premium keeps the same premium-target access after the trial ends.',
        ),
        findsOneWidget,
      );
      expect(find.text('Premium is ACTIVE'), findsNothing);
      expect(find.text('Upgrade to Premium'), findsOneWidget);

      await PremiumService().enablePremium();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text(
          'Premium active: premium-target Today routes and World 5+ are unlocked.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Your account already has premium access on current main.'),
        findsOneWidget,
      );
      expect(find.text('Upgrade to Premium'), findsNothing);
      expect(find.text('Premium Activated'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('premium hub refreshes visible access state after lifecycle resume', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'premium_is_active': false,
    });

    await tester.pumpWidget(const MaterialApp(home: UiV2PremiumHub()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text(
        'Free access stays on the opening path plus one Today route per UTC day.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Premium adds premium-target Today routes and World 5+ progression on current main.',
      ),
      findsOneWidget,
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(milliseconds: 40));
    await PremiumService().enablePremium();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(
      find.text(
        'Premium active: premium-target Today routes and World 5+ are unlocked.',
      ),
      findsOneWidget,
    );
    expect(find.text('Premium Activated'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
