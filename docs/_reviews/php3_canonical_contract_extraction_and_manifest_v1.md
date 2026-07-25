# PHP-3 Canonical Contract Extraction and Manifest v1

## 1. Published starting baseline

- Published `origin/main`: `f3a40782194eb91595e9c36f235a3aa2314d2a90`.
- Latest admitted PR: `#61`.
- Candidate branch: `codex/php3a-scenario-seat-state-extraction-v1`.
- Production changes: none.

## 2. Frozen evidence source

The read-only frozen worktree
`/private/tmp/sharky-php3-canonical-contract-extraction-batch1-v1` supplied
the prior assertion mapping. Every mapping below was rechecked against this
published baseline; no frozen diff was copied.

## 3. Exact single carrier

`test/ui_v2/scenario_seat_state_contract_test.dart` was the sole processed
PHP-3 carrier. The other 76 handoffs remain untouched.

## 4. Original test titles

1. `ScenarioSpecV1 derives folded seats from zero stacks by default`
2. `ScenarioSpecV1 rejects impossible seat occupancy combinations`
3. `ScenarioSpecV1 round-trips optional blind-level authored state`
4. `ScenarioSpecV1 rejects impossible blind-level authored state`
5. `ModernTableScreenV1 distinguishes folded and empty seats`

## 5. Original assertion families

- Default zero-stack-to-folded normalization with the exact three-seat result.
- Invalid empty-hero and folded-positive-stack occupancy rejection with
  `throwsArgumentError`.
- Blind-level JSON round trip with exact seats, blinds, and ante values.
- Invalid duplicate blind seat and inverted blind amount rejection with
  `throwsArgumentError`.
- Folded-versus-empty legacy table widget keys and border-opacity rendering.

## 6. Current versus legacy semantics

The first four families are current `ScenarioSpecV1` engine correctness. The
widget family imports `lib/ui_v2/screens/modern_table_screen_v1.dart`, which is
absent from the published tree; its only source is the archived
`lib/archive/legacy_runners/modern_table_screen_v1.dart` surface. It has no
current learner-route owner and is retired as legacy wiring.

## 7. Current source owners

`lib/engine/scenario_replayer_fsm_v1.dart` owns all surviving semantics:
`resolvedSeatOccupanciesV1`, `validate`, `toJson`, `fromJson`, and blind-level
validation. Live non-archive consumers include the headless scenario validator,
session-drill projection services, and canonical spatial scenario-state owner.

## 8. Replacement search

`test/engine/scenario_replayer_fsm_integration_test.dart` covers deterministic
FSM outcome only; it does not cover the four extracted assertion families.
Current service tests cover specific projections, not this direct ScenarioSpec
contract. Therefore `test/engine/scenario_seat_state_contract_test.dart` is the
necessary new current-owner test. It is not added to Tier B because Tier B is
the frozen observed support inventory and its validator forbids extra entries.

## 9. Exact old to new assertion map

| Old family | New/current protection | Verdict |
| --- | --- | --- |
| zero-stack folded normalization | `test/engine/scenario_seat_state_contract_test.dart` test 1, exact three-entry occupancy list | equal |
| invalid occupancy combinations | replacement test 2, both invalid cases retain `throwsArgumentError` | equal |
| blind-level serialization | replacement test 3, all five exact fields retain round-trip assertions | equal |
| invalid blind-level state | replacement test 4, duplicate-seat/inverted-amount case retains `throwsArgumentError` | equal |
| folded/empty widget rendering | archived `ModernTableScreenV1` only; no active source owner | legacy-only retired |

Mapping completeness: complete. No current semantic was weakened.

## 10. Manifest transition

The original carrier is removed from Tier B and added to Tier D. The manifest
validator now recognizes a PHP-3 extraction ledger disposition in addition to
the existing PHP-2 deletion disposition; this is required so an authorized
PHP-3 Tier-B-to-D transition is not structurally impossible.

| File | Prior owner | Current owner | Replacement | Disposition | Evidence |
| --- | --- | --- | --- | --- | --- |
| `test/ui_v2/scenario_seat_state_contract_test.dart` | Tier B maintained support | `lib/engine/scenario_replayer_fsm_v1.dart` | `test/engine/scenario_seat_state_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | four exact current-engine families pass; widget remainder is archived-only |

## 11. Focused validation

- `flutter test test/engine/scenario_seat_state_contract_test.dart -r compact`:
  4/4 passed.
- `./tools/test_authority_validate_v1.sh`: passed; Tier B 76, Tier C 307,
  Tier D 41; no manifest overlap, missing ledger evidence, or unexplained
  historical disappearance.
- Original-retirement proof: the original path is absent, absent from Tier B,
  and present exactly once in Tier D.
- `flutter analyze`, `graphify hook-check`, `git diff --check`, Tier A, affected
  Tier B, `./tools/fast_loop_world1_v1.sh`, and
  `/opt/homebrew/bin/bash ./tools/release_gate_world1.sh`: passed.
- PHP-0/PHP-1 protection: the current reconstruction of the named protection
  owners passes 79 assertions. The brief's historical 82-test label has no
  executable command or file list at this baseline, so it is recorded as a
  provenance discrepancy rather than represented as 82.

## 12. Nine-path census

The published baseline is 77. The frozen 77-carrier inventory finds exactly
one absent candidate path—the retired original carrier—so the candidate
nine-path residual is 76.

## 13. Remaining unresolved count

Before admission: 77. Candidate residual: 76. Unexplained residual: 0.

## 14. No-weakening review

The new engine test preserves exact occupancy values, both negative cases,
every blind-level field, and exact failure types. The retired widget assertions
were not converted into a weaker proxy; their sole owner is archived.

## 15. Pilot verdict

Candidate prepared; required broader local gates passed. Clean-room review and
exact-head CI remain pending.

## 16. Context-cost record

- Budget selected / changed: light / no.
- Authority files read: supplied PHP-3A brief; campaign state; context router;
  PHP-2 terminal ledger; original carrier; manifest validator.
- Exploratory commands: baseline, manifest, owner, and replacement searches.
- Decision-changing commands: published SHA verification, exact Tier-B
  membership, source-owner search, and replacement-coverage comparison.
- Escalations: validator widened only because it otherwise permits PHP-2 but
  rejects the explicitly authorized PHP-3 atomic transition.
- Reopens after owner tracing: 0.
- Parallel conflicts avoided or found: frozen worktree used read-only; no
  overlapping mutable owner.
- Outcome: candidate prepared; focused test and manifest authority pass.
- One removable cost for the next comparable packet: retain this exact map.

## 17. PHP-3B World1 host/route contract family extraction

### Starting baseline and scope

- Published `origin/main`: `190721a5dfa86ad65b716c071fcc09371857d35f`.
- Latest admitted PR: `#62`.
- Candidate branch: `codex/php3b-world1-host-route-contracts-v1`.
- Starting PHP-3 counts: admitted 1, unresolved 76, nine-path residual 76,
  unexplained 0.
- Production changes: none. The only processed originals are the four named
  World1 carriers; the other 72 unresolved handoffs remain untouched.

### Carrier mapping and retirement decision

| Original carrier | Assertion family | Current owner | Replacement | Disposition | Evidence |
| --- | --- | --- | --- | --- | --- |
| `test/ui_v2/runner/world1_canonical_host_adapter_v1_test.dart` | World1 resolved launch mode, selected pack steps, bootstrap flags, and deterministic session identity | `lib/ui_v2/runner/world1_canonical_host_state_entry_adapter_v1.dart` and `world1_canonical_host_adapter_v1.dart` | `test/ui_v2/runner/canonical_world1_host_route_contract_v1_test.dart` test 1 | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | exact state and identity assertions pass |
| `test/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1_test.dart` | Early-pack payoff/status/next-session copy, campaign chrome, and shared grammar adoption | `lib/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1.dart` and `shared_learner_host_grammar_v1.dart` | replacement test 2 | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | exact progression/chrome assertions pass |
| `test/ui_v2/runner/canonical_terminal_world1_runtime_config_v1_test.dart` | Runtime payload instruction-source identity | archive-only public type surface | unchanged original carrier | Preserved unchanged; not admitted | retained in Tier B |
| `test/ui_v2/world1_foundations_runner_route_v1_test.dart` | Route-to-runner argument forwarding, including instruction-source identity | archive-only observable runner type | unchanged original carrier | Preserved unchanged; not admitted | retained in Tier B |

The two admitted mappings preserve every current-owner assertion family with
exact values. The two non-admitted carriers were not converted to a proxy: the
instruction-source identity assertion remains intact in its original carrier.
This is a bounded partial family extraction, not a claim that the archive-typed
route boundary has been repaired.

### Manifest transition and census

The two admitted originals moved from Tier B to Tier D with the existing
PHP-3 disposition `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED`. Tier B is 74;
Tier D is 43. The exact candidate paths therefore have admitted 3, unresolved
74, nine-path residual 74, and unexplained 0. No validator change is required:
the PHP-3A disposition model already accepts this atomic transition.

### Focused proof

- `flutter test test/ui_v2/runner/canonical_world1_host_route_contract_v1_test.dart -r compact`: 2/2 passed.
- The exact PHP-0/PHP-1 selection used by PR #62 (nine named files, 79
  assertions) passed after the Phase 7 state-label guard advanced from PHP-3A
  to PHP-3B.
- `flutter analyze`, Tier A, affected Tier B, `graphify hook-check`,
  `./tools/fast_loop_world1_v1.sh`, and
  `/opt/homebrew/bin/bash ./tools/release_gate_world1.sh` passed.
- Original retirement proof for each admitted carrier: source absent, absent
  from Tier B, and present exactly once in Tier D.
- The preserved carriers remain present in source and Tier B.

### Context-cost record

- Budget selected / changed: light / no.
- Authority and owner files read: supplied PHP-3B brief; campaign state;
  PHP-2 handoff ledger; PHP-3A ledger; the four carriers; current host,
  progression, grammar, and route owners; Tier B/D manifests and validator.
- Decision-changing finding: `RunnerInstructionSourceV1` is declared only in
  `lib/archive/legacy_runners/world1_foundations_microtask_runner_surface_v1.dart`.
- Reopens after owner tracing: 0. Production, CI, dependency, PHP-4, and Human
  scope remained untouched.
