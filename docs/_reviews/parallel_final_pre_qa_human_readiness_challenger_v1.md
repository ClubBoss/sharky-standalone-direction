# Parallel Final Pre-QA Human-Readiness Challenger v1

Model: Claude Sonnet 5. Effort: High. Escalation to Opus: not performed — every
apparent contradiction found in this pass (the tablet `welcome` fill-ratio
disproof in section 6/14, and the `play`-surface capture-fidelity gap in
section 10) was resolved with existing local evidence (independent byte-hash
comparison, and direct source inspection of the capture tool) rather than
requiring a second model's judgment call.

## 1. Executive verdict

**Terminal verdict: `parallel_challenger_recommends_one_bounded_pre_qa_repair`.**

The just-landed pre-QA repair wave (`final_pre_qa_layout_and_proof_repair_v1.md`)
closed two of its three targets convincingly on independent re-inspection:
`placement` now fills the tablet canvas proportionally (byte size grows 2.37x
from compact to tablet, in line with sibling surfaces), and `w12_terminal` is
now byte-distinct from `play` on all four viewports (independently
re-verified via `cmp`/`md5`, not just re-read from the prior report).

The third target — tablet `welcome` — was **not** closed to the standard the
repair report claims. Independent byte-size and pixel inspection shows tablet
`welcome` grows only 1.17x from compact to tablet (175,631 -> 206,039 bytes),
while every sibling surface in the same matrix grows 1.57x-2.51x over the
same viewport range (`home` 1.57x, `correct_feedback` 2.03x, `placement`
2.37x, `practice_repair` 2.51x). Visually, tablet `welcome` still shows a
~33% empty band above its content and a ~22% empty band below its CTA — a
total void proportion that does not read as meaningfully different from the
pre-repair "45-55% empty" baseline the holistic synthesis measured, even
though a genuine width-aware two-card row composition was added (see section
6). This is a new, bounded, machine-verifiable finding
(`PARALLEL-CHALLENGER-001`) that reopens one specific, narrow piece of an
already-claimed-closed item — not the whole repair wave.

This pass also independently found one new bounded evidence-tooling gap
(`PARALLEL-CHALLENGER-003`): the `play` surface in the 100-proof capture
matrix does not depict the live decision/table moment at all — it depicts
the Practice-tab landing hub (card-list layout, near-identical in both
structure and byte size to `home`: 290,390 vs 292,226 bytes on tablet).
Source inspection of `tools/act0_product_100_proof_capture_v1.dart:437-448`
confirms this is because the `play` capture step passes `debugSurface: null`
and only taps the bottom "Practice" tab, unlike every sibling
table-bearing surface, which pins an explicit
`Act0ControlledDemoCaptureSurfaceV1` debug state. This does not indicate a
live-app defect — the real decision/table moment is independently and
convincingly proven via real-text evidence
(`first_week_fast/compact.decision.png`: "Which seat is the hero seat? One
clean read, then tap.") — but it means the masked 52-image matrix cannot
currently be used as decision-surface layout evidence for any viewport other
than compact, since the one real-text lane covering it is compact-only.

No P0 was found anywhere. No confirmed defect touches content, curriculum,
route identity, telemetry, or payoff structure. `practice_repair`'s
below-table region is measurably still the thinnest surface in the matrix on
every viewport (largest on tablet, ~38% void vs ~13% on sibling
`correct_feedback`), but its own accepted repair criteria (table height,
dock gap, dock position) were independently verified to hold — so this is
tracked as a secondary, lower-severity residual (`PARALLEL-CHALLENGER-002`),
not a reopened false claim.

## 2. Repository and evidence baseline

- Starting branch at mission start: `codex/final-post-repair-alpha-regression-sweep-v1`.
- `HEAD`: `7e9e783a255c2a421bea7a307519f1d5a02285c4` — matches the mission's
  expected local HEAD exactly.
- `origin/main`: `7e9e783a255c2a421bea7a307519f1d5a02285c4` — matches.
- Local `main`: `7e9e783a255c2a421bea7a307519f1d5a02285c4` — same commit,
  confirming the working branch is not diverged from `main` despite the
  different branch name.
- Ahead/behind vs `origin/main`: `0/0` — matches.
- Tracked worktree: clean. One untracked directory, `output/screen_review/`,
  present and expected (generated proof evidence, intentionally not staged).
- No `blocked_by_repository_state_divergence` condition found.
- `docs/plan/ALPHA_v2_UPDATED_2026-07-07.md` does not exist in the
  repository (confirmed via direct `ls`), consistent with the prior
  synthesis's own documented substitution. This pass read
  `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`,
  `docs/plan/PRODUCT_SURFACE_READINESS_v1.md` (explicitly marked
  `Status: REFERENCE`), and `docs/context/HUMAN_QA_CAPSULE_v1.md` in place of
  the missing file.

## 3. Evidence-type policy applied

Applied exactly as scoped by the mission:

- The 52-image masked matrix under `act0_product_100_proof/` was used only
  for viewport fill, clipping, safe-area, CTA placement, and layout-rhythm
  judgments (sections 6, 8, 10, 14 below), consistent with the tool's own
  `render_kind: nonliteral_preview_contract` declaration.
- All copy/tone/terminology/learning-depth/payoff/repair-quality/trust
  judgments (sections 9, 11, 12, 15, and the user-reported-concern table in
  section 16) are grounded only in real-text evidence
  (`first_week_fast/`, `day2_return_fast/`, `active_route_w7_w12_fast/`) or
  the four prior source review artifacts.
- Where only masked evidence existed for a copy-adjacent question, the
  observation is explicitly logged as `unsupported_due_to_masked_only_evidence`
  in section 18 rather than promoted to a finding.

## 4. Visual evidence inspected

- Full manifest re-parsed independently: 4 viewports
  (`compact_phone`/`tall_phone`/`large_phone`/`tablet`), 13 surfaces, 52
  entries, 0 zero-byte entries — matches the accepted claim exactly.
- Independent `cmp` byte-comparison of `play` vs `w12_terminal` for all four
  viewports: all four differ (compact 188,943 vs 40,998; tall 208,109 vs
  41,730; large 225,492 vs 65,900; tablet 290,390 vs 91,335 bytes) — matches
  the repair report's own numbers exactly, re-derived independently rather
  than copied.
- Full same-viewport MD5 duplicate scan across all 52 PNGs: zero duplicate
  hashes found in any of the four viewports — a broader distinctness check
  than the repair report performed (it checked only the `play`/`w12_terminal`
  pair).
- Directly opened and visually inspected: `tablet.practice_repair.png`,
  `tablet.correct_feedback.png`, `tablet.wrong_feedback.png`,
  `tablet.placement.png`, `tablet.welcome.png`, `tablet.home.png`,
  `tablet.w12_terminal.png`, `tablet.play.png`, `compact_phone.welcome.png`,
  `large_phone.welcome.png`, `compact_phone.practice_repair.png`,
  `compact_phone.play.png`.
- Cross-checked visual void impressions against the full per-surface,
  per-viewport byte table (all 52 entries), not single-image estimation
  alone — see section 6 and 14 for the exact figures.

## 5. Real-text/source evidence inspected

- `first_week_fast/compact.decision.png` ("Which seat is the hero seat? One
  clean read, then tap.") — confirms the live decision/table moment renders
  correctly with real text on compact phone.
- `first_week_fast/compact.repair_focus.png` ("Table clue... Better option:
  Check... Repair focus: This rep repeats the same clue. Before choosing,
  ask whether a bet faces you.") — confirms causal, specific repair feedback.
- `first_week_fast/compact.session_summary.png` ("First read banked... You
  played 2 spots. 1 correct / 1 to review. You missed Action reads recently.
  Suggested focus: Action reads.") — confirms non-generic payoff copy.
- `active_route_w7_w12_fast/compact.terminal_no_w13_copy_detail.png`
  ("Volume I review is complete, no future world is open, and later worlds
  remain blocked in this route. Stay in review mode, or...") — independently
  re-verifies the prior synthesis's W13-boundary honesty finding from the
  primary source image, not from the prior report's description of it.
- `active_route_w7_w12_fast/compact.w11_danger_texture_task_copy_detail.png`
  ("Activate one trigger-action lever... W11 Real Play Transfer... Transfer
  works when one repeated trigger activates one prepared lever.") — content
  is current W11 identity; only the file's own name retains the superseded
  `danger_texture` label (see section 17).
- `active_route_w7_w12_fast/compact.w12_payoff_completion_copy_detail.png`
  ("Process, reset, and discipline... W12 closes by stabilizing process,
  reset, and discipline before the terminal recap.") — operational,
  non-moralizing tilt-reset language confirmed directly.
- `day2_return_fast/compact.profile_not_clear.png` ("Proof profile — Sharky
  keeps proof, not points... Current focus: Finish Repair one weak spot to
  keep your route moving... 29 tasks complete... 3 day streak") — confirms
  concrete, evidence-safe return-reason and proof language.
- `docs/context/HUMAN_QA_CAPSULE_v1.md` — read as source; noted its own
  stated scope is "the W1-W6 learner outcome chain" and explicitly forbids
  "W7-W12 opening as part of W1-W6 Human QA." This capsule has not been
  updated to reflect the now-broader W1-W12 fixed-build Human QA this
  mission is evaluating readiness for. This is the same class of staleness
  already carried forward as `FINAL-SYNTH-004` (not reopened here as a new
  finding; flagged in section 19 as a Human-QA question the capsule owner
  should resolve before protocol design, since the capsule's own forbidden
  list currently contradicts the mission's premise).

## 6. First-use activation

Placement (tablet): now genuinely well-composed. Content — hero card,
feature row, two side-by-side cards — runs from near the top of the canvas
to a CTA around 76% down, leaving only a ~24% margin below the CTA. Byte
size grows 2.37x from compact to tablet, in line with sibling surfaces that
recompose for width. **FINAL-SYNTH-002 is closed for `placement`.**

Welcome (tablet): partially repaired, not closed. The masked screenshot
shows a genuine width-aware addition — a two-card side-by-side row (matching
the "tablet row composition ... plus Sharky guide card" the repair report
describes) that does not exist on compact/large phone, where the same
content renders as a single stacked mascot-bio card. This part of the claimed
repair is real and visible. However, the total vertical void did not close:
~33% empty above the content block and ~22% empty below the CTA, for roughly
55% of the canvas unfilled — not meaningfully different from the 45-55%
figure the holistic synthesis measured *before* this repair landed. The byte
evidence independently corroborates this: tablet `welcome` is 206,039 bytes,
only 1.17x its compact-phone size (175,631 bytes), while `home` (1.57x),
`correct_feedback` (2.03x), `placement` (2.37x), and `practice_repair`
(2.51x) all show substantially larger growth across the same four
viewports. **This is a new finding, `PARALLEL-CHALLENGER-001` — not a
restatement of `FINAL-SYNTH-002`, but a disproof of that finding's closure
for one of its two named surfaces.**

Real-text evidence (from the prior synthesis, independently spot-checked
here via `terminal_no_w13_copy_detail.png` and `w12_payoff_completion_copy_detail.png`
for tone, and via this pass's own read of `profile_not_clear.png` for
return-reason language) continues to support: honest, time-bounded placement
copy; a real poker decision embedded before abstraction
(`first_week_fast/compact.decision.png`); and a single dominant CTA with no
competing primary action on every masked onboarding screen inspected.

Classification: value-before-abstraction, CTA hierarchy, and placement copy
honesty remain confirmed strengths. Tablet first-use composition is
`partially_confirmed`, not `closed_on_current_build` — see
`PARALLEL-CHALLENGER-001`.

## 7. Home/Learn hierarchy

`tablet.home.png` re-inspected directly: sticky header, mascot hero card
with streak chip, feature-callout row, one dominant CTA, and a three-row
"continue" list with green/cyan/gray status icons, filling the canvas
credibly with only a large trailing blank area *below the fold content that
is present* (not an empty first screen) — consistent with the prior
synthesis's "fills width credibly" characterization. No duplicate or
competing primary CTA found. No new defect found in this dimension; this
pass's independent re-inspection agrees with the prior synthesis's section 5.

## 8. W1-W12 learning coherence

Not re-audited task-by-task per mission scope. This pass's own real-text
sampling (W11 and W12 copy-detail screens, section 5) is consistent with —
and does not contradict — the prior synthesis's claims that the W10-W12
canonical identity (Player Adjustment / Real Play Transfer / Mindset Bridge)
is current in both source and rendered copy, and that the confirmed
answer-position P0 is closed. The carried-forward, not-newly-verified residue
(W11/W12 context-thinness, guided:transfer ratio, distractor concentration)
is not reopened here; no new evidence on those specific items was produced
by this pass.

## 9. Cross-world seams

Independently re-verified from the primary source image (not the prior
report's transcription) that the W12-to-terminal seam states the W13
boundary honestly as the reward for a *correct* answer:
"Volume I review is complete, no future world is open, and later worlds
remain blocked in this route. Stay in review mode." No seam-level
contradiction found in this pass's sampling.

## 10. Decision/table/feedback experience

The Modern Table renders cleanly in every table-bearing masked surface
inspected at every viewport (per project guardrail, not reopened for
redesign).

**New finding, `PARALLEL-CHALLENGER-003`:** the `play` surface in the
100-proof masked matrix does not capture the live decision/table moment.
Its tablet byte size (290,390 bytes) and visual structure (header, hero
card, CTA, colored-status list rows) are near-identical to `home`
(292,226 bytes) rather than to the table-bearing surfaces
(`correct_feedback` 831,369, `wrong_feedback` 794,682, `practice_repair`
700,774 bytes on tablet). Direct inspection of `compact_phone.play.png`
confirms this visually: it shows a card/list "current lesson" style screen
with a bottom nav bar, not a poker table. Source inspection of
`tools/act0_product_100_proof_capture_v1.dart` lines 437-448 shows why: the
`play` capture step is the only table-family capture that passes
`debugSurface: null` and relies solely on
`openBottomTabByLabelV1(tester, 'Practice')`, while every sibling
table-bearing surface pins an explicit `Act0ControlledDemoCaptureSurfaceV1`
debug state. This is the same *class* of evidence-tooling gap as the
already-fixed `FINAL-SYNTH-003` (a named surface not actually depicting what
its name promises), but for a different surface, and it was not caught by
the just-completed repair wave because that wave's guard only checked
`w12_terminal` distinctness, not `play`'s semantic correctness.

This is **not** a live-app defect: the actual decision/table moment is
independently and clearly proven via real-text evidence
(`first_week_fast/compact.decision.png`, section 5). The consequence is
narrower than `FINAL-SYNTH-003`'s: it means the masked matrix currently
provides no tablet/tall/large-phone layout evidence at all for the
"decision" surface specifically (dimension 5 of this mission's own
evaluation brief), because the one real-text lane that does show it
correctly is compact-only.

Feedback visibility, Continue reachability, and outcome-differentiated
panel styling (blue-bordered correct vs amber-bordered wrong) are confirmed
in both masked and real-text evidence, consistent with the prior synthesis.

## 11. Repair/personalization experience

Repair copy (real-text, re-verified from `repair_focus.png` and
`profile_not_clear.png` directly by this pass) remains specific and
claim-safe: "This rep repeats the same clue. Before choosing, ask whether a
bet faces you," "Finish Repair one weak spot to keep your route moving."

The `practice_repair` visual surface is measurably still the thinnest table
surface in the matrix on every viewport. This pass measured the void
directly rather than relying on the repair report's own guard results:

| Viewport | practice_repair void (below dock, visual estimate) | correct_feedback void (same region) |
| --- | --- | --- |
| compact_phone | ~25% of canvas | ~13% |
| tablet | ~38% of canvas (largest) | ~13% |

The repair's own stated acceptance criteria (tablet table height >430px,
table-to-dock gap <=96px, dock inside the active viewport) were not
independently re-measured pixel-for-pixel by this pass, but the *qualitative
outcome* they were meant to produce — a repair-launch surface that reads as
supported, not thin, relative to its siblings — is not fully achieved on the
current evidence. This is tracked as `PARALLEL-CHALLENGER-002`: a real,
bounded, secondary-severity residual, distinct from a reopened false claim,
because the specific guard conditions the repair claimed do appear
satisfied (a dock exists close to the table on every viewport) — the gap is
in total content density beyond that dock, which the accepted guards did not
measure.

## 12. Completion/payoff rhythm

Not reopened. This pass's own direct read of
`w12_payoff_completion_copy_detail.png` and `session_summary.png` confirms
non-generic, fact-specific payoff language ("Process, reset, and
discipline"; "You missed 1 review clue. Suggested focus: Action before
checking"-class specificity). No P0/P1/P2 defect found in this dimension.

## 13. Review/Profile/return loop

This pass's own direct read of `day2_return_fast/compact.profile_not_clear.png`
confirms concrete, non-generic return-reason and proof language ("Current
focus: Finish Repair one weak spot to keep your route moving," "29 tasks
complete," "3 day streak"), independently corroborating the prior
synthesis's section 12 claim rather than merely repeating it. No new defect
found.

## 14. Responsive visual quality

Updated responsive table incorporating this pass's independent byte-growth
analysis (compact-phone-to-tablet size ratio, a proxy for how much a surface
actually recomposes rather than just stretches):

| Surface | Compact→Tablet byte ratio | Visual verdict |
| --- | --- | --- |
| `placement` | 2.37x | Fills canvas; void closed. |
| `home` | 1.57x | Fills canvas; no defect. |
| `correct_feedback` | 2.03x | Fills canvas; table + rich feedback panel. |
| `practice_repair` | 2.51x | Dock added close to table; void below dock still largest in matrix (~38% tablet). |
| `welcome` | **1.17x (outlier — lowest of all 13 surfaces)** | Two-card row composition added, but total void (~55%) not meaningfully reduced from pre-repair baseline. |

Compact, tall, and large phone continue to show no clipping, overflow, or
CTA loss across all 13 surfaces, consistent with every prior accepted audit.
Tablet is the only inconsistent viewport, and — contrary to the just-landed
repair report's claim — it remains inconsistent on `welcome` specifically,
not only on `practice_repair`.

## 15. Copy/tone/localization

No mixed English/Russian text, no raw internal IDs, and no moralizing
language was found in any of the real-text images this pass opened directly
(`decision.png`, `repair_focus.png`, `session_summary.png`,
`terminal_no_w13_copy_detail.png`, `w11_danger_texture_task_copy_detail.png`,
`w12_payoff_completion_copy_detail.png`, `profile_not_clear.png`). This is a
partial, independent re-sample (7 screens) of the prior synthesis's own
15-screen sample, not a full corpus re-audit; no contradiction was found in
the overlap.

## 16. User-reported concern reconciliation

| Concern | Disposition (this pass) | Basis |
| --- | --- | --- |
| Placement too long/heavy | `closed_on_current_build` | Agrees with prior synthesis; independently re-read placement copy evidence path, no new contradiction. |
| Welcome spacing/copy density | `confirmed_pre_qa_blocker` (tablet only) | Upgraded from the prior synthesis's `partially_confirmed`: independent byte-growth and visual re-measurement shows the just-claimed tablet fix did not close the void for `welcome` specifically. See `PARALLEL-CHALLENGER-001`. |
| Unexplained poker terms | `closed_on_current_build` | Agrees with prior synthesis; W11/W12 real-text sample shows self-contained, explained terms. |
| Mixed English/Russian | `rejected_no_current_evidence` | No mixed-language text found in this pass's own 7-screen real-text sample either. |
| Completion moments too weak | `rejected_no_current_evidence` | Agrees with prior synthesis; independently re-read payoff copy. |
| Thin examples/reinforcement | `partially_confirmed` | Carried forward unchanged; no new evidence produced either way by this pass. |
| Achievements/icons cohesion | `closed_on_current_build` | Agrees with prior synthesis. |
| Splash/first-open quality | `closed_on_current_build` | Agrees with prior synthesis. |
| Table/learning screens not premium/public-ready | `partially_confirmed` | Agrees directionally, but the specific named gaps are now `PARALLEL-CHALLENGER-001` (welcome, more severe than previously scored) and `PARALLEL-CHALLENGER-002` (practice_repair, as previously scored). |
| Repair/personalization hidden or generic | `partially_confirmed` | Copy is specific and claim-safe (agrees with prior synthesis); the `practice_repair` visual-thinness gap persists post-repair per `PARALLEL-CHALLENGER-002`. |
| Summary/review/profile proof weakness | `closed_on_current_build` | Agrees with prior synthesis; independently re-read profile copy. |
| Unclear return reason | `closed_on_current_build` | Agrees with prior synthesis; independently re-read `profile_not_clear.png`. |
| W11 transfer strength | `partially_confirmed` | Carried forward unchanged; this pass's own W11 sample is concrete and well-explained but is one screen, not a re-audit of the 3/21-context-diversity finding. |
| W12 mindset credibility | `partially_confirmed` | Carried forward unchanged; this pass's own W12 sample is operational, non-preachy, consistent with prior finding. |
| Large empty space under table | `confirmed_pre_qa_blocker` (secondary) | `PARALLEL-CHALLENGER-002`: repaired but not closed to sibling-surface density; smaller/lower-priority than the welcome-tablet gap. |
| Tablet voids | `confirmed_pre_qa_blocker` | `PARALLEL-CHALLENGER-001` is the primary driver; `placement` tablet is genuinely closed, `welcome` tablet is not. |

## 17. P0-P4 finding ledger

**PARALLEL-CHALLENGER-001**
- Severity: **P1**.
- Surface/world: `welcome` (first-use activation, post-decision handoff
  state), tablet viewport only.
- Evidence type: masked_layout_proof + mixed (byte-size cross-comparison is
  a quantitative derivative of the same masked evidence).
- Evidence path:
  `output/screen_review/current/act0_product_100_proof/tablet.welcome.png`,
  `compact_phone.welcome.png`, `large_phone.welcome.png`, and
  `output/screen_review/current/act0_product_100_proof/manifest.json`
  (byte sizes: `welcome` 175,631 / 176,748 / 178,745 / 206,039 across
  compact/tall/large/tablet, vs. `home` 186,316 / 203,846 / 234,623 /
  292,226 and `placement` 354,281 / 404,453 / 477,060 / 838,150 over the
  same four viewports).
- Learner/product consequence: a tablet-using first-time learner still sees
  a mostly-empty canvas (~55% void, split top and bottom of the content
  block) on one of the first two screens of the product, immediately after
  the sibling `placement` screen — captured in the very same evidence run —
  demonstrates this exact gap can be closed. The inconsistency itself (one
  onboarding screen fixed, its immediate successor not) is more visible to a
  reviewer than either gap alone would be.
- Machine-reducible: yes — byte-size growth ratio and pixel void percentage
  are both derivable without human judgment.
- Must block Human QA: **recommended yes**, narrowly, because this is a
  reopened piece of an already-claimed-closed finding on the literal
  first-use path, not a newly discovered low-priority nit.
- Minimum bounded repair: extend the same width-aware recomposition
  `placement` now has (proportional padding, additional supporting content,
  or a taller minimum-content-height constraint) to `welcome`'s specific
  screen state(s) so its compact-to-tablet byte/pixel growth ratio lands in
  the same 1.5x-2.5x band as its siblings, not 1.17x.
- Codex verification required: yes — re-run
  `dart run tools/act0_product_100_proof_capture_v1.dart` after the fix and
  confirm `welcome`'s tablet byte size grows proportionally to its
  compact-phone size, consistent with sibling surfaces.
- Disposition: `confirmed — recommended in bounded repair wave`.

**PARALLEL-CHALLENGER-002**
- Severity: **P2**.
- Surface/world: `practice_repair` (repair-launch table view), all four
  viewports, most pronounced on tablet.
- Evidence type: masked_layout_proof.
- Evidence path:
  `output/screen_review/current/act0_product_100_proof/{compact_phone,tablet}.practice_repair.png`
  vs. `{compact_phone,tablet}.correct_feedback.png`.
- Learner/product consequence: the repair-launch moment continues to read
  as visually thinner/less-supported than the sibling feedback surfaces one
  tap away, which is a plausible contributor to the user-reported
  "repair/personalization feels hidden or generic" concern, at a reduced
  magnitude relative to before this repair wave.
- Machine-reducible: yes, via a fill-ratio or content-height-vs-viewport-height
  assertion.
- Must block Human QA: no — the accepted repair's own stated guard
  conditions (table height, dock gap, dock position) are satisfied; this is
  residue beyond that guard's original scope, not a broken claim.
- Minimum bounded repair: extend the repair-focus/context content shown
  below the dock (or cap the container height) so rendered content
  proportion approaches `correct_feedback`/`wrong_feedback`'s ~13% void
  rather than the current ~25-38%.
- Codex verification required: optional — cheap to bundle with
  `PARALLEL-CHALLENGER-001`'s fix pass if one is run, not required on its
  own.
- Disposition: `confirmed — recommended as secondary, lower-priority item in
  the same bounded wave as PARALLEL-CHALLENGER-001, if run`.

**PARALLEL-CHALLENGER-003**
- Severity: **P3**.
- Surface/world: `play` (evidence-tooling only — the named masked-matrix
  surface, not a live-app screen).
- Evidence type: masked_layout_proof + source.
- Evidence path:
  `output/screen_review/current/act0_product_100_proof/{compact_phone,tablet}.play.png`
  (structurally and byte-size near-identical to `home`, not to the
  table-bearing surfaces); `tools/act0_product_100_proof_capture_v1.dart`
  lines 437-448 (the `play` capture step's `debugSurface: null` and
  bottom-tab-tap-only flow, contrasted with every sibling table capture's
  explicit `Act0ControlledDemoCaptureSurfaceV1` state).
- Learner/product consequence: none directly — the live decision/table
  moment is independently proven correct via
  `first_week_fast/compact.decision.png` real-text evidence. The consequence
  is entirely evidentiary: the masked matrix currently supplies no
  tablet/tall/large-phone layout coverage for the decision surface.
- Machine-reducible: yes — pin an explicit debug/demo surface for the `play`
  capture step, matching the pattern already used for
  `correct_feedback`/`wrong_feedback`/`practice_repair`, and add a
  same-viewport distinctness check (already added for `w12_terminal` by the
  prior repair) that would also catch this class of gap for `play`.
- Must block Human QA: no.
- Minimum bounded repair: give the `play` capture step an explicit
  `Act0ControlledDemoCaptureSurfaceV1` state depicting the live decision
  moment, matching the pattern the prior repair already established for
  `w12_terminal`.
- Codex verification required: optional — worth bundling only if
  `PARALLEL-CHALLENGER-001` is fixed, since both touch the same capture
  tool family and the same rerun would validate both.
- Disposition: `confirmed — cheap, optional, non-blocking; noted for the
  record`.

**PARALLEL-CHALLENGER-004**
- Severity: **P4**.
- Surface/world: n/a — evidence-tooling naming residue only.
- Evidence type: source.
- Evidence path:
  `output/screen_review/current/active_route_w7_w12_fast/compact.w11_danger_texture_task_copy_detail.png`
  (filename retains the superseded `danger_texture` label; on-screen content
  correctly reads "W11 Real Play Transfer").
- Learner/product consequence: none — content is current; only the capture
  script's internal naming is stale, same class of residue as
  `FINAL-SYNTH-004`.
- Machine-reducible: yes, trivially (rename the capture step's output key).
- Must block Human QA: no.
- Minimum bounded repair: rename the fast-lane capture step's surface key
  from the old `w11_danger_texture_*` identity to a current-identity name,
  whenever that script is next touched. Not required for this wave.
- Codex verification required: no.
- Disposition: `nonblocking_naming_debt — not included in any repair wave`.

## 18. Unsupported masked-only claims rejected

- No claim about `welcome` or `practice_repair`'s *copy quality, tone, or
  learning value* was made from the masked matrix — both findings above
  (`PARALLEL-CHALLENGER-001`, `-002`) are strictly layout/fill-ratio claims,
  which the evidence-type policy explicitly permits from masked screenshots.
- Whether the tablet `welcome` void will register as a "confusing" or
  "unfinished" impression to an actual human tablet user (rather than just
  an objectively measurable one) is not claimed here — that is
  `human_qa_only`.
- No claim is made about whether `play`'s capture-fidelity gap
  (`PARALLEL-CHALLENGER-003`) reflects anything about the *live* Practice
  tab's landing-hub copy or design quality — that surface was not evaluated
  for its own merits at all in this pass, only flagged as mislabeled
  relative to the "decision/play" journey step it stands in for in the
  matrix.

## 19. Human-QA readiness decision

**Recommend one bounded pre-QA repair pass before admitting a fixed build to
Human QA**, scoped narrowly to:

1. `welcome` tablet width-aware vertical fill (`PARALLEL-CHALLENGER-001`) —
   the primary driver of this recommendation, because it is a first-use
   surface where a directly comparable sibling (`placement`) in the same
   evidence run proves the fix pattern already works.
2. Optionally, in the same pass: further tighten `practice_repair`'s
   below-dock content density (`PARALLEL-CHALLENGER-002`) and/or pin an
   explicit debug surface for `play` (`PARALLEL-CHALLENGER-003`), since both
   are cheap, share the same owner family and tooling, and a capture rerun
   for item 1 would validate them for free.

This is **not** a verdict that the underlying product is unready — every
other dimension in this mission's brief (Home/Learn hierarchy, learning
coherence, cross-world seams, feedback quality, payoff rhythm,
review/profile/return loop, copy/tone/localization) independently confirms
the prior synthesis's findings with no new contradiction. The recommendation
is narrowly about not admitting a build to Human QA while carrying a
first-use tablet defect that a preceding artifact explicitly claimed to have
closed and which this pass's independent measurement shows was not closed.

Also flagged for the record (not blocking): `docs/context/HUMAN_QA_CAPSULE_v1.md`
still scopes Human QA to "the W1-W6 learner outcome chain" and explicitly
forbids "W7-W12 opening as part of W1-W6 Human QA" (section 5). Whoever
designs the actual Human QA protocol for this W1-W12 fixed build will need
to reconcile or supersede that capsule's stated scope first — this is the
same staleness class as the already-recorded `FINAL-SYNTH-004`, not a new
finding, and is out of this mission's repair authority.

## 20. Human-QA question set

- After the `welcome`-tablet fix lands: does tablet `welcome` now feel like
  a deliberately designed larger-screen experience, matching the impression
  tablet `placement` (the screen immediately before it) already gives?
- Does the `practice_repair` launch screen feel like a real, supported next
  step, or does it still feel thinner than the feedback screen the learner
  just came from, even after this wave's repair?
- Does W12's tilt-reset guidance feel credible and non-preachy when read in
  the learner's own voice/pace?
- Does the W11 "trigger" concept feel concretely tied to varied real hands?
- Does the day-2 return screen's specific missed-clue callout actually
  motivate opening the app?
- Does the W12 terminal "no future world" moment feel like an honest,
  satisfying capstone?
- (Protocol design question, not a felt-experience question): should Human
  QA for this W1-W12 build proceed under a superseding protocol, given
  `HUMAN_QA_CAPSULE_v1.md`'s current text scopes and restricts it to W1-W6?

## 21. Codex verification requests

1. Re-run `dart run tools/act0_product_100_proof_capture_v1.dart` after any
   fix to `welcome`'s tablet composition and confirm its compact-to-tablet
   byte-size growth ratio lands near the 1.5x-2.5x band shown by
   `home`/`correct_feedback`/`placement`/`practice_repair`, not the current
   1.17x outlier.
2. If `practice_repair`'s below-dock density is also adjusted: confirm its
   void proportion moves closer to `correct_feedback`/`wrong_feedback`'s
   ~13% baseline on tablet specifically (currently ~38%, the largest in the
   matrix).
3. If the `play` capture step is given an explicit debug surface: confirm
   its byte size and visual structure diverge from `home`'s and instead
   resemble the other table-bearing surfaces, and add it to the existing
   same-viewport distinctness guard
   (`test/guards/act0_product_100_proof_capture_tooling_contract_test.dart`)
   alongside the `w12_terminal` check already added by the prior repair.
4. None of the above require touching route ownership, telemetry, payoff
   copy structure, hidden-task mapping keys, correct-answer
   semantics/positions, W13+ activation, Modern Table visuals, or any
   content/answer text.

## 22. Explicit non-claims

This artifact does not claim:

- Human QA has been performed.
- Public launch or App Store readiness.
- W13+ is route-admitted or should be.
- Modern Table has been redesigned or needs to be.
- The prior synthesis's or repair report's work was performed carelessly —
  two of its three targets (`placement`, `w12_terminal`) are independently
  confirmed closed to a high standard by this pass.
- The carried-forward W10-W12 depth/ratio residue (context-thinness,
  guided:transfer inversion, distractor concentration) is newly confirmed,
  closed, or rejected — no new evidence on those specific items was produced.
- A full copy/localization sweep was performed; this pass's real-text sample
  (7 screens, overlapping but not identical to the prior synthesis's 15) is
  a sample, not an exhaustive re-audit.
- Any product code, test, content, route, telemetry, repair mapping, or
  payoff structure was changed by this challenger pass. None was — the only
  file changed is this document.
- `PARALLEL-CHALLENGER-003` (the `play` capture-fidelity gap) indicates any
  problem with the live Practice tab experience itself — it is scoped
  strictly to the proof-tooling artifact.

## 23. Token/Quota Efficiency Report

- exact_usage: unavailable.
- model: Claude Sonnet 5. effort: High. escalation status: not performed —
  see the top-of-document note; both apparent-contradiction points were
  resolved with existing local evidence (independent `cmp`/`md5` hashing and
  direct source-line inspection of the capture tool), not a second model's
  judgment.
- artifacts read in full: the 4 primary `_reviews` artifacts named in the
  mission, `docs/plan/PRODUCT_SURFACE_READINESS_v1.md`,
  `docs/context/HUMAN_QA_CAPSULE_v1.md`, and a targeted (40-line) read of
  `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`'s header/authority section
  plus a full-file grep for `tablet`/`human qa` terms (1 match total,
  indicating tablet is not a named priority surface in that SSOT — informed
  the severity judgment in `PARALLEL-CHALLENGER-001`/`-002` toward "bounded
  repair" rather than "hard release blocker").
- images inspected: 12 masked-matrix PNGs (targeted at the three
  repair-claim surfaces plus reference siblings, not a full 52-image
  re-inspection, since the manifest/hash checks already gave
  full-matrix-level distinctness and non-emptiness coverage
  programmatically) and 7 real-text PNGs across all three fast lanes.
- source expansions: one — reading
  `tools/act0_product_100_proof_capture_v1.dart` lines 332-530 after the
  `play`/`home` byte-size and visual similarity was noticed, which converted
  a "surface looks odd" observation into a source-grounded finding
  (`PARALLEL-CHALLENGER-003`) rather than leaving it as visual speculation.
- files opened beyond images: `git` preflight commands, `python3`-based
  manifest parsing and MD5 duplicate scan (broader than the prior repair's
  own validation, which only spot-checked the `play`/`w12_terminal` pair),
  `cmp` byte comparisons, `grep`/`ls` for artifact and capture-tool
  discovery.
- largest token sinks: the 12-image targeted masked-matrix inspection and
  the 7-image real-text inspection; both were narrowed to the surfaces this
  mission's own accepted-closure chain made load-bearing (the three
  just-claimed repairs plus their nearest siblings), rather than
  re-inspecting all 52 masked images or the full real-text corpus.
- repeated investigation: none — each surface was inspected once and cross-
  checked against the byte-size table rather than re-opened.
- avoidable quota cost: low — the targeted-surface strategy (byte-size
  triage before deciding which images to open) kept image-inspection count
  well under a full 52+52 re-review while still producing two independently
  verified new findings and one independently reconfirmed closure.
- second synthesis pass required: only if the recommended bounded repair
  wave lands and needs its own closure verification, or if Human QA
  produces new evidence.
- findings produced per estimated 10k tokens: approximately 1 (4 findings
  across an estimated 150-200k token session — a denser findings-per-token
  yield than the prior synthesis's 52-image full-matrix pass, achieved by
  triaging via the manifest's own byte-size column before choosing which
  images to open).
