---
status: "REVIEW ARTIFACT - docs-only, static visual evidence"
status_source: "derived"
baseline: "485e773c5406"
generated_by: "docs_frontmatter_v1"
---

# Full UI/UX Visual 10/10 Deconstruction v1

Status: REVIEW ARTIFACT - docs-only, static visual evidence.

Evidence pack: `/Users/elmarsalimzade/.config/superpowers/worktrees/Sharky_1.0/pre-human-qa-max10-push-v5/output/design_review/real_text_visual_pack_v5.zip`

Extracted inspection copy: `/tmp/sharky_real_text_visual_pack_v5/real_text_visual_pack_v5/`

Pack commit: `485e773c540638c7168a3d5a23d5dab339dd08b2`

Pack status: `clean_or_output_only`

Pack coverage: 19/19 screens, 108 entries, compact phone primary, tablet smoke only.

Allowed claim boundary: visual hierarchy, copy readability, density, CTA clarity, first impression, premium/product feel, empty-state quality, navigation clarity, and screen-to-screen continuity.

Disallowed claim boundary: no Human QA approval, public readiness, launch readiness, 9.0 proof, 10/10 proof, durable learning effect, beginner mastery, or premium commercial readiness.

## Verdict

This does not yet feel like a top-1 premium mobile poker trainer. It feels like a competent, unusually coherent poker-learning app with polished cards, good copy discipline, and a real product concept. The ceiling visible in this packet is not "broken app"; the ceiling is that the core learning moment still looks like a table screenshot stacked above an explanation card, not one premium interactive teaching instrument.

Current overall score from static visual evidence: **7.8 / 10**.

UI score: **8.0 / 10**.

UX score: **7.7 / 10**.

Premium visual score: **7.4 / 10**.

Table/gameplay score: **7.2 / 10**.

Sharky companion score: **6.4 / 10**.

Learning-loop score: **8.0 / 10**.

Commercial/investor-showing score: **7.3 / 10**.

The exact blockers to 10/10 are:

- The table is attractive but not yet a strong enough learning object. The clue, actor, pot, street, and best action are present, but they do not form an immediate visual chain.
- Feedback panels over-own the moment. CTAs and cards often overpower the learning signal rather than acting as the next step in the same table read.
- Sharky is not yet a premium companion. The small badge/PNG system is useful, but it does not carry brand memory, emotional state, or milestone ceremony at top-product level.
- Many screens share the same dark card grammar, teal/cyan emphasis, large CTA, and rounded-panel rhythm. That makes the app coherent, but also visually samey.
- Motion, touch feel, and transition affordance are under-proven by static screenshots and visibly under-expressed in the design language.
- Empty/value surfaces such as Review, Practice, Profile, and Session Summary explain value but do not always make the user feel the value.

Redesign decision: **Option 2 - current system can reach 8.5-9 through bounded/component evolution, but needs visual direction evolution for 10.** No full product redesign is required before Human QA. The table-feedback-Sharky system does require component evolution before a serious external/investor showing, and selected P1s should be fixed before Human QA if the owner wants max-quality tester signal.

## Product-Level Diagnosis

The product has a clear identity: one real spot, one answer, one clear why. That identity is visible in Home, Learn, Review, Practice, and late-route screens. The problem is that the visible product is still more "well-designed lesson app" than "desirable poker training instrument."

The most important premium gap is not color or shadows. It is signal choreography. A 10/10 poker trainer would make the user's eye travel from hero seat to board/pot/action state to answer to repair/proof without decoding multiple pills, panels, and labels. Sharky currently asks the user to read several UI objects to reconstruct that chain.

The system has no hard strategic ceiling, but it has a current component ceiling. The table component, feedback component, and Sharky component need to evolve together. Bounded polish can lift readability and CTA hierarchy. Component evolution is needed to make the table and feedback one learning system. Larger redesign is not justified before Human QA unless the goal changes from max-quality QA to investor-grade visual theater.

## Full Journey Audit

### 1. Home

What the user should understand: continue today's table read, then practice/review.

What the eye sees first: the large cyan Continue CTA, then "Fold, check, call, raise."

Assessment: strong first action, but CTA overpowers the learning concept. The sequence below is clear, yet lower contrast and partly clipped in the Review row. Sharky is reduced to a tiny identity badge and does not emotionally greet or coach.

Fix class: bounded polish plus Sharky component evolution.

### 2. Learn

What the user should understand: W1 current lesson, lesson progress, route support.

What the eye sees first: the large lesson card and Start CTA.

Assessment: clear and functional. It has too many progress metaphors in one viewport: Today count, 3d badge, world card, percentage bar, current lesson, current step, foundation map, journey preview. The "Foundation map" is useful but visually competes with the actual lesson.

Fix class: bounded polish.

### 3. Learn Lesson Detail

What the user should understand: exact lesson contents and path.

What the eye sees first: same large lesson card and Start CTA.

Assessment: detail state is readable but not meaningfully more premium than Learn. The journey preview becomes a dense nested list. The user can understand it, but the page feels like another card stack rather than a guided curriculum map.

Fix class: component evolution for path preview.

### 4. Placement

What the user should understand: quick start, no exam, answer two questions.

What the eye sees first: Sharky Poker hero and Find your start.

Assessment: one of the stronger brand-entry screens. The issue is nested panels and repeated reassurance. The stepper is small relative to the card mass, and the bottom CTA is separated by a large dead area.

Fix class: bounded polish.

### 5. Welcome

What the user should understand: meet the table, receive first clue, proceed.

What the eye sees first: the table.

Assessment: table-first is correct. The bottom teaching panel is useful. However, the panel and table feel like separate products, with a hard horizontal seam. Sharky is absent from the main table read.

Fix class: component evolution.

### 6. First Decision / First Table Read

What the user should understand: locate hero before choosing actions.

What the eye sees first: huge felt surface, then hero seat, then bottom prompt.

Assessment: the prompt is good, but the answer options are not visible in the compact first viewport. The table wastes too much central felt for a task about seat location, and the hero highlight is not commanding enough for the first active skill.

Fix class: component evolution; P1 before max-quality Human QA.

### 7. Correct Feedback

What the user should understand: check was correct because nobody bet yet; proof was banked.

What the eye sees first: table, proof badge, bottom card, huge Continue.

Assessment: conceptually strong. Visually, the clue-to-proof chain is fragmented: "No bet yet" lives in a small board pill, proof lives in a floating table badge, explanation lives in the panel, CTA sits at the bottom. A 10/10 version would connect these with a clear signal path.

Fix class: feedback/table component evolution.

### 8. Wrong Feedback

What the user should understand: better option is Check; folding gives up the hand.

What the eye sees first: table, then muted grey panel.

Assessment: supportive tone is good, but the wrong state lacks enough emotional and instructional distinction. It feels subdued rather than actively corrective. Sharky becomes a small badge, and the repair CTA dominates the panel.

Fix class: feedback component evolution plus Sharky state work.

### 9. Repair Focus

What the user should understand: repeat the same clue; ask whether a bet faces you.

What the eye sees first: table, then Table clue card.

Assessment: good repair specificity. The issue is the same table/panel split. The actual clue is inside a small line while the CTA is oversized. Repair feels like "same screen with a different card" more than a focused corrective mode.

Fix class: component evolution.

### 10. Targeted Recheck / Repair Result

What the user should understand: retry the clue, then land proof.

What the eye sees first: same table; result panel after completion.

Assessment: the sequence is coherent but visually under-celebrated. The recheck and proof states look too similar to ordinary feedback states. The state change is mostly text.

Fix class: motion/interactions plus feedback component evolution.

### 11. Session Summary

What the user should understand: first read banked; replay before moving on; practice next.

What the eye sees first: large gold "First read banked."

Assessment: highest-emphasis payoff screen in the pack, but it still feels like a receipt card rather than a premium accomplishment moment. Gold is correctly reserved, yet the hero card is dense, Sharky is small/awkward, and the bottom nav clips the lower content.

Fix class: payoff component evolution; P1/P2 depending on Human QA target.

### 12. Practice Default / Repair State

What the user should understand: start short reps, repair keeps clue fresh.

What the eye sees first: Start daily set card and CTA.

Assessment: clear but static. Locked tiles below suggest breadth, but they look more like disabled app inventory than personalized value. The screen needs more "alive" repair priority and less generic category grid.

Fix class: UX and value component evolution.

### 13. Review Empty

What the user should understand: no misses yet; go Learn; Review will save exact misses.

What the eye sees first: Review header and large empty-state card.

Assessment: helpful, but over-explained. Empty state has strong copy, yet the card is large and low-emotion. The "How Review Works" block reads like documentation inside the app.

Fix class: bounded polish.

### 14. Review Active Repair State

What the user should understand: one miss is ready to repair.

What the eye sees first: "1 miss to fix" badge, active card, Practice CTA.

Assessment: better than empty state. The issue is that the miss card is text-heavy and does not show the table clue visually. It could be far more valuable if it exposed a miniature table signal or hand context.

Fix class: component evolution.

### 15. Profile / You

What the user should understand: proof profile, route proof, streak, tasks, skills.

What the eye sees first: Proof profile hero.

Assessment: commercially promising idea, but currently too abstract. "Sharky keeps proof, not points" is good positioning; the proof shown underneath is still generic app-progress inventory. Needs stronger earned moments and fewer flat stat boxes.

Fix class: proof/value component evolution.

### 16. Day-2 Return Home / Repair Priority

What the user should understand: repair one weak spot before continuing.

What the eye sees first: "Repair one weak spot" card and Practice this spot CTA.

Assessment: one of the best UX flows in the pack. The problem is again CTA dominance and weak emotional return. Day-2 should feel like Sharky remembered something concrete; current screen says it, but does not dramatize it.

Fix class: bounded polish plus Sharky component evolution.

### 17. W11 Transfer

What the user should understand: use one prepared live cue.

What the eye sees first: table plus bottom question.

Assessment: late-route concept is visible, but W11 does not feel meaningfully more advanced or premium than W1. The table label "Repeated blind overfold cue" is tiny for the sophistication of the moment.

Fix class: table and late-route payoff evolution.

### 18. W12 Payoff / Mindset Bridge

What the user should understand: process, reset, discipline before review.

What the eye sees first: table, then bottom multiple-choice card.

Assessment: conceptually mature but visually flat. A W12 bridge should feel like a milestone in a premium trainer. Here it looks like another table question with slightly different copy.

Fix class: payoff and motion evolution.

### 19. W12 Terminal / No-W13

What the user should understand: Volume I complete; review continues; W13 is not opening.

What the eye sees first: table plus terminal question.

Assessment: clear enough, but not earned enough. "Volume I review is complete" is critical route truth, yet it appears in a small table label and normal bottom panel. The terminal state needs ceremony without implying public mastery.

Fix class: payoff component evolution.

## Table / Gameplay Deep Audit

The table is the heart of the product and the current biggest 10/10 blocker.

Strengths:

- Felt color and rail are on-brand and materially better than a generic trainer.
- Seats are readable enough on compact phone.
- Hero/BTN treatment exists and is not lost.
- Cards are legible in the inspected compact screenshots.
- Pot labels and street labels exist across W1-W12 route examples.
- The table consistently renders source-owned context rather than empty placeholders.

Problems:

- Table size is large, but not always efficient. The first decision and several late-route screens spend too much area on empty felt while the actual learning prompt is below the fold or compressed at the bottom.
- The board container is too visually heavy for the actual amount of information inside it. It frames small labels, cards, and pot text in a dark rounded island that competes with the felt.
- Pot labels are visible but too low-prominence for a poker trainer. They read as status chips, not table economics.
- "No bet yet" is a useful clue, but its tiny pill treatment makes it feel like UI metadata instead of the main table signal.
- Street labels like FLOP and REVIEW are present but small and oddly placed inside the same board cluster as the status label.
- Blind chips and seat labels create many small objects with similar visual weight. The eye has to parse too many pills.
- Hero/BTN is clear after inspection, but for first-use teaching it needs stronger directed attention.
- Action controls in multiple-choice screens are clear, but ordinary action rows and feedback CTAs often visually outweigh the table signal.
- Hint/coaching affordance is small and not emotionally integrated with Sharky.
- The progress bar at the top is functional but generic; it does not contribute to the table-read moment.
- Table and feedback are stacked, not fused. The top says "see the table"; the bottom says "read this explanation"; there is little connective tissue between them.

Table redesign call: not a full table redesign before Human QA. The component needs a **signal-layer evolution**:

- one canonical active clue layer;
- stronger hero/action target focus;
- board/status/pot hierarchy cleanup;
- visual bridge from table clue to feedback explanation;
- state-specific table accents for miss, repair, proof, and terminal.

## Feedback / Repair / Proof Loop Audit

The loop is structurally strong: Miss -> Repair -> Proof is visible in Review, Practice, feedback, and Session Summary. The issue is expression.

Wrong feedback is supportive but too quiet. It needs a more active repair frame: "Here is the signal you missed" should visually point back to the exact table object. Current wrong feedback mostly says the better option and why.

Repair focus is clear but not focused enough visually. It repeats the table and card pattern; it does not shrink the world around the one clue.

Correct feedback has useful proof language, but proof is split between a small table badge, explanation card, and CTA. The proof should feel earned without becoming gamified.

Session Summary says proof was banked, but the evidence chain is too textual. A 10/10 version would show what got banked, where it came from, and what it unlocks next in one glance.

## Sharky Companion Audit

Current Sharky is not top-1 caliber yet. The mascot functions as an app icon, badge, or small emotional stamp. It does not yet feel like a premium product companion that guides the user through states.

Observed issues:

- Badge-style Sharky is too weak on Home, Review, Profile, and feedback cards.
- Full-body Sharky in Session Summary and feedback is cute but not yet premium or clearly stateful.
- Emotional expression does not carry enough difference between correct, wrong, repair, proof, and terminal.
- Sharky placement often feels appended to cards rather than owning a companion slot.
- Current art does not create strong commercial memorability.
- Static screenshots cannot prove micro-animation, but the design visibly needs it: reactions, attention cues, proof banking, and repair encouragement are currently text-led.

Required direction: designer/illustrator production is required for 10/10. Codex can implement the slots and deterministic state plumbing, but the art quality and expression system need design production.

## Visual System Audit

The visual system is coherent and mostly disciplined. It also has a sameness problem.

Typography: readable overall, but small uppercase labels, pill text, and table labels often carry important meaning. H1s and CTAs are strong; mid-level instructional text sometimes becomes dense.

Spacing: generous on cards, sometimes wasteful on compact. The table uses large vertical real estate; bottom panels can crowd or clip.

Color semantics: teal/cyan/blue/gold are consistent. Cyan CTA is overused as the strongest object on too many screens. Gold is correctly reserved, but payoff gold still feels like a tinted card rather than a ceremony.

Cards/glows/borders: repeated heavily. Almost every concept is a rounded panel, pill, or nested card. This helps consistency but reduces moment distinctiveness.

Iconography: serviceable, not distinctive. Many icons are generic and small.

Background depth: premium enough for internal QA; not enough for top commercial screenshots.

Screen distinctiveness: Home/Learn/Review/Practice/Profile share too much card rhythm; table screens share too much identical composition across correct, wrong, repair, transfer, payoff, terminal.

## UX Mechanics Audit

The next action is usually obvious within one second because CTAs are huge. That is good for novice flow, but it also hides hierarchy mistakes. "Obvious CTA" is not the same as "obvious learning value."

Common UX issues:

- CTAs are sometimes larger than the concept they advance.
- Several screens require reading multiple explanatory blocks to understand value.
- Bottom nav is clear, but it flattens product modes into ordinary app tabs.
- Review/Practice empty states explain their role but feel static.
- Late-route progression is semantically important but visually similar to early-route progression.
- Important content can sit close to bottom nav or below the first fold, especially Session Summary.
- There is little visible transition/reward between states in static evidence.

## Learning / Value Audit

Beginner clarity is strong at the copy level. The app repeatedly avoids claiming mastery and focuses on one table clue. The risk is that the value can feel small because the visual system under-dramatizes the actual learning mechanism.

Review feels valuable in theory, but the empty and active states need more concrete table context. Practice feels useful but generic. Session Summary tells the user they improved, but static evidence does not show enough proof chain. W11/W12 copy shows mature thinking, but the visual treatment does not escalate with route maturity.

The user can understand "I got a thing right." The user does not yet fully feel "I got better because I learned to see the table."

## Complete Backlog

Counts: **84 findings total. P0: 0. P1: 16. P2: 40. P3: 26. P4: 2.**

| ID | Severity | Area | Category | Current issue and 10/10 blocker | Evidence | 10/10 target and proposed fix | Fix type | Agent | Impact | Risk | Before Human QA |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| UX10-001 | P1 | Table system | table | Table and feedback read as stacked products, blocking a seamless learning instrument. | compact/visible/07_correct_feedback.png, 08_wrong_feedback.png | Add a table-to-feedback signal bridge that repeats the exact clue and visually anchors explanation to board/status. | component evolution | Codex | high | medium | yes |
| UX10-002 | P1 | First decision | UX | First decision asks "Which seat is the hero?" but answer options are not visible in the compact first viewport. | compact/visible/06_first_decision.png | Ensure first-use decision controls are visible or make the viewport clearly invite one deliberate scroll. | component evolution | Codex | high | medium | yes |
| UX10-003 | P1 | Table clue | visual hierarchy | "No bet yet" is the key clue but is styled as a small pill. | compact/visible/07_correct_feedback.png | Promote the active clue into a primary table signal with clear connection to answer. | component evolution | Codex | high | medium | yes |
| UX10-004 | P1 | Wrong feedback | learning | Wrong state says the better action but does not visually show the missed table signal strongly enough. | compact/visible/08_wrong_feedback.png | Highlight missed clue on table and explanation together. | component evolution | Codex | high | medium | yes |
| UX10-005 | P1 | Repair focus | learning | Repair repeats the same layout instead of narrowing attention to one clue. | compact/visible/09_repair_focus.png | Create repair mode that suppresses nonessential table noise and spotlights the repeated clue. | component evolution | Codex | high | medium | yes |
| UX10-006 | P1 | Sharky | Sharky | Sharky is badge-like and not a premium companion. | compact/visible/01_home.png, 11_session_summary.png | Define stronger companion slots and art states for orient, miss, repair, proof, milestone. | art-mascot production | designer-illustrator | high | medium | yes |
| UX10-007 | P1 | Feedback CTAs | visual hierarchy | Large cyan CTAs often overpower the learning content. | compact/visible/08_wrong_feedback.png, 09_repair_focus.png | Make CTA subordinate to clue/explanation on feedback surfaces while staying tappable. | bounded polish | Codex | high | low | yes |
| UX10-008 | P1 | Session Summary | payoff | "First read banked" is strong copy but feels like a receipt card, not an earned moment. | compact/visible/11_session_summary.png | Build a richer proof receipt with table clue, earned state, and next action in one hierarchy. | component evolution | Codex | high | medium | depends |
| UX10-009 | P1 | W12 terminal | payoff | Terminal route truth lacks ceremony and still looks like an ordinary question. | compact/full_scroll/19_w12_terminal_segment_01_table.png | Add terminal/review state ceremony without implying W13 or public mastery. | component evolution | Codex | high | medium | depends |
| UX10-010 | P1 | Motion | motion | Static design exposes missing transition/reaction language for proof, repair, and terminal. | all feedback/summary captures | Add motion evidence for proof banking, repair focus, Sharky response, and terminal handoff. | motion-interaction | Codex | high | medium | depends |
| UX10-011 | P1 | Table economics | table | Pot labels are readable but not important enough for poker decision training. | compact/visible/06_first_decision.png, 17_w11_transfer.png | Raise pot/price hierarchy when economics matter. | component evolution | Codex | high | medium | yes |
| UX10-012 | P1 | Late route | payoff | W11/W12 do not visually feel more advanced than W1. | compact/visible/17_w11_transfer.png, 18_w12_payoff.png | Add route-maturity visual progression without changing route semantics. | component evolution | Codex | high | medium | depends |
| UX10-013 | P1 | Review active | learning | Active repair card does not show the missed table clue visually. | compact/visible/14_review_active.png | Add mini table-clue preview or compact source signal inside active review card. | component evolution | Codex | high | medium | yes |
| UX10-014 | P1 | Practice | UX | Practice looks useful but generic; repair priority is not vivid enough. | compact/visible/12_practice_default.png | Put the current repair clue and why-it-matters above category inventory. | component evolution | Codex | high | medium | yes |
| UX10-015 | P1 | Commercial impression | brand | Screens are coherent but not yet screenshot-desirable enough for top-1 positioning. | contact_sheets/compact_visible_contact_sheet.png | Create 3-4 hero-grade moments: first table read, miss repair, proof banked, Volume I complete. | larger redesign | designer-illustrator | high | high | no |
| UX10-016 | P1 | Touch feel | interaction | Static evidence cannot prove tap comfort, but cramped bottom panels suggest risk in first decision and feedback. | compact/visible/06_first_decision.png, 07_correct_feedback.png | Run device touch QA after layout changes; preserve target sizes and avoid bottom-nav collision. | Human QA validation | Human QA | high | low | yes |
| UX10-017 | P2 | Home | visual hierarchy | Continue is the dominant visual object, above the lesson concept. | compact/visible/01_home.png | Balance hero card so "table read" and lesson title beat CTA. | bounded polish | Codex | medium | low | yes |
| UX10-018 | P2 | Home | Sharky | Home Sharky avatar is too small for the product's identity moment. | compact/visible/01_home.png | Give Sharky a compact greeting/coach slot or stronger identity treatment. | art-mascot production | designer-illustrator | medium | medium | yes |
| UX10-019 | P2 | Home | copy | "Today's sequence" includes several labels and muted rows that require parsing. | compact/visible/01_home.png | Make sequence read as one current path with one next move. | content-copy | Codex | medium | low | yes |
| UX10-020 | P2 | Home | accessibility | Review row text appears clipped/truncated in compact viewport. | compact/visible/01_home.png | Ensure row copy truncates intentionally or wraps cleanly. | bounded polish | Codex | medium | low | yes |
| UX10-021 | P2 | Learn | visual hierarchy | Too many progress concepts appear at once. | compact/visible/02_learn.png | Reduce visible progress layers to current world, current lesson, next path. | bounded polish | Codex | medium | low | yes |
| UX10-022 | P2 | Learn | spacing | Foundation map chips crowd the screen before journey preview. | compact/visible/02_learn.png | Compact the map or move it behind "View path." | bounded polish | Codex | medium | low | no |
| UX10-023 | P2 | Learn detail | UX | Detail screen does not feel materially different from Learn. | compact/visible/03_learn_lesson_detail.png | Make detail view more path-specific or collapse duplicate hero content. | component evolution | Codex | medium | medium | no |
| UX10-024 | P2 | Learn detail | visual hierarchy | Journey preview nested list competes with lesson start. | compact/visible/03_learn_lesson_detail.png | Make preview a clear vertical route with lighter row chrome. | bounded polish | Codex | medium | low | no |
| UX10-025 | P2 | Placement | spacing | Large dead area separates content from sticky CTA. | compact/visible/04_placement.png | Pull CTA context closer or add useful trust/progress element in the gap. | bounded polish | Codex | medium | low | yes |
| UX10-026 | P2 | Placement | copy | "Quick start", "Fast start", "no exam", and "two answers" repeat similar reassurance. | compact/visible/04_placement.png | Remove one redundant reassurance layer. | content-copy | Codex | medium | low | yes |
| UX10-027 | P2 | Placement | interaction | Stepper choices are small relative to surrounding cards. | compact/visible/04_placement.png | Increase stepper clarity or make it a true progress affordance. | bounded polish | Codex | medium | low | yes |
| UX10-028 | P2 | Welcome | spacing | Hard seam between table and teaching panel breaks immersion. | compact/visible/05_welcome.png | Integrate panel with table edge or use a transitional coach overlay. | component evolution | Codex | medium | medium | yes |
| UX10-029 | P2 | Welcome | Sharky | Sharky is missing from the table-read moment. | compact/visible/05_welcome.png | Place Sharky as a quiet guide near the first clue or handoff. | art-mascot production | designer-illustrator | medium | medium | yes |
| UX10-030 | P2 | Table | visual hierarchy | Board container is visually heavy relative to cards and signal text. | compact/visible/07_correct_feedback.png | Reduce board island chrome or create stronger inner hierarchy. | component evolution | Codex | medium | medium | yes |
| UX10-031 | P2 | Table | typography | Street/status labels are small and compete with each other. | compact/visible/08_wrong_feedback.png | Define street/status typography scale and priority. | bounded polish | Codex | medium | low | yes |
| UX10-032 | P2 | Table | spacing | Empty felt dominates first decision and some late-route screens. | compact/visible/06_first_decision.png, 19_w12_terminal.png | Use empty felt for guided focus or reduce vertical table height in prompt-heavy steps. | component evolution | Codex | medium | medium | yes |
| UX10-033 | P2 | Table | visual hierarchy | Dealer button is visible but peripheral for a BTN-hero teaching moment. | compact/visible/06_first_decision.png | Strengthen dealer/BTN relation during seat-location lessons. | bounded polish | Codex | medium | low | yes |
| UX10-034 | P2 | Table | accessibility | Small pill labels may be hard to read on physical compact devices. | compact visible table screens | Audit minimum label size and contrast on device. | Human QA validation | Human QA | medium | low | yes |
| UX10-035 | P2 | Correct feedback | payoff | Proof badge on table is small and disconnected from bottom proof card. | compact/visible/07_correct_feedback.png | Make proof badge and proof card share one visual token/line. | component evolution | Codex | medium | medium | yes |
| UX10-036 | P2 | Correct feedback | copy | "Proof confirmed", "Best play", "Repair proof", "Table read improved" create many proof labels. | compact/visible/07_correct_feedback.png | Collapse proof hierarchy to one top label and one evidence line. | content-copy | Codex | medium | low | yes |
| UX10-037 | P2 | Wrong feedback | brand | Greyed wrong panel looks less premium than correct/repair states. | compact/visible/08_wrong_feedback.png | Use supportive repair styling, not disabled-looking grey. | bounded polish | Codex | medium | low | yes |
| UX10-038 | P2 | Wrong feedback | Sharky | Wrong Sharky is too muted and not emotionally useful. | compact/visible/08_wrong_feedback.png | Add supportive miss expression and state slot. | art-mascot production | designer-illustrator | medium | medium | yes |
| UX10-039 | P2 | Repair focus | copy | Repair focus explanation is small in a tinted box below stronger CTA/answer text. | compact/visible/09_repair_focus.png | Move repair question into primary focus position. | component evolution | Codex | medium | medium | yes |
| UX10-040 | P2 | Targeted recheck | motion | Recheck-to-result change lacks visible transition in static evidence. | compact/visible/10_targeted_recheck.png | Add proof landing motion and capture evidence. | motion-interaction | Codex | medium | medium | depends |
| UX10-041 | P2 | Session Summary | spacing | Bottom nav clips/obscures lower summary content in visible capture. | compact/visible/11_session_summary.png | Add bottom inset and ensure primary summary content rests above nav. | bounded polish | Codex | medium | low | yes |
| UX10-042 | P2 | Session Summary | Sharky | Sharky in proof card looks small and awkward relative to hero typography. | compact/visible/11_session_summary.png | Replace with stronger proof/milestone companion pose. | art-mascot production | designer-illustrator | high | medium | depends |
| UX10-043 | P2 | Session Summary | UX | "Practice this next" is text link inside a dense card, not a clear next action. | compact/visible/11_session_summary.png | Promote next action while preserving proof as the hero. | bounded polish | Codex | medium | low | yes |
| UX10-044 | P2 | Practice | visual hierarchy | Locked category grid draws attention away from today's rep. | compact/visible/12_practice_default.png | De-emphasize locked inventory until the daily set is complete. | bounded polish | Codex | medium | low | no |
| UX10-045 | P2 | Practice | copy | "No full lesson" and "Table reads" pills feel like feature tags, not value. | compact/visible/12_practice_default.png | Rewrite chips as user benefits or remove. | content-copy | Codex | medium | low | no |
| UX10-046 | P2 | Review empty | UX | Empty Review reads like an in-app explainer page. | compact/visible/13_review_empty.png | Shorten to one promise, one example, one CTA. | content-copy | Codex | medium | low | yes |
| UX10-047 | P2 | Review empty | Sharky | Sharky bubble is present but not expressive enough to make empty state memorable. | compact/visible/13_review_empty.png | Use a "ready to catch misses" companion pose. | art-mascot production | designer-illustrator | medium | medium | no |
| UX10-048 | P2 | Review active | visual hierarchy | "1 miss to fix" badge is useful but small for the screen's purpose. | compact/visible/14_review_active.png | Make active miss count and clue card the page hero. | bounded polish | Codex | medium | low | yes |
| UX10-049 | P2 | Profile | brand | Proof profile concept is excellent, but visible proof is too generic. | compact/visible/15_profile.png | Replace generic stat emphasis with concrete earned reads and route moments. | component evolution | Codex | high | medium | no |
| UX10-050 | P2 | Profile | visual hierarchy | Four stat boxes plus streak plus current focus create dashboard clutter. | compact/visible/15_profile.png | Prioritize route proof and earned moments over inventory stats. | component evolution | Codex | medium | medium | no |
| UX10-051 | P2 | Day-2 Home | payoff | Return moment says Sharky remembers, but visual treatment is identical to normal Home. | compact/visible/16_day2_return_home.png | Add return-state emphasis and remembered-clue cue. | component evolution | Codex | high | medium | yes |
| UX10-052 | P2 | W11 | visual hierarchy | "Repeated blind overfold cue" is too small for an advanced transfer cue. | compact/visible/17_w11_transfer.png | Promote advanced cue label and connect it to choice. | component evolution | Codex | medium | medium | no |
| UX10-053 | P2 | W11 | payoff | W11 transfer lacks milestone/advancement feel. | compact/visible/17_w11_transfer.png | Add subtle late-route maturity treatment without new route semantics. | bounded polish | Codex | medium | low | no |
| UX10-054 | P2 | W12 | payoff | W12 bridge looks like another question rather than a mindset bridge. | compact/visible/18_w12_payoff.png | Add bridge-specific state treatment and Sharky coaching. | component evolution | Codex | medium | medium | no |
| UX10-055 | P2 | W12 terminal | UX | Terminal "no-W13" truth is clear in answers but not emotionally resolved. | compact/full_scroll/19_w12_terminal_segment_01_table.png | Add a clear review handoff state after answer, not only question copy. | component evolution | Codex | medium | medium | no |
| UX10-056 | P2 | Tablet smoke | spacing | Tablet uses phone-like centered content and leaves large unused canvas. | tablet contact sheets | Accept for smoke, but document as not investor-grade tablet. | future/preference | designer-illustrator | low | high | no |
| UX10-057 | P3 | Global | typography | Letter-spaced small labels appear often and slow scanning. | compact visible contact sheet | Reduce tracking on critical labels or reserve it for metadata. | bounded polish | Codex | medium | low | no |
| UX10-058 | P3 | Global | visual hierarchy | Too many rounded cards within rounded cards. | all non-table screens | Remove one nesting layer where container meaning is redundant. | bounded polish | Codex | medium | low | no |
| UX10-059 | P3 | Global | brand | Cyan/teal dominance makes screens feel samey. | compact visible contact sheet | Add controlled semantic accents for repair/proof/milestone. | component evolution | designer-illustrator | medium | medium | no |
| UX10-060 | P3 | Global | iconography | Icons are serviceable but generic. | Home/Learn/Practice/Profile | Create a small proprietary icon set for proof, repair, clue, route. | art-mascot production | designer-illustrator | medium | medium | no |
| UX10-061 | P3 | Bottom nav | UX | Bottom nav is clear but makes modes feel ordinary. | compact visible contact sheet | Add subtle state-specific nav badges only when meaningful. | bounded polish | Codex | low | low | no |
| UX10-062 | P3 | Header | UX | "Today 0/3" and "3d" repeat across screens without always adding value. | Home/Learn/Profile/Review | Hide or contextualize daily header on deep lesson/table states. | bounded polish | Codex | medium | medium | no |
| UX10-063 | P3 | Home | interaction | Ellipsis menu appears but no visible purpose in static evidence. | compact/visible/01_home.png | Remove or explain through menu affordance only if useful. | bounded polish | Codex | low | low | no |
| UX10-064 | P3 | Learn | copy | "Current world - W1" plus "Poker from Zero" plus percentage repeats identity/progress. | compact/visible/02_learn.png | Compress world header. | content-copy | Codex | low | low | no |
| UX10-065 | P3 | Placement | visual hierarchy | Question icon dominates Quick start card but does not communicate poker value. | compact/visible/04_placement.png | Replace with Sharky/hand/table cue. | art-mascot production | designer-illustrator | medium | low | no |
| UX10-066 | P3 | Table | table | Opponent card backs are visually large compared with active clue labels. | compact/visible/07_correct_feedback.png | Tune card-back opacity/size for novice-focus states. | bounded polish | Codex | low | low | no |
| UX10-067 | P3 | Table | spacing | Seat labels overlap the table rail visually. | compact table captures | Pull labels inward or make rail/label relationship cleaner. | bounded polish | Codex | low | low | no |
| UX10-068 | P3 | Table | brand | Felt is good but lacks tactile premium detail in screenshot. | compact table captures | Add subtle felt texture/depth if performance-safe. | larger redesign | designer-illustrator | medium | medium | no |
| UX10-069 | P3 | Feedback | copy | "Sharp read", "calm retry", "repair coach" tones vary but are small. | feedback captures | Create stronger state language hierarchy. | content-copy | Codex | low | low | no |
| UX10-070 | P3 | Feedback | accessibility | Panel text density may strain compact readers. | compact/visible/07_correct_feedback.png | Increase line-height/spacing in explanatory body. | bounded polish | Codex | medium | low | no |
| UX10-071 | P3 | Feedback | interaction | Book/hint icon in question panels is small and detached. | table question captures | Make help affordance clearly tappable and Sharky-owned. | component evolution | Codex | medium | medium | no |
| UX10-072 | P3 | Repair | visual hierarchy | "Repair focus" label is gold but buried in the panel. | compact/visible/09_repair_focus.png | Move repair identity to panel header with clue anchor. | bounded polish | Codex | medium | low | no |
| UX10-073 | P3 | Session Summary | typography | Hero title is very large, leaving less room for proof context. | compact/visible/11_session_summary.png | Slightly reduce hero or pair with visible concrete proof chip. | bounded polish | Codex | low | low | no |
| UX10-074 | P3 | Session Summary | copy | "Replay this block before moving on" appears in multiple places. | compact/visible/11_session_summary.png | Keep one next-step line and one CTA. | content-copy | Codex | low | low | no |
| UX10-075 | P3 | Practice | payoff | Short reps section is below the fold and visually secondary. | compact/visible/12_practice_default.png | Bring the actual rep choices closer to top after hero. | bounded polish | Codex | medium | low | no |
| UX10-076 | P3 | Review | copy | "Nothing else is due" line competes with bottom nav. | compact/visible/13_review_empty.png | Make completion status quieter or integrate inside empty card. | bounded polish | Codex | low | low | no |
| UX10-077 | P3 | Review active | spacing | "How Review Works" appears after active repair and may distract. | compact/visible/14_review_active.png | Hide explainer when there is an active miss. | bounded polish | Codex | medium | low | yes |
| UX10-078 | P3 | Profile | interaction | "View week" button has large footprint but unclear immediate value. | compact/visible/15_profile.png | Clarify value or demote. | content-copy | Codex | low | low | no |
| UX10-079 | P3 | Profile | payoff | Earned moments start below visible fold. | compact/visible/15_profile.png | Move first earned moment higher or summarize it in hero. | bounded polish | Codex | medium | low | no |
| UX10-080 | P3 | Day-2 Home | brand | Return priority lacks special Sharky remembrance treatment. | compact/visible/16_day2_return_home.png | Add "I saved this clue" companion state. | art-mascot production | designer-illustrator | medium | medium | yes |
| UX10-081 | P3 | W11/W12 | typography | Advanced route questions use long lines in bottom cards. | compact W11/W12 table segments | Tighten line length and emphasize exact decision phrase. | content-copy | Codex | medium | low | no |
| UX10-082 | P3 | W12 terminal | visual hierarchy | Correct answer "Start keep-sharp review" is just another option row. | compact/full_scroll/19_w12_terminal_segment_01_table.png | Give intended terminal action a clearer guided affordance after answer. | component evolution | Codex | medium | medium | no |
| UX10-083 | P4 | Global | motion | Static packet cannot judge animation quality. | all static screenshots | Human QA or video capture should validate motion/touch. | Human QA validation | Human QA | medium | low | no |
| UX10-084 | P4 | Tablet | UX | Tablet-native premium redesign is out of scope for this pack. | tablet contact sheets | Keep as smoke-only until commercial tablet goal exists. | future/preference | designer-illustrator | low | high | no |

## Redesign Decision

Chosen decision: **2. Current system can reach 8.5-9, but needs visual direction evolution for 10.**

Evidence:

- The current UI is coherent and not broken across compact phone coverage.
- The core route and learning loop are visually present across Home, Learn, table, feedback, Review, Practice, Profile, and W11/W12.
- No P0 visual failure appears in the static packet.
- The blockers are system-expression blockers, not fundamental navigation collapse.
- The table, feedback, and Sharky companion need component evolution together. If those stay as-is, the system likely caps around 8.0-8.3 visually even with polish.

Human QA does not require a full redesign first. Max-quality Human QA should wait for the P1 table/feedback/CTA/Sharky issues that would otherwise generate predictable tester feedback.

## Wave Plan To 10/10

### Wave A - Must Do Before Human QA For Max Quality

Goal: remove obvious static UX issues that would waste tester attention.

Included backlog IDs: UX10-001, UX10-002, UX10-003, UX10-004, UX10-005, UX10-007, UX10-011, UX10-013, UX10-014, UX10-016, UX10-017, UX10-020, UX10-025, UX10-026, UX10-027, UX10-028, UX10-030, UX10-031, UX10-034, UX10-037, UX10-039, UX10-041, UX10-043, UX10-046, UX10-048, UX10-051, UX10-077.

Screens/components touched: table signal layer, first decision viewport, feedback panels, repair focus, active Review card, Practice priority card, Home hero, Placement CTA gap, Session Summary safe area.

What not to touch: route semantics, answer correctness, W13+, telemetry, content-engine architecture, monetization.

Best implementation agent: Codex.

Expected score lift: 7.8 -> 8.4.

DoD: refreshed compact real-text screenshots, no output staged, focused visual guards if available, `graphify hook-check`, docs artifact updated.

Validation/evidence required: compact visible and full-scroll screenshots for the 19 screens, plus before/after contact sheet review.

### Wave B - Should Do Before External / Investor Showing

Goal: create a few screenshot-grade moments instead of only coherent app screens.

Included backlog IDs: UX10-008, UX10-009, UX10-012, UX10-015, UX10-035, UX10-036, UX10-042, UX10-049, UX10-050, UX10-052, UX10-053, UX10-054, UX10-055, UX10-079, UX10-082.

Screens/components touched: Session Summary, W11, W12 payoff, W12 terminal, Profile proof, correct feedback.

What not to touch: Human QA evidence claims, premium commerce, W13 unlocks.

Best implementation agent: Codex for implementation, designer/illustrator for visual direction.

Expected score lift: 8.4 -> 8.8.

DoD: at least four hero-grade screenshots: first table read, missed clue repair, proof banked, Volume I complete.

Validation/evidence required: compact contact sheet plus individual hero screenshot inspection.

### Wave C - Table / Gameplay System Evolution

Goal: make table clues, actor, pot, street, and answer form one visible learning signal.

Included backlog IDs: UX10-001, UX10-003, UX10-011, UX10-030, UX10-031, UX10-032, UX10-033, UX10-034, UX10-066, UX10-067, UX10-068.

Screens/components touched: Act0 table component, board/status area, pot/price label, hero/BTN treatment, clue highlight layer.

What not to touch: poker correctness, source contract, route IDs.

Best implementation agent: Codex with design input.

Expected score lift: 8.0 table -> 8.8 table.

DoD: novice can identify the active clue in 1 second from screenshot alone.

Validation/evidence required: W1 first decision, correct/wrong/repair, W11, W12 terminal compact screenshots.

### Wave D - Sharky Art / Companion System

Goal: make Sharky a memorable product companion, not a badge.

Included backlog IDs: UX10-006, UX10-018, UX10-029, UX10-038, UX10-042, UX10-047, UX10-065, UX10-080.

Screens/components touched: Home, Welcome, feedback, Review, Session Summary, Profile.

What not to touch: phrase truth, proof claims, random personality logic.

Best implementation agent: designer/illustrator first, Codex second.

Expected score lift: 6.4 Sharky -> 8.2 Sharky.

DoD: stateful Sharky set for neutral, coach, miss, repair, proof, milestone, terminal; same-character continuity at small/medium/large sizes.

Validation/evidence required: visual board, compact screenshot replacements, reduced-motion/motion notes where applicable.

### Wave E - Feedback / Repair / Proof System Evolution

Goal: make Miss -> Repair -> Proof emotionally and visually distinct.

Included backlog IDs: UX10-004, UX10-005, UX10-007, UX10-035, UX10-036, UX10-037, UX10-039, UX10-040, UX10-069, UX10-070, UX10-071, UX10-072.

Screens/components touched: wrong feedback, repair focus, targeted recheck, correct feedback.

What not to touch: answer correctness or repaired content.

Best implementation agent: Codex.

Expected score lift: 8.0 loop -> 8.7 loop.

DoD: each state has a distinct first glance: missed signal, repair focus, proof earned.

Validation/evidence required: same scenario captured in wrong, repair, recheck, correct states.

### Wave F - Journey / Payoff / Ceremony Evolution

Goal: make progress feel earned without claiming mastery.

Included backlog IDs: UX10-008, UX10-009, UX10-012, UX10-041, UX10-043, UX10-049, UX10-050, UX10-052, UX10-053, UX10-054, UX10-055, UX10-073, UX10-074, UX10-078, UX10-079, UX10-081, UX10-082.

Screens/components touched: Session Summary, Profile, W11, W12 payoff, W12 terminal.

What not to touch: public readiness, durable learning claims, W13+.

Best implementation agent: Codex with design review.

Expected score lift: 7.3 commercial -> 8.5 commercial.

DoD: proof is concrete, route maturity is visible, terminal handoff is clear.

Validation/evidence required: compact full-scroll captures for Session Summary/Profile/W11/W12.

### Wave G - Motion / Touch Refinement

Goal: prove the static states feel responsive and premium in hand.

Included backlog IDs: UX10-010, UX10-016, UX10-040, UX10-083.

Screens/components touched: proof banking, repair focus, Sharky response, table clue highlight, terminal handoff.

What not to touch: new game logic or new telemetry.

Best implementation agent: Codex for motion implementation, Human QA for feel.

Expected score lift: unknown from static evidence; likely high perceived-premium lift.

DoD: video or deterministic motion evidence, reduced-motion behavior, no CTA obstruction.

Validation/evidence required: motion capture and device QA.

### Wave H - Post-Human-QA Improvements

Goal: address findings that need real users or external commercial goals.

Included backlog IDs: UX10-023, UX10-024, UX10-044, UX10-045, UX10-056, UX10-057, UX10-058, UX10-059, UX10-060, UX10-061, UX10-062, UX10-063, UX10-064, UX10-075, UX10-076, UX10-084.

Screens/components touched: Learn detail, Practice inventory, global card grammar, iconography, tablet layout.

What not to touch: validated Human QA flows unless evidence demands it.

Best implementation agent: Codex plus designer/illustrator for visual identity.

Expected score lift: 8.8 -> 9.0+ depending on art/motion.

DoD: tester-backed prioritization and refreshed visual baseline.

Validation/evidence required: Human QA notes plus screenshot/video deltas.

## What Not To Change Now

- Do not change route semantics.
- Do not change answer correctness.
- Do not open W13+.
- Do not add or change telemetry.
- Do not change content-engine architecture.
- Do not activate monetization, paywall, pricing, trial, or entitlement work.
- Do not stage screenshots or output evidence.
- Do not replace the whole app shell.
- Do not redesign tablet as a premium surface yet; keep tablet as smoke unless a commercial tablet goal is opened.
- Do not reopen frozen surfaces without evidence tied to this visual pack.
- Do not claim Human QA readiness, public readiness, launch readiness, durable learning, beginner mastery, or 10/10 proof from this packet.

## Human QA Decision

Should we refresh Human QA baseline now: **not if the owner wants max-quality Human QA signal.**

Should visual/UX work continue before Human QA: **yes, at least Wave A.**

What Human QA uniquely answers:

- whether users understand the table clue without coaching;
- whether touch targets feel comfortable on device;
- whether repair feels supportive or repetitive;
- whether Sharky helps or distracts emotionally;
- whether users feel the proof loop after a session;
- whether motion and transitions feel premium or slow;
- whether the route language creates trust or confusion.

What should be fixed before Human QA to avoid wasting tester feedback:

- first decision answer visibility / scroll clarity;
- table clue salience;
- wrong/repair/correct state distinction;
- active Review repair clue visibility;
- Practice repair priority;
- CTA dominance on feedback;
- Session Summary bottom inset and next-step hierarchy;
- baseline Sharky state/slot improvements if art is available.

## Final Recommendation

Score now: **7.8 / 10** from static visual evidence.

Core blockers to 10/10: table signal salience, table-feedback integration, Sharky companion quality, payoff ceremony, visual sameness, and unproven motion/touch feel.

Redesign needed: **no full redesign before Human QA.** Required path is bounded polish plus component evolution. A larger visual direction evolution is required for true 10/10 and investor-grade commercial impression.

Exact next 3 implementation waves:

1. **Wave A1 - Table signal and first-decision actionability.** Codex. Fix UX10-001, UX10-002, UX10-003, UX10-011, UX10-030, UX10-031, UX10-032, UX10-033.
2. **Wave A2 - Feedback / repair / CTA hierarchy.** Codex. Fix UX10-004, UX10-005, UX10-007, UX10-013, UX10-014, UX10-035, UX10-037, UX10-039, UX10-041, UX10-043.
3. **Wave D0 - Sharky companion art-direction production brief.** Designer/illustrator first, Codex second. Fix UX10-006, UX10-018, UX10-029, UX10-038, UX10-042, UX10-047, UX10-080.

Designer/illustrator required: **yes** for 10/10; Codex can do structure, state slots, layout, and evidence capture, but cannot make current Sharky art premium by code alone.

Human QA should wait: **yes, if the goal is max-quality Human QA.** If the goal is only to test comprehension before polish, Human QA can proceed, but tester feedback will predictably spend time on visible issues already listed here.
