import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/premium_value_package_v1.dart';

void main() {
  test('premium value package stays bounded, honest, and consumer-backed', () {
    expect(kPremiumValuePackageV1.title, 'Premium Access');
    expect(
      kPremiumValuePackageV1.freeRuleLine,
      'Free includes the opening path and one Today route per UTC day.',
    );
    expect(
      kPremiumValuePackageV1.unlockLine,
      'Trial or premium unlock premium-target Today routes and World 5+ progression on current main.',
    );
    expect(
      kPremiumValuePackageV1.restoreLine,
      'Restore checks this store account on this device and activates premium only if a past purchase is found.',
    );

    expect(kPremiumValuePackageV1.freeRuleLine, isNot(contains('all worlds')));
    expect(kPremiumValuePackageV1.unlockLine, isNot(contains('all features')));
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
