import 'package:poker_analyzer/ui_v2/act0_shell/act0_hlp02_math_core_v1.dart';
import 'package:test/test.dart';

void main() {
  group('HLP-02 BB/chips conversions', () {
    test('uses explicit big-blind denomination and preserves fractions', () {
      expect(
        hlp02BbToChipsV1(amountBb: 2.5, bigBlindChips: 200),
        500,
      );
      expect(
        hlp02ChipsToBbV1(amountChips: 500, bigBlindChips: 200),
        2.5,
      );
      expect(
        hlp02BbToChipsV1(amountBb: 1 / 3, bigBlindChips: 100),
        closeTo(100 / 3, 1e-12),
      );
      expect(hlp02BbToChipsV1(amountBb: 0, bigBlindChips: 25), 0);
      expect(hlp02ChipsToBbV1(amountChips: 0, bigBlindChips: 25), 0);
    });

    test('round trips across blind sizes without intermediate rounding', () {
      for (final blind in <num>[1, 3, 20, 50, 100, 1000]) {
        for (final chips in <num>[0, 1, 5, 37.5, 100, 1250]) {
          final amountBb = hlp02ChipsToBbV1(
            amountChips: chips,
            bigBlindChips: blind,
          );
          expect(
            hlp02BbToChipsV1(
              amountBb: amountBb,
              bigBlindChips: blind,
            ),
            closeTo(chips.toDouble(), 1e-10),
            reason: 'blind=$blind chips=$chips',
          );
        }
      }
    });

    test('rejects zero or negative big blind in both directions', () {
      for (final blind in <num>[0, -1]) {
        expect(
          () => hlp02BbToChipsV1(amountBb: 2, bigBlindChips: blind),
          throwsArgumentError,
        );
        expect(
          () => hlp02ChipsToBbV1(amountChips: 200, bigBlindChips: blind),
          throwsArgumentError,
        );
      }
    });

    test('rejects negative and nonfinite BB, chips and blind values', () {
      for (final bad in <num>[
        -1,
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(
          () => hlp02BbToChipsV1(amountBb: bad, bigBlindChips: 100),
          throwsArgumentError,
        );
        expect(
          () => hlp02ChipsToBbV1(amountChips: bad, bigBlindChips: 100),
          throwsArgumentError,
        );
        expect(
          () => hlp02BbToChipsV1(amountBb: 1, bigBlindChips: bad),
          throwsArgumentError,
        );
        expect(
          () => hlp02ChipsToBbV1(amountChips: 100, bigBlindChips: bad),
          throwsArgumentError,
        );
      }
    });

    test('fails closed on overflow and underflow', () {
      expect(
        () => hlp02BbToChipsV1(
          amountBb: 1e308,
          bigBlindChips: 1e308,
        ),
        throwsArgumentError,
      );
      expect(
        () => hlp02BbToChipsV1(
          amountBb: 1e-320,
          bigBlindChips: 1e-20,
        ),
        throwsArgumentError,
      );
      expect(
        () => hlp02ChipsToBbV1(
          amountChips: 1e-320,
          bigBlindChips: 1e100,
        ),
        throwsArgumentError,
      );
    });
  });

  group('HLP-02 call price / pot odds', () {
    test('includes opponent wager already in pre-call pot', () {
      // Pot was 100, opponent bet 50: pot BEFORE Hero calls is 150.
      final price = hlp02CallPriceV1(
        potBeforeCallChips: 150,
        additionalCallChips: 50,
      )!;
      expect(price.potBeforeCallChips, 150);
      expect(price.additionalCallChips, 50);
      expect(price.potAfterCallChips, 200);
      expect(price.requiredWinRateFraction, 0.25);
      expect(price.requiredWinRatePercent, 25);
    });

    test('uses final pot denominator and reports threshold, not equity', () {
      final price = hlp02CallPriceV1(
        potBeforeCallChips: 100,
        additionalCallChips: 50,
      )!;
      expect(price.potAfterCallChips, 150);
      expect(price.requiredWinRateFraction, closeTo(1 / 3, 1e-12));
      expect(price.requiredWinRatePercent, closeTo(100 / 3, 1e-10));
    });

    test('has no price when there is no additional bet to call', () {
      expect(
        hlp02CallPriceV1(
          potBeforeCallChips: 100,
          additionalCallChips: 0,
        ),
        isNull,
      );
      expect(
        hlp02CallPriceV1(
          potBeforeCallChips: 0,
          additionalCallChips: 0,
        ),
        isNull,
      );
    });

    test('zero contestable pot with positive call gives 100% arithmetic', () {
      final price = hlp02CallPriceV1(
        potBeforeCallChips: 0,
        additionalCallChips: 20,
      )!;
      expect(price.requiredWinRateFraction, 1);
      expect(price.requiredWinRatePercent, 100);
    });

    test('requires finite nonnegative inputs, even for a free check', () {
      for (final invalid in <num>[
        -0.1,
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(
          () => hlp02CallPriceV1(
            potBeforeCallChips: invalid,
            additionalCallChips: 0,
          ),
          throwsArgumentError,
        );
        expect(
          () => hlp02CallPriceV1(
            potBeforeCallChips: 100,
            additionalCallChips: invalid,
          ),
          throwsArgumentError,
        );
      }
    });

    test('rejects overflow and lost call precision', () {
      expect(
        () => hlp02CallPriceV1(
          potBeforeCallChips: 1e308,
          additionalCallChips: 1e308,
        ),
        throwsArgumentError,
      );
      expect(
        () => hlp02CallPriceV1(
          potBeforeCallChips: 1e300,
          additionalCallChips: 1,
        ),
        throwsArgumentError,
      );
    });

    test('price is invariant to consistent conversion into BB', () {
      const blind = 20;
      final inChips = hlp02CallPriceV1(
        potBeforeCallChips: 120,
        additionalCallChips: 30,
      )!;
      final inBb = hlp02CallPriceV1(
        potBeforeCallChips: hlp02ChipsToBbV1(
          amountChips: 120,
          bigBlindChips: blind,
        ),
        additionalCallChips: hlp02ChipsToBbV1(
          amountChips: 30,
          bigBlindChips: blind,
        ),
      )!;
      expect(inBb.requiredWinRateFraction, inChips.requiredWinRateFraction);
      expect(inChips.requiredWinRatePercent, 20);
    });
  });
}
