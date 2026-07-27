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
| `test/ui_v2/runner/world1_canonical_host_adapter_v1_test.dart` — `world1 canonical host adapter consumes canonical runtime config defaults` | explicit runtime config title, mode, start index, and hints | `canonical_terminal_host_contract_v1.dart` | replacement test 1 | `EXTRACTED_TO_CURRENT_OWNER` | exact title resolver, `campaign_spine`, index 3, and true hints pass without an archive import |
| `test/ui_v2/runner/world1_canonical_host_adapter_v1_test.dart` — `world1 canonical resolved host launch uses resolved mode and bootstrap flags` | mode, marker, chosen steps, initial index, four bootstrap flags | `world1_canonical_host_state_entry_adapter_v1.dart` | replacement test 2 | `EXTRACTED_TO_CURRENT_OWNER` | exact values pass |
| `test/ui_v2/runner/world1_canonical_host_adapter_v1_test.dart` — `world1 canonical host session identity tracks session reset inputs` | reset identity at indices 0 and 2 | `world1_canonical_host_adapter_v1.dart` | replacement test 2 | `EXTRACTED_TO_CURRENT_OWNER` | both exact identities pass |
| `test/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1_test.dart` — `early World 1 act0 packs resolve capability-aware payoff copy` | three exact payoff, status, and next-session families | `world1_foundations_runner_progression_chrome_adapter_v1.dart` | replacement test 3 | `EXTRACTED_TO_CURRENT_OWNER` | exact current adapter values pass |
| `test/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1_test.dart` — `campaign-pack adapter resolves canonical world1 chrome` | campaign title, status, payoff, and next session | progression chrome adapter | replacement test 3 | `EXTRACTED_TO_CURRENT_OWNER` | exact current adapter values pass |
| `test/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1_test.dart` — `campaign-pack runner surfaces canonical title and status chrome` | rendered campaign title, status, prompt, and old direct-widget keys | active `CanonicalLauncherV1` / `CanonicalTerminalRunnerSurfaceV1` route | replacement test 4 for title, status, and prompt; direct-widget key fixtures retired | `EXTRACTED_TO_CURRENT_OWNER` | current route renders exact title/status and prompt; the archive-era capsule/support keys are not rendered on that route |
| `test/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1_test.dart` — `campaign spine slice surfaces canonical prompt and support primitives from shared grammar` | grammar adoption plus direct-widget capsule/support key fixture | `shared_learner_host_grammar_v1.dart`; old direct screen fixture | replacement test 3 for grammar; rendered key fixture retired | `LEGACY_WIRING_RETIRED_AFTER_EXTRACTION` | pure grammar remains current; no weaker rendered proxy is claimed |
| `test/ui_v2/runner/canonical_terminal_world1_runtime_config_v1_test.dart` | Runtime payload instruction-source identity | archive-only public type surface | unchanged original carrier | Preserved unchanged; not admitted | retained in Tier B |
| `test/ui_v2/world1_foundations_runner_route_v1_test.dart` | Route-to-runner argument forwarding, including instruction-source identity | archive-only observable runner type | unchanged original carrier | Preserved unchanged; not admitted | retained in Tier B |

| Retired original path | Prior owner | Current owner | Replacement ledger | Manifest disposition | Evidence |
| --- | --- | --- | --- | --- | --- |
| `test/ui_v2/runner/world1_canonical_host_adapter_v1_test.dart` | Tier B maintained support | current host config/state owners above | three-test mapping above | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | all current assertion families map to replacement tests 1–2 |
| `test/ui_v2/runner/world1_foundations_runner_progression_chrome_adapter_v1_test.dart` | Tier B maintained support | current progression/grammar/launcher owners above | four-test mapping above | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | current semantics extracted; legacy key wiring explicitly retired |

The host-adapter mapping is complete across all three original tests. The
progression mapping separates current adapter/route semantics from the old
direct-widget fixture: `ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
is absent, and the only class implementation is under
`lib/archive/legacy_runners/`. The active canonical route reaches that
presenter through `CanonicalTerminalRunnerSurfaceV1`, but its actual rendered
surface has the exact title/status and prompt while not rendering the old
`microtask_runner_prompt_capsule_v1` or `microtask_scene_support_lane_v1`
keys. Those two key assertions are therefore retired legacy wiring, not
relabelled as current rendered proof. The two non-admitted carriers remain
unchanged: their instruction-source identity assertion stays in its original
carrier.

### Manifest transition and census

The two admitted originals moved from Tier B to Tier D with the existing
PHP-3 disposition `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED`. Tier B is 74;
Tier D is 43. The exact candidate paths therefore have admitted 3, unresolved
74, nine-path residual 74, and unexplained 0. No validator change is required:
the PHP-3A disposition model already accepts this atomic transition.

### Focused proof

- `flutter test test/ui_v2/runner/canonical_world1_host_route_contract_v1_test.dart -r compact`: 4/4 passed.
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

## 18. PHP-3C outside-handoff authority debt disposition

The full, independently reconciled 39-path record is
`docs/_reviews/php3_outside_handoff_failure_audit_v1.md`; this ledger does not
duplicate it. PHP-3 carrier accounting remains admitted 3, unresolved 74,
nine-path residual 74, unexplained 0.

| File | Prior authority | Current owner result | Scope result | Disposition | Evidence |
| --- | --- | --- | --- | --- | --- |
| `test/guards/world1_branch_unlock_contract_test.dart` | absent/unclassified outside-handoff guard | Progress Map-only assertion; canonical entry is Act0 | no current route seam | `ARCHIVED_NONCANONICAL_TEST_RETIRED` | absent Progress Map source |
| `test/guards/world1_checkpoint_locked_contract_test.dart` | absent/unclassified outside-handoff guard | Progress Map-only assertion; canonical entry is Act0 | no current route seam | `ARCHIVED_NONCANONICAL_TEST_RETIRED` | absent Progress Map source |
| `test/ui_v2/runner/world1_seat_quiz_feedback_copy_v1_test.dart` | Tier B maintained support | no live non-archive runtime importer; source retained as orphaned deferred debt | archive-only runtime consumer | `ARCHIVED_NONCANONICAL_TEST_RETIRED` | old `generic` enum expectation and stale copy mismatch |

The first two paths were not Tier-B members. The seat-quiz original moves from
Tier B to Tier D, and the validator accepts this exact archival disposition in
addition to current-owner extraction. This is not a replacement-test claim.

## 19. PHP-3 Wave 1 drill-decision safe-subset extraction

Starting baseline: `594529efdcc5714b3e874b898bf16e5a8437de54` (PR #65 merge).
The 28-title census and live-owner diagnostic are recorded in
`/tmp/PHP3_WAVE1_DRILL_DECISION_READJUDICATION_v2.md` (local evidence only).

| Retired original | Prior owner | Current owner | Replacement | Disposition | Evidence |
| --- | --- | --- | --- | --- | --- |
| `test/ui_v2/session_drill_player_initiative_contract_test.dart` | Tier B maintained support | canonical session-drill route | `test/ui_v2/runner/canonical_session_drill_initiative_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | Both titles run through `CanonicalLauncherV1.sessionDrill`; choice determinism, source facts, rendered feedback, supplements, recap, and progression are retained. |
| `test/ui_v2/session_drill_player_position_thinking_contract_test.dart` | Tier B maintained support | canonical session-drill route plus seat-context scenario-state owner | `test/ui_v2/runner/canonical_session_drill_position_thinking_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | Both titles run through the canonical launcher; street/player/seat source facts, folded and empty state, table presence, failure grammar, and progression are retained. The removed `modern_table_seat_empty_3` assertion was stale presentation wiring; the current source-empty contract and canonical seat-context scenario-state owner retain the semantic occupancy proof. |

The two board-texture and twenty-two bet-sizing titles remain Tier B. They are
not silently retired: their diagnostic failures require a separate bounded
owner packet. This PR admits two carriers, so PHP-3 arithmetic becomes admitted
`5`, unresolved `72`, residual `72`, unexplained `0`. No production or Modern
Table source changed.

## 20. PHP-3 Wave 1 authored-projection bounded repair and extraction

Starting baseline: `bb5f235b70ad2246c8b64a45dfd442fa42ec8281`.

| Retired original | Prior owner | Current owner | Replacement | Disposition | Evidence |
| --- | --- | --- | --- | --- | --- |
| `test/ui_v2/session_drill_player_world2_source_projection_contract_test.dart` | Tier B maintained support | canonical session-drill route | `test/ui_v2/runner/canonical_session_drill_world2_source_projection_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | canonical phone fixture, current bounded geometry, rendered cards/seat semantics, and ephemeral optional-defaults test fixture pass |
| `test/ui_v2/session_drill_player_world3_continuation_slice_contract_test.dart` | Tier B maintained support | canonical session-drill route | `test/ui_v2/runner/canonical_session_drill_world3_continuation_slice_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | continuation surface and three-step completion pass |
| `test/ui_v2/session_drill_player_world3_front_slice_contract_test.dart` | Tier B maintained support | canonical session-drill route | `test/ui_v2/runner/canonical_session_drill_world3_front_slice_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | front surface and three-step completion pass |
| `test/ui_v2/session_drill_player_world3_hand_chain_surface_contract_test.dart` | Tier B maintained support | canonical session-drill route | `test/ui_v2/runner/canonical_session_drill_world3_hand_chain_surface_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | rendered hand-chain progression passes |
| `test/ui_v2/session_drill_player_world3_tail_slice_contract_test.dart` | Tier B maintained support | canonical session-drill route and shared frame | `test/ui_v2/runner/canonical_session_drill_world3_tail_slice_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | supported 800x560 completion fixture passes with the shared top-region scroll repair and no overflow |
| `test/ui_v2/session_drill_player_world9_surface_contract_test.dart` | Tier B maintained support | canonical session-drill route | `test/ui_v2/runner/canonical_session_drill_world9_surface_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | current stacked seat IDs and non-duplicated blind-role presentation pass |

This admits six carriers. PHP-3 arithmetic is admitted `11`, unresolved `66`,
residual `66`, unexplained `0`. The only production repair is the shared-frame
overflow fix; Modern Table source is unchanged.

## 21. PHP-3 Wave 1 final interaction-owner extraction

Starting canonical baseline: PR #70 merge `9574b6c896b49069290c9189c0b3587c60377570`.
Starting arithmetic: admitted `11`, unresolved `66`, residual `66`, unexplained `0`.

Two independent inventory methods agree on the selected carrier list:

1. Tier-B manifest paths: `session_drill_player_board_tap_contract_test.dart`,
   `session_drill_player_seat_tap_contract_test.dart`, and
   `session_drill_player_projection_invariant_spine_contract_test.dart`.
2. Source title census: board tap (2), seat tap (2), projection invariant spine
   (1), for five ordered titles; source `expect` census is 17, 17, and 3,
   respectively, for 37 assertion calls.

| Retired original | Prior owner | Title/assertion family | Current owner and equal-or-stronger executable replacement | Disposition | Evidence |
| --- | --- | --- | --- | --- | --- |
| `test/ui_v2/session_drill_player_board_tap_contract_test.dart` | Tier B maintained support | symbolic board-slot feedback; authored World-2 board scene | `test/ui_v2/runner/session_drill_canonical_corrective_feedback_v1_test.dart` and `test/ui_v2/runner/session_drill_spatial_projection_contract_v1_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | current corrective feedback proves exact board-slot answer/notice grammar; spatial owner proves board-card payload gate |
| `test/ui_v2/session_drill_player_seat_tap_contract_test.dart` | Tier B maintained support | symbolic seat-role/id feedback; authored World-2 seat scene | `test/ui_v2/runner/session_drill_canonical_corrective_feedback_v1_test.dart` and `test/ui_v2/runner/session_drill_spatial_projection_contract_v1_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | current corrective feedback proves exact BTN answer/notice grammar; spatial owner proves seat-anchor payload and host gate |
| `test/ui_v2/session_drill_player_projection_invariant_spine_contract_test.dart` | Tier B maintained support | contradictory empty-blind truth is rejected before projected scenario render | `test/services/session_drill_projection_truth_invariant_spine_v1_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | current service owner proves coherent truth, empty villain rejection, and exact empty-blind rejection |

The original files directly import deleted screen/runner paths and cannot compile.
Their Modern Table callback inspection is retired wiring, not replaced with a
proxy. The public current owners above retain the behavioral contracts without a
Modern Table change, runner migration, or production change.

Final Wave-1 arithmetic: admitted `14`, unresolved `63`, residual `63`,
unexplained `0`. All three authorized extraction slots are consumed.

Focused current-owner tests, manifest validation, Phase-7 state guard, Tier A,
affected Tier B, analyzer, Graphify hook check, fast loop, and release gate
pass. The one terminal `flutter test test/ui_v2 test/guards` run reports two
unrelated pre-existing Wave-4 premium-copy failures in
`wave4_2_premium_identity_claim_cleanup_v1_test.dart`; neither owner nor test
is in this deletion-only diff. No broad test rerun is performed after this
ledger correction.

## 22. PHP-3 F-17 current-owner repair and manifest completeness closure

Starting baseline: PR #71 merge `2c640be080f4ab4cd25a9f03c82106c2aee981b7`.
The historical Wave-1 state is corrected to admitted `14`, unresolved `62`,
residual `62`, unexplained `0`; the PHP-3C non-admission retirement accounts
for the otherwise stale one-count narrative discrepancy.

The six F-17 `UNRESOLVED_UNIQUE_CONTRACT` guards below were absent from the
frozen F-15 inventory, but are current executable guards, not archive carriers.
Each is `CURRENT_CANONICAL_STALE_ASSERTION`: current source history replaced the
expectation, route, or copy while retaining the decision-controlling semantic.
They are added to Tier B as six distinct F-17 carrier keys; none is a
Tier-B-to-D extraction admission.

| File | Current owner | Current contract retained | Carrier key | Tier |
| --- | --- | --- | --- | --- |
| `test/guards/early_world_feedback_quality_family_contract_test.dart` | Act0 learner route (`Act0ShellPreviewScreenV1` → `Act0LessonRunnerShellV1` → `Act0CausalFeedbackV1`) | active wrong decision surfaces a non-generic reason, selected weaker response, preferred correction, and next-clue instruction; archived session-drill helper is not claimed as active owner | `F17:early-feedback-quality` | B |
| `test/guards/showable_spine_handoff_coherence_contract_test.dart` | progression route story + session result | active result prose resolves through the canonical story seam | `F17:showable-spine-handoff` | B |
| `test/guards/targeted_content_repairs_contract_test.dart` | active W5/W10/W11 content authorities | observational texture/connected-board and bounded W10 copy | `F17:targeted-content-repairs` | B |
| `test/guards/w10_to_w11_transition_policy_contract_test.dart` | W10→W11 policy + campaign registry | admitted W12 packs and no W13 unlock | `F17:w10-w11-transition-policy` | B |
| `test/ui_v2/session_summary_gold_containment_v1_test.dart` | Act0 session summary | gold containment, saved-read payoff, Sharky ceremony | `F17:session-summary-gold-containment` | B |
| `test/ui_v2/wave4_2_premium_identity_claim_cleanup_v1_test.dart` | Act0 feedback/session summary | no XP/Level economy, `Read banked`, `Local read saved` | `F17:premium-identity-proof-copy` | B |

No product, Modern Table, visual-system, or curriculum source changed. The
exact current text is supported by `e3b4eabd`, `44faa780`, and `57036376`; it
is not attributed to Wave-1 PRs #67, #70, or #71. Post-reconciliation
arithmetic is admitted `14`, unresolved `68`, residual `68`, unexplained `0`:
the six paths are newly ledgered residual guards, not extraction admissions.
The F-15 carrier population remains 77 (14 admitted + 62 residual + 1
non-admission archival retirement); adding six distinct F-17 keys produces a
total PHP-3-owned population of 83, with zero duplicate keys and zero missing
owned files. The nine session-drill Wave-2 carriers remain unmodified. PHP-4,
Human, Visual Completion, and Modern Table work remain unauthorized.

## 23. PHP-3 Wave 2 live session-drill extraction

Starting canonical baseline: PR #72 merge `8075e088cf15ab852917489b4e9a2b54d33b9204`.
Starting arithmetic: admitted `14`, unresolved `68`, residual `68`, unexplained `0`.

The nine retired files imported deleted screen/runner owners or inspected legacy
implementation callbacks. Their replacements pump `CanonicalLauncherV1.sessionDrill`
through the live session runtime; no production, Modern Table, visual-system, or
curriculum source changes are made.

| Retired original | Prior owner | Current owner | Replacement | Disposition | Evidence |
| --- | --- | --- | --- | --- | --- |
| `test/ui_v2/session_drill_player_hand_chain_contract_test.dart` | deleted screen owner | canonical session-drill route | `canonical_session_drill_world3_hand_chain_surface_contract_test.dart`, `canonical_session_drill_world3_continuation_slice_contract_test.dart`, and `canonical_session_drill_world3_tail_slice_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | live W3 early, continuation, and tail hand-chain table/action progression |
| `test/ui_v2/session_drill_player_runner_stress_benchmark_acceptance_test.dart` | deleted runner owner | canonical session-drill route | `canonical_session_drill_phone_quality_contract_test.dart` and `canonical_session_drill_world2_source_projection_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | live W2 phone prompt/table/support-lane order and no-overflow surface |
| `test/ui_v2/session_drill_player_seat_info_density_rendered_quality_test.dart` | deleted runner owner | canonical session-drill route | `canonical_session_drill_phone_quality_contract_test.dart` and `canonical_session_drill_world2_source_projection_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | live W2 phone seat label/state visibility; stale legacy chip geometry is not retained as a proxy |
| `test/ui_v2/session_drill_player_spatial_runtime_bundle_contract_test.dart` | deleted screen owner | canonical spatial projection | `session_drill_spatial_projection_contract_v1_test.dart` and `session_drill_canonical_spatial_scenario_state_v1_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | current spatial payload and scenario-state projection |
| `test/ui_v2/session_drill_player_world2_live_layout_contract_test.dart` | deleted screen/runner owner | canonical session-drill route | `canonical_session_drill_world2_source_projection_contract_test.dart` and `canonical_session_drill_phone_quality_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | live canonical W2 layout/source facts at phone size |
| `test/ui_v2/session_drill_player_world3_mid_tail_rendered_quality_test.dart` | deleted runner owner | canonical session-drill route | `canonical_session_drill_world3_continuation_slice_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | live W3 continuation progression |
| `test/ui_v2/session_drill_player_world3_tail_capstone_rendered_quality_test.dart` | deleted runner owner | canonical session-drill route | `canonical_session_drill_world3_tail_slice_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | live W3 tail completion |
| `test/ui_v2/session_drill_player_world9_exploit_synthesis_rendered_quality_test.dart` | deleted runner owner | canonical session-drill route | `canonical_session_drill_world9_surface_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | live W9 authored exploit synthesis and no-placeholder proof |
| `test/ui_v2/session_drill_player_world9_position_spatial_rendered_quality_test.dart` | deleted runner owner | canonical session-drill route | `canonical_session_drill_world9_surface_contract_test.dart` and `canonical_session_drill_phone_quality_contract_test.dart` | `EXTRACTED_TO_CURRENT_OWNER_AND_TOMBSTONED` | live W9 position markers and phone spatial truth |

Wave-2 candidate arithmetic is admitted `23`, unresolved `59`, residual `59`,
unexplained `0`, for the unchanged owned population of `83`. PHP-4 remains
conditional on this candidate's complete deterministic, review, and CI gates.

## 24. PHP-3 terminal Tier-B archive-import blocker disposition

Starting canonical baseline: PR #73 merge `633c9e2220a2b02c60020ff43a0aa16da857839c`.

The four remaining Tier-B compile blockers are retired to Tier D as
`ARCHIVED_NONCANONICAL_TEST_RETIRED`. They exercise dormant Modern Table,
deleted session-drill screen, or legacy result-screen owners, while the current
Act0/session-drill authority already owns the retained behavior. No production,
Modern Table, visual-system, or curriculum source changes are made.

| Retired original | Prior owner | Current owner | Current authority already covering the contract | Disposition | Evidence |
| --- | --- | --- | --- | --- | --- |
| `test/ui_v2/modern_table_entry_test.dart` | archive-only `ModernTableScreenV1` | Act0 route | Modern Table is maintenance-mode, not active authority | `ARCHIVED_NONCANONICAL_TEST_RETIRED` | archived import loads, then 21 legacy-surface assertions fail; no active importer |
| `test/ui_v2/session_drill_player_bet_sizing_contract_test.dart` | deleted session-drill screen and Modern Table | canonical session-drill route | current `DrillRuntimeAdapterV1` content contracts | `ARCHIVED_NONCANONICAL_TEST_RETIRED` | deleted screen imports prevent loading; canonical route owns active decision/feedback semantics |
| `test/ui_v2/session_drill_player_board_texture_contract_test.dart` | deleted session-drill screen and Modern Table | canonical session-drill spatial projection | corrective-feedback contracts | `ARCHIVED_NONCANONICAL_TEST_RETIRED` | deleted screen imports prevent loading; legacy table widget assertions are not active-route authority |
| `test/ui_v2/session_result_screen_contract_test.dart` | legacy result/runner and deleted session-drill owners | Act0 session-summary | canonical runner continuation contracts | `ARCHIVED_NONCANONICAL_TEST_RETIRED` | deleted screen and runner imports prevent loading; legacy result surface is outside the Act0 boundary |

After the four supplied dispositions, arithmetic is admitted `23`, unresolved
`55`, residual `55`, non-admission archival retirements `5`, unexplained `0`,
population `83`.
The complete Tier-B manifest has no archive/reference-only owner imports and
is eligible for the PHP-4 entry-gate validation.

## 25. PHP-3 terminal compile-census reconciliation

The complete Tier-B invocation also exposed four non-supplied compile-failing
carriers. Each is an obsolete map or legacy World-1 runner test, and each is
retired to Tier D as `ARCHIVED_NONCANONICAL_TEST_RETIRED`; no new carrier is
admitted and no product owner changes.

| Retired original | Prior owner | Current owner | Current authority | Disposition | Evidence |
| --- | --- | --- | --- | --- | --- |
| `test/ui_v2/runner/canonical_terminal_world1_runtime_config_v1_test.dart` | deleted World-1 runner types | canonical terminal host | canonical terminal runtime-config guards | `ARCHIVED_NONCANONICAL_TEST_RETIRED` | missing deleted types prevent compilation |
| `test/ui_v2/world1_foundations_runner_route_v1_test.dart` | deleted World-1 runner screen | canonical World-1 host route | `canonical_world1_host_route_contract_v1_test.dart` | `ARCHIVED_NONCANONICAL_TEST_RETIRED` | missing deleted types prevent compilation |
| `test/ui_v2/ui_v2_accessibility_touch_contract_test.dart` | deleted progress map | Act0 shell/settings owners | active Act0 accessibility and shell guards | `ARCHIVED_NONCANONICAL_TEST_RETIRED` | missing map import prevents compilation |
| `test/ui_v2_smoke_test.dart` | deleted progress map | Act0 shell and current module surfaces | active app-root/shell smoke guards | `ARCHIVED_NONCANONICAL_TEST_RETIRED` | missing map import prevents compilation |

Terminal PHP-3 arithmetic is admitted `23`, unresolved `51`, residual `51`,
non-admission archival retirements `9`, unexplained `0`, population `83`.
