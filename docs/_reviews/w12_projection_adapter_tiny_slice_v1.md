# W12 Projection Adapter Tiny Slice v1

## Verdict

`w12_projection_ready_no_route`

## Projection summary

- Source fixture:
  `content/worlds/world12/v1/sessions/w12.s01/campaign/w12.s01_campaign_fixture_v1.json`
- Pure projection helper:
  `lib/campaign/w12_campaign_fixture_projection_v1.dart`
- Target shape: `W12CampaignFixtureProjectionV1`, a non-registering immutable
  source-rep DTO.
- Projected rep count: six, in fixture/source order.
- Preserved fields: world/session/rep identity, source reference, visible
  state, learner prompt, legal choices, expected answer, target skill, error
  type, correct/incorrect feedback, repair cue, and telemetry-input intent.

The helper is deliberately not a route adapter. It proves deterministic source
shape without admitting the packet into the learner route.

## Boundary proof

- W12 remains non-routed.
- No `world12_` campaign registry row or canonical registration was added.
- No learner entry, progression behavior, UI, Modern Table, or telemetry schema
  changed.
- W13+ remains outside this slice.

## Checks

- `flutter test test/guards/w12_projection_adapter_contract_test.dart`: passed.
- Existing source and fixture guards: passed.
