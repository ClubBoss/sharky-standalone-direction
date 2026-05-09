const int kChipsStartPackCostV1 = 1;
const int kChipsCheckpointCompletionRewardV1 = 3;
const int kChipsNormalPackCompletionRewardV1 = 2;

class ChipsLedgerSnapshotV1 {
  const ChipsLedgerSnapshotV1({
    required this.balance,
    required this.earnedTotal,
    required this.spentTotal,
  });

  final int balance;
  final int earnedTotal;
  final int spentTotal;
}

class ChipsLedgerMutationV1 {
  const ChipsLedgerMutationV1({
    required this.before,
    required this.after,
    required this.requestedAmount,
    required this.appliedAmount,
    required this.insufficientFunds,
  });

  final ChipsLedgerSnapshotV1 before;
  final ChipsLedgerSnapshotV1 after;
  final int requestedAmount;
  final int appliedAmount;
  final bool insufficientFunds;
}

int chipsCompletionRewardForSessionV1({required bool isCheckpoint}) {
  return isCheckpoint
      ? kChipsCheckpointCompletionRewardV1
      : kChipsNormalPackCompletionRewardV1;
}

ChipsLedgerMutationV1 earnChipsV1(
  ChipsLedgerSnapshotV1 snapshot, {
  required int amount,
}) {
  final safeAmount = amount < 0 ? 0 : amount;
  if (safeAmount == 0) {
    return ChipsLedgerMutationV1(
      before: snapshot,
      after: snapshot,
      requestedAmount: amount,
      appliedAmount: 0,
      insufficientFunds: false,
    );
  }
  final next = ChipsLedgerSnapshotV1(
    balance: snapshot.balance + safeAmount,
    earnedTotal: snapshot.earnedTotal + safeAmount,
    spentTotal: snapshot.spentTotal,
  );
  return ChipsLedgerMutationV1(
    before: snapshot,
    after: next,
    requestedAmount: amount,
    appliedAmount: safeAmount,
    insufficientFunds: false,
  );
}

ChipsLedgerMutationV1 spendChipsV1(
  ChipsLedgerSnapshotV1 snapshot, {
  required int amount,
}) {
  final safeAmount = amount < 0 ? 0 : amount;
  if (safeAmount == 0) {
    return ChipsLedgerMutationV1(
      before: snapshot,
      after: snapshot,
      requestedAmount: amount,
      appliedAmount: 0,
      insufficientFunds: false,
    );
  }
  if (snapshot.balance < safeAmount) {
    return ChipsLedgerMutationV1(
      before: snapshot,
      after: snapshot,
      requestedAmount: amount,
      appliedAmount: 0,
      insufficientFunds: true,
    );
  }
  final next = ChipsLedgerSnapshotV1(
    balance: snapshot.balance - safeAmount,
    earnedTotal: snapshot.earnedTotal,
    spentTotal: snapshot.spentTotal + safeAmount,
  );
  return ChipsLedgerMutationV1(
    before: snapshot,
    after: next,
    requestedAmount: amount,
    appliedAmount: safeAmount,
    insufficientFunds: false,
  );
}
