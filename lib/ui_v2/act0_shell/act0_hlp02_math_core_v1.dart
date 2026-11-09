/// HLP-02 teaching-only unit arithmetic. Not a betting or equity engine.
///
/// Every chip value must use the same caller-selected chip denomination.
/// BB is a number of big blinds, not the big-blind seat or a currency.
///
/// These functions use unrounded IEEE 754 doubles (about 15-17 significant
/// decimal digits). The caller owns display rounding. This is not a settlement,
/// legal-action, rake, side-pot, or source-history authority. Do not use the
/// output to grade poker decisions or to assert a hand's equity.

/// Converts a nonnegative BB quantity into chips using a positive BB size.
///
/// Formula: chips = amountBb * bigBlindChips.
/// Fractional chip values are preserved, never silently rounded.
double hlp02BbToChipsV1({
  required num amountBb,
  required num bigBlindChips,
}) {
  final amount = _finiteNonnegative(amountBb, 'amountBb');
  final blind = _finitePositive(bigBlindChips, 'bigBlindChips');
  final chips = amount * blind;
  if (!chips.isFinite || (amount > 0 && chips == 0)) {
    throw ArgumentError.value(amountBb, 'amountBb', 'chip result out of range');
  }
  return chips;
}

/// Converts a nonnegative chip quantity into BB with no display rounding.
///
/// Formula: BB = amountChips / bigBlindChips.
/// A caller may convert the returned BB back with hlp02BbToChipsV1;
/// floating-point round trips use a tolerance rather than exact equality.
double hlp02ChipsToBbV1({
  required num amountChips,
  required num bigBlindChips,
}) {
  final chips = _finiteNonnegative(amountChips, 'amountChips');
  final blind = _finitePositive(bigBlindChips, 'bigBlindChips');
  final bb = chips / blind;
  if (!bb.isFinite || (chips > 0 && bb == 0)) {
    throw ArgumentError.value(
      amountChips,
      'amountChips',
      'BB result out of range',
    );
  }
  return bb;
}

/// The arithmetic price of calling, not a prediction of hand equity.
///
/// [potBeforeCallChips] contains the already committed, contestable pot,
/// INCLUDING the opponent's current wager but EXCLUDING Hero's new call.
/// [additionalCallChips] is the actual incremental call cost (not a raise-to
/// total). It must already be derived and, where needed, stack-capped by the
/// existing poker-state owner. Unqualified side pots must not be included.
///
/// Assumptions: no rake, future betting, refunds, or implied odds.
/// Required win-rate threshold = call / (pot before call + call).
/// This threshold is NOT the hero hand's actual equity.
final class Hlp02CallPriceV1 {
  const Hlp02CallPriceV1._({
    required this.potBeforeCallChips,
    required this.additionalCallChips,
    required this.potAfterCallChips,
    required this.requiredWinRateFraction,
  });

  final double potBeforeCallChips;
  final double additionalCallChips;
  final double potAfterCallChips;

  /// Break-even win-rate threshold in [0, 1], not calculated hand equity.
  final double requiredWinRateFraction;

  /// Percent representation of the threshold, not calculated hand equity.
  double get requiredWinRatePercent => requiredWinRateFraction * 100;
}

/// Returns null when there is no price to call (free check / no facing bet).
///
/// Rejects negative, nonfinite, overflowing or precision-losing inputs.
/// Zero pot with a positive call is valid arithmetic (100% threshold); whether
/// that state is poker-legitimate belongs to the existing poker-state owner.
Hlp02CallPriceV1? hlp02CallPriceV1({
  required num potBeforeCallChips,
  required num additionalCallChips,
}) {
  final pot = _finiteNonnegative(potBeforeCallChips, 'potBeforeCallChips');
  final call = _finiteNonnegative(additionalCallChips, 'additionalCallChips');
  if (call == 0) return null;

  final after = pot + call;
  if (!after.isFinite || after <= pot) {
    throw ArgumentError.value(
      additionalCallChips,
      'additionalCallChips',
      'final pot overflows or loses the added call',
    );
  }

  return Hlp02CallPriceV1._(
    potBeforeCallChips: pot,
    additionalCallChips: call,
    potAfterCallChips: after,
    requiredWinRateFraction: call / after,
  );
}

double _finiteNonnegative(num value, String name) {
  final number = value.toDouble();
  if (!number.isFinite || number < 0) {
    throw ArgumentError.value(value, name, 'must be finite and >= 0');
  }
  return number;
}

double _finitePositive(num value, String name) {
  final number = value.toDouble();
  if (!number.isFinite || number <= 0) {
    throw ArgumentError.value(value, name, 'must be finite and > 0');
  }
  return number;
}
