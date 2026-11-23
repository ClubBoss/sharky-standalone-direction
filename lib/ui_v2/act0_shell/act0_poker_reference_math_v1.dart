/// The pot includes only chips the caller can win, before adding the call.
/// The call is capped by the caller's remaining stack. Use consistent units.
({double potAfterCall, double equity, double? oddsToOne})? act0CallPriceV1(
  double pot,
  double call,
) {
  final total = pot + call;
  if (!total.isFinite || pot <= 0 || call < 0 || call > pot) return null;
  final odds = pot / call;
  return (
    potAfterCall: total,
    equity: call / total,
    oddsToOne: odds.isFinite ? odds : null,
  );
}

/// Conditional on every counted out being clean and equally likely.
double? act0OneCardOutsV1(int outs, int unseen) =>
    unseen > 0 && unseen <= 47 && outs >= 0 && outs <= unseen
    ? outs / unseen
    : null;

/// Both cards are dealt without replacement and the same outs remain clean.
double? act0TwoCardOutsV1(int outs, int unseen) {
  final first = act0OneCardOutsV1(outs, unseen);
  if (first == null || unseen < 2) return null;
  if (outs >= unseen - 1) return 1;
  return 1 - (1 - first) * (unseen - outs - 1) / (unseen - 1);
}

/// 1 BB is the supplied number of chips. Fractional BB are preserved.
double? act0ConvertBlindUnitsV1(
  double amount,
  double chipsPerBlind, {
  required bool toChips,
}) {
  if (!amount.isFinite ||
      !chipsPerBlind.isFinite ||
      amount < 0 ||
      chipsPerBlind <= 0) {
    return null;
  }
  final result = toChips ? amount * chipsPerBlind : amount / chipsPerBlind;
  return result.isFinite && (result > 0 || amount == 0) ? result : null;
}
