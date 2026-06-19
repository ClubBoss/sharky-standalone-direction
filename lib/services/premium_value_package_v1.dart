import 'package:flutter/foundation.dart';

@immutable
class PremiumValuePackageV1 {
  const PremiumValuePackageV1({
    required this.title,
    required this.freeRuleLine,
    required this.unlockLine,
    required this.restoreLine,
  });

  final String title;
  final String freeRuleLine;
  final String unlockLine;
  final String restoreLine;
}

// Canonical bounded premium value package truth for current main.
const PremiumValuePackageV1 kPremiumValuePackageV1 = PremiumValuePackageV1(
  title: 'Premium Access',
  freeRuleLine: 'Free keeps the opening path and first useful hand open.',
  unlockLine:
      'Premium is optional later: more table-clue practice after the free foundation.',
  restoreLine:
      'Restore checks this store account on this device and activates premium only if a past purchase is found.',
);
