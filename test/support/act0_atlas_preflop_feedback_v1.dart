// R1 checks for a stated consequence of the wrong answer. It is a text
// check. The poker truth and arithmetic of that consequence have their
// own guards.
const atlasPreflopFeedbackTargetV1 = 'Две трети неверных вариантов';
const atlasPreflopFeedbackScopeV1 = 'W2–W3';

// A value elsewhere in the explanation does not qualify a generic
// "look again". Require the amount in the same clause as the loss.
final _moneyAtRisk = RegExp(
  r'\b(?:costs?|risks?|pays?|paying|loses?|losing|saves?|saving|stakes?|spends?|puts?(?: in)?|putting in|commits?|matches?|matching)\b'
  r'[^.!?;]{0,36}\b(?:\d+(?:\.\d+)?\s*(?:bb|chips?|blinds?)|(?:one|two|three|four|five|six|seven|eight|nine|ten) (?:extra |more )?(?:chips?|blinds?))\b',
  caseSensitive: false,
);

final _statedLoss = RegExp(
  r"\b(?:gives? up|passes? up|misses?|forgoes?|surrenders?|concedes?|throws? away|hands? (?:the|your))\b"
  r"[^.!?;]{0,80}\b(?:pot|blinds?|chips?|stack|fold pressure|fold equity|equity|value|in.position|position|open|reraise|raise|call|check|flop|see|sees|observe|information)\b"
  r"|\b(?:(?:loses?|gives? up) fold pressure|loses? (?:big )?pots?|risks? (?:extra |more )?chips|out of position|first to act after the flop|count[s]?[^.!?;]{1,35}twice)\b"
  r"|\b(?:lets?|leaves?|invites?|offers?|gives?)\b[^.!?;]{0,55}\b(?:free|cheap(?:er|ly)?|raise behind|act behind|call with better hands)\b",
  caseSensitive: false,
);

final _spotFact = RegExp(
  r'\b(?:UTG|HJ|CO|BTN|SB|BB)\b'
  r'|\b\d+(?:\.\d+)?\s*(?:%)'
  r'|\b(?:one|two|three|four|five) players? (?:still |left to )?act'
  r'|\b(?:the|both) blinds\b',
);

bool atlasExplainsPreflopLossV1(String feedback) =>
    _moneyAtRisk.hasMatch(feedback) ||
    (_statedLoss.hasMatch(feedback) && _spotFact.hasMatch(feedback));

/// R1 measures the cohort as a whole. Integer arithmetic preserves the
/// two-thirds threshold for denominators that are not divisible by three.
int atlasPreflopFeedbackShortfallV1(int explained, int total) {
  if (total == 0) return 1;
  final required = (2 * total + 2) ~/ 3;
  return explained < required ? required - explained : 0;
}
