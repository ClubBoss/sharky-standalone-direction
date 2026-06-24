# W11 Campaign Fixture Tiny Slice v1

## 1. Verdict

`w11_fixture_ready_no_route`

## 2. Fixture summary

- Fixture:
  `content/worlds/world11/v1/sessions/w11.s01/campaign/w11.s01_campaign_fixture_v1.json`
- Source packet:
  `content/worlds/world11/v1/sessions/w11.s01/w11.s01_deterministic_source_packet_v1.md`
- Rep count: six, in stable source order `w11.s01.r01` through
  `w11.s01.r06`.
- Mapping: one fixture object for each source packet rep, with the same
  contract fields and source reference.
- Distribution: three `fold` and three `continue` decisions.
- Skills: position/texture folding discipline, draw price, weak-draw restraint,
  player tendency, tight-strength recognition, and position/price/showdown
  continuation.

## 3. Source consistency proof

The fixture is a deterministic representation of the approved source packet.
The focused guard compares every fixture rep's identity, source reference,
visible state, learner prompt, expected answer, target skill, error type,
feedback, repair cue, and telemetry inputs against the source packet.

It also proves that every rep has the stable binary choices `continue` and
`fold`, and that the expected answer is one of those choices. No route action,
campaign registration, or runtime projection is invented by the fixture.

## 4. Boundary proof

- W11 remains source-owned and non-routed.
- No `world11_` campaign registry row or canonical registration was added.
- No learner entry, W10 handoff, progression behavior, UI, or Modern Table
  change was added.
- W12 remains planned; W13+ remains frontier-only.
- No commerce, paywall, trial, entitlement, AI, mastery, leak, or
  specialization behavior was added.
- No telemetry schema changed; the fixture retains only the existing source
  concepts: user choice, correct-or-incorrect, error type, time to decision,
  and source/rep identity.

## 5. Tests / guards

Added:

- `test/guards/w11_campaign_fixture_contract_test.dart`

The guard proves fixture existence, JSON shape, exact six-rep order, field
presence, source-packet equality, legal-choice and expected-answer safety,
non-empty skill/error identifiers, allowed telemetry inputs, forbidden wording
absence, and absence of a W11 campaign registration.

Existing foundation and W11 source guards remain in the validation set. These
guards do not prove a mapper, route admission, canonical registration,
learner-visible launch, result/progression behavior, or runtime rendering.

## 6. Deferred formatter baseline note

Repository-wide `dart format --set-exit-if-changed .` currently reformats
unrelated tracked files. This W11 slice intentionally uses touched-file
formatting only. Repository formatter-baseline cleanup remains a separate
hygiene decision and is not mixed with W11 source, fixture, or route work.

## 7. Next recommended wave

`W11 Projection Adapter Tiny Slice v1`

The fixture is ready. The next bounded question is how a test-only,
non-registering projection can preserve this source-owned shape before any
route-admission decision. It must not add a registry row, canonical admission,
learner entry, or W10 handoff.
