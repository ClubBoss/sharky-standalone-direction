---
status: "undeclared"
status_source: "absent"
generated_by: "docs_frontmatter_v1"
---

# Sharky Poker — Full UI/UX/Visual 10/10 Deconstruction (v1)

**Objective:** Full deconstruction of the current build against a 10/10 bar — visual, UX, table/gameplay, feedback loop, Sharky companion, onboarding, navigation, cognitive load, typography, spacing, touch ergonomics, motion gaps, emotional payoff, premium impression, beginner trust, commercial impression. Not a Human QA substitute; not a launch-readiness claim.

**Evidence pack:** `real_text_visual_pack_v5` — 19 screens/states, compact phone portrait (primary) + tablet (smoke only), visible + full-scroll captures, 4 contact sheets, `manifest.json`, `coverage.md`. Git commit `485e773`. All captures verified real-text, real-UI. Every screen and every full-scroll segment in the compact set was inspected directly; tablet evidence was inspected via contact sheets for clipping/overflow/CTA-access/broken-layout smoke only, per scope.

**Disallowed claims honored:** this review makes no claim of Human QA approval, public/launch readiness, 9.0/10.0 proof, durable learning effect, beginner mastery, or premium commercial readiness. Screenshots cannot prove motion or touch feel — where that matters, it is flagged as an open question for Human QA/engineering, not scored.

---

## 1. Product-level diagnosis

**Does this feel like a top-1 premium mobile poker trainer, or a competent app with polished cards?**
On this evidence: the latter. The system is coherent, internally consistent, and clearly engineered with real care in the copy and the learning-loop concept. But nothing in 19 screens produces a "this is the best-in-class poker trainer" reaction — no screen escalates, no moment surprises, and the same handful of container/card templates recur so often that the product reads as one well-organized component library wearing 19 different labels, not 19 distinct, considered moments.

**Scores (visual/UX evidence only, not proof of learning or launch readiness):**
- Overall: **6.0 / 10**
- UI: **6 / 10** — clean and systemized, but monotonous; weak label/pill hierarchy everywhere.
- UX: **6.5 / 10** — the flows are logical and the Miss→Repair→Proof loop is legible, but redundant stacked copy inflates reading load at nearly every step.
- Premium visual: **5 / 10** — one palette, no elevation system, no escalation across the journey.
- Table/gameplay: **5.5 / 10** — touch ergonomics on the action buttons are genuinely good; everything else on the felt is under-hierarchized and wastes space.
- Sharky companion: **4.5 / 10** — real but thin; too few poses, too small, no distinct iconographic language.
- Learning loop: **7 / 10** — the strongest subsystem in the product; the why-explanations are the closest thing to a 10/10 moment in the whole pack.
- Commercial/investor-showing: **5 / 10** — a credible MVP; nothing in a 30-second glance is ownable or distinctive enough to be a demo-day "wow."

**What exactly blocks 10/10:**
1. The table does not visually evolve at all between Week 1 and Week 12 (see §3, §10 Wave C) — the single biggest structural gap.
2. Sharky is under-produced as a companion — too few emotional states, always small, no signature visual language (§5).
3. Correct / Wrong / Repair states share one near-monochrome palette — no real color-semantic system (§4).
4. Chronic label/pill/copy stacking on the two screens that matter most (table, feedback) — competing micro-labels instead of one clear signal (§3, §4).
5. Four of five hub tabs (Home, Learn, Practice, You) reuse one hero-card template almost verbatim — the tab bar promises five distinct places; the visuals deliver one (§6).

**Does the system have a ceiling? Can it reach 9+ through bounded/component evolution?**
Most of the backlog (copy density, spacing, terminology, color semantics, per-tab differentiation) is bounded polish or component evolution and can plausibly get the product to **8.5–9**. Two areas sit above that ceiling without new production work: the table-escalation system (needs a designed richer-felt language for later weeks, not just a bug fix) and Sharky's art set (needs a real illustration/animation pass, not a code change). Those two are the difference between "8.5–9 achievable in-repo" and "true 10/10."

**Does any part require a larger redesign before Human QA?** No single screen is broken enough to demand a ground-up redesign before Human QA. The correct/wrong feedback color system and the table wasted-space/hierarchy problems are worth fixing before Human QA because they will otherwise generate tester feedback we can already predict (see §13).

---

## 2. Full journey UI/UX audit — screen-by-screen notes

Per-screen notes below feed the numbered backlog in §9; only qualitative summary is repeated here to avoid duplication.

1. **Home** — Legible, functional. Hero card ("Today's table read") pattern will be reused verbatim on 3 more tabs, undercutting distinctiveness. Bottom of "Today's sequence" list clips off-screen mid-sentence (bug). First-second read: clear "what to do next," reasonably good.
2. **Learn** — Structurally near-identical to Home. World progress card + current-lesson card + foundation map + journey preview is a lot of nested containers before any new information appears.
3. **Learn lesson detail** — Up to 4 levels of nested rounded-rect containers stacked (world > lesson > preview > accordion > step list). Good progressive disclosure concept, over-nested execution.
4. **Placement** — Reassuring, low-pressure copy ("Fast start, no exam"). ~40% of the screen between the third info card and the CTA is empty. Progress indicator style differs from the rest of onboarding.
5. **Welcome** — First table view (step 2/3) is an almost entirely empty felt — no board, no pot, no real information — the weakest possible first exposure to the core product surface. Handoff screen (3/3) is ~70% empty canvas around a small centered mascot glyph.
6. **First decision / first table read** — The real "first meaningful table" moment; well-populated, functional. Stack size ("100 BB") is the smallest, lowest-contrast text on the screen despite being decision-critical. The teaching question ("Which seat is the hero seat?") is answered by color before it's asked.
7. **Correct feedback** — Reads correctly but shares near-identical structure/palette with "wrong." "Repair proof" sub-system appears here before it has been introduced anywhere else in the flow.
8. **Wrong feedback** — No distinct color, icon, or Sharky pose separates this from "correct" at a glance; the visual system does not protect against misreading the moment.
9. **Repair focus** — Best-differentiated feedback state (amber accent) — but has the most stacked label rows of any screen (five).
10. **Targeted recheck / repair result** — A "you fixed your own mistake" moment, which should feel bigger than a first-try correct, is styled identically to one.
11. **Session summary** — Strong opening card (first real color escalation in the pack). Then three cards in a row restate the same "go replay" idea before the actual accuracy stat (the single most important number of the session) appears, small and un-emphasized, near the bottom of a 3-screen scroll.
12. **Practice default / repair state** — Single active hero card; the entire secondary practice grid (4 topics) is locked, and three separate cards on the same screen all explain the same gating concept.
13. **Review empty** — One of the cleanest screens in the pack: clear reassurance, clear 3-step legend, one CTA. Slightly information-dense for an empty state, and the 3-step legend duplicates Screen 14's legend nearly verbatim.
14. **Review active repair state** — Clear "1 miss to fix" badge. Same double-paragraph-before-CTA density problem as other feedback screens. About half the screen below the legend is empty.
15. **Profile / You** — Fourth reuse of the hero-card template. Four different content types (stats / achievements / skills / settings) rendered in identical card chrome for three screen-heights. No personalization (name/avatar) anywhere on the "You" tab. Streak visualization has no day labels.
16. **Day-2 return Home** — Structurally and visually identical to Home aside from two copy edits. The single highest-churn retention moment in a habit product gets zero distinct visual treatment.
17. **W11 transfer** — Table chrome is pixel-identical to Week-1 table chrome. Blind-chip token style has silently changed (see §3) from the earlier lessons with no visual bridge explaining the change.
18. **W12 payoff / mindset bridge** — Copy register shifts to abstract coaching language ("Process, reset, and discipline") right at the point comprehension should be most effortless. Table still identical to Week 1.
19. **W12 terminal / no-W13** — The single biggest narrative payoff in the 12-week arc ("Volume I complete") is delivered in the same small card component as any ordinary in-lesson correct answer. No escalation, no ceremony.

---

## 3. Table/gameplay deep audit

The table is evidence-confirmed to be the most repeated screen surface in the pack (appears, structurally unchanged, in screens 5–10 and 17–19 — 9 of 19 screens). It deserves the deepest scrutiny the brief asks for, and it is also where the most severe findings live.

- **Felt shape/size/margins:** tall stadium oval, nearly full width, occupying ~60% of viewport height. A wide band of felt between the seat pods and the center board module is empty on every single screenshot — roughly a third of the felt surface carries no information in any state observed.
- **Card size/readability:** hero hole cards and villain card-backs are rendered at the same size. This means the one hand that matters (hero's) does not visually dominate — five identical blue rectangles compete for the same attention budget as the two cards a beginner actually needs to read.
- **Board container:** a semi-transparent dark rounded rect, floating mid-felt, holding street label + community cards + pot pill. Its header zone (directly above the cards) has been observed rendering at least three different contents across the pack (No-bet-yet pill + street label, OR a "Proof banked" progress bar, OR a full-width contextual sentence) with no shared container design tying those states together.
- **Pot label prominence:** "Pot 3 BB" / "Pot 12 BB" is a small pill, visually subordinate to the card ranks above it and roughly equal in weight to the street label beside it — despite pot size being one of the most decision-relevant numbers on the felt.
- **Street label placement:** small-caps amber text sits on the same horizontal band as the "No bet yet" pill, splitting one line into two unrelated pieces of information.
- **"No bet yet" chip:** ambiguous the first time it's seen — reads like an internal state name rather than a polished in-product phrase — and it disappears entirely from the vocabulary by W11+, replaced with much longer prose banners, with no visual throughline connecting the two idioms.
- **Blind chips:** in early screens (5–10), blinds are a round gold-outlined coin icon labeled "1 BB"/"0.5 BB" that sits outside the seat pod. In late screens (17–19) the same concept is a plain gray text label ("1 BB") inside the seat pill, with no coin icon at all. Two different components for one concept, with no evolution shown in between.
- **Dealer button:** a small plain white circle with no bevel/shadow, overlapping the hero pod's corner — reads as a stray dot rather than a recognizable poker dealer button.
- **Seat labels:** correct standard position abbreviations (UTG/HJ/CO/BB/SB/BTN) — good for teaching positional literacy, but zero in-context glossary/tap-to-define affordance exists on the felt itself for a "Poker from Zero" beginner audience.
- **Hero/BTN treatment:** the hero pod does get a real, distinct blue/gold outline vs. the gray villain pods — a genuine hierarchy win — but the avatar circle inside is just a generic "Y" letter, identical in kind to villain placeholder icons, so there's no true "this is you" signature beyond the border color.
- **Action controls:** three large, well-sized (~64px), semantically color-coded pill buttons (Fold/Check/Call) — this is a real strength and should not be changed.
- **Hint/coaching affordance:** present once ("Need a hint?") on the very first placement-style decision screen and then absent from every subsequent decision screen observed — inconsistent availability across reps.
- **Progress bar:** a flat 2px line with a numeric fraction, no segment ticks — a different, better-designed segmented/gradient bar exists elsewhere in the app (Session Summary's top bar) that is never reused here.
- **Table ↔ feedback relationship:** the felt and the feedback panel below it sit in two visually disconnected blocks (hard edge, different background value, no shared framing) — table and coaching genuinely read as two stacked products, exactly the risk the brief names.
- **Does the table system need component evolution or full redesign?** Component evolution, not a full redesign — the underlying grid/seat/board logic is sound and reusable; what's missing is (a) a wasted-space/hierarchy pass, (b) a unified blind/chip token, (c) a designed escalation language so the felt looks different — richer, more "earned" — by Week 12 than it did on Day 1.

---

## 4. Feedback / repair / proof loop audit

**Strengths (do not change):** the underlying Miss → Repair → Proof concept is sound and one of the clearest explanatory pieces of UI in the pack (Review empty state's 3-row legend). The "why" explanations under each answer ("Nobody had bet yet — that was the clue...") are genuinely good teaching copy, not just "what," and this is the single strongest asset in the product.

**Gaps:**
- Correct and Wrong feedback panels are near carbon copies in layout, type weight, and color — both trend cool blue/white. There is no color-semantic system distinguishing a win from a miss from a repair (repair does at least get its own amber accent — the one deliberate exception).
- Both Correct and Repair-focus panels stack four to five separate label rows (eyebrow label → status label → "Best/Better option" label → headline word → sub-box) before the payoff lands. The payoff word itself ("Check") is reused as the giant headline on four different screens with four different surrounding meanings — from a glance, the screens are visually indistinguishable.
- The table clue that supposedly justifies the explanation (the "No bet yet" pill) and the explanation text below it are co-located on the same static screen but not visually connected — no line, arrow, highlight, or shared color ties the clue to its explanation.
- A "repaired" success (Targeted recheck result, screen 10) is styled identically to an ordinary first-try success (screen 7) — a moment that should feel like a bigger win (you fixed your own mistake) carries no extra visual weight.
- "Repair proof" as a sub-system is introduced on screen 7 (Correct feedback) before the user has been taught what "repair" means anywhere in the flow up to that point — a sequencing gap.

---

## 5. Sharky companion audit

Sharky is a real, recognizable character concept with likeable, simple art — but as evidenced across all 19 screens, he is under-produced relative to how central the copy makes him sound ("Sharky has one clue ready," "Sharky brings back the exact clue you missed").

- **Pose count:** three distinct poses observed across the whole pack — (1) a small flat neutral circular badge/avatar, used most often; (2) a "worried, chin-scratch" pose, used for both a wrong-answer moment and a session-summary congratulation — an emotional mismatch, since the same worried face congratulates and consoles; (3) a larger friendly open-smile pose used twice (Placement hero, Review empty).
- **Size:** Sharky never appears larger than roughly a 96×96px framed square anywhere in the pack. For a mascot the copy treats as a constant companion, his visual presence is consistently smaller and quieter than his narrative role.
- **Iconographic language:** Sharky's square, dark-framed badge treatment is visually similar enough to generic topic icons (graduation cap, lightning bolt, trophy) that at a glance he can read as "just another icon" rather than a distinct, always-recognizable character (no signature shape, no signature ring color, no consistent circular framing that would separate "this is a companion" from "this is a bullet-point icon").
- **Role per state:** correctly present at good moments (correct answer, session close, repair coaching) but the pose assigned to each moment doesn't reliably track the emotional register of that moment (see the worried-pose mismatch above).
- **Where full Sharky should appear:** Day-2 return (a retention-critical moment with zero mascot ceremony currently) and W12 terminal (the biggest payoff moment in the arc, currently a standard card with no larger Sharky presence).
- **Where Sharky should be quieted:** nowhere observed is he overused — if anything the opposite problem exists.
- **New art needed:** yes. A five-to-seven pose set (encourage, celebrate, console, coach, welcome-back, milestone-pride, neutral/idle) would close the gap between what the copy claims about Sharky and what the art currently delivers. This is a designer-illustrator task, not a code task.
- **Brand memorability:** on this evidence, thin. The character is pleasant but not yet distinctive or reused with enough visual consistency to be instantly recognizable outside the product.

---

## 6. Visual system audit

- **Typography hierarchy:** headline sizes/weights ("Fold, check, call, raise," "Check," "First read banked.") are strong and legible. Body/meta text frequently drops to an estimated ~13–14px gray-on-navy for badge chips, journey-preview subcopy, and profile stat labels — borderline small for a mobile product, and notably smaller than the brief's minimum-scale guidance would favor for anything decision-relevant.
- **Color:** the entire non-table UI is monochrome navy + one cyan CTA color, with amber/gold as the only deliberate accent (repair states, session-proof). Every hub tab (Home/Learn/Practice/You) uses the identical palette with no per-tab identity color — a contributing cause of tab sameness.
- **Spacing rhythm/card language:** one rounded-rect + 1px border + soft glow container is reused for essentially every content block in the app (hero cards, lesson cards, achievement cards, stat cards, tip cards, miss cards). Internally consistent, but it also erases any container hierarchy — a critical CTA card and a passive informational tip card carry identical visual weight.
- **Iconography:** mostly outline-style, but stroke weight is noticeably heavier in the bottom nav than inside cards — a minor but real inconsistency.
- **Background depth / shadows / material:** essentially flat. No elevation system is evidenced — cards do not appear to sit at distinguishable depths; everything reads as one layer, which reads as slightly less premium than a layered-elevation system would.
- **Screen-to-screen distinctiveness:** of the 19 screens, roughly 14 are visual reskins of just two templates (the hero-card hub template, and the table+feedback template). Only Placement, Session Summary's opening card, and the empty states carry genuinely distinct visual treatment.
- **Key-moment escalation:** Session Summary's opening card and the amber repair accent are the only two places in the entire pack where the visual system deliberately escalates for a bigger moment. Day-2 return and W12 terminal — arguably the two biggest emotional beats in the whole reviewed arc — do not escalate at all.

---

## 7. UX mechanics audit

- **Bottom nav** (Home/Learn/Practice/Review/You): clear, standard, good touch-target height. Keep as-is.
- **Navigation badging** is inconsistent: Review gets a live orange dot + counted pill ("1 miss to fix"); Practice's equally time-sensitive "0/3 daily spots" gets no nav badge at all.
- **CTA copy:** "Continue" is reused as the label for at least four structurally different actions (advance past a correct answer, advance past a repair result, advance past a milestone, advance past a terminal recap) — a missed opportunity for CTA copy to signal what's actually about to happen.
- **Practice tab gating:** all four secondary topic cards are locked on the evidenced screen, and three separate cards on the same screen explain the same gating concept in three slightly different ways — redundant explanation without added specificity (no "unlocks in 3 lessons" style detail).
- **Confirmation/transition moments:** none are evidenced between a "Continue" tap and the next screen appearing — this cannot be judged from static evidence and is flagged as an open motion question, not scored.
- **Review/Practice "feels empty" risk:** the Review empty state is handled well (clear reassurance + explanation). The Practice tab's fully-locked secondary grid is the screen most likely to read as sparse/demo-like to a new user.

---

## 8. Learning/value audit

- **Real strength:** the why-explanations under each poker decision are specific and correct-feeling ("Checking keeps the hand going when no bet faces you") — this is the backbone of any claim this product could someday make about teaching quality, and it should be protected, not diluted, in any redesign pass.
- **Terminology overload:** the word "proof" is used in at least eight distinct compound forms across the pack — "Proof banked," "Repair proof," "Proof confirmed," "Session proof," "Proof profile," "Collected proof," "Route proof," "Local proof saved" — each meaning something slightly different (a badge, a section title, a stat, a UI label). This is a real clarity risk for a concept the product is trying to make feel valuable and ownable.
- **Beginner clarity:** position jargon (UTG/HJ/CO/BTN) appears on the very first live table with no in-context safety net if a beginner hasn't retained it from the separate Learn tab.
- **Voice consistency:** early lessons use concrete, plain-spoken poker language ("fold, check, call, raise"). W11/W12 copy shifts into abstract coaching/self-help register ("Process, reset, and discipline," "Mindset Bridge") — a tonal jump late in the arc that may not read as the same product voice.
- **"I got better this session" feeling:** the actual accuracy stat (the evidence of improvement) is the least visually emphasized element of the Session Summary screen, buried near the bottom of a long scroll behind three cards that restate the same "go replay" idea.

---

## 9. Complete backlog

Format per finding: **ID — Title** *(Screen/area · Category · Severity)* — Issue → Why it blocks 10/10 → Evidence → 10/10 target → Fix (fix type · agent · impact · risk · before Human QA?).

**F001 — Ambiguous streak/today badge** *(Home · UX/copy · P2)* — "Today 0/3" + amber "3d" pill reads like a countdown/urgency device, not a streak indicator. → Confuses first-second scan of the app's most-seen header. → `01_home.png`. → A badge whose meaning is legible with zero prior context. → Relabel/restyle to make streak vs. daily-count unambiguous (e.g. flame icon + "3-day streak"). Bounded polish · Claude Code · Medium impact · Low risk · Yes.

**F002 — Home and Learn share one hero-card template** *(Home, Learn · UX/IA · P2)* — The "current lesson" hero card is structurally identical on both tabs. → Two of five tabs are visually interchangeable, undermining the tab bar's promise of distinct places. → `01_home.png`, `02_learn.png`. → Each tab has a recognizably different opening treatment. → Component evolution (per-tab accent/layout variant). Component evolution · Claude Code · Medium impact · Low risk · Depends.

**F003 — "Sharky" row reads as a chat-thread header** *(Home · UX · P3)* — Avatar + name + "•••" mimics a messaging inbox row with nothing chat-like following it. → Sets a wrong interaction expectation. → `01_home.png`. → A header that doesn't imply tappable chat history it doesn't have. → Bounded polish (restyle row). Bounded polish · Claude Code · Low impact · Low risk · No.

**F004 — Two competing metadata chips above one CTA** *(Home · Visual hierarchy · P3)* — "Poker from Zero" + "4 of 9 lessons complete" stack as two pills before the CTA. → Adds label clutter to the screen's single most important card. → `01_home.png`. → One consolidated metadata line. → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F005 — Redundant "next" signaling** *(Home · UI · P3)* — Numbered "2" badge and a "Next" pill both claim the same slot in "Today's sequence." → Two visual signals for one fact. → `01_home.png`. → Single unambiguous "next" indicator. → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F006 — Truncated copy bug** *(Home, Day-2 Home · UI/typography · P1)* — "Misses from lessons appear here when ther…" is cut off mid-word with no wrap/ellipsis handling. → A visible, embarrassing text-clipping bug on the most-seen screen in the app. → `01_home.png`, `16_day2_return_home.png`. → Text always wraps or truncates gracefully. → Bounded polish (fix line-clamp/width). Bounded polish · Claude Code · High impact · Low risk · Yes.

**F007 — Low-contrast "Next useful hand" link** *(Home · UX/CTA clarity · P3)* — Detached gray link+arrow floats top-right of a section header with no clear tap affordance. → Easy to miss or mistake for a label. → `01_home.png`. → A visibly tappable link. → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F008 — World-pill copy wraps unevenly** *(Learn · Typography/spacing · P3)* — "Hand Discipline" wraps to two lines inside its pill while siblings stay one line, producing uneven pill heights. → Small polish miss in an otherwise tidy row. → `02_learn.png`. → Uniform pill sizing regardless of label length. → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F009 — Accordion rows lack an expand affordance at rest** *(Learn · Interaction · P3)* — Collapsed "Journey preview" rows show only a chevron; nothing else hints they're expandable. → Minor discoverability gap. → `02_learn.png`. → A clearer expand/collapse cue (e.g. subtle background change). → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F010 — Up to four nested containers on one screen** *(Learn lesson detail · Visual hierarchy/spacing · P2)* — World card > lesson card > journey-preview card > accordion > step list nest four deep. → Visual nesting fatigue right where a beginner needs the clearest possible reading path. → `03_learn_lesson_detail.png`. → No more than two nesting levels visible at once. → Component evolution (flatten container structure). Component evolution · Claude Code · Medium impact · Medium risk · Depends.

**F011 — ~40% dead vertical space before the primary CTA** *(Placement · Spacing/wasted space · P2)* — Large empty gap between the third info card and "About two minutes... / Find my start." → Wastes the screen's most valuable real estate right before the conversion moment. → `04_placement.png`. → Balanced vertical rhythm, CTA reachable without excess empty scroll. → Bounded polish. Bounded polish · Claude Code · Medium impact · Low risk · Yes.

**F012 — Onboarding progress affordance is inconsistent** *(Placement · UX/navigation · P3)* — No progress bar here, unlike Welcome/gameplay screens. → Inconsistent wayfinding across one onboarding arc. → `04_placement.png` vs `05_welcome.png`. → One progress-indicator component used throughout onboarding. → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F013 — Three onboarding cards share identical visual weight** *(Placement · Visual hierarchy · P3)* — Hero card, quick-start card, and reassurance/FAQ card all use the same glowing gradient treatment. → No signal for which card is "the moment" vs. supporting reassurance. → `04_placement.png`. → A clear primary/secondary card hierarchy. → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F014 — Low-contrast step tracker** *(Placement · Typography/accessibility · P2)* — "Answer / Quick check / First hand" circle-outline tracker is small and low-contrast against the dark card. → Hard to read progress at a glance. → `04_placement.png`. → Higher-contrast, larger step indicator. → Bounded polish. Bounded polish · Claude Code · Medium impact · Low risk · Yes.

**F015 — First table exposure is nearly empty** *(Welcome, step 2/3 · Product flow/first impression · P2)* — No board, no pot, no populated hand — just card-backs and an instruction. → The very first look at the core product surface shows none of what makes it compelling. → `05_welcome_segment_01_decision` region / visible `05_welcome.png`. → The first table view previews at least a partial reveal of what a "read" feels like. → Component evolution. Component evolution · Claude Code + designer input · Medium impact · Low risk · Depends.

**F016 — Hero cards dwarfed by empty villain card-backs** *(Welcome · Table/visual hierarchy · P1)* — Four pairs of large, identical card-backs dominate the felt while hero's actual hand sits small at the bottom. → Eye goes to the least useful information first. → `05_welcome.png`. → Hero's hand reads as the clear visual subject of the screen. → Component evolution (table hierarchy pass, see §3/Wave C). Component evolution · Claude Code · High impact · Medium risk · Depends.

**F017 — Handoff screen is ~70% empty canvas** *(Welcome, step 3/3 · Spacing/premium impression · P2)* — Mascot glyph floats alone with huge top/bottom padding; CTA sits far below the visual interest. → Emptiness reads as unfinished rather than as intentional breathing room. → `05_welcome_segment_03_handoff.png`. → Compressed, intentional composition; empty space reads as a design choice, not an accident. → Bounded polish. Bounded polish · Claude Code · Medium impact · Low risk · Yes.

**F018 — Redundant recap chips vs. header copy** *(Welcome handoff · Copy/redundancy · P3)* — "Your first useful hand is ready." and the "Answer ✓ / Quick check ✓ / First hand ▶" chip row repeat the same information twice. → Minor redundancy. → `05_welcome_segment_03_handoff.png`. → One clear statement of "what's next." → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F019 — Board/pot module risks a layout jump preflop→flop** *(First decision · Table/motion gap · P2)* — The centered "PREFLOP · Pot 1.5 BB" module occupies the space later filled by 3 community cards; whether this resizes/animates cleanly can't be proven from stills. → Potential jank at the exact moment new information (the flop) arrives. → `06_first_decision.png` vs `07_correct_feedback.png`. → A verified, smooth preflop→flop transition. → Needs Human QA/engineering validation, not a blind visual fix. Motion-interaction · Human QA · Medium impact · Medium risk · Depends.

**F020 — Stack size is the smallest, lowest-contrast text on the screen** *(First decision · Table/typography · P1)* — "100 BB" renders in tiny white text under the hero name. → Stack size is decision-critical poker information and is currently the weakest text element present. → `06_first_decision.png`. → Stack size reads at a glance, comparable in weight to seat labels. → Bounded polish (type-scale/weight bump). Bounded polish · Claude Code · High impact · Low risk · Yes.

**F021 — Thin, low-visibility progress bar** *(First decision · UI/motion · P3)* — 2px line, low contrast against the header hairline. → Weak wayfinding for a journey meant to feel like meaningful steps. → `06_first_decision.png`. → A clearly visible progress indicator (reuse Session Summary's segmented bar, see F072). → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F022 — Teaching question undercuts itself** *(First decision · UX/learning · P2)* — "Which seat is the hero seat?" is asked while the hero seat is already the only color-distinguished pod on the table. → The exercise isn't actually blind; pedagogically weak as a "first find your seat" moment. → `06_first_decision.png`. → Either ask a question the UI doesn't already answer, or reframe the copy as confirmation rather than a quiz. → Content-copy fix. Content-copy · Claude Code · Medium impact · Low risk · Yes.

**F023 — Four competing micro-labels above the board** *(Correct/Wrong feedback, Repair states · Table/visual noise · P1)* — "No bet yet" pill + "FLOP" label + community cards + "Pot 3 BB" pill stack in a ~110px zone. → Exactly the "too many competing labels" pattern named in the review brief; a lot of small elements for one simple fact. → `07_correct_feedback.png`, `08_wrong_feedback.png`. → One unified, larger status treatment for street + action-state + pot. → Component evolution. Component evolution · Claude Code · High impact · Medium risk · Yes.

**F024 — "No bet yet" reads as an internal state name** *(Table screens W1–W1 lessons · Copy/table · P2)* — Ambiguous, debug-flavored phrase for a first-time reader. → Adds friction to reading the one clue the lesson is built around. → `07_correct_feedback.png`. → A phrase that reads as coached, in-voice copy on first encounter. → Content-copy. Content-copy · Claude Code · Medium impact · Low risk · Yes.

**F025 — Three label rows before the payoff word** *(Correct feedback · Visual hierarchy/eye path · P2)* — "Correct" → "Proof confirmed · Sharp read." → "Best play" all precede the giant "Check" headline, each in different type treatments. → Eye-jumping before the actual payoff. → `07_correct_feedback.png`. → One or two label rows max before the answer lands. → Bounded polish. Bounded polish · Claude Code · Medium impact · Low risk · Yes.

**F026 — Correct and Wrong feedback are visually near-identical** *(Correct vs Wrong feedback · Feedback/emotional tone · P1)* — Same layout, same cool blue/white palette, same icon size; "Table clue / Missed cue" carries no distinct color or shape from "Correct." → A user glancing quickly cannot tell win from miss without reading — a core "10/10" blocker for a feedback system. → `07_correct_feedback.png`, `08_wrong_feedback.png`. → A deliberate, still-supportive (not alarm-red) color/shape difference that's readable in under a second. → Component evolution. Component evolution · Claude Code · High impact · Medium risk · Yes.

**F027 — "Repair proof" sub-system appears before it's introduced** *(Correct feedback, screen 7 · Learning/onboarding sequencing · P2)* — "Repair proof / Table read improved" footer shows up on only the third table screen, ahead of any explanation of what "repair" is. → Introduces a new concept mid-flow without setup. → `07_correct_feedback.png`. → Repair vocabulary introduced before or exactly when first used. → Content-copy / sequencing fix. Content-copy · Claude Code · Medium impact · Low risk · Depends.

**F028 — "Try one like this" undersells the core remediation mechanic** *(Wrong feedback · Copy/CTA clarity · P3)* — Casual-sounding CTA for what is actually the app's main repair loop. → Undercuts the weight of the moment. → `08_wrong_feedback.png`. → CTA copy that signals "this matters" without being alarming. → Content-copy. Content-copy · Claude Code · Low impact · Low risk · No.

**F029 — Wrong-feedback Sharky uses the least expressive art available** *(Wrong feedback · Sharky · P1)* — The small neutral circular badge (same as the Home avatar) appears at a miss moment instead of a coaching/empathetic pose. → The exact moment a companion should show up strongest gets the flattest art. → `08_wrong_feedback.png`. → A pose visibly distinct from the neutral badge, communicating support. → Art-mascot production. Art-mascot production · Designer-illustrator · High impact · Low risk · Depends.

**F030 — Five stacked label rows in Repair focus** *(Repair focus · Visual hierarchy · P1)* — "Table clue / Repair coach..." → "Better option" → "Check" → "Repair focus" sub-box is the densest label stack in the pack. → Worst-case example of the copy-stacking problem. → `09_repair_focus.png`. → No more than two to three label rows before the CTA. → Component evolution. Component evolution · Claude Code · High impact · Medium risk · Yes.

**F031 — Repaired success looks identical to first-try success** *(Targeted recheck result · Emotional payoff · P2)* — "Fix landed: you handled this spot correctly" uses the same generic layout as an ordinary correct answer. → A "you fixed your own mistake" moment should feel bigger; currently it doesn't escalate at all. → `10_targeted_recheck.png` vs `07_correct_feedback.png`. → A visually distinct "you repaired this" celebratory treatment. → Component evolution. Component evolution · Claude Code · Medium impact · Low risk · Depends.

**F032 — "Check" reused as the giant headline across four unrelated screens** *(07, 08, 09, 10 · Visual system/screen distinctiveness · P1)* — From a glance, four screens with four different meanings are visually indistinguishable; only a small label above changes. → Directly undermines "screen-to-screen continuity" and "premium feel." → `07`–`10` visible screenshots. → Each state visually distinct even before reading the small label. → Component evolution. Component evolution · Claude Code · High impact · Medium risk · Yes.

**F033 — Clue and explanation aren't visually connected** *(Correct/Wrong/Repair screens · Feedback/eye path · P1)* — The felt's "No bet yet" clue and the text explanation below it are co-located but not linked by any line, highlight, or shared color. → The brief specifically calls out this connection as a thing to check; evidence shows it's missing. → `07_correct_feedback.png`. → A visible link (highlight, arrow, shared accent) between the table clue and its explanation. → Component evolution. Component evolution · Claude Code · High impact · Medium risk · Yes.

**F034 — No unifying container for the board's header zone across states** *(Table screens · Table/visual system · P2)* — The zone above the community cards has been observed holding three different kinds of content (pill+label, progress bar, long banner) with no shared design. → State-dependent layout thrash in the felt's most-viewed zone. → `07_correct_feedback.png` vs `17_w11_transfer.png`. → One flexible but visually consistent header-zone component for all states. → Component evolution. Component evolution · Claude Code · Medium impact · Medium risk · Depends.

**F035 — Correct/Wrong/Repair share one near-monochrome palette** *(Feedback system · Feedback/color semantics · P0)* — No deliberate 3-way color system separates a win, a miss, and a repair state; the only current differentiation is Repair's amber accent. → This is close to the core of "does wrong feel supportive, does proof feel earned" — the palette currently can't carry that emotional distinction on its own. → `07`, `08`, `09` visible screenshots. → A calm 3-color system (e.g., teal=correct, muted warm=miss, amber=repair) that never reads as alarming. → Component evolution. Component evolution · Claude Code + designer input · High impact · Medium risk · Yes.

**F036 — Sharky's "worried" pose is reused for a positive session-close moment** *(Session summary · Sharky/emotional tone · P1)* — The same chin-scratch pose used for a wrong-answer moment also delivers "Good proof. Keep the table clue in view." at session close. → Art doesn't semantically map to the state it's illustrating. → `11_session_summary.png` vs `08_wrong_feedback.png`. → Distinct poses for consoling vs. congratulating. → Art-mascot production. Art-mascot production · Designer-illustrator · High impact · Low risk · Depends.

**F037 — Three cards restate one idea before the score appears** *(Session summary · Copy/spacing · P2)* — "What next," "What improved," "This run" all circle back to "go replay this block" before any stats surface. → Redundant reading load exactly where a payoff should land. → `11_session_summary_segment_02_mid.png`. → One consolidated "what happened / what's next" block. → Bounded polish (content consolidation). Bounded polish · Claude Code · Medium impact · Low risk · Yes.

**F038 — Session accuracy stat is the least visually prominent element on the screen** *(Session summary · Learning/visual hierarchy · P1)* — "50% accuracy · 1/2 correct · 1 error" is small, plain gray-white text near the bottom of a 3-screen scroll, behind four cards of restated copy. → The single most concrete "did I get better" proof point in the whole session is the hardest thing on the screen to notice. → `11_session_summary_segment_03_bottom.png`. → The score is one of the first things seen, sized and colored to match its importance. → Component evolution. Component evolution · Claude Code · High impact · Low risk · Yes.

**F039 — Two exits with unclear priority** *(Session summary · UX/copy clarity · P2)* — "Replay before next lesson" (primary) and "Back to map" (text link) don't make clear what "replay" actually replays. → Ambiguous next action at the end of a session. → `11_session_summary_segment_03_bottom.png`. → Copy that states exactly what each exit does. → Content-copy. Content-copy · Claude Code · Medium impact · Low risk · Yes.

**F040 — Session Summary is a long, visually flat scroll** *(Session summary · Visual system · P2)* — Three screen-heights of nearly identical dark rounded-rect cards with the same label+headline+body pattern. → By the third screen height, content blurs together. → `11_session_summary_*`. → Visual variation (color, size, layout) that breaks up the scroll at least once. → Component evolution. Component evolution · Claude Code · Medium impact · Low risk · Depends.

**F041 — Practice tab opens as a bare page title, unlike other hub tabs** *(Practice · Visual system/consistency · P3)* — No hero card treatment for the page header itself, in contrast to Home/Learn's immediate hero-card opening. → Inconsistent opening pattern across hub tabs. → `12_practice_default.png`. → Consistent opening treatment across all hub tabs. → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F042 — Fourth reuse of the hero-card template** *(Practice · IA/visual system · P2)* — "Start a short rep" is the same icon-badge/title/chips/CTA component used on Home and Learn. → Confirms full pattern fatigue: the app's "hero card" now looks the same on 3+ tabs. → `12_practice_default.png`. → A tab-specific accent/icon language differentiating Practice's hero moment. → Component evolution. Component evolution · Claude Code · Medium impact · Low risk · Depends.

**F043 — Generic checkmark icon reused for "informational tip"** *(Practice · Iconography · P3)* — The same green checkmark used for completed tasks/achievements also marks a plain explanatory tip card. → No icon vocabulary distinguishing "FYI" from "done." → `12_practice_default.png`. → A distinct icon for informational content vs. completion state. → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F044 — Entire secondary practice grid is locked** *(Practice · Product flow/premium impression · P2)* — All four topic cards (Actions, Blinds, Positions, Showdown) show a lock icon; only the single daily hero card is active. → A "Practice" tab where 100% of browsable content is locked reads as sparse/demo-like on an early-week screen. → `12_practice_default.png`. → Locked cards communicate specifically when/how they unlock, reducing the "empty tab" feeling. → Content-copy + component evolution. Component evolution · Claude Code · Medium impact · Low risk · Depends.

**F045 — Same gating concept explained three times on one screen** *(Practice · Copy/redundancy · P2)* — Hero card, "Repair unlocks from real misses" card, and "More practice opens through the route" card all restate the same idea. → Redundant without adding specificity. → `12_practice_default_segment_02_mid.png`. → One clear explanation of the gating model. → Bounded polish. Bounded polish · Claude Code · Medium impact · Low risk · Yes.

**F046 — Empty-state legend is fairly dense for a zero-state** *(Review empty · Cognitive load · P3)* — The MISS/REPAIR/PROOF 3-row legend delivers a mini-lecture instead of pure reassurance-and-redirect. → Slightly more reading than an empty state typically needs. → `13_review_empty.png`. → A lighter-weight empty state, with the full legend available on demand rather than by default. → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F047 — Two near-identical Sharky bubbles on one screen** *(Review empty · Sharky/visual repetition · P3)* — Same avatar+speech-bubble art used twice in quick succession for two separate tips. → Minor repetition. → `13_review_empty.png`. → Vary avatar presentation between the two tips, or consolidate into one. → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F048 — Double-paragraph density before the CTA** *(Review active repair state · Copy density · P2)* — "Pattern to practice" sub-box plus a second paragraph both precede "Practice this spot." → Same over-explanation pattern as feedback screens. → `14_review_active.png`. → One paragraph max before the CTA. → Bounded polish. Bounded polish · Claude Code · Medium impact · Low risk · Yes.

**F049 — Large empty zone below the legend** *(Review active repair state · Spacing/wasted space · P2)* — Roughly half the screen below the MISS/REPAIR/PROOF row is empty before the bottom nav. → Wasted space on a screen meant to feel purposeful and focused. → `14_review_active.png`. → Rebalanced composition, no large dead zone. → Bounded polish. Bounded polish · Claude Code · Medium impact · Low risk · No.

**F050 — Fifth reuse of the hero-card template** *(Profile/You · Visual system · P2)* — "Proof profile" is the same component pattern seen on Home, Learn, and Practice. → Confirms the pattern now spans four of five tabs. → `15_profile.png`. → A profile-specific visual treatment (e.g., a stat-ring/badge-wall aesthetic) distinct from the hub hero card. → Component evolution. Component evolution · Claude Code + designer input · Medium impact · Low risk · Depends.

**F051 — Four different content types share one card style for three screen-heights** *(Profile/You · Visual hierarchy/screen monotony · P2)* — Stats, achievements, skills-practiced, and settings-nav all render in the same outlined-card chrome. → Contributes to overall screen-to-screen and section-to-section sameness. → `15_profile_segment_02_mid.png`, `15_profile_segment_03_bottom.png`. → Distinct visual treatment per content type. → Component evolution. Component evolution · Claude Code · Medium impact · Low risk · Depends.

**F052 — Streak visualization has no day labels** *(Profile/You · Gamification/visual payoff · P2)* — A row of dots/pills with no Mon/Tue-style labels. → Weak payoff for a mechanic meant to feel motivating. → `15_profile.png`. → Labeled streak visualization the user can read at a glance. → Bounded polish. Bounded polish · Claude Code · Medium impact · Low risk · No.

**F053 — Earned and locked achievement badges share one visual tier** *(Profile/You · UI clarity · P3)* — "Rhythm saved today" appears grayed among otherwise-earned badges with no lock icon distinguishing it. → Ambiguity about what's actually unlocked. → `15_profile_segment_03_bottom.png`. → Clear locked/earned visual distinction. → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F054 — No personalization anywhere on the "You" tab** *(Profile/You · Product/premium impression · P3)* — No name, no avatar, no photographic/personal element beyond the generic Sharky icon and stat cards. → For a tab literally called "You," there is no user identity. → `15_profile.png`. → Open question: confirm whether this is an intentional anonymity/privacy choice before treating as a gap. → Depends on product intent — flag for clarification, not an automatic fix. Content-copy / product decision · Human QA / product · Low impact · Low risk · Depends.

**F055 — Day-2 return gets zero distinct visual treatment** *(Day-2 return Home · Product flow/emotional payoff · P1)* — Structurally identical to Home aside from two copy edits; no date ceremony, no streak-color change, nothing marking "you came back." → Day 2 is the highest-churn day in most habit products; this moment currently gets no visual investment at all. → `16_day2_return_home_full_page.png` vs `01_home.png`. → A distinct "welcome back" visual moment (however small) tied to returning. → Component evolution. Component evolution · Claude Code + designer input · High impact · Low risk · Depends.

**F056 — 12 weeks of progress produce a pixel-identical table** *(W11 transfer, W12 payoff, W12 terminal · Product flow/payoff/escalation · P0)* — Table structure, seat layout, card-back style, dealer button, and chrome in screens 17–19 are structurally identical to screen 6 (Week 1's first decision). → Nothing about the table visually communicates progress across an entire 12-week arc — the single biggest structural finding in this review. → `06_first_decision.png` vs `17_w11_transfer.png`/`19_w12_terminal.png`. → A designed escalation language (richer felt treatment, upgraded HUD elements, or similar) that visibly differentiates early and late tables. → Larger redesign (of the table-escalation system specifically, not the whole app). Component evolution / larger redesign (scoped) · Claude Code + designer input · High impact · Medium risk · Depends.

**F057 — Late-game contextual banner copy is longer and more abstract than early copy** *(W11/W12 screens · Copy/cognitive load · P2)* — "Repeated blind overfold cue," "Process, reset, discipline loop," and similar replace the earlier "No bet yet" idiom with denser, more abstract prose. → A readability cliff at the exact milestone moment comprehension should be effortless. → `17_w11_transfer.png`, `18_w12_payoff.png`. → Consistent copy register/length across early and late lessons. → Content-copy. Content-copy · Claude Code · Medium impact · Low risk · Yes.

**F058 — "Volume I complete" delivered in an ordinary feedback card** *(W12 terminal · Emotional payoff/motion gap · P0)* — The biggest narrative payoff of the reviewed arc uses the same small card, same Continue button, same layout as any routine correct answer. → No ceremony at the one moment that should feel most earned. → `19_w12_terminal.png`. → A distinct, larger "milestone complete" visual treatment (not necessarily a new component per lesson, but a deliberately escalated one for arc-closing moments). → Larger redesign (scoped to milestone moments). Component evolution / larger redesign (scoped) · Claude Code + designer input · High impact · Medium risk · Depends.

**F059 — Striking late-game board textures aren't called out** *(W11/W12 screens · Table/pedagogical visual support · P2)* — Monotone/two-tone flops (e.g., three spades) visually suggest flush/straight textures the lesson is explicitly about, but nothing highlights this. → Missed chance to visually reinforce exactly what's being taught. → `18_w12_payoff.png`. → The board visually spotlights the texture the lesson names (e.g., highlighting the three same-suit cards). → Component evolution. Component evolution · Claude Code · Medium impact · Low risk · Depends.

**F060 — Blind-chip token style silently changes between early and late lessons** *(W1 vs W11+ table screens · Table/visual system · P2)* — Early screens show a round gold-coin chip icon outside the seat pod; late screens show plain gray text inside the seat pill, with no icon. → Two different components for one concept, with no visual bridge or evolution shown. → `06_first_decision.png` vs `17_w11_transfer.png`. → One consistent blind/chip token used everywhere. → Bounded polish (pick one, apply everywhere). Bounded polish · Claude Code · Medium impact · Low risk · Yes.

**F061 — Wasted felt: roughly a third of the table surface carries no information** *(All table screens · Table/wasted space · P1)* — Wide "wings" of empty green felt sit between seat pods and the center board module in every table screenshot. → The heart-of-the-app screen under-uses its own canvas. → `06_first_decision.png`, `17_w11_transfer.png`. → Felt space is either reduced/reshaped or given purposeful content (e.g., subtle position/action history). → Component evolution. Component evolution · Claude Code + designer input · High impact · Medium risk · Depends.

**F062 — Hero cards and villain card-backs share equal visual weight** *(All table screens · Table/card hierarchy · P1)* — Hero's two cards and five pairs of identical villain card-backs are rendered at the same size. → The one hand that matters doesn't visually dominate. → `06_first_decision.png`. → Hero's hand reads as the clear subject of the felt (via size, elevation, or framing). → Component evolution. Component evolution · Claude Code · High impact · Medium risk · Depends.

**F063 — Board container contrast against felt may be marginal** *(All table screens · Table/contrast · P3)* — The dark semi-transparent board container is only subtly differentiated from the green felt in these captures. → Possible legibility risk on lower-brightness displays; cannot be fully confirmed from stills. → `07_correct_feedback.png`. → Confirmed adequate contrast across real device brightness ranges. → Needs Human QA validation (display testing), not a blind fix. Human QA validation · Human QA · Medium impact · Low risk · Depends.

**F064 — Pot label under-prioritized relative to its decision importance** *(All table screens · Table/pot prominence · P1)* — "Pot 3 BB"/"Pot 12 BB" is a small pill roughly equal in weight to the street label beside it. → Pot size is one of the most decision-relevant numbers on the felt yet the least prominent numeral on screen — named explicitly in the review brief's calibration list. → `07_correct_feedback.png`. → Pot size rendered with clearly greater visual weight than surrounding metadata. → Component evolution. Component evolution · Claude Code · High impact · Low risk · Yes.

**F065 — Street label and action-state pill split one line into unrelated halves** *(All table screens · Table/label hierarchy · P2)* — "FLOP" and "No bet yet" sit on the same horizontal band, competing rather than cooperating. → Splits attention across the same visual row into two disconnected facts. → `07_correct_feedback.png`. → Street and action-state presented as one cohesive status, not two competing pills. → Component evolution (folds into F023/F034). Component evolution · Claude Code · Medium impact · Low risk · Yes.

**F066 — Dealer button reads as a stray dot, not a poker artifact** *(All table screens · Table/iconography · P2)* — A small plain white circle with no shadow/bevel, overlapping the hero pod's corner. → Doesn't read as a recognizable, weighted poker object. → `06_first_decision.png`. → A dealer button with enough visual presence/dimension to read clearly as itself. → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F067 — Hero avatar has no true "this is you" signature beyond border color** *(All table screens · Table/hero treatment · P2)* — The "Y" avatar circle is the same generic treatment as villain gray icons, just recolored. → The one seat that matters most to the user lacks a distinct identity marker. → `06_first_decision.png`. → A hero-seat signature (glow, subtle motion-ready highlight, or icon) beyond color alone. → Component evolution. Component evolution · Claude Code · Medium impact · Low risk · Depends.

**F068 — No in-context glossary for position jargon** *(All table screens · Learning/beginner trust · P2)* — UTG/HJ/CO labels appear with zero tap-to-define affordance on the felt itself. → A "Poker from Zero" beginner has no safety net if they've forgotten a position abbreviation. → `06_first_decision.png`. → A lightweight, non-intrusive glossary affordance available in-context. → Component evolution. Component evolution · Claude Code · Medium impact · Low risk · No.

**F069 — Coaching/hint affordance is inconsistent across reps** *(Table decision screens · Table/coaching · P2)* — "Need a hint?" appears once (Placement-style first decision) and is absent from subsequent decision screens observed. → Inconsistent support availability. → `06_first_decision.png` vs `09_repair_focus.png`. → Consistent hint affordance available on every live decision. → Component evolution. Component evolution · Claude Code · Medium impact · Low risk · Depends.

**F070 — Two incompatible progress-bar designs used for the same concept** *(Table screens vs. Session Summary · UI/motion · P2)* — Table screens use a flat 2px line with a numeric fraction; Session Summary uses a nicer segmented/gradient bar. → Inconsistent progress component for the same underlying idea. → `06_first_decision.png` vs `11_session_summary.png`. → One progress-bar component reused everywhere. → Bounded polish. Bounded polish · Claude Code · Medium impact · Low risk · Yes.

**F071 — Table and action-controls panel read as two stacked products** *(All table screens · Table/UX cohesion · P1)* — Hard edge and differing background values separate the green felt from the dark action-button panel below it, with no shared framing. → Directly matches the brief's named risk: "table and feedback feel like two stacked blocks." → `06_first_decision.png`. → Felt and action panel read as one continuous system. → Component evolution. Component evolution · Claude Code + designer input · High impact · Medium risk · Yes.

**F072 — Action buttons are a genuine strength** *(All table screens · Table/touch ergonomics · Positive — do not change)* — Three large (~64px), semantically color-coded pill buttons (Fold/Check/Call). → This is one of the few clearly premium-feeling, well-executed interaction surfaces in the pack. → `06_first_decision.png`. → N/A — preserve as-is. → Do not change. N/A · N/A · N/A · N/A · N/A.

**F073 — "Proof" terminology is overloaded across the product** *(App-wide · Copy/learning clarity · P1)* — At least eight distinct compound uses of "proof" observed ("Proof banked," "Repair proof," "Proof confirmed," "Session proof," "Proof profile," "Collected proof," "Route proof," "Local proof saved"), each meaning something slightly different. → Significant terminology overload risking confusion rather than reinforcement of a concept meant to feel valuable. → Multiple screens, e.g. `07_correct_feedback.png`, `11_session_summary.png`, `15_profile.png`. → A tightened vocabulary — "proof" reserved for one clear meaning, with distinct terms for the others. → Content-copy. Content-copy · Claude Code · High impact · Low risk · Yes.

**F074 — "Continue" reused for four structurally different actions** *(Multiple screens · Copy/CTA clarity · P3)* — Same generic label advances past a correct answer, a repair result, a milestone, and a terminal recap. → Missed opportunity for CTA copy to build anticipation or clarity. → `07`, `10`, `17`, `19` visible screenshots. → CTA copy specific to what happens next in higher-stakes moments. → Content-copy. Content-copy · Claude Code · Low impact · Low risk · No.

**F075 — Nav badge policy is inconsistent across tabs** *(Bottom nav · UX/navigation · P3)* — Review gets a live badge + counted pill; Practice's equally time-sensitive "0/3 daily spots" gets none. → Inconsistent signal of urgency across tabs. → `13_review_empty.png` vs `12_practice_default.png`. → Consistent badge policy across tabs that have daily/time-sensitive state. → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F076 — No confirmation/transition moment evidenced between reps** *(Table/feedback flow · UX mechanics/motion · P3)* — Static evidence can't show whether tapping "Continue" produces any sense of arrival at the next rep. → Cannot be judged from screenshots; flagged as an open question rather than scored. → N/A (motion, not visual). → A confirmed, non-jarring transition between reps. → Needs Human QA / engineering validation. Motion-interaction · Human QA · Medium impact · Low risk · Depends.

**F077 — Elevation/shadow system is essentially flat app-wide** *(App-wide · Visual system/premium feel · P2)* — Cards use border+glow only; no distinguishable depth layering is evidenced anywhere in the pack. → Contributes to a less premium, single-layer feel versus apps using real elevation for focus. → All screens. → A layered elevation system distinguishing foreground/background/modal content. → Component evolution. Component evolution · Claude Code + designer input · Medium impact · Medium risk · Depends.

**F078 — One container style used for every content type app-wide** *(App-wide · Visual hierarchy · P1)* — Rounded-rect + 1px border + soft glow is reused for hero cards, lesson cards, achievement cards, stat cards, tip cards, and miss cards alike. → No container hierarchy exists — a critical CTA card and a passive tip card carry identical visual weight everywhere in the app. → All screens. → At least two to three container tiers signaling relative importance. → Component evolution. Component evolution · Claude Code + designer input · High impact · Medium risk · Depends.

**F079 — Icon stroke-weight inconsistency between nav and in-card icons** *(App-wide · Iconography · P3)* — Bottom nav icons appear heavier-stroke than icons inside cards. → Minor but noticeable inconsistency in an otherwise tidy icon set. → All screens with nav visible. → One consistent icon stroke weight throughout. → Bounded polish. Bounded polish · Claude Code · Low impact · Low risk · No.

**F080 — Only two moments in the entire pack visually escalate** *(App-wide · Visual system/key-moment escalation · P1)* — Session Summary's opening card and the Repair amber accent are the only deliberate escalations observed across 19 screens. → Day-2 return and W12 terminal — arguably the two biggest emotional beats reviewed — do not escalate at all (see F055, F058). → All screens, cross-referenced. → A defined set of "escalation moments" (milestones, returns, streak events) each with a deliberately bigger visual treatment than routine screens. → Larger redesign (scoped to escalation moments). Component evolution / larger redesign (scoped) · Claude Code + designer input · High impact · Medium risk · Depends.

**F081 — Sharky's pose count is thin relative to his narrative role** *(App-wide · Sharky · P1)* — Three poses total (neutral badge, worried/chin-scratch, open-smile) cover at least five distinct emotional beats the copy implies (encourage, celebrate, console, coach, congratulate). → The character the copy treats as a constant companion is visually under-built. → Multiple screens, e.g. `08_wrong_feedback.png`, `11_session_summary.png`, `13_review_empty.png`. → A 5–7 pose set matching the emotional beats the product already writes copy for. → Art-mascot production. Art-mascot production · Designer-illustrator · High impact · Low risk · Depends.

**F082 — Sharky never appears larger than a small framed badge** *(App-wide · Sharky/brand memorability · P2)* — Largest instance observed is roughly 96×96px inside a square dark frame. → Visual presence is consistently smaller and quieter than the copy's emotional claims about him. → All Sharky-inclusive screens. → At least one or two "hero Sharky" moments (large, full-body, unframed) at key beats. → Art-mascot production. Art-mascot production · Designer-illustrator · Medium impact · Low risk · Depends.

**F083 — Sharky's icon frame is visually similar to generic topic icons** *(App-wide · Sharky/iconography · P2)* — The same square, dark-gradient frame used for Sharky is close enough to graduation-cap/lightning-bolt/trophy icons that he can read as "just another icon" rather than a distinct character. → Undercuts brand memorability. → `01_home.png` vs `02_learn.png` (Foundation-map icon) or `12_practice_default.png` (topic icons). → A signature Sharky frame (e.g., always circular, always ringed in one signature color) never used for anything else. → Art-mascot production. Art-mascot production · Designer-illustrator · Medium impact · Low risk · Depends.

**F084 — No static affordance suggests Sharky ever animates/reacts** *(App-wide · Motion · P3)* — No motion-lines, blink-hint, or bubble-tail animation cue is evidenced in any still. → Cannot be judged from screenshots; flagged as an open question. → All Sharky-inclusive screens. → A confirmed motion/animation spec for Sharky's key states. → Needs Human QA/engineering + designer collaboration to scope. Motion-interaction · Human QA + designer-illustrator · Medium impact · Low risk · Depends.

**F085 — Body/meta text frequently sits near the low end of comfortable mobile scale** *(App-wide · Typography · P2)* — Badge-chip text, journey-preview subcopy, and profile stat labels are estimated at ~13–14px gray-on-navy. → Borderline small for a mobile product, especially for anything decision-relevant. → `04_placement.png`, `15_profile.png`. → A minimum body-text scale that stays comfortably legible on-device. → Bounded polish. Bounded polish · Claude Code · Medium impact · Low risk · Yes.

**F086 — Every hub tab uses the identical monochrome-navy + cyan palette** *(App-wide · Visual system/color · P2)* — No per-tab identity color exists anywhere in Home/Learn/Practice/You. → A contributing cause of the tab-sameness problem named throughout this review. → `01`, `02`, `12`, `15` visible screenshots. → A restrained per-tab accent (still within one cohesive palette family) that helps each tab feel like its own place. → Component evolution. Component evolution · Claude Code + designer input · Medium impact · Low risk · Depends.

**F087 — Roughly 14 of 19 screens are reskins of just two templates** *(App-wide · Visual system · P1)* — The hero-card hub template (Home/Learn/Practice/You) and the table+feedback template (05–10, 17–19) account for the large majority of the reviewed surface. → Directly undercuts "does this feel top-1 premium" — the product currently reads as one component library, not 19 considered moments. → All screens, cross-referenced. → A recognizable, distinct visual identity for each of the app's main contexts. → Larger redesign (scoped — template differentiation, not a full rebuild). Component evolution / larger redesign (scoped) · Claude Code + designer input · High impact · High risk · Depends.

**F088 — Home/Learn/Practice/You headers do not differentiate their tab's purpose** *(App-wide · UX/IA · P2)* — Every hub tab opens with a hero card following the exact same title/subtitle/CTA scaffold regardless of whether the tab's job is "resume," "browse," "drill," or "review self." → Reinforces IA sameness noted above. → `01`, `02`, `12`, `15`. → Header treatment that visually signals the tab's distinct job. → Component evolution. Component evolution · Claude Code · Medium impact · Low risk · Depends.

**F089 — Practice tab's gating gives an "empty/demo" impression on first exposure** *(Practice · Product flow · P2)* — 100% of the browsable secondary content is locked, with only the always-present single daily card active. → Risk that early users perceive the tab as unfinished rather than intentionally paced. → `12_practice_default.png`. → Locked content communicates a specific, motivating unlock path rather than reading as absence. → Content-copy + component evolution. Component evolution · Claude Code · Medium impact · Low risk · Depends.

**F090 — "Voice" shifts from concrete poker language to abstract coaching language late in the arc** *(W11/W12 · Copy/brand voice · P2)* — "Process, reset, and discipline," "Mindset Bridge" contrast sharply with earlier "fold, check, call, raise" concreteness. → Risks reading as a different product voice right at the emotional payoff. → `18_w12_payoff.png`. → One consistent voice across the entire reviewed arc. → Content-copy. Content-copy · Claude Code · Medium impact · Low risk · Yes.

---

## 10. Redesign decision

**Selected: Option 2 — the current system can reach 8.5–9 with bounded/component evolution, but true 10/10 requires visual-direction evolution in two specific subsystems.**

Reasoning: the overwhelming majority of this backlog (spacing, copy density, terminology, label stacking, container tiering, per-tab accenting, progress-bar unification) is bounded polish or ordinary component evolution — real work, but not a redesign, and low-to-medium risk to implement without touching route semantics or content architecture. Two areas, however, sit structurally above that: (1) the table's total lack of visual escalation across a 12-week arc (F056) and the related wasted-felt/hierarchy problems (F061, F062, F071), which need a *designed* escalation and hierarchy system, not a patch; and (2) Sharky's art set (F081–F084), which needs new illustration production, not a code change. Neither of these individually justifies "full redesign before Human QA" status for the whole product, but both are scoped, larger design efforts that should be planned as their own tracks (Waves C and D below) rather than folded into ordinary bounded polish.

---

## 11. Wave plan to 10/10

**Wave A — must do before Human QA for max quality**
Goal: remove the issues we can already predict will distract or confuse testers, at low risk and low cost.
IDs: F001, F004, F005, F006, F007, F011, F012, F014, F022, F024, F027, F028, F037, F039, F041, F043, F045, F046, F048, F049, F052, F053, F057, F060, F065, F066, F070, F073, F074, F075, F079, F085, F090.
Screens/components touched: Home, Learn, Placement, Welcome handoff, feedback panels (copy only), Session Summary, Practice, Review, Profile, table blind-chip token.
What not to touch: table layout/hierarchy structure, feedback color system, Sharky art, route logic.
Best implementation agent: Claude Code / Codex (copy, spacing, single-component prop fixes — no new art, no new visual language).
Expected score lift: Overall +0.5–0.8; UX and UI scores most affected.
DoD: no truncated text anywhere in the pack; "proof" vocabulary consolidated; each feedback/table screen has ≤2 label rows before its payoff; blind-chip token unified; nav badge policy consistent.
Validation/evidence required: refreshed real-text screenshot pack of touched screens; visual diff against this baseline.

**Wave B — should do before external/investor showing**
Goal: break the "everything looks the same" impression for anyone seeing the product for the first time.
IDs: F002, F042, F050, F077, F086, F088.
Screens/components touched: Home, Learn, Practice, Profile hero-card headers; global elevation tokens.
What not to touch: underlying data/props feeding these cards; navigation structure.
Best implementation agent: Claude Code / Codex, with a designer pass to define the per-tab accent language and elevation tiers before implementation.
Expected score lift: Premium visual +0.5–1.0.
DoD: each hub tab has a recognizably distinct opening treatment; at least two container elevation tiers exist and are used consistently.
Validation/evidence required: side-by-side contact sheet of all 4 hub tabs pre/post.

**Wave C — table/gameplay system evolution**
Goal: fix the heart of the app — hierarchy, wasted space, and a designed escalation language across the 12-week arc.
IDs: F015, F016, F023, F034, F056, F059, F061, F062, F064, F067, F069, F071, F078, F087 (table-specific portion).
Screens/components touched: all table screens (Welcome through W12 terminal), action-panel/felt boundary.
What not to touch: action-controls button design (F072, keep as-is), poker rules/route semantics, hand/board data.
Best implementation agent: Claude Code / Codex for engineering, with a designer-illustrator or product designer defining the escalation language (what "richer" looks like by Week 12) before implementation begins.
Expected score lift: Table/gameplay score +1.5–2.0; single biggest lever in this review.
DoD: pot/hero/stack hierarchy clearly readable at a glance; felt and action panel read as one system; a defined, implemented visual difference between an early-week table and a Week 11/12 table.
Validation/evidence required: fresh real-text captures of Week 1 vs Week 11/12 tables side by side; Human QA read on "does this feel like it's evolved."

**Wave D — Sharky art/companion system**
Goal: close the gap between what the copy claims about Sharky and what the art delivers.
IDs: F029, F036, F081, F082, F083, F084.
Screens/components touched: every screen with a Sharky avatar/bubble.
What not to touch: copy referencing Sharky (already good — see §8), placement logic/timing of when Sharky appears.
Best implementation agent: Designer-illustrator (new poses are the blocker; no code agent can originate them). Claude Code/Codex to implement once art is delivered.
Expected score lift: Sharky companion score +2.0–3.0; meaningful brand-memorability gain.
DoD: 5–7 pose set delivered and mapped to specific product moments; at least one "hero Sharky" large-scale placement implemented (Day-2 return or W12 terminal).
Validation/evidence required: pose-to-moment mapping doc; refreshed screenshots of the moments where new poses land.

**Wave E — feedback/repair/proof system evolution**
Goal: make Correct/Wrong/Repair readable at a glance, and visually connect the table clue to its explanation.
IDs: F025, F026, F030, F031, F032, F033, F035, F038.
Screens/components touched: Correct feedback, Wrong feedback, Repair focus, Targeted recheck result, Session Summary score display.
What not to touch: the underlying why-explanation copywriting (F077's strength — protect it), the Miss→Repair→Proof concept itself.
Best implementation agent: Claude Code/Codex, with designer input on the 3-color semantic system before implementation.
Expected score lift: Learning-loop score +0.5; UX score +0.5; directly addresses one of the brief's named P0s.
DoD: a user can tell correct/wrong/repair apart within one second without reading; the table clue and its explanation are visibly linked; session accuracy stat reads as the visual headline of the summary screen.
Validation/evidence required: 1-second glance test (can a fresh viewer sort correct/wrong/repair screenshots by state without reading copy).

**Wave F — journey/payoff/ceremony evolution**
Goal: give the two biggest emotional beats in the reviewed arc (Day-2 return, W12 terminal) a visual treatment that matches their narrative weight.
IDs: F017, F018, F040, F055, F058, F080.
Screens/components touched: Day-2 return Home, Session Summary composition, W12 terminal.
What not to touch: W13+ content and any route/unlock logic beyond the visual treatment of the moment itself.
Best implementation agent: Claude Code/Codex for implementation, designer input for the milestone/ceremony visual language (can share DNA with Wave C's escalation system).
Expected score lift: Commercial/investor-showing score +1.0; emotional payoff meaningfully improved.
DoD: Day-2 return and W12 terminal are each visually distinguishable from an ordinary screen at a glance; Welcome handoff composition no longer reads as mostly-empty.
Validation/evidence required: refreshed captures of the three ceremony moments.

**Wave G — motion/touch refinement**
Goal: resolve the open questions this static review could not answer.
IDs: F019, F063, F076, F084 (motion portion).
Screens/components touched: preflop→flop transition, board-container contrast, inter-rep transitions, Sharky motion.
What not to touch: nothing yet — this wave is validation-first, implementation-second.
Best implementation agent: Human QA to identify real issues; Claude Code/Codex to implement fixes once validated.
Expected score lift: unknown until validated; potentially meaningful for perceived "feel."
DoD: each flagged motion question has a confirmed answer (jank present/absent, contrast adequate/inadequate, transition present/absent).
Validation/evidence required: Human QA session notes and/or on-device recordings targeting these four specific questions.

**Wave H — post-Human-QA improvements**
Goal: lower-priority refinements that don't block a max-quality pre-HQA pass.
IDs: F003, F008, F009, F010, F013, F020, F021, F044, F047, F051, F054, F068, F089, F054 (F054 dup removed).
Screens/components touched: Home, Learn, Learn lesson detail, First decision, Practice, Review empty, Profile.
What not to touch: anything already covered by earlier waves.
Best implementation agent: Claude Code/Codex.
Expected score lift: incremental, +0.2–0.4 cumulative.
DoD: backlog closed out; no P2/P3 items left unaddressed without an explicit "do not change" decision.
Validation/evidence required: final refreshed full pack vs. this baseline.

---

## 12. What not to change

Per the review's constraints, and confirmed by this evidence as healthy or out-of-scope for a visual/UX pass:
- Route semantics and navigation logic.
- Answer correctness / poker-rule logic.
- W13+ content (not evidenced, not in scope).
- Telemetry.
- Content-engine architecture.
- The Miss → Repair → Proof conceptual model itself (F096) — sound, keep the concept even while fixing its visual execution.
- The why-explanation copywriting depth (F077/§4 strength) — the single strongest asset in the product; any redesign pass must preserve or strengthen this, not compress it for space.
- The action-controls (Fold/Check/Call) button design (F072) — genuinely good touch ergonomics.
- The bottom tab-bar IA (5 tabs, current labels) (F091/§7) — clear and standard, not a source of the problems found here.
- The Repair state's amber accent color (F034) — the one place a deliberate color decision already exists; extend the system rather than replace this piece.
- Tablet layout, beyond confirming (via this smoke pass) that nothing clips, overflows, or hides a CTA — no premium tablet redesign is warranted by this evidence; the phone UI is centered/letterboxed on tablet with generous but not broken dead space on both sides, which is a system-level note worth logging but does not rise to a redesign trigger per the review's own scope rules.

---

## 13. Human QA decision

- **Should we refresh the Human QA baseline right now?** No — recommend Wave A lands first. It is fast, low-risk, and removes issues (the truncation bug, the correct/wrong sameness, the "proof" terminology overload) that would otherwise consume tester attention and reporting on things already known.
- **Should visual/UX work continue before Human QA?** Yes, through at least Wave A, ideally also Wave B.
- **What would Human QA uniquely answer that this review cannot:** actual motion/transition feel between reps and preflop→flop; whether the action buttons feel as good in-hand as they look in stills; whether real beginners are actually tripped up by UTG/HJ/CO in live play; whether the "why" explanations are read and understood in practice, not just present; real emotional reaction to Sharky's current expressiveness; whether the current "proof" terminology confuses real users the way this review predicts it will on paper.
- **What should be fixed before Human QA to avoid wasting tester feedback on things we already see:** the text-truncation bug (F006), the correct/wrong visual sameness (F026), and the "proof" terminology overload (F073) — all three are near-certain to generate tester notes we can already write ourselves.

---

## 14. Final recommendation

- **Score now:** ~6.0/10 on visual/UX evidence — a competent, coherent app with polished individual cards, not yet a top-1 premium product.
- **Core blockers to 10/10:** (1) the table does not visually evolve across the entire 12-week arc; (2) Sharky is under-produced as a companion — too few poses, always small, no signature iconographic language; (3) Correct/Wrong/Repair share one near-monochrome palette with no real color-semantic system; (4) chronic label/copy stacking on the two screens that most need to be scannable (table, feedback); (5) four of five hub tabs reuse one hero-card template, flattening the whole IA.
- **Is a full redesign needed?** No. This is Option 2: bounded/component evolution gets most of the product to 8.5–9; two scoped tracks (table-escalation system, Sharky art production) need real design/illustration work beyond ordinary polish to close the last distance to 10.
- **Exact next 3 implementation waves, in order:** Wave A (bounded polish + copy, do immediately) → Wave E (feedback/repair color system + clue-to-explanation connection) → Wave C (table system evolution), with Wave D (Sharky art) running in parallel to C since it is an independent production track, not blocked by engineering sequencing.
- **Codex or Claude Code per wave:** Waves A, B, E, F, G, H are implementation-only (copy, spacing, component props, color tokens) — Codex/Claude Code, no new art required. Wave C needs Codex/Claude Code for engineering plus designer input to define the escalation language before implementation starts. Wave D is designer-illustrator-led; Codex/Claude Code implements only once art is delivered.
- **Is a designer/illustrator required?** Yes — specifically for Wave D (new Sharky poses, non-negotiable — no code agent can originate expressive character art) and to art-direct Wave C's escalation language and Wave F's ceremony/milestone visual language before those waves are implemented in code.
- **Should Human QA wait?** Only for Wave A (fast, low-risk, days not weeks). Do not hold Human QA hostage to Waves B–H — run Human QA in parallel with those, since it answers real motion/feel/comprehension questions this visual-only review structurally cannot.

---

## Final report

- **Objective:** Full UI/UX/visual 10/10 deconstruction of Sharky Poker against the attached real-text evidence pack (v5), across product, journey, table, feedback loop, Sharky, visual system, UX mechanics, and learning value.
- **Verdict:** Not yet 10/10. Currently reads as a competent, coherent app with polished individual cards rather than a distinctive top-1 premium poker trainer. Most of the gap is closeable via bounded/component evolution; the table-escalation system and Sharky's art set need dedicated design/illustration production beyond ordinary polish.
- **Artifact path:** `docs/_reviews/full_ui_ux_visual_10_10_deconstruction_v1.md` (this file). **Note on scope of this session:** this review was produced in a design-review workspace without access to the product's actual code repository — I inspected the attached evidence pack and wrote this markdown artifact directly, but I did not create a git branch, commit, or push anything to a repository. If a git commit is required, apply this file at the path above in the target repo using the suggested branch `codex/full-ui-ux-visual-10-10-deconstruction-v1` and commit message `docs: deconstruct ui ux visual path to 10`.
- **Evidence pack inspected:** `real_text_visual_pack_v5` — all 19 screens/states, full compact visible + full-scroll captures inspected directly; tablet evidence inspected via contact sheets for clipping/overflow/CTA-access/broken-layout smoke only, per scope. No inference beyond what the real-text captures show.
- **Number of findings:** 90 backlog items (F001–F090, one duplicate reference removed from Wave H's list).
- **Severity counts:** P0: 4 · P1: 18 · P2: 40 · P3: 26 · P4: 0 · (2 items marked "do not change" / positive, not counted as issues: F072, and the "what not to change" list in §12).
- **Redesign decision:** Option 2 — bounded/component evolution reaches 8.5–9; two scoped tracks (table-escalation system, Sharky art production) are required beyond that for true 10/10. Not a full ground-up redesign.
- **Recommended next wave:** Wave A, starting immediately.
- **Should Human QA wait:** Only for Wave A; run in parallel with all subsequent waves.
- **Push status:** Not applicable / not performed — no repository connection available in this workspace. Artifact is ready to be copied into the target repo at the path and branch specified above.
