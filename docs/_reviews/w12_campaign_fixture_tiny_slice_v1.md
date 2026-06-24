# W12 Campaign Fixture Tiny Slice v1

## Verdict

`w12_fixture_ready_no_route`

## Fixture summary

- Fixture:
  `content/worlds/world12/v1/sessions/w12.s01/campaign/w12.s01_campaign_fixture_v1.json`
- Source packet:
  `content/worlds/world12/v1/sessions/w12.s01/w12.s01_deterministic_source_packet_v1.md`
- Rep count: six, in stable source order `w12.s01.r01` through
  `w12.s01.r06`.
- Mapping: one fixture object for each source packet rep, with the same
  contract fields and source reference.

## Source consistency proof

The fixture is a deterministic JSON representation of the approved W12 source
packet. The focused guard compares identity, source reference, visible state,
prompt, expected answer, target skill, error type, feedback, repair cue, legal
choices, and telemetry inputs against the source packet.

## Boundary proof

- W12 remains source-owned and non-routed.
- No `world12_` campaign registry row or canonical registration was added.
- No learner entry, W11 handoff, progression behavior, UI, telemetry schema, or
  Modern Table behavior changed.
- W13+ remains outside this slice.
- No commerce, paywall, trial, future-access, solver, or route-completion claim
  was added.

## Checks

- `flutter test test/guards/w12_campaign_fixture_contract_test.dart`: passed.
- Existing W12 source guard: passed.
