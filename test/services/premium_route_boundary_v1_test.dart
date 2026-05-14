import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/premium_route_boundary_v1.dart';

void main() {
  test('premium route boundary keeps W1-W4 free and W5+ premium', () {
    expect(PremiumRouteBoundaryV1.freeWorldMax, 4);
    expect(PremiumRouteBoundaryV1.premiumWorldMin, 5);

    expect(PremiumRouteBoundaryV1.isPremiumProgressionWorldV1(null), isFalse);
    expect(PremiumRouteBoundaryV1.isPremiumProgressionWorldV1(1), isFalse);
    expect(PremiumRouteBoundaryV1.isPremiumProgressionWorldV1(4), isFalse);
    expect(PremiumRouteBoundaryV1.isPremiumProgressionWorldV1(5), isTrue);
    expect(PremiumRouteBoundaryV1.isPremiumProgressionWorldV1(12), isTrue);
  });
}
