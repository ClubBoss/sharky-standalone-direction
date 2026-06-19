import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/premium_value_package_v1.dart';

void main() {
  test('premium value package stays bounded, honest, and consumer-backed', () {
    expect(kPremiumValuePackageV1.title, 'Premium Access');
    expect(
      kPremiumValuePackageV1.freeRuleLine,
      'Free keeps the opening path and first useful hand open.',
    );
    expect(
      kPremiumValuePackageV1.unlockLine,
      'Premium is optional later: more table-clue practice after the free foundation.',
    );
    expect(
      kPremiumValuePackageV1.restoreLine,
      'Restore checks this store account on this device and activates premium only if a past purchase is found.',
    );

    expect(kPremiumValuePackageV1.freeRuleLine, isNot(contains('all worlds')));
    expect(kPremiumValuePackageV1.unlockLine, isNot(contains('all features')));
    expect(kPremiumValuePackageV1.unlockLine, isNot(contains('World 5+')));
    expect(
      kPremiumValuePackageV1.unlockLine,
      isNot(contains('premium-target')),
    );
    expect(kPremiumValuePackageV1.unlockLine, isNot(contains('seven-day')));
    expect(
      kPremiumValuePackageV1.unlockLine,
      isNot(contains('progress insights')),
    );
    expect(kPremiumValuePackageV1.restoreLine, isNot(contains('guarantees')));
    expect(kPremiumValuePackageV1.restoreLine, isNot(contains('always')));

    final todayPlan = File(
      'lib/ui_v2/screens/universal_intake_plan_screen.dart',
    ).readAsStringSync();
    final premiumHub = File(
      'lib/ui_v2/ui_v2_premium_hub.dart',
    ).readAsStringSync();

    expect(todayPlan, contains('kPremiumValuePackageV1.title'));
    expect(todayPlan, contains('kPremiumValuePackageV1.freeRuleLine'));
    expect(todayPlan, contains('kPremiumValuePackageV1.unlockLine'));
    expect(todayPlan, contains('kPremiumValuePackageV1.restoreLine'));

    expect(premiumHub, contains('kPremiumValuePackageV1.title'));
    expect(premiumHub, contains('kPremiumValuePackageV1.freeRuleLine'));
    expect(premiumHub, contains('kPremiumValuePackageV1.unlockLine'));
    expect(premiumHub, contains('kPremiumValuePackageV1.restoreLine'));
  });
}
