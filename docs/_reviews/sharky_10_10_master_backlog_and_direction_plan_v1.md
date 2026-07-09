# Sharky 10/10 Master Backlog And Direction Plan v1

Status: REVIEW / PLANNING ARTIFACT - docs-only synthesis.

Branch target: `codex/sharky-10-10-master-backlog-and-direction-plan-v1`

Evidence baseline:

- Codex deconstruction: `docs/_reviews/full_ui_ux_visual_10_10_deconstruction_v1.md`
- Claude deconstruction: `docs/_reviews/claude_full_ui_ux_visual_10_10_deconstruction_v1.md`
- Latest visual pack cited by both reviews: `output/design_review/real_text_visual_pack_v5/` and `real_text_visual_pack_v5.zip`
- Pack implementation commit cited by both reviews: `485e773c540638c7168a3d5a23d5dab339dd08b2`
- Local availability note: this checkout did not contain `docs/_reviews/pre_human_qa_max10_push_v5.md` or `output/design_review/real_text_visual_pack_v5/`; the plan uses the two deconstruction artifacts as the active evidence record and does not invent closure facts from missing local files.

Claim boundary:

- No product code changes.
- No UI implementation.
- No Human QA run.
- No launch/public readiness, Human QA approval, durable learning, beginner mastery, premium commercial readiness, 9.0 proof, or 10/10 proof claim.

## 1. Executive verdict

Merged current score range: **6.8 to 7.8 / 10** from static visual/UX evidence. The lower bound reflects Claude's stricter top-1 commercial premium bar; the upper bound reflects Codex's more implementation-aware reading that the app is coherent, polished, and structurally salvageable.

Why the scores differ:

- Codex scored the product as a coherent current app with real learning-loop value: roughly **7.8 / 10** overall, no P0s, and a path to 8.5-9 through bounded/component evolution.
- Claude scored against a harsher "30-second top-1 premium product" bar: roughly **6.0 / 10**, with P0 labels for system-level visual failures.
- The disagreement is mostly calibration, not evidence. Both reviews identify the same core gaps: table signal weakness, table-feedback split, under-produced Sharky, state sameness, weak proof/payoff ceremony, and unproven motion/touch.

Merged truth:

- Sharky is a competent, coherent, serious poker learning product.
- It is not currently a top-1, 10/10, premium poker trainer.
- The route and learning concept are stronger than the visual/product expression.
- The core ceiling is not "broken app"; it is "premium teaching instrument not yet realized."

Can the current system reach 8.5-9: **yes**, if the next waves move table signal, feedback/repair/proof, container hierarchy, hub distinctiveness, and payoff moments in a coordinated way.

What is required for 9.5-10:

- A designed table signal layer that makes the table teach by sight.
- A feedback system where correct, miss, repair, and proof are visually distinct and tied to the exact table clue.
- A real Sharky art/pose/animation production track.
- A scoped escalation system for W11/W12 and terminal payoff moments.
- Motion/touch validation on device or video evidence.
- A final brutal re-review against refreshed screenshots after the above.

Is full app redesign required: **no**. Full app redesign would add risk and reopen working route semantics. The required move is **scoped system redesign/evolution** in the table, feedback/proof, Sharky, hub-template, payoff/ceremony, and motion layers.

Should Human QA wait if the goal is max-quality signal: **yes**. If the goal is to test raw comprehension immediately, Human QA can proceed, but if the goal is max-quality signal, Human QA should wait through Waves 1-3 and preferably Wave 4. Otherwise testers will spend time reporting predictable visual/UX issues already visible in the evidence.

## 2. Comparison of Codex vs Claude

| Dimension | Codex deconstruction | Claude deconstruction | Merged judgment |
| --- | --- | --- | --- |
| Strengths | Better practical implementation triage; clearer distinction between bounded polish, component evolution, art production, and Human QA validation. | Better top-1 commercial harshness; stronger challenge to template sameness, table escalation, and Sharky under-production. | Use Codex for implementation sequencing and Claude for not under-scoping the quality bar. |
| Weaknesses | More optimistic score may understate how ordinary the screenshots feel in a premium market context. | P0 labels are too severe under the practical policy and could cause false emergency framing. | Reclassify Claude P0s as P1 unless broken/harmful/unusable. |
| Most valuable findings | Table-feedback bridge; first-decision visibility; CTA dominance; proof/payoff gaps; clear wave plan. | W1-W12 table non-evolution; Sharky pose/art thinness; color semantics; proof terminology overload; 14/19 screens from two templates. | These become the master blockers. |
| Overlap | Table is the largest blocker; feedback/repair/proof states are under-differentiated; Sharky is not production-grade; journey/payoff moments under-escalate; motion/touch cannot be judged from stills. | Same. | High agreement on the real blockers. |
| Conflicts | Codex: no P0, 7.8 score, Human QA can proceed after selected P1s. | Claude: 4 P0, 6.0 score, Wave A before Human QA. | Practical policy wins: P0=0, but Human QA should wait for P1s if max-quality signal matters. |
| Severity disagreements | Codex calls many gaps P1/P2 and preserves Human QA flexibility. | Claude escalates color semantics, terminal payoff, and table non-evolution as P0-level top-1 blockers. | P0 only means broken/harmful/unusable. These are P1/P2 top-quality blockers, not P0 product emergencies. |
| Better future source | Codex for code-adjacent roadmap execution. | Claude for design challenge and top-1 harshness. | Future use should pair them: Claude Design for visual direction, Codex/Claude Code for implementation. |

Practical severity policy used here:

- P0 = broken, harmful, or unusable.
- P1 = must fix before Human QA if the goal is max-quality tester signal.
- P2 = should fix before external showing or near-10 path.
- P3 = high-EV polish.
- P4 = future/preference.

## 3. 10/10 North Star Definition

| Surface/system | Current state | Target 10/10 state | Main gap | Current components enough? | Evolution required |
| --- | --- | --- | --- | --- | --- |
| First impression | Coherent dark premium trainer; not top-1 memorable. | The first 5 seconds communicate "table coach, one real spot, one clear why" with a distinctive visual beat. | Hero templates and table moments do not yet create a memorable signature. | Partly. | Component evolution plus Sharky/art direction. |
| Onboarding | Placement and Welcome are safe and clear, but table preview and handoff have dead space. | Quick start feels personal, table-first, and immediately useful without setup burden. | First table exposure is not compelling enough. | Partly. | Bounded polish plus table-preview evolution. |
| Home | Strong CTA and return flow, but CTA dominates the learning concept. | Home says exactly why today's table read matters, with Sharky remembering a concrete clue. | Generic hero-card pattern and weak remembered-clue staging. | Partly. | Component evolution. |
| Learn | Readable path, too many progress metaphors and nested containers. | The curriculum feels like a premium route, not a card stack. | Repeated card grammar and crowded progress layers. | Mostly. | Bounded polish/component evolution. |
| Practice | Clear daily rep, but locked grid reads sparse/demo-like. | Practice feels alive: the current repair or useful rep is the hero, inventory is secondary. | Category grid and gating explanation dilute value. | Partly. | Component evolution. |
| Review | Conceptually strong miss/repair/proof loop, but active repair lacks table clue. | Review feels like a personal coach showing the exact missed signal and what to do next. | Miss card is text-heavy and not table-signal-backed. | Partly. | Component evolution. |
| Profile | "Proof profile" is a strong idea, but proof is still abstract. | Profile shows concrete earned reads, repairs, route moments, and next focus without dashboard bloat. | Generic stats and same card chrome. | Partly. | Component evolution. |
| Table/gameplay | Attractive felt, readable seats, strong buttons; weak signal hierarchy. | The eye moves from hero/actor to clue to pot/price to best action without decoding labels. | Small clue/pot/status labels, empty felt, table-panel split. | No. | Scoped table signal redesign/component evolution. |
| Feedback/repair/proof | Copy is strong; visual states are too similar and proof vocabulary is overloaded. | Correct, miss, repair, and proof are distinct at a glance and tied to the exact table clue. | State semantics live mostly in text. | No. | Component evolution. |
| Sharky companion | Present, likeable, but badge-like and under-produced. | Sharky has recognizable product, repair, proof, return, and milestone presence across sizes. | Too few poses, weak signature frame, no motion proof. | No. | Designer/illustrator art production. |
| Session Summary | Best payoff copy, but receipt-like and dense. | Summary feels earned, concrete, and connected to the table clue just mastered. | Proof/score hierarchy and next action are buried. | Partly. | Component evolution. |
| Day-2 return | Strong UX idea, visually identical to ordinary Home. | Return feels like Sharky saved a concrete clue for the learner. | No special remembrance treatment. | Partly. | Component evolution plus Sharky state. |
| W11/W12 late-route | Semantically mature, visually flat. | Late route feels more advanced and earned without changing route semantics. | W11/W12 table looks too close to W1. | No. | Scoped table escalation. |
| W12 terminal | Clear no-W13 route truth, weak ceremony. | Volume I completion/review handoff feels final, honest, and memorable. | Ordinary card treatment for biggest arc beat. | No. | Scoped payoff redesign. |
| Premium/commercial impression | Credible MVP, not screenshot-powerful. | 3-4 hero-grade screenshots sell the table coach concept without explanation. | No "wow" moments yet. | No. | Scoped redesign/art/motion. |
| Beginner trust | Safe copy, strong why-explanations. | Beginner can understand what to look at without reading dense UI. | Jargon/status/pills still require decoding. | Partly. | Table signal and copy hierarchy. |
| Motion/touch feel | Static evidence cannot prove it; action buttons look strong. | Transitions, proof banking, repair focus, and Sharky response feel premium in hand. | No video/device validation. | Unknown. | Motion/interaction validation. |

## 4. System-level blockers to 10/10

| Blocker | Evidence sources | Why it blocks 10/10 | Fix class | Owner | Before Human QA |
| --- | --- | --- | --- | --- | --- |
| 1. Table signal layer | Codex UX10-001, UX10-003, UX10-011, UX10-030; Claude F023, F061, F064, F071 | The table is the product core, but the active clue, pot, street, actor, and answer do not form an immediate visual chain. | Scoped redesign/component evolution | Codex + Claude Design | Yes |
| 2. Table-feedback integration | Codex UX10-001, UX10-004, UX10-035; Claude F033, F071 | Feedback explains the clue but does not visually attach to the table object that caused it. | Component evolution | Codex | Yes |
| 3. First decision actionability | Codex UX10-002; Claude F016, F020, F022 | The first real table read must be frictionless; current first-decision/seat-read moment spends attention on wrong objects or hides actionability. | Component evolution | Codex | Yes |
| 4. Feedback/repair/proof visual distinction | Codex UX10-004, UX10-005, UX10-037; Claude F026, F030, F032, F035 | Correct, wrong, repair, and repaired-success are too similar from a glance. | Component evolution | Codex + Claude Design | Yes |
| 5. Proof terminology overload | Codex UX10-036; Claude F073 | "Proof" appears in too many compound meanings, risking confusion in a concept meant to build trust. | Content/copy | Codex | Yes |
| 6. Sharky companion/art production | Codex UX10-006, UX10-018, UX10-038, UX10-042; Claude F029, F036, F081-F084 | Copy positions Sharky as a companion, but the art behaves like a small badge/icon. | Art/mascot production | Designer/illustrator + Claude Design | Yes for max-quality signal; depends if art not ready |
| 7. Container/card sameness | Codex UX10-015, UX10-058; Claude F078, F087 | One rounded-card grammar flattens hierarchy and makes key moments feel routine. | Scoped redesign/component evolution | Claude Design + Codex | Depends |
| 8. Hub tab distinctiveness | Codex UX10-023, UX10-044, UX10-049, UX10-050; Claude F002, F042, F050, F086, F088 | Home/Learn/Practice/Profile look too similar despite different jobs. | Component evolution | Codex + Claude Design | Depends |
| 9. Practice/Review value surfaces | Codex UX10-013, UX10-014, UX10-044, UX10-046, UX10-048; Claude F044, F045, F048, F049, F089 | Repair value exists but is expressed as text/cards rather than visible table clue and reason. | Component evolution | Codex | Yes |
| 10. Session Summary/Profile proof payoff | Codex UX10-008, UX10-041, UX10-043, UX10-049, UX10-050; Claude F037-F040, F038, F051 | The proof spine is real, but payoff and progress remain receipt-like/generic. | Component evolution | Codex | Yes for Summary; no/depends for Profile |
| 11. Day-2 return retention moment | Codex UX10-051, UX10-080; Claude F055, F080 | The retention-critical return state says Sharky remembered but does not dramatize the remembered clue. | Component evolution/art | Codex + designer/illustrator | Yes |
| 12. W11/W12/terminal milestone escalation | Codex UX10-009, UX10-012, UX10-052-055; Claude F056-F058, F090 | Late route looks too much like early route; terminal payoff uses ordinary screen grammar. | Scoped redesign | Codex + Claude Design | Depends |
| 13. Motion/touch absence | Codex UX10-010, UX10-016, UX10-040, UX10-083; Claude F019, F063, F076, F084 | Static screenshots cannot prove premium feel, jank absence, or reduced-motion behavior. | Motion/interaction validation | Codex + Human QA | Yes after Waves 1-3 |
| 14. Commercial screenshot power | Codex UX10-015; Claude product diagnosis, F080, F087 | The product is credible but lacks 3-4 ownable hero screenshots for external showing. | Scoped redesign + art/motion | Claude Design + designer/illustrator + Codex | No for Human QA; yes before external showing |

## 5. Deduplicated master backlog

Merged backlog count: **44 items**.

Merged severity counts:

- P0: **0**
- P1: **14**
- P2: **22**
- P3: **7**
- P4: **1**

| MB ID | Title | Source IDs | Area | Category | Severity | Current issue | Why this blocks 10/10 | Evidence paths | Proposed fix | Fix type | Best owner | Impact | Risk | Before Human QA | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| MB-001 | Table signal layer | UX10-001, UX10-003, UX10-011; F023, F061, F064, F071 | Table | table / visual hierarchy | P1 | Active clue, pot, actor, street, and action are split across small labels and panels. | The core promise is table-first learning; the table must teach by sight. | `06_first_decision.png`, `07_correct_feedback.png`, `17_w11_transfer.png` | Design a primary signal layer: active clue, pot/price, actor, and best-action link in one visible chain. | scoped redesign | Codex + Claude Design | high | medium | yes | Evidence-backed blocker. |
| MB-002 | First decision actionability | UX10-002; F016, F020, F022 | First decision | UX / learning | P1 | First table read does not focus the learner on the right thing quickly enough. | The first meaningful table decision is the product's trust test. | `06_first_decision.png`, `05_welcome.png` | Make first-decision controls/focus obvious; rebalance hero/villain card weight and stack/hero treatment. | component evolution | Codex | high | medium | yes | Preserve action buttons. |
| MB-003 | Table-to-feedback bridge | UX10-001, UX10-004, UX10-035; F033, F071 | Table + feedback | feedback / learning | P1 | Explanation panel and table clue read as separate products. | A 10/10 trainer shows "this clue caused this answer." | `07_correct_feedback.png`, `08_wrong_feedback.png`, `09_repair_focus.png` | Add shared accent/highlight/anchor from clue on felt to explanation below. | component evolution | Codex | high | medium | yes | Core learning blocker. |
| MB-004 | Correct/miss/repair/proof semantics | UX10-004, UX10-005, UX10-037; F026, F030, F032, F035 | Feedback | feedback / color / emotion | P1 | Correct, wrong, repair, and repaired-success share too much layout and palette. | State meaning should be visible in under one second. | `07_correct_feedback.png`, `08_wrong_feedback.png`, `09_repair_focus.png`, `10_targeted_recheck.png` | Define calm semantic states: correct, miss, repair, repaired proof; avoid alarm-red. | component evolution | Codex + Claude Design | high | medium | yes | Claude P0 reclassified to P1. |
| MB-005 | Repair focus density | UX10-005, UX10-039; F030, F031 | Repair | visual hierarchy / learning | P1 | Repair focus stacks too many labels and does not narrow attention enough. | Repair should feel like a focused corrective mode, not another text card. | `09_repair_focus.png`, `10_targeted_recheck.png` | Promote one repair question and one repeated clue; suppress nonessential table/panel noise. | component evolution | Codex | high | medium | yes | Evidence-backed. |
| MB-006 | Proof terminology overload | UX10-036; F027, F073 | App-wide | copy / learning | P1 | "Proof" is used for many related but distinct concepts. | A trust concept becomes jargon if every receipt/status/profile line uses it differently. | `07_correct_feedback.png`, `11_session_summary.png`, `15_profile.png` | Reserve "proof" for one meaning; rename secondary uses as clue, receipt, result, or progress. | content/copy | Codex | high | low | yes | Copy contract before visuals. |
| MB-007 | Sharky production system | UX10-006, UX10-018, UX10-029, UX10-038, UX10-042; F029, F036, F081-F084 | Sharky | Sharky / brand / motion | P1 | Sharky is small, badge-like, pose-thin, and inconsistently mapped to emotional states. | The companion is part of the brand promise but not yet production-grade. | `01_home.png`, `08_wrong_feedback.png`, `11_session_summary.png`, `13_review_empty.png` | Produce 5-7 pose set, signature frame, small/medium/hero sizes, and state mapping. | art/mascot production | Designer/illustrator + Claude Design | high | medium | yes/depends | Code follows art. |
| MB-008 | CTA overpowers learning | UX10-007, UX10-017; F004, F025, F028 | Feedback/Home | visual hierarchy / interaction | P1 | Large cyan CTAs often beat clue, answer, and explanation. | The learner remembers the button instead of the table read. | `01_home.png`, `08_wrong_feedback.png`, `09_repair_focus.png` | Keep tap targets but reduce CTA visual dominance on feedback/repair surfaces. | bounded polish | Codex | high | low | yes | Low risk. |
| MB-009 | Practice/Review current-clue value | UX10-013, UX10-014, UX10-044, UX10-048; F044, F045, F048, F049, F089 | Practice/Review | UX / learning | P1 | Active repair and practice surfaces explain value but do not show enough concrete table clue. | Return/practice must feel personalized to a real missed signal. | `12_practice_default.png`, `14_review_active.png` | Add compact clue preview/reason in active repair cards; de-emphasize locked inventory. | component evolution | Codex | high | medium | yes | Evidence-backed. |
| MB-010 | Session Summary proof payoff | UX10-008, UX10-041, UX10-043; F037-F040, F038 | Session Summary | payoff / learning | P1 | Proof and score are receipt-like, dense, and partly low in the scroll. | The session close should be a memorable earned proof moment. | `11_session_summary.png`, `11_session_summary_segment_03_bottom.png` | Make concrete table clue, result, score, and next action a single hierarchy above nav. | component evolution | Codex | high | medium | yes | Summary is pre-HQA important. |
| MB-011 | Day-2 return remembrance | UX10-051, UX10-080; F055, F080 | Home return | retention / Sharky / payoff | P1 | Day-2 return is visually ordinary despite a strong remembered-clue idea. | Habit value must feel personal, not generic. | `16_day2_return_home.png` | Add remembered-clue treatment and Sharky "I saved this clue" state. | component evolution | Codex + designer/illustrator | high | medium | yes | Retention-critical. |
| MB-012 | W12 terminal ceremony | UX10-009, UX10-055; F058 | W12 terminal | payoff / route | P1 | Volume I completion/no-W13 truth uses ordinary question/card grammar. | The arc-closing moment must feel earned without claiming mastery. | `19_w12_terminal.png` | Add terminal review handoff/ceremony state; do not open W13. | scoped redesign | Codex + Claude Design | high | medium | depends | Claude P0 reclassified to P1. |
| MB-013 | Late-route table maturity | UX10-012, UX10-052-054; F056, F057, F059, F090 | W11/W12 | table / payoff / copy | P1 | W11/W12 look too close to W1 and use more abstract copy. | A 12-week route needs visible maturity and consistent concrete language. | `17_w11_transfer.png`, `18_w12_payoff.png`, `19_w12_terminal.png` | Add late-route table escalation and tighten advanced copy to concrete table cues. | scoped redesign | Codex + Claude Design | high | medium | depends | Not W13 expansion. |
| MB-014 | Motion/touch validation layer | UX10-010, UX10-016, UX10-040, UX10-083; F019, F063, F076, F084 | Motion/touch | motion / interaction / accessibility | P1 | Static evidence cannot prove transitions, touch feel, contrast, or reduced-motion behavior. | Premium quality must be felt, not only seen. | Static pack plus future video/device evidence | Validate preflop->flop, proof landing, repair focus, Sharky response, terminal handoff. | motion/interaction | Codex + Human QA | high | medium | yes after visual P1s | Validation-first. |
| MB-015 | Container hierarchy tiers | UX10-015, UX10-058; F078, F087 | App-wide | visual hierarchy | P2 | One card/container style carries most content types. | Key moments and passive tips look equally important. | all screens/contact sheets | Define 2-3 container tiers for hero, active task, proof, support, passive info. | component evolution | Claude Design + Codex | high | medium | depends | Evidence-backed. |
| MB-016 | Hub tab distinctiveness | UX10-023, UX10-044, UX10-049, UX10-050; F002, F042, F050, F086, F088 | Home/Learn/Practice/Profile | UX / brand | P2 | Major tabs reuse the same hero-card grammar. | The IA promises distinct places; visuals deliver one template. | `01`, `02`, `12`, `15` screenshots | Give each tab a distinct opening composition and restrained semantic accent. | component evolution | Codex + Claude Design | medium | low | depends | Near-10 path. |
| MB-017 | Learn progress/nesting simplification | UX10-021-024; F010 | Learn | UX / visual hierarchy | P2 | Too many progress concepts and nested route cards appear at once. | Curriculum should feel guided, not layered with app-internal progress metaphors. | `02_learn.png`, `03_learn_lesson_detail.png` | Reduce visible progress layers; flatten journey preview. | bounded polish | Codex | medium | low | no | Safe after table P1s. |
| MB-018 | Placement/Welcome empty-space rhythm | UX10-025-029; F011, F014-F018 | Placement/Welcome | spacing / onboarding | P2 | Large dead areas and table/panel seams weaken entry flow. | First-start should feel intentional and table-first. | `04_placement.png`, `05_welcome.png` | Rebalance vertical rhythm, stepper clarity, and first table/handoff composition. | bounded polish/component evolution | Codex | medium | low | yes for easy fixes | Some overlap with MB-002. |
| MB-019 | Pot/stack/BTN/blind hierarchy | UX10-011, UX10-031, UX10-033; F020, F060, F064, F066 | Table | table / typography | P2 | Decision-critical table artifacts are under-prioritized or inconsistent. | Poker training requires pot, stack, BTN, and blinds to read clearly. | `06_first_decision.png`, `07_correct_feedback.png`, `17_w11_transfer.png` | Raise stack/pot, unify blind-chip token, strengthen dealer/BTN artifact. | component evolution | Codex | high | low | yes | Often part of Wave 1. |
| MB-020 | Board/status header consistency | UX10-030, UX10-031; F023, F034, F065 | Table | table / visual system | P2 | Board header zone swaps pills, labels, banners, and progress without shared structure. | The most-viewed table area should not feel state-thrashy. | `07_correct_feedback.png`, `17_w11_transfer.png` | Create flexible status header component with clear priority. | component evolution | Codex | medium | medium | yes | Feeds MB-001. |
| MB-021 | Hero/villain card weighting | UX10-032, UX10-066; F016, F061, F062 | Table | table / visual hierarchy | P2 | Villain card backs compete with hero hand and table clue. | Eye goes to low-value objects before the user's hand/read. | `05_welcome.png`, `06_first_decision.png` | Tune size/opacity/elevation so hero hand and clue dominate. | component evolution | Codex | high | medium | depends | Designer review helpful. |
| MB-022 | Review active mini table clue | UX10-013, UX10-048; F048, F049 | Review | learning / visual hierarchy | P2 | Active miss card is text-heavy and visually detached from the original clue. | Review must feel like exact repair, not a text log. | `14_review_active.png` | Add mini table signal or source-clue preview. | component evolution | Codex | high | medium | yes | Could merge with MB-009 in implementation. |
| MB-023 | Practice locked inventory impression | UX10-044, UX10-045; F044, F045, F089 | Practice | UX / product value | P2 | Secondary practice grid is mostly locked and repeats gating explanation. | Practice can read sparse/demo-like if the current useful rep is not the hero. | `12_practice_default.png` | Clarify unlock path, reduce repeated gating copy, foreground current rep. | component evolution/content | Codex | medium | low | depends | Not monetization. |
| MB-024 | Profile concrete proof moments | UX10-049, UX10-050; F050-F053 | Profile | proof / payoff | P2 | Profile proof is a strong concept but generic in visual execution. | "Proof not points" must show real earned moments, not inventory stats. | `15_profile.png` | Prioritize earned reads/repair moments; reduce stat-box sameness. | component evolution | Codex | high | medium | no | External showing path. |
| MB-025 | Sharky signature frame/icon language | UX10-018, UX10-047; F082, F083 | Sharky | brand / iconography | P2 | Sharky frame resembles generic icon/card treatment. | Companion needs instant recognition outside copy. | `01_home.png`, `02_learn.png`, `12_practice_default.png` | Define dedicated Sharky frame/silhouette/ring not reused for topic icons. | art/mascot production | Designer/illustrator | medium | low | depends | Subject to active three-register art direction. |
| MB-026 | Sharky state placement | UX10-029, UX10-038, UX10-042, UX10-080; F029, F036 | Sharky | emotional UX | P2 | Existing poses/placements do not match miss, proof, return, terminal beats. | Emotional support and brand memory require correct state mapping. | `08_wrong_feedback.png`, `11_session_summary.png`, `16_day2_return_home.png` | Map neutral/coach/miss/repair/proof/milestone/terminal to proper placements. | art/mascot production | Designer/illustrator + Codex | high | medium | depends | Code only after art. |
| MB-027 | Session Summary exits/next action | UX10-043; F039, F074 | Session Summary | UX / copy | P2 | Replay/back/continue labels do not always explain what happens next. | End-of-session handoff should not create decision ambiguity. | `11_session_summary_segment_03_bottom.png` | Clarify replay target and primary/secondary action priority. | content/copy | Codex | medium | low | yes | Can be Wave 2. |
| MB-028 | W11/W12 concrete voice | UX10-052, UX10-054, UX10-081; F057, F090 | W11/W12 | copy / beginner trust | P2 | Late-route copy shifts toward abstract coaching terms. | Advanced does not mean vague; trust comes from concrete table cues. | `17_w11_transfer.png`, `18_w12_payoff.png` | Rewrite late-route labels to concrete cue/action language. | content/copy | Codex | medium | low | yes/depends | Preserve authored meaning. |
| MB-029 | Welcome first table exposure | UX10-028, UX10-029; F015, F016 | Welcome | first impression / table | P2 | First table exposure shows too little of what makes a "read" compelling. | The first table sight should sell the product concept. | `05_welcome.png` | Preview a real table clue and hand relationship without overloading. | component evolution | Codex + Claude Design | medium | medium | depends | No route change. |
| MB-030 | Tablet smoke not investor-grade | UX10-056; Claude tablet notes | Tablet | UX / commercial | P2 | Tablet appears smoke-safe but not premium/tablet-native. | External tablet screenshots should not be treated as commercial proof. | tablet contact sheets | Keep tablet smoke-only unless commercial tablet goal is opened. | future/preference | Designer/illustrator | low | high | no | Explicitly not a blocker. |
| MB-031 | Text scale and contrast floor | UX10-034, UX10-057, UX10-085; F014, F063, F085 | App-wide | typography / accessibility | P2 | Small labels and gray-on-navy meta text may sit near comfort limits. | Beginner/mobile trust depends on effortless readability. | `04_placement.png`, table captures, `15_profile.png` | Define minimum text/contrast floor for decision-relevant labels. | bounded polish | Codex | medium | low | yes for table labels | Needs device check. |
| MB-032 | Bottom inset/nav collision | UX10-041, UX10-076; Claude Summary notes | Session Summary/Review | spacing / accessibility | P2 | Lower content can crowd nav or visible bottom. | Important result/next-step copy must remain readable above nav. | `11_session_summary.png`, `13_review_empty.png` | Add bottom safe-area/inset policy for summary/review content. | bounded polish | Codex | medium | low | yes | Low risk. |
| MB-033 | Progress and badge consistency | UX10-021, UX10-027, UX10-061, UX10-062; F001, F012, F070, F075 | App-wide | UI / navigation | P2 | Progress bars, streak/daily badges, and nav badges are inconsistent. | Wayfinding should be calm and meaningful, not label noise. | Home/Learn/Placement/Table/Summary | Consolidate progress/badge policy and reuse best progress component. | bounded polish | Codex | medium | low | depends | Avoid fake urgency. |
| MB-034 | Empty-state copy density | UX10-046; F046, F047 | Review empty | copy / UX | P2 | Empty Review explains too much and repeats Sharky/tip structures. | Zero-state should reassure and redirect quickly. | `13_review_empty.png` | Shorten to one promise, one example, one CTA; defer full legend if no miss. | bounded polish | Codex | medium | low | no | Subjective but evidence-backed. |
| MB-035 | Commercial hero screenshot set | UX10-015; F080, F087 | App-wide | brand / payoff | P2 | No 3-4 screenshots yet create top-1 external reaction. | External showing needs ownable scenes, not just coherent UI. | contact sheets | Build hero-grade scenes: first read, miss repair, proof banked, Volume I complete. | scoped redesign | Claude Design + Codex + designer/illustrator | high | high | no | Before investor/external, not HQA. |
| MB-036 | Elevation/color token system | UX10-059; F077, F086 | App-wide | color / elevation | P2 | The product leans on one navy/cyan grammar and flat borders/glow. | Premium feel needs hierarchy and semantic accents. | all screens | Define restrained semantic colors and elevation tiers; avoid one-note palette. | component evolution | Claude Design + Codex | medium | medium | depends | Not generic reskin. |
| MB-037 | Bottom nav polish | UX10-061; F075 | Bottom nav | UX / UI | P3 | Nav is clear but badge policy and ordinary feel can be tightened. | It does not block 10/10 alone, but polish helps coherence. | bottom nav screens | Keep IA; adjust badges only where meaningful. | bounded polish | Codex | low | low | no | Protect bottom nav. |
| MB-038 | Icon stroke/generic icons | UX10-060; F043, F079 | App-wide | iconography | P3 | Icons are serviceable but generic/inconsistent. | Ownable premium product benefits from proprietary proof/repair/clue icons. | Home/Learn/Practice/Profile | Standardize stroke; later create small proprietary icon set. | art/mascot production | Designer/illustrator | medium | medium | no | Not before HQA. |
| MB-039 | Low-contrast links/chips | UX10-019, UX10-031; F007, F008 | Home/Learn/Table | typography / accessibility | P3 | Some small chips/links are easy to miss. | Adds scanning friction but is not a core blocker. | `01_home.png`, `02_learn.png`, table captures | Improve affordance/contrast where labels carry action. | bounded polish | Codex | low | low | no | Can ride with P2 polish. |
| MB-040 | Learn accordion affordance | UX10-024; F009 | Learn | interaction | P3 | Collapsed journey rows are not strongly discoverable. | Minor path-discovery friction. | `02_learn.png`, `03_learn_lesson_detail.png` | Add subtle expand affordance or reduce reliance on accordion. | bounded polish | Codex | low | low | no | Not a blocker. |
| MB-041 | Review empty Sharky repetition | UX10-047; F047 | Review | Sharky / copy | P3 | Similar Sharky bubbles repeat in zero-state. | Slightly weakens polish/memorability. | `13_review_empty.png` | Consolidate or vary the companion treatment. | bounded polish | Codex | low | low | no | Subjective taste. |
| MB-042 | Generic "Continue" labels | UX10-074; F074 | App-wide | copy / CTA | P3 | "Continue" carries multiple different actions. | Specific CTAs can add anticipation but this is not a core blocker. | feedback/W12 captures | Use action-specific copy for higher-stakes transitions. | content/copy | Codex | low | low | no | Avoid over-clever copy. |
| MB-043 | Card nesting/taste cleanup | UX10-058; F010, F013 | App-wide | visual hierarchy | P3 | Some rounded cards inside rounded cards create visual fatigue. | Contributes to sameness but can be subjective. | all non-table screens | Remove redundant containers opportunistically when touching a surface. | bounded polish | Codex | medium | low | no | Marked subjective design taste unless tied to a P1 blocker. |
| MB-044 | Tablet-native premium redesign | UX10-084; Claude tablet scope | Tablet | UX / commercial | P4 | Tablet is smoke-only and not part of current commercial proof path. | It matters only if tablet becomes a target surface. | tablet contact sheets | Do not redesign tablet until a commercial tablet goal exists. | future/preference | Designer/illustrator | low | high | no | Future only. |

## 6. Design evolution decision map

| System | Classification | Reason | Target state | First admitted wave |
| --- | --- | --- | --- | --- |
| Bottom navigation | A. Keep mostly as-is | Clear, standard, not a blocker. | Preserve labels/IA; adjust badges only if policy demands. | Wave 4 or later only if touched. |
| Home hero | C. Component evolution | Strong flow, generic hero-card shape, CTA dominance. | Return/continue card carries concrete clue and Sharky memory. | Wave 4, with Day-2 slice in Wave 2/5. |
| Learn curriculum | B. Bounded polish | Readable but progress/nesting heavy. | Cleaner route preview and fewer visible progress metaphors. | Wave 4. |
| Practice | C. Component evolution | Current useful rep is not vivid enough; locked grid can read empty. | Current repair/useful rep is the hero; inventory is secondary. | Wave 2 or Wave 4. |
| Review | C. Component evolution | Concept is strong; active state needs visible table clue. | Miss card shows the exact clue and repair reason. | Wave 2. |
| Profile | C. Component evolution | Proof profile idea is strong; proof remains generic. | Concrete earned reads/moments over stat inventory. | Wave 5. |
| Table felt/board/pot/status | D. Scoped redesign | Central system cannot reach 10 through polish alone. | Unified status/signal layer with pot/actor/clue priority. | Wave 1. |
| Hero/seat/BTN/blind treatment | C. Component evolution | Present but under-weighted/inconsistent. | Hero and BTN/blinds read as poker artifacts at a glance. | Wave 1. |
| Action controls | A. Keep mostly as-is | Large, clear, touch-friendly; both reviews mark them as a strength. | Preserve size/color semantics; only adjust surrounding hierarchy. | Protected in all waves. |
| Feedback panel | C. Component evolution | Strong copy, weak state semantics and clue linkage. | Miss/repair/proof/correct states distinct at a glance. | Wave 2. |
| Repair focus | C. Component evolution | Too label-dense; clue focus not strong enough. | One repeated clue, one repair question, clear action. | Wave 2. |
| Proof/summary | C. Component evolution | Real proof is receipt-like and dense. | Concrete proof payoff with table clue, score, next action. | Wave 2 and Wave 5. |
| W11/W12/terminal | D. Scoped redesign | Late route lacks maturity/ceremony. | Advanced route visibly escalates without W13 or mastery claims. | Wave 5 and Wave 6. |
| Sharky | E. New art/animation production | Current art cannot carry 10/10 brand role. | Three-register, same-character system with state/pose/motion mapping. | Wave 3. |
| Motion/touch | F. Human QA validation | Static evidence cannot prove feel. | Video/device evidence for key transitions and reduced-motion behavior. | Wave 7. |
| Typography/color/elevation | C. Component evolution | One palette/card/elevation language flattens hierarchy. | Semantic state accents and 2-3 elevation/container tiers. | Wave 2 and Wave 4. |

## 7. Wave roadmap to strong 10/10

### Wave 0 - SSOT / no-code planning

- Goal: this artifact.
- Included MB IDs: all MB-001 through MB-044 as planning scope.
- Target score lift: no score lift; creates control plane.
- Owner/tool: Codex, strongest available, high effort.
- Recommended model/effort: Codex, strongest available, high effort.
- Implementation DoD: merged backlog and direction plan accepted.
- Evidence required: this docs-only artifact; imported Claude source artifact.
- What not to touch: product code, tests, screenshots, output evidence, route/content/telemetry/W13 behavior.
- Risk: low.
- Should Human QA wait: yes, pending Wave 1-3 if max-quality signal is the goal.

### Wave 1 - Table Signal + First Decision Actionability

- Goal: make the table teach by sight.
- Included MB IDs: MB-001, MB-002, MB-003, MB-019, MB-020, MB-021, MB-029, MB-031.
- Target score lift: table/gameplay +0.7 to +1.2; overall +0.4 to +0.6.
- Owner/tool: Codex implementation with Claude Design review for signal hierarchy.
- Recommended model/effort: Codex, strongest available, high effort.
- Implementation DoD: W1 first decision, correct/wrong/repair, W11, and W12 table captures show active clue, pot/price, actor, and action relationship at a glance.
- Evidence required: refreshed compact visible/full-scroll screenshots and contact sheet; no output staged.
- What not to touch: answer correctness, source route specs, W13+, action button design.
- Risk: medium.
- Should Human QA wait for it: yes.

### Wave 2 - Feedback / Repair / Proof System

- Goal: make Miss, Repair, and Proof visually/emotionally distinct and connected to table clue.
- Included MB IDs: MB-003, MB-004, MB-005, MB-006, MB-008, MB-009, MB-010, MB-022, MB-027, MB-032, MB-036.
- Target score lift: learning-loop +0.5 to +0.8; UX +0.4 to +0.7.
- Owner/tool: Codex; Claude Design for semantic state language if color/elevation tokens are touched.
- Recommended model/effort: Codex, strongest available, high effort.
- Implementation DoD: a fresh viewer can sort correct/miss/repair/proof screenshots without reading small labels; proof vocabulary has one reserved meaning.
- Evidence required: same scenario captured in correct, wrong, repair, recheck, and summary states.
- What not to touch: Miss -> Repair -> Proof concept, answer correctness, telemetry.
- Risk: medium.
- Should Human QA wait for it: yes.

### Wave 3 - Sharky Companion Direction + Art Production

- Goal: create the companion system needed for 10/10.
- Included MB IDs: MB-007, MB-011, MB-025, MB-026, MB-038, MB-041.
- Target score lift: Sharky companion +1.5 to +2.5 after art lands; overall +0.3 to +0.6.
- Owner/tool: Claude Design and designer/illustrator first, Codex second.
- Recommended model/effort: Claude Design, Opus/strongest available design model, maximum effort; designer/illustrator production pass.
- Implementation DoD: same-character state set for neutral, coach, miss, repair, proof, return, milestone/terminal; 16dp/34dp/68-92dp viability; no random personality logic.
- Evidence required: design board, pose-to-moment map, small/medium/hero scale tests, later refreshed screenshots.
- What not to touch: phrase truth, proof claims, route semantics, cosmetic economy.
- Risk: medium to high because art direction can churn.
- Should Human QA wait for it: yes if max-quality emotional signal matters; depends if art schedule would block too long.

### Wave 4 - Hub / Value Surface Evolution

- Goal: Home/Learn/Practice/Review/Profile stop feeling like one repeated hero-card template.
- Included MB IDs: MB-015, MB-016, MB-017, MB-018, MB-023, MB-024, MB-033, MB-034, MB-037, MB-039, MB-040, MB-043.
- Target score lift: premium visual +0.4 to +0.8; commercial impression +0.3 to +0.5.
- Owner/tool: Codex with Claude Design review for per-tab treatments.
- Recommended model/effort: Codex, strongest available, high effort; Claude Design high effort for visual system decisions.
- Implementation DoD: each tab's opening treatment signals its job; repeated container chrome reduced where it weakens hierarchy.
- Evidence required: side-by-side Home/Learn/Practice/Review/Profile contact sheet.
- What not to touch: bottom nav IA, route semantics, monetization/paywall.
- Risk: medium.
- Should Human QA wait for it: depends. For max-quality signal, yes through the Practice/Review active slices; otherwise can run after Human QA.

### Wave 5 - Payoff / Ceremony / Late-Route Evolution

- Goal: Session Summary, Day-2 return, W11/W12, and W12 terminal feel earned and memorable.
- Included MB IDs: MB-010, MB-011, MB-012, MB-013, MB-024, MB-027, MB-028, MB-035, MB-042.
- Target score lift: commercial/investor-showing +0.8 to +1.2; payoff +1.0.
- Owner/tool: Codex plus Claude Design.
- Recommended model/effort: Claude Code or Codex, strongest available, high effort; Claude Design strongest available design model, maximum effort for ceremony language.
- Implementation DoD: Day-2 return and W12 terminal are distinguishable from ordinary screens at a glance; no W13 or mastery implication.
- Evidence required: compact/full-scroll captures for Session Summary, Day-2 return, W11, W12 payoff, W12 terminal.
- What not to touch: W13+, public readiness claims, durable mastery claims.
- Risk: medium.
- Should Human QA wait for it: depends. Recommended before external/investor showing.

### Wave 6 - Table Escalation / Advanced Route Visual Evolution

- Goal: W1 table and W11/W12 table no longer feel pixel-identical; late-route maturity appears without changing route semantics.
- Included MB IDs: MB-001, MB-013, MB-019, MB-020, MB-021, MB-028, MB-035.
- Target score lift: table/gameplay +0.8 to +1.2; 10/10 ceiling lift.
- Owner/tool: Claude Design first, Codex implementation second.
- Recommended model/effort: Claude Design, Opus/strongest available design model, maximum effort; Codex strongest available, high effort.
- Implementation DoD: defined escalation language for early vs late tables, with board texture/cue emphasis and consistent status artifacts.
- Evidence required: W1 vs W11/W12 side-by-side captures; no route-semantic drift.
- What not to touch: route IDs, content ownership, poker correctness.
- Risk: medium/high.
- Should Human QA wait for it: not necessarily for first Human QA; yes before serious 10/10 re-review.

### Wave 7 - Motion / Touch / Microinteraction Layer

- Goal: prove and improve premium feel in hand.
- Included MB IDs: MB-014, MB-031, MB-036 plus motion portions of MB-007, MB-010, MB-012.
- Target score lift: unknown from static evidence; likely strong perceived-premium lift.
- Owner/tool: Codex for implementation/evidence; Human QA for feel; designer/illustrator for Sharky motion.
- Recommended model/effort: Codex, strongest available, high effort; Human QA fixed protocol after implementation.
- Implementation DoD: video/device evidence for proof banking, repair focus, preflop->flop, Sharky response, terminal handoff; reduced-motion behavior verified.
- Evidence required: motion capture/video and device notes.
- What not to touch: telemetry, route logic, hidden proof claims.
- Risk: medium.
- Should Human QA wait for it: yes if the specific Human QA goal is premium feel; no if Human QA is comprehension-only after Waves 1-3.

### Wave 8 - Full 10/10 Re-review Pack

- Goal: regenerate evidence and run final brutal review.
- Included MB IDs: all remaining open MB IDs, especially MB-030, MB-035, MB-044 for scope decisions.
- Target score lift: no direct lift; validates whether 9.0+ or 9.5+ is plausible.
- Owner/tool: Codex for packet generation; Claude/Codex challenger reviews; Human QA if admitted.
- Recommended model/effort: Codex strongest available, high effort; Claude Design/Claude Code strongest available, maximum/high effort.
- Implementation DoD: fresh real-text pack, compact/full-scroll contact sheets, video/motion evidence if motion touched, merged closure report.
- Evidence required: refreshed visual pack and independent re-review.
- What not to touch: launch/public readiness claims unless separately scoped.
- Risk: low/medium.
- Should Human QA wait for it: Human QA can run before this if Waves 1-3 are accepted; final 10/10 claims must wait.

## 8. Immediate next implementation wave

First implementation wave after this plan: **Wave 1 - Table Signal + First Decision Actionability**.

Why this first:

- It is the strongest overlap between Codex and Claude.
- It touches the heart of the product: the table read.
- It improves Human QA signal because testers can then judge comprehension instead of reporting obvious clue/signal hierarchy issues.
- It has a clear scope and does not require new Sharky art before starting.

Why not Sharky first:

- Sharky needs design/illustration production and final art-direction control; starting implementation before art risks placeholder churn.
- Table signal is prerequisite context for where Sharky should point, react, or coach.

Why not global visual polish first:

- Global polish can make the same weak table signal look cleaner without solving the product problem.
- The goal is not an 8.0/8.5 cosmetic pass; the first wave must move the 10/10 ceiling.

Exact MB IDs:

- MB-001
- MB-002
- MB-003
- MB-019
- MB-020
- MB-021
- MB-029
- MB-031

Success looks like:

- In `06_first_decision.png`, the learner immediately sees hero/BTN/stack and what the first table-read action is asking.
- In feedback states, the exact table clue visually connects to the answer and explanation.
- Pot/price/status labels no longer feel like minor metadata.
- Action controls remain as strong as they are now.

Implementation owner: **Codex, strongest available, high effort**, with a Claude Design pass if the signal layer requires new visual language beyond existing tokens.

## 9. Tool/model/effort recommendations

| Tool/owner | Use when | Model strength | Effort | Guardrails |
| --- | --- | --- | --- | --- |
| Codex | Implementing bounded UI/component changes, writing docs, updating tests/guards, regenerating evidence packets. | Codex, strongest available, high effort. | High. | Stay in admitted MB IDs; preserve route semantics, answer correctness, telemetry, W13+, content-engine architecture, output unstaged. |
| Claude Code | Alternative implementation agent for copy/spacing/component waves, especially when Codex needs a second pass. | Claude Code, strongest available, high effort. | High. | Same guardrails as Codex; do not originate new art. |
| Claude Design | Defining visual direction for table signal, feedback semantic states, hub distinctiveness, Sharky direction, and ceremony. | Claude Design, Opus/strongest available design model, maximum effort. | Maximum. | Produce direction boards/specs, not route or code changes; no Runout copying; respect Sharky three-register lock. |
| Designer/Illustrator | Sharky poses, signature frame, hero/terminal art moments, production-ready mascot assets, and possible table/ceremony art direction. | Human designer/illustrator. | Production-quality pass. | Deliver same-character continuity, small-size tests, source files/export specs, reduced-motion/motion notes if animated. |
| Human QA | Validating comprehension, touch feel, motion feel, emotional reaction, trust, and beginner understanding after predictable visual blockers are removed. | Fixed human protocol, not model-dependent. | Targeted. | No fake/synthetic QA; no public readiness or learning-effect claims from static review. |

## 10. Human QA gate

Should Human QA wait right now: **yes, if max-quality Human QA signal is the goal.**

Waves that should land before Human QA for max-quality signal:

- Wave 1 - Table Signal + First Decision Actionability.
- Wave 2 - Feedback / Repair / Proof System.
- Wave 3 - Sharky Companion Direction + Art Production, at least a direction/placement pass; full art can be a dependency decision if schedule is too high.
- Selected Wave 4 slices for active Practice/Review if they remain visibly generic after Waves 1-2.

Waves that can run after Human QA:

- Full hub visual distinctiveness if not tied to active repair comprehension.
- Profile proof upgrade.
- W11/W12 advanced table escalation.
- Commercial hero screenshot polish.
- Tablet-native redesign.
- Final full 10/10 re-review.

What Human QA uniquely answers:

- Whether real beginners identify the table clue without coaching.
- Whether users understand miss -> repair -> proof as a loop rather than jargon.
- Whether action controls, bottom panels, and nav feel comfortable on physical devices.
- Whether Sharky helps, distracts, or feels emotionally correct.
- Whether motion/transitions feel premium, slow, or confusing.
- Whether proof/return language creates trust or overclaims.

## 11. What not to change

Protect:

- Route semantics.
- Answer correctness.
- W13+.
- Telemetry.
- Content-engine architecture.
- Miss -> Repair -> Proof concept.
- Working action controls unless directly admitted by a table/actionability wave.
- Bottom nav IA unless evidence proves harm.
- No fake progress, fake proof, fake misses, fake mastery, fake Human QA, or synthetic learner evidence.
- No public readiness, launch readiness, premium commercial readiness, or 10/10 proof claims from this plan.
- No copied Runout assets, layouts, category names, charts, paywall story, or analytics theater.
- No screenshots/output staging unless a future prompt explicitly admits them.

## 12. Final recommended path

First 3 actions:

1. Accept this SSOT backlog/direction plan as Wave 0.
2. Run Wave 1 - Table Signal + First Decision Actionability with Codex, strongest available, high effort.
3. In parallel, prepare Wave 3 Sharky art-direction production brief for Claude Design/designer review, but do not implement Sharky assets until direction is accepted.

First implementation wave:

- Wave 1 - Table Signal + First Decision Actionability.

When to bring Claude Design again:

- Before Wave 1 if the table signal layer needs new visual language.
- Definitely before Wave 3 Sharky art production.
- Before Wave 5/6 if terminal ceremony or late-table escalation becomes more than component evolution.

When to bring designer/illustrator:

- After Claude Design narrows Sharky to a production-ready state/pose system.
- Before any claim that Sharky can support a 10/10 brand/companion bar.

When to refresh Human QA baseline:

- After Waves 1-2 land, and after Wave 3 direction/art decision is either landed or explicitly deferred.
- If art is deferred, the Human QA protocol should name current Sharky as a known visual limitation so feedback is not misread as surprising.

Score targets:

- Before Human QA: aim for **8.4-8.8** static visual/UX band, not a 10/10 claim.
- Before external/investor showing: aim for **9.0+** static visual/commercial band with 3-4 hero-grade screenshots and no unresolved P1/P2 commercial blockers.
- Before any 10/10 claim: require Wave 8 re-review plus Human QA/motion evidence; this plan alone is not proof.

Validation for this docs-only wave:

- Docs-only diff.
- `git diff --check`.
- `graphify hook-check`.

Final implementation guidance:

- Do not optimize for "acceptable for Human QA."
- Optimize for removing the system blockers that would cap the product below a strong 10/10 path.
