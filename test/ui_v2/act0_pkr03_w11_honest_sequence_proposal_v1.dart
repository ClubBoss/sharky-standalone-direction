// PKR-03 W11 honest-sequence PROPOSAL (test-side example only).
//
// Nothing here is product source. It does not change State, Runner, the order
// contracts or W1. It records, for the two W11 trigger hands, which facts the
// author already wrote and which trail items would be NEW. Adopting the new
// items is a new authored version of the scene and is the integrator's call.
//
// Sources read (main, read-only):
// - State trail of w11_trigger_small_price_continue / w11_trigger_bad_price_fold
// - their authored captions:
//   small: 'Six-handed, 0.25 BB ante each. CO opens to 2.5 BB, BTN calls with
//          QJs. Flop J-7-4 rainbow: CO bets 2 BB into 8 BB, with 35 BB behind
//          each.'
//   bad:   'Same hand again. BTN called 2 BB on J-7-4. Turn 2 is a brick; pot
//          is 12 BB and both started this street with 33 BB behind. Tight CO
//          rarely bluffs big turn bets and now bets 12 BB.'
// - seat flags: BTN is the button and Hero, SB/BB are the blind seats.
// - project blind profile 0.5/1 BB (price contract header); the ledger test
//   checks that this profile closes the authored pot exactly.

/// Where a step comes from.
enum W11ProvenanceV1 {
  /// Verbatim item of the authored State action trail.
  authoredTrail,

  /// Stated in the authored caption, absent from the trail.
  authoredCaption,

  /// Not written anywhere, but the only reading the authored facts allow.
  /// The `because` field names those facts; the ledger test proves it.
  forcedByAuthoredFacts,
}

enum W11VerbV1 { ante, post, fold, check, call, raiseTo, bet }

class W11StepV1 {
  const W11StepV1(
    this.street,
    this.seat,
    this.verb,
    this.provenance, {
    this.to,
    required this.label,
    this.isNote = false,
    this.because = '',
  });

  /// 'Preflop', 'Flop', 'Turn'.
  final String street;

  /// Seat label (UTG, HJ, CO, BTN, SB, BB) or 'ALL' for the ante note.
  final String seat;
  final W11VerbV1 verb;
  final W11ProvenanceV1 provenance;

  /// Street-total commitment after the action (raise/bet/call/post), or the
  /// per-player ante. Null for fold/check and for a call whose amount the
  /// ledger derives from the price.
  final double? to;

  /// Trail text the author would show. For authored items it is verbatim.
  final String label;

  /// Antes are dead money, not a turn: shown as a typed trail note.
  final bool isNote;
  final String because;

  bool get isNew => provenance != W11ProvenanceV1.authoredTrail;
}

const _anteBecause =
    "caption: 'Six-handed, 0.25 BB ante each'; no trail grammar for antes, "
    'so it is a note (the order contract skips notes)';
const _blindBecause =
    'SB/BB seat flags + project 0.5/1 BB profile; the pot ledger closes '
    'exactly at the authored 8 BB only with these posts';
const _firstInBecause =
    "caption: 'CO opens to 2.5 BB' = first in, so UTG and HJ folded before";
const _blindFoldBecause =
    "authored 'into 8 BB' = 1.5 antes + 0.5 + 1 + 2.5 + 2.5; any SB or BB "
    "call adds chips, and the caption has two players ('both', 'each')";

/// Shared preflop + flop-bet prefix of both scenes (one hand).
const w11HonestPrefixV1 = <W11StepV1>[
  W11StepV1(
    'Preflop',
    'ALL',
    W11VerbV1.ante,
    W11ProvenanceV1.authoredCaption,
    to: 0.25,
    label: 'Antes 0.25 BB each',
    isNote: true,
    because: _anteBecause,
  ),
  W11StepV1(
    'Preflop',
    'SB',
    W11VerbV1.post,
    W11ProvenanceV1.forcedByAuthoredFacts,
    to: 0.5,
    label: 'SB blind 0.5 BB',
    because: _blindBecause,
  ),
  W11StepV1(
    'Preflop',
    'BB',
    W11VerbV1.post,
    W11ProvenanceV1.forcedByAuthoredFacts,
    to: 1,
    label: 'BB blind 1 BB',
    because: _blindBecause,
  ),
  W11StepV1(
    'Preflop',
    'UTG',
    W11VerbV1.fold,
    W11ProvenanceV1.forcedByAuthoredFacts,
    label: 'UTG folds',
    because: _firstInBecause,
  ),
  W11StepV1(
    'Preflop',
    'HJ',
    W11VerbV1.fold,
    W11ProvenanceV1.forcedByAuthoredFacts,
    label: 'HJ folds',
    because: _firstInBecause,
  ),
  W11StepV1(
    'Preflop',
    'CO',
    W11VerbV1.raiseTo,
    W11ProvenanceV1.authoredTrail,
    to: 2.5,
    label: 'CO raises 2.5 BB',
  ),
  W11StepV1(
    'Preflop',
    'BTN',
    W11VerbV1.call,
    W11ProvenanceV1.authoredTrail,
    label: 'BTN calls',
  ),
  W11StepV1(
    'Preflop',
    'SB',
    W11VerbV1.fold,
    W11ProvenanceV1.forcedByAuthoredFacts,
    label: 'SB folds',
    because: _blindFoldBecause,
  ),
  W11StepV1(
    'Preflop',
    'BB',
    W11VerbV1.fold,
    W11ProvenanceV1.forcedByAuthoredFacts,
    label: 'BB folds',
    because: _blindFoldBecause,
  ),
  W11StepV1(
    'Flop',
    'CO',
    W11VerbV1.bet,
    W11ProvenanceV1.authoredTrail,
    to: 2,
    label: 'Flop: CO bets 2 BB',
  ),
];

/// w11_trigger_small_price_continue: BTN decides on the flop.
const w11HonestSmallPriceV1 = w11HonestPrefixV1;

/// w11_trigger_bad_price_fold: the same hand, BTN decides on the turn.
const w11HonestBadPriceV1 = <W11StepV1>[
  ...w11HonestPrefixV1,
  W11StepV1(
    'Flop',
    'BTN',
    W11VerbV1.call,
    W11ProvenanceV1.authoredTrail,
    to: 2,
    label: 'BTN calls 2 BB',
  ),
  W11StepV1(
    'Turn',
    'CO',
    W11VerbV1.bet,
    W11ProvenanceV1.authoredTrail,
    to: 12,
    label: 'Turn: CO bets 12 BB',
  ),
];

/// OPTIONAL second new authored change: size the authored 'BTN calls'.
/// A call is by definition the 2.5 BB price, so no fact is guessed, but the
/// visible label changes; it lets the strict proof and playback read it.
const w11SizedCallStepV1 = W11StepV1(
  'Preflop',
  'BTN',
  W11VerbV1.call,
  W11ProvenanceV1.forcedByAuthoredFacts,
  to: 2.5,
  label: 'BTN calls 2.5 BB',
  because: "replaces authored 'BTN calls': a call equals the 2.5 BB price",
);

List<W11StepV1> w11WithSizedCallV1(List<W11StepV1> steps) => [
  for (final s in steps) s.label == 'BTN calls' ? w11SizedCallStepV1 : s,
];

/// Remaining stacks at each decision, derived only from the captions:
/// turn start 33 behind each (bad caption) + 2 BB flop each = 35 at flop
/// start, which is how the small caption's '35 BB behind each' must read.
const w11HonestStacksAtSmallDecisionV1 = <String, double>{'CO': 33, 'BTN': 35};
const w11HonestStacksAtBadDecisionV1 = <String, double>{'CO': 21, 'BTN': 33};

/// Facts that stay unauthored after this proposal (never filled in here).
const w11StillUnauthoredV1 = <String>[
  'UTG, HJ, SB and BB stacks (they only need chips for their ante/blind)',
  'raise size of "Raise for protection now" (small price option)',
  'how antes are shown in the trail and counted by the playback pot',
  'whether the authored label "BTN calls" may be sized (optional variant)',
];
