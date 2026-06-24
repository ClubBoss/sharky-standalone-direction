# W11 Projection Adapter Tiny Slice v1

## 1. Verdict

`w11_projection_ready_no_route`

## 2. Projection summary

- Source fixture:
  `content/worlds/world11/v1/sessions/w11.s01/campaign/w11.s01_campaign_fixture_v1.json`
- Pure projection helper:
  `lib/campaign/w11_campaign_fixture_projection_v1.dart`
- Target shape: `W11CampaignFixtureProjectionV1`, a non-registering immutable
  campaign-rep DTO.
- Projected rep count: six, in fixture/source order.
- Preserved fields: world/session/rep identity, source reference, visible
  state, learner prompt, legal choices, expected answer, target skill, error
  type, correct/incorrect feedback, repair cue, and telemetry-input intent.

`MicroTaskStep` was not used as the target shape. It requires seat/action
execution semantics and lacks the W11 source, repair, and telemetry fields;
mapping `continue` to an active poker action would invent behavior. The pure
DTO proves the source projection without changing an active runner contract.

## 3. Source-to-projection consistency proof

The projection reads the fixture map only and has no side effects. The focused
guard proves all six reps project in stable source order, preserving binary
choices, expected answers, feedback, repair cues, error types, source identity,
and existing telemetry intent. The helper validates the fixture owner as
`world11` / `w11.s01` and rejects missing/non-string contract values.

No route action, active campaign ID, task completion, learner launch, or
progress mutation is created by the helper.

## 4. Boundary proof

- W11 remains non-routed.
- No `world11_` campaign registry row or canonical registration was added.
- No learner entry, W10 handoff, progression behavior, UI, or Modern Table
  change was added.
- W12 remains planned; W13+ remains frontier-only.
- No commerce, paywall, trial, entitlement, AI, mastery, leak, or
  specialization behavior was added.
- No telemetry schema changed.

## 5. Tests / guards

Added:

- `test/guards/w11_projection_adapter_contract_test.dart`

It proves fixture-to-projection order and field preservation, binary choice and
expected-answer safety, source/repair/telemetry preservation, no `world11_`
campaign registration, and no projection dependency on canonical, progression,
UI, W10, W12, or W13 seams.

Existing fixture, Foundation Rep Contract, and W11 source guards remain part of
the validation set. The guards do not prove runtime routing, canonical
admission, learner-visible launch, W10 handoff, result handling, or progression.

## 6. Formatter baseline note

Repository-wide formatter baseline cleanup remains deferred. This slice used
touched-file formatting only; it does not mix unrelated formatter changes with
W11 source or route work.

## 7. Next recommended wave

`W11 Route Proof Goal Pack v1`

The source packet, fixture, and pure projection are now independently proven.
The next step should decide the minimum route-admission evidence and ownership
requirements before any registry or learner-entry change is considered.
