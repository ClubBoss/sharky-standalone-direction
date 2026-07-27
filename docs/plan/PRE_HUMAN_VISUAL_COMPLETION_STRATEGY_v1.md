# Pre-Human Visual Completion Strategy v1

Status: **TERMINAL — PRE_HUMAN_VISUAL_COMPLETION_STRATEGY_COMPLETED.**
Checkpoint admitted at PR #86 (`432c9f47`); completed and published by this PR.

Authority: this document does not override
`docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md` (single first-read dispatch
authority) or `docs/plan/MASTER_PLAN_v3.0.md`. It supplies the strategy that
state file now points to. It does not authorize product implementation,
broad redesign, Modern Table changes, new Sharky art, PHP-9, or Human Novice
Proof.

Baseline: `de3f0ce2398601ab557af05b18fcff8a07279cfa` (post-PR #85, terminal
corridor publication) → this checkpoint's own prior packet merged at
`432c9f47` (PR #86, VS-0).

## 1. Owner-supplied visual directives (published, unchanged from VS-0)

| Directive | State |
| --- | --- |
| `VISUAL_SYSTEM_COMPLETENESS` | NOT CLOSED — PHP-7 closed only its narrow role/hierarchy contract; full-screen composition, density, rhythm, affordance, cross-screen cohesion, and premium finish are unproven. |
| `VISUAL_COMPLETION_OPERATING_MODEL` | Resolved by this document (§8–§9): recommended primary + fallback model selected. |
| `VISUAL_STATE_ACQUISITION_OPERATING_MODEL` | Resolved by this document (§2): existing tooling verdict + freshness architecture. |
| `PRE_HUMAN_VISUAL_COMPLETION_STRATEGY` | Terminal at this publication. |

None of these authorize broad redesign, Modern Table changes, or new Sharky
art on their own.

## 2. Visual-state acquisition truth

Audited every existing capture mechanism in `tools/` against the
code/render/runtime/device taxonomy. Full method-by-method findings are
recorded in the machine-readable manifest
(`docs/plan/_data/visual_completion_strategy_manifest_v1.json`,
`acquisition_methods`). Summary:

| # | Mechanism | Category | Real shell | Real text | Deterministic | Commit-pinned | Verdict |
| - | --- | --- | --- | --- | --- | --- | --- |
| 1 | `act0_real_text_surface_capture_v1.dart` (`screen_review_fast_v1.sh`) | **C** — in-app capture, injected route/data | Yes (`Act0ShellPreviewScreenV1`) | Yes | Yes | Yes (git_commit + sha256 in manifest) | **Strongest current evidence tier. Explicitly declares `allowed_claims` (copy, tone, readability, payoff, surface identity) vs `unsupported_claims` (human QA, launch readiness, tablet claims). Use as primary composition/density/hierarchy evidence.** |
| 2 | `act0_product_100_proof_capture_v1.dart` | B — widget deterministic render | Yes | No (`is_real_text:false`) | Yes | Yes | Layout/geometry/CTA-placement only; not copy or premium-feel evidence. |
| 3 | `act0_motion_evidence_capture_v1.dart` | B | Yes | Yes | Yes | No sha | Motion timing/staging only; has a known rendering anomaly (correct widget state, missing detail in rasterized frame in at least one investigated case). |
| 4 | `world_screenshot_evidence_capture_v1.dart` | B | **No** — legacy `DrillRuntimeAdapterV1`, not active Act0 shell | Yes | Yes | No | Low trust for current UX — not the active learner surface. |
| 5 | `world_screenshot_evidence_audit_v1.dart` | **A** — code-only, no render at all | N/A | N/A | N/A | N/A | Structural/ownership assertions only. Zero visual evidence despite adjacent naming. |
| 6 | `modern_table_screenshot_v1.dart` | B | Mixed, some mocked | Yes | Yes | No | Modern Table Maintenance Mode regression evidence only — **must not** be used as a design-iteration tool (guardrail). |
| 7 | `capture_act0_screens_v1.sh` / `screen_review_v1.sh` | **D** — real iOS Simulator, full app build+install+launch | Yes | Yes (device render) | **No** — reflects live app state, not byte-repeatable | No sha256, has git_commit | Highest visual fidelity but slow (minutes/surface), requires local Xcode, not CI-repeatable. Use sparingly for spot-checks, not as the primary evidence lane. |
| 8 | `act0_controlled_demo_capture_v1.sh` | **G** — hybrid: headless Playwright over Flutter web build, route-injected | Yes (web) | Yes (browser render) | Mostly | No sha, has blank/forbidden-chrome gate | Good structural/smoke coverage; web rasterization differs from device, weaker for fine visual judgment. |
| 9 | `checkpoint_world1_v1_capture.sh` | N/A | — | — | — | — | Not a screenshot tool despite the name — captures test-failure diagnostics only. |

**Category coverage verdict:**
- **A** (code-only): covered, structural claims only.
- **B** (widget deterministic render): covered, several lanes, mostly non-real-text or legacy-surface — layout/geometry only.
- **C** (deterministic in-app capture, injected state): covered and strong — this is the load-bearing lane for any visual-quality assertion.
- **D** (simulator automation): covered but slow, non-deterministic, local-Xcode-dependent — spot-check only.
- **E** (physical-device capture): **no tooling exists.**
- **F** (external device-cloud / visual-QA service): **no tooling exists** — no Percy/Chromatic/Applitools/Firebase Test Lab integration found anywhere in the repo. External research (§8) confirms these services are web-component-oriented (Chromatic/Percy) or paid native-mobile services with private-repo/pricing implications (Applitools, Drizz) — none are a drop-in fit for a private Flutter repo without material cost or setup.
- **G** (hybrid): one lane (browser-over-Flutter-web), moderate trust.

**Assertion-to-evidence rule applied:** structural/ownership/responsive-branch
claims may cite code or lane #2/#5; composition/hierarchy/balance/density/
rhythm claims require lane #1 (real-text, real-shell, commit-pinned);
interaction/reachability/scrolling/safe-area claims require lane #1 or #7/#8
at runtime; premium-feel/emotional/cross-screen-cohesion claims require
multimodal review of lane #1 output plus owner adjudication — no lane alone
can certify this tier.

**Freshness/token-efficiency architecture (already substantially present,
formalized here):** lane #1's manifest already records `git_commit`,
`git_status_classification` (flags tracked-source drift vs output-only
drift), `matches_current_head`, image sha256, device/state identifiers,
capture method, and an explicit `allowed_claims`/`unsupported_claims` split.
This is the correct shape and should be the template other lanes converge
toward rather than a new system. The one missing piece: no lane
auto-invalidates when a named owner file changes (e.g., a shared shell
widget) — this is a v2 refinement, not a blocker, and is intentionally out
of scope for this checkpoint (no new tooling authorized).

## 3. Canonical screen/state matrix (learner-facing, current route)

| Screen/state | Device coverage in lane #1 | Notes |
| --- | --- | --- |
| Home | compact/tall/large via `core` group | Primary daily-return surface. |
| Learn / lesson detail | compact/tall/large via `core` group | |
| Practice | compact/tall/large via `core` group | |
| Review (populated) | `alpha_journey`, `review_return` groups | |
| Review (empty) | `core` group (`review_empty`) | **Symptom found — §5.** |
| Profile / You | `profile_evidence` group | |
| Decision / theory / correct / incorrect feedback / repair / recheck | `alpha_journey`, `presentation_closure` groups | Presentation-closure lane currently **fails to capture** — §5. |
| Welcome/onboarding, placement | `alpha_journey` group | |
| Session Summary / milestone / ceremony | `first_week`, `day2_return` groups | Not re-captured this session (bounded budget); existing lane covers them per manifest schema. |
| Sharky states | `sharky_evidence` group | Six state-art rows remain `EXTERNAL_ASSET_INPUT_REQUIRED` per campaign state — unchanged by this checkpoint. |
| Modern Table (where still in a learner route) | `modern_table_screenshot_v1.dart` | Maintenance Mode only; not touched. |

Device classes exercised: `compact` (375×812), `tall_phone` (390×844),
`large_phone` (430×932); `iphone17_class` safe-area fixture also exists.
Accessibility: one `text_scaler` 1.4x linear variant exists, scoped to the
`presentation_closure` group only. **No reduced-motion capture mode exists
anywhere in the tooling** — the product has a reduced-motion seam
(`MediaQuery.disableAnimations`) but nothing in `tools/` exercises it. This is
a genuine acquisition gap, not assumed.

## 4. Representative current evidence (this session, pinned to `de3f0ce2`)

Generated locally via existing lane #1 (`screen_review_fast_v1.sh` /
`act0_real_text_surface_capture_v1.dart`), kept local-only per repository
policy (`output/` is not committed):

- `core` group, `compact` and `tall_phone` devices — home, learn, learn_detail,
  practice, review, review_empty, profile.
- `alpha_journey` group, `compact` — onboarding-to-decision chain.
- `presentation_closure` group, `compact` — **capture FAILED**, see §5.

## 5. Systemic visual root-cause analysis

### Symptom → root cause → owner family

**Symptom S1 — Review-empty state has ~40% unused vertical space below its
last element (compact, 812pt height, content ends ~55% down the viewport).**
- Evidence: `core_fast/compact.review_empty.png` (this session).
- Root cause cluster: **weak vertical-allocation grammar for empty/zero-content
  states.** The screen does not have a shared "empty state" template that
  either centers content, adds a secondary supporting element, or intentionally
  fills remaining space with a low-commitment affordance (e.g., a bounded CTA
  back into Practice). Each screen composes its own vertical stack with no
  shared minimum-fill or centering contract.
- Owner family: Act0 shell screen-composition layer (`lib/ui_v2/act0_shell`),
  specifically whatever review-screen widget renders the zero-state branch.
- Defect-class breadth: **likely repeats** anywhere a screen has a genuine
  empty/zero-content state (review-empty is the only one evidenced this
  session; day2_return/first_week groups were not re-captured and should be
  checked before implementation, not assumed clean).
- Learner impact: low-severity but real — an empty-feeling screen on a
  learning app reads as unfinished, which is exactly the
  `VISUAL_SYSTEM_COMPLETENESS: NOT CLOSED` directive's concern.
- Repair scope: bounded — one shared empty-state layout contract (min-fill or
  center-with-secondary-element), applied only to screens that currently have
  a bare zero-content branch. Not a redesign.
- Regression surface: small — additive layout only, no logic change.
- Fix before Human Proof: **yes**, low-cost and directly addresses the owner
  directive.

**Symptom S2 — Primary CTA button renders as a solid color bar with no
visible label text in raw lane-#1 output.**
- Evidence: raw `act0_real_text_surface_capture_v1.dart` output (this
  session, before running the paired repair step) on `home` and
  `learn_detail`.
- Root cause: **not a product defect.** This is a documented Ahem/Roboto
  font-fallback rasterization artifact in the widget-test text renderer,
  already patched by `screen_review_fast_text_repair_v1.py`
  ("repaired 8 labels" — confirmed this session by re-running the full
  `screen_review_fast_v1.sh` pipeline, which restored legible "Continue" /
  button text).
- Owner family: evidence-tooling only, not `lib/ui_v2/act0_shell`.
- Action: **none required** — but this is exactly the kind of tooling
  artifact that could be misread as a P1 visual defect by anyone who runs
  the bare capture script instead of the full pipeline. Recorded here so
  future evidence reviewers don't reopen it. `AGENTS.md`/lane docs should
  make the two-step (capture → repair) requirement more prominent — a
  documentation nit, not a code fix.

**Symptom S3 — `presentation_closure` real-text capture lane fails a
mechanical-state (layout rect) assertion at the exact pinned baseline
`de3f0ce2`** (`Expected: Rect.fromLTRB(45.4, 46.0, 356.6, 586.2)` vs
`Actual: Rect.fromLTRB(83.5, 46.0, 318.5, 454.0)`).
- Evidence: reproducible this session, `dart run
  tools/act0_real_text_surface_capture_v1.dart presentation_closure compact`
  fails deterministically; prior output preserved at
  `output/screen_review/current/presentation_closure_v1` (stale, from an
  earlier baseline).
- Root cause: **evidence coverage blind spot / stale fixture drift** — the
  capture tool's own expected-geometry fixture for the presentation-closure
  surfaces (feedback/repair/accessibility states) has drifted from current
  `lib/ui_v2/act0_shell` layout, and nothing detected this until this
  session ran the lane directly. This is an acquisition-architecture gap,
  not a proven product visual defect — it could be either a genuine layout
  regression in the product or a stale test fixture; this checkpoint cannot
  distinguish which without further owner-scoped investigation, which is out
  of scope here (docs/evidence-only mission).
- Owner family: whichever owns `presentation_closure` fixtures in
  `act0_real_text_surface_capture_v1.dart` plus whatever screen renders the
  affected surface (likely `accessibility_feedback_after_answer` or a
  neighboring feedback/repair state, per the manifest's group naming).
  **Requires an owner-scoped repair packet (VS-4/W2A-class) to determine
  which side drifted.**
- Learner impact: **unknown until root-caused** — this state includes the
  1.4x accessibility text-scaler variant, so if it is a real product
  regression it directly affects accessibility-mode users, which is
  decision-controlling.
- Fix before Human Proof: **recommended yes** — this is the accessibility
  lane and a real gap here would be a genuine failure-mode risk, not
  cosmetic polish.

**Symptom S4 — No reduced-motion capture mode exists anywhere in
acquisition tooling** (§3).
- Root cause: acquisition-architecture gap, not a product defect per se —
  the product has the seam, evidence tooling doesn't exercise it.
- Owner family: evidence tooling (lane #1 extension), zero product-owner
  risk.
- Fix before Human Proof: not required to be product-side; worth a bounded
  tooling addition in a future evidence-acquisition wave, not this
  checkpoint (no new tooling authorized here).

**No systemic composition/shell/template defect was proven this session at
the breadth the owner directive worries about.** The two clean screens
inspected (`home`, `learn_detail`) show one dominant CTA, clear role
separation, and no dead-space or hierarchy problem — i.e., the directive's
concern is plausible but **not yet proven as a repository-wide systemic
defect** from the bounded evidence gathered. The concrete, reproducible
findings are S1 (narrow, bounded) and S3 (real acquisition/possible
accessibility gap, needs an owner-scoped repair packet to classify). A
broader claim of systemic visual incompleteness would require the fuller
screen/state matrix (§3, un-recaptured groups) before it could be asserted
as proven rather than directive-suspected.

## 6. Operating models compared

Seven end-to-end operating models, each covering the full cycle
(acquisition → analysis → root-cause → decision → implementation →
re-verification → runtime proof → owner acceptance → closure):

1. **Shared screen-composition shell** — one wrapper (safe area, scroll
   policy, min-fill/empty-state contract, CTA anchoring) all Act0 screens
   adopt.
2. **Canonical template families (3–4)** — e.g., "content-with-CTA",
   "list/sequence", "feedback/repair", "empty/zero-state" — screens map to a
   template instead of bespoke composition.
3. **Vertical-allocation grammar only** — a narrow rule set (intrinsic vs
   flexible vs scroll zones, min-fill behavior) without a full shared shell.
4. **Interaction-affordance layer** — a shared CTA/reachability/scroll-hint
   component set, independent of layout-shell work.
5. **Selective rebuild of critical surfaces** — hand-fix only the screens with
   proven symptoms (e.g., review-empty), no shared abstraction.
6. **Deeper layout-system rebase** — replace the Act0 shell's layout
   primitives wholesale (highest power, highest regression risk, explicitly
   discouraged by `AGENTS.md`'s "keep diffs proportional" and the mission's
   "no broad redesign" boundary).
7. **Multimodal-audit + device-matrix pipeline (process model, not a code
   change)** — formalize lane #1 as the evidence source, require every
   future visual PR to attach a lane-#1 bundle plus a multimodal (Claude)
   read against the manifest's `allowed_claims`, before owner sign-off.

(Candidate families 8–10 from the brief — code-to-design/design-to-code,
hybrid senior-designer/AI pipeline — are folded into §8's tool research and
into model 7's process design rather than treated as separate structural
models, since they are workflow overlays on top of models 1–7, not
alternatives to them.)

## 7. Tool research conclusions

- **Claude Design** (Anthropic Labs, research preview since 2026-04-17, paid
  Pro/Max/Team/Enterprise, shares usage pool with Claude Code) now supports a
  round-trip handoff with Claude Code (`/design` in-terminal, or hand a
  finished design to Claude Code to implement). Real and current, but per
  this mission's own boundary and the campaign state's standing rule, **not
  authorized for repository governance or final code integration** — usable
  only for a bounded, owner-gated asset/spec production step (§9), never to
  invent product direction.
- **Claude Code + multimodal review of lane #1 screenshots** (what this
  session just did in §5) is free (same Claude Code session), deterministic
  in the sense that the evidence is commit-pinned, and requires no new
  vendor relationship or private-repo exposure. This is the cheapest capable
  option for composition/hierarchy/premium-feel judgment.
- **Flutter golden_toolkit / golden tests**: mature, well-documented,
  Flutter-native — but golden tests assert *pixel sameness vs a prior
  approved image*, not *quality*. They are a regression guard for a design
  already accepted, not a quality-discovery tool. Complementary to, not a
  substitute for, lane #1 + multimodal review.
- **Chromatic / Percy**: both are fundamentally web/component-library
  (Storybook) oriented; neither has native Flutter/mobile-app support.
  Applying either would mean rendering Flutter to web first (as lane #8
  already does) and accepting browser-rasterization deviation from device
  truth — no net gain over existing lane #8, and it adds an external SaaS
  dependency and cost for no clear benefit here.
- **Applitools / device-cloud native-mobile visual QA (e.g., Drizz)**: real
  native-mobile-capable services exist, but bring pricing, private-repo
  data-sharing implications, and setup/maintenance cost disproportionate to
  the currently-proven defect breadth (§5 found one bounded symptom and one
  acquisition gap, not a broad crisis). Not justified now; revisit only if a
  future wave proves systemic defects broad enough to need continuous
  automated device-matrix monitoring.
- **Physical-device capture / device farms**: no current tooling, no current
  evidence of need — supported-phone classes (compact/tall/large) are
  already covered logically by lane #1's viewport definitions; a physical
  pass remains a Human-Proof-adjacent, not strategy-checkpoint, concern.

Sources: [Claude Design guide 2026](https://www.buildfastwithai.com/blogs/claude-design-anthropic-guide-2026), [Claude Design × Claude Code integration](https://theplanettools.ai/blog/claude-design-claude-code-integration-2026), [Introducing Claude Design — Anthropic](https://www.anthropic.com/news/claude-design-anthropic-labs), [Flutter golden tests guide](https://www.dhiwise.com/post/guide-to-flutter-golden-tests-for-flawless-ui-testing), [golden_toolkit docs](https://pub.dev/documentation/golden_toolkit/latest/), [Percy app visual testing 2026](https://percy.io/blog/app-visual-testing), [Visual regression tools comparison 2026](https://www.drizz.dev/post/best-visual-regression-testing-tools).

## 8. Scorecard

Weights: defect coverage (20%), root-cause leverage (15%), speed to first
useful result (15%), cycles-to-closure (10%), token cost (10%), runtime cost
(5%), regression risk (10%, inverted — lower risk scores higher), repository
fit (10%), aesthetic preservation (5%, inverted risk).

| Model | Defect cov. | Root-cause leverage | Speed | Cycles | Token cost | Runtime cost | Regression risk (inv.) | Repo fit | Aesthetic preserved | **Weighted** |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1. Shared composition shell | 8 | 9 | 5 | 6 | 6 | 7 | 6 | 7 | 8 | **7.1** |
| 2. Template families | 7 | 7 | 6 | 6 | 6 | 7 | 6 | 7 | 8 | 6.7 |
| 3. Vertical-allocation grammar only | 6 | 6 | 8 | 7 | 8 | 8 | 8 | 9 | 9 | **7.4** |
| 4. Interaction-affordance layer | 5 | 5 | 7 | 7 | 7 | 8 | 8 | 8 | 8 | 6.6 |
| 5. Selective rebuild of symptomatic surfaces | 4 | 3 | 9 | 8 | 9 | 9 | 9 | 9 | 9 | 6.9 |
| 6. Deep layout-system rebase | 9 | 9 | 2 | 3 | 2 | 3 | 2 | 3 | 4 | 4.6 |
| 7. Multimodal-audit + device-matrix process | 6 | 6 | 8 | 7 | 6 | 8 | 9 | 9 | 9 | **7.5** |

Model 6 loses clearly: highest theoretical ceiling but violates the
mission's own "no broad redesign" boundary, worst regression/aesthetic risk,
slowest — disqualified by boundary, not just score. Models 2 and 4 are
subsumed by 1 once a shell exists (a shell is where templates and affordance
live) and don't independently justify separate work. Model 5 scores well on
cost/speed but has the lowest root-cause leverage — it would fix S1 without
preventing the next occurrence, i.e., it treats a symptom.

## 9. Recommendation

**Primary: Model 7 (multimodal-audit + device-matrix process) governing
Model 3 (vertical-allocation grammar) as its only in-scope code change.**

Rationale: the evidence gathered this session (§5) does not prove a
repository-wide compositional crisis — it proves one bounded empty-state gap
(S1) and one acquisition/possible-accessibility gap (S3), against two clean
screens. That evidence profile does not justify Model 1's full shared-shell
investment yet; it justifies formalizing the *process* that would have
caught S1/S3 earlier (Model 7 — require a lane-#1 bundle + multimodal read
on every visual-affecting PR, using the manifest's `allowed_claims` split as
the adjudication contract) plus the narrowest code fix that generalizes S1
(Model 3 — a min-fill/center rule for zero-content states, not a full shell).

**Fallback: Model 1 (shared composition shell), triggered only if Wave V1
(§10) recaptures the un-reaudited groups (day2_return, first_week, milestone,
Sharky-state surfaces) and finds S1-class dead-space or hierarchy symptoms
repeating across 3+ independently-owned screens** — at that breadth, a
shared shell's leverage clears its cost, and this document's scorecard
would flip in its favor.

Model 6 is never recommended under current evidence. Model 5 is the correct
choice only if a symptom is proven genuinely isolated (used here for S1 if
Wave V2 finds no repetition).

## 10. Sharky asset relationship

- State-art production should happen **after**, not before, any Wave V2
  layout-grammar change lands — otherwise assets get placed against soon-to-move
  containers, risking rework.
- SHK-CREST-01 remains genuinely active and unresolved (OD-03d: refined-C's
  small soft front crest vs the approved no-crest
  `sharky_canonical_character_package_v1_1` rank-1 authority). It must be
  resolved by the owner **before any crest-dependent row is produced**; it
  does not block non-crest rows or this checkpoint.
- Six state-art rows remain `EXTERNAL_ASSET_INPUT_REQUIRED` per
  `PRE_HUMAN_CAMPAIGN_STATE_v1.md` — unchanged by this checkpoint.
- Size/safe bounds already proven in PHP-6: 16dp/34dp small-size identity
  continuity across both growth stages, same-character continuity, and
  reduced-motion proof — reuse those, do not re-derive.
- Claude Design is the correct tool for asset **specification/production**
  only (§7), gated behind SHK-CREST-01 resolution for crest rows, and never
  for layout/composition decisions.

## 11. Human Proof relationship

Default owner direction stands: **the Visual Completion Strategy checkpoint
(this document) is terminal before Human Novice Proof**, per the mission
brief. This session's evidence does not surface a case for a diagnostic,
non-admission Human observation ahead of that — the two open findings (S1,
S3) are each independently repairable in a bounded wave without needing
Human input to classify them, and Human Proof against a known-open
accessibility-lane gap (S3) would produce noisy, non-attributable results.
No Human session is recommended or run. Any future deviation from
"strategy-before-Human" still requires fresh owner authorization.

## 12. Visual closure contract

Terminal visual closure (a future state, not claimed here) requires:

- canonical screen/state matrix (§3) fully re-captured, not partially as here;
- commit-pinned current evidence for every row;
- Wave V2's selected composition fix (Model 3, or Model 1 if the fallback
  trigger fires) implemented and verified;
- S3 classified (real regression vs stale fixture) and closed;
- compact/tall/large-phone verification for every changed surface;
- accessibility (1.4x text scaler) and reduced-motion handling verified —
  reduced-motion capture tooling must exist by then (§3 gap);
- runtime proof (lane #1 minimum, lane #7/#8 spot-check) for every
  interaction-sensitive assertion;
- full active-route re-audit, zero unexplained P1/P2 visual defects;
- no Modern Table scope drift;
- no screenshot-only declaration of premium quality — multimodal read plus
  owner acceptance required for that tier specifically;
- explicit owner acceptance recorded in the campaign state file.

Distinguish, and do not conflate: **functional** visual completeness (no
overflow/dead-space/broken layout — S1 is this tier), **compositional**
completeness (hierarchy/density/rhythm — not yet proven broadly one way or
the other), **brand/emotional** completeness (Sharky states, premium feel —
blocked on external assets), **runtime/device** completeness (S3, reduced-motion
gap — partially open).

## 13. Three-wave implementation corridor (designed, not executed)

### Wave V1 — Evidence completion + S3 classification
- Authorization: docs/evidence + one bounded diagnostic packet, no product
  redesign.
- Owner family: evidence tooling + whichever screen owns the
  `presentation_closure` surfaces.
- Agent: Claude Code. Model: Sonnet 5. Effort: Medium (High only if S3 proves
  a genuine cross-owner conflict).
- Goal Mode: ON, bounded to V1 scope. Computer Use: OFF.
- Entry gate: this document merged.
- Scope: recapture the un-reaudited screen/state matrix rows (§3); classify
  S3 as real regression vs stale fixture and close whichever it is; add a
  reduced-motion capture variant to lane #1 (tooling-only, no new pipeline).
- Exclusions: no layout/composition code changes, no Sharky art, no Modern
  Table.
- DoD: full matrix has fresh commit-pinned evidence; S3 has a terminal
  disposition; reduced-motion variant exists and is exercised at least once.
- Visual evidence: lane #1 bundles, local-only.
- Regression gates: existing `release_gate_world1.sh` must stay green.
- Skip/close-unnecessary: if recapture finds zero new symptoms and S3 proves
  stale-fixture-only, V1 may close as `CLOSED_UNNECESSARY` for its
  code-adjacent half (the S3 fixture fix still ships).
- Global stop rule: return only on a genuine cross-owner SSOT conflict.
- Token budget: 40,000–70,000.

### Wave V2 — Systemic composition/layout implementation
- Authorization: conditional — auto-enters only if V1's recapture confirms
  S1-class symptoms in 1–2 screens (→ Model 3, narrow grammar fix) or in 3+
  independently-owned screens (→ Model 1 fallback, shared shell).
- Owner family: `lib/ui_v2/act0_shell` composition layer.
- Agent: Claude Code. Model: Sonnet 5, escalate to Opus only for the
  shared-shell fallback path (architecture-adjacent). Effort: Medium
  (shell fallback: High).
- Goal Mode: ON. Computer Use: OFF (or ON only if a supported simulator
  is available for a final spot-check — optional, not required).
- Entry gate: V1 terminal, symptom count known.
- Scope: implement Model 3's min-fill/center empty-state rule (or Model 1's
  shared shell only under the fallback trigger) on exactly the screens V1
  evidenced.
- Exclusions: no Modern Table, no new screen roles, no aesthetic identity
  change, no mascot/asset work.
- DoD: every V1-evidenced symptom closed with fresh lane #1 evidence;
  compact/tall/large verified; `release_gate_world1.sh` green.
- Regression gates: same as V1 plus a diff-review of any shared-widget change.
- Skip/close-unnecessary: if V1 found zero repair-worthy symptoms, V2 closes
  `CLOSED_UNNECESSARY`.
- Global stop rule: an SSOT conflict on shared-shell scope, or evidence the
  fix requires touching Modern Table.
- Token budget: 60,000–120,000 (narrow path) / 100,000–180,000 (shell
  fallback path).

### Wave V3 — Brand/emotional completion (Sharky, gated)
- Authorization: conditional — enters only after V2 terminal, and only for
  non-crest rows unless SHK-CREST-01 is separately resolved by the owner.
- Owner family: Sharky asset production (external/Claude Design), PHP-6's
  existing resolver/migration path for integration.
- Agent: Claude Design for spec/production (bounded), Claude Code (Sonnet 5)
  for deterministic integration — Claude Design never touches repository
  governance or final integration.
- Goal Mode: ON, bounded to named rows. Computer Use: OFF.
- Entry gate: V2 terminal; SHK-CREST-01 resolved for any crest row in scope.
- Scope: produce/integrate the six `EXTERNAL_ASSET_INPUT_REQUIRED` rows
  named in the campaign state, at proven 16dp/34dp bounds, both growth
  stages, reduced-motion-safe.
- Exclusions: no new mood/state invention, no crest work without OD-03d
  resolution, no product-UI change beyond asset swap-in.
- DoD: all six rows have production-ready admitted assets or an explicit,
  narrower remaining `EXTERNAL_ASSET_INPUT_REQUIRED` list; deterministic
  proof (lane #1) of continuity and small-size identity.
- Regression gates: PHP-6's existing fallback/migration guards.
- Skip/close-unnecessary: rows already resolvable by existing approved
  assets close without new production.
- Global stop rule: SHK-CREST-01 remains unresolved and blocks every
  remaining row (partial closure with the rest still proceeds).
- Token budget: 30,000–60,000 (integration) + external design-tool time
  (not token-metered the same way).

Global corridor stop rule (all waves): return to the owner only when a
genuine R3 exists (incompatible SSOT, a real product/visual decision, an
unauthorized architecture change, or decision-controlling Human evidence)
**and** it blocks every remaining independent wave — a blocker local to one
wave does not halt the others.

## 14. Downstream prompts

See `docs/plan/_data/visual_completion_strategy_manifest_v1.json` field
`downstream_prompts` for the machine-readable version. Full copyable text:

### Prompt 1 — Wave V1 (evidence completion + S3 classification)

```
Chat: continue in a new Claude Code chat.
Agent: Claude Code. Model: claude-sonnet-5. Effort: Medium (escalate to High
only for a genuine cross-owner conflict on the presentation_closure surfaces).
Goal Mode: ON, bounded to Wave V1 scope only. Computer Use: OFF.
Baseline: exact origin/main HEAD after PRE_HUMAN_VISUAL_COMPLETION_STRATEGY_v1.md
merges (record the merge SHA at mission start).
Authority order: docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md, then
docs/plan/PRE_HUMAN_VISUAL_COMPLETION_STRATEGY_v1.md §13 Wave V1, then
AGENTS.md.
Use a clean detached worktree from exact origin/main. Do not touch the
operator's own checkout if one is dirty.

Scope:
1. Recapture the full canonical screen/state matrix in §3 of the strategy
   doc using existing tools/screen_review_fast_v1.sh groups (alpha_journey,
   core, first_week, day2_return, profile_evidence, sharky_evidence,
   full_scroll, presentation_closure, review_return) across compact/
   tall_phone/large_phone, local-only output.
2. Run tools/act0_real_text_surface_capture_v1.dart presentation_closure
   compact directly (bypassing the repair-script wrapper) and determine
   whether the reported Rect mismatch is a stale test fixture or a real
   lib/ui_v2/act0_shell layout regression. Classify and close it either way
   (update the fixture, or file and fix the real regression under its
   actual owner).
3. Add a reduced-motion capture variant to the lane-#1 tooling (MediaQuery
   disableAnimations), exercised on at least the presentation_closure and
   core groups.
4. For every recaptured screen, note any new S1-class (dead space, overflow,
   weak hierarchy, floating CTA, cross-screen inconsistency) symptom found,
   with exact screen/state/device.

Exclusions: no lib/ui_v2/act0_shell composition/layout code changes beyond
the S3 fix itself, no new capture pipeline, no Sharky art, no Modern Table
work, no PHP-9, no Human Novice Proof.

DoD: full matrix has fresh commit-pinned evidence; S3 has a terminal
disposition with a merged fix; reduced-motion variant exists and has been
run at least once with evidence attached; a symptom count/list is published
for Wave V2 to consume.

Token budget: 40,000-70,000. Hard ceiling 100,000.
Global stop rule: return only on a genuine R3 — incompatible SSOT, a real
owner decision, or evidence the S3 fix requires touching a shared contract
outside this wave's owner family.
```

### Prompt 2 — Claude Design asset-specification prompt (only if Wave V3's
entry gate is satisfied — do not run before then)

```
Chat: continue in a new session using Claude Design (/design in Claude Code,
or the standalone Claude Design app), handed off to Claude Code for
integration.
Agent: Claude Design for specification/production; Claude Code
(claude-sonnet-5) for deterministic integration only. Claude Design must not
make repository-governance or final-integration decisions.
Goal Mode: ON, bounded to the named rows only. Computer Use: OFF.
Baseline: exact origin/main HEAD at Wave V3 entry (record merge SHA).
Authority order: docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md, then
docs/plan/PRE_HUMAN_VISUAL_COMPLETION_STRATEGY_v1.md §10 and §13 Wave V3,
then the Sharky canonical character package manifest
(assets/design/sharky_character_v1/sharky_character_package_manifest_v1.json).

Precondition check before doing anything: confirm SHK-CREST-01 disposition
for every row you are about to touch. If a row requires the refined-C small
soft front crest and OD-03d is still unresolved, skip that row and report it
— do not ask the owner the same question again unless this is the first time
in this session.

Scope: produce/finish exactly the six EXTERNAL_ASSET_INPUT_REQUIRED rows
named in docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md, at the proven 16dp/34dp
small-size bounds, both growth stages, reduced-motion-safe, matching the
sharky_canonical_character_package_v1_1 identity (no crest unless OD-03d is
separately resolved for that row).

Exclusions: no new mood/state invention beyond the six named rows, no
product-UI change beyond asset swap-in, no layout changes.

DoD: each in-scope row has a production-ready admitted asset integrated
through PHP-6's existing fallback/migration path, with deterministic lane-#1
evidence proving continuity and small-size identity across both growth
stages.

Token budget: 30,000-60,000 for the Claude Code integration half.
Global stop rule: SHK-CREST-01 blocking every remaining row; report and stop
for owner decision rather than guessing at crest geometry.
```

### Prompt 3 — Codex implementation-corridor prompt (Wave V2)

```
Chat: continue in a new Codex session (or Claude Code if Codex is
unavailable — do not switch agents mid-wave once started).
Agent: Codex. Effort: bounded implementation, not architecture invention —
Codex must not invent product direction; the model choice (Model 3 narrow
grammar fix, or Model 1 shared-shell fallback) is decided by Wave V1's
evidence per docs/plan/PRE_HUMAN_VISUAL_COMPLETION_STRATEGY_v1.md §9, not by
Codex.
Goal Mode: ON, bounded to Wave V2 scope. Computer Use: OFF (optional
simulator spot-check only if available).
Baseline: exact origin/main HEAD after Wave V1 merges (record merge SHA).
Authority order: docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md, then
docs/plan/PRE_HUMAN_VISUAL_COMPLETION_STRATEGY_v1.md §9 and §13 Wave V2,
then Wave V1's symptom list, then AGENTS.md.

Scope: implement exactly the model selected by Wave V1's evidence (§9 of the
strategy doc: Model 3 min-fill/center empty-state rule on the exact screens
V1 evidenced, unless V1 proved 3+ independently-owned screens repeat the
symptom, in which case implement Model 1's shared composition shell instead
— but only then). Apply only to screens V1 actually evidenced as symptomatic.

Exclusions: no Modern Table, no new screen roles, no aesthetic-identity
change, no mascot/asset work, no scope beyond what V1 evidenced.

DoD: every V1-evidenced symptom closed with fresh commit-pinned lane-#1
evidence on compact/tall/large; ./tools/release_gate_world1.sh green.

Token budget: 60,000-120,000 (narrow path) or 100,000-180,000 (shell
fallback path). Hard ceiling 220,000.
Global stop rule: an SSOT conflict on shared-shell scope, or evidence the
fix requires touching Modern Table — return to owner immediately in either
case.
```

## 15. What remains owner-decision-controlled

- Whether Wave V1's S3 classification (once known) is accepted as sufficient
  before Wave V2 begins.
- SHK-CREST-01 (OD-03d) — unchanged, still owner-blocked for crest rows only.
- The fallback trigger in §9 (Model 1 shared-shell) if Wave V1 finds 3+
  independently-owned repeating symptoms — this document pre-authorizes that
  fallback path so no fresh dispatch is needed solely to approve it, but the
  owner may override at that point if evidence looks different than
  expected.
- PHP-9 admission and Human Novice Proof authorization — both remain fully
  owner-controlled and are not advanced by this checkpoint.
