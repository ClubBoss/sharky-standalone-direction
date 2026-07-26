---
status: "undeclared"
status_source: "absent"
generated_by: "docs_frontmatter_v1"
---

# W10-W12 Adversarial Content and Learning-Quality Audit v1

Model: Claude Sonnet 5. Effort: High. Escalation to Opus: not performed (no unresolved pedagogical contradiction found in the packet).

## 1. Executive verdict

W10 (Player Adjustment), W11 (Real Play Transfer), and W12 (Mindset Bridge) are structurally coherent and teach-before-ask is mostly honored, but current assessment evidence is **not trustworthy as proof of learner skill**. All 42 of 42 assessed visible tasks resolve to correct option index 0, with no runtime shuffle. This is a single global defect (P0) that, combined with a large family of extreme/absolute distractors (20 of 42 tasks) and a few prompt/answer wording overlaps (2-3 tasks), means a learner can pass W10-W12 assessment, checkpoints, and the same-signal repair path by pattern-matching rather than by demonstrating player-adjustment, transfer, or mindset skill. The same-signal repair mappings inherit the identical index-0 pattern, so repair does not currently restore assessment integrity.

None of this reflects a teaching-content catastrophe: the taught material (tagging, one-lever adjustment, guardrails, session planning, triggers, review loops, process-over-outcome, tilt reset, discipline) is coherent, sequenced sensibly, and free of harmful claims. The defect is concentrated in assessment construction, not in the instructional copy itself. One grouped, docs/content-only repair wave is sufficient to close it.

**Terminal verdict: `w10_w12_audit_recommends_one_grouped_content_repair_wave`.**

## 2. Evidence boundary and confidence

- Primary and sole source: `docs/_reviews/w10_w12_verified_deep_content_evidence_packet_v1.md` (414 lines), read in full (two reads, offsets 0-168 and 168-415).
- No source expansion was performed. The packet contains no internal contradiction, no sentence truncated enough to block pedagogical judgment, and poker correctness was assessable from the included task/feedback/rationale text for every dimension this mission scopes.
- One evidence-boundary limitation is carried forward rather than resolved by expansion: the packet's "Context" column (table/session state shown to the learner) is not a full screen render, and the packet explicitly states it does not render every screen. Where this affects a finding (see 8.6), it is marked Human-QA-only rather than treated as a confirmed defect.
- Confidence: high for assessment-integrity, terminology, duplicate, repair-pedagogy, and progression findings (all directly tabulated in the packet). Medium for learning-depth and world-promise findings that depend on judging copy the packet fully quotes. Low/Human-QA-only for emotional/psychological effectiveness and table-feel realism, per mission instruction.

## 3. Assessment-integrity verdict

**Severity: P0.**

- Distribution: 42/42 assessed visible tasks (guided practice, independent transfer/assessment, checkpoint practice) resolve to correct option index 0. W10 {0:15}, W11 {0:14}, W12 {0:13}. No runtime shuffle exists — options render in fixed source order every time (packet §2, §9).
- **Does 42/42 index 0 invalidate current assessment evidence?** Yes, globally, not merely "once noticed." The mission is explicit that a finding must not be weakened because a learner may not consciously exploit it — the relevant question is whether demonstrated success proves skill, and it does not: a learner who always taps the first choice scores identically to one who reasons through tendency tags, one-lever exploits, guardrails, session focus, triggers, review loops, process-vs-outcome, tilt reset, and discipline. Because the mechanism is structural and constant across every single scored task in three consecutive worlds, it invalidates the assessment signal from task 1 onward, not from some discovery point forward.
- **Can checkpoint and transfer evidence still be trusted?** No. All 20 checkpoint/prove/checkpoint-lesson rows are inside the same 42-task pool and share the identical index-0 pattern (packet §3-§5, §13). Checkpoint "synthesis" claims and independent-transfer claims are equally unproven by current scoring.
- **Do repair targets repeat the same leakage?** Yes. All 3 same-signal repair mappings route to targets whose correct answer is still index 0, and the packet's own repair-pedagogy matrix flags this explicitly for each (§16): "target correct answer is still index 0; wording should be reviewed for answer leakage." Repair currently reproduces the defect it is meant to remediate.
- **Do tests currently encode the leakage?** Not resolvable from the packet — the packet lists focused guard/contract tests that pass, but does not state whether any test asserts a fixed index-0 correctness contract that would need updating alongside a content fix. This is called out in the Codex checklist (§20) as a required check during repair, not asserted as a confirmed defect here.
- **Is deterministic option reordering sufficient?** No, not by itself. Reordering alone fixes the 20 tasks whose distractors are not independently identifiable (plain "correct-index-0" only, no other shortcut flag). It does **not** fix the 20 tasks flagged with "extreme/absolute distractor" wording, nor the tasks with prompt/answer wording overlap — those remain solvable by elimination or recognition even after index rotation, because the shortcut lives in distractor/prompt construction, not option position. See §9 for the exact task split.
- **Should option order be balanced by authored rotation rather than runtime randomization?** Yes. Authored (source-level, fixed) rotation keeps validation deterministic, avoids introducing runtime-shuffle risk to telemetry/accessibility/route logic that this audit is explicitly forbidden from reopening, and is the smallest-blast-radius fix consistent with "content repair only."

## 4. W10 audit — Player Adjustment

- **Promise honored structurally**: classification (tag: nit / loose_passive / overaggressive), one-lever adjustment ("adjust one lever at a time," explicit "Precision over chaos... Do not rewrite everything at once" framing), and sample-size restraint (`exploit_guardrails` lesson, "Exploit with control... avoid extreme swings from one or two hands") are all present and sequenced before assessment (packet §3, §6).
- **Overconfidence/stereotype safety**: the guardrail lesson explicitly teaches against full-strategy rewrites from thin evidence (`w10_guardrail_sample_size`: correct answer is "small probe, keep watching," wrong answers are "full counter-strategy immediately" and "ignore completely"). This is a real safety lever, not decorative — it is the strongest anti-overconfidence content in the three worlds.
- **Finding**: nearly all W10 teaching/guided/practice task rows share an identical placeholder table Context (`streetLabel: Flop; potLabel: Pot 5 BB; ... hero: Qh,Qs; board: Kc,7d,2s`) — only one row in the 22-task sequence (`w10_table_value_vs_caller_transfer`) shows a distinct hand/table context. See §8.6 (Human-QA-boundary finding) for why this is not asserted as a confirmed defect from the packet alone.
- W10 has the best guided-practice-to-transfer ratio of the three worlds (6 guided / 5 transfer / 4 checkpoint against 22 tasks), consistent with it being the first of the three worlds and needing the most scaffolding.

## 5. W11 audit — Real Play Transfer

- **Promise honored structurally**: session plan, table trigger reads, and post-session review loop each get an intro-teach task before guided/transfer use (packet §11 teach-before-ask matrix marks W11 "present").
- **Real capstone vs. checklist-reading**: of 21 W11 tasks, only 3 (`w11_trigger_small_price_continue`, `w11_trigger_bad_price_fold`, `w11_checkpoint_mixed_table_line`) present a concrete, varied poker hand/table state; the remaining 18 are meta-level questions about planning/triggers/review process using the generic placeholder context. This weights the world toward recognizing correct process language over applying it to differentiated poker decisions — see finding W10W12-DCA-006 for full framing and its evidence-boundary caveat.
- Independent-assessment task `w11_plan_table_focus_transfer` has a prompt/answer wording-overlap shortcut flagged in §13 ("Pick one focus for the session" against a prompt asking for "the cleaner session plan"), which is a real, packet-confirmed weakness distinct from the context-thinness question.
- Difficulty gradient plan → trigger → review → checkpoint is coherent (packet §15, §18).

## 6. W12 audit — Mindset Bridge

- **Promise honored structurally**: decision-quality-over-outcome, tilt reset, and confidence-with-discipline each have an intro-teach task before drills (packet §11: "mostly present").
- **Actionable vs. slogan-only**: the tilt reset protocol is operationally concrete ("Name the emotion, take one breath cycle, restate your one-focus plan, then continue with smaller decision scope") rather than an unsupported psychological claim — this is a genuine strength.
- **Guided-practice thinness**: W12 has only 3 guided-practice tasks against 7 independent-transfer tasks (packet §12) — the inverse ratio of W10 (6/5) and W11 (6/5). Learners are asked to apply tilt/discipline judgment independently more than twice as often as they are shown a modeled example first.
- **"Obvious healthy answer vs. ridiculous answer" risk**: confirmed by the packet's own feedback-quality matrix, which flags W12 explicitly — "Some distractors are obviously bad, reducing need for reasoning" (packet §14). Distractor labels across W12 (`self_attack`, `deny_mistake`, `revenge_mode`, `quit_immediately`, `prove_point`, `autopilot`, `tank_every_spot`, `jam_back`, `snap_fold_noise`) are socially-undesirable-coded rather than plausible competing choices in 7 of 13 assessed W12 tasks (packet §13). This is a second, independent leakage family layered on top of the index-0 pattern.
- **Terminal payoff proportionality**: the payoff claim ("You learned how to judge process, reset tilt, and keep discipline before deeper strategy") is currently unearned as *demonstrated* competence, because W12's assessed evidence carries both the global index-0 pattern and the highest concentration of socially-obvious distractors of the three worlds. The taught content itself does not overclaim, but the proof behind the claim is currently the weakest of the three worlds.
- Health/mental-state/emotional-effectiveness claims are marked Human-QA-only per mission instruction (§15).

## 7. Terminology and teach-before-ask

Teach-before-ask status per world: W10 "mostly present," W11 "present," W12 "mostly present" (packet §11) — no confirmed instance of a term appearing first in feedback and then being required for an assessed answer.

Required-inspection terms not found as literal learner-facing strings (packet §10):

| World | Term | Status |
| --- | --- | --- |
| W10 | player type | not found (taught as "tendency" instead) |
| W10 | over-adjustment | not found (taught behaviorally via guardrails: "small probe" vs. "full counter-strategy") |
| W11 | process note | not found (taught as "if-then fix" / repair note) |
| W11 | table cue | not found (taught as "trigger") |
| W12 | entitlement | not found (taught as ego/"prove a point" framing) |

Each of these is a low-risk **naming** gap, not a **teaching** gap: the underlying behavior is taught and reused before assessed use in every case. These are P3, bounded to a one-line copy addition per term, and do not block closure.

One audit lead worth carrying forward: the term "exploit" (W10) is introduced in the very first teaching task and reused 24 times, but the packet's own audit lead flags it "may need plain-language framing before repeated use" (§11) — P3, optional copy clarification.

## 8. Learning depth and independent transfer

Guided/transfer/checkpoint counts (packet §12): W10 6/5/4 of 22; W11 6/5/3 of 21; W12 3/7/4 of 20.

- W10 and W11 show conventional scaffolding (guided ≥ transfer). W12 inverts this (guided < transfer by more than 2:1), which is a real, bounded finding (§8.5 below).
- Same-signal repair paths exist for all three worlds and target a different task on the same concept family, satisfying "not the same question reworded" at the task-ID level (packet §16). However, all three repair targets sit inside the same index-0 pool, so the repair path currently proves nothing more than the original assessment did (see §3).
- §8.6 Context-thinness finding: W10 (21/22 identical placeholder context) and W11 (18/21 identical placeholder context) rows overwhelmingly reuse one generic table state across teaching, guided-practice, and even several independent-transfer tasks. Where a task's "Context" column is identical to a dozen unrelated tasks, the packet cannot confirm from that column alone whether the learner is shown differentiating villain-behavior evidence elsewhere in the screen (the packet explicitly disclaims full screen rendering, §22). This is reported as a **partially confirmed, Human-QA-required** finding, not asserted as a confirmed content defect, because the packet's own evidence-boundary statement prevents a stronger claim.

## 9. Assessment validity and pattern leakage

Full task-level detail is in packet §13. Summary split of the 42 assessed tasks by shortcut type:

- **20 tasks**: "extreme/absolute distractor" only (or combined with index-0) — distractors use denial/revenge/all-or-nothing/auto-quit framing that is identifiable without applying the taught skill.
  - W10 (9): `w10_nit_tag`, `w10_loose_passive_tag`, `w10_vs_nit_open_wider`, `w10_overbluff_punish`, `w10_guardrail_sample_size`, `w10_checkpoint_tag_line`, `w10_checkpoint_guardrail_line`, `w10_checkpoint_table_notice`, `w10_checkpoint_review`
  - W11 (4): `w11_trigger_overfold_blinds`, `w11_trigger_overcall_flop`, `w11_checkpoint_trigger_line`, `w11_checkpoint_review`
  - W12 (7): `w12_good_fold_bad_result`, `w12_after_bad_beat_reset`, `w12_after_mistake_reset`, `w12_assertive_not_ego`, `w12_discipline_under_pressure`, `w12_pretty_hand_bad_price_fold`, `w12_checkpoint_reset_line`
- **3 tasks**: prompt/answer wording overlap — `w11_plan_table_focus_transfer`, `w12_good_fold_bad_result` (also extreme-distractor), `w12_checkpoint_review` (also extreme-distractor).
- **20 tasks**: correct-index-0 only, no other packet-flagged shortcut — a clean reorder (with a distractor-plausibility spot check) is likely sufficient for these.
- Every one of the 42 tasks is additionally marked "yes, position alone works" in the packet (§13) — the index-0 pattern is a superset defect layered over all of the above.

**Answer to required question 3 (which tasks need distractor rewrites vs. order-only):** the 20 extreme-distractor tasks listed above plus the 2-3 wording-overlap tasks need content rewrites (distractor plausibility and/or prompt/option de-duplication), not merely a position swap. The remaining 20 plain-index-0 tasks can likely be resolved by authored index rotation alone, subject to an author spot-check during the repair pass.

## 10. Duplicate/template audit

5 duplicate prompt groups (packet §19):

1. "What is the first step in player adjustment?" → `w10_player_type_intro`, `w10_checkpoint_intro` — **both ungraded teaching-phase intros (no options)**. Harmless recap/bridge framing.
2. "What is the best pre-session plan style?" → `w11_session_plan_intro`, `w11_checkpoint_intro` — **both ungraded teaching intros**. Harmless.
3. "What should be judged first after a hand?" → `w12_decision_quality_intro`, `w12_checkpoint_intro` — **both ungraded teaching intros**. Harmless.
4. "What quick tag fits best?" → `w10_loose_passive_tag`, `w10_overaggressive_tag` — **both scored**, different option sets and different correct tag, so no direct answer leakage between them, but the shared generic prompt reduces prompt-specific reasoning cues and compounds the position-guessing pattern. P3.
5. "What is the sharper adjustment?" → `w10_underbluff_fold_more` (W10 bluff-frequency exploit) and `w11_plan_avoid_overload` (W11 session-focus narrowing) — **cross-world, scored, unrelated concepts sharing one generic prompt**. P3 template-redundancy; not literal leakage since concepts and options differ, but weakens assessment specificity.

1 duplicate option-set group: inherited intro/recap templates with no options — nonblocking (packet §19).

**Verdict**: 3 of 5 duplicate-prompt groups are legitimate harmless recap (no options, no scoring impact). 2 of 5 are real but low-severity (P3) template redundancy on scored tasks, not invalid independent assessment on their own — they compound rather than cause the pattern-guessing risk that §3/§9 already establish as the primary defect.

## 11. Feedback-quality audit

Packet §14 summary, all three worlds:

- Decisive cue explained: yes/mostly yes across W10-W12.
- Why correct works / why wrong fails: yes/mostly yes across all three.
- **Change condition** (what would flip the answer): **partial** for all three worlds — the weakest, most consistent gap.
- Notice-next-time guidance: partial for W10, yes for W11/W12.
- W12-specific: "Some distractors are obviously bad, reducing need for reasoning" (already covered in §6, §9).

**Finding**: feedback reliably explains the immediate right/wrong of the specific hand shown but under-delivers the counterfactual condition that would make a different option correct. This limits transfer to genuinely novel table states even where the taught concept is sound. P2, bounded to a copy-only addition (one condition-contrast sentence per incorrect-option feedback block), highest-priority on the 20 extreme-distractor tasks identified in §9 since those are already being touched in the repair wave.

## 12. Repair-pedagogy audit

All 3 same-signal mappings (W10 `w10_player_tendency_tag_hidden`→`w10_loose_passive_tag`; W11 `w11_session_plan_hidden`→`w11_plan_avoid_overload`; W12 `w12_tilt_reset_hidden`→`w12_after_mistake_reset`) satisfy same-concept/different-task transfer at the task-ID level — this part of repair pedagogy is sound (packet §16).

**Confirmed defect**: every target task's correct answer is still index 0, and the packet's own matrix explicitly flags "wording should be reviewed for answer leakage" for all three (§16). A learner routed into repair via same-signal detection can pass the repair check with the identical guess-the-first-option strategy that triggered the repair in the first place. This makes repair-pedagogy validity fully dependent on the §3 fix — it cannot be closed independently.

No untaught knowledge was found injected into any of the three repair targets; no evidence of the repair target being "an easier wording of the same question" beyond the shared shortcut.

## 13. Cross-world progression

W9→W10, W10→W11, W11→W12, and W12→terminal-review seams are all marked coherent by payoff-preview-to-next-intro matching (packet §18), and no contradiction was found. Difficulty gradient within each world is sensible (tag → lever → guardrail; plan → trigger → review; process → reset → confidence/discipline). This progression claim is about **structure and promise**, not about **proven skill increase** — the latter is currently unverifiable because of the §3 assessment-integrity defect. Progression coherence and assessment validity are independent axes; only the second is broken.

## 14. Promise/payoff and terminal review

All three payoffs are structurally aligned to their world's taught lesson set (packet §17). W12's payoff is the one most exposed by the assessment-integrity defect, since it is the terminal Volume I claim ("You learned how to judge process, reset tilt, and keep discipline before deeper strategy") and W12 also carries the highest concentration of socially-obvious distractors (§6, §9). Once the grouped repair wave lands, no payoff copy change is required — the payoff text itself does not overclaim relative to the taught content; it is the assessment behind it that needs to catch up.

## 15. Confirmed / partial / rejected / Human-QA / deferred ledger

| ID | Summary | Severity | Disposition |
| --- | --- | --- | --- |
| W10W12-DCA-001 | 42/42 assessed tasks resolve to correct index 0, no runtime shuffle | P0 | confirmed — immediate repair |
| W10W12-DCA-002 | All 3 same-signal repair targets reproduce the index-0 pattern | P1 | confirmed — immediate repair |
| W10W12-DCA-003 | 20 tasks use extreme/absolute-distractor wording, independently guessable | P1 | confirmed — immediate repair |
| W10W12-DCA-004 | 3 tasks show prompt/answer wording overlap | P2 | confirmed — immediate repair |
| W10W12-DCA-005 | W12 guided-practice:independent-transfer ratio inverted vs. W10/W11 | P2 | partially_confirmed — deferred_to_w1_w12_debt_burn |
| W10W12-DCA-006 | W10/W11 task Context largely reuses one placeholder hand/table state | P2 | partially_confirmed — human_qa_only for final confirmation |
| W10W12-DCA-007 | Feedback "change condition" only partial across all three worlds | P2 | confirmed — immediate repair (prioritized on the 20 DCA-003 tasks); residual scope deferred_to_w1_w12_debt_burn |
| W10W12-DCA-008 | 2 of 5 duplicate-prompt groups reused on scored, unrelated tasks | P3 | confirmed — immediate repair (low-cost reword) |
| W10W12-DCA-009 | 5 required-inspection terms not found as literal learner-facing strings | P3 | partially_confirmed — nonblocking_naming_or_tooling_debt, optional low-cost inclusion in same wave |
| W10W12-DCA-010 | Tilt-reset efficacy, table-feel realism, emotional credibility unverifiable from source | P4 | human_qa_only |

No findings were rejected outright; none required Opus escalation (no unresolved pedagogical contradiction existed in the packet — every question above was answerable from the tabulated evidence).

## 16. Root-cause clusters

1. **Global authored option-position leakage** — DCA-001, DCA-002. Single root cause: correct answers were authored/extracted consistently at index 0 across the entire W10-W12 route, including repair targets.
2. **Distractor plausibility / social-desirability leakage** — DCA-003 (extreme/absolute framing) and the W12-specific "obvious virtuous answer" pattern (§6, §9). Independent of position but same symptom (guessable without skill).
3. **Prompt/option wording overlap** — DCA-004. Concept name echoed between prompt and correct option on a small number of tasks.
4. **Template/duplicate-prompt redundancy** — DCA-008. Generic scored prompts reused verbatim across distinct tasks/worlds.
5. **Feedback actionability gap** — DCA-007. "Change condition" under-delivered network-wide; not tied to the other clusters, a separate authoring habit.
6. **Thin independent transfer / context reuse** — DCA-005, DCA-006. Scaffolding-ratio and example-variety concerns; lower confidence, partially Human-QA-bound.
7. **Terminology-naming drift** — DCA-009. Concept taught, literal term not used; cosmetic.

## 17. One-wave repair recommendation

**A single grouped W10-W12 content-repair wave is recommended and sufficient.** All confirmed-for-immediate-repair findings (DCA-001 through DCA-004, DCA-007's prioritized slice, DCA-008, optionally DCA-009) are text/data-only changes — option ordering, distractor wording, prompt wording, and feedback copy — with no route, architecture, telemetry, or payoff-structure change required. Poker/content correctness and process/mindset pedagogy do not require incompatible validation approaches here: both are being fixed via the same deterministic content-authoring and the same existing focused test suite (packet §23). No finding in this audit requires a route or architecture change, and none creates material regression risk when combined. A second wave is therefore not warranted by this audit's own split-wave criteria.

## 18. W1-W12 debt-burn candidates

- DCA-005 (W12 guided:transfer ratio) — worth checking whether other worlds in the wider W1-W12 route show the same inversion pattern before deciding whether to add tasks or reclassify existing ones.
- DCA-007 residual scope — extending "change condition" feedback coverage to all 42 tasks (only the 20 DCA-003 tasks are prioritized for the immediate wave).
- DCA-006 confirmation, if Human QA finds the context-thinness pattern real — check whether it is a W10-W12-specific authoring shortcut or systemic across earlier worlds.
- Terminology-naming drift pattern (DCA-009) — the packet's own deferred-debt list already carries a related "historical owner file/class names retain retired labels" item as nonblocking tooling debt; naming-drift on learner-facing terms should be checked together with that in the wider burn.

## 19. Provisional scores and caps

Scale 1-10. No score of 9 or 10 is given anywhere, per mission rule. Assessment-validity is hard-capped by the 42/42 index-0 finding regardless of other strengths.

| Dimension | W10 | W11 | W12 | Cap reason |
| --- | --- | --- | --- | --- |
| Promise alignment | 8 | 6 | 7 | W11 capped for thin poker-scenario variety (§5); W12 capped for payoff/assessment mismatch (§14) |
| Teach-before-ask | 7 | 7 | 7 | Capped for the 5 not-found required terms (§7), otherwise strong |
| Beginner safety | 7 | 7 | 6 | W12 capped: highest concentration of socially-obvious distractors undercuts demonstrated (not just taught) discipline; health/emotion claims remain Human-QA-only |
| Learning depth | 6 | 5 | 5 | W11/W12 capped for context reuse (§8.6) and W12's guided:transfer inversion (§8.5) |
| Assessment validity | 2 | 2 | 2 | Hard-capped by 42/42 index-0 (§3); W12 additionally carries the most extreme-distractor tasks proportionally |
| Feedback quality | 6 | 7 | 6 | Capped for partial "change condition" across all three (§11); W12 further capped for obvious-distractor reasoning bypass |
| Transfer | 6 | 5 | 6 | W11 capped: only 3/21 tasks show differentiated poker-hand transfer rather than process-recognition |
| Repair pedagogy | 3 | 3 | 3 | Hard-capped: all 3 repair targets reproduce the index-0 defect (§12) |
| Progression/payoff | 7 | 6 | 5 | W12 capped lowest: terminal payoff is the least currently-provable given assessment defects concentrate there |

Human QA remains required before any of these scores can be treated as final, per mission instruction — these are evidence-only, deterministic-source scores.

## 20. Exact Codex implementation checklist

1. For each of the 42 assessed W10-W12 tasks, reassign the correct-option index via **authored, source-level rotation** (not runtime shuffle) so no world's correct-index distribution is a single constant value; target a roughly even spread across indices 0/1/2 with no run of the same index longer than 2-3 consecutive tasks in visible route order. Update the options array/correct-id pairing accordingly.
2. Apply the identical rotation, consistent with its corresponding source task's new index, to the 3 same-signal repair targets: `w10_loose_passive_tag`, `w11_plan_avoid_overload`, `w12_after_mistake_reset`.
3. Rewrite distractor text for the 20 tasks listed in §9 (extreme/absolute-distractor family) toward plausible-but-suboptimal alternatives — a competing, defensible-sounding lever or action rather than an absolutist "always/never/everything/auto-quit/self-attack/deny" framing — while preserving the existing correct-answer semantics.
4. Reword prompt or option text for `w11_plan_table_focus_transfer`, `w12_good_fold_bad_result`, and `w12_checkpoint_review` to remove the direct concept-name echo between prompt and correct option flagged in §13.
5. Reword the two scored duplicate prompts: "What quick tag fits best?" (currently shared by `w10_loose_passive_tag` and `w10_overaggressive_tag`) and "What is the sharper adjustment?" (currently shared by `w10_underbluff_fold_more` and `w11_plan_avoid_overload`) to be task-specific.
6. Add one condition-contrast sentence ("if X were true instead, Y would be correct") to the incorrect-option feedback for the 20 tasks touched in step 3, as the prioritized slice of DCA-007.
7. Optional, low-cost, same wave: add the literal terms "over-adjustment" (W10 guardrails intro), "process note" and "table cue" (W11 relevant intros), and "entitlement" (W12 confidence intro) into existing teaching copy without adding new tasks.
8. Do not change: route ownership, telemetry, payoff copy structure, hidden-task mapping keys, correct-answer semantics (only position/wording), W13+ activation, or any test that is not directly checking the option-index/content values touched above.
9. After edits, re-run the full focused validation set already listed in the evidence packet (§23: guard/payoff/repair/route-admission contract tests) plus `flutter analyze`, and add a deterministic check that no world's correct-index distribution collapses to a single value.

## 21. Explicit non-claims

- This audit does not claim final closure of W10-W12; it recommends one grouped repair wave and defines its scope.
- This audit does not claim the taught content is free of any imperfection beyond what is listed — only the confirmed and partially confirmed findings above.
- This audit does not evaluate visual design, animation, Modern Table, monetization, or W13+, per forbidden scope.
- This audit does not confirm or deny the DCA-006 context-thinness finding as a settled defect — it is explicitly bounded by the packet's own stated screen-rendering limitation and requires Human QA.
- This audit does not assert whether any test currently encodes a fixed index-0 contract; that is an open check assigned to the Codex implementation pass, not a confirmed finding here.
- No product code, content, tests, poker answers, option ordering, route ownership, payoff, or repair mappings were changed by this audit. No W13+ activation occurred.

## 22. Token/Quota Efficiency Report

- exact_usage: unavailable.
- model used: Claude Sonnet 5.
- effort: High.
- escalation occurred: no.
- estimated token usage: packet read (~37k tokens across two paginated reads) plus analysis and report authoring; total session estimate in the low-to-mid tens of thousands of tokens.
- packet sections read: all 24 sections (full file, 415 lines, in two sequential reads).
- source expansions and reasons: none — no internal contradiction, no truncation, and poker correctness was assessable from included task/feedback/rationale text throughout.
- files opened: evidence packet (full) via preflight `ls`; git preflight commands (`git branch --show-current`, `git rev-parse HEAD`, `git status --porcelain`, `git cat-file -t`, `git diff --stat`) to verify branch/HEAD/worktree/single-file-diff before analysis.
- full files read: `docs/_reviews/w10_w12_verified_deep_content_evidence_packet_v1.md` only.
- largest token sinks: the two full-packet reads (task matrices in §3-§8 and §13 are the densest tables).
- repeated investigation: none — single linear read plus analysis, no re-reads or backtracking.
- avoidable quota cost: low — no broad repository search was performed, consistent with mission scope restriction.
- whether a second Claude pass is required: no for the deterministic findings in this report; a second pass would only be needed post-repair to re-verify the option-distribution and distractor fixes against a refreshed evidence packet.
- findings produced per estimated 10k tokens: approximately 2-3 (10 confirmed/partial findings across roughly 35-45k estimated tokens of packet-plus-analysis work).
