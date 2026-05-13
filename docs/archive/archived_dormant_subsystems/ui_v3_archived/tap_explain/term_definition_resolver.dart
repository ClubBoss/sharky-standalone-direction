class TermDefinitionResolver {
  static const Map<String, String> _definitions = {
    "EQUITY": "Your chance to win the pot if all remaining cards are dealt.",
    "EV": "The long-term average result of repeating the same decision.",
    "POT_ODDS": "The ratio of the call price to the current pot size.",
    "IMPLIED_ODDS": "Future chips you expect to win when your hand improves.",
    "EQUITY_REALIZATION":
        "How much of your raw equity you actually convert by showdown.",
    "RANGE_ADVANTAGE":
        "When one range connects better to the board than the other.",
    "FREQUENCY":
        "How often you select a line to keep your strategy repeatable.",
    "VARIANCE": "The natural swings up and down even with correct play.",
    "SPR": "Stack-to-Pot Ratio, measuring stack depth relative to the pot.",
    "BLOCKERS": "Cards you hold that reduce opponent strong combinations.",
    "TILT": "Emotion-driven play that hurts decision quality.",
    "LEAK": "A repetitive mistake opponents can detect and punish.",
    "EXPLOIT": "A deliberate deviation to punish a known opponent leak.",
    "MERGE": "A range of medium-strength hands that target calls.",
    "POLARIZATION":
        "A mix of very strong hands and bluffs to pressure callers.",
    "PROBE": "A turn bet after a checked flop to seize initiative.",
    "OVERFOLD": "When opponents fold too often to your aggression.",
    "THIN_VALUE":
        "A small value bet sized to be called by slightly worse hands.",
    "RISK_PREMIUM":
        "Extra equity needed because busting costs more than winning.",
    "ICM": "Tournament math valuing chips by payouts instead of cash.",
    "BANKROLL": "The money set aside to absorb variance and stay in action.",
    "FOLD_EQUITY": "The chance an opponent folds to a bet or raise.",
  };

  static String? getDefinition(String term) {
    return _definitions[term.toUpperCase()];
  }
}
