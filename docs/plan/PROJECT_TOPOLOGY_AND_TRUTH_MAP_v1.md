# PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1
Status: ACTIVE
Purpose: primary orientation layer for future agents before repo investigation.

## How to use this map

- Read order:
  - `AGENTS.md`
  - this file
  - `docs/plan/MASTER_PLAN_v3.0.md` for active product-working route / block order
  - `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md` when the task concerns
    top-1 ambition, 10/10 product/commercial standard, Runout/competitor
    positioning, first-week proof, visible repair proof, or best-in-class
    product attack sequencing
  - `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md` only when launch/readiness reference is actually needed
  - `docs/plan/ACTIVE_APP_BOUNDARY_AND_DORMANT_SYSTEMS_v1.md` when the task risks drifting into legacy, persona, AI-coach, or non-Act0 families
  - latest Audit Hub surfaces if routing depends on fresh live truth:
    - `assets/audit_hub_v1/latest_run.json`
    - `assets/audit_hub_v1/operational_snapshot.json`
    - latest `out/audit_hub_v1/dossiers/project_status_dossier_*.md`
    - latest `out/audit_hub_v1/top_wave_packets/top_wave_packet_*.md`

- Do not do this first:
  - broad repo-wide recon
  - giant todo backlog building
  - reopening historical readiness docs as if active
  - routing from stale review packets without checking live Audit Hub freshness

- Fast next-frontier selection:
  - if the task is active product routing, use `docs/plan/MASTER_PLAN_v3.0.md` first
  - if the task is about becoming top-1 / 10 out of 10 / Runout benchmark /
    commercial-product attack path, use `docs/plan/MASTER_PLAN_v3.0.md` for
    day-to-day priority and `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
    for the top-1 operating map
  - if the task is post-route proof / "what still blocks product 100?", use
    `docs/plan/PRODUCT_100_PROOF_AUDIT_v1.md`
  - if the task is launch/readiness framing, use `docs/plan/MASTER_PLAN_v3.0.md` plus `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`
  - if the task is operator routing, check `latest_run.json` summary, then `completion_gap_synthesis`, `autonomous_block_handoff`, and latest dossier / top packet
  - if the task is runtime/debugging, start from the canonical runner boundary and only open legacy paths if a boundary contract proves they still own that seam

## 1. Source-of-truth hierarchy

- Strict priority order:
  1. `docs/plan/MASTER_PLAN_v3.0.md`
     - active product-working master plan
     - owns current route order, launch-shape priorities, and bounded-wave sequencing
     - companion layer: `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
       - companion strategy SSOT for top-1 / 10/10 product attack planning
       - owns Runout benchmark interpretation, 10/10 operating map, acceptance
         gates, and current visible-repair attack sequence
       - does not replace Master Plan, Monetization SSOT, readiness SSOT, or
         active route truth
  2. `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`
     - auxiliary launch-readiness reference
     - use for release/store-prep framing, not day-to-day bottleneck selection
  3. Historical execution references:
     - `docs/plan/ROUTE_TO_B_EXECUTION_RESET_v1.md`
     - `docs/plan/ROUTE_TO_B_ACTION_LADDER_v1.md`
     - historical stubs only; use when older prompts or references need traceability
  4. Subordinate readiness references:
     - `docs/plan/WORLD_READINESS_REGISTRY_v1.md`
     - `docs/plan/PRODUCT_SURFACE_READINESS_v1.md`
     - visibility layers only; they do not compete with the readiness SSOT
  5. Audit-Hub routing protocol:
     - `docs/ops/AUTONOMOUS_WAVE_PROTOCOL_SSOT.md`
     - use when interpreting live hub artifacts and normalized routing truth
  6. Release / ops governance reference:
     - `docs/release/operational_dashboard_governance_truth_v1.md`
     - canonical negative truth for dashboard ownership

- Routing vs readiness vs reference:
  - active product-working plan -> `docs/plan/MASTER_PLAN_v3.0.md`
  - near-term route / execution mode / wave sizing -> `docs/plan/MASTER_PLAN_v3.0.md`
  - post-route proof pass toward practical product `100 / 100` ->
    `docs/plan/PRODUCT_100_PROOF_AUDIT_v1.md`
  - launch/readiness framing reference -> `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`
  - deeper historical structure / reference context -> `docs/plan/MASTER_PLAN_v2.2.md`
  - archived execution-route context -> `docs/plan/archive/execution_history/`
  - operator live-route interpretation -> `docs/ops/AUTONOMOUS_WAVE_PROTOCOL_SSOT.md` + Audit Hub outputs

- Historical-only docs:
  - `docs/plan/TRUE_RELEASE_READINESS_SSOT_v1.md`
    - historical beta-path record only
    - never use for current scoring, rollout gating, or final-100 meaning
  - `docs/reference/history/Current Execution Context.md`
    - historical snapshot only

## 2. Runtime families

- Archived ModernTable & World1 Runner paths (Legacy):
  - Moved to `lib/archive/legacy_runners/`
  - `lib/archive/legacy_runners/modern_table_screen_v1.dart`
  - `lib/archive/legacy_runners/world1_foundations_microtask_runner_surface_v1.dart`
  - `lib/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart`
  - `lib/archive/legacy_runners/world1_modern_table_adapter_v1.dart`
  - These are preserved for compilation but are no longer active runtime surfaces.

- Legacy table path:
  - `lib/ui_v2/screens/drill_runner_screen.dart`
  - legacy table leaf: `lib/ui_v2/table/table_surface.dart`
  - older non-canonical shell / pack-play / training bridges remain around this family

- Where each is used:
  - canonical:
    - world1 canonical runner
    - canonical surfaced session-drill runner
    - launch-boundary -> terminal-surface learner paths
  - legacy:
    - explicit legacy drill compatibility
    - branch-only pack-play / training-session bridges
    - boundary-preserved legacy launch surfaces

- Canonical vs legacy-only:
  - canonical learner-facing runtime truth is the **Act0 shell route** (`lib/ui_v2/act0_shell/*`)
  - legacy paths (World1 runners, ModernTable) are archived and no longer active

## 2a. Active app boundary

- Current active learner-facing app truth is the Act0 shell route.
- Prefer these families first:
  - `lib/ui_v2/act0_shell/*`
  - `lib/ui_v2/app_root.dart`
  - `lib/ui_v2/ui_v2_beta_shell.dart`
- Treat these as dormant/non-route unless explicitly reopened:
  - `lib/ui_v2/persona/*`
  - `lib/ui_v2/ai_coach/*`
  - `lib/personalization/*`
  - `lib/ui_v3/*`
  - older non-Act0 learner surfaces that are not the current canonical entry path

## 3. Core runtime seams

- Runner surface:
  - `lib/ui_v2/runner/canonical_launch_boundary_runner_surface_v1.dart`
  - `lib/ui_v2/runner/canonical_terminal_runner_surface_v1.dart`
  - canonical top-level dispatch from launch family -> terminal family

- Runner authority:
  - `lib/ui_v2/runner/world1_canonical_runner_authority_v1.dart`
  - owns seat-quiz vs hand-loop mode and action-bar visibility truth

- Table render branch:
  - `lib/ui_v2/runner/world1_canonical_table_render_branch_v1.dart`
  - owns seat-quiz branch vs hand-loop branch for the table scene

- Modern table adapter:
  - `lib/ui_v2/runner/world1_modern_table_adapter_v1.dart`
  - converts runner state into `ScenarioSpecV1`, seat labels, pot/price labels, and selected/acting seat projection for `ModernTableScreenV1`

- Action-state derivation:
  - authority currently lives in `lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart`
  - key seam: `_campaignActionUiStateForCurrentStep()`
  - legal-action / `toCall` / decision-bar truth should be consumed from this seam, not recomputed ad hoc
  - action tap policy lives in `lib/ui_v2/runner/world1_canonical_host_action_bridge_v1.dart`

- Seat-quiz derivation:
  - `lib/ui_v2/runner/world1_canonical_host_interaction_state_adapter_v1.dart`
  - seat selection, seat-quiz resolution, retry / advance, and review-pass cursor truth
  - seat tap / check routing policy also flows through `world1_canonical_host_action_bridge_v1.dart`

- Session-drill scenario-state seams:
  - seat-context family -> `lib/ui_v2/runner/session_drill_canonical_seat_context_scenario_state_v1.dart`
  - hand-chain family -> `lib/ui_v2/runner/session_drill_canonical_hand_chain_scenario_state_v1.dart`
  - surfaced session runner should consume these canonical scenario-state seams instead of stitching fields inline

- Proxy tiers / where they live:
  - prompt / reveal proxy:
    - `lib/ui_v2/runner/runner_prompt_source_v1.dart`
    - `lib/ui_v2/runner/runner_reveal_payload_v1.dart`
    - `lib/ui_v2/runner/runner_host_prompt_reveal_presentation_v1.dart`
  - table spatial / canvas proxy:
    - `lib/ui_v2/runner/world1_canonical_table_spatial_scaffold_v1.dart`
    - `lib/ui_v2/runner/world1_canonical_overlay_lane_contract_v1.dart`
    - `lib/ui_v2/runner/world1_surfaced_table_scene_runtime_v1.dart`
  - seat / marker / action-token proxy:
    - `lib/ui_v2/runner/world1_canonical_seat_body_contract_v1.dart`
    - `lib/ui_v2/runner/runner_seat_state_badge_v1.dart`
    - `lib/ui_v2/runner/world1_canonical_action_token_contract_v1.dart`
  - board / pot / caption / portrait overlay proxy:
    - `lib/ui_v2/runner/world1_canonical_board_pot_body_contract_v1.dart`
    - `lib/ui_v2/runner/world1_canonical_felt_caption_contract_v1.dart`
    - `lib/ui_v2/runner/world1_canonical_portrait_overlay_contract_v1.dart`

## 4. Verification layers

- `dart analyze`
  - baseline static safety
  - protects type flow, imports, dead APIs, obvious breakage

- `./tools/fast_loop_world1_v1.sh`
  - default policy-gated loop
  - runs lint-tools + analyze + selected tier tests + optional validators / checkpoint contracts based on changed files
  - protects fast local regressions in the active runtime families

- `./tools/release_gate_world1.sh`
  - pre-PR gate
  - adds format check, forced fast-loop tests, content validation when needed, l10n generation when needed, optional full-suite by policy

- `./tools/checkpoint_world1_v1.sh`
  - checkpoint / before-merge gate
  - escalates into release gate checkpoint mode and full-suite when policy allows

- Validators / QA:
  - content / world validators under `tools/validate_*`
  - examples:
    - `tools/validate_world_content_v1.dart`
    - `tools/validate_world2_board_texture_truth_v1.dart`
    - `tools/validate_world2_board_tap_truth_v1.dart`
  - protect authored-content truth and structured content/runtime alignment

- Key contract test families:
  - canonical runner boundaries / ownership:
    - `test/guards/world1_canonical_terminal_surface_cutover_contract_test.dart`
    - `test/guards/canonical_runner_state_authority_contract_test.dart`
    - `test/guards/legacy_drill_canonical_terminal_cutover_contract_test.dart`
  - world1 runtime / shared shell / visual contracts:
    - `test/guards/world1_foundations_microtask_contract_test.dart`
    - `test/ui_v2/runner/world1_canonical_runner_authority_v1_test.dart`
    - `test/ui_v2/runner/world1_canonical_table_render_branch_v1_test.dart`
  - session-drill canonical state seams:
    - `test/guards/canonical_runner_state_authority_contract_test.dart`
    - `test/ui_v2/runner/session_drill_*_scenario_state_*`
  - hub / operator truth:
    - `test/tools/audit_hub_service_v1_test.dart`
    - `test/audit_hub_v1/audit_hub_operational_builder_v1_test.dart`
  - legacy boundary protection:
    - `test/guards/legacy_surface_route_guard_test.dart`
    - `test/guards/onboarding_legacy_bridge_boundary_contract_test.dart`
    - `test/guards/module_launcher_legacy_bridge_boundary_contract_test.dart`
    - `test/guards/legacy_training_*`

- What each layer protects:
  - analyze -> compile / API integrity
  - fast_loop -> active bounded-wave regression net
  - release gate -> pre-PR discipline
  - checkpoint -> merge-grade confidence
  - validators -> authored truth / content contract
  - guard tests -> runtime ownership, boundary integrity, anti-drift

## 4.1 Localization file model

- Act0 localization API / runtime seam:
  - `lib/ui_v2/act0_shell/act0_content_copy_v1.dart`
- Act0 RU language data:
  - `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart`
- Act0 file-model SSOT:
  - `docs/plan/ACT0_LOCALIZATION_FILE_MODEL_SSOT_v1.md`

Rules:

- do not scatter localized learner-facing copy back across screens
- do not treat the core Act0 copy API file as the place to hand-edit Russian
- for Act0, edit the language file or generated world packs, then flow changes
  back through the same stable-id tooling

## 5. Hub / control-plane truth

- Generator / owner:
  - `tools/audit_hub_service_v1.dart`
  - operational models / builder:
    - `lib/audit_hub_v1/audit_hub_operational_models_v1.dart`
    - `lib/audit_hub_v1/audit_hub_operational_builder_v1.dart`

- Core live files:
  - `assets/audit_hub_v1/latest_run.json`
  - `assets/audit_hub_v1/history_index.json`
  - `assets/audit_hub_v1/operational_snapshot.json`
  - human-readable latest surfaces under:
    - `out/audit_hub_v1/reviews/`
    - `out/audit_hub_v1/top_wave_packets/`
    - `out/audit_hub_v1/dossiers/`

- `remaining_to_100_routing_truth`
  - rendered in latest review exports and dossier
  - operator map for why repo is not at final `100/100`
  - not a competing scoring system
  - use for human-proof / external-owner / HOLD ceilings

- `completion_gap_synthesis`
  - field in `assets/audit_hub_v1/operational_snapshot.json`
  - summarized in `latest_run.json`
  - owns top machine frontier, recommended next frontier, and remaining-gap counts

- `autonomous_block_handoff`
  - field in `assets/audit_hub_v1/operational_snapshot.json`
  - summarized in review / dossier / top packet
  - tells you current active block, state, and whether there is an honest admit-now seam

- Project State / Next Steps / Progress surfaces:
  - Project State:
    - latest `out/audit_hub_v1/dossiers/project_status_dossier_*.md`
    - section: `Current Project State by Major Block`
  - Next Steps:
    - latest `out/audit_hub_v1/top_wave_packets/top_wave_packet_*.md`
    - use only if fresh and consistent with snapshot / latest run
  - Progress:
    - latest review export section `Progress Visibility`
    - `latest_run.json` summary / blockers / normalized results

- What operators should look at first:
  1. `assets/audit_hub_v1/latest_run.json`
     - run id, blockers, warning count, summary
  2. `assets/audit_hub_v1/operational_snapshot.json`
     - `completion_gap_synthesis`
     - `autonomous_block_handoff`
  3. latest dossier
     - human-readable project-state pass
  4. latest top wave packet
     - only if snapshot + latest run freshness agrees

## 6. Proven useful fix families already discovered

- inserted-action-beat seam
  - fixed: authored World2 seat loop staying correct after inserted action beats and maintaining correct highlighted seat progression
  - evidence anchor:
    - `test/guards/world1_foundations_microtask_contract_test.dart`
  - family type: authored-step / runtime-truth family

- board/canvas proxy tier
  - fixed: table canvas stability, board-state lane placement, and felt dominance instead of boxed / drifting portrait layout
  - evidence anchors:
    - `lib/ui_v2/runner/world1_canonical_table_spatial_scaffold_v1.dart`
    - `lib/ui_v2/runner/world1_canonical_overlay_lane_contract_v1.dart`
    - `test/guards/world1_foundations_microtask_contract_test.dart`
  - family type: geometry / scene-proxy family

- step-prompt proxy tier
  - fixed: duplicated / low-signal prompt ownership and prompt-vs-reveal drift
  - evidence anchors:
    - `lib/ui_v2/runner/runner_prompt_source_v1.dart`
    - `lib/ui_v2/runner/runner_host_prompt_reveal_presentation_v1.dart`
    - `lib/ui_v2/runner/world1_foundations_microtask_runner_surface_v1.dart`
  - family type: prompt / reveal proxy family

- felt-caption tier
  - fixed: mounted prompt vs fallback prompt vs outcome placeholder behavior on live felt
  - evidence anchors:
    - `lib/ui_v2/runner/world1_canonical_felt_caption_contract_v1.dart`
    - `test/ui_v2/runner/world1_canonical_felt_caption_contract_v1_test.dart`
  - family type: scene-caption proxy family

- portrait viewport tier
  - fixed: portrait dead space, overlay collisions, and non-dominant felt mass
  - evidence anchors:
    - `lib/ui_v2/runner/world1_canonical_portrait_overlay_contract_v1.dart`
    - `lib/ui_v2/runner/world1_canonical_table_spatial_scaffold_v1.dart`
    - `docs/plan/SURFACED_SESSION_HOST_PARAMETER_AUDIT_v1.md`
  - family type: portrait-layout / viewport-contract family

- seat-btn tier
  - fixed: seat semantic display, hero / action / folded badges, and button-seat readability instead of ad hoc seat rendering
  - evidence anchors:
    - `lib/ui_v2/runner/world1_canonical_seat_body_contract_v1.dart`
    - `lib/ui_v2/runner/runner_seat_state_badge_v1.dart`
    - `test/guards/deterministic_seat_tap_lane_v1_test.dart`
  - family type: seat-body / semantic-marker family

## 7. Known legacy traps / anti-drift notes

- Legacy-only paths still exist:
  - `lib/ui_v2/screens/drill_runner_screen.dart`
  - `lib/ui_v2/table/table_surface.dart`
  - `TrainingPackPlayScreen` / `TrainingSessionScreen` compatibility launch families

- Legacy-only boundary tests are intentional:
  - `test/guards/legacy_surface_route_guard_test.dart`
  - `test/guards/onboarding_legacy_bridge_boundary_contract_test.dart`
  - `test/guards/module_launcher_legacy_bridge_boundary_contract_test.dart`
  - `test/guards/legacy_training_explicit_payload_launch_contract_test.dart`
  - `test/guards/onboarding_legacy_completion_boot_parity_contract_test.dart`

- Update a legacy boundary test only after explicit contract verdict:
  - when ownership is intentionally changing across canonical vs legacy seams
  - when the route / bridge / launcher contract is deliberately rewritten
  - not because a local feature patch wants the old boundary out of the way

- Canonical-vs-legacy mismatch patterns:
  - canonical runner = launch boundary -> terminal surface -> shared learner shell -> embedded ModernTable
  - legacy runner = compatibility wrappers, legacy drill screen, or pack/session training bridges
  - do not import canonical runtime ownership directly into onboarding / branch-only / legacy training seams unless the contract changes on purpose

- Things agents must not assume:
  - no machine frontier does not mean final `100/100`
  - clean completion-gap counts do not erase human-proof / external-owner HOLD blockers
  - old beta-path docs are not active truth
  - a legacy screen still existing does not make it the runtime owner
  - closed seams should not be reopened without concrete new evidence

## 8. Execution rules for future agents

- One blocker family per wave.
- No broad red-state mapping by default.
- No giant todo backlog first.
- No `git reset`, stash churn, or history-recovery tricks unless explicitly requested.
- No human-proof counted as done.
- Machine-first until honest ceiling.
- Prefer class-of-issues fixes over local symptom fixes.
- Reassess after 1-2 waves or when the active readiness bottleneck changes.
- Start from canonical seams first; open legacy files only if a guard / boundary contract says that seam still lives there.
