class HandRank {
  const HandRank(this.rank);

  final int rank;
}

class HandEvaluator {
  const HandEvaluator();

  HandRank evaluate(List<Object> cards) {
    return HandRank(cards.length);
  }

  int evaluateHand(List<Object> cards) {
    return evaluate(cards).rank;
  }
}
