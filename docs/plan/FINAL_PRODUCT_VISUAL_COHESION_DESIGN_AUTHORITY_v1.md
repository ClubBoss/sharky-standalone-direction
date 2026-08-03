# FINAL PRODUCT VISUAL COHESION — DESIGN AUTHORITY v1

**Product:** Sharky Poker (mobile poker training)
**Product baseline:** `fba56cf313dfdead4b955f3b411cd5e547b6c443`
**Evidence:** `SHARKY_COMPLETE_VISUAL_REALITY_CENSUS_v1` (10 current-main iOS Simulator rasters, iPhone 11 Pro T5 Compact, iOS 18.1, system fonts, 1.0×) + `SHARKY_VISUAL_CENSUS_INDEPENDENT_AUDIT_v1.md`
**Authority:** Claude Design — design adjudication only. No code, no repository change, no new screenshots, no generated imagery.
**Stage opened:** `FINAL_PRODUCT_VISUAL_COHESION_V1` — three implementation waves maximum, then freeze.

---

## 1. Executive verdict

**Path B is justified. Open `FINAL_PRODUCT_VISUAL_COHESION_V1` now, at three waves, and freeze.**

The product is not visually broken. It is visually **unauthored at the system level**. Every captured screen is individually legible; the defect is that each screen was solved locally. Three unrelated visual grammars are running simultaneously:

1. **Modern Table** — the strongest surface in the product. Material, geometry, and state chrome are premium and internally consistent.
2. **Navigation cards** — an outlined-card dashboard grammar with accumulating status pills, repeated "current" language, and nested bordered containers.
3. **Instructional panels** — dense, heavily tracked, label-led typography that reads procedural rather than coached.

They share a palette and share almost nothing else: not hierarchy, not density, not container logic, not typographic voice. That is why the product reads as an intermediate build. A learner moving Home → Learn → runner → feedback → Review crosses three design systems in five taps.

The correct intervention is **subtractive and systemic**, not a redesign campaign. In quantity terms the target is roughly: **-40% visible borders, -50% status pills, -35% words on navigation surfaces, one accent hue retired per screen, exactly one cyan CTA per screen, maximum container nesting depth of two.** No new surfaces. No new content. No added cards.

This document is written so Codex can implement without making a single local aesthetic decision. Where I do not have evidence, I say so and defer rather than invent.

**Verdict: OPEN_FINAL_VISUAL_COHESION — Wave 1 and Wave 2 are fully supported by current evidence; Wave 3 is admitted but cannot be accepted without the missing progressed-route captures listed in §2.**

---

## 2. Evidence confidence and limitations

### 2.1 Adjudication of conflicting scores

The census pack self-assessed 6.8/10 overall; the independent audit scored 6.1/10. **The independent audit is adopted as authoritative** for three reasons: it caught a semantic mislabel the pack did not; it identified systemic cross-screen grammar failure where the pack recorded only per-screen density; and it correctly refused to call the Practice truncation cosmetic.

| Dimension | Pack | Independent | **Adopted** |
|---|---|---|---|
| Overall visual maturity | 6.8 | 6.1 | **6.1** |
| Premium impression | 6.5 | 5.7 | **5.7** |
| Learning clarity | 7.8 | 7.5 | **7.5** |
| Cross-screen consistency | 6.7 | 5.9 | **5.9** |

Learning clarity is the product's real asset and must be protected through every wave. Cross-screen consistency is the failure mode, and it is the single number this stage exists to move.

### 2.2 Mandatory evidence correction

`09_learn_landing_fresh_ordinary.png` is **Fresh Home**, not Fresh Learn. The bottom navigation selects Home and the composition is the Home hero. Reclassify as `home_fresh_ordinary`.

Consequences, binding on all three waves:

- **A true Fresh Learn state does not exist in this census.** Any claim in the pack that "Fresh Learn hierarchy" is a strength (`VISUAL_COHESION_SYNTHESIS.md`, "Keep frozen") is unsupported and is **withdrawn**. Nothing about Fresh Learn may be frozen or redesigned on this evidence.
- The pack's per-screen table scores Fresh Learn 8/10 P and 9/10 L. That score belongs to Fresh Home. Fresh Home is therefore the highest-rated *captured* navigation surface **and** the screen with the largest empty lower canvas — a direct contradiction that confirms scoring by "absence of noise" rather than by composition.

### 2.3 Confidence by domain

| Domain | Confidence | Basis |
|---|---|---|
| Cross-screen grammar failure | **High** | Visible in all 10 rasters |
| Typography defects (tracking, all-caps, weight inflation) | **High** | Directly measurable in rasters |
| Card-nesting overuse | **High** | Practice, Review, Learn, You, world selection |
| Colour-role overload | **High** | Practice and You each carry ≥4 accent hues |
| CTA sizing/hierarchy | **High** | Consistent across captures |
| Compact-phone density | **Medium-High** | One visible truncation; several near-edge states |
| Modern Table quality | **High (as a keep)** | Best surface in the pack |
| Fresh Learn | **None** | Not captured |
| Repair / recheck / receipt | **None** | Route-blocked |
| Payoff, Practice-next, focused W4 drill | **None** | Locked |
| W3–W12 representatives | **None** | Locked |
| 1.4× accessibility | **None** | Not exercised |
| Motion | **None** | Stills only |

### 2.4 Evidence gates

No visual decision in this document depends on an uncaptured state. Where a state is uncaptured, this document defines the **grammar the state must join** rather than the state's layout — and Wave 3 acceptance is gated on capturing it.

**Wave 3 acceptance gate (hard):** true Fresh Learn, W1 repair, W1 recheck, W1 recheck receipt, real Learning Run payoff, Practice-next transition, one W3 or W4 representative, and W1 feedback + payoff at 1.4×. Wave 3 may be *implemented* against the grammar in §8; it may not be *accepted* until these exist as current-main ordinary-route Simulator captures.

---

## 3. Current visual-system diagnosis

### D1 — Three grammars, no arbitration *(root cause)*

The table is composed (fixed geometry, deliberate negative space, material depth). The navigation surfaces are stacked (cards appended vertically, each self-justifying, none subordinate). The instructional panels are labelled (every idea gets a coloured micro-heading). Nothing in the system says which grammar wins when they meet — so at the runner/theory boundary (`01`) they simply abut, with a hairline divider between two products.

### D2 — Border inflation

Almost every unit of meaning is wrapped in an outline. On `04_practice_landing` a bordered page card contains a bordered nested card which contains a left-rule block which contains a text action. Four containers, one idea: *retry the same clue*. When every element has a border, borders stop meaning anything, and the eye has no entry point. Same pattern on `05_review` (why-this → miss-to-repair → current clue → pattern-to-practice), `02_learn_landing_progressed` (world card → mission card → current-step block), and `06_profile` (hero → focus → progress card → four tiles).

### D3 — Status-pill accumulation

Home carries `Poker from Zero`, `2 of 9 lessons complete`, a route-proof line, `Today 0/3`, and `3d`. Five status objects before the CTA. Each is individually reasonable; together they convert the hero into a telemetry readout. The learner does not need proof of state — they need to know what to tap.

### D4 — Typographic over-emphasis

Recurring, all visible in the rasters: bold at nearly every level, so nothing is emphatic; all-caps micro-labels with heavy positive tracking (`WHY THIS, WHY NOW`, `MISS TO REPAIR`, `HOW REVIEW WORKS`); tracking applied to **full sentences** (`Before choosing, check whether a bet…`, `Current lesson is above.`, `On the next hand, notice No bet yet before choosing.`) which is both a legibility defect and the primary cause of the Practice truncation; four to five competing title sizes per screen; and saturated coloured labels sitting beside low-contrast grey body text, inverting the intended reading order.

### D5 — Colour carrying too many roles at once

`04_practice_landing` shows amber, cyan, electric blue, teal gradient, and blue outlines simultaneously. `06_profile` shows blue, cyan, amber, green, and a teal-gradient hero. When five hues are present, none is semantic. The learner cannot learn that amber means *repair* if amber also means *streak*, *eyebrow*, and *left rule*.

### D6 — CTA correct in identity, wrong in mass

The cyan filled button is the best-behaved component in the product: consistent, reachable, bottom-safe. But at its current height and width it can occupy ~10% of a compact viewport, and it often sits *inside* a hero card that is itself the loudest element. Two dominant objects, one action.

### D7 — Empty space that reads unfinished

`01_runner_theory` and `09_home_fresh` both leave roughly the lower 40% of the viewport as undifferentiated background. This is not calm — calm requires composition. It reads as a layout awaiting content, and it is the single largest contributor to the 5.7 premium score.

### D8 — Redundant navigation

`01_runner_theory` presents a top-left back arrow and a second lower-left back control in one viewport. Two affordances, one meaning, at opposite ends of the screen.

### D9 — Mascot without a role

Sharky appears at ~40px in a Home header and ~64px in the You hero — too small to create identity, large enough to consume the top of the hierarchy, and absent from every moment where an emotional anchor would actually pay off (miss, repair, achievement).

### D10 — Internal vocabulary surfaced to learners

"Proof profile", "Sharky keeps proof, not points", "Route proof", "Locked inventory stays secondary until the route opens it", "0 tasks complete", "6 tracked". This is the team's model of the system, not the learner's model of themselves. It is a visual problem because it forces label-led layouts to explain itself.

---

## 4. Target design principles

Seven principles. Every decision in §5–§9 derives from these; any future local decision must cite one.

**P1 — The table is the product's voice.** Non-table surfaces inherit the table's discipline: composed, dark, materially quiet, deliberately spaced. Where a navigation surface disagrees with the table, the navigation surface changes.

**P2 — One first glance.** Every screen has exactly one object that wins the first 300ms: a title, a hero, or a table. Everything else is visibly subordinate. Subordination is achieved by removing weight from the loser, never by adding weight to the winner.

**P3 — One action, one place.** One primary CTA per screen. If a screen appears to need two, one of them is secondary and must lose its fill.

**P4 — Show state, do not narrate it.** Progress is shown once, in one form, in one place. Repeated reassurance ("current", "route proof", "current mission above") is deleted, not restyled.

**P5 — Borders are expensive.** A border must earn itself by separating things that would otherwise be confused. Maximum container nesting depth is two.

**P6 — Colour is semantic before it is decorative.** Five roles, one hue each, no overlap. A hue with no role on this screen does not appear on this screen.

**P7 — Warmth comes from Sharky and from copy, not from chrome.** Emotional lift is delivered at five defined moments by the mascot and by sentence-case human language — never by gradients, glows, or added ornament.

**Target register:** premium, calm, focused, poker-native, learning-first, emotionally warm, compact-phone disciplined.

---

## 5. Design tokens and grammar

> **Mapping note.** Values below are given as **relationships plus indicative compact-phone px at 1.0×**. Codex must map them onto the existing Flutter token layer and keep the *relationships* exact even where an existing token differs by 1–2px. Do not introduce a parallel token system. Do not hard-code any value that an existing token already expresses.

### 5.1 Typography

Single system font family (SF on iOS), one family only. No display face, no secondary family.

| Role | Size (compact 1.0×) | Weight | Line-height | Tracking | Case |
|---|---|---|---|---|---|
| `display` | 32–34 | 700 | 1.05 | −1.5% | Sentence |
| `pageTitle` | 27–28 | 700 | 1.15 | −1.0% | Sentence |
| `cardTitle` | 19–20 | 600 | 1.25 | −0.5% | Sentence |
| `bodyStrong` | 16 | 600 | 1.45 | 0 | Sentence |
| `body` | 16 | 400 | 1.45 | 0 | Sentence |
| `support` | 14 | 400 | 1.45 | 0 | Sentence |
| `eyebrow` | 12 | 600 | 1.2 | +2% max | **Sentence** |
| `label` | 13 | 600 | 1.1 | 0 | Sentence |
| `numeric` | inherits | 600 | 1.0 | 0 | Tabular figures |
| `buttonLabel` | 17 | 600 | 1.0 | 0 | Sentence |

**Scale rule:** each step is ~1.25× its neighbour (14 → 16 → 20 → 27 → 34). No size may be introduced between steps.

**Weight rule:** exactly one 700 element per screen (`display` **or** `pageTitle`, never both). 600 is the emphasis weight. 400 is body. No 500. No 800.

**Line-height rule:** ≥1.45 for anything two lines or longer; ≤1.25 for titles. Never tighten body to fit — cut words instead.

**Tracking rules (binding):**
- Positive tracking is permitted **only** at ≤13px and **only** on `eyebrow` / `label`, capped at +2%.
- Positive tracking on any full sentence is **forbidden**. This retires the tracked sentence styles on Practice, Home ("Current lesson is above."), and both feedback screens.
- Negative tracking only on `cardTitle` and above.

**All-caps:**
- **Permitted:** inside Modern Table only, for protected stage/street tokens (`PREFLOP`, `FLOP`) — this is existing protected table chrome.
- **Forbidden everywhere else.** Specifically retires `WHY THIS, WHY NOW`, `MISS TO REPAIR`, `HOW REVIEW WORKS`, `MISS / REPAIR / RESULT`. These become sentence-case `eyebrow`.

**Per-screen ceiling:** at most **three** type sizes above `body` on any one screen.

**Measure:** body and support text max ~40 characters per line. If a string cannot fit its container at `body` size with correct tracking, the string is too long — shorten the copy; never scale down and never letter-space.

### 5.2 Colour roles

Exactly five semantic accents. One hue per role. No hue holds two roles.

| Role | Hue | Indicative | Used for | Never used for |
|---|---|---|---|---|
| **Primary action** | Cyan | `#4FE3F5` | The one primary CTA fill per screen. Nothing else. | Text, borders, icons, eyebrows, pills, progress |
| **Current learning state** | Electric blue | `#2E7BF6` | Progress fill, current-step marker, selected state, text actions, active nav tab | Success, warning, CTA fills |
| **Success / proof** | Green | `#34C88A` | Completed lessons, verified repair, receipt confirmation | Any CTA, any forward action |
| **Repair / attention** | Amber | `#F3B341` | The active miss, the repair state, streak flame | Eyebrows, decorative rules, generic emphasis |
| **Locked / inactive** | Cool grey | `#6B7A90` | Locked rows, disabled labels, lock glyphs | Any active element |
| Informational metadata | Slate | `#8FA0B5` | Support copy, metadata, secondary numerals | Titles |

**Per-screen ceiling:** the cyan CTA **plus at most two** other accents. Practice currently shows five; You shows five. Both must reduce.

**Adjacency rule:** green and amber never appear in the same container. They encode opposite learner states and reading them together is ambiguous.

**Gradient policy:** one gradient object per screen maximum, permitted only on the `hero` surface (§5.3), only as the existing dark teal → deep blue, only at low contrast against the page. Gradients are forbidden on cards, rows, pills, disabled controls (retires the gradient "Later" block on Practice), and behind text smaller than `cardTitle`.

**Contrast floor:** `body` ≥ 4.5:1 against its own surface; `support` ≥ 4.0:1; locked text may sit at 3.0:1 but must also carry a non-colour cue (lock glyph or position). Coloured labels may never be the only carrier of meaning.

### 5.3 Surface grammar

| Surface | Fill | Border | Radius | Rules |
|---|---|---|---|---|
| `page` | `#0A0F18` flat | — | — | No gradient, no texture, no glow. |
| `hero` | Teal→blue gradient | **None** | 20 | **Max one per screen.** May contain rows and pills. May **not** contain a bordered card. |
| `card` | `#101826` flat | 1px `rgba(255,255,255,.08)` | 16 | May contain rows and pills only. |
| `nested` | `#16202F` flat | **None** | 12 | Depth-2 only. Distinguished by fill, never by border. |
| `row` | Transparent | Bottom hairline only | 12 (on fill states) | Min height 56; 64 with two lines. |
| `pill` | `#16202F` | None (1px blue when selected) | 999 | `label` type. Max two per container, four per screen. |
| `progress` | Track `rgba(255,255,255,.10)`, fill blue | — | 999 | Height 4–6. One percentage readout, not two. |
| `selected` | Blue @ 8% | 1.5px electric blue | inherits | No shadow, no glow. |
| `locked` | `page` fill | None | inherits | Grey text + 16px lock glyph. |
| `disabled` | `card` fill @ 38% | None | inherits | Flat. No gradient, no cyan. |

**Nesting law (binding):**
- Maximum depth **2**: `hero`|`card` → `nested`|`row`|`pill`.
- **A bordered container inside a bordered container is prohibited.** Depth-2 differentiation is by fill only.
- **Prohibited today:** Practice (`card` → `card` → left-rule block → text action), Review (`card` → `nested` → `nested`), Learn progressed (world `card` + mission `card` → current-step block), You (`hero` → focus `card` → progress `card` → four tiles).
- **Permitted:** `hero` containing a progress row and up to two pills; `card` containing a list of rows; `nested` used **once** per card for the single most important sub-fact (e.g. the current clue).

**Depth policy:** one shadow level in the whole product, on `hero` only, low and diffuse. Elevation is otherwise expressed by fill lightness. No inner glows, no double borders, no border + shadow on the same object.

### 5.4 Spacing and density

Base unit **4**. Scale: 4, 8, 12, 16, 20, 24, 32, 40.

| Token | Compact 1.0× | Rule |
|---|---|---|
| `page.marginH` | 20 (16 at ≤375pt) | Identical on every screen including runner copy panels. |
| `page.top` | 16 below the persistent header | |
| `section.gap` | 28 | Between titled groups. This is the primary rhythm signal. |
| `block.gap` | 16 | Between sibling cards inside a section. |
| `card.padding` | 16 (`hero` 20) | Uniform on all four sides. |
| `nested.padding` | 12 | |
| `stack.gap` | 8 | Between title and its support line. |
| `row.minHeight` | 56 / 64 two-line | Never below 44 tappable. |
| `cta.height` | 52 | |
| `cta.gapAbove` | 20 from last content | |
| `cta.safeArea` | 12 above the safe-area inset | Sticky CTAs only. |

**Compact-phone density:** at ≤375pt width, `page.marginH` → 16 and `section.gap` → 24; **nothing else shrinks**. Reduce content, not type or padding. Any screen that requires more than two vertical scrolls of the viewport on a compact phone to reach its primary action has failed and must lose content.

**Empty-state composition** (fixes D7): a screen with little content is composed in **three bands** — orientation (title + one sentence), focus (hero + primary CTA), and horizon (a single quiet line or compact row that shows what comes next). The focus band is optically centred in the remaining space, not top-pinned above a void. Never fill the void with additional cards.

**Long-state composition:** at most three titled sections. Beyond three, the content belongs behind a route, not on the page.

**Safe area:** bottom-sticky CTAs respect the inset + 12. The persistent header respects the top inset. No content within 16 of the home indicator.

### 5.5 CTA hierarchy

| Tier | Appearance | Rules |
|---|---|---|
| **Primary** | Cyan fill, `#0A0F18` label, `buttonLabel`, full width, height 52, radius 14 | **Exactly one per screen.** Either inside the hero **or** bottom-sticky — never both. |
| **Secondary** | `#16202F` fill, 1px hairline, white label, same height | Max one per screen. Never cyan. |
| **Text action** | Electric-blue `label`, no fill, no border, ≥44 hit area | For lateral navigation ("All lessons", "View path"). Max two per screen. |
| **Disabled** | `card` fill @38%, grey label, flat | Never gradient, never cyan, never full-hero size. |
| **In-card** | Text action or secondary only | An in-card control may be Primary **only if it is the screen's single primary**. |

**Sizing principle:** the primary CTA is sized by reachability, not by importance — importance is already carried by being the only filled button. Its width matches the content column; it never exceeds 52 in height at 1.0×.

**Applies immediately to:** Home (hero CTA is the only primary — the "Today's sequence" rows become rows with a chevron, no fills); Practice (the disabled "Later" block loses its gradient and drops to a text action); Review ("Practice this spot" remains the single primary; the process diagram loses all button-like chrome).

### 5.6 Iconography

- **One set, one weight.** Line icons, ~2px stroke at 24px, rounded joins. No filled icons, no duotone, no mixed metaphor sets. Card suits inside Modern Table are protected content, not icons.
- **Sizes:** 16 (inline with `label`), 20 (row leading), 24 (nav, header actions). No other size.
- **Containers** (rounded-square icon tiles) are permitted **only** for: the hero eyebrow icon, and the completion check on a completed row. **Max two icon containers per screen.**
- **Semantic vs decorative:** an icon must change meaning if removed. Decorative icons are deleted — this retires the lightning tile on Practice's short-rep block, the bookmark tile on Review's miss card, and the target tile on You's focus card. Retained semantic icons: lock (locked), check (complete), flame (streak), eye (clue), chevron (navigation).
- **Ceiling:** at most **three distinct icon shapes** per screen, plus navigation.

### 5.7 Sharky mascot role

Sharky is the **coach**, not the product's mascot-in-residence. Presence is defined by moment, not by surface.

| Moment | Where | Scale | Emotional function | Copy contract |
|---|---|---|---|---|
| **Orientation** | First-session Home; placement/world intro | 96 | "I know where you are; start here." | One sentence, sentence case, first person. |
| **Encouragement** | Between-session Home, only when a streak or a due repair exists | 40 inline | Continuity, low-key warmth. | One clause. Never a paragraph. |
| **Repair** | Review, only when a miss is open | 40 inline beside the miss | Removes shame; frames the miss as fixable. | One sentence, never explanatory. |
| **Achievement** | Payoff, lesson completion, recheck receipt | 160 | Earned reward. The one loud moment. | One line + the proof. |
| **Identity** | You / Profile hero | 96 | "This is my coach and my record." | Name + one growth line. |

**Prohibited:** in the tab bar; in list rows; in the runner while the table is on screen; on Practice; on Learn; more than once per screen; alongside an explanatory paragraph in the same block (art and prose compete — pick one).

**Scale ladder:** 40 / 96 / 160. No other size. At 40, Sharky is an avatar and must not carry meaning alone. Below 40, Sharky is not used — a 40px mascot in a header (current Home) is decoration and is retired.

### 5.8 Motion — principles only

Evidence is absent, so this section defines **five patterns and their limits**, no timing curves beyond broad category, and no decorative motion. Motion is specified after static hierarchy is accepted (Wave 3), never before.

**Principles:** motion explains state change or it does not exist; a learning result is the only thing that earns a celebration; nothing loops; nothing enters that the learner did not cause; the table never animates for aesthetic reasons.

| # | Pattern | Trigger | Character | Limit |
|---|---|---|---|---|
| M1 | **Route advance** | Forward navigation | Horizontal push, emphasised ease, ~200–260ms | One direction per gesture. No cross-fade. |
| M2 | **Feedback reveal** | Decision result appears | Short rise (~16) + fade, ~160–200ms | Panel only. The table does not move. |
| M3 | **Progress commit** | A real result changes progress | Tween the bar and its numeral together, ~350–450ms, ease-out, once | Only after a genuine state change. Never on page entry. |
| M4 | **Proof stamp** | Completion, streak, receipt | One-shot scale 0.92→1 + fade, ~240–280ms | Non-looping. One per screen. |
| M5 | **Clue focus** | Teaching moment names a table element | Single highlight on that element, ~600ms, once | Non-looping, non-repeating, geometry unchanged. |

**Forbidden:** shimmer/skeleton pulses on real content, looping glows, parallax, staggered card entry on tab switch, confetti anywhere except the payoff moment, any animation on the Modern Table's geometry.

---

## 6. Screen-by-screen adjudication

Each entry: strengths → exact problems → hierarchy → density → typography → component consistency → relation to Modern Table → emotional/premium → **decision** → target outcome → **must remain unchanged**.

---

### 6.1 W1 runner theory — `01_runner_theory_w1_ordinary.png`

**Decision: REDESIGN (composition only — table geometry protected).** Wave 3. Severity P2.

**Strengths.** Table is clear, stable, premium. Step indicator (`Step 1/8` + bar) is immediately understandable. The teaching sentence is short and readable.

**Exact problems.**
1. Table occupies the upper ~55%; a single sentence occupies a ~40% empty lower canvas with no composition.
2. Two back controls in one viewport — top-left arrow and lower-left circular control (D8).
3. `Continue` sits bottom-right, unrelated in position or alignment to the teaching copy above it.
4. Teaching copy sits at the page's left margin while the table is centred — two different layout logics abutting at a hairline divider.
5. The eyebrow (`Preflop`) duplicates information already displayed inside the table (`PREFLOP` chip).

**Hierarchy.** Broken. The table wins the glance, but the table is not the learner's task — reading the sentence is. Nothing directs attention downward.
**Density.** Inverted: dense above, void below.
**Typography.** The teaching sentence is `cardTitle`-weight prose with no eyebrow hierarchy; table labels and lesson copy visibly disagree in weight and tracking.
**Component consistency.** The lower panel belongs to no defined surface — it is neither `card` nor `page` band. `Continue` is a bordered blue pill matching nothing else in the product.
**Relation to Modern Table.** Adjacent, not integrated. The strongest surface is undermined by what sits beneath it.
**Emotional/premium.** Lowest in the pack. Reads as an unfinished screen.

**Target outcome — the teaching stage.** Three fixed bands, top to bottom:
- **Stage** — the table, unchanged, in a fixed-height region that does not resize between steps.
- **Teaching rail** — a fixed-height band at `page.marginH`, containing: sentence-case `eyebrow` (step objective, *not* the street name), one `cardTitle` teaching sentence at ≤40ch, and nothing else. Fixed height so copy of different lengths does not shift the table between steps.
- **Advance** — one full-width Primary CTA, bottom-sticky, respecting `cta.safeArea`.

Remove the lower-left back control; the top-left arrow is the only back affordance. Remove the duplicate street eyebrow. Align the rail's left edge to `page.marginH` and let the table remain optically centred — the shared left margin is what joins them.

**Must remain unchanged.** Table geometry, seat positions, card rendering, chip/pot/street chrome, `Step n/m` semantics and progress truth, step count, teaching copy content, forward/back route behaviour.

---

### 6.2 Progressed Learn — `02_learn_landing_progressed_ordinary.png`

**Decision: REFINE.** Wave 2. Severity P2.

**Strengths.** World, current mission, current step, and lesson inventory are all comprehensible. Primary `Start` is unmistakable.

**Exact problems.**
1. Three peer layers compete: world card, mission card, lesson list.
2. The word "current" appears three times in one viewport (`Current world · W1`, `Current table read`, `Current step · 1 of 6`), plus `Current mission above` in the list.
3. `22%` is rendered twice — as a large coloured numeral and inside `2 of 9 lessons · 22%`.
4. The mission card carries two pills, a title, an eyebrow, a rationale, a bordered current-step block, and an oversized CTA — six weights in one container.
5. Nesting depth 3 (world card + mission card → current-step block with left rule).
6. `First Table Guide` appears twice — as the mission title and as the first list row, with the row explaining that it is "above".

**Hierarchy.** Two heroes. The world card and mission card have comparable mass; the list then starts a third.
**Density.** Administrative. Every fact is stated twice — once as status, once as reassurance.
**Typography.** Four title sizes; tracked coloured eyebrows; `Why it matters` styled louder than the sentence it introduces.
**Component consistency.** Two pill styles (filled cyan-outline vs plain text), two progress representations, three border treatments.
**Relation to Modern Table.** Distant. This is a form, not a composed surface.
**Emotional/premium.** Competent, not premium. Feels like a course-admin screen.

**Target outcome.**
- **World context becomes a header line, not a card:** `W1 · Poker from Zero` as `eyebrow` + `cardTitle` on the page background, with a 4px progress bar and **one** `22%` readout. No border, no icon tile, no map button as a peer — the map becomes a `24` header action.
- **One hero:** the mission `hero` — eyebrow (`Next up`), `pageTitle` mission name, one `body` rationale line ≤40ch, one `row` for the current step (fill-differentiated, no border, no left rule), one Primary CTA. Delete the second pill.
- **Lesson inventory becomes a plain row list** under a `section.gap`: no card wrapper, hairline dividers, 56/64 rows, leading state glyph (blue current / green check / grey lock), title + one support line, trailing chevron. Delete the `Now` pill (the blue leading marker already says it) and delete `Current mission above`.
- Delete two of the three "current"s. Keep `Next up`.

**Must remain unchanged.** Route order, lesson order, lock/unlock truth, lesson names, step counts, percentage values, `Start` destination, replay availability semantics.

---

### 6.3 Progressed Home — `03_home_progressed_ordinary.png`

**Decision: REDESIGN.** Wave 2 (tokens from Wave 1). Severity P2.

**Strengths.** The primary action is obvious. The daily intent is legible. Sharky is present.

**Exact problems.**
1. The hero carries an icon tile, an eyebrow, a `pageTitle`, two body paragraphs, two status pills, a proof line with its own icon, and an oversized CTA — eight objects.
2. `Today's sequence` immediately opens a second hierarchy with its own eyebrow, sentence, and two bordered rows, one of which carries a `Next` pill and a blue arrow — a second implied action.
3. Five status objects before the CTA (D3).
4. The Sharky header (40px avatar + name + world + overflow menu) reads as a chat surface, unrelated to anything below it.
5. `One tap opens the first hand chosen from your placement result.` — internal mechanics as learner copy, and the longest string on the screen.
6. `Learning path` row is marked complete with a green check while its support line says `Current lesson is above.` — tracked, redundant, and semantically confusing next to a completion state.

**Hierarchy.** Diffuse. Three objects have comparable mass.
**Density.** Overloaded above, then a second dashboard below.
**Typography.** Tracked sentences, coloured support text louder than body, four title sizes.
**Component consistency.** Two row styles, three pill styles, both green and amber present, gradient hero plus bordered cards.
**Relation to Modern Table.** None. This is the screen furthest from the product's voice.
**Emotional/premium.** Reads as a debug-rich product summary. Warmth is asserted in copy, not delivered by composition.

**Target outcome — one mission, one signal, one continuation.**
- **Header:** persistent, quiet. `Today 0/3` + streak chip. Retire the Sharky chat header on progressed Home (Sharky's Home role moves to the encouragement moment, §5.7, at 40px inline beside the mission eyebrow — or absent).
- **Band 1 — Mission `hero`:** eyebrow (`Today`), `pageTitle` mission name, **one** `body` line stating the learner benefit in learner language, one Primary CTA. **Maximum one pill.** Delete the second paragraph, the second pill, and the proof line — proof lives on You.
- **Band 2 — One progress signal:** a single row: world name, 4px bar, one percentage. No card.
- **Band 3 — One continuation:** a single row for the next thing (`Practice · 0/3 daily spots`) with a chevron. No pill, no fill, no arrow-plus-pill duplication. If a repair is open, this row is the repair row, amber leading glyph.
- Nothing else on Home. Ever.

**Must remain unchanged.** `Today n/m` truth, streak value, mission selection logic, CTA destination, lesson-completion counts, the Home↔Practice↔Review route relationships, telemetry event points.

---

### 6.4 Practice — `04_practice_landing_ordinary.png`

**Decision: REFINE (with one P2 defect fix).** Wave 2. Severity **P2** — visible truncation.

**Strengths.** "Useful reps" is an excellent, learner-native concept. Active repair is correctly prioritised over browsable inventory. The current-clue block gives real learning continuity.

**Exact problems.**
1. **`Before choosing, check whether a bet i…` is visibly clipped at the right edge.** Root cause is the tracked-sentence style (§5.1) in a fixed-width container. **P2 — must fix in Wave 1.**
2. Nesting depth 4: page `card` → `card` → left-rule block → text action.
3. The same idea — *retry the same clue* — is stated four times: the amber banner, `Active repair first`, the tracked amber line, and `Practice this`.
4. The disabled `Later` module is the largest single object on the screen and carries a teal gradient — a disabled control styled as a hero (D5, §5.5).
5. Five accents simultaneously: amber, cyan, blue, teal gradient, blue outlines.
6. `Start a short rep` is rendered in grey at `pageTitle` scale inside a gradient block, above a Primary-sized disabled button — the loudest composition on the page belongs to the least available action.
7. `Locked inventory stays secondary until the route opens it` — internal vocabulary.

**Hierarchy.** Inverted. The unavailable block outweighs the available repair.
**Density.** Highest in the pack.
**Typography.** Tracked sentences (causing the clip), grey `pageTitle` on gradient, four sizes.
**Component consistency.** Worst offender: two card grammars, three pill styles, gradient + bordered + left-rule containers in one scroll.
**Relation to Modern Table.** None; the gradient block is the least table-like object in the product.
**Emotional/premium.** Busy and slightly anxious.

**Target outcome.**
- **Page title band:** `Useful reps` (`pageTitle`) + one `support` line. Delete the amber instructional banner entirely — its content is redundant with the repair card that follows.
- **One repair `card`** (depth 2 max): amber `eyebrow` (`Repair first`), `cardTitle` naming the clue, one `nested` block holding the clue itself, one Primary CTA (`Practice this spot`). Delete the tracked amber line and the separate `Practice this` text action.
- **Quick session as a row, not a hero:** one `row` — `Short rep · 3 spots · ~3 min` — with a chevron. Delete the gradient block, the three chips, and the disabled `Later` button; if unavailable, the row shows a grey `Locked` trailing label.
- **Locked inventory:** collapsed row list, grey, lock glyphs, no card wrapper, no explanation sentence.
- Accents after refine: amber (repair) + blue (locked/current) + cyan (one CTA). Green and teal gradient removed from this screen.

**Must remain unchanged.** Repair-before-browse priority, clue identity and text, spot counts and time estimates, lock states, session-start destinations, telemetry.

---

### 6.5 Review — `05_review_ordinary.png`

**Decision: REDESIGN.** Wave 2. Severity P2.

**Strengths.** The repair CTA is explicit and correct. `Current clue` and `Pattern to practice` are genuinely useful learning constructs. The miss→repair→result model is sound.

**Exact problems.**
1. Six competing blocks: `WHY THIS, WHY NOW`, `MISS TO REPAIR`, `Current clue`, `Pattern to practice`, two body paragraphs, `HOW REVIEW WORKS`.
2. Three all-caps tracked headings, plus `MISS / REPAIR / RESULT` — the densest all-caps usage in the product (§5.1 forbids all four).
3. The same instruction is stated five times: `Practice this repair: notice No bet yet.` / `Read the table is still the one to fix.` / `nobody has bet yet` / `Miss: Read the table. Repair: spot it before choosing.` / `Next rep: spot the clue before choosing.`
4. Nesting depth 3 with two `nested` blocks in one card (amber clue + blue pattern) — and amber and blue adjacent, competing.
5. The bottom process diagram is cramped, its labels are clipped/overlapping (`Read-the-table → · · → · ·`), and it is partly cut by the viewport.
6. `Today` appears as a divider label above a `pageTitle` `Review`, creating a false second title.

**Hierarchy.** Absent. The screen has no single first glance; six labels all claim it.
**Density.** Second-highest in the pack, and the most verbally repetitive.
**Typography.** The worst screen for all-caps, tracking, and label-led layout. Reads procedural, technical, slightly punitive.
**Component consistency.** Three container styles, four label styles, both amber and blue `nested` blocks.
**Relation to Modern Table.** None. The table's calm is entirely absent.
**Emotional/premium.** Weakest emotionally. A miss should feel fixable; this reads like an audit report.

**Target outcome — one repair, one proof layer.**
- **Title band:** `Review` (`pageTitle`) + amber `1 miss to fix` chip. Delete the `Today` divider.
- **One repair `card`** — the screen's single hero:
  - amber `eyebrow`: `Miss to repair`
  - `cardTitle`: the miss, in learner language (`You missed that nobody had bet yet`)
  - one `nested` amber-led block: the clue, verbatim, once
  - one `body` line: why it matters (≤40ch × 2 lines max)
  - one Primary CTA: `Practice this spot`
  - Sharky at 40 inline beside the eyebrow (repair moment, §5.7) — one sentence, warm, non-explanatory.
  - Everything else in the current card is deleted: `WHY THIS, WHY NOW`, `Pattern to practice`, the duplicated `Next rep` line, and the second body paragraph.
- **Proof layer replaces the process diagram:** a compact three-state progress row — `Missed → Repairing → Proven` — as a single 3-step indicator using blue (current) and green (done), sentence-case `label`s, one line, no arrows-as-glyphs, no explanatory sentence. If nothing is due, this band shows one green `support` line and nothing else.
- **Delete `HOW REVIEW WORKS` entirely.** A learner who has a miss does not need the mechanism explained; if onboarding needs it, it belongs in the first-session flow, not on every visit.

**Must remain unchanged.** Miss identity and clue text, repair→recheck→proof semantics, due/not-due truth, `Practice this spot` destination, miss counts, telemetry.

---

### 6.6 You / Profile — `06_profile_ordinary.png`

**Decision: REDESIGN.** Wave 2. Severity P2.

**Strengths.** Sharky is present and correctly placed for identity. Streak and tracked skills are comprehensible. The intent — evidence of growth rather than points — is genuinely differentiating.

**Exact problems.**
1. `Proof profile` and `Sharky keeps proof, not points.` are internal product philosophy presented as the learner's identity (D10).
2. The `pageTitle` `Proof profile` wraps to two lines against the mascot and collides optically with the streak chip.
3. Five peer blocks: hero, `Current focus`, `Progress proof` card, four tiles inside it, rhythm bar + `View week`.
4. Four proof tiles carry equal weight, and their values do not form a story: `0 tasks complete`, `3 day streak`, `6 tracked`, `Three day rhythm` — the streak is stated **three times** on one screen (chip, tile, rhythm).
5. Five accents: blue, cyan, amber, green, teal gradient.
6. Nesting depth 3 (`card` → tile grid → tile content), plus a bordered `View week` button competing with the rhythm bar.
7. `0 tasks complete` as prominent evidence — a zero rendered at `cardTitle` weight is demotivating and is the first number the learner reads.

**Hierarchy.** Dashboard overload. Nothing is the point of the screen.
**Density.** Highest object count in the pack.
**Typography.** Wrapping title, four sizes, coloured support louder than body.
**Component consistency.** Assembled from three systems — gradient hero, bordered focus card, tile grid.
**Relation to Modern Table.** None.
**Emotional/premium.** The screen most in need of warmth and the least warm. The mascot is too small to carry identity (D9).

**Target outcome — a player-growth model, not a dashboard.**
- **Identity `hero`:** Sharky at **96**, learner name or level in learner language (`New player` → a growth stage the learner can advance: e.g. `Learning the table`), one warm `body` line about where they are. **No philosophy line. No pills.** The streak appears here **once**, as a small amber chip.
- **One current focus row** (not a card): amber leading glyph, one sentence, trailing text action `View path`. No border, no icon container.
- **Exactly two proofs, chosen for meaning, not availability:**
  - **Lessons proven** — count + world context, with a 4px bar. (When zero, phrase it as a beginning, not a deficit — and never render `0` at title scale.)
  - **Rhythm** — the streak, expressed once, with the 7-day strip.
  Two proofs side by side, no card wrapper, hairline divider between. Delete `6 tracked` and `Three day rhythm` (a duplicate of streak) — or, if skills coverage must be visible, it becomes one `support` line beneath Lessons, not a tile.
- **`View week`** becomes a text action beside the rhythm proof, not a bordered button.
- Accents after redesign: blue (progress) + amber (streak/focus) + one gradient hero. Green appears only when a proof is genuinely complete. Cyan appears only if this screen has a primary action; if it does not, **no cyan on this screen.**

**Must remain unchanged.** Streak truth, lesson counts, skill-tracking data availability, `View path` destination, `View week` destination, telemetry, any earned-achievement records.

---

### 6.7 World selection — `07_world_selection_w1_ordinary.png`

**Decision: REFINE.** Wave 2. Severity P3.

**Strengths.** Route clarity is genuinely good — current world, current mission, ordered inventory, and lock states are all unambiguous. The `In order` affordance is honest. Start CTA is obvious.

**Exact problems.**
1. The full mission card is duplicated here from Learn, above an inventory that repeats the same lesson as its first row.
2. Border-heavy and vertically dense; the world card, mission card, list card, and rows each carry outlines.
3. `Show less` / `All lessons` toggle and `In order` metadata occupy the same visual tier as section titles.
4. Locked rows are quieted only by opacity; completed and locked rows share the same container weight, so the list has no rhythm.
5. `This week, see the table before choosing.` duplicates guidance already given on Learn and Practice.

**Hierarchy.** Acceptable but flat — the current item does not stand out enough from its inventory.
**Density.** High but scannable.
**Typography.** Same tracked-eyebrow and multi-size issues as Learn.
**Component consistency.** Shares Learn's grammar, which means it inherits Learn's defects.
**Relation to Modern Table.** Distant.
**Emotional/premium.** Functional. Not the screen to spend refinement on.

**Target outcome.**
- **Do not duplicate the mission hero.** On world selection, the current mission is the **first row of the inventory, in a selected state** (§5.3 `selected`) carrying the Primary CTA inline. One representation of the current lesson on this screen, not two.
- **World context as a header line** (identical treatment to Learn, §6.2) — this shared header is one of Wave 2's reusable components.
- **Inventory rhythm:** three visually distinct row states — current (blue marker + selected fill), complete (green check, normal weight, `Replay` text action), locked (grey, lock glyph, no border, reduced row height). Group locked rows under one quiet `support` line (`6 lessons unlock as you progress`) and drop the `In order` chip.
- Remove the list card wrapper; rows on `page` with hairline dividers.
- Delete the duplicated week guidance.

**Must remain unchanged.** Route order, lock/unlock truth, world numbering, lesson names, replay availability, `Start` destination, progress percentages.

---

### 6.8 Welcome wrong feedback — `08_w1_welcome_wrong_feedback_ordinary.png`

**Decision: REFINE (to the canonical grammar).** Wave 3. Severity P3.

**Strengths.** **The semantic sequence is the best learning design in the product:** missed clue → better option → clue from table → why → what to notice next time → CTA. The table remains readable. This order must survive verbatim.

**Exact problems.**
1. The feedback content sits directly on the page background with no container, while canonical feedback (`10`) uses a bordered panel — two grammars for one semantic family.
2. A large empty gap separates the explanation from the CTA; the CTA appears detached rather than concluding.
3. `Clue from table` and the next-hand instruction are set in tracked type at `support` size — dense and hard to read (§5.1 forbids tracked sentences).
4. `Missed clue` / `Better option` are two stacked eyebrows before the answer, so the answer (`Check`) is the third thing read.
5. The feedback band's left margin does not match the table's optical centre or `page.marginH` consistently.

**Hierarchy.** The answer should win; two eyebrows precede it.
**Density.** Loose vertically, dense typographically — the inverse of what is wanted.
**Typography.** Tracked sentences; `support`-size explanation carrying primary teaching load.
**Component consistency.** Diverges from canonical feedback — the core cohesion defect of the family.
**Relation to Modern Table.** Better than theory, worse than canonical.
**Emotional/premium.** Neutral. A miss deserves warmth this screen does not provide.

**Target outcome.** Adopt the canonical feedback container and spacing verbatim (§8). Preserve semantic order exactly. Merge the two eyebrows into one amber `eyebrow` (`Missed clue`) so the answer is the second thing read. Set the explanation at `body`, untracked. Close the vertical gap: explanation → `cta.gapAbove` → bottom-sticky Primary.

**Must remain unchanged.** Semantic order, clue text, better-option identity, explanation content, next-hand instruction, `Try same clue` destination and label, table geometry, step truth.

---

### 6.9 Fresh Home — `09_learn_landing_fresh_ordinary.png` *(reclassify → `home_fresh_ordinary`)*

**Decision: REDESIGN.** Wave 2. Severity P2.

**Strengths.** Exactly one CTA. Genuinely simple. Low cognitive load at the highest-stakes moment in the product.

**Exact problems.**
1. The hero occupies the upper ~55%; the lower ~40% is undifferentiated background (D7). The most important session in the product ends in a void.
2. The mascot appears at ~40px in a chat-style header — too small to orient, and the only warmth on the screen.
3. `One tap opens the first hand chosen from your placement result.` is mechanism, not motivation, and it is the longest string on the learner's first screen.
4. `0 of 9 lessons complete` — a zero-state pill presented as status. It informs nothing and starts the relationship with a deficit.
5. `Your route is ready. Next proof starts with one clean read.` is internal vocabulary at the moment the learner most needs plain language.
6. Fresh and progressed Home differ only in strings; the same oversized-hero-plus-void structure serves both, so neither is composed for its actual moment.

**Hierarchy.** Single-focus, which is right — but unresolved, because nothing occupies or closes the lower canvas.
**Density.** Too sparse to feel authored.
**Typography.** Two body paragraphs plus a coloured proof line, all competing beneath the title.
**Component consistency.** Gradient hero + two pill styles + icon tile.
**Relation to Modern Table.** None, and this is the learner's first impression of the product's quality.
**Emotional/premium.** The single largest premium deficit in the pack, because it is first.

**Target outcome — a deliberate first session, in three bands (§5.4).**
- **Orientation:** Sharky at **96** (orientation moment, §5.7) + one warm first-person sentence in learner language. This replaces the header avatar and both mechanism paragraphs. This is where the void becomes composition.
- **Focus:** the mission `hero` — eyebrow (`Start here`), `pageTitle` mission name, one `body` benefit line, one Primary CTA. **No pills at all in the fresh state.** A zero count is not status.
- **Horizon:** one quiet `support` line naming what the first session leads to (e.g. `9 lessons in Poker from Zero`) — one line, no card, no bar, no pill.
- Focus band optically centred in the space remaining after orientation; horizon pinned above the tab bar. No additional cards, ever.

**Must remain unchanged.** Single-CTA discipline, CTA destination and placement logic, mission selection from placement result, lesson counts and world identity, `Today n/m` header truth, telemetry.

---

### 6.10 Canonical W1 wrong feedback — `10_w1_canonical_wrong_feedback_ordinary.png`

**Decision: KEEP WITH REFINEMENT — this is the semantic reference for the entire feedback family.** Wave 3. Severity P3.

**Strengths.** Strongest captured runner screen and the only place where table and learning layer read as one product. Complete clue, complete explanation, next-hand instruction, bottom-safe CTA. Table state (highlighted board cards, highlighted `CO`, `BB Big blind` / `SB Small blind` expansions) is doing genuine teaching work.

**Exact problems.**
1. The lower panel is text-heavy: eyebrow + answer + clue block + two tracked paragraphs.
2. Label tracking is excessive (`Clue from table`, and the next-hand sentence is fully tracked).
3. The in-table status pill `Read hand, board, pot` sits centred over the board and competes with the board cards it refers to.
4. The panel's border plus the page divider double-separate the same boundary.
5. `Missed clue` is styled identically to `08`'s `Missed clue` while the containers differ — same label, different grammar.

**Hierarchy.** Nearly correct. Answer wins after one eyebrow; only tracking and paragraph mass hold it back.
**Density.** Acceptable; typographic density is the issue.
**Typography.** Tracked sentences and tracked labels are the only substantive defect.
**Component consistency.** This is the target the others move toward.
**Relation to Modern Table.** Best integration in the product. Protect it.
**Emotional/premium.** Highest in the pack. Confirms the system can be premium once grammar is unified.

**Target outcome.** Keep the container, spacing, order, and CTA placement as the canonical feedback panel. Apply §5.1: remove all sentence tracking, set the explanation at `body`, set `Clue from table` as an untracked `label` inside a `nested` block. Remove the panel border **or** the page divider — one boundary, not two. Reposition or de-emphasise the `Read hand, board, pot` pill so it does not overlay the board (position change only — **no geometry change**); if it cannot be moved without touching protected geometry, reduce its fill opacity and defer relocation to a table-owned ticket outside this stage.

**Must remain unchanged.** Table geometry and all seat/card/chip/pot rendering, board highlight semantics, seat-label expansion behaviour, `Step n/m` truth, semantic order, clue and explanation content, `See my start` label and destination, bottom-safe CTA placement.

---

## 7. Target screen architectures

Shared shell, applied to all five navigation surfaces:

**Persistent header** — `Today n/m` (left, `label`) + streak chip (right, amber). Height fixed, respects top inset, hairline bottom divider. No titles, no mascot, no overflow menu.
**Page title band** — `pageTitle` + optional single `support` line. One per screen. Absent where a `hero` carries the title (Home).
**Content bands** — maximum three titled sections, `section.gap` between.
**Tab bar** — unchanged information architecture; active tab in electric blue; badge dot amber only when a real repair is due.

### 7.1 Home

Answers, in reading order: *What do I do now?* → *Why is it useful?* → *What progress matters?* → *What is secondary?*

| Band | Fresh | Progressed |
|---|---|---|
| Orientation | Sharky 96 + one warm sentence | Omitted (or Sharky 40 inline in the mission eyebrow when a streak/repair exists) |
| Focus | Mission `hero`: eyebrow `Start here`, mission name, one benefit line, Primary CTA. **No pills.** | Mission `hero`: eyebrow `Today`, mission name, one benefit line, **max one pill**, Primary CTA |
| Progress | Omitted (nothing to show) | One row: world + 4px bar + one percentage |
| Continuation | One `support` horizon line | One row: next step (`Practice · 0/3`) or the open repair (amber), with chevron |

Deleted from Home permanently: the chat-style Sharky header, mechanism copy, route-proof lines, zero-state pills, the second `Today's sequence` hierarchy, and any second filled button.

### 7.2 Learn

Relationship model, stated once each, at one level each:

- **World** — header line (`W1 · Poker from Zero` + bar + one %). Never a card.
- **Mission** — the `hero`. The only large object.
- **Current step** — one `row` inside the hero, fill-differentiated, no border, no left rule.
- **Lesson inventory** — plain row list on the page background, hairline dividers, three states (current / complete / locked).
- **Lesson** — a row; opens the runner.

| Band | Fresh *(no evidence — grammar only)* | Progressed |
|---|---|---|
| Header line | World + bar at 0 (or the world name alone if 0% is meaningless) | World + bar + one % |
| Hero | First mission, eyebrow `Start here`, Primary CTA | Current mission, eyebrow `Next up`, current-step row, Primary CTA |
| Inventory | Rows, mostly locked, grouped under one quiet line | Rows, three states, one selected |

Fresh Learn **must be captured before its band contents are finalised.** Wave 2 implements the grammar; the fresh variant's content is confirmed against the new capture.

### 7.3 Practice

Priority order is the design: **active repair → recommended rep → quick session → locked inventory.**

| Band | Content |
|---|---|
| Title | `Useful reps` + one `support` line |
| Repair (when open) | One `card`, amber eyebrow, clue in one `nested` block, Primary CTA. Depth 2 max. |
| Recommended rep | One `row`: name · spots · minutes, chevron |
| Quick session | One `row`. If unavailable: grey trailing `Locked` label — **never** a gradient block with a disabled hero button |
| Locked inventory | Grey row list under one quiet line, no card wrapper |

When no repair is open, the recommended rep becomes the `card` and takes the Primary CTA. There is never more than one `card` on Practice.

### 7.4 Review

Answers exactly four questions, once each: *What did I miss?* → *Why does it matter?* → *What do I practise?* → *Is it proven?*

| Band | Content |
|---|---|
| Title | `Review` + amber miss-count chip |
| Repair hero | One `card`: amber eyebrow `Miss to repair`, the miss in learner language, the clue once in a `nested` block, one why-line, Sharky 40 inline, Primary CTA `Practice this spot` |
| Proof | Three-state indicator `Missed → Repairing → Proven`, one line, blue/green, no explanation |
| Empty state | One green `support` line. Nothing else. `HOW REVIEW WORKS` is deleted from the product. |

The five duplicate statements of the same instruction collapse to **two**: the miss (what) and the why-line (why). The repair instruction itself lives on the CTA.

### 7.5 You / Profile

Player growth, not a dashboard. Internal vocabulary is replaced throughout.

| Band | Content |
|---|---|
| Identity `hero` | Sharky 96, growth-stage name in learner language, one warm line, one amber streak chip |
| Focus | One row: amber glyph, one sentence, `View path` text action |
| Proof (exactly two) | **Lessons proven** (count + world + 4px bar) · **Rhythm** (streak + 7-day strip + `View week` text action) |
| Achievements | Only when genuinely earned; one row each, green. Never a placeholder tile. |

Prominence test for any proof: it must be (a) caused by the learner's effort, (b) legible without explanation, and (c) non-duplicative. `6 tracked` fails (b). `Three day rhythm` fails (c). `0 tasks complete` fails the motivation floor at title scale.

### 7.6 World selection

Route clarity preserved; repeated context and chrome removed.

| Band | Content |
|---|---|
| Header line | World identity + bar + one % (shared component with Learn) |
| Inventory | Rows only. Current row in `selected` state carrying the Primary CTA inline. Complete rows: green check + `Replay`. Locked rows: grey, lock glyph, reduced height, grouped under one quiet line. |

No mission hero. No list card wrapper. No `In order` chip. No week-guidance sentence.

### 7.7 Runner theory

Three fixed bands — **Stage / Teaching rail / Advance** — as specified in §6.1. The rail's height is fixed across steps so the table never shifts between steps of a lesson. One back affordance (top-left). No street-name duplication. Protected table geometry untouched.

### 7.8 Feedback family

See §8. Canonical W1 feedback (`10`) is the reference; all other states inherit its container, spacing, and order.

---

## 8. Feedback-family grammar

One container, one spatial order, seven state variants. States that carry different learning meaning stay visually distinct **in accent and eyebrow only** — never in layout.

### 8.1 The canonical panel

Derived from `10_w1_canonical_wrong_feedback_ordinary.png`, which is the reference implementation.

```
┌─ Stage ────────────────────────────────┐
│  Modern Table — protected geometry     │
│  state highlights per learning meaning │
└────────────────────────────────────────┘
   one boundary only (divider OR border)
┌─ Feedback panel ───────────────────────┐
│  [accent] eyebrow            ← state   │
│  Answer / outcome     (cardTitle)      │
│  ┌ nested ─────────────────────────┐   │
│  │ Clue from table: <clue>         │   │  ← exactly once, untracked
│  └─────────────────────────────────┘   │
│  Why      (body, ≤2 lines, untracked)  │
│  Next time (support, ≤1 line)          │
└────────────────────────────────────────┘
   cta.gapAbove
[ Primary CTA — full width, bottom-safe ]
```

**Invariant order:** eyebrow → answer → clue → why → next time → CTA. This order is protected learning semantics and may not be reordered, merged, or conditionally hidden except where a state genuinely has no clue (correct feedback).

**Invariants across all states:** one container, one boundary, `page.marginH` left edge shared with the table's optical centre line, `body` untracked explanation, one Primary CTA bottom-sticky, table geometry unchanged, `Step n/m` visible and truthful.

### 8.2 State variants

| State | Eyebrow (sentence case) | Accent | Clue block | CTA (label owned by product copy) | Mascot |
|---|---|---|---|---|---|
| **Welcome (first miss)** | `Missed clue` | Amber | Yes | Retry the same clue | No |
| **Correct** | `Clean read` | Green | Only if a clue names *why* it was right | Continue | No |
| **Wrong (canonical)** | `Missed clue` | Amber | Yes | See my start / Continue | No |
| **Repair** | `Repair this clue` | Amber | Yes — the same clue, verbatim | Practise it | Sharky 40 inline |
| **Recheck** | `Recheck` | Blue | Yes — same clue | Choose | No |
| **Receipt** | `Repaired` | Green | Clue restated as proven | Continue | Sharky 40 inline |
| **Payoff** | `Proven` | Green | Replaced by the proof summary | Continue | **Sharky 160** |

**Distinctions preserved:** amber = something to fix; blue = you are being asked again; green = proven. Repair and recheck are separate states with separate eyebrows and accents — they may not be flattened into one screen.

**Distinctions removed:** container differences, spacing differences, tracking differences, and the double-eyebrow pattern on welcome feedback. Welcome feedback is not a different design; it is the canonical panel in its first-miss state.

**Payoff** is the only feedback state permitted to break the panel's proportions: Sharky at 160, `display` type, and M4 proof-stamp motion. It is the single loud moment in the product and must remain rare.

**Evidence gate:** repair, recheck, receipt, and payoff are uncaptured. Wave 3 implements them **against this grammar** and cannot be accepted until each is captured on current main via the ordinary route.

---

## 9. Mascot role

Full specification in §5.7. Summary of the adjudication:

- **Five moments only:** orientation, encouragement, repair, achievement, identity.
- **Three sizes only:** 40 (inline avatar), 96 (hero), 160 (celebration).
- **Sharky is a coach, not a brand ornament.** He appears where the learner needs a human presence — starting, struggling, succeeding — and nowhere else.
- **Current state is wrong in both directions:** present as 40px decoration on Home (retire), absent from Review's repair moment (add at 40), and undersized at the two places identity is actually formed — first-session Home and You (raise to 96).
- **Copy contract:** Sharky speaks in sentence case, first person, one sentence. Mascot art and an explanatory paragraph never share a block — if the block needs a paragraph, Sharky is not in that block.
- **Prohibited:** tab bar, list rows, any runner state while the table is on screen (except the 160 payoff moment, which has no table), Practice, Learn, more than once per screen.

---

## 10. Motion principles

Full specification in §5.8. Five patterns: **M1 route advance, M2 feedback reveal, M3 progress commit, M4 proof stamp, M5 clue focus.** Nothing loops. Nothing enters uncaused. The table never animates for aesthetic reasons. Motion is designed and accepted in Wave 3 only, after static hierarchy is signed off, and only against real motion evidence — which does not currently exist.

---

## 11. Three-wave implementation plan

### Wave 1 — Visual Foundation

**Goal.** Ship the token and component layer so that no later screen work requires a local aesthetic decision. Independently mergeable with **no broad screen redesign**.

**Included.** Typography roles and rules (§5.1) · colour roles and per-screen ceilings (§5.2) · surface grammar + nesting law (§5.3) · spacing scale and compact rules (§5.4) · CTA tiers (§5.5) · icon set and ceilings (§5.6) · mascot size ladder and slots (§5.7) · shared components: persistent header, page title band, world header line, state row (current/complete/locked), pill, progress bar, three-state proof indicator, canonical feedback panel shell · **the Practice truncation fix** (root cause: tracked sentence style) · explicit protected Modern Table contract recorded in code comments or docs.

**Excluded.** Every screen architecture change. Every content or copy rewrite beyond deleting strings that the nesting/typography rules make unrenderable. Motion. Mascot art changes.

**Visual DoD.** Tokens exist and are referenced (no new hard-coded values) · no all-caps outside protected table chrome · no positive tracking on any sentence · one 700-weight element per screen · nesting depth ≤2 with no bordered-in-bordered container anywhere · exactly one cyan-filled control per screen · ≤3 accents per screen (cyan + 2) · no gradient outside a single `hero` · one shadow level, on `hero` only.

**UX DoD.** No text truncation on any captured screen at 1.0× and 1.4× · all tap targets ≥44 · bottom CTAs respect safe area + 12 · primary action reachable within one scroll on every navigation surface.

**Regression protections.** Modern Table geometry byte-identical in rendering terms · route order, lock truth, progression, telemetry, and content strings unchanged except the specific deletions listed per screen · no dependency added · deterministic behaviour preserved · learning semantics untouched.

**Required screenshots (current main, ordinary route, Simulator, system fonts).** All 10 census states re-captured at 1.0×, plus Practice and Review at 1.4×, plus the corrected `home_fresh_ordinary` label.

**Likely shared component owners.** Design-system/theme layer (typography, colour, spacing) · shared widgets (header, title band, world header line, state row, pill, progress bar, CTA tiers, feedback panel shell) · Modern Table contract doc.

**Maximum PR decomposition (5).** (1) Type + colour tokens. (2) Spacing + surface/nesting grammar. (3) CTA tiers + icon normalisation. (4) Shared components incl. feedback panel shell. (5) Truncation fix + 1.4× pass.

**Stop conditions.** Any Modern Table geometry diff · any learning-semantics or route change · any new hue, size, or spacing value not in §5 · scope creep into screen layout.

---

### Wave 2 — Navigation Surfaces

**Goal.** One coherent product shell: Home, Learn, Practice, Review, You, world selection all speaking the table's language, each with one first glance and one action.

**Included.** Home fresh + progressed (§7.1) · Learn progressed, and Learn fresh **grammar only** pending capture (§7.2) · Practice (§7.3) · Review (§7.4) · You (§7.5) · world selection (§7.6) · internal-vocabulary replacement on Home, Practice, Review, You · mascot slots at orientation, encouragement, repair, identity.

**Excluded.** Runner, theory, decisions, feedback, repair/recheck, payoff, Practice-next, motion, table changes, new content.

**Visual DoD.** Every navigation surface has exactly one object winning the first glance · ≤3 titled sections per screen · Home shows ≤1 pill (0 when fresh) · Review contains ≤2 statements of the same instruction · You shows exactly 2 proofs · world selection shows the current lesson once · no duplicated percentage or streak on any screen · no disabled control larger than a row · every screen passes the §5 ceilings.

**UX DoD.** Every screen answers its assigned questions (§7) in reading order · primary action reachable without scrolling on Home, Learn, Practice, Review · empty states composed in three bands, never top-pinned above a void · zero states never render a bare `0` at title scale · locked content understandable without an explanatory sentence.

**Regression protections.** Navigation IA unchanged (5 tabs, same destinations) · route order and lock truth unchanged · all counts, percentages, streaks, and miss counts numerically identical to baseline · telemetry event points preserved (deleted UI must not delete its event) · payoff policy untouched · deterministic behaviour preserved.

**Required screenshots.** Home fresh + progressed · Learn fresh (**new capture required**) + progressed · Practice with and without an open repair · Review with a miss and empty · You at 0-progress and progressed · world selection W1 · all at 1.0×, and Review + Practice + You at 1.4×.

**Likely shared component owners.** Home/Learn/Practice/Review/Profile view layers · shared world header line · state row · proof indicator · mascot slot widget · copy layer (learner-language replacements).

**Maximum PR decomposition (6).** (1) Home fresh + progressed. (2) Learn progressed + shared world header. (3) World selection (reuses Learn's header + rows). (4) Practice. (5) Review + proof indicator. (6) You + mascot slots + copy replacement.

**Stop conditions.** Any screen requiring a fourth titled section · any new card introduced · any attempt to finalise Fresh Learn without its capture · any numeric or route drift from baseline · any telemetry event lost with its UI.

---

### Wave 3 — Runner / Feedback / Payoff

**Goal.** Join the runner and feedback family to the shell, using canonical W1 feedback as the reference, and specify motion once the static system is stable.

**Included.** Runner theory teaching stage (§7.7) · decision-state chrome alignment to the panel grammar · welcome feedback → canonical (§8) · correct feedback · repair · recheck · receipt · payoff · Practice-next transition · focused drill continuity · motion M1–M5.

**Excluded.** Modern Table geometry · poker content · learning semantics · route order · payoff policy · any new world or lesson.

**Visual DoD.** All seven feedback states use one container, one boundary, one spatial order · no sentence tracking anywhere in the runner · one back affordance per runner screen · theory rail height fixed across steps (table does not shift) · exactly one Primary CTA per runner screen, bottom-safe · payoff is the only `display`-scale moment and the only 160px mascot · ≤5 motion patterns implemented, none looping.

**UX DoD.** Welcome and canonical feedback are indistinguishable in layout and distinguishable only by eyebrow + accent · repair and recheck remain semantically distinct · the clue string appears exactly once per feedback screen · every runner CTA reachable one-handed above the safe area · 1.4× renders every mandatory string in full on feedback and payoff.

**Regression protections.** Table geometry unchanged (verified against baseline rasters) · feedback semantic order unchanged · step counts and progress truth unchanged · repair/recheck/receipt semantics unchanged · payoff policy unchanged · telemetry preserved · no motion on table geometry.

**Required screenshots — Wave 3 acceptance gate (hard, blocking).**
1. W1 runner theory (new composition) · 2. W1 standard decision · 3. W1 correct feedback · 4. W1 welcome wrong feedback · 5. W1 canonical wrong feedback · 6. **W1 repair** · 7. **W1 recheck** · 8. **W1 recheck receipt** · 9. **Real Learning Run payoff** · 10. **Practice-next transition** · 11. **One W3 or W4 representative** (Position or Price) · 12. **Focused W4 drill** · 13. **W1 feedback at 1.4×** · 14. **Payoff at 1.4×** · 15. Motion capture (screen recording) for M1–M5.

Items 6–12, 13–14 do not exist today. **Wave 3 may be implemented against §8's grammar but may not be accepted until they are captured on current main via the ordinary route — no proxies, no harness states, no fixtures.**

**Likely shared component owners.** Runner shell · theory stage · feedback panel (Wave 1 shell, Wave 3 states) · payoff view · motion/animation layer · Practice-next transition owner.

**Maximum PR decomposition (6).** (1) Theory stage + back-control removal. (2) Feedback panel states: welcome + correct + canonical. (3) Repair + recheck + receipt. (4) Payoff + mascot 160. (5) Practice-next + focused drill continuity. (6) Motion M1–M5.

**Stop conditions.** Any table geometry diff · any feedback-order change · any flattening of repair/recheck · acceptance attempted without the 15 captures · motion added before static sign-off · more than five motion patterns.

---

## 12. Must-fix / refine / optional / deferred ledger

### 12.1 Must-fix for visual cohesion (blocking)

| # | Finding | Screens | Wave |
|---|---|---|---|
| MF1 | Practice line clipped at right edge (`Before choosing, check whether a bet i…`) | Practice | 1 |
| MF2 | Positive tracking on full sentences | Practice, Home, Review, both feedback states | 1 |
| MF3 | All-caps tracked headings | Review (4 instances) | 1 |
| MF4 | Bordered container inside bordered container (nesting >2) | Practice, Review, Learn, You, world selection | 1 |
| MF5 | More than three accents on one screen | Practice (5), You (5) | 1 |
| MF6 | Disabled control styled as a hero (gradient + hero-scale button) | Practice `Later` | 1 |
| MF7 | Two back affordances in one viewport | Runner theory | 3 |
| MF8 | Welcome and canonical feedback use different containers for one semantic family | Feedback family | 3 |
| MF9 | Two competing hierarchies on Home (hero + `Today's sequence`) | Home progressed | 2 |
| MF10 | Current lesson represented twice on one screen | Learn, world selection | 2 |
| MF11 | Streak stated three times on one screen | You | 2 |
| MF12 | Internal vocabulary as learner-facing copy | Home, Practice, Review, You | 2 |
| MF13 | Undifferentiated empty lower canvas on the learner's first screen | Fresh Home | 2 |
| MF14 | `09` mislabelled as Fresh Learn; a real Fresh Learn does not exist | Evidence | 1 (relabel) / 2 (capture) |

### 12.2 High-value refinement

| # | Finding | Screens | Wave |
|---|---|---|---|
| HV1 | Reduce Review to one repair + one proof layer; delete `HOW REVIEW WORKS` | Review | 2 |
| HV2 | You → two meaningful proofs, mascot at 96, growth language | You | 2 |
| HV3 | World context becomes a header line, not a card (shared component) | Learn, world selection | 2 |
| HV4 | Lesson inventory → plain rows with three distinct states | Learn, world selection | 2 |
| HV5 | Runner theory teaching-stage composition with fixed rail height | Theory | 3 |
| HV6 | Sharky at the repair moment (Review, 40 inline) | Review | 2 |
| HV7 | Sharky at 96 for orientation and identity | Fresh Home, You | 2 |
| HV8 | Icon-container ceiling; delete decorative icon tiles | Practice, Review, You | 1 |
| HV9 | One boundary between table and feedback panel (not border + divider) | Canonical feedback | 3 |
| HV10 | Single progress representation per screen (one bar, one numeral) | Learn, Home, world selection | 2 |

### 12.3 Optional polish

| # | Finding | Wave |
|---|---|---|
| OP1 | Reposition the `Read hand, board, pot` table pill off the board | 3, if achievable without geometry change |
| OP2 | 7-day rhythm strip visual refinement on You | 2 |
| OP3 | Row-press feedback states across navigation surfaces | 2 |
| OP4 | Replay affordance styling on completed lessons | 2 |
| OP5 | Tab-bar badge dot timing/appearance | 2 |
| OP6 | Micro-refinement of `Step n/m` treatment in the runner header | 3 |

### 12.4 Deferred (out of this stage)

| # | Item | Reason |
|---|---|---|
| DF1 | W3–W12 world-specific visual identity | No evidence; worlds locked |
| DF2 | 1.4× beyond the DoD checks | Requires dedicated accessibility pass |
| DF3 | Landscape / tablet / large-phone layouts | Out of scope; compact phone is the target |
| DF4 | Sharky illustration set expansion (new poses/expressions) | Image generation forbidden; needs an art brief |
| DF5 | Dark/light theming | Product is dark-native; no request |
| DF6 | Sound and haptics | No evidence, no request |
| DF7 | Modern Table internal redesign | Protected |
| DF8 | Content expansion of any kind | Explicitly out of stage |

---

## 13. Acceptance protocol

**Evidence standard.** Current-main iOS Simulator captures, iPhone 11 Pro T5 Compact class, system fonts, ordinary production route, 1.0× plus specified 1.4× states. No harness proxies, no direct state mutation, no fixtures, no legacy fast routes, no capture-only sources. A state that cannot be reached by the ordinary route is **not accepted** — it is captured or it is deferred.

**Per-wave gate.** A wave is accepted only when all of: required screenshots exist for that wave · every Visual DoD item verifies against those screenshots · every UX DoD item verifies · regression protections verify against baseline `fba56cf3` · and a mechanical §5 conformance pass returns clean.

**Mechanical conformance checklist (run per screen, every wave):**
1. Count 700-weight elements → must be ≤1.
2. Count type sizes above `body` → must be ≤3.
3. Count cyan-filled controls → must be exactly 1 (or 0 if the screen has no primary action).
4. Count accents besides cyan/greys → must be ≤2.
5. Count gradient objects → must be ≤1, on `hero` only.
6. Measure container nesting depth → must be ≤2, with no bordered-in-bordered.
7. Count status pills → ≤2 per container, ≤4 per screen; Home progressed ≤1; Home fresh 0.
8. Count icon containers → ≤2; distinct icon shapes → ≤3 plus nav.
9. Search for all-caps outside the table → must be 0.
10. Search for positive tracking on strings >3 words → must be 0.
11. Check every string renders in full at 1.0× and 1.4× → 0 truncations.
12. Check tap targets ≥44 and bottom CTA ≥ safe area + 12.
13. Count titled sections → ≤3.
14. Diff all numerals against baseline → identical.

**Corrective passes.** One corrective pass per wave. If a second corrective pass is required, the wave stops and the owner decides scope, not the implementer.

**Freeze.** After Wave 3 acceptance, `FINAL_PRODUCT_VISUAL_COHESION_V1` freezes. Further visual change requires a new stage with new evidence. Human/device acceptance on real hardware remains a separate gate after visual convergence.

---

## 14. Protected non-changes

Preserved unless a *separately proven* regression, evidenced on current main, justifies otherwise:

1. **Modern Table internals and geometry** — seat positions, table shape and material, card rendering, chip and pot chrome, street tokens, board and seat highlight semantics. Position/opacity of the overlaid status pill (OP1) is the only permitted discussion, and only if geometry is untouched.
2. **Poker content** — every hand, board, position, sizing, and clue string.
3. **Route order** — world, lesson, and step sequence; lock and unlock truth.
4. **Learning semantics** — miss → repair → recheck → proof; the feedback order in §8.1; repair and recheck as distinct states.
5. **Progression** — counts, percentages, streaks, completion records, all numerically identical.
6. **Payoff policy** — when payoff occurs and what it grants.
7. **Telemetry** — every event point. Deleting a UI element must not delete its event; re-attach it.
8. **Navigation information architecture** — five tabs, same names, same destinations.
9. **Dependencies** — no new packages for visual work.
10. **Deterministic behaviour** — identical inputs produce identical states and identical captures.
11. **Single-CTA discipline and bottom-safe CTA placement** — already correct; keep.
12. **Canonical W1 feedback's semantic sequence** — protected verbatim.
13. **`Step n/m` truth** in the runner.

---

## 15. Risks and anti-patterns

### Risks

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | **Subtraction is read as feature loss.** Deleting pills, labels, and explanations will feel like removing information. | High | High | The ledger (§12) names every deletion explicitly. Nothing is deleted that a numeral or state glyph does not already say. Owner signs the deletions in Wave 1. |
| R2 | **Telemetry lost with deleted UI.** | Medium | **Highest** | Wave DoD requires an event-point audit per deleted element. This is the single highest implementation risk. |
| R3 | **Wave 2 drifts into content rewriting.** | High | Medium | Copy changes are limited to internal-vocabulary replacement and deletion of duplicated strings. New copy requires owner approval. |
| R4 | **Wave 3 accepted on missing evidence.** | Medium | High | Hard gate: 15 captures. No proxies. |
| R5 | **Modern Table touched while "aligning" the runner.** | Medium | High | §14.1 + geometry diff against baseline rasters in Wave 3 DoD. |
| R6 | **Token layer forked** (new values added alongside existing Flutter tokens). | Medium | Medium | Wave 1 DoD: no new hard-coded values; relationships mapped onto existing tokens. |
| R7 | **1.4× breaks the new tighter compositions.** | Medium | Medium | 1.4× is in Wave 1 and Wave 3 DoD, not deferred to the end. |
| R8 | **Fresh Learn built on an assumption** because `09` was mislabelled. | Medium | Medium | Wave 2 implements grammar only; content confirmed against a new capture. |
| R9 | **Three waves become five.** | Medium | High | One corrective pass per wave; second pass escalates to the owner. |

### Anti-patterns — explicitly forbidden in this stage

- "Make it cleaner" as an instruction, or any change not traceable to a §4 principle and a §12 ledger row.
- Trend-driven redesign; adopting another product's structure. **Do not copy Duolingo or any competitor's model, layout, or mascot behaviour.** Sharky's role in §5.7 is derived from this product's own learning loop.
- Glassmorphism, blur panels, frosted overlays.
- Gamification for its own sake: XP, gems, leaderboards, badge walls, celebratory loops. Proof of learning is the reward model and it already exists.
- Decorative gradients; gradients without the semantic role defined in §5.2.
- **Adding cards.** Every wave should end with fewer containers than it started with.
- Replacing clarity with spectacle; animating to appear premium.
- Fixing density by shrinking type, tightening line-height, or letter-spacing text to fit. Cut words instead.
- Zero-states presented as deficits (`0 tasks complete` at title scale).
- Surfacing the team's model of the system as the learner's model of themselves.
- Adding the mascot anywhere outside the five defined moments.

---

## 16. Final owner decision recommendation

**Recommendation: proceed with Path B as a strictly finite three-wave stage, and start Wave 1 immediately.**

Path B is justified — but not because the screens are ugly. It is justified because the product has **three visual grammars and no arbitration between them**, and that is a systemic defect no amount of per-screen polish will resolve. The evidence supports this conclusion with high confidence across all ten captures.

Equally, Path B must be **bounded**, because the product's learning design is its strongest asset and is scored highest in both audits (7.5/10). The risk in this stage is not under-ambition; it is a redesign that damages learning clarity while chasing premium feel. Hence: subtraction over addition, one grammar imposed by the table, protected non-changes enforced mechanically, and a hard evidence gate on Wave 3.

**Owner decisions required now:**

1. **Approve the deletion list** in §12.1–§12.2 — specifically: `HOW REVIEW WORKS`, the `Today's sequence` block on Home, the gradient `Later` block on Practice, the duplicated mission card on world selection, and the `6 tracked` / `Three day rhythm` proofs on You. These are the changes most likely to be contested later.
2. **Approve the internal-vocabulary replacement** on Home, Practice, Review, and You ("Proof profile", "route proof", "locked inventory", "0 tasks complete"), and assign a copy owner.
3. **Authorise the missing-evidence capture run** for the 15 Wave 3 states — or accept that Wave 3 cannot be accepted this stage.
4. **Confirm Wave 1 ships alone**, before any screen work, and that no screen PR may hard-code a value outside §5.
5. **Confirm the freeze commitment:** three waves, one corrective pass each, then `FINAL_PRODUCT_VISUAL_COHESION_V1` closes.

**Expected outcome.** Overall visual maturity 6.1 → **8.5**; premium impression 5.7 → **8.5**; cross-screen consistency 5.9 → **9.0**; learning clarity held at **≥7.5** and expected to rise to ~8.5 as duplicated instruction is removed.

**Next executing agent:** Codex, on Wave 1 only, with this document as the sole visual authority.

---

## OWNER_EXECUTION_ADJUDICATION

The global conformance statements in this authority are not permission to
redesign every screen during Wave 1. Wave 1 owns semantic token consolidation,
typography roles, colour-role aliases, spacing relationships, surface grammar
contracts, CTA and icon contracts, shared primitive ownership, regression
guards, an exact Practice truncation diagnosis and repair only when reproduced,
and targeted Simulator evidence.

Wave 1 does not own Home, Learn, Practice architecture beyond an exact
reproduced truncation repair, Review, You/Profile, world selection, section
deletion, learner-copy replacement, Sharky placement, runner composition,
feedback migration, payoff, Practice-next, or motion. Screen-level ceilings,
nested-container rules, gradient and pill rules, and learner-vocabulary
replacement are binding only for newly created or modified shared primitives,
directly touched reference surfaces, and untouched-screen non-regression; full
acceptance applies when the relevant screen is migrated in Wave 2 or Wave 3.

Do not create speculative unused component abstractions. A shared primitive
may be introduced or extracted only when it has an existing live owner, at
least two live consumers migrate in the same bounded PR, or it removes an
existing duplicated implementation safely. Modern Table internals and
geometry; learning semantics, content, route order, progression, payoff
policy, telemetry, navigation IA, dependencies, and deterministic behaviour
remain protected. Full Atlas refresh, Human QA, and Human Proven status are not
authorized by Wave 1.

---

## Appendix A — Completion packet

| Item | Value |
|---|---|
| Terminal verdict | **OPEN_FINAL_VISUAL_COHESION — Path B justified, three waves, then freeze** |
| Output file | `FINAL_PRODUCT_VISUAL_COHESION_DESIGN_AUTHORITY_v1.md` |
| Current maturity | **6.1/10** (premium 5.7 · learning clarity 7.5 · cross-screen consistency 5.9) |
| Target maturity | **8.5/10** (premium 8.5 · learning clarity ≥7.5 · cross-screen consistency 9.0) |
| Strongest retained surfaces | Modern Table (geometry + material); canonical W1 wrong feedback (semantic reference); the single-cyan-CTA pattern; "Useful reps" as a concept; repair-before-browse priority |
| Surfaces to redesign | Progressed Home; Fresh Home; Review; You/Profile; runner theory composition |
| Surfaces to refine | Progressed Learn; Practice; world selection; welcome feedback; canonical feedback (typography only) |
| Principal design-system changes | Five semantic colour roles with per-screen ceilings; nesting law (depth ≤2, no bordered-in-bordered); all-caps banned outside the table; no positive tracking on sentences; three-tier CTA with exactly one cyan fill per screen; one gradient on `hero` only; five mascot moments and three mascot sizes; five motion patterns |
| Waves | **3** — Foundation · Navigation Surfaces · Runner/Feedback/Payoff |
| Evidence gaps affecting Wave 3 | True Fresh Learn; W1 repair; W1 recheck; W1 recheck receipt; real payoff; Practice-next; W3/W4 representative; focused W4 drill; 1.4× feedback and payoff; all motion |
| Protected non-changes | Modern Table internals/geometry; poker content; route order; learning semantics; progression; payoff policy; telemetry; navigation IA; dependencies; deterministic behaviour |
| Highest implementation risk | **Telemetry event points lost together with deleted UI elements** (R2) |
| Recommended next agent | Codex — Wave 1 only |
| Recommended model / effort | Codex, high reasoning effort; Goal Mode off; one wave per session; one corrective pass maximum |
| Owner decision required | Approve the deletion list, the vocabulary replacement, the Wave 3 capture run, Wave-1-ships-alone, and the freeze commitment (§16) |
| Elapsed | Single design session; document produced in one pass from the supplied census and audit (not independently wall-clock timed) |
