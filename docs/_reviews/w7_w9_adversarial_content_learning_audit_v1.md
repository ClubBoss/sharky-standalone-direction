# W7-W9 Adversarial Content and Learning-Quality Audit v1

Date: 2026-07-08

Audited branch (evidence branch, unmodified): `codex/w7-w9-deep-content-evidence-packet-v1`

Evidence branch HEAD: `a40bf6d82c8e2e37e948f1c9e8243a9ced76b55e`

Base main represented by packet: `27a862ed2055bd62f5bda3ca5aae8ef6faf04b64`

Primary evidence packet: `docs/_reviews/w7_w9_deep_content_audit_evidence_packet_v1.md`

Model: Claude Sonnet High. Effort: High. Escalation to Opus: not performed, not needed — no written contradiction or synthesis failure in the packet required it.

Terminal verdict: `w7_w9_audit_recommends_one_bounded_repair_wave`

## 1. Executive Verdict

W7, W8, and W9 teach factually correct poker content in a mostly coherent
beginner-to-intermediate sequence. No finding in this audit alleges false
poker teaching (no P0). The audit confirms three P1 defects that are real but
bounded: (a) every world's bridge/final-checkpoint question shares one
answer template that is solvable by structure alone, (b) the W9 payoff
claims "ladder pressure" competence that is never taught or assessed on the
default learner route, and (c) an extreme/absolute-distractor pattern
recurs across dozens of tasks in all three worlds, letting a learner answer
by eliminating obviously-wrong absolutes rather than reasoning about poker.
Two P2 and two P3 findings round out the ledger. All of it fits inside one
grouped, bounded repair wave (copy/content-only, no route or ownership
changes).

### Answers to the 13 required adversarial questions

1. **Confirmed P0-P4 defects**: 0 P0, 3 P1, 2 P2, 2 P3, 0 P4-as-findings (three items are Human-QA-only observations, not findings). See ledger, section 16.
2. **Evidence-backed vs Human-QA-only**: all 7 confirmed/partially-confirmed findings are evidence-backed directly from the packet's own matrices. Three items (M-ratio-formula clarity, whether real learners notice the answer template/distractor pattern, felt payoff satisfaction) are Human-QA-only.
3. **Does each world honestly teach its promise?** W7 and W8: yes, with bounded gaps (thin transfer, minor scope dilution). W9: no, not fully — the payoff overclaims "ladder pressure," which is an unsupported-payoff mismatch (section 3, section 14 finding W7W9-DCA-002).
4. **Is every major term taught before assessment?** Mostly yes. "Blocker" is used in W7 prompts/feedback without an in-route explanation (section 7, W7W9-DCA-005), and "ladder pressure" is never taught on the visible route at all (W7W9-DCA-002).
5. **Enough examples and independent transfer?** Learning depth is generally "thin but coherent" for an introductory promise. One confirmed transfer gap: W7's sole transfer task for the visible-card promise recombines already-seen examples instead of an unseen one (W7W9-DCA-004).
6. **Assessment validity vs pattern guessing?** No — this is the audit's strongest finding. World-bridge checkpoints share one leak-prone template (W7W9-DCA-001) and extreme/absolute distractors recur system-wide (W7W9-DCA-003).
7. **Does feedback explain reasoning?** Generally yes across all three worlds (section 11); no confirmed feedback-specific defect beyond the distractor-quality issue already counted under assessment validity.
8. **Are repair targets same-signal?** Yes for all confirmed repair mappings except that the ladder-pressure repair target (`w9_bubble_short_stack`) still never names "ladder pressure," which reinforces W7W9-DCA-002 rather than resolving it.
9. **Is difficulty progressive and coherent?** Yes across W7->W8->W9; no abrupt vocabulary jump was confirmed at any seam (section 15).
10. **Is payoff proportionate to competence?** W7 and W8: proportionate with minor caveats. W9: not proportionate — see W7W9-DCA-002.
11. **What enters the one repair wave?** W7W9-DCA-001, 002, 003 (mandatory), 004 and 006 (recommended), 007 (optional/cheap). See section 18.
12. **What is deferred or Human-QA-only?** W7W9-DCA-005 is partially confirmed pending a Codex check of whether W1-W6 already teaches "blocker" (out of this audit's scope). Three items are Human-QA-only (section 16).
13. **Can W7-W9 close after at most one repair wave?** Yes — every confirmed finding is copy/content-level and shares one validation surface (existing repair/payoff/telemetry test files plus `flutter analyze`).

## 2. Evidence Boundary And Confidence

- Primary source: the full evidence packet (391 lines), read in its entirety before any judgment was formed.
- One bounded source expansion was attempted, per the evidence policy's "option order is materially relevant but omitted" trigger. The packet's own pattern-guessing scan (section 16) explicitly invites this: "exact UI order should be checked from source if this becomes a P1/P2 finding." Since the distractor-pattern and template-leakage findings were judged P1, a check was attempted.
  - File/symbols inspected: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`, task-ID anchors (`w6_ak_combos`, `w6_pair_combos`, `range_checkpoint_value`, `w7_effective_stack_intro`, `w7_20bb_wider`, `w7_low_spr_commit`, `w7_stack_checkpoint`, `w9_m_ratio_yellow_zone`, `w9_medium_stack_tighten`, `w9_bubble_table_risk_transfer`, `w9_checkpoint_review`) and their referenced runners (`_w6AkComboRunner`, `_w6PairComboRunner`, `_w6RangeIntroRunner`, `_w6ValueDryBoardRunner`, `_w6ComboCountsIntroRunner`).
  - Why the packet was insufficient: the packet does not extract literal rendered option order/index, only correct-vs-other-option text.
  - Result: task entries reference runners defined via chained `.copyWith(...)` calls (e.g. `_w6AkComboRunner = _w6ComboCountsIntroRunner.copyWith(...)`), so the literal resolved `options`/`correctIndex` sit behind multiple copyWith hops rather than in a single small slice. Resolving this exactly would exceed "smallest relevant slice" and would drift into the broad exploration this mission forbids. This lead is therefore **not confirmed**; it is carried into section 20 as an exact Codex verification step instead of being asserted as a finding.
- `graphify query` was run twice per the active hook policy before any raw-file read/grep, oriented on `options`/`correctIndex` structure; it confirmed the field locations but not literal values, consistent with the graph's symbol-level (not literal-value) scope.
- No other source expansion was performed. No archives, donor roots, W1-W6, or W10-W12 content were read.
- Confidence: high for all findings drawn directly from the packet's matrices (sections 6-16); medium for the "blocker" finding (depends on unverified W1-W6 prior teaching); low/deferred for the option-position lead (explicitly not confirmed).

## 3. World-Promise Reconciliation

| World | Promise | Actually teaches | Independently assesses | Payoff claims | Alignment |
|---|---|---|---|---|---|
| W7 | Visible cards narrow ranges | combo counts (inherited/prerequisite) + 3 visible-card examples (A72, K84, 772) | 1 transfer task, reusing 2 of the 3 examples | "learned how visible cards remove combinations and narrow ranges" | thin but coherent; transfer gap (W7W9-DCA-004) |
| W8 | Effective stack, SPR, and format change risk | effective stack, depth shift, SPR/commitment, format, + 1 tangential side-pot task | table-effective-notice, A-J depth transfer, top-pair SPR transfer, final checkpoint | "learned how effective stack depth changes commitment and risk" | sufficient; minor scope dilution (W7W9-DCA-007) |
| W9 | Survival pressure, zones, bubble pressure, player adjustment | survival, M-ratio zones (no formula), bubble/risk premium | cash-vs-tournament, zone transfer, bubble transfer, checkpoint | "learned how survival pressure, **ladder pressure**, and risk premium change decisions" | **unsupported payoff** — ladder pressure is claimed but never taught/assessed on the visible route (W7W9-DCA-002) |

## 4. W7 Audit

- Sequence: combo counts (inherited `w6_`-labeled prerequisite content) -> range-bucket checkpoint -> visible-card combo-density lesson. Only the final 5 tasks (`visible_ace_combo_reduction_intro` through `visible_card_combo_reduction_recap`) are the world's own new promise content; the first 17 tasks are prerequisite recap.
- Teaching is present before assessment for both combo counts and visible-card removal (section 9/10 of the packet confirm this ordering).
- Gap: the sole independent-transfer task (`visible_card_combo_density_transfer_check`) only recombines the two examples already shown (A72, K84) rather than testing an unseen board; the most conceptually distinct case (paired board 772, where trips remain possible despite fewer matching combos) is taught but never independently assessed (W7W9-DCA-004).
- The world-bridge checkpoint (`range_checkpoint_review`) shares the cross-world answer template flagged in W7W9-DCA-001.
- "Blocker" appears in prompts/feedback without in-route explanation (W7W9-DCA-005).
- Payoff wording is proportionate to what is taught, but rests on a thin transfer base.

## 5. W8 Audit

- Sequence: effective stack -> same-hand-different-depth -> SPR/commitment -> format pressure -> checkpoint. This is the most evenly staged of the three worlds; each concept gets a teach -> guided -> transfer arc before the next concept starts.
- A side-pot fact (`what_poker_is_side_pot_intro`) is inserted mid-SPR lesson as a single combined teach+practice task. It is mechanically correct but tangential to the world's stated promise ("effective stack, SPR, and format"); the packet itself flags this as an open dilution question (W7W9-DCA-007).
- The world-bridge checkpoint (`w7_stack_checkpoint`) shares the W7W9-DCA-001 template.
- Nonblocking, already-accepted debt: 25 of 26 W8 route task IDs retain historical `w7_` prefixes. Not re-opened here — naming-only, no learner-facing, telemetry, persistence, or ownership harm shown.
- Payoff wording is proportionate to demonstrated competence.

## 6. W9 Audit

- Sequence: survival pressure -> M-ratio zones -> bubble/risk premium -> checkpoint. M-ratio is taught as urgency zones without the underlying formula; this reads as an intentional "lite" simplification (task ID suffix `_lite`), not a truncation defect — judged **no issue** for content correctness, flagged **Human-QA-only** for whether it frustrates a curious learner.
- The defining defect of this world: "ladder pressure" appears only inside a **hidden** repair-source task (`short_stack_ladder_pressure_lite`) and in the payoff copy. It is absent from all 23 visible route tasks (section 8 of the packet), and even the repair target it maps to (`w9_bubble_short_stack`) never names it in its own correct answer or feedback text. A learner who never triggers repair — the majority path — earns a payoff claiming a concept they were never shown (W7W9-DCA-002).
- The checkpoint's entry task (`w9_checkpoint_intro`) is a verbatim duplicate of `w9_survival_intro` (packet: "same as survival intro"), adding no new synthesis at checkpoint entry (W7W9-DCA-006).
- The world-bridge checkpoint (`w9_checkpoint_review`) shares the W7W9-DCA-001 template.

## 7. Terminology And Beginner-Safety Audit

Audited against the mission's minimum term list (combination, range, blocker, visible card, effective stack, commitment, SPR, risk premium, bubble, ladder pressure, survival pressure), using the packet's terminology ledger (section 9) as the primary source.

| Term | Status |
|---|---|
| combination/combo | taught, demonstrated, assessed, reused — no issue |
| range | taught, demonstrated, assessed, bridges to W8 — no issue |
| blocker | used in prompts/feedback, not explained in-route, no independent assessment, no repair target — **W7W9-DCA-005** |
| visible card | taught, demonstrated, assessed (with the transfer-thinness caveat) — **W7W9-DCA-004** |
| effective stack | taught, demonstrated, assessed, reused — no issue |
| commitment | taught, demonstrated, assessed, reused — no issue |
| SPR | taught, demonstrated, assessed, reused; acronym density is a watch-item but adequately explained — no confirmed defect |
| risk premium | taught, demonstrated, assessed, reused — no issue |
| bubble | taught, demonstrated, assessed, reused — no issue |
| ladder pressure | **never taught or assessed on the visible route; only in hidden source + payoff** — **W7W9-DCA-002** |
| survival pressure | taught, demonstrated, assessed, reused — no issue |

## 8. Teach-Before-Ask Audit

Cross-checked against the packet's own teach-before-ask matrix (section 10). No term is assessed before its first teaching task, with two caveats already covered above: "blocker" (never explained in-route at all, W7W9-DCA-005) and "ladder pressure" (never appears on the visible route, W7W9-DCA-002). The side-pot fact (W8) functions as a single combined teach+practice task rather than a separate teach step first; given its factual (non-strategic) nature and single-task footprint, this is bounded and captured under W7W9-DCA-007 rather than as its own teach-before-ask violation.

## 9. Learning-Depth Audit

- W7: thin but coherent for the introductory promise; capped by the transfer gap in W7W9-DCA-004.
- W8: sufficient for the stated introductory competence — clearest teach -> guided -> transfer -> checkpoint arc of the three worlds.
- W9: thin but coherent for survival/M-ratio/bubble; insufficient specifically for "ladder pressure," which has zero visible-route depth (W7W9-DCA-002).
- Raw task count is not used as a depth proxy anywhere in this audit, per mission instruction.

## 10. Assessment-Validity And Pattern-Guessing Audit

This is where the packet's own pattern-scan leads (section 16) converted into the audit's most material findings.

- **Template leakage (W7W9-DCA-001)**: every world's bridge/final-checkpoint question — `range_checkpoint_review` (W7), `w7_stack_checkpoint` (W8), `w9_checkpoint_review` (W9) — shares the identical structure: correct answer names **both** prior concepts ("range plus stack depth," "range plus stack risk," "map pressure first, then adjust by player") while both distractors are single-concept subsets. A learner who notices this meta-pattern once can answer every world's highest-stakes checkpoint question without any poker reasoning.
- **Extreme/absolute distractors (W7W9-DCA-003)**: recurring across W7 (`unchanged`/`must have`/`never has`), W8 (`wait/freedom`, `same as high SPR`, `full ring`), and W9 (`avoid all risk`, `fold everything`, `jam any two`, `call off light`) — the correct answer is consistently the single moderate/hedged option between two absolutes, which is answerable by elimination.
- **Checkpoint duplication (W7W9-DCA-006)**: `w9_checkpoint_intro` duplicates `w9_survival_intro` verbatim.
- **Not confirmed**: repeated correct-option UI position. The packet flags this as a lead; source verification was attempted and blocked by multi-hop `copyWith` chains (section 2). Carried forward as a Codex verification step (section 20), not asserted as a finding.
- **Not confirmed**: answer-label leakage beyond the template/extreme-distractor patterns already counted — no additional distinct instance found that isn't already explained by W7W9-DCA-001 or 003.

## 11. Feedback-Quality Audit

Consistent with the packet's feedback matrix (section 12): correct feedback generally reinforces the decisive cue (combo/range logic in W7; stack/room/commitment/format in W8; survival/urgency/leverage/risk-premium in W9), and incorrect/suboptimal feedback generally explains why the wrong choice fails rather than only restating the correct answer. No feedback-specific defect was confirmed beyond the distractor-quality issue already counted under assessment validity (the same extreme-distractor pattern shows up in feedback as "rejects the absolute" rather than "explains the graded middle ground," which is folded into W7W9-DCA-003 rather than treated as a second, separate feedback defect).

## 12. Transfer And Difficulty Audit

- W7: counts -> checkpoint -> visible-card reduction escalates appropriately, but the sole transfer task under-varies its surface features (W7W9-DCA-004).
- W8: effective stack -> depth shift -> SPR -> format -> checkpoint varies stack sizes, hand types, and table context well; no confirmed transfer defect.
- W9: survival -> zones -> bubble -> checkpoint varies context (cash/tournament, zone color, stack size at bubble) well, except that "ladder pressure" never gets a transfer opportunity at all because it never gets a teaching opportunity (W7W9-DCA-002).
- Difficulty rises gradually across all three worlds; no artificial-jargon-difficulty defect was confirmed beyond the already-noted SPR/M-ratio acronym density, which is adequately mitigated by feedback text.

## 13. Repair-Pedagogy Audit

Per the packet's repair/checkpoint matrix (section 14), all confirmed repair mappings are same-signal:

- W7 visible-card family repairs stay inside the visible-card family (king -> paired-board -> transfer-check -> king), which is appropriate spaced reuse across ranks.
- W8 stack-depth/SPR repairs map hidden misses to the correct launchable W8 task for that same signal (e.g. short-stack pressure -> `w7_low_spr_commit`; deep-stack room -> `w7_high_spr_room`).
- W9 survival/bubble repairs map correctly, with one caveat: `short_stack_ladder_pressure_lite -> w9_bubble_short_stack` is same-signal for survival urgency, but the repair target still never names "ladder pressure," which is supporting evidence for W7W9-DCA-002 rather than a separate repair-pedagogy defect.

No re-audit of repair launchability, telemetry, or intent lifecycle was performed or needed; the packet's evidence did not contradict that prior closure.

## 14. Progression And Payoff Audit

| World | Final checkpoint demonstrates payoff skill? | Payoff proportionate? | Next-world preview conceptually prepared? |
|---|---|---|---|
| W7 | partially — checkpoint tests range+depth bridge, not a fresh visible-card transfer | mostly, with thin-transfer caveat | yes, previews W8 stack depth cleanly |
| W8 | yes | yes, with side-pot-dilution caveat | yes, previews W9 tournament pressure cleanly |
| W9 | partially — checkpoint covers survival/zone/bubble lines but never ladder pressure | **no — overstates ladder-pressure competence** | yes, previews W10 player adjustment without overstating readiness on the covered concepts |

Claims about felt satisfaction or motivation from any payoff screen require real users and are marked Human-QA-only (section 16).

## 15. Cross-World Seam Audit

- W6 -> W7: bridging task carries "range plus stack depth" forward; no abrupt vocabulary jump.
- W7 -> W8: W7 payoff previews "Stack Depth And Risk" cleanly; W8's opening lesson (`effective_stack_basics`) does not assume unexplained W7-only vocabulary.
- W8 -> W9: `w7_stack_checkpoint` bridges to W9 with "range plus stack risk"; W9's `survival_pressure_basics` opener stands alone conceptually.
- W9 -> W10: `w9_checkpoint_review` bridges to "player adjustment" without claiming readiness beyond what W9 actually taught (the W9W7W9-DCA-002 overclaim lives in the payoff copy, not the transition-bridge task itself).
- No deep W6 or W10 audit was performed, per mission scope.

## 16. Confirmed/Rejected/Human-QA/Deferred Ledger

### Confirmed / partially confirmed findings

**W7W9-DCA-001**
- World/tasks: W7 `range_checkpoint_review`; W8 `w7_stack_checkpoint`; W9 `w9_checkpoint_review`.
- Severity: P1.
- Defect family: assessment-validity / template leakage.
- Evidence: packet section 6 row 17, section 7 row 26, section 8 row 23 — all three correct answers are "concept A + concept B," both distractors are single-concept subsets.
- Learner consequence: the highest-stakes checkpoint question in every world is answerable by structural pattern rather than poker reasoning, once noticed.
- Root cause: shared answer-authoring template for world-bridge checkpoints.
- Minimum bounded repair: rewrite each of the three checkpoint's distractor pair so at least one distractor is also a plausible two-concept combination (not just single-concept), breaking the "combined answer always wins" heuristic. One representative rewrite pattern fixes the family; no per-row repair needed beyond applying it to the 3 tasks.
- Likely owner/files: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` (task content).
- Deterministic Codex validation: re-run `test/ui_v2/act0_w2_w6_completion_payoff_v1_test.dart` and `test/guards/w8_w9_canonical_identity_ownership_reconciliation_contract_test.dart` after the copy change to confirm no ownership/persistence regression; `flutter analyze`.
- Repair wave: yes (mandatory).

**W7W9-DCA-002**
- World/tasks: W9 payoff copy (`lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`); visible route tasks 1-23 in packet section 8; hidden source `short_stack_ladder_pressure_lite`; repair target `w9_bubble_short_stack`.
- Severity: P1.
- Defect family: promise/payoff mismatch (unsupported payoff).
- Evidence: W9 payoff states "You learned how survival pressure, ladder pressure, and risk premium change decisions"; none of the 23 visible W9 tasks (packet section 8) teach, demonstrate, or assess "ladder pressure"; terminology ledger (section 9) confirms it exists only in a hidden repair source and the payoff line; the repair target it maps to also never names it.
- Learner consequence: the default (non-repair) learner — the majority — receives a completion claim for a concept they were never shown, which is a trust/promise-integrity defect at the exact moment the world claims mastery.
- Root cause: payoff copy was written to include a concept intended only for the repair path, without gating the claim on repair completion or adding any default-route exposure.
- Minimum bounded repair: remove "ladder pressure" from the default W9 payoff copy (cheapest, safest), or alternatively fold one short "ladder pressure" clause into `w9_bubble_short_stack`'s existing feedback text so every learner who reaches that task sees the term named and explained. Either option is copy-only.
- Likely owner/files: `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` (payoff copy) and/or `lib/ui_v2/act0_shell/act0_w9_tournament_pressure_hidden_runtime_session_owner_v1.dart` (hidden source feedback).
- Deterministic Codex validation: re-run `test/ui_v2/act0_w2_w6_completion_payoff_v1_test.dart`; confirm payoff copy string change does not break any string-matching assertion; `flutter analyze`.
- Repair wave: yes (mandatory).

**W7W9-DCA-003**
- World/tasks: pervasive — representative instances: W7 `visible_ace_combo_reduction_intro` (unchanged/must have ace/never has ace); W8 `w7_spr_intro`, `w7_low_spr_commit`, `w7_fullring_tighter`; W9 `w9_survival_intro`, `w9_medium_stack_tighten`, `w9_bubble_short_stack`, `w9_checkpoint_table_notice`.
- Severity: P1.
- Defect family: assessment-validity / distractor-quality.
- Evidence: packet's own pattern-scan (section 16) already names this pattern ("always," "never," "fold everything," "jam any two," "ignore pressure"); confirmed directly against the task-matrix "Other options/actions" columns across all three world matrices (sections 6-8).
- Learner consequence: a learner can answer a large share of W7-W9 tasks correctly by eliminating obviously-extreme wording rather than reasoning about the poker situation, undermining the assessment's validity system-wide.
- Root cause: distractor authoring convention that pairs a moderate/hedged correct answer against two absolute-worded distractors.
- Minimum bounded repair: for the flagged families, replace one obviously-extreme distractor per family with a plausible-but-wrong, moderately-worded distractor (e.g. replace "fold everything" with a specific-but-incorrect moderate line). One representative rewrite per family, not per individual row.
- Likely owner/files: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`.
- Deterministic Codex validation: `flutter analyze`; re-run the four test files already listed in the evidence packet's validation section to confirm no answer-key/telemetry regression from wording changes.
- Repair wave: yes (mandatory).

**W7W9-DCA-004**
- World/tasks: W7 `visible_card_combo_density_transfer_check` (independent transfer), `paired_board_texture_lite_intro` (772 rainbow, guided practice only).
- Severity: P2.
- Defect family: thin transfer / checkpoint family.
- Evidence: packet section 6 row 21 — prompt is "Across A72 rainbow and K84 rainbow..." (the exact two boards from rows 18-19); the paired-board mechanic (772, where visible pair cards still allow trips) is taught at row 20 but is not part of the transfer check's own prompt text, and the repair matrix (section 14) shows it only feeds into the transfer check as a repair source, not as default-route independent content.
- Learner consequence: the world's only independent-transfer moment for its own promise recombines material the learner has already seen rather than testing an unseen context, so the "narrow ranges" claim is under-tested for the paired-board case specifically.
- Root cause: transfer task authored before the paired-board example was added, or added without updating the transfer prompt to include it.
- Minimum bounded repair: extend `visible_card_combo_density_transfer_check`'s prompt/options to include the 772 paired-board case as a third comparison point, or add one additional lightweight independent-assessment task using an unseen board.
- Likely owner/files: `lib/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart`, `act0_shell_state_v1.dart`.
- Deterministic Codex validation: `flutter analyze`; confirm no regression in the same-signal repair recheck test (`act0_w7_w9_same_signal_repair_recheck_v1_test.dart`).
- Repair wave: recommended (not mandatory).

**W7W9-DCA-005**
- World/tasks: W7 `w6_ak_combos`, `range_checkpoint_combos` (prompt: "How many combos does A-K have before blockers?").
- Severity: P2.
- Disposition: partially_confirmed.
- Defect family: terminology-order gap.
- Evidence: terminology ledger (packet section 9) row for "blocker": "not fully taught in W7-W9 packet," "no direct repair target."
- Learner consequence: bounded — the qualifier "before blockers" does not change the graded answer (16/6 combo counts are unaffected by it), so no learner fails a task from not knowing this term. The consequence is comprehension friction, not incorrect answers.
- Root cause: uncertain whether "blocker" is properly pre-taught in W1-W6 (out of this audit's scope per mission instruction not to deep-audit W1-W6); if it is, this is a non-issue (properly deferred prior knowledge).
- Minimum bounded repair (if confirmed after W1-W6 check): add a short in-line clause defining "blocker" the first time "before blockers" appears in a W7 prompt/feedback string.
- Likely owner/files: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`.
- Deterministic Codex validation: check whether W1-W6 canonical content defines "blocker" before W7's first use; only then decide whether to include in a future wave.
- Repair wave: no — pending the W1-W6 check described above.

**W7W9-DCA-006**
- World/tasks: W9 `w9_checkpoint_intro`.
- Severity: P3.
- Defect family: thin transfer/checkpoint family (duplication subtype).
- Evidence: packet section 8 row 18, explicitly annotated "same as survival intro" (duplicate of row 1 `w9_survival_intro`).
- Learner consequence: low — this is a teaching-phase recap, not a scored assessment, so it does not let a learner skip reasoning on a graded item; it is redundant padding at the start of the checkpoint rather than an invalid assessment.
- Root cause: checkpoint's recap-intro step reused the earlier lesson's content verbatim instead of a condensed, checkpoint-appropriate recap.
- Minimum bounded repair: shorten or reword `w9_checkpoint_intro` so it is a condensed recap rather than a verbatim duplicate.
- Likely owner/files: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`.
- Deterministic Codex validation: `flutter analyze`; visual confirmation not required (teaching-phase copy only).
- Repair wave: recommended (optional/low-priority; cheap and low-risk).

**W7W9-DCA-007**
- World/tasks: W8 `what_poker_is_side_pot_intro`.
- Severity: P3.
- Defect family: promise/payoff mismatch (minor scope dilution).
- Evidence: packet section 15 explicitly raises this as an open question ("Does format/side-pot content dilute stack-depth promise?"); the task sits inside `spr_and_commitment` without a separate preceding teaching step, per packet section 10 ("side pot: appears inside W8 SPR lesson, one support task only").
- Learner consequence: low — side pots are correctly explained and the fact itself is true; the risk is narrow scope-drift inside a lesson named for SPR/commitment, not incorrect teaching.
- Root cause: an adjacent poker-mechanics fact was inserted into the SPR lesson without a one-line tie-back to stack depth/SPR relevance.
- Minimum bounded repair: add one clause connecting the side-pot fact back to effective-stack/SPR relevance (e.g., note that side pots change whose stack is "effective" for whom), or move it to a clearly separate single support step.
- Likely owner/files: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`.
- Deterministic Codex validation: `flutter analyze`; confirm no regression in the completion-payoff test.
- Repair wave: recommended (optional/low-priority; cheap and low-risk).

### Rejected

- None. Every lead raised by the packet's own pattern-scan and matrices was either confirmed (bounded) or moved to Human-QA-only / deferred rather than outright rejected, because the packet's own leads were treated as genuine candidates, not noise, and each had at least partial supporting evidence.

### Human-QA-only

- Whether omitting the M-ratio formula (intentional "lite" simplification) actually reads as clear or frustrating to a real beginner learner.
- Whether real learners notice and exploit the checkpoint-answer template (W7W9-DCA-001) or the extreme-distractor pattern (W7W9-DCA-003) in practice, versus reasoning normally regardless.
- Whether the W9 payoff's overclaim (W7W9-DCA-002) is felt as a trust problem by real learners, versus going unnoticed.
- General comprehension, pacing, and motivation across W7-W9 — requires real users per mission instruction.

### Deferred

- W7W9-DCA-005 ("blocker" terminology) — deferred pending a Codex check of W1-W6 prior teaching, out of this audit's scope.

### Nonblocking naming/tooling debt (already accepted, not re-opened)

- 25 of 26 canonical W8 route task IDs retain historical `w7_` prefixes. No learner-facing, telemetry, persistence, or ownership harm shown in this packet; not re-audited.

## 17. Root-Cause Clusters

1. **Template leakage** — W7W9-DCA-001. One shared answer-authoring template across all three world-bridge checkpoints.
2. **Distractor-quality family** — W7W9-DCA-003. One shared extreme/absolute-distractor authoring convention across dozens of tasks in all three worlds.
3. **Promise/payoff mismatch** — W7W9-DCA-002 (major) and W7W9-DCA-007 (minor). Payoff or lesson copy claiming/including more than the visible route actually teaches.
4. **Thin transfer/checkpoint family** — W7W9-DCA-004 (transfer under-variation) and W7W9-DCA-006 (checkpoint duplication).
5. **Terminology-order gap** — W7W9-DCA-005. Single bounded instance, pending W1-W6 verification.

## 18. One-Wave Repair Recommendation

One grouped, bounded repair wave is recommended, covering clusters 1-4 as copy/content-only changes inside `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` (and the W9 payoff string in `act0_lesson_runner_shell_v1.dart`):

- Mandatory: W7W9-DCA-001 (rewrite 3 checkpoint distractor pairs), W7W9-DCA-002 (trim or relocate the "ladder pressure" payoff claim), W7W9-DCA-003 (replace flagged extreme distractors family-wide, representative rewrite per family).
- Recommended, low-risk, bundle into the same wave: W7W9-DCA-004 (extend the W7 transfer check to include the paired-board case), W7W9-DCA-006 (shorten the duplicate checkpoint intro).
- Optional, cheap, bundle if convenient: W7W9-DCA-007 (one clause tying side-pot fact to SPR/stack-depth relevance).
- Excluded from this wave: W7W9-DCA-005, pending the W1-W6 terminology check described in section 20.

A second wave is not recommended. All mandatory/recommended items are content-string changes validated by the same existing test files (`act0_w7_w9_same_signal_repair_recheck_v1_test.dart`, `act0_w2_w6_completion_payoff_v1_test.dart`, the two guard contract tests already listed in the evidence packet) plus `flutter analyze` — they share one validation surface and none blocks closure if deferred.

## 19. Provisional Evidence-Only Scores And Caps

Scores are provisional, source-only, and capped below any perfect score per mission instruction. Human QA remains required for comprehension, pacing, trust, motivation, and felt learning effect.

### W7

| Dimension | Score /10 | Cap reason |
|---|---:|---|
| Promise alignment | 6 | capped by W7W9-DCA-004 (thin transfer for the core promise) |
| Teach-before-ask | 6 | capped by W7W9-DCA-005 (blocker gap) |
| Beginner safety | 6 | capped by W7W9-DCA-003 (distractor pattern) |
| Learning depth | 6 | thin but coherent; capped by W7W9-DCA-004 |
| Assessment validity | 4 | capped hard by W7W9-DCA-001 and W7W9-DCA-003 |
| Feedback quality | 7 | no confirmed W7-specific feedback defect |
| Transfer | 5 | capped by W7W9-DCA-004 |
| Repair pedagogy | 7 | repair mappings are same-signal and sound |
| Progression/payoff | 6 | proportionate wording, but thin transfer base |

### W8

| Dimension | Score /10 | Cap reason |
|---|---:|---|
| Promise alignment | 7 | minor dilution from W7W9-DCA-007 |
| Teach-before-ask | 7 | cleanest teach->guided->transfer arc of the three worlds |
| Beginner safety | 6 | capped by W7W9-DCA-003 |
| Learning depth | 7 | sufficient for stated introductory competence |
| Assessment validity | 4 | capped hard by W7W9-DCA-001 and W7W9-DCA-003 |
| Feedback quality | 7 | no confirmed W8-specific feedback defect |
| Transfer | 6 | good real-table variation; no confirmed W8-specific transfer defect |
| Repair pedagogy | 7 | repair mappings are same-signal and sound |
| Progression/payoff | 6 | proportionate; minor side-pot tangent (W7W9-DCA-007) |

### W9

| Dimension | Score /10 | Cap reason |
|---|---:|---|
| Promise alignment | 5 | capped hard by W7W9-DCA-002 |
| Teach-before-ask | 6 | ladder pressure is the sole visible-route gap |
| Beginner safety | 6 | capped by W7W9-DCA-003; M-ratio omission judged acceptable design |
| Learning depth | 6 | thin but coherent, except ladder pressure has zero depth |
| Assessment validity | 4 | capped hard by W7W9-DCA-001, W7W9-DCA-003, and W7W9-DCA-006 |
| Feedback quality | 7 | no confirmed W9-specific feedback defect |
| Transfer | 6 | reasonably varied bubble/zone transfer; ladder pressure untested |
| Repair pedagogy | 6 | same-signal, but ladder-pressure repair target never names the term |
| Progression/payoff | 4 | capped hard by W7W9-DCA-002 — the most serious payoff defect found |

## 20. Exact Codex Verification Checklist

1. For W7W9-DCA-001/002/003 copy changes: re-run
   `flutter test test/ui_v2/act0_w7_w9_same_signal_repair_recheck_v1_test.dart test/ui_v2/act0_w2_w6_completion_payoff_v1_test.dart test/guards/w8_w9_canonical_identity_ownership_reconciliation_contract_test.dart test/guards/w7_w10_route_status_alignment_contract_test.dart`
   and confirm all still pass (baseline: 110 tests passed per the evidence packet).
2. Run `flutter analyze` after any content-string edit; confirm no issues.
3. For the deferred option-position pattern-scan lead: trace the literal resolved `options`/`correctIndex` for the three checkpoint tasks (`range_checkpoint_review`, `w7_stack_checkpoint`, `w9_checkpoint_review`) plus a stratified sample of ~15 other flagged tasks, by resolving each task's runner through its full `copyWith(...)` chain back to its base runner definition in `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`, to confirm or deny whether the correct option is disproportionately in one position.
4. For W7W9-DCA-005: check whether W1-W6 canonical content defines "blocker" before W7's first "before blockers" use; if yes, close as no-issue; if no, add to a future bounded wave.
5. Run `git diff --check` and `git diff --cached --check` on this audit branch to confirm no whitespace/formatting errors in the new artifact.
6. Confirm exactly one file changed on this audit branch: `docs/_reviews/w7_w9_adversarial_content_learning_audit_v1.md`.

## 21. Explicit Non-Claims

- No content-quality final score is claimed; all scores in section 19 are provisional and source-only.
- No Human QA result is claimed or simulated.
- No route ownership, poker-answer, payoff-implementation, telemetry, or repair-mapping change was made or is proposed to be made by this audit itself.
- No W10-W12 closure or W13+ activation is claimed.
- No visual, Modern Table, or monetization review was performed.
- No product code, content source, or test file was edited.
- No W8 task ID was renamed; the accepted `w7_` naming debt is not re-opened.
- No second model (Opus) was commissioned; no escalation occurred.
- No deep W1-W6 or W10-W12 audit was performed; the "blocker" finding is explicitly bounded by this limitation.
- No claim of final closure is made — see terminal verdict.

## 22. Token/Quota Efficiency Report

- exact_usage: unavailable (not exposed to this session).
- model used: Claude Sonnet High (Sonnet 5), no escalation to Opus.
- escalation occurred: no.
- estimated tokens: input/context roughly 35-40k (full 391-line packet plus ~350 lines of targeted source/grep output); output roughly 6-8k for this artifact.
- packet sections read: all 20 sections of the evidence packet, in full.
- source expansions and reasons: one — option-order verification for the checkpoint/distractor findings, per the packet's own invitation to check source "if this becomes a P1/P2 finding"; inconclusive, converted into a Codex verification step rather than a claimed finding.
- files opened: `docs/_reviews/w7_w9_deep_content_audit_evidence_packet_v1.md` (full read); `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` (two bounded slices, ~140 lines total, plus targeted `grep -n` line lookups); no other files opened.
- full files read: only the evidence packet.
- largest token sink: the two `graphify query` calls, which returned generic symbol/edge listings not specific enough to resolve literal option order, and were not reused after the second attempt.
- repeated investigation: one (the copyWith-chain trace was attempted once, then stopped once it was clear it would exceed bounded-slice scope — no further retries).
- avoidable quota cost: the two graphify queries added orientation overhead without resolving the underlying question; a single targeted grep would likely have been sufficient if not for the hook-mandated graphify-first sequencing.
- whether a second Claude pass is required: no, for the audit itself. A second pass is optional only if Codex's option-order verification (section 20, item 3) surfaces a new confirmed P1/P2 finding that materially changes the ledger.
- findings produced per estimated 10k tokens: approximately 1.5-2 (7 confirmed/partially-confirmed findings across ~35-40k estimated tokens).
