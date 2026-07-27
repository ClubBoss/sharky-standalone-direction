# Pre-Human Active-Route Visual Reality Reconciliation and Corridor v1

Status: **TERMINAL — dispatch, reconciliation, and three-wave corridor
publication.** Wave A is authorized by this document. Wave B and Wave C are
conditionally preauthorized per §7.

Authority: does not override `docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md` or
`docs/plan/MASTER_PLAN_v3.0.md`. This document reconciles the state file to
its true canonical HEAD, records fresh owner evidence (VRT-02), and supplies
the next authorized capability. It does not authorize Human Novice Proof,
PHP-9, Modern Table changes, or new Sharky art.

Baseline: exact final `origin/main` at mission start —
`20b7cc8d58f4ea9f9593adbbb37ed4757f358ed6` (PR #93, Wave V2 terminal
publication). Work performed in a clean detached worktree; the operator's
dirty checkout (uncommitted `.claude/settings.json`, `.gitignore`, `AGENTS.md`,
`CLAUDE.md` edits, and untracked `pptx-theater-cues/`, `tmp/`) was not read,
touched, or included in this dispatch.

## 1. Authority drift repair (R1 classification)

`docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md`'s **Canonical HEAD** field still
read `1da7d34833fc3254fa7ece6ba3ecd77b5cfc8d6b` (PR #92 product/evidence
merge) and its **Authority freshness** line still described "Wave V2 has a
fresh dispatch at this exact baseline," even though PR #93 (Wave V2 terminal
publication, `20b7cc8d`) had already merged on top of it. This is a **stale
pointer left by the terminal-publication PR itself** (the publication PR's own
merge SHA cannot be written into the state file before that PR exists — see
the state file's own "Update rule"), not a conflicting-authority defect. This
document performs that reconciliation (§9) as part of its own publication,
per the state file's stated update rule ("the next packet reconciles this
state file to that admitted merge SHA at mission start").

No standalone repair-only PR is created — the repair is folded into this
dispatch's publication PR, consistent with the corridor's "no standalone
dispatch PR per micro-packet" efficiency policy.

## 2. Packet R0 — Route and capture truth for VRT-02

### 2.1 Exact route identity

| Field | Value |
| --- | --- |
| Route id | Act0 lesson runner, active drill/practice step |
| Lesson | `lessonId: 'positions'` ("The 6 positions"), `taskId: 'positions_early_late'` ("Early vs late"), step 6 of 7 in the lesson's task sequence (`positions_review` is the next/7th task) |
| Runner content | `_earlyLatePositionRunner` (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:11489`), question `"Which seat is early preflop?"`, correct answer `utg`, distractor `btn` |
| Reused by | `_w3SeatOrderDecisionRunner`, `_w3EarlyLateOrderRepairRunner`, `_w3EarlySeatPressureRunner` (`act0_shell_state_v1.dart:13484-13549`) — the same seat-tap composition and instruction-card grammar recurs in a later World's position-pressure family, not only in the World-1 "positions" lesson |
| Semantic phase | `Act0LessonPhaseV1.drill`, `Act0LessonStepKindV1.practice` — a teaching-drill decision, not theory and not feedback |
| Renderer | `Act0LessonRunnerShellV1` (`lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`), seat rendering via `_SeatNodeV1` (line 10925) inside `Act0TableSceneV1` (line 5068) |
| Layout owner | The `runnerScreen` composition's `usesSharedActiveRunnerAllocation` branch (`act0_lesson_runner_shell_v1.dart:3184-3253`) — the same shared-allocation mechanism (`_sharedActiveRunnerTableHeightV1`, `buildRunnerActionDock()`) already implicated in Wave V1's S1 finding for other owner families |
| Table owner | `Act0TableSceneV1` / `_SeatNodeV1`, seat affordance via `_SeatVisualStateV1` and `_seatBorderColorV1`/`_seatRingColorV1` (lines 11435-11600) |
| Instructional-card owner | `_RunnerInstructionSlotV1` (line 3728) inside `buildRunnerStage()` |
| Interaction owner | Seat `onTap` wired through `_SeatNodeV1`; hint affordance rendered via the `'Need a hint?'` recall label (lines 2797, 2815, 2840) |
| Responsive branches | compact/tall/large via the same `usesSharedActiveRunnerAllocation` `LayoutBuilder` math; no seat-tap-specific branch exists separate from the generic runner layout |
| Reproduction seed | Navigate any drill task using `_earlyLatePositionRunner` or a `_w3*` derivative (e.g. lesson `positions`, task `positions_early_late`) on a compact-height device (owner screenshot is 402×874pt-class, iPhone-standard) |

### 2.2 Was this captured by Wave V1?

**No.** Wave V1's 11-group, 27-invocation recapture (§2 of the Wave V1 report,
`wave_v1_evidence_symptom_manifest_v1.json`) is exhaustive over its own
declared taxonomy, and that taxonomy never contained a group for **in-lesson,
campaign-pack-driven seat-tap drill content**. Concretely:

- The lane-#1 capture tool's "table read" and "table decision" surfaces
  (`normal_four_option_table_read`, `direct_table_decision`,
  `accessibility_feedback_after_answer`) all render `tableRunner`, which is
  built from `placementQuickCheckRunnerV1` (`tools/act0_real_text_surface_capture_v1.dart:1372`)
  — a synthetic placement-flow fixture, not `_earlyLatePositionRunner` or any
  `_w3*` seat-order runner.
- `_earlyLatePositionRunner`, `_w3SeatOrderDecisionRunner`,
  `_w3EarlyLateOrderRepairRunner`, and `_w3EarlySeatPressureRunner` have zero
  references anywhere under `tools/` or `test/` — confirmed by direct grep.
- Wave V1's own matrix table (`docs/plan/PRE_HUMAN_VISUAL_COMPLETION_STRATEGY_v1.md`
  §3) lists "Decision / theory / correct / incorrect feedback / repair /
  recheck" as covered by the `alpha_journey`/`presentation_closure` groups —
  both of which, per §2.2 of this document's own source inspection, use
  synthetic fixture runners for their table-decision states, not live
  campaign-pack lesson content.

### 2.3 Classification

**CAPTURE_COVERAGE_GAP combined with MANIFEST_CLASSIFICATION_GAP.** This is
not a `MULTIMODAL_REVIEW_MISS` — there was nothing to multimodally review,
because the capture taxonomy itself has no category for "live in-lesson
seat-tap drill decision," so no lane-#1 image of this exact state has ever
existed. It is also not simply `PREVIEW_TO_RUNTIME_PARITY_GAP` — the
composition owner (`usesSharedActiveRunnerAllocation`) is identical in
preview and runtime; the gap is upstream, in what the acquisition manifest
was ever told to capture.

**Root confirmation of the owner-observed symptoms, verified in source, not
assumed from the screenshot alone:**

- **"Large unused lower viewport"** — matches the `usesSharedActiveRunnerAllocation`
  branch's `lowerSurfaceDemand` math (`act0_lesson_runner_shell_v1.dart:3200-3224`):
  the table height is derived from available width first, and the lower dock
  receives only the *remainder*; when the lower content (one instruction line
  + one hint pill) is shorter than that remainder, the leftover space is not
  reclaimed. This is the same "weak vertical-allocation grammar for
  low-content branches" root cause Wave V1 named for S1 (`PRE_HUMAN_VISUAL_COMPLETION_WAVE_V1_REPORT_v1.md`
  §6), now confirmed in a **third, independently-owned** owner family (the
  lesson-runner action dock, distinct from the Review zero-state and
  onboarding/welcome families S1 already covered).
- **"Selectable seats do not read as sufficiently obvious response
  controls"** — confirmed in `_SeatNodeV1`: `shouldShowRing` is explicitly
  `false` for `_SeatVisualStateV1.selectable` (line 10993-10995), identical to
  `passive` (non-interactive) seats; selectable seats are distinguished from
  passive ones only by a border-color token change
  (`_seatBorderColorV1`, line 11581), not by the ring/glow treatment used for
  `hero`/`activeFocus`/`targetFocus` states. This is a genuine,
  code-verifiable interaction-affordance defect, not a subjective read of one
  screenshot.
- **"Table and instructional region form separate visual islands"** — the
  `_RunnerInstructionSlotV1` (instruction card) and `Act0TableSceneV1` (table)
  are siblings inside `buildRunnerStage()`, laid out with independent
  backgrounds/containers and no shared visual grammar connecting them (no
  shared card boundary, connecting rail, or zone transition) — consistent
  with the owner's "two visual islands" read.

## 3. Packet R1 — Active learner-surface reality matrix (bounded)

Full recapture of every row is out of this mission's token budget and is not
required — Wave V1 already fresh-captured 11 groups / 27 invocations at a
recent baseline and found **zero** new symptoms outside S1 in: home, learn,
learn_detail, practice, profile, review (non-empty), first_week, day2_return,
profile_evidence, full_scroll, active_route_w7_w12, w2. That evidence is
reused here rather than re-derived (Wave V1 report §2, §6). Wave V2 then
closed S1 for its two evidenced owner families (Review zero-state, onboarding/
welcome) per the Wave V2 report. This document's incremental contribution is
the row Wave V1's taxonomy structurally could not reach:

| State | Status | Evidence basis |
| --- | --- | --- |
| Theory (preceding `positions_early_late`) | Not independently re-captured this mission; same `runnerScreen` composition family | Source inspection only (§2) |
| **Seat-selection decision (VRT-02)** | **New symptom confirmed** — dead space + weak seat affordance + visual-island separation | Owner screenshot + source verification (§2.3) |
| Action-selection decision (4-option table read) | Captured by lane #1 (`normal_four_option_table_read`), passes structurally; **uses a synthetic runner, not live lesson content** — same acquisition blind spot as VRT-02's family | `wave_v1_evidence_symptom_manifest_v1.json` |
| Correct feedback | Captured (`correct_feedback`) | Wave V1 manifest |
| Incorrect feedback / repair (long-copy) | Captured (`long_copy_repair_feedback`), S3 closed `STALE_FIXTURE` | Wave V1 report §4 |
| Recheck | Not independently captured this mission | Inherited from repair/feedback composition family |
| Session summary / recovered result | first_week/day2_return groups, zero new symptoms | Wave V1 manifest |
| Return to Learn | `core` group (home/learn), zero new symptoms | Wave V1 manifest |
| Review repair entry | `review_return` group, zero new symptoms | Wave V1 manifest |
| Compact state requiring scroll | `long_copy_repair_feedback` (S3, closed) | Wave V1 report §4 |
| 1.4x text state | `presentation_closure` 1.4x variant, no new symptom reported | Strategy doc §3 |

Device classes: compact/tall/large already exercised for the reused
composition family by Wave V1 for its sibling states; VRT-02 itself is
reproduced on a compact-class device per the owner screenshot. This matrix is
declared **bounded but sufficient** to answer the mission question — it does
not claim full-route re-audit, and none is asserted.

## 4. Packet R2 — Systemic root-cause reconciliation

| Symptom | Root cause | Owner family | Breadth | Systemic repair option |
| --- | --- | --- | --- | --- |
| Dead/unused lower viewport in VRT-02 | Weak vertical-allocation grammar for low lower-content demand (same class as Wave V1's S1) | Lesson-runner shared active allocation dock (`act0_lesson_runner_shell_v1.dart`) | **3rd independently-owned family** — joins Review zero-state and onboarding/welcome, already fixed under `LOCAL_EQUIVALENT_RULE` in Wave V2 | Extend the same min-fill/reserve-and-anchor contract already proven twice in Wave V2, generalized into a shared allocation rule instead of a 3rd bespoke local fix |
| Selectable seats read as weak controls | No ring/glow or other elevated-affordance treatment distinguishes `selectable` from `passive` seat visual state | `_SeatNodeV1` / `_seatRingColorV1` | Affects every seat-tap decision task across every world that reuses `Act0TableSceneV1` for interactive selection (not proven cross-owner beyond this composition, but the composition itself is shared infrastructure, not a one-off) | A shared interaction-affordance rule for tappable table targets (ring/elevation/motion on `selectable`, distinct from both `passive` and `activeFocus`) |
| Table/instruction "two islands" | No shared visual/zoning grammar connects the instruction card to the table stage | `_RunnerInstructionSlotV1` + `Act0TableSceneV1` siblings inside `buildRunnerStage()` | Structural to the shared `runnerScreen` composition — affects every drill/practice state using this stage, not isolated to VRT-02 | A shared vertical-zoning contract (intrinsic instruction zone → flexible table zone → action zone) rather than independently-composed siblings |
| Duplicate BTN/You/position labels | Table renders both a `BTN` seat-role chip and a separate floating `BTN` badge next to the `You/100 BB` hero panel (visible in owner screenshot) | `_SeatMarkersV1`/hero panel composition | Same shared table-rendering owner as the other three findings | Fold into the same affordance/zoning contract — one canonical position-label slot per seat, not two |
| Acquisition blind spot for live lesson content | Lane #1's "table read"/"table decision" surfaces render synthetic placement fixtures, not real campaign-pack drill runners | `tools/act0_real_text_surface_capture_v1.dart` | Affects **every** in-lesson drill/practice decision state across every world — not just `positions_early_late` | Add a lane-#1 group that captures representative live drill runners (not just synthetic placement fixtures) — acquisition-tooling fix, no product code |

**Cross-owner count for the dead-space/allocation-grammar defect class is now
3** (Review zero-state, onboarding/welcome, lesson-runner action dock). This
crosses the Wave V1/strategy doc's own pre-declared **3+ independently-owned
screens threshold** for the `V2_MODEL_1_SHARED_SHELL` fallback
(`PRE_HUMAN_VISUAL_COMPLETION_STRATEGY_v1.md` §9; `PRE_HUMAN_VISUAL_COMPLETION_WAVE_V1_REPORT_v1.md`
§7). That fallback was explicitly pre-authorized to trigger without a fresh
dispatch "if Wave V1 finds 3+ independently-owned repeating symptoms" — this
document is the fresh evidence that satisfies it, arriving via VRT-02 rather
than a further Wave V1-style recapture.

Independently, the **affordance** and **visual-island** findings are a
*different* defect class from allocation/dead-space — they are not closed by
a shared-shell allocation contract alone. Both classes share one owner
family (the lesson-runner composition layer) and are best addressed together
rather than sequentially, since both require touching the same
`runnerScreen`/`Act0TableSceneV1` files.

## 5. Packet R3 — Operating model reselection

Ten candidate models scored (0-10 per axis; weights follow the strategy
doc's precedent: defect coverage 20%, root-cause leverage 15%, speed 15%,
cycles-to-closure 10%, token cost 10%, runtime cost 5%, regression risk
(inverted) 10%, repo fit 10%, aesthetic preservation (inverted) 5%,
owner-decision burden factored qualitatively, not scored — see notes):

| # | Model | Defect cov. | Root-cause | Speed | Cycles | Token cost | Runtime cost | Regr. risk (inv.) | Repo fit | Aesthetic (inv.) | **Weighted** |
| - | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Full visual census + screen-by-screen master audit | 9 | 5 | 2 | 3 | 2 | 3 | 5 | 5 | 6 | 4.6 |
| 2 | Template-family audit and repair | 7 | 7 | 5 | 6 | 6 | 6 | 6 | 7 | 8 | 6.4 |
| 3 | Route-critical-state audit only | 6 | 5 | 8 | 7 | 8 | 8 | 7 | 8 | 8 | 6.9 |
| 4 | Shared composition-system first (shell/zoning grammar) | 8 | 9 | 5 | 6 | 6 | 7 | 6 | 8 | 8 | 7.2 |
| 5 | Root-cause cluster audit from representative states | 7 | 8 | 7 | 7 | 8 | 7 | 7 | 8 | 8 | 7.5 |
| 6 | Runtime-first simulator walkthrough | 5 | 4 | 4 | 5 | 4 | 3 | 8 | 6 | 8 | 5.2 |
| 7 | Deterministic screenshot matrix first | 6 | 4 | 6 | 6 | 7 | 8 | 8 | 8 | 8 | 6.6 |
| 8 | Hybrid: census → root-cause waves → delta recapture → periodic full audit | 8 | 8 | 5 | 6 | 5 | 6 | 7 | 7 | 8 | 6.9 |
| 9 | Design-spec-first, then implementation | 6 | 6 | 3 | 5 | 4 | 5 | 6 | 5 | 7 | 5.3 |
| 10 | Selective rebuild of the critical learning loop | 5 | 3 | 8 | 7 | 8 | 8 | 6 | 7 | 7 | 6.4 |

**Model 1 (full census) loses clearly**, exactly as the prior strategy
checkpoint found for its own Model 6 analogue: highest theoretical ceiling,
worst speed/cycles/token cost, and this mission's own evidence shows it is
unnecessary — VRT-02 was found via **one owner screenshot plus targeted
source reads**, not a full re-census. **Model 9 (design-spec-first)** is
disqualified by the campaign's standing rule that Claude Design never invents
product direction and is gated behind SHK-CREST-01/asset scope, not layout
scope. **Model 6 (runtime-first simulator)** scores low on root-cause
leverage — `capture_act0_screens_v1.sh` cannot even reach the seat-tap
decision surfaces (per Wave V1's own parity report), so it cannot find or
verify this defect class at all.

**Highest-EV single model: #5 (root-cause cluster audit)**, but its score
converges with #4 (shared composition system) because §4 above already
*proves* the cluster crosses the pre-set 3+ threshold — meaning the audit
Model 5 would perform has already been performed by this document, and its
output is exactly Model 4's entry condition. **Synthesized selection:**

**Primary model: Model 4 (shared composition-zoning grammar) governing two
named contracts — vertical-allocation and interaction-affordance — applied
only to the proven owner families, not a full shared-shell rewrite.** This is
the corridor's brief hybrid #7 ("template-family plus interaction-affordance
model"), narrowed by evidence to exactly the two contracts VRT-02 and the
S1 lineage jointly require, not a full new template system.

This is **not** the "Continue local equivalent rules" model (candidate 3 in
the mission's required list / Model 3 in the strategy doc's numbering) that
Wave V2 used, because the decision rule's own condition for staying local no
longer holds: 3+ independently-owned surfaces now share the dead-space root
cause (§4), and local repairs on a 3rd owner would foreseeably reproduce the
same layout logic Wave V2 already wrote twice. It is **not** the full
shared-shell rewrite either (Model 6 in the strategy doc / disfavored broad
option here) — the fix is two narrow, named contracts (allocation +
affordance) layered onto the existing `runnerScreen`/`Act0TableSceneV1`
composition, not a replacement of it.

### Why the prior `V2_MODEL_3_NARROW_GRAMMAR` conclusion changed

It does not become wrong — Wave V1/V2's own evidence was accurate for what it
captured (2 owner families, correctly under the 3+ threshold, correctly
resolved locally). What changed is **new evidence from a family the capture
matrix structurally could not see** (§2.2-2.3), which the strategy doc's own
decision rule already anticipated and pre-authorized a response to. This is
`RECONCILIATION_REQUIRED`, not a reversal of a wrong prior verdict.

## 6. Decision

**Selected model: shared vertical-allocation + interaction-affordance
contract, scoped to the lesson-runner composition layer
(`lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`) and its three
proven owner families** (Review zero-state, onboarding/welcome — already
closed under `LOCAL_EQUIVALENT_RULE` in Wave V2 and not reopened — plus the
newly proven lesson-runner action dock and seat-affordance family).

Scope is **not** a full shared shell across Home/Learn/Review/Profile — those
surfaces show zero symptoms in Wave V1's full recapture and are excluded.

## 7. Three-wave corridor

### Wave A — Active learner composition foundation (**AUTHORIZED**)
- Owner family: `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
  (`runnerScreen` shared-allocation branch, `_SeatNodeV1` affordance,
  `_RunnerInstructionSlotV1`/`Act0TableSceneV1` zoning).
- Scope: (1) a named vertical-allocation contract for the shared-allocation
  lower dock that reclaims genuinely unused remainder space (min-fill or
  reserve-to-content, matching the grammar Wave V2 already proved twice); (2)
  a named interaction-affordance treatment for `_SeatVisualStateV1.selectable`
  distinct from `passive` (ring/elevation, not just border-color); (3) a
  minimal zoning relationship (shared container, connecting rail, or
  consistent background) between the instruction card and the table stage;
  (4) resolve the duplicate BTN/position-label rendering into one canonical
  slot per seat.
- Exclusions: no Modern Table, no new screen roles beyond the lesson-runner
  drill/practice states already in scope, no Sharky art, no aesthetic
  identity change beyond the four named contracts, no touching Review/
  Welcome/Placement (already closed, not reopened without new evidence).
- Agent: Codex. Effort: Medium. Goal Mode: ON, bounded to Wave A scope.
  Computer Use: OFF (bounded simulator spot-check optional).
- DoD: fresh lane-#1 evidence (extended per Wave B's acquisition fix, or
  hand-captured if the extension lands after Wave A) for
  `positions_early_late` and at least one `_w3*` derivative at compact/tall/
  large; `./tools/release_gate_world1.sh` green; `flutter analyze` clean.
- Token budget: 70,000-110,000.

### Wave B — Complete route migration and regression proof (**CONDITIONALLY PREAUTHORIZED**)
- Entry gate: Wave A terminal, `release_gate_world1.sh` green, no SSOT
  conflict discovered during Wave A.
- Scope: (1) add the acquisition-tooling fix identified in §4 (a lane-#1
  group capturing representative live drill/practice runners, not only
  synthetic placement fixtures) so this defect class cannot recur invisibly;
  (2) apply Wave A's two contracts to any additional owner-family instance
  the new acquisition group surfaces; (3) full deterministic recapture of the
  lesson-runner family across compact/tall/large plus the existing 1.4x and
  reduced-motion variants; (4) preserve Home/Learn/Review/Profile untouched.
- Exclusions: same as Wave A; no new capture pipeline beyond the one group
  extension.
- DoD: acquisition group exists and passes; every Wave-A-touched surface has
  fresh commit-pinned evidence; no new symptom found outside the four named
  contracts; regression gate green.
- Token budget: 60,000-100,000.

### Wave C — Brand and emotional completion (**CONDITIONALLY PREAUTHORIZED**)
- Entry gate: Wave B terminal, owner visual acceptance of Waves A/B, and
  SHK-CREST-01 resolved for any crest-dependent row.
- Scope: unchanged from the standing Wave V3 design in the strategy doc §13 —
  the six `EXTERNAL_ASSET_INPUT_REQUIRED` Sharky rows, at proven 16dp/34dp
  bounds, both growth stages, reduced-motion-safe.
- This wave is not accelerated or newly scoped by VRT-02; it remains exactly
  as previously designed and gated.

Global corridor stop rule: return to the owner only when a genuine R3 exists
(incompatible SSOT, a real product/visual decision, an unauthorized
architecture change, or decision-controlling Human evidence) **and** it
blocks every remaining independent wave.

## 8. Boundaries reconfirmed

PHP-9 remains `NOT_PREAUTHORIZED`. Human Novice Proof remains `NOT
AUTHORIZED`. Modern Table remains permanent Maintenance Mode, untouched. No
new Sharky art is authorized by Wave A or Wave B. SHK-CREST-01 remains
unresolved and unreopened. Review/Welcome/Placement (Wave V2's closed scope)
are not reopened.

## 9. Campaign state reconciliation

This publication updates `docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md`:
canonical HEAD to this PR's merge SHA; authority freshness to this document;
umbrella stage to "Wave A authorized, lesson-runner composition foundation";
`VISUAL_SYSTEM_COMPLETENESS` and `VISUAL_COMPLETION_OPERATING_MODEL` rows
updated to reflect `RECONCILIATION_REQUIRED` → resolved-by-this-document;
packet ledger gains a row for this dispatch. PHP-9/Human/Modern Table rows
unchanged.
