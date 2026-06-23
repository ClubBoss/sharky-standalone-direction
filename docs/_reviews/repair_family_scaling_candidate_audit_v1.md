# Repair Family Scaling Candidate Audit v1

Date: 2026-06-23

Origin main after W6 resolution-policy audit push:
`c95cb07769968c578cef81d31a19f435cfc3031c`

Status: audit only.

## Scope / non-scope

This audit identifies the next highest-EV deterministic repair family that can
reuse the W6 receipt -> queue -> Review card -> targeted session-drill launch
infrastructure.

It does not implement product code, content, UI, route schema, telemetry,
queue resolution, one-drill result flow, Modern Table work, or Home/Practice
ranking.

## Current W6 proof chain

The current W6 proof chain is:

1. W6 `range_bucket_classifier_v1` miss produces a repair receipt candidate.
2. The persisted receipt is converted into an internal recheck candidate.
3. The candidate becomes a `SessionDrillRecheckLaunchQueueItemV1`.
4. Review can show a visible queue card for the first real queue item.
5. The CTA launches the canonical session-drill route with:
   - `sessionId == launchSessionId`
   - `initialDrillId == targetDrillId`
   - `isRecheckLaunchV1 == true`
6. The runner starts at the target drill and suppresses normal completion
   side effects for recheck launches.

The unresolved boundary remains queue/receipt resolution. Launch intent is not
learning success.

## Candidate family table

| Family | Classification | Existing error signal | Existing target identity | Route compatibility | UI/Review compatibility | Content/telemetry risk | Estimated EV | Recommended action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Board texture classifier (`board_texture_classifier_v1`) | `ready_for_mapping` | `board_texture_v1` plus `expected_action_mismatch`; evaluator and validators already support the kind. | Strong: 34 authored drills found across W2/W5, with concrete session ids and drill ids. Requires explicit target map. | Compatible with current `sessionId + initialDrillId + isRecheckLaunchV1` route contract. | Compatible with existing Review queue card pattern if copy stays generic by missed signal label. | Low-medium: no new content needed for first slice; no telemetry needed. | High: board read is early, visible, table-adjacent, and commercially legible. | Next implementation candidate: add board-texture receipt adapter/consumer/queue support for one narrow session slice, likely W5 s01 or W2 s04. |
| Same-signal action read (`action_choice`) | `needs_target_identity` | Many `action_choice` drills expose expected action and error class. | Weak as a generic family: 282 drills span many worlds and meanings. Needs a narrow subfamily owner before mapping. | Route compatible once a target drill is selected. | Compatible only if the signal label is precise; generic "action" risks noisy queue copy. | Medium: high risk of over-broad mapping and accidental content semantics. | High for first-week proof, but Act0 task repair already covers much of this value. | Do not map broad `action_choice`. Pick a small named subfamily later, for example W1 no-bet/facing-bet action read, if session-drill ownership is required. |
| Position read (`position_thinking_choice_v1`) | `needs_target_identity` | `position_thinking_choice_mismatch` gives a clean position signal. | Medium: 4 authored drills found in W2; enough for proof but thinner than board texture. | Route compatible once target map exists. | Review card can explain "position clue" without new UI. | Low-medium: likely no new content for a tiny proof, but target pairing must be authored. | Medium-high: position is beginner-critical and first-week-friendly. | Good second candidate after board texture; add only after board texture proves multi-family mapping pattern. |
| Price / pot-odds / bet sizing (`bet_sizing_choice_v1`, price-related action choices) | `needs_target_identity` | `bet_sizing_selection`, `tocall_legality_mismatch`, and price-copy drills exist. | Medium: many W1/W4 sizing drills and W2 price-related action choices exist, but they are not one clean family yet. | Route compatible once target map exists. | Queue card can show price/sizing signal, but copy must avoid dashboard/math overload. | Medium-high: term safety and concept timing are more sensitive. | Medium-high: price mistakes are high learning value, but more advanced than board texture. | Defer until one exact price family is selected and term/copy risk is checked. |
| Starting hand / preflop hand bucket (`hand_chain_v1` W3) | `needs_content_contract` | W3 hand-bucket copy and hand-chain steps exist. | Medium-low: target drills exist, but the signal is embedded in multi-step `hand_chain_v1` rather than a simple classifier receipt. | Route compatible, but target correctness inside a chain is more complex. | Review card could work, but mapping one chain step to a single missed signal needs a new contract. | Medium: likely needs chain-step receipt semantics. | Medium: important learning family, but less surgical than board texture. | Defer until chain-step receipt ownership is explicitly opened. |
| Table position / seat anchors (`seat_tap`, table-position reads) | `needs_target_identity` | Seat/anchor mismatch classes exist across W0/W1/W4/W9. | Medium: many repeat/focus drills exist, but semantics vary between onboarding, position, and table anchoring. | Route compatible once target map exists. | Review card may confuse table-location repair with strategy repair unless scoped tightly. | Medium: UI/copy ownership risk is higher. | Medium: useful, but less direct than board texture for poker decision proof. | Defer unless first-start/table-literacy repair becomes active priority. |
| Range bucket classifier (`range_bucket_classifier_v1`) | `ready_for_mapping` but already implemented | `range_bucket_v1` and evaluator support. | Strong: six W6 s01 drills and deterministic target map exist. | Already compatible and launched. | Already visible in Review. | Current limitation is resolution lifecycle, not mapping. | Proven proof-case. | Do not expand locally now; use it as the pattern for the next family. |
| Later depth, ICM, exploit, SPR, blocker families | `defer_low_ev` or `needs_content_contract` | Action choices exist in W7-W10, but terms and policies are later-world. | Mixed. | Route compatible only after target map. | Review copy would be less first-week-friendly. | Higher term/telemetry/content risk. | Lower for first-week proof. | Defer until core early families scale. |

## Top 3 candidate families

1. **Board texture classifier** — highest next EV. It has a clean classifier
   kind, evaluator support, validator support, concrete authored drills, and
   table-visible signal language. It can reuse the W6 route contract and
   Review card pattern with minimal conceptual change.
2. **Position read** — good second candidate. It has a clean signal but a
   smaller content base, so it should follow after board texture proves the
   multi-family adapter shape.
3. **Narrow action-read subfamily** — high product value, but only after a
   named subfamily is selected. Broad `action_choice` is too mixed to map
   safely.

## Rejected / deferred families

- Broad `action_choice`: too many worlds and error meanings; mapping all of it
  would create noisy queue semantics.
- Price / pot-odds / sizing: valuable but needs careful concept/term timing and
  a narrower selected family.
- Starting-hand / preflop bucket chains: likely requires chain-step receipt
  semantics before safe mapping.
- Table position / seat anchors: useful but can blur onboarding/table literacy
  with strategy repair unless explicitly scoped.
- W7-W10 depth/ICM/exploit families: later-world and higher copy/term risk.
- W6 range bucket: already mapped; current bottleneck is resolution lifecycle,
  not family selection.

## Recommended next implementation wave

`Board Texture Repair Receipt Mapping v1`

Recommended scope:

- Add one board-texture receipt adapter slice for an existing authored
  classifier session, preferably W5 s01 if W5 premium/depth scope is allowed,
  or W2 s04 if the next proof must stay earlier/free.
- Preserve the existing receipt -> consumer -> queue -> route contract shape.
- Add explicit deterministic source drill -> target drill mapping.
- Reuse `SessionDrillRecheckLaunchQueueItemV1` and Review queue-card copy via
  `missedSignalLabel`.
- Do not add queue resolution, telemetry schema, content expansion, route
  schema, Home/Practice ranking, or UI redesign.

First focused tests:

- board-texture miss creates a stable receipt candidate;
- supported board-texture receipt becomes a recheck candidate;
- candidate becomes a launch queue item preserving session/drill identity;
- unsupported/malformed/non-board receipts are ignored;
- current W6 range-bucket tests remain unchanged.

## Validation run

Required validation for this docs-only audit:

- `graphify hook-check`
- `flutter analyze`
- `git diff --check`
- `git status --short`

No product tests or screenshot commands are required because this audit changes
only this review note.
