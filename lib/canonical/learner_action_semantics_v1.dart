import 'package:poker_analyzer/engine_v2/model/action_v1.dart';

bool isCanonicalLearnerPreflopActionSpotV1({required bool isPreflop}) {
  return isPreflop;
}

ActionKindV1 canonicalizeLearnerActionKindV1({
  required ActionKindV1 kind,
  required bool isPreflop,
  required int toCall,
}) {
  if (kind == ActionKindV1.call && toCall == 0) {
    return ActionKindV1.check;
  }
  if (kind == ActionKindV1.bet && (isPreflop || toCall > 0)) {
    return ActionKindV1.raise;
  }
  if (kind == ActionKindV1.raise && !isPreflop && toCall == 0) {
    return ActionKindV1.bet;
  }
  return kind;
}

String canonicalizeLearnerActionTokenV1({
  required String token,
  required bool isPreflop,
  required int toCall,
}) {
  final normalized = token.trim().toLowerCase().replaceAll('-', '_');
  if (normalized.isEmpty) {
    return normalized;
  }
  if (normalized == 'call' && toCall == 0) {
    return 'check';
  }
  if (normalized == 'bet' && (isPreflop || toCall > 0)) {
    return 'raise';
  }
  if ((normalized == 'raise' ||
          normalized == 'raise_to' ||
          normalized == 'raise_min') &&
      !isPreflop &&
      toCall == 0) {
    return 'bet';
  }
  return normalized;
}
