# Foundation Campaign Rep Contract + W11 Packet Alignment v1

## 1. Verdict

`foundation_contract_and_w11_packet_ready`

## 2. Foundation contract summary

The Foundation Campaign Rep Contract defines the shared fields required before
a training rep can be route-backed: owned identity, visible state, prompt,
legal choices, expected answer, target skill, error type, feedback, repair
cue, and existing telemetry inputs. Answers must be explained by visible facts.

W7-W10 remain legacy-compatible deterministic implementations of this same
concept; a later adapter/test can prove field equivalence without replacing
their current registry-first owner. W11 is the first source-owned
implementation, so it is not a separate product mechanism.

## 3. W11 packet summary

- Packet: `content/worlds/world11/v1/sessions/w11.s01/w11.s01_deterministic_source_packet_v1.md`
- Rep count: six.
- The six `source_ref` values resolve to matching authored scenario anchors in
  `session.md`; the packet does not become a second, disconnected W11 source.
- Skills: position, player tendency, board texture, price, folding discipline,
  simple continue logic, and showdown value.
- Balance: three fold decisions and three continue decisions.
- Determinism: every rep states the observable situation, binary legal choice,
  expected target, error classification, visible-signal feedback, repair cue,
  and source/rep telemetry identity.

## 4. Poker correctness review

Each answer is tied to visible position, board, draw, price, player-tendency,
or action facts. The packet contains no hidden cards, ranges, or solver
assumptions. Continue decisions require a real draw, reasonable made hand, or
a specific small-price/tendency combination; fold decisions identify weak
draws, poor price, or a strong tight-player signal. No solver or GTO framing is
used.

## 5. Learning review

The six reps use one-focus transfer decisions with two simple legal choices.
They repeat the same observable loop without copying one spot: read the signal,
choose continue or fold, and re-check one concrete cue after an error. This
keeps cognitive load bounded while covering both overfold and overvalue errors.

## 6. Boundary proof

- No fixture JSON was added.
- No mapper or projection helper was added.
- No route registry, canonical registration, learner entry, or W10 handoff was added.
- W12 remains planned and W13+ remains later frontier.
- No commerce, paywall, trial, entitlement, AI, mastery, leak, or specialization claim was added.

## 7. Tests / guards

`test/guards/foundation_campaign_rep_contract_v1_test.dart` proves the shared
contract fields, exact six W11 rep identities, matching authored scenario
anchors, required per-rep fields, continue/fold vocabulary and balance,
non-empty error/repair fields, forbidden wording absence, and lack of a
`world11_` campaign registration. The existing W11 source guard remains
responsible for shelf structure, price-first focus, and non-registration.

These tests intentionally do not prove a fixture, projection, campaign pack,
canonical registration, learner entry, W10 handoff, or runtime behavior.

Validation passed: the foundation packet guard and existing W11 source guard
passed all three focused test cases; the term scanner, graph hook check, and
`flutter analyze` also passed.

## 8. Next recommended wave

`W11 Campaign Fixture Tiny Slice v1`

The packet now supplies reviewed deterministic facts that a future source-owned
fixture may preserve and validate before any route admission is considered.
