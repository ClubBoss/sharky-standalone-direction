# W11 Campaign-Source Ownership Contract v1

## 1. Verdict

`campaign_source_contract_ready_no_code`

The future W11 campaign source owner is a reviewed, source-owned static fixture
beside the active W11 session. No fixture or mapper is implemented in this
wave: the current Markdown does not yet author the deterministic scene, choice,
target, error, and feedback fields needed to fill one truthfully.

## 2. Current blocker

W11 route admission stopped because the existing W7-W10 mechanism consumes
deterministic `MicroTaskStep` payloads while W11 has one prose micro-session.
The campaign registry can normalize authored beats to a 12-hand campaign, but
it cannot derive table state, legal actions, expected target, or feedback from
Markdown without inference.

The W7-W10 registry pattern is therefore insufficient as W11 content truth:
it is a runtime/bootstrap compatibility owner, not an authored-content owner.
Adding a W11 row there now would hard-code prompts, targets, and consequences
that have not been reviewed in the active W11 source.

## 3. Ownership options comparison

| Option | Owner | Determinism | Source truth | Testability | Risk | Decision |
| --- | --- | --- | --- | --- | --- | --- |
| Hard-code W11 pack in registry | `campaign_pack_registry_v1.dart` | High | Low | Medium | Manufactures campaign content in a non-source owner. | Reject. |
| Source-owned static fixture | W11 session `campaign/` folder | High | High | High | Requires one bounded fixture schema and review. | **Select.** |
| Markdown parser/generator | Parser plus Markdown conventions | Medium until grammar is mature | Medium | Medium | Broad parser, heuristic inference, and new architecture. | Reject. |
| Keep source-only | Existing Markdown only | High for non-route state | High | Low for routing | Leaves the route blocker unresolved. | Reject as next move. |
| Generic W11+ authored-session campaign system | New shared content/runtime layer | Potentially high | High | High after build | Broad refactor before one W11 proof. | Reject now. |

## 4. Recommended owner

The future authoritative campaign fixture path is:

`content/worlds/world11/v1/sessions/w11.s01/campaign/w11.s01_campaign_fixture_v1.json`

Its sibling `campaign/index.md` may describe fixture version and source review
status. The fixture is authored content: it owns concrete deterministic
campaign facts for `w11.s01`; the Markdown remains the learner-facing
micro-session narrative. A future read-only mapper may convert the reviewed
fixture to `MicroTaskStep` values at the existing campaign boundary.

No fixture or mapper exists now. The current source does not contain sufficient
facts to fill one without inventing table state or choices. This contract does
not register W11 because a fixture path is not a campaign pack, canonical
registration, route branch, or learner entry.

## 5. W11 rep-to-campaign mapping contract

Every fixture rep must have a stable `rep_id` such as `w11.s01.r01`, a matching
session ID, and a source reference to its reviewed Markdown rep/heading. Each
rep must author, rather than infer:

| Field group | Required authored fields |
| --- | --- |
| Identity | `rep_id`, `session_id`, `source_ref`, fixture version. |
| Visible signal | Signal kind plus exact seat/position, street, board, player cue, price, and any relevant card state. |
| Learner choice | Prompt, hint, bounded legal choice IDs/labels, and expected choice ID. |
| Correctness | Expected target, `error_type`, and deterministic evaluation rule. |
| Why | Factual correct explanation and specific incorrect explanation. |
| Repair | Recheck cue and one bounded next-similar-spot instruction. |
| Campaign projection | Required `MicroTaskStep` fields, including expected seat IDs, action data, context, tradeoff, consequence, and insight where the selected runner needs them. |
| Telemetry | Existing event owner inputs for `session_id`, future `pack_id`, `rep_id`, learner choice, correctness, error type, and time-to-decision. No telemetry schema change is authorized. |

The fixture may contain six reviewed source reps. The existing campaign
normalization behavior may later expand reviewed beats to the runner's
12-hand shape only if the mapper test proves that every expanded beat preserves
the originating `rep_id` and its exact authored target and feedback.

## 6. Drift prevention

Before route registration, add deterministic guards that fail when:

1. a W11 fixture rep lacks a matching `w11.s01` source reference;
2. a source rep required by the reviewed fixture has no fixture representation;
3. a fixture lacks required visible-state, choice, target, error, explanation,
   repair, or telemetry fields;
4. mapper output changes an authored target, legal choice vocabulary, or
   feedback text;
5. `world11_` appears in campaign IDs, canonical registrations, or
   `ProgressService` before fixture review and mapper tests are accepted;
6. fixture/source/route copy mentions W12 access, W13 unlock, Volume I
   completion, premium/trial/entitlement, AI, mastery, leak, or specialization.

The W11 source guard must continue to prove no W11 campaign row until these
new checks are deliberately introduced and the admission decision changes.

## 7. Future W11 route-proof DoD

Route proof may reopen only when all gates are true:

1. the W11 source-owned fixture is authored and independently reviewed for
   pedagogy and poker correctness;
2. fixture and mapper validation is green and deterministic;
3. campaign registry row is deliberately admitted from the reviewed mapper
   output, not hand-authored in the registry;
4. canonical campaign/session registration is admitted for the same pack and
   session IDs;
5. canonical Act0 learner entry is identified and tested;
6. W10 selected-track completion/handoff is either explicitly deferred or has
   an approved deterministic implementation;
7. route tests prove W12 remains planned, W13+ remains inaccessible, and no
   Volume I, commerce, AI, mastery, leak, or specialization claim appears.

## 8. Implementation performed, if any

No fixture or mapper skeleton was added. A skeleton with empty or invented
choice/target/state fields would look source-owned while hiding the same
content-truth gap. No runtime access changed; W11 has no campaign ID,
canonical registration, learner entry, or W10 handoff.

Validation passed: the focused W11 source guard (2 tests), term coverage
scanner, graph hook check, and `flutter analyze`. No fixture-owner test exists
because no fixture or mapper was added.

## 9. Next recommended wave

`W11 Campaign Fixture Tiny Slice v1`

That slice should author and independently review the bounded six-rep fixture
at the selected source path, add source/fixture consistency guards, and remain
non-routed. It must not add a registry row, learner access, or W10 handoff.
