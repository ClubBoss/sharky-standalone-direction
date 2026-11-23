import 'package:poker_analyzer/ui_v2/act0_shell/act0_poker_reference_math_v1.dart';
import 'package:test/test.dart';

void main() {
  test('price uses the current pot plus exactly one call', () {
    final price = act0CallPriceV1(30, 10)!;
    expect(price.potAfterCall, 40);
    expect(price.equity, .25);
    expect(price.oddsToOne, 3);
    expect(act0CallPriceV1(30, 0)!.equity, 0);
    expect(act0CallPriceV1(30, 30)!.equity, .5);
    expect(act0CallPriceV1(30, 31), isNull);
    expect(act0CallPriceV1(30, -1), isNull);
    expect(act0CallPriceV1(0, 0), isNull);
    expect(act0CallPriceV1(30, double.nan), isNull);
    expect(act0CallPriceV1(1e308, 1e308), isNull);
  });

  test('converts both ways and validates finite units', () {
    expect(act0ConvertBlindUnitsV1(2.5, 20, toChips: true), 50);
    expect(act0ConvertBlindUnitsV1(50, 20, toChips: false), 2.5);
    expect(act0ConvertBlindUnitsV1(0, 20, toChips: false), 0);
    expect(act0ConvertBlindUnitsV1(50, 0, toChips: false), isNull);
    expect(act0ConvertBlindUnitsV1(-1, 20, toChips: true), isNull);
    expect(act0ConvertBlindUnitsV1(1e308, 2, toChips: true), isNull);
  });

  test('outs use draws without replacement and reject impossible cards', () {
    expect(act0OneCardOutsV1(9, 46), closeTo(.19565, .00001));
    expect(act0TwoCardOutsV1(9, 47), closeTo(.34968, .00001));
    expect(act0TwoCardOutsV1(0, 47), 0);
    expect(act0TwoCardOutsV1(46, 47), 1);
    expect(act0OneCardOutsV1(46, 46), 1);
    expect(act0OneCardOutsV1(47, 46), isNull);
    expect(act0OneCardOutsV1(1, 0), isNull);
    expect(act0TwoCardOutsV1(1, 1), isNull);
  });
}
