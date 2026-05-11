import 'package:flutter/widgets.dart';

const EdgeInsets kCanonicalLearnerActionSurfacePaddingV1 = EdgeInsets.fromLTRB(
  12,
  0,
  12,
  8,
);
const EdgeInsets kCanonicalLearnerBottomBandPaddingV1 = EdgeInsets.fromLTRB(
  8,
  6,
  8,
  8,
);
const EdgeInsets kCanonicalLearnerActionSafeAreaMinimumV1 = EdgeInsets.only(
  bottom: 8,
);
const EdgeInsets kCanonicalLearnerBottomBandSafeAreaMinimumV1 = EdgeInsets.only(
  bottom: 14,
);
const double kCanonicalLearnerFeedbackActionGapV1 = 6.0;
const double kCanonicalLearnerBottomBandHeightFractionV1 = 0.16;
const double kCanonicalLearnerBottomBandMinHeightV1 = 72.0;
const double kCanonicalLearnerBottomBandMaxHeightV1 = 136.0;

int? canonicalLearnerPrimaryActionOrderRankV1(String actionId) {
  switch (actionId.trim().toLowerCase()) {
    case 'fold':
      return 0;
    case 'check':
    case 'call':
      return 1;
    case 'bet':
    case 'raise':
    case 'raise_to':
    case 'raise min':
    case 'raise_min':
      return 2;
  }
  return null;
}

List<T> canonicalLearnerPrimaryActionOrderV1<T>(
  Iterable<T> items,
  String Function(T item) actionIdOf,
) {
  final indexedItems = items.toList(growable: false);
  final recognizedCount = indexedItems
      .where(
        (item) =>
            canonicalLearnerPrimaryActionOrderRankV1(actionIdOf(item)) != null,
      )
      .length;
  if (recognizedCount < 2) {
    return indexedItems;
  }
  final nonPrimaryCount = indexedItems.length - recognizedCount;
  if (nonPrimaryCount > 0) {
    return indexedItems;
  }
  final indexed = List.generate(
    indexedItems.length,
    (index) => (index, indexedItems[index]),
    growable: false,
  );
  indexed.sort((left, right) {
    final leftRank =
        canonicalLearnerPrimaryActionOrderRankV1(actionIdOf(left.$2)) ?? 99;
    final rightRank =
        canonicalLearnerPrimaryActionOrderRankV1(actionIdOf(right.$2)) ?? 99;
    if (leftRank != rightRank) {
      return leftRank.compareTo(rightRank);
    }
    return left.$1.compareTo(right.$1);
  });
  return indexed.map((entry) => entry.$2).toList(growable: false);
}
