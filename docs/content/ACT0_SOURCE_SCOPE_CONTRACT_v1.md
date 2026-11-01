# Act0 source scope contract v1

This is a source compatibility contract, subordinate to Master Plan v5 and the
live owner dispatch. It grants no poker, Human, native or release acceptance.

## Ownership and meaning

`Act0TableStateV1.scope` in `act0_shell_state_v1.dart` owns instructional intent:

- `unclassified`: no intent attested; hand-history consumers fail closed.
- `playedHand`: an authored hand context, **not a certificate of legal history**.
- `orientation`: seat/card recognition without a played action sequence.
- `explanation`: a diagram illustrating a relationship rather than a played hand.

The four authored base tables and their explicit exceptions classify the active
367 task tables as 317 hand contexts, 46 orientation frames and 4 explanations.
This is a context count, not 317 legal hands. `copyWith` and choreography frames
preserve scope. New independently constructed tables default to unclassified.

`Act0ActionTrailItemV1.note` preserves visible source text without making it an
executable action. The replay and choreography owners skip notes while retaining
original source indexes. Runner chip playback and derived action cues must not
execute notes or non-hand frames. A visible note containing poker verbs does not
change its type. A diagram with missing cards remains a diagram, not a malformed
completed showdown that can be repaired by inventing cards.

## Existing evidence boundaries

The replay contract's `isConsumerSafe` means parsable presentation context. It is
**not** legal actor order, round closure, stack/min-raise or payout validation.
PR #352 chronology and post-fold guards remain required. Removing 20 orientation
replays leaves two existing hand-context replays; it creates no new legal history.

The Runner's optional board-tap comparison requires five distinct physical board
cards, two physical Hero cards matching Hero's seat, and complete disclosures for
every source-live opponent. Physical cards cannot repeat across shown owners.
Incomplete or contradictory disclosures produce no computed comparison. Complete
disclosures use the existing poker solver and describe best shown hands/ties;
they do not establish terminal history, pot eligibility or payment ownership.

## Facts required before the other original Q0 DoDs can close

- PKR-02: source-owned current/prior street commitments, last full raise,
  stack caps at action time and which actors have already acted. A display label
  or a plausible synthetic short-all-in fixture cannot supply these facts.
- PKR-03: complete applicable actor participation/order, explicit street/round
  boundaries and terminal state. Missing folds must not be synthesized from pot
  size or a template's inherited flags.
- PKR-08: consistent live-hand disclosures and physical cards, independently
  supported terminal state, contributions/eligibility and actual payout claims.
  A best-hand comparison cannot award a pot or certify a source outcome.

No cards, folds, stacks, winners, payouts, task/choice IDs, grading, evidence or XP
are authored by this compatibility bridge. Owner-authored missing facts and
editorial contradictions require a separate source decision before full closure.
