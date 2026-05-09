import 'money_state_v1.dart';

enum ActionKindV1 { fold, check, call, bet, raise }

class ActionV1 {
  const ActionV1({required this.actorId, required this.kind, this.amount});

  final PlayerIdV1 actorId;
  final ActionKindV1 kind;

  // For bet: chips to add on empty street.
  // For raise: raise-to target (total committed chips for actor on this street).
  final int? amount;

  @override
  bool operator ==(Object other) {
    if (other is! ActionV1) {
      return false;
    }
    return actorId == other.actorId &&
        kind == other.kind &&
        amount == other.amount;
  }

  @override
  int get hashCode => Object.hash(actorId, kind, amount);
}
