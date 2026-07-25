---
status: "stage_1b_wave_d_closed"
status_source: "derived"
baseline: "206c9fdf9093"
generated_by: "docs_frontmatter_v1"
---

# Stage 1B Wave D — Minimum Same-Signal Repair v1

Status: `stage_1b_wave_d_closed`

Stage 1B status: `stage_1b_w4_w6_repairs_complete_pending_integration`

Branch: `codex/stage-1b-wave-d-minimum-same-signal-repair-v1`

Required base HEAD: `206c9fdf909328c62e041ad118b0691ff3829d06`

Implementation commit: `43db5c16` (`feat: add bounded Stage 1B same signal repair`)

## 1. Final verdict

Wave D closes the authorized minimum same-signal repair slice.

- W5 later board texture: one coherent dry-texture pair is implemented across
  the in-position application and capstone synthesis sessions.
- W6 range width: two exact concepts are implemented, `wider` and `narrower`,
  with two distinct active drills in each concept.
- W4 denial: the architecture-fit check passed and one denial-only direction is
  implemented through the existing receipt, persistence, consumer, queue,
  launch, retained-result, metadata, and Review projection seams.
- D0 W6.s01 authority remains unchanged: four strong/missed mappings pass and
  medium/weak remain ineligible.
- No content, manifest, route, schema, parser, evaluator, telemetry, UI,
  dependency, Modern Table, or W7+ production file changed.

The active-route capsule was stale for this branch, but the explicit mission,
the D0 review, live source, and tests are higher authority. No route decision
was inferred from the stale capsule.

## 2. D0 baseline preservation

The pre-change D0 lifecycle suite passed `50/50`. The post-change focused suite
passed the same D0 authority and lifecycle coverage inside an `84/84` run.

Preserved without modification:

- authored family: `range_bucket_board_fit_classifier_v1`;
- runtime kind: `DrillKindV1.actionChoice`;
- eligible signals: `range_bucket_strong`, `range_bucket_missed`;
- exact four strong/missed source-target directions;
- no receipt for `classify_medium_second_pair_fit` or
  `classify_weak_bottom_pair_fit`;
- no active repair use of obsolete W6.s01 stable IDs, family, or runtime kind.

W6.s01 content, index, mappings, and the D0 target table were not edited.
Range-width receipts use `range_width_classifier_v1` and cannot be consumed as
board-fit receipts.

## 3. W5 later-session inventory

All active W5.s02-W5.s10 board-texture classifiers are authored as
`board_texture_classifier_v1` and load as
`DrillKindV1.boardTextureClassifier`. The expected action and texture are
structured; the situational/table context is prompt-authored because these
rows contain no structured board-card state. Route activity is proven by the
active manifest and `DrillRuntimeAdapterV1.loadSessionDrills` in the Wave D
guard. Difficulty is not an authored field; session order is the only proxy.

The eight `hand_chain_v1` recap/checkpoint rows in s02-s07, s09, and s10 were
also inspected. They are multi-step recaps, not single-decision repair sources,
and remain ineligible. W5.s08 contains no chain row.

| Session | Stable ID / file under session `drills/` | Expected | Concept group | Repair status / partner | Difficulty and state |
| --- | --- | --- | --- | --- | --- |
| `w5.s02` | `classify_dry_discipline_high_card_raise_v1` / `d.classify_dry_discipline_high_card_raise_v1.json` | `raise`, `high_card` | dry/high-card discipline | deferred; none | early application; hybrid structured/prompt-authored |
| `w5.s02` | `classify_dry_discipline_paired_call_v1` / `d.classify_dry_discipline_paired_call_v1.json` | `call`, `paired` | paired boards | deferred; none | early application; hybrid |
| `w5.s02` | `classify_dry_discipline_trap_fold_v1` / `d.classify_dry_discipline_trap_fold_v1.json` | `fold`, `dry` | dry/wet texture | deferred; none | early application; hybrid |
| `w5.s03` | `classify_wet_protection_connected_call_v1` / `d.classify_wet_protection_connected_call_v1.json` | `call`, `connected` | connectivity/draw pressure | deferred; none | early application; hybrid |
| `w5.s03` | `classify_wet_protection_connected_raise_v1` / `d.classify_wet_protection_connected_raise_v1.json` | `raise`, `connected` | connectivity/draw pressure | deferred; none | early application; hybrid |
| `w5.s03` | `classify_wet_protection_wet_fold_v1` / `d.classify_wet_protection_wet_fold_v1.json` | `fold`, `wet` | wet/draw pressure | deferred; none | early application; hybrid |
| `w5.s04` | `classify_turn_shift_connected_raise_v1` / `d.classify_turn_shift_connected_raise_v1.json` | `raise`, `connected` | street change/connectivity | deferred; none | turn-shift application; hybrid |
| `w5.s04` | `classify_turn_shift_paired_fold_v1` / `d.classify_turn_shift_paired_fold_v1.json` | `fold`, `paired` | street change/paired | deferred; none | turn-shift application; hybrid |
| `w5.s04` | `classify_turn_shift_wet_call_v1` / `d.classify_turn_shift_wet_call_v1.json` | `call`, `wet` | street change/draw pressure | deferred; none | turn-shift application; hybrid |
| `w5.s05` | `classify_river_closure_connected_call_v1` / `d.classify_river_closure_connected_call_v1.json` | `call`, `connected` | street change/connectivity | deferred; none | river application; hybrid |
| `w5.s05` | `classify_river_closure_dry_fold_v1` / `d.classify_river_closure_dry_fold_v1.json` | `fold`, `dry` | street change/dry closure | deferred; none | river application; hybrid |
| `w5.s05` | `classify_river_closure_wet_raise_v1` / `d.classify_river_closure_wet_raise_v1.json` | `raise`, `wet` | street change/draw completion | deferred; none | river application; hybrid |
| `w5.s06` | `classify_in_position_connected_raise_v1` / `d.classify_in_position_connected_raise_v1.json` | `raise`, `connected` | connectivity/position | deferred; none | later application; hybrid |
| `w5.s06` | `classify_in_position_dry_raise_v1` / `d.classify_in_position_dry_raise_v1.json` | `raise`, `dry` | dry/wet texture | **eligible** -> `w5.s10/classify_texture_synthesis_dry_raise_v1` | later application -> capstone; hybrid |
| `w5.s06` | `classify_in_position_wet_call_v1` / `d.classify_in_position_wet_call_v1.json` | `call`, `wet` | wet/draw pressure/position | deferred; none | later application; hybrid |
| `w5.s07` | `classify_oop_connected_call_v1` / `d.classify_oop_connected_call_v1.json` | `call`, `connected` | connectivity/position | deferred; none | later application; hybrid |
| `w5.s07` | `classify_oop_dry_call_v1` / `d.classify_oop_dry_call_v1.json` | `call`, `dry` | dry/wet texture/position | deferred; none | later application; hybrid |
| `w5.s07` | `classify_oop_wet_fold_v1` / `d.classify_oop_wet_fold_v1.json` | `fold`, `wet` | wet/draw pressure/position | deferred; none | later application; hybrid |
| `w5.s08` | `classify_draw_completion_connected_call_v1` / `d.classify_draw_completion_connected_call_v1.json` | `call`, `connected` | draw completion/connectivity | deferred; none | draw-completion application; hybrid |
| `w5.s08` | `classify_draw_completion_dry_fold_v1` / `d.classify_draw_completion_dry_fold_v1.json` | `fold`, `dry` | draw completion/dry closure | deferred; none | draw-completion application; hybrid |
| `w5.s08` | `classify_draw_completion_wet_raise_v1` / `d.classify_draw_completion_wet_raise_v1.json` | `raise`, `wet` | draw completion/wet pressure | deferred; none | draw-completion application; hybrid |
| `w5.s09` | `classify_blocker_context_connected_raise_v1` / `d.classify_blocker_context_connected_raise_v1.json` | `raise`, `connected` | connectivity/blocker modifier | deferred; none | modifier application; hybrid |
| `w5.s09` | `classify_blocker_context_high_card_fold_v1` / `d.classify_blocker_context_high_card_fold_v1.json` | `fold`, `high_card` | high-card/blocker modifier | deferred; none | modifier application; hybrid |
| `w5.s09` | `classify_blocker_context_paired_call_v1` / `d.classify_blocker_context_paired_call_v1.json` | `call`, `paired` | paired/blocker modifier | deferred; none | modifier application; hybrid |
| `w5.s10` | `classify_texture_synthesis_connected_call_v1` / `d.classify_texture_synthesis_connected_call_v1.json` | `call`, `connected` | synthesis/connectivity | deferred; none | capstone synthesis; hybrid |
| `w5.s10` | `classify_texture_synthesis_dry_raise_v1` / `d.classify_texture_synthesis_dry_raise_v1.json` | `raise`, `dry` | synthesis/dry texture | **eligible** -> `w5.s06/classify_in_position_dry_raise_v1` | capstone -> later application; hybrid |
| `w5.s10` | `classify_texture_synthesis_wet_fold_v1` / `d.classify_texture_synthesis_wet_fold_v1.json` | `fold`, `wet` | synthesis/wet pressure | deferred; none | capstone synthesis; hybrid |

## 4. Exact W5 mappings

| Source | Target | Signal / family | Same-signal and distinctness proof |
| --- | --- | --- | --- |
| `w5.s06/classify_in_position_dry_raise_v1` | `w5.s10/classify_texture_synthesis_dry_raise_v1` | `board_texture_dry` / `board_texture_classifier_v1` | Both require the structured `dry` texture and expected `raise`; the target changes from an in-position application to full texture synthesis. |
| `w5.s10/classify_texture_synthesis_dry_raise_v1` | `w5.s06/classify_in_position_dry_raise_v1` | `board_texture_dry` / `board_texture_classifier_v1` | Same structured texture/action, different session, prompt, and route-depth context; never exact replay. |

Both targets are active in `content/_meta/world_drills_manifest_v1.json`, load
through the active runtime adapter, and use `same_signal_recheck`. W5.s11 is
absent from the active manifest and from all production repair mappings.

## 5. W6 range-width inventory

All six active rows are authored as `range_width_classifier_v1`, load as
`DrillKindV1.actionChoice`, use structured expected answers, and keep
prompt-authored comparison context. The active manifest and runtime adapter
prove route admission.

| Stable ID / file in `w6.s02/drills/` | Expected | Exact concept | Status / target | Drift check |
| --- | --- | --- | --- | --- |
| `classify_button_range_wider` / `d.find_btn_realize.json` | `wider` | BTN first-in includes more hands than UTG | eligible -> `classify_late_position_more_hands` | pure range width; no board fit, blocker, combo, action, synthesis, or W7 drift |
| `classify_late_position_more_hands` / `d.tap_turn.json` | `wider` | late position includes more hands than early position | eligible -> `classify_button_range_wider` | pure range width; no drift |
| `classify_continue_range_narrower` / `d.choose_call_realize.json` | `narrower` | continuing after an open filters the range | eligible -> `classify_big_blind_continue_narrower` | pure range width; no drift |
| `classify_big_blind_continue_narrower` / `d.find_bb.json` | `narrower` | BB continue versus early open is filtered | eligible -> `classify_continue_range_narrower` | pure range width; no drift |
| `classify_button_open_less_constrained` / `d.choose_raise_blocker.json` | `less_constrained` | constraint/variety, not exact wider answer | deferred; no distinct `less_constrained` partner | relabelling a wider row would erase answer semantics |
| `classify_utg_range_stronger_average` / `d.tap_flop_realize.json` | `stronger_on_average` | average range quality, not width direction | deferred; no distinct same-answer partner | using wider/narrower would drift concepts |

## 6. Exact W6 range-width mappings

| Source | Target | Expected answer / signal | Distinctness proof |
| --- | --- | --- | --- |
| `classify_button_range_wider` | `classify_late_position_more_hands` | `wider` / `range_width_wider` | BTN-vs-UTG comparison changes to late-vs-early position hand-count comparison. |
| `classify_late_position_more_hands` | `classify_button_range_wider` | `wider` / `range_width_wider` | Reverse direction preserves width answer while changing prompt and source identity. |
| `classify_continue_range_narrower` | `classify_big_blind_continue_narrower` | `narrower` / `range_width_narrower` | Generic continue-after-open comparison changes to BB-versus-early-open context. |
| `classify_big_blind_continue_narrower` | `classify_continue_range_narrower` | `narrower` / `range_width_narrower` | Reverse direction preserves filtering concept with a distinct prompt/source. |

The receipt family is `range_width_classifier_v1`. Consumer, queue, and
retained-result allowlists require the exact reviewed source-session,
source-ID, target-session, target-ID, and signal tuple. A forged
`less_constrained` near-match is rejected.

## 7. W4 architecture decision

Decision: `W4_denial_same_signal_repair_implemented`.

The fit check passed because the existing contract already carries world,
source session/ID, family, signal, chosen and expected action, target
session/ID, target kind, and error class. Existing persistence is world-neutral;
the consumer/queue/launcher are tuple-driven; retained results already support
source family and provenance; Review renders the shared queue item. The change
needed only exact family/session allowlist extension. There is no new framework,
schema, route type, dependency, generalized abstraction, or UI production edit.

Exact mapping:

| Source | Target | Expected / signal / family | Why same-signal and distinct |
| --- | --- | --- | --- |
| `w4.s02/choose_raise_denial` | `w4.s06/choose_raise_repeat` | `raise` / `denial_equity_charge` / `denial_action_choice_v1` | Source teaches naming denial and charging hands that can outdraw; target changes to visible overcards/draws while keeping denial-only raise logic. |

Only this direction is admitted. Value, bluff, protection, generic bet purpose,
generic sizing, and price/action-response rows remain rejected. A forged bluff
source using the denial family is rejected by consumer, queue, and retained
result guards.

## 8. Receipt, consumer, queue, launch, and retained-result proof

For every admitted mapping the focused guard proves:

1. A wrong non-acceptable answer is a hard evaluator failure.
2. The adapter emits schema `1`, exact source world/session/ID, family, signal,
   original choice, expected answer, exact target session/ID,
   `same_signal_recheck`, and evaluator error class.
3. Shared-preferences persistence serializes and reloads the payload, replacing
   only the same source receipt.
4. The family-specific consumer admits only an exact reviewed tuple.
5. `loadSupportedLaunchQueueItems()` creates
   `session_drill_recheck:<target-session>:<target-id>`.
6. `sessionDrillRecheckLaunchRouteV1` passes the target session/ID into the
   canonical session-drill route with `isRecheckLaunchV1=true`.
7. A target success or miss appends retained evidence with original source
   session, exact target, signal, source family, and source receipt key.
8. Canonical metadata resolves the exact tuple with `canonicalAtomId: null`,
   source-proven confidence, and no cross-family equivalence claim.

The existing Review shell consumes the shared supported queue, renders the
first real queue item with learner-safe signal/choice/expected copy, and routes
its CTA through the same exact-target launcher. Existing Review projection and
CTA tests passed. Retained evidence does not silently clear the receipt; the
current supported closure behavior keeps the repair visible and avoids false
mastery/resolution semantics.

## 9. Telemetry and provenance boundary

Available through existing receipt and retained-result state:

- original user choice;
- hard correctness/error result;
- source world, session, and stable ID;
- missed signal and learner-facing signal label;
- receipt family;
- exact target session and stable ID;
- source-to-target receipt key;
- recheck selected/expected answer;
- retained `success` or `miss` result.

Not available: a session-drill per-decision telemetry event or
time-to-decision. No telemetry subsystem or synthetic timing field was added.
This remains a known gap for the later consolidated W1-W6 audit. The current
evidence is deterministic local provenance, not AI personalization or telemetry
completeness.

## 10. Deferred families and exact reopen conditions

| Deferred family | Why deferred now | Reopen condition |
| --- | --- | --- |
| W5 wet texture | No bounded exact pair was needed after the dry pair closed minimum coverage; action differences add secondary-cue ambiguity. | Reopen if telemetry concentrates hard wet-texture errors, novice QA repeats the misunderstanding, or adjacent approved content creates a clearly paired same-answer target. |
| W5 connectivity | Several rows mix connectivity with position, blocker, street, or draw-completion cues. | Reopen if final AI-simulated QA finds a connectivity recovery failure or a future content wave creates a bounded pure-connectivity pair. |
| W5 paired/high-card | No admitted minimum pair with equal-depth same-signal proof. | Reopen on concentrated learner errors or a future adjacent active target with the same structured texture answer. |
| W5 street change / river closure | Street-transition meaning is entangled with final action and draw story. | Reopen if novice testing shows repeated failure to transfer across streets and two active rows can preserve one exact street-change signal. |
| W5 draw completion | Completion rows mix texture with whether draws arrived. | Reopen only after correctness/QA evidence names draw-completion repair as a bottleneck and a distinct active same-completion target exists. |
| W5 blocker-context modifier | The current rows deliberately add blocker context. | Reopen only in an approved blocker-modifier wave with exact source-owned same-signal targets. |
| W5 connected/wet synthesis | Minimum synthesis coverage is already represented by dry; other rows would broaden the slice. | Reopen if capstone QA finds a recovery failure or telemetry identifies these exact IDs. |
| W5 recap chains | Multi-step chain results do not map cleanly to the single-decision receipt. | Reopen only if the existing receipt architecture gains source-owned chain-step provenance in a separately authorized wave. |
| W6 `less_constrained` | Only one active row has this exact answer. | Reopen when a distinct active `less_constrained` range-width target exists. |
| W6 `stronger_on_average` | Range quality is not the admitted narrow/wide concept and has one row. | Reopen in a separately authorized range-quality family with a distinct same-answer target. |
| W6.s01 medium/weak board fit | D0 explicitly keeps these ineligible. | Reopen only when distinct active medium and weak board-fit targets exist. |
| W4 denial sizing | This wave admits denial action choice only. | Reopen only if error evidence identifies sizing recovery as the bottleneck and an exact same-size/same-purpose target is approved without schema or evaluator change. |
| W4 value/bluff/protection/generic purpose | Different concept families. | Reopen only through their own authorized family inventory and exact same-signal target proof. |

## 11. Obsolete-reference and scope checks

- Active W6 repair production contains zero exact obsolete W6.s01 stable IDs,
  zero quoted `range_bucket_classifier_v1`, and zero
  `DrillKindV1.rangeBucketClassifier` uses.
- W5.s11 has zero active manifest or production repair references.
- W7+ has zero repair targets.
- W4/W5/W6 learner content JSON changes: zero.
- Manifest/session-index changes: zero.
- New dependencies: zero.
- Modern Table changes: zero.
- Parser/schema/evaluator changes: zero.
- Route/progression changes: zero.
- Review UI production changes: zero.

## 12. Files changed

Production:

- `lib/services/board_texture_repair_receipt_mapping_v1.dart`
- `lib/services/canonical_source_target_metadata_v1.dart`
- `lib/services/session_drill_recheck_launch_queue_v1.dart`
- `lib/services/session_drill_repair_receipt_adapter_v1.dart`
- `lib/services/session_drill_repair_receipt_consumer_v1.dart`
- `lib/services/session_drill_repair_receipt_persistence_v1.dart`

Tests:

- `test/guards/stage_1b_wave_d_minimum_same_signal_repair_contract_test.dart`

Review:

- `docs/_reviews/stage_1b_wave_d_minimum_same_signal_repair_v1.md`

## 13. Focused tests and regressions

TDD evidence:

- Mapping guard observed RED: W5, W6, and W4 returned null receipts.
- Lifecycle guard observed RED at consumer admission, then retained-result
  admission.
- Metadata guard observed RED on the first missing W5 tuple.
- Fail-closed guard observed RED at consumer, queue, and retained-result
  admission for unreviewed near-matches.
- Each guard passed after the minimal existing-seam change.

Focused post-change run: `84/84` tests passed across:

- Wave D and D0 authority guards;
- W5 board-texture mapping and active route guards;
- W6 board-fit runtime and adapter regressions;
- evaluator;
- receipt adapter and persistence;
- consumer and queue;
- exact recheck launch;
- retained result;
- canonical metadata;
- Review projection and CTA.

One existing board-texture test printed a non-failing AssetManifest binding
warning; the command exited successfully with all tests passed. No stale
unrelated test failure affected this wave.

## 14. Validation

Passing at implementation checkpoint:

- pre-change D0 focused suite: `50/50`;
- post-change focused suite: `84/84`;
- `flutter analyze`: `No issues found`;
- `git diff --check`: passed;
- `git diff --cached --check`: passed before implementation commit.

Fresh final closure results:

- post-review focused suite: `84/84`;
- `flutter analyze`: `No issues found`;
- `git diff --check`: passed;
- `git diff --cached --check`: passed;
- `graphify hook-check`: passed;
- W4/W5/W6 content or active-meta changes: `0`;
- dependency changes: `0`;
- forbidden UI/runtime/content surface changes: `0`;
- W7+ repair targets: `0`;
- obsolete active W6 repair tokens: `0`;
- active W5.s11 references: `0`.

## 15. Stage 1B closure readiness and integration recommendation

Wave D is ready to close as `stage_1b_wave_d_closed`. The resulting Stage 1B
state is `stage_1b_w4_w6_repairs_complete_pending_integration`.

Recommended integration: review this artifact and the exact branch range from
`206c9fdf909328c62e041ad118b0691ff3829d06` through the final branch HEAD, then
integrate by the repository owner's normal non-force workflow. Do not push from
this wave.
