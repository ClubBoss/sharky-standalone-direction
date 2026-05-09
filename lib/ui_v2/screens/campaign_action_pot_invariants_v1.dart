import 'package:meta/meta.dart';

@immutable
class CampaignActionPotTruthV1 {
  const CampaignActionPotTruthV1({
    required this.potTotal,
    required this.currentBet,
    required this.toCallBySeatId,
    required this.actingSeatToCall,
    required this.sumCommitted,
  });

  final int potTotal;
  final int currentBet;
  final Map<String, int> toCallBySeatId;
  final int actingSeatToCall;
  final int sumCommitted;
}

CampaignActionPotTruthV1 deriveCampaignActionPotTruthV1({
  required Map<String, int> committedBySeatId,
  required String actingSeatId,
}) {
  var sumCommitted = 0;
  var currentBet = 0;
  for (final amount in committedBySeatId.values) {
    final normalized = amount < 0 ? 0 : amount;
    sumCommitted += normalized;
    if (normalized > currentBet) {
      currentBet = normalized;
    }
  }

  final toCallBySeatId = <String, int>{
    for (final entry in committedBySeatId.entries)
      entry.key: _toCallForSeat(currentBet: currentBet, committed: entry.value),
  };

  final actingSeatToCall = toCallBySeatId[actingSeatId] ?? currentBet;
  return CampaignActionPotTruthV1(
    potTotal: sumCommitted,
    currentBet: currentBet,
    toCallBySeatId: toCallBySeatId,
    actingSeatToCall: actingSeatToCall,
    sumCommitted: sumCommitted,
  );
}

int _toCallForSeat({required int currentBet, required int committed}) {
  final normalizedCommitted = committed < 0 ? 0 : committed;
  final delta = currentBet - normalizedCommitted;
  return delta > 0 ? delta : 0;
}
