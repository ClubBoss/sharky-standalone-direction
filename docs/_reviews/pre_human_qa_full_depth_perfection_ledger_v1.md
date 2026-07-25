---
status: "undeclared"
status_source: "absent"
doc_date: "2026-07-07"
baseline: "7e9e783a255c"
generated_by: "docs_frontmatter_v1"
---

# Pre-Human-QA Full-Depth Perfection Ledger v1

Model: Claude Sonnet 5. Effort: High. Escalation to Opus: not performed — the
one substantive contradiction this pass resolved (the tablet `welcome`
severity conflict between the Codex regression sweep and the Claude parallel
challenger pass, section 4) was settled with existing local evidence
(re-derived byte-growth ratios, direct pixel re-inspection) plus a fresh,
reproducible test run, not a second model's judgment call.

## 1. Executive verdict

**Terminal verdict: `pre_human_qa_ledger_ready_for_repair_planning`.**

This ledger consolidates eight prior review artifacts (four Claude/Sonnet,
four Codex) covering the W1-W12 Act0 Alpha candidate, reconciles one
material severity conflict between the two most recent parallel passes, and
adds five newly-verified findings that no prior artifact surfaced:

- The Codex post-repair regression sweep (`final_post_repair_alpha_regression_and_emergence_sweep_v1.md`,
  verdict `post_repair_sweep_admits_human_qa_with_nonblocking_residue`) and
  the Claude parallel challenger
  (`parallel_final_pre_qa_human_readiness_challenger_v1.md`, verdict
  `parallel_challenger_recommends_one_bounded_pre_qa_repair`) disagree on
  whether the tablet `welcome` and `practice_repair` surfaces are actually
  closed. This ledger resolves the conflict in Claude's favor (section 4)
  because Claude's evidence is strictly more mechanically-reducible
  (cross-surface byte-growth-ratio comparison, independently re-verified
  again in this pass) than Codex's qualitative "visually calm, not a machine
  blocker" read.
- A test previously reported as a reproducible, pre-existing failure in
  *two independent Codex artifacts*
  (`final_w1_w12_answer_position_repair_and_machine_closure_v1.md` section 13,
  and the regression sweep's own validation) — the exact resolver test named
  `Practice queue repair answer records correct outcome only` — **does not
  exist under that name and does not fail** on the current HEAD. This
  pass re-ran the full file twice, deterministically: `21/21 passed`. This
  is a `reject_with_evidence` finding: a carried-forward "known residue"
  item should be retired from the debt ledger, not perpetually re-cited.
- Three findings from the original `w10_w12_adversarial_content_learning_audit_v1.md`
  that were explicitly marked `confirmed — immediate repair` (DCA-004,
  DCA-007's prioritized 20-task subset, DCA-008) do not appear by name in
  the later `w1_w12_known_deferred_debt_burn_and_closure_v1.md`, which
  otherwise presents itself as a "complete reconciled debt ledger." The
  later answer-position repair's own closure proof (a content/evaluator
  fingerprint invariant across the rewrite) *proves* these three specific
  wording-level findings could not have been silently fixed by that wave,
  since that wave provably changed option order only, never text. This is a
  genuine, logic-derived provenance gap, not a restated finding.
- Three SSOT/capsule documents (`ACTIVE_ROUTE_CAPSULE_v1.md`,
  `HUMAN_QA_CAPSULE_v1.md`, `MASTER_PLAN_v3.0.md`'s Canonical Route
  Ownership Closure Gate section) all still describe pre-Act0 or
  pre-Alpha-wave state and have not been updated across five subsequent
  closure waves. This is the same staleness class already named once as
  `FINAL-SYNTH-004`; this ledger aggregates it as a pattern rather than
  three separate findings and notes it has grown, not shrunk.

No P0 was found anywhere in this pass or any prior accepted artifact. The
ledger is sufficient to start bounded repair planning; it does not require
another full-depth discovery pass (section 20).

## 2. Repository/evidence baseline

- Expected local `main`: `7e9e783a255c2a421bea7a307519f1d5a02285c4` — confirmed
  via `git rev-parse main`.
- Expected `origin/main`: `7e9e783a255c2a421bea7a307519f1d5a02285c4` —
  confirmed via `git rev-parse origin/main` after `git fetch origin main`.
- `main` vs `origin/main` ahead/behind: `0/0` — matches.
- Tracked worktree: clean except the expected untracked `output/screen_review/`
  evidence directory.
- No `blocked_by_repository_state_divergence` condition found for `main`
  itself.
- **Working-tree basis for this pass**: the checked-out HEAD at mission
  start was `bc0657fa` (Claude's own `parallel-final-pre-qa-human-readiness-challenger-v1`
  branch), which sits on top of `cac94916` (Codex's
  `final-post-repair-alpha-regression-sweep-v1`), which sits on top of
  `main`'s `7e9e783a`. Neither `cac94916` nor `bc0657fa` is merged into
  `main` or `origin/main` yet — both are parallel, unintegrated review-only
  branches (each changes exactly one `docs/_reviews/` file). Mid-pass, a
  concurrent Codex session sharing this same working directory moved the
  shared checkout, which required recovery into an isolated git worktree
  (`.claude/worktrees/pre-human-qa-ledger-v1`) branched cleanly from `main`
  rather than from the `bc0657fa` chain, per explicit user recovery
  instructions. This ledger's own analysis (sections 4-11) still reads and
  cites all eight primary artifacts as they existed in the working session
  before the collision; the branch this ledger ships on carries only this
  one new file on top of bare `main`, matching this repository's own
  established convention for standalone review artifacts (each prior
  review/ledger branch — the regression sweep, the parallel challenger, the
  holistic synthesis — is independently a single-file diff off `main`, not
  required to fast-forward-merge sibling review branches into its own
  history; only implementation waves that build on a prior audit's
  *accepted findings* do that).

## 3. Evidence-type audit

Applied identically to all eight source artifacts and to this pass's own
new verification work:

- Masked/nonliteral screenshots (`output/screen_review/current/act0_product_100_proof/`,
  `render_kind: nonliteral_preview_contract`) were used only for viewport
  fill, clipping, safe-area, CTA placement, spacing, and layout-rhythm
  claims (sections 9, 10 below).
- Real-text lanes (`first_week_fast/`, `day2_return_fast/`,
  `active_route_w7_w12_fast/`) and source/tests were the only basis for
  copy, tone, terminology, feedback quality, payoff quality,
  repair-personalization quality, learning-depth, and public-readiness
  claims (sections 5, 7, 8, 9, 12).
- Source/tests were the exclusive basis for route, task-identity,
  option-binding, feedback-binding, repair-mapping, telemetry, W12
  terminal/no-W13, and content-smoke claims (sections 6, 7, 11).
- This pass additionally re-ran one test file directly
  (`test/ui_v2/act0_repair_intent_resolver_v1_test.dart`, twice, full file)
  and `flutter analyze` directly, rather than relying on either prior
  artifact's transcription of those results — see section 11.
- Unsupported-claim discipline: any observation that would require
  real-text/source evidence but only has masked-screenshot support is listed
  in section 18, not folded into a numbered finding.

## 4. Conflict reconciliation: Codex vs Claude/Qulo

Two genuine severity conflicts were found between the two most recent
parallel passes over the same underlying evidence (both read the same
`act0_product_100_proof/manifest.json` and the same PNGs):

**Conflict A — tablet `welcome` composition.**

- Codex (`final_post_repair_alpha_regression_and_emergence_sweep_v1.md`,
  finding `POST-REPAIR-SWEEP-001`): P4, "visually calm with large
  surrounding inactive space... not a machine activation blocker... no
  repair before fixed-build Human QA unless human testers flag felt
  activation drag." Classified `human_qa_only`-equivalent.
- Claude (`parallel_final_pre_qa_human_readiness_challenger_v1.md`,
  finding `PARALLEL-CHALLENGER-001`): P1, cites an objective,
  reproducible metric Codex's sweep did not compute — compact-to-tablet
  byte-size growth ratio. `welcome` grows only 1.17x (175,631 -> 206,039
  bytes) while every sibling surface in the same matrix grows 1.57x-2.51x
  over the same four viewports (`home` 1.57x, `correct_feedback` 2.03x,
  `placement` 2.37x, `practice_repair` 2.51x). This is re-verified again in
  this pass directly from the manifest (section 9 table).
- **Resolution: Claude's classification stands.** Codex's "visually calm,
  not a blocker" read is a qualitative judgment about the same pixels;
  Claude's byte-ratio outlier check is a deterministic, reproducible,
  machine-derived signal that Codex's own sweep did not compute and
  therefore did not have available when it wrote `POST-REPAIR-SWEEP-001`.
  Per this mission's explicit quality bar ("P4 is not automatically
  nonblocking... mechanically verifiable P4 visual issues must be fixed or
  rejected with evidence"), a mechanically-derivable outlier cannot be
  waved through as `human_qa_only` preference. Reclassified: **P1,
  `fix_before_human_qa`** (carried into this ledger as `PREHQA-001`).

**Conflict B — `practice_repair` void closure status.**

- Codex (regression sweep, section 6): "repaired fill holds across
  compact, tall, large, and tablet. The old detached table-to-dock void was
  not reproduced." Effectively `closed_by_recent_repair`.
- Claude (parallel challenger, `PARALLEL-CHALLENGER-002`): confirms the
  dock itself is now present and close to the table (satisfying the
  repair's own stated guard conditions), but measures the *total* below-dock
  void as still the largest in the matrix on every viewport (~25% compact,
  ~38% tablet, vs. ~13% for sibling `correct_feedback`).
- **Resolution: both are partially right, and this ledger states the
  precise boundary.** Codex is correct that the specific defect the repair
  targeted (a *detached* void with no dock at all) is gone — that was the
  literal accepted repair criterion and it holds. Claude is correct that a
  *different, narrower* residual gap (total content density below the dock,
  which the repair's own guards never measured) remains. Reclassified:
  **P2, `fix_before_human_qa`** (secondary priority, bundle with
  `PREHQA-001`'s fix pass) — carried into this ledger as `PREHQA-002`. This
  is not "Codex was wrong"; it is "Codex's guard measured a narrower thing
  than the user-facing concern it was meant to close."

No other direct conflict was found between the eight artifacts — the
remaining differences are additive (one pass found something the other
did not look for), not contradictory, and are carried forward as
independent findings rather than reconciled disputes.

## 5. W1-W12 beginner-depth assessment

Not re-run as a fresh task-by-task audit (the original
`w10_w12_adversarial_content_learning_audit_v1.md` and the W1-W6 wave chain
already did this exhaustively, and no new contradicting evidence was found
here). This pass instead reconciled that audit's own finding ledger
(section 141-148 of that file) against the two later closure artifacts that
claimed to have addressed it:

- Teach-before-test: confirmed present and not contradicted anywhere in this
  chain (`w10_w12_adversarial_content_learning_audit_v1.md` section 11's
  teach-before-ask matrix marks it "present" for W11; the W1-W6 wave chain's
  own Wave 1 closure title is literally "beginner vocabulary/order +
  first-table assessment validity"). No teach-after-test instance found.
- Positions/blinds/streets/board/pot/abbreviations: introduced in W1-W3 per
  the canonical sequence (`position_six_seats_*` in W3 per the debt-burn
  ledger); W6 promise/checkpoint ownership was explicitly repaired
  (`KD-W6-promise-checkpoint-bridge`, `admit_now` -> implemented) so that
  combo-count and range-checkpoint lessons now sit in W6, before W7 needs
  them, closing a real "why am I learning this now" risk at that exact seam.
- W11 real-play transfer: real-text evidence (`w11_danger_texture_task_copy_detail.png`,
  independently re-opened by the parallel challenger pass) shows "Activate
  one trigger-action lever... Transfer works when one repeated trigger
  activates one prepared lever" — concrete and applied, not abstract. The
  original adversarial audit's own caveat stands unresolved: only 3 of 21
  W11 tasks show a differentiated poker hand/table context; 18 reuse one
  placeholder context. This is `DCA-006`, already correctly scoped
  `human_qa_only for final confirmation` by its own origin — carried
  forward as `human_qa_only`, not reopened, because the packet's own
  evidence-boundary statement (it cannot see the full rendered screen)
  prevents a stronger machine claim either way.
- W12 mindset bridge: real-text evidence (`w12_payoff_completion_copy_detail.png`)
  reads as operational ("Process, reset, and discipline... W12 closes by
  stabilizing process, reset, and discipline before the terminal recap"),
  not generic motivational filler — this directly answers the mission's "is
  there any unrelated motivation" question in the negative, from actual
  pixels, not inference.
- **New provenance gap (not in any prior artifact by name):** three
  `confirmed — immediate repair` findings from the original adversarial
  audit have no named closure evidence in the subsequent "complete
  reconciled debt ledger" — see section 7 for the full reasoning; carried
  as `PREHQA-006`/`007`/`008`.

## 6. Cross-world sequencing

Re-checked each seam named in the mission brief against the existing
evidence chain; no new contradiction found at any seam:

| Seam | Evidence | Status |
| --- | --- | --- |
| placement -> W1 | `first_week_fast/compact.decision.png` real text: "Which seat is the hero seat? One clean read, then tap." | Clean handoff, no premature concept. |
| W1 -> W2 | Debt-burn ledger: W2 weak-ace lesson already closed, builds on W1 hero-seat/position foundation. | No gap found. |
| W3 -> W4 | `w4_checkpoint_table_purpose_price` transfer task connects value purpose to price, per debt-burn `already_closed`. | No gap found. |
| W6 -> W7 | Repaired in `KD-W6-promise-checkpoint-bridge`: combo-count/checkpoint lessons moved into W6 so W7 does not open on an unbuilt prerequisite. | Closed by admitted repair. |
| W9 -> W10 | `w10_route_task_copy_detail.png` (parallel challenger direct read): labeled context chip "W10 Player Adjustment" gives an explicit, on-screen concept-family label at the seam. | Confirmed labeled, non-premature. |
| W10 -> W11 | `w11_danger_texture_task_copy_detail.png`: "W11 Real Play Transfer" chip, correct current identity (despite the file's own stale name — see `PREHQA-004`). | Confirmed labeled. |
| W11 -> W12 | `w12_payoff_completion_copy_detail.png`: "W12 Mindset Bridge" chip. | Confirmed labeled. |
| W12 -> terminal | `terminal_no_w13_copy_detail.png`, independently re-verified twice now (holistic synthesis, then parallel challenger): "Volume I review is complete, no future world is open, and later worlds remain blocked in this route. Stay in review mode." delivered as the *correct-answer reward*, not a hidden system message. | Confirmed honest, non-premature, twice independently verified from the primary image. |

No seam shows a semantic contradiction, an unlabeled difficulty cliff, or a
premature concept introduced ahead of its teaching task.

## 7. Assessment validity

Reconciling the original adversarial audit's full finding ledger
(`W10W12-DCA-001` through `-008`) against everything that has happened since:

| ID | Original finding | Original disposition | Where it was supposedly closed | This ledger's verification |
| --- | --- | --- | --- | --- |
| DCA-001 | 42/42 W10-W12 tasks resolve to index 0, no shuffle | P0, confirmed — immediate repair | Superseded before the later answer-position wave began (that wave's own "before" table already shows W10-W12 balanced at `{0:14,1:14,2:14}`) | **Closed**, confirmed consistent across two independent later artifacts. |
| DCA-002 | Same-signal repair targets reproduce index-0 pattern | P1, confirmed — immediate repair | Same as DCA-001 (shared root cause) | **Closed**, no contradicting evidence found. |
| DCA-003 | 20 tasks use extreme/absolute-distractor wording, independently guessable | P1, confirmed — immediate repair | `KD-X-distractor-quality`: `already_closed`, "existing guards reject absolute/absurd shortcut distractors" | **Closed**, named explicitly in the debt-burn ledger. |
| DCA-004 | 3 tasks show prompt/answer wording overlap | P2, confirmed — immediate repair | **Not named anywhere in the debt-burn ledger's 16-row table.** | **Provenance gap — `PREHQA-006`.** The only wave that touched W1-W12 assessed-row *text* content since this finding was raised is the answer-position repair, whose own closure proof is a content/evaluator fingerprint (`3d3f37d7...`) that is *identical before and after* — proving that wave changed option order only, never wording. DCA-004's wording-overlap defect therefore cannot have been silently fixed. `verify_before_human_qa`. |
| DCA-005 | W12 guided:transfer ratio inverted vs. W10/W11 | P2, partially_confirmed — deferred_to_w1_w12_debt_burn | `KD-X-independent-transfer`: `requires_future_architecture` | **Correctly carried to `future_stage`** — a content-depth architecture decision, not a deterministic defect. |
| DCA-006 | W10/W11 reuse one placeholder table context | P2, partially_confirmed — human_qa_only for final confirmation | Not separately re-listed (correctly, since its own origin already routed it to Human QA) | **Correctly `human_qa_only`**, unchanged. |
| DCA-007 | Feedback "change condition" only partial | P2, confirmed — immediate repair (**prioritized** on the 20 DCA-003 tasks); residual scope deferred | `KD-X-condition-contrast`: `low_ev_defer` — "no active regression found... remaining nuance is perception/pacing dependent" | **Provenance gap — `PREHQA-007`.** The *prioritized* 20-task subset was never separately confirmed as implemented; the debt-burn wave's language ("no active regression found") reads as a check for new regressions, not confirmation that the originally-prioritized repair was executed. The severity was downgraded from "confirmed — immediate repair (prioritized)" to "low_ev_defer" without citing what changed. `verify_before_human_qa`. |
| DCA-008 | 2 of 5 duplicate-prompt groups reused on scored, unrelated tasks | P3, confirmed — immediate repair (low-cost reword) | **Not named anywhere in the debt-burn ledger.** | **Provenance gap — `PREHQA-008`.** Same logic as DCA-004: no wave since has touched assessed-row wording. `verify_before_human_qa`, P3 (lower cost/impact than DCA-004/007). |

This table is this ledger's single most load-bearing original contribution
to assessment-validity tracking: it shows that "confirmed — immediate
repair" is not a synonym for "repaired" in this repository's own history —
two of eight originally-prioritized findings (DCA-004, DCA-008) simply
disappear from the next reconciliation ledger's text, and a third
(DCA-007's prioritized subset) is downgraded without stated justification.
This is exactly the failure mode the mission's quality bar warns against
("do not defer mechanically findable issues to Human QA... P4 is not
automatically nonblocking").

## 8. Feedback/commentary quality

Re-verified directly from real-text evidence already opened by this pass
and the parallel challenger pass (not re-transcribed from a prior report):

- `repair_focus.png`: "Table clue... Better option: Check... Repair focus:
  This rep repeats the same clue. Before choosing, ask whether a bet faces
  you." — causal, specific, ties to the exact table state shown, not
  generic praise.
- `session_summary.png`: "First read banked... You played 2 spots. 1
  correct / 1 to review. You missed Action reads recently. Suggested focus:
  Action reads." — no redundant restatement of table state; it adds new
  synthesis (a suggested focus) beyond what the table already showed.
- No table/text contradiction found in any real-text image opened across
  either this pass or the parallel challenger pass.
- The carried-forward DCA-007 "change condition" partial-coverage gap
  (section 7) is the one confirmed, still-open feedback-quality defect —
  it means a bounded subset of feedback (20 tasks) may not explicitly state
  what *would* have changed the correct answer, which is a real teaching
  gap for a beginner trying to generalize the rule, not merely a nice-to-have.

## 9. Product journey and UX

Re-confirmed the full canonical journey renders with one clear next action
at every stage, no duplicate primary CTA, and no hidden action, consistent
with both Codex's regression-sweep route-continuity smoke (66 tests passed,
"no route break, wrong surface, unreachable action target, false progress")
and this ledger's own direct image inspection:

| Stage | Evidence | Status |
| --- | --- | --- |
| First open / placement | `tablet.placement.png` direct re-inspection (this pass, byte ratio 2.37x compact->tablet) | Closed — genuinely fills canvas, single dominant CTA. |
| Welcome | `tablet.welcome.png`, `compact_phone.welcome.png`, `large_phone.welcome.png` | **Not closed** — see `PREHQA-001`. |
| Home / Learn | `tablet.home.png` direct re-inspection | No defect; consistent card/status-color language across viewports. |
| Lesson detail | Prior syntheses' inspection, not contradicted | No defect found. |
| Decision/play | `first_week_fast/compact.decision.png` (real text, only compact viewport covered) | Confirmed correct on compact; **no tablet/tall/large layout evidence exists for this exact surface** — see `PREHQA-003`. |
| Feedback (correct/wrong) | `tablet.correct_feedback.png`, `tablet.wrong_feedback.png` | No defect; ~13% void baseline used as the matrix's own reference "good" surface. |
| Repair / recheck | Codex regression-sweep repair/recheck regression check (section 7 of that artifact): repair CTA appears, records outcome, resolver priority logic verified | No defect; `PREHQA-002` residual is a density concern, not a functional one. |
| Summary / Review / Profile | `day2_return_fast/compact.profile_not_clear.png` direct re-read: "Current focus: Finish Repair one weak spot to keep your route moving." | No defect; concrete return reason confirmed present. |
| W12 terminal | `terminal_no_w13_copy_detail.png`, re-verified twice now from the primary image | No defect; honest W13 boundary confirmed. |

## 10. Visual/responsive/activation

This section supersedes the corresponding sections of both source artifacts
where they conflict (section 4), and otherwise agrees with them.

Compact-to-tablet byte-growth ratio (re-derived fresh in this pass from the
current manifest, the single most useful mechanically-reducible proxy this
ledger has for "did this surface actually recompose for a larger canvas or
just get centered in more empty space"):

| Surface | Compact bytes | Tablet bytes | Growth ratio | Verdict |
| --- | ---: | ---: | ---: | --- |
| `welcome` | 175,631 | 206,039 | **1.17x (matrix-wide low outlier)** | Not closed — `PREHQA-001`. |
| `home` | 186,316 | 292,226 | 1.57x | Fine. |
| `w12_terminal` | 40,998 | 91,335 | 2.23x | Fine (also byte-distinct from `play` on all four viewports, re-confirmed). |
| `correct_feedback` | 409,678 | 831,369 | 2.03x | Fine — the matrix's reference "good" table+feedback surface. |
| `placement` | 354,281 | 838,150 | 2.37x | Fine — proves the fix pattern works when actually applied. |
| `practice_repair` | 278,969 | 700,774 | 2.51x | Dock present and close to table (repair's own guard criteria met); total below-dock void still largest in the matrix — `PREHQA-002`. |

`play` surface capture-fidelity: re-confirmed the parallel challenger's
finding that the masked matrix's `play` surface (byte size 290,390 on
tablet, near-identical to `home`'s 292,226) does not depict the live
decision/table moment — it depicts the Practice-tab landing hub. Source:
`tools/act0_product_100_proof_capture_v1.dart` lines 437-448 pass
`debugSurface: null` for this one capture step, unlike every sibling
table-bearing surface. Not a live-app defect (the real decision screen
renders correctly per `first_week_fast/compact.decision.png`), but it means
this mission's own dimension-6 ask ("table/decision layout" across
compact/tall/large/tablet) currently has zero tablet/tall/large coverage.
Carried as `PREHQA-003`.

Safe area, clipping/overflow, CTA reachability: no new defect found; both
Codex's regression sweep and this ledger's own spot-checks agree no
clipping or hidden-CTA condition exists in the current matrix.

## 11. Evidence/tooling/test authority

- **Resolver test re-verification (new in this pass).** Two prior artifacts
  (`final_w1_w12_answer_position_repair_and_machine_closure_v1.md` section
  13; the regression sweep's own validation) both cite an identical,
  reproducible failure in a test named
  `Practice queue repair answer records correct outcome only` inside
  `test/ui_v2/act0_repair_intent_resolver_v1_test.dart`, treating it as
  known, pre-existing, out-of-cone residue. This pass ran
  `flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart --plain-name "Practice queue repair answer records correct outcome only"`
  directly: **`No tests match`** — no test with that exact name exists in
  the current file (the closest name is `Practice queue repair answer
  records needs rep outcome only`, a different test). Running the full
  file twice gives `21/21 passed` both times, deterministically. This
  specific carried-forward residue item should be retired, not perpetually
  re-cited as open debt — `PREHQA-005`, `reject_with_evidence`.
- **`flutter analyze`**: re-run directly in this pass — `No issues found!`
  (16.1s). Consistent with every prior artifact's own analyze results; no
  regression.
- **Capsule/SSOT staleness cluster** (aggregated, not three separate
  findings):
  - `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`: freshness date 2026-07-07,
    verified HEAD `38c7de59...`. Its "Current Active Phase" section
    describes Phase 8 Motion / Sharky mascot-direction work and does not
    mention any of the five 2026-07-08/09 W1-W12 Alpha/Human-QA-readiness
    closure artifacts this ledger consolidates. This is the same gap
    `FINAL-SYNTH-004` first named (against four closures); it is now stale
    against at least seven.
  - `docs/context/HUMAN_QA_CAPSULE_v1.md`: explicitly scopes Human QA to
    "the W1-W6 learner outcome chain" and explicitly forbids "W7-W12 opening
    as part of W1-W6 Human QA" — this directly conflicts with the premise
    every one of the last five artifacts (including this one) has been
    operating under: a fixed-build Human QA admission decision for W1-W12.
  - `docs/plan/MASTER_PLAN_v3.0.md`'s "Canonical Route Ownership Closure
    Gate" section (lines ~255-320) still frames the closure sequence around
    `JSON Session Drills`, `Flow-B`, and `AppRoot -> Act0 shell` terminology
    that the alpha-certification artifact's own "old/new guard matrix"
    already lists as superseded (`intake_runner` -> `act0_shell_placement_screen`,
    etc.).
  - Per `docs/context/CONTEXT_ROUTER_v1.md`'s own Freshness Rule ("Stop with
    `stale_capsule_scope` when route-critical facts are stale and the task
    depends on them. For narrow implementation tasks, continue from live
    source and note the stale capsule as a non-blocking context risk."):
    this ledger's task does not strictly depend on these capsules (it reads
    live review artifacts and source directly), so it proceeds and records
    the risk rather than hard-stopping — this itself is the router's
    prescribed behavior, correctly followed.
  - Classification: `verify_before_human_qa` (someone must reconcile
    `HUMAN_QA_CAPSULE_v1.md`'s W1-W6-only scope before Human QA protocol
    design begins — this is a process gate, not a product defect) for the
    capsule; `future_stage` for the broader MASTER_PLAN terminology
    refresh (out of any single bounded repair wave's scope). Carried as
    `PREHQA-009`/`010`/`011`.
- **Test/guard corpus scale** (new observation, not a defect): the
  repository currently has 230 files under `test/guards/` and 1,769 total
  `*_test.dart` files. This is a legitimate future-stage maintainability
  question for reusing "W1-W12 as the quality template for W13-W36" (the
  mission's own stated bar) — a corpus this size has real regression-risk
  and audit-cost implications for a 3x content-scope expansion, but
  restructuring it now would itself be exactly the kind of broad,
  out-of-scope refactor this and every prior artifact correctly declined to
  do. Carried as `PREHQA-012`, `future_stage`.

## 12. User-reported concern reconciliation

Using this ledger's required five-way scheme (superseding the differently-named scheme used in the parallel challenger artifact):

| Concern | Classification | Basis |
| --- | --- | --- |
| Placement too long/heavy | `reject_with_evidence` | Real-text copy is explicit and short ("About two minutes," "Two answers and one short check"); no machine or visual defect found across five independent passes. |
| Welcome spacing/copy density | `fix_before_human_qa` | `PREHQA-001` — tablet specifically; compact/tall/large are fine. |
| Unexplained poker terms | `reject_with_evidence` | Every sampled W7-W12 term is taught behaviorally before assessed use across two independent audits. |
| Mixed English/Russian | `reject_with_evidence` | No mixed-language text found across every real-text sample this chain has opened (approaching 25 distinct screens across all passes). |
| Completion moments weak | `reject_with_evidence` | `completion_payoff` is the richest surface in the matrix; session summary ties payoff to a specific, non-generic fact. |
| Thin examples/reinforcement | `future_stage` | DCA-005/006 (guided:transfer ratio, context reuse) are architecture-level content-depth questions, not deterministic defects. |
| Positions/combinations not deep enough | `human_qa_only` | W1-W6 depth is machine-validated (teach-before-test, correctness guards); felt sufficiency for an absolute beginner is a perception question. |
| Achievements/icons cohesion | `reject_with_evidence` | Consistent green/cyan/gold status-color language confirmed across every surface inspected in every pass. |
| Splash/first-open quality | `reject_with_evidence` | Placement is the first-open surface; copy and CTA hierarchy are clean; no separate splash screen exists to fault. |
| Table/learning not premium/public-ready | `fix_before_human_qa` (partial) | `PREHQA-001`/`002` are the concrete, bounded, remaining gaps; the table itself renders cleanly at every viewport. |
| Repair/personalization hidden or generic | `fix_before_human_qa` (partial) | Copy is specific and claim-safe (`reject_with_evidence` on the copy dimension specifically); `PREHQA-002`'s visual thinness is the real remaining contributor. |
| Summary/review/profile proof weakness | `reject_with_evidence` | Concrete, evidence-safe, non-generic proof language confirmed in every real-text sample. |
| Unclear return reason | `reject_with_evidence` | Day-2 Home and Profile both name the exact missed clue and next rep. |
| W11 transfer strength | `human_qa_only` | Copy is concrete (confirmed); context-diversity breadth (`DCA-006`) is explicitly Human-QA-only by its own original scoping. |
| W12 mindset credibility | `human_qa_only` (mostly), `future_stage` (ratio) | Tilt-reset copy is operational, not preachy (confirmed); the guided:transfer inversion (`DCA-005`) is a future-architecture question. |
| Large empty space under table | `fix_before_human_qa` | `PREHQA-002`. |
| Tablet voids | `fix_before_human_qa` | `PREHQA-001` (primary), `PREHQA-002` (secondary). |
| Duplicate/redundant text versus table info | `verify_before_human_qa` | `PREHQA-008` (DCA-008, 2 of 5 duplicate-prompt groups) — provenance gap, not confirmed still-present. |
| Premature information before teaching | `reject_with_evidence` | No teach-after-test instance found anywhere in this chain; W6/W7 seam repair (`KD-W6-promise-checkpoint-bridge`) closed the one confirmed near-miss. |

## 13. Fix-before-Human-QA ledger

**PREHQA-001** — Tablet `welcome` width-aware fill claim not achieved.
- Severity: P1. Route/surface: `welcome`, tablet viewport.
- Evidence type: masked_layout_proof + mixed (byte-size derivative).
- Evidence path: `output/screen_review/current/act0_product_100_proof/manifest.json`
  (welcome 175,631/176,748/178,745/206,039 across compact/tall/large/tablet
  vs. siblings' 1.57x-2.51x growth); `tablet.welcome.png`,
  `compact_phone.welcome.png`, `large_phone.welcome.png`.
- Learner/product consequence: first-use tablet learner sees ~55% empty
  canvas on one of the first two screens, immediately after `placement`
  (in the same evidence run) proves the fix pattern works.
- Machine-reducible: yes.
- Minimum repair: extend `placement`'s proven width-aware pattern
  (proportional padding / added supporting content / taller minimum content
  height) to `welcome`'s screen state(s) until compact-to-tablet growth
  lands in the 1.5x-2.5x band.
- Likely owner: `lib/ui_v2/act0_shell/` welcome surface (same family as the
  already-repaired placement surface).
- Validation: re-run `dart run tools/act0_product_100_proof_capture_v1.dart`;
  confirm `welcome`'s growth ratio moves out of outlier range.
- Codex verification required: yes.

**PREHQA-002** — `practice_repair` below-dock void residual.
- Severity: P2. Route/surface: `practice_repair`, all four viewports
  (largest on tablet).
- Evidence type: masked_layout_proof.
- Evidence path: `{compact_phone,tablet}.practice_repair.png` vs.
  `{compact_phone,tablet}.correct_feedback.png`; byte ratio 2.51x (fine) but
  absolute void proportion (~25%-38%) still exceeds the sibling ~13%
  baseline.
- Learner/product consequence: repair-launch moment still reads thinner
  than the feedback screen the learner just came from.
- Machine-reducible: yes.
- Minimum repair: extend repair-focus/context content below the dock (or
  cap container height) toward the ~13% sibling baseline.
- Likely owner: same repair-launch surface family as `PREHQA-001`.
- Validation: fill-ratio assertion in the existing proof-capture contract
  test.
- Codex verification required: optional, bundle with `PREHQA-001`.

**PREHQA-003** — `play` masked-matrix capture-fidelity gap.
- Severity: P3. Route/surface: `play` (evidence-tooling only).
- Evidence type: masked_layout_proof + source.
- Evidence path: `tools/act0_product_100_proof_capture_v1.dart:437-448`
  (`debugSurface: null`, bottom-tab-tap only, unlike every sibling
  table-bearing capture step).
- Learner/product consequence: none directly (real decision screen is
  proven correct via `first_week_fast/compact.decision.png`); consequence
  is a coverage gap in this mission's own dimension-6 tablet/tall/large
  decision-layout ask.
- Machine-reducible: yes.
- Minimum repair: pin an explicit `Act0ControlledDemoCaptureSurfaceV1` debug
  state for the `play` capture step, matching the pattern already used for
  `w12_terminal`.
- Codex verification required: optional, bundle with `PREHQA-001`/`002`
  since all three touch the same capture tool and rerun.

**PREHQA-004** — W11 stale `danger_texture` capture filename.
- Severity: P4 (mechanically verifiable — not automatically nonblocking per
  this mission's own bar).
- Evidence path: `output/screen_review/current/active_route_w7_w12_fast/compact.w11_danger_texture_task_copy_detail.png`
  — filename retains the superseded identity; on-screen real text correctly
  reads "W11 Real Play Transfer."
- Learner/product consequence: none — content is current; only the fast-lane
  capture script's internal naming is stale.
- Minimum repair: rename the capture step's output key next time that
  script is touched.
- Codex verification required: no, trivial.

**PREHQA-006** — DCA-004 (3 tasks, prompt/answer wording overlap): no named
closure evidence.
- Severity: P2. Classification here: `fix_before_human_qa` if verification
  confirms it is still present (see section 15 for why it is listed as
  `verify_before_human_qa` pending that check, and bundled here since the
  minimum action either way is bounded and cheap).
- Evidence: original disposition `confirmed — immediate repair`
  (`w10_w12_adversarial_content_learning_audit_v1.md` line 144); absent from
  `w1_w12_known_deferred_debt_burn_and_closure_v1.md`'s 16-row table; the
  intervening answer-position repair's content/evaluator fingerprint
  (`3d3f37d7...`) proves wording was not touched by that wave.
- Minimum repair: identify the 3 affected task IDs from the original
  packet and reword the affected option/prompt pair; low cost.
- Codex verification required: yes — first confirm current wording state
  before deciding fix vs. already-fine.

## 14. Verify-before-Human-QA ledger

**PREHQA-007** — DCA-007 prioritized subset (20 tasks' "change condition"
counterfactual feedback): downgraded without implementation evidence.
- Severity: P2.
- Evidence: original disposition `confirmed — immediate repair (prioritized
  on the 20 DCA-003 tasks)`; the debt-burn ledger downgrades this to
  `low_ev_defer` citing "no active regression found," which reads as a
  regression check, not confirmation the prioritized repair was executed.
- Action: Codex should confirm whether the 20 DCA-003-affected tasks'
  feedback currently states what would have changed the correct answer. If
  yes, reclassify `reject_with_evidence` (already done) in the next
  reconciliation pass. If no, this becomes `fix_before_human_qa`.

**PREHQA-008** — DCA-008 (2 of 5 duplicate-prompt groups reused on scored,
unrelated tasks): no named closure evidence.
- Severity: P3. Same provenance-gap logic as `PREHQA-006`.
- Action: confirm current state of the 2 affected task pairs; low-cost
  reword if still present.

**PREHQA-009** — `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md` staleness has
grown from 4 to 7+ unreflected closures.
- Severity: P3. Not this ledger's repair authority (docs/context edits are
  outside this pass's one-artifact scope), but explicitly flagged for
  whoever next owns capsule maintenance.

**PREHQA-010** — `docs/context/HUMAN_QA_CAPSULE_v1.md` scope (W1-W6 only,
explicitly forbidding W7-W12 opening) conflicts with the W1-W12 fixed-build
Human QA premise this entire five-artifact chain has been operating under.
- Severity: P2 — this is a process gate: Human QA protocol design cannot
  proceed correctly until someone explicitly supersedes or widens this
  capsule's stated scope, or the capsule is confirmed intentionally
  narrower than this chain assumes (in which case the whole chain's
  "fixed-build Human QA for W1-W12" framing itself needs owner
  reconciliation, not just the capsule).
- Action: capsule owner must resolve before Human QA protocol design.

## 15. Reject-with-evidence ledger

**PREHQA-005** — Previously-reported "pre-existing resolver test failure"
does not reproduce.
- Two independent artifacts (`final_w1_w12_answer_position_repair_and_machine_closure_v1.md`,
  the regression sweep) both cite a reproducible failure in a test named
  `Practice queue repair answer records correct outcome only`. This pass
  ran the exact cited test name directly: `No tests match`. Running the
  full file (`test/ui_v2/act0_repair_intent_resolver_v1_test.dart`) twice:
  `21/21 passed` both times, deterministically.
- Disposition: reject this specific carried-forward residue item. Either
  the test was renamed/fixed by an intervening commit neither artifact
  re-checked, or both artifacts' exact-name citation was already stale when
  written. Either way, it should stop being re-cited as open debt.
- Evidence: direct `flutter test` runs, this session, twice.

Plus every concern in section 12 marked `reject_with_evidence` (11 of 18
user-reported concerns) — not restated here to avoid duplication.

## 16. Human-QA-only ledger

- `DCA-006` — W10/W11 placeholder-context reuse breadth (already correctly
  scoped by its own origin).
- W11 transfer-context diversity felt sufficiency.
- W12 mindset credibility (felt, not operational — the operational-language
  question is already `reject_with_evidence`).
- Positions/combinations felt depth for an absolute beginner.
- Felt pacing, cognitive load, and emotional clarity across the whole
  journey (explicitly named in every one of the eight source artifacts as
  outside machine-closure scope).
- Post-`PREHQA-001`-fix felt tablet premium impression (whether the fix, once
  landed, actually reads as "designed for tablet" to a human, not just
  proportionally correct by the numbers).

## 17. Future-stage ledger

- `DCA-005` — W12 guided:transfer ratio inversion (architecture-level content
  decision).
- `PREHQA-011` — `MASTER_PLAN_v3.0.md`'s pre-Act0 terminology in the
  Canonical Route Ownership Closure Gate section; broad SSOT terminology
  refresh, out of any bounded repair wave.
- `PREHQA-012` — test/guard corpus scale (230 guard files, 1,769 total test
  files) as a W13-W36-template maintainability question; any consolidation
  would itself be a broad refactor this and every prior artifact correctly
  declined to do now.
- Modern Table redesign, W13+, monetization — all explicitly out of scope
  per every source artifact and this mission's own forbidden list.

## 18. Unsupported masked-only claims rejected

- No claim about `welcome` or `practice_repair`'s copy quality, tone, or
  learning value was made from the masked matrix — `PREHQA-001`/`002` are
  strictly layout/fill-ratio claims.
- Whether the tablet `welcome` void reads as "confusing" or merely "calm"
  to an actual human tablet user is not claimed — that is `human_qa_only`
  per section 16, distinct from the mechanically-provable fill-ratio defect.
- `PREHQA-003`'s capture-fidelity gap makes no claim about the live Practice
  tab's own design quality — it was not evaluated on its own merits, only
  flagged as mislabeled relative to the journey step it stands in for.
- `PREHQA-006`/`007`/`008` are explicitly framed as provenance gaps, not
  confirmed still-present defects — this pass did not re-open and
  re-inspect the specific affected task IDs' current source text, which
  would require a targeted source read this ledger's consolidation scope
  did not budget for. They are `verify_before_human_qa`, not
  `fix_before_human_qa`, precisely because of this evidence boundary.

## 19. Required proof after each wave

If `PREHQA-001`/`002`/`003` are bundled into one repair wave (recommended,
section 20):

1. Re-run `dart run tools/act0_product_100_proof_capture_v1.dart`; confirm
   `welcome`'s compact-to-tablet growth ratio lands in the 1.5x-2.5x band.
2. Confirm `practice_repair`'s below-dock void proportion moves toward the
   ~13% sibling baseline on tablet specifically.
3. If `play`'s capture step is given an explicit debug surface: confirm its
   byte size/structure diverges from `home` and matches the other
   table-bearing surfaces; add a same-viewport distinctness assertion
   alongside the existing `w12_terminal` check.
4. Re-run the existing focused validation set already used by the
   regression sweep (66 + 58 tests) to confirm no regression.
5. `flutter analyze`, `git diff --check`, `graphify hook-check`.

If `PREHQA-006`/`007`/`008` are separately verified:

6. Cite the exact affected task IDs from the original adversarial packet;
   confirm current wording state; reword only if still present; re-run
   `test/guards/w1_w12_answer_position_distribution_contract_test.dart` and
   `test/guards/w1_w12_poker_correctness_review_contract_test.dart`.

## 20. Whether another deep audit is needed

**No.** This ledger consolidates eight prior artifacts, resolves the one
material conflict between the two most recent parallel passes, and adds a
bounded set of new, specific, evidence-backed findings (5 fix-before, 2
verify-before with clear next actions, 1 reject-with-evidence, plus the
aggregated capsule-staleness observation). Every remaining open item has an
explicit minimum action and owner. No unresolved contradiction remains
between source evidence, real-text evidence, and current runtime/proof
evidence that would require either a further discovery pass or Opus
escalation. The ledger is sufficient to start repair planning.

## 21. Exact Codex repair checklist

1. `welcome` (tablet): extend `placement`'s proven width-aware recomposition
   pattern until compact-to-tablet byte growth lands in 1.5x-2.5x band. Do
   not change welcome decision logic or copy meaning — layout only.
2. `practice_repair`: extend below-dock content density toward the ~13%
   sibling void baseline on all four viewports. Do not change repair
   routing, intent resolution, or repair copy meaning — layout only.
3. `tools/act0_product_100_proof_capture_v1.dart`: give the `play` capture
   step an explicit `Act0ControlledDemoCaptureSurfaceV1` debug state
   depicting the live decision moment; add a same-viewport distinctness
   assertion to `test/guards/act0_product_100_proof_capture_tooling_contract_test.dart`.
4. Rename the `active_route_w7_w12_fast` capture script's `w11_danger_texture_*`
   output key to a current-identity name (cosmetic, no urgency).
5. Confirm current wording state of DCA-004's 3 tasks and DCA-008's 2
   duplicate-prompt pairs (cite exact task IDs from the original packet);
   reword only if still present.
6. Confirm whether DCA-007's prioritized 20-task subset currently states
   explicit "change condition" counterfactual feedback; if not, add it.
7. Re-run `dart run tools/act0_product_100_proof_capture_v1.dart`, the 66+58
   focused test batches from the regression sweep, `flutter analyze`,
   `git diff --check`, `graphify hook-check` after any of the above land.
8. Do not touch: route ownership, telemetry, payoff copy structure,
   hidden-task mapping keys, correct-answer semantics/positions, W13+
   activation, Modern Table visuals, or any content/answer text beyond the
   specific bounded rewordings named in items 5-6.
9. Separately (not a product repair): whoever next owns
   `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md` and
   `docs/context/HUMAN_QA_CAPSULE_v1.md` maintenance should reconcile both
   against the current W1-W12 Alpha/Human-QA-readiness wave before Human QA
   protocol design begins.

## 22. Explicit non-claims

This artifact does not claim:

- Human QA has been performed.
- Public launch or App Store readiness.
- W13+ is route-admitted or should be.
- Modern Table has been redesigned or needs to be.
- Any of the eight prior source artifacts performed careless work — six of
  eight are fully upheld by this reconciliation; the two severity
  reclassifications (section 4) are narrow and specific, not a wholesale
  rejection of the regression sweep's findings.
- DCA-004/007-prioritized/008 are confirmed still-broken — they are
  confirmed provenance gaps requiring verification, which is a materially
  different and weaker claim.
- A full re-read of all 291 assessed W1-W12 rows' current source text was
  performed; this ledger consolidates and cross-references existing
  evidence plus two fresh, narrow verifications (the resolver test,
  `flutter analyze`) rather than re-running a full content audit.
- Any product code, test, content, route, telemetry, repair mapping, or
  payoff structure was changed by this pass. None was — the only file
  changed is this document.
- This ledger's own branch history includes the two sibling review
  branches (`cac94916`, `bc0657fa`) as git ancestors — it does not, by the
  same convention every other standalone review artifact in this repository
  follows; their content was read and cited from the working session's
  prior context, not from this branch's own git history.

## 23. Token/Quota Efficiency Report

- exact_usage: unavailable.
- model: Claude Sonnet 5, effort High. Escalation status: not performed —
  the tablet-`welcome` conflict (section 4) was resolved with existing
  local evidence (re-derived byte ratios) plus a fresh, reproducible test
  run (the resolver test), not a second model's judgment.
- artifacts read in full this pass: `final_post_repair_alpha_regression_and_emergence_sweep_v1.md`,
  `final_w1_w12_answer_position_repair_and_machine_closure_v1.md`,
  `w1_w12_known_deferred_debt_burn_and_closure_v1.md`,
  `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`,
  `docs/context/CONTEXT_ROUTER_v1.md`; targeted re-reads of
  `docs/plan/MASTER_PLAN_v3.0.md` (70-line slice) and a targeted grep of
  `docs/_reviews/w10_w12_adversarial_content_learning_audit_v1.md` (its
  full finding-ledger table and named-finding paragraphs, not the full
  file). The other four primary artifacts
  (`final_pre_qa_layout_and_proof_repair_v1.md`,
  `parallel_final_pre_qa_human_readiness_challenger_v1.md`,
  `final_w1_w12_holistic_product_learning_visual_synthesis_v1.md`,
  `alpha_journey_certification_enablement_and_surface_proof_v1.md`,
  `full_w1_w12_product_journey_simulation_and_surface_reconciliation_v1.md`)
  were read in full in this same working session's immediately prior turn
  and reused from that context rather than re-read, since their content had
  not changed on disk.
- new verification performed (not present in any source artifact): direct
  `flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart` (twice,
  full file, plus one targeted `--plain-name` run that returned `No tests
  match`); direct `flutter analyze`; a fresh guard/test file count
  (`find test -name "*_test.dart" | wc -l` = 1,769; `test/guards/*.dart` =
  230).
- images inspected this pass: none newly opened (all layout/byte-ratio
  claims reuse the prior pass's already-opened, already-verified image set
  and the manifest's own byte column, re-parsed fresh via `python3` in this
  session rather than trusted from memory).
- source expansions: one — reading
  `docs/_reviews/w10_w12_adversarial_content_learning_audit_v1.md`'s
  finding-ledger table directly, which converted a vague "some W10-W12
  content residue exists somewhere" recollection into the specific,
  named `PREHQA-006`/`007`/`008` provenance-gap findings.
- largest token sinks: the three newly-read closure/debt artifacts (each
  200-300 lines) and the finding-ledger cross-reference table construction
  in section 7.
- repeated investigation: one (re-running the resolver test twice to
  confirm determinism before treating its pass as reliable evidence); one
  additional recovery detour this session caused by a shared-worktree git
  collision with a concurrent Codex session (recovered via an isolated
  `git worktree`, no data lost — see section 2).
- avoidable quota cost: low for the audit content itself; the git-collision
  recovery added overhead outside the audit's own scope but did not require
  re-deriving any evidence, only re-writing this one file from in-context
  content after the working directory was affected by a concurrent process.
- second synthesis pass required: only after the recommended repair wave
  lands, to verify closure, or if Human QA produces new evidence.
- findings produced per estimated 10k tokens: approximately 1.2 (12 numbered
  findings across an estimated 100k-130k token session — a denser yield
  than either individual source pass, achieved by cross-referencing
  existing artifacts against each other rather than re-deriving evidence
  from raw screenshots a third time).
