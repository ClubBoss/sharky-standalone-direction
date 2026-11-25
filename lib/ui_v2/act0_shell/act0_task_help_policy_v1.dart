/// Manual reference tools, not task answer generators.
enum Act0TaskHelpToolV1 { potOdds, blindUnits, outs }

/// Match the learner's actual prompt, not the lesson name, hidden hints,
/// feedback, or the answer options. A generic mention of a pot, BB or a draw
/// does not by itself make a calculator useful.
Set<Act0TaskHelpToolV1> act0TaskHelpToolsV1({
  required String question,
  required String context,
  bool hasExposedOpponentCards = false,
  bool canDraw = true,
}) {
  final text = '$question $context';
  bool has(String pattern) =>
      RegExp(pattern, caseSensitive: false).hasMatch(text);
  final priceMath =
      has(r'\bpot odds\b|\bcall (?:price|threshold)\b') ||
      (has(r'\bcall\b') &&
          has(
            r'breaks?[- ]?even|\b(?:winning|win) (?:chance|rate)\b|\bchance to win\b|'
            r'\b(?:call|bets?) \d+(?:\.\d+)?(?: BB)? into\b|\bcall divided by\b|\bequity\b',
          ));
  final numeric = has(
    r'\d|\bhow (?:much|many)\b|\bpercent(?:age)?\b|\bchance\b|\bthreshold\b|\bcalculat',
  );
  final callComparison =
      has(r'\bcall\b') &&
      has(r'\bfold\b') &&
      has(r'\d+(?:\.\d+)?\s*%|\b\d+ (?:time|times) in \d+\b');
  final outs =
      has(
        r'\bouts?\b|\bevery (?:flush|straight) wins\b|\ball other (?:rivers|turns) lose\b',
      ) &&
      (has(r'\b(?:chance|probability|percent(?:age)?|equity)\b|%') ||
          (has(r'\bcall\b') && has(r'\bfold\b')));
  // The outs reference assumes only hero cards and board are known.
  final knownOpponent =
      hasExposedOpponentCards ||
      has(
        r'\b(?:shows|exposes|face[- ]up|known opponent)\b|\b(?:suppose|assume) [^.!?]*\bholds\b',
      );
  final conversion =
      has(r'\b(?:BB|big blinds?)\b') &&
      has(r'\bchips\b') &&
      has(
        r'\bconvert\b|\b(?:BB|chips) (?:to|per|in) (?:BB|chips)\b|\bhow (?:many|much) (?:BB|chips)\b.*\b\d+(?:\.\d+)? (?:BB|chips)\b',
      );
  return {
    if ((priceMath && numeric) || callComparison) Act0TaskHelpToolV1.potOdds,
    if (conversion) Act0TaskHelpToolV1.blindUnits,
    if (outs && canDraw && !knownOpponent) Act0TaskHelpToolV1.outs,
  };
}

/// Do not expose a definition when recalling the definition is the task.
bool act0TaskHelpTestsDefinitionV1(String question) => RegExp(
  r'^\s*(?:what (?:is|are|does|do|makes|means)\b|which (?:term|definition|description|street|position|action)\b|what do you call\b|how (?:many|much)\b)|\b(?:mean|stand for)\?$',
  caseSensitive: false,
).hasMatch(question);
