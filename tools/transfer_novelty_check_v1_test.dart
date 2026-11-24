// Standalone Dart fixture check. Run this file directly.
import 'transfer_novelty_check_v1.dart';

TransferSpotV1 _spot({
  String cards = 'As Ks',
  double price = 3,
  String? handBucket = 'premium',
  List<String> actions = const ['call', 'fold'],
}) => (
  position: 'btn',
  price: price,
  thresholdBucket: 'above',
  handBucket: handBucket,
  actionSet: actions,
  answer: ['call'],
  spot: 'preflop',
  cosmetics: cards,
);

void main() {
  for (final (repeat, expected, missing) in [
    (
      _spot(actions: ['fold', 'call']),
      TransferNoveltyV1.paraphrase,
      <String>[],
    ),
    (_spot(cards: 'Ah Kh'), TransferNoveltyV1.cosmetic, <String>[]),
    (_spot(price: 4), TransferNoveltyV1.changedDecision, <String>[]),
    (_spot(handBucket: null), TransferNoveltyV1.unknown, ['repeat.handBucket']),
  ]) {
    final result = classifyTransferNoveltyV1(_spot(), repeat);
    if (result.classification != expected ||
        result.missing.join(',') != missing.join(',')) {
      throw StateError('Expected $expected with $missing, got $result');
    }
  }
  print('4 transfer novelty fixtures passed');
}
