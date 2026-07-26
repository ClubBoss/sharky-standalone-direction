---
status: "undeclared"
status_source: "absent"
generated_by: "docs_frontmatter_v1"
---

# Stage 1B Wave A W5 Route / Content Truth v1

## Owner decision

Decision: `remove_from_active_content_truth_and_archive_defer`

W5.s11 Basic Outs Awareness is preserved as authored source under `content/worlds/world5/v1/sessions/w5.s11/`, but it is no longer active W5 content truth. No normal learner route, active W5 index, or active W5 manifest should claim W5.s11 as canonical playable W5 ownership.

## Before / after route truth

Before Wave A:

- Canonical route/progress already ended W5 at `w5.s10`.
- `content/worlds/world5/v1/sessions/index.md` still advertised `w5.s11`.
- `content/_meta/world_drills_manifest_v1.json` still advertised `w5.s11`.
- `content/_meta/world_sessions_manifest_v1.json` still advertised `w5.s11`.

After Wave A:

- Active W5 sessions are exactly `w5.s01` through `w5.s10`.
- W5 completion/calibration still occurs after `w5.s10`.
- W5 -> W6 bridge remains after W5 calibration and W5 followup rules.
- W5.s11 remains source-preserved but noncanonical/deferred.

## Files changed

- `content/worlds/world5/v1/sessions/index.md`
- `content/_meta/world_drills_manifest_v1.json`
- `content/_meta/world_sessions_manifest_v1.json`
- `test/guards/world5_campaign_routing_contract_test.dart`
- `test/guards/world5_early_runtime_truth_contract_test.dart`
- `docs/_reviews/stage_1b_wave_a_w5_route_content_truth_v1.md`

## W5.s11 authored-source treatment

No W5.s11 authored files were deleted or edited.

Retained source:

- `content/worlds/world5/v1/sessions/w5.s11/session.md`
- `content/worlds/world5/v1/sessions/w5.s11/notes.md`
- `content/worlds/world5/v1/sessions/w5.s11/drills/`

No explicit content-level deferred marker was added because the repo inspection found no required existing metadata mechanism for noncanonical retained source. The active ownership boundary is now enforced by the W5 index and both active content manifests.

## Why removal from active W5 truth is safe

W2 already teaches prerequisite outs/draw concepts before W5.s11:

- `content/worlds/world2/v1/sessions/w2.s10/drills/d.chain_texture_outs_action_v1.json`
- `content/worlds/world2/v1/sessions/w2.s13/drills/d.chain_texture_outs_continue_v1.json`
- `content/worlds/world2/v1/sessions/w2.s14/drills/d.chain_texture_outs_fold_v1.json`

Therefore W5.s11 is not required to prevent a W6 prerequisite break. Wave A does not route-admit W5.s11 and does not create an optional post-completion route.

## Completion and bridge proof

Canonical/progress files already owned the correct W5 boundary and were not edited for symmetry:

- `lib/canonical/canonical_truth_map_v1.dart` lists W5 canonical sessions as `w5.s01` through `w5.s10`.
- `lib/services/progress_service.dart` marks W5 calibration only after `w5.s01` through `w5.s10`.
- The W5 campaign guard still proves `w5.s10` completes W5 calibration.
- The W5 routing guard still proves campaign launch starts at `w5.s01` and advances through the canonical owned arc.

## Stale guard corrections

### `world5_campaign_routing_contract_test.dart`

Old expectation:

- The small-portrait test waited for map-era keys: `world_campaign_open_5`, `world_campaign_next_pack_cta`, or `map_render_fallback_v1`.

Current production truth:

- The current actionable W5 entry for this flow is the Today Plan CTA key `today_plan_start_cta` in `UniversalIntakePlanScreen`.

Why stale:

- The old assertion protected an older map/key surface and failed before reaching current W5 route actionability.

New regression prevented:

- Small portrait must still surface an enabled, visible W5 start CTA without weakening route-start assertions.

### `world5_early_runtime_truth_contract_test.dart`

Old expectation:

- `w5.s01` had exactly three active drills.

Current production truth:

- `w5.s01` has six active board-texture classifier drills.

Why stale:

- The guard lagged behind current W5.s01 source truth.

New regression prevented:

- The guard now protects the exact six active W5.s01 drills, active W5 session list `w5.s01` through `w5.s10`, absence of W5.s11 from active index/manifests, and preservation of W5.s11 source.

## Validation

Commands run:

- `python3 -m json.tool content/_meta/world_drills_manifest_v1.json`
- `python3 -m json.tool content/_meta/world_sessions_manifest_v1.json`
- exact active W5 session-count script over both manifests and `content/worlds/world5/v1/sessions/index.md`
- `flutter test test/guards/world5_campaign_routing_contract_test.dart test/guards/world5_early_runtime_truth_contract_test.dart`
- `flutter analyze test/guards/world5_campaign_routing_contract_test.dart test/guards/world5_early_runtime_truth_contract_test.dart`
- `git diff --check`
- `graphify hook-check`

Focused results at artifact creation time:

- Active W5 sessions: `w5.s01`, `w5.s02`, `w5.s03`, `w5.s04`, `w5.s05`, `w5.s06`, `w5.s07`, `w5.s08`, `w5.s09`, `w5.s10`
- Active W5 count: 10
- W5.s11 in active drill manifest: no
- W5.s11 in active session manifest: no
- W5.s11 source preserved: yes
- W6 active manifest sessions unchanged: `w6.s01` through `w6.s10`
- Focused W5 route/runtime guards: pass
- Targeted analyze on changed Dart guards: pass
- Diff hygiene and graphify hook check: pass

## Scope exclusions

Not changed:

- W5 learner-facing `w5.s01` through `w5.s10` drill content
- W5 expected actions
- W6 content or W6 route/copy guards
- W4 content
- repair architecture
- telemetry contracts
- Modern Table
- mascot/assets
- dependencies
- W7+
- Stage 1A files

Known out-of-scope stale guards remain deferred:

- `test/guards/world6_campaign_routing_contract_test.dart`
- stale W1 canonical cutover guard

## Wave B admission status

Wave A closes only W5 route/content truth. Wave B remains blocked until owner review of this artifact, then may be admitted as:

`stage_1b_wave_b_admitted_after_wave_a_review`

## Exact next owner action

Review Wave A and authorize Wave B feedback/action-model repair.
