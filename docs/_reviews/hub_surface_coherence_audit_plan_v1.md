---
status: "docs-only audit. No source changes in this wave"
status_source: "derived"
generated_by: "docs_frontmatter_v1"
---

# Hub Surface Coherence Audit / Plan v1

Status: docs-only audit. No source changes in this wave.

## Executive verdict

Terminal verdict:
`hub_surface_coherence_audit_complete_ready_for_learn_worlds_coherence_pass`

The owner's Learn/Worlds duplication concern is **confirmed and sharper than
stated**: the Learn screen stacks four distinct "where am I in the
world/path" framings in a single scroll (a mini world-progress card with a
map-icon button, a "Foundation map" chip strip, a "Journey preview" /
"View path" list, and the full Worlds menu overlay one tap away), all
co-located within a few hundred pixels. This is real, screenshot-confirmed
role overlap, not a false alarm.

The owner's Profile/You "not enough proof" concern is **not confirmed** by
evidence. Profile is the single densest proof surface in the app (hero
"Proof profile" card, "Recent route proof" line, a 2x2 "Progress proof"
stat grid, and an "Earned moments" section below the fold) — the real,
already-known issue (matches the accepted master-backlog MB-024) is that
this proof is presented as generic stat tiles, not that there isn't enough
of it.

The owner's "Home may feel empty" concern is **partially confirmed but
narrower than stated**: Home's first viewport is not structurally sparse
(strong hero card + 3-step daily sequence), but in its default,
not-yet-done state it shows zero backward-looking proof or momentum
signal — every line is forward-looking task copy. That is a real, smaller
gap than "empty."

Practice and Review both hold up well against the matrix: single clear
job, visible first-viewport CTA, evidence-backed copy. Their known issues
(Practice's locked-grid sparseness, Review's bottom dead space) are minor
or already tracked elsewhere.

## Source files inspected

- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart` (targeted sections: build
  method, mission command card, checklist/daily-plan card)
- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart` (targeted sections:
  `_FoundationProofCardV1`, world-menu button/header row,
  `_JourneyPreviewV5`, `_WorldMenuOverlayV1`)
- `lib/ui_v2/act0_shell/act0_play_shell_v1.dart` (key/section inventory via
  targeted grep only)
- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart` (key/section inventory
  via targeted grep only)
- `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart` (targeted sections:
  `_ProfileEvidenceSignalV1`, `_ProfileStorySupportBandV1`, section-key
  inventory via targeted grep)
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart` (targeted:
  `onOpenWorldMenu`/`_showWorldMenu` wiring only, to confirm the Worlds
  button opens an in-shell overlay, not a separate route)
- `docs/_reviews/sharky_10_10_master_backlog_and_direction_plan_v1.md`
  (cross-checked findings against MB-015, MB-016, MB-023, MB-024 to avoid
  re-opening already-accepted findings as new)
- `docs/_reviews/design_10_10_execution_ssot_v1.md` (cross-checked active
  route / guardrails)

No archive/donor roots, no telemetry, no route/content-engine files, and no
full-file reads of the two largest shells (`act0_learn_path_shell_v1.dart`,
5831 lines; `act0_profile_shell_v1.dart`, 3503 lines) were performed —
findings for those two are based on targeted section reads plus the
screenshot evidence in Section "Evidence" below, which is sufficient to
support every claim made in this artifact.

## Surface-by-surface findings

Scored qualitatively against the 11-item matrix (clarity, actionability,
learning signal, return value, proof value, premium composition, screen
role uniqueness, overlap/duplication, first viewport strength, CTA
clarity, relationship to full route). These are working audit judgments,
not final design scores.

### Home

- Clarity: strong. Single hero answers "what do I do now" directly
  ("Today's table read" -> lesson title -> CTA).
- Actionability: strong. One primary CTA (`Continue`) plus a 3-step
  "Today's sequence" checklist with a clear "Next" pointer to Practice.
- Learning signal: present via the hero's lesson framing, but generic
  ("Sharky has one table clue ready" repeats regardless of state).
- Return value: weak in the default state. No day-2/return-specific
  language visible in this capture; the checklist is the same regardless
  of whether this is day 1 or day 30.
- Proof value: **absent in the default state.** No completed-work,
  streak, or "reads saved" signal appears anywhere in the first viewport
  or the checklist card. (Streak/proof text exists in source only for the
  post-completion "daily done" state — confirmed at
  `act0_home_shell_v1.dart:1103-1189` — so most visits to Home before
  finishing today's task show zero proof.)
- Premium composition: same rounded-card-with-icon-badge grammar as every
  other hub screen (already tracked, MB-015).
  - Screen role uniqueness: clear and distinct — Home's job ("what next")
  does not overlap with any other tab in this capture.
- Overlap/duplication: none found.
- First viewport strength: strong (hero + CTA + checklist all visible
  without scrolling on a 390x844 canvas).
- CTA clarity: strong. One primary button, unambiguous label.
- Relationship to full route: implicit only (course title + "4 of 9
  lessons complete" pill); no explicit "you are in World 1 of 12" framing
  on Home itself (that lives on Learn).

### Learn (default state)

- Clarity: mixed. The current-lesson card itself is clear, but it sits
  directly above two more path-shaped elements.
- Actionability: strong for the immediate lesson (`Start` CTA is
  unambiguous).
- Learning signal: strong ("Why it matters" / "Current step X of Y").
- Return value: moderate; "Journey preview" gives a sense of recent
  progress via checkmarks.
- Proof value: moderate (world progress bar, "4 of 9 lessons", checkmarks
  in Journey preview).
- Premium composition: same card grammar as other screens (MB-015).
- Screen role uniqueness: **compromised.** See Overlap/duplication below.
- Overlap/duplication: **confirmed, this is the core finding.** In one
  screenshot-captured scroll (`compact.learn.png`), the following four
  elements all reference "world" or "path" position within a few hundred
  pixels of each other:
  1. A "Current world · W1" mini card with a progress bar, `44%`, and a
     small blue map-icon button (`act0_shell_levels_menu_button`,
     `Icons.map_rounded`) that opens the full Worlds overlay
     (`_WorldMenuOverlayV1`).
  2. The "Foundation map" card (`_FoundationProofCardV1`,
     `act0_shell_foundation_proof`): "Worlds 1-4 support this lesson,"
     with per-world chips (W1 unlocked, W2-W4 locked).
  3. "Journey preview" / "View path" (`_JourneyPreviewV5`,
     `act0_shell_learn_v5_journey_preview`): "This week, see the table
     before choosing," an expandable list of recent/upcoming lessons with
     a `View path` / `Full journey` toggle.
  4. The Worlds overlay itself (`_WorldMenuOverlayV1`), reachable from
     (1), showing the full 12-world macro map with Volume I / Volume II
     pills.
  These are not literally the same content (verified by reading source:
  Foundation map is a static 4-chip reference to which worlds support the
  *current lesson*; Journey preview is an expandable *this-week lesson
  list*; the Worlds overlay is the real macro *all-12-worlds* map), but
  they all use "map"/"world"/"path" language and iconography in
  immediate proximity, on the same screen, in the same visit. A first-time
  user has no clear signal for which one answers "where am I in the big
  path" versus "what's coming up this week" versus "what does this lesson
  build on."
- First viewport strength: the primary lesson card is visible, but is
  immediately followed by the Foundation map card before any scrolling is
  needed, front-loading path-adjacent content ahead of the lesson's own
  supporting detail.
- CTA clarity: `Start` is clear; but there are three additional tappable
  path-related affordances above the fold (map-icon button, world chips,
  `View path` link) competing for the same conceptual space.
- Relationship to full route: strong (arguably too strong for a screen
  whose job should be "what should I do now").

### Learn (lesson-detail state)

- Same structure repeats: the "Current world · W1" mini card with the
  map-icon button appears again at the top of the lesson-detail view
  (`compact.learn_detail.png`), followed by "Journey preview" /
  `View path` again. This confirms the overlap is not a one-off — it
  recurs across at least two Learn states inspected.

### Worlds (menu overlay, opened from Learn)

- Clarity: strong for its actual job — shows Volume I/Volume II pills,
  current world, next world, and a full world list.
- Screen role uniqueness: this is the legitimate "where am I in the big
  path" surface per the owner's hypothesis. Structurally it is *not*
  duplicating Foundation map or Journey preview's content (different
  data: full 12-world list + volume framing vs. a 4-chip lesson-support
  reference vs. a this-week lesson list) — the issue is discoverability
  and naming pressure from the other three elements on Learn, not content
  duplication inside the overlay itself.
- Evidence gap: no capture lane covers this overlay (it is a runtime
  `setState` overlay, not a routed screen — same class of gap already
  documented in Wave 6A/6B for the Block Completion Shell). Not captured
  in this audit; assessed from source only.

### Practice

- Clarity: strong. "Useful reps" / "Build the read one spot at a time."
- Actionability: strong. Single `Start daily set` CTA with a real
  duration estimate (`3 spots ~3 min`).
- Learning signal: good ("One short rep keeps this table clue fresh," a
  "Repair unlocks from real misses" explainer card).
- Return value: moderate; the "Today's training" card doesn't yet
  differentiate by day (matches MB-011/return-moment debt, already
  tracked, not new here).
- Proof value: light on this screen specifically (proof lives on
  Profile/Review); acceptable given Practice's job is action, not proof.
- Premium composition: same card grammar (MB-015).
- Screen role uniqueness: clear ("do a short rep now").
- Overlap/duplication: none with Learn/Worlds. Minor overlap in spirit
  with Review (both offer "practice this spot"-style CTAs), but this is
  intentional per the accepted Miss->Repair->Proof loop, not new debt.
- First viewport strength: strong (hero card fully visible, CTA visible
  without scrolling).
- CTA clarity: strong.
- Relationship to full route: minimal, appropriately so (Practice is a
  same-day, not route-level, surface).
- Known pre-existing issue reconfirmed, not new: the "Short reps" grid
  below (Actions/Blinds/Positions/Showdown, all locked) reads sparse and
  gated (matches accepted MB-023). Not re-scored as a new finding.

### Review

- Clarity: strong. "1 miss to fix" pill + "The no-bet-yet clue is still
  the one to fix" states the job immediately.
- Actionability: strong. `Practice this spot` CTA is unambiguous.
- Learning signal: strong. "Pattern to practice" line states miss ->
  repair -> next-rep expectation in plain language.
- Return value: strong for the active-miss state; zero-state
  (`compact.review_empty.png`) is also clear and non-alarming.
- Proof value: strong ("saved read" result concept stated explicitly in
  the "How review works" strip).
- Premium composition: same card grammar (MB-015).
- Screen role uniqueness: clear and distinct from Practice (Review = "fix
  a specific real miss"; Practice = "general daily rep").
- Overlap/duplication: none found.
- First viewport strength: strong for the active-miss card; the
  zero-state screenshot shows a large empty gap between the "How review
  works" strip and the closing "Nothing else is due" line (cosmetic
  spacing, not a role/clarity problem).
- CTA clarity: strong.
- Relationship to full route: appropriately minimal (Review is same-day
  focused, correctly so).

### You / Profile

- Clarity: mixed. Header states the job well ("What Sharky can already
  prove"), but the volume of stacked proof elements (hero card, "Current
  focus" card, "Progress proof" 2x2 grid, "Earned moments" section, and
  more below the fold) makes the screen feel like several
  independently-designed proof modules rather than one coherent story.
- Actionability: moderate (`View path`, `View week` links; no single
  primary CTA the way Home/Practice/Review each have one).
- Learning signal: present but abstract ("Table sense is becoming more
  familiar" is not tied to a specific table clue the way Review's copy
  is).
- Return value: present via streak ("3 day streak") and "Current focus."
- Proof value: **high in raw quantity, contradicting the owner's stated
  premise.** Confirmed in-screenshot: "Proof profile" hero, "Recent route
  proof: Table sense is becoming more familiar," "Route on track" + "28
  tasks complete" chips, a full "Progress proof" 2x2 stat grid (Lessons /
  Rhythm / Skills / Earned), and "Earned moments" below the fold. This is
  the single most proof-dense screen among all six audited.
- Premium composition: **the real issue.** The "Progress proof" section
  is a 2x2 grid of near-identical stat tiles (icon + label + one
  number/short phrase each), and the `_ProfileEvidenceSignalV1` widget
  (source-confirmed, not this capture's default state) uses the exact
  same icon-badge + label + title + muted-body pattern as Home's mission
  card and Review's coach card. This matches the already-accepted MB-024
  ("Profile proof is a strong concept but generic in visual execution...
  reduce stat-box sameness") almost exactly — this audit reconfirms
  MB-024 is still unresolved, it does not surface a new problem.
- Screen role uniqueness: clear in principle ("this is where proof
  lives"), but diluted by proof-adjacent content also appearing on Home's
  post-completion state and Review's "saved read" language.
- Overlap/duplication: soft overlap with Home's (state-gated) proof
  language and Review's "saved read" result language; not a structural
  duplication the way Learn/Worlds is, more a "proof is scattered across
  three screens with three different visual treatments" issue.
- First viewport strength: strong (hero + focus + stat grid all visible).
- CTA clarity: weak — no single dominant action; several small links
  (`View path`, `View week`) compete.
- Relationship to full route: strong ("Current focus" ties back to the
  active lesson).

## Duplication/overlap map

| Element A | Element B | Relationship | Verdict |
| --- | --- | --- | --- |
| Learn: "Current world" mini card + map-icon button | Worlds overlay | A opens B; A is a teaser, B is the full macro map | Legitimate entry point, not duplication by itself |
| Learn: "Foundation map" chip strip | Worlds overlay | Different scope (4 chips tied to current lesson vs. full 12-world list); different job (lesson-support reference vs. route map) | Content is distinct; **naming/iconography overlap is real** (both use "map" framing) |
| Learn: "Journey preview" / "View path" | Worlds overlay | Different scope (this-week lesson list vs. full world list); "View path" label is easily confused with "the path" meaning the Worlds map | **Label collision risk** — "View path" and the Worlds map both plausibly answer "show me the path" |
| Learn: "Foundation map" | Learn: "Journey preview" | Both are supporting/reference cards stacked directly under the primary lesson card, both about "what's around this lesson" | **Redundant screen real estate**, two path-adjacent cards front-loaded before lesson-specific detail |
| Home: post-completion proof text | Profile: "Progress proof" | Both show streak/completion language, in different visual systems | Minor, state-gated overlap; not urgent |
| Profile: "Progress proof" grid | Review: "saved read" result language | Both describe "what you've proven," in different vocabularies | Minor vocabulary inconsistency (`proof` vs `saved read` vs `route proof`), not a structural duplication |

The **confirmed, actionable duplication** is inside Learn: Foundation map
and Journey preview are two separate cards doing adjacent-but-distinct
"what's around this lesson" jobs, both competing with the Worlds
button/overlay for the same "map/path" concept space, in the same screen,
in the same viewport region.

## Objective severity classification

- **P0:** none. Nothing broken, harmful, or unusable.
- **P1:** Learn screen's intra-screen map/path concept redundancy (Current
  world card + map-icon button, Foundation map, Journey preview, all
  competing for the same "where does this fit" question within one
  scroll). Real, screenshot-confirmed, and it is the most concrete,
  bounded, single-file fix among this audit's findings.
- **P2:** Home has no proof/momentum signal in its default (not-yet-done)
  state.
- **P2:** Profile's proof content is presented as generic stat tiles
  (reconfirms already-accepted MB-024; not new, but still open).
- **P3:** Practice's locked short-rep grid reads sparse/gated
  (reconfirms already-accepted MB-023; not new).
- **P3:** Review's zero-state has a large empty gap near the bottom of
  the viewport (cosmetic spacing only).
- **P4:** Container/card-grammar sameness across all six hub screens
  (reconfirms already-accepted MB-015; large, cross-cutting, not a hub-
  specific finding, best handled as its own dedicated wave if ever
  opened).

## Recommended repair order

1. Learn/Worlds coherence pass (P1) — highest-confidence, most bounded,
   single-file.
2. Home proof/momentum addition (P2) — small, additive, low risk.
3. Profile stat-tile differentiation (P2) — larger, already scoped by
   MB-024; treat as a continuation of that existing backlog item rather
   than new scope.
4. Practice/Review polish items (P3) — opportunistic, not urgent.
5. Card-grammar system pass (P4) — defer; cross-cutting, needs its own
   design-direction wave per MB-015/MB-036, not a hub-specific fix.

## Explicit decision

Recommended: **B) Learn/Worlds coherence pass.**

Rationale: it is the only finding in this audit backed by direct
screenshot evidence of *screen-role blur inside a single screen* (not just
"the app repeats a card style," which is already tracked separately as
MB-015). It is scoped to one file
(`lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`) that already owns
all three competing elements (Foundation map, Journey preview, Worlds
button/overlay), so the repair does not require touching Home, Practice,
Review, or Profile at all. A) is weaker justified by evidence (Profile
already has abundant proof; the real Profile issue is visual, matching an
already-open backlog item rather than a new urgent gap). C) is too broad
to scope safely right now and would re-open already-tracked cross-cutting
work (MB-015/MB-016) rather than close new, bounded debt. D) does not
apply — hub coherence and W11/W12 table differentiation are unrelated
systems; there is no dependency reason to defer this to that wave.

### A) Home/You proof-value pass

- Scope: add one small, honest, backward-looking proof/momentum element
  to Home's default (not-yet-done) state — for example, a single line
  referencing the most recent saved read or streak, gated to only appear
  when real data exists (no fake progress).
- Non-scope: no Profile visual redesign, no new proof data model, no
  streak/gamification mechanic changes, no stat-tile rework (that is
  MB-024's scope, not this).
- Expected EV: low-medium. Home already tests well structurally; this
  closes a real but narrow gap.
- Regression risk: low. Purely additive, single file
  (`act0_home_shell_v1.dart`), gated behind existing real data.
- Files likely touched: `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
  only.
- Screenshot evidence needed: `./tools/screen_review_fast_v1.sh core
  compact` (already the cheapest lane; re-run after change to confirm
  Home's first-viewport composition).

### B) Learn/Worlds coherence pass (recommended)

- Scope: reduce the number of distinct "map/path" framings visible in one
  Learn scroll. Concrete, bounded options (final choice belongs to a
  design pass, not this audit): (i) merge Foundation map's chip content
  into the existing "Current world" mini card instead of a separate card;
  (ii) rename "Journey preview" / "View path" to remove the word "path"
  so it does not compete linguistically with the Worlds map button; (iii)
  move Foundation map lower in scroll order, behind lesson-specific
  detail, so the primary lesson card is not immediately followed by a
  second path-adjacent card. Any one or a small combination of these,
  chosen after a quick internal design check, would materially reduce the
  confirmed overlap without touching the Worlds overlay's own content.
- Non-scope: no changes to the Worlds overlay's content or the full
  12-world macro map; no changes to route semantics, lesson content, or
  world-unlock logic; no Home/Practice/Review/Profile changes; no new
  screens.
- Expected EV: medium-high. Directly answers the owner's stated
  hypothesis ("Learn should answer 'what should I do now,' Worlds should
  answer 'where am I in the big path'") with a bounded, evidence-backed
  fix.
- Regression risk: low-medium. Single file, but a large one (5831 lines);
  existing tests likely reference the touched widget keys
  (`act0_shell_foundation_proof`, `act0_shell_learn_v5_journey_preview`,
  `act0_shell_levels_menu_button`) and would need focused review/update,
  not a rewrite.
- Files likely touched:
  `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart` only, plus
  whichever focused test file(s) reference the touched keys/copy (to be
  identified by grep at implementation time, not broad-read here).
- Screenshot evidence needed: `./tools/screen_review_fast_v1.sh core
  compact` (covers `learn` and `learn_detail`, the two states this audit
  captured evidence from); no tablet; no full pack.

### C) All-hub role definition pass

- Scope: a cross-cutting design pass defining each tab's unique opening
  composition and reducing shared card grammar (this is effectively
  MB-015 + MB-016 combined, at full scope).
- Non-scope: n/a — by definition this touches all five hub-adjacent
  shells.
- Expected EV: potentially the highest long-term, but diffuse and
  unbounded as currently scoped.
- Regression risk: high. Touches every hub screen simultaneously;
  difficult to keep bounded; high chance of scope creep beyond what a
  single wave should attempt.
- Files likely touched: all six hub shell files plus shared design
  tokens.
- Screenshot evidence needed: full `core` + `full_scroll` compact lanes,
  possibly tablet smoke.
- Recommendation: not now. Revisit only after B) is landed and evidence
  shows the narrower fix wasn't sufficient, per the Design SSOT's Section
  4 route (this would be closer to that document's item C, "all-hub role
  definition," which is explicitly listed after the currently-active
  table-escalation item, not before it).

### D) Defer until W11/W12 table differentiation

- Not recommended as a dependency. Hub surface coherence (Home / Learn /
  Worlds / Practice / Review / Profile) and W11/W12 late-route table
  differentiation are unrelated systems (confirmed via Wave 6A: the
  W11/W12 work is scoped entirely inside the table/decision-runner
  rendering path, not the hub shells). There is no technical or design
  reason one must wait for the other. If sequencing is desired for
  planning/capacity reasons, that is a scheduling choice, not a
  dependency finding from this audit.

## Return queue items — do not fix now

- Container/card-grammar sameness across all hub screens (P4, MB-015) —
  too broad for a bounded wave; needs its own design-direction pass.
- Profile stat-tile visual differentiation (P2, MB-024) — already an open
  backlog item with its own scope; do not fold into the Learn/Worlds
  pass.
- Practice locked-grid sparseness (P3, MB-023) — already tracked,
  low urgency.
- Review zero-state bottom dead space (P3) — cosmetic, opportunistic
  fix only if that screen is touched for another reason.
- Home day-2+ return-specific copy variation (implied by MB-011, not
  newly found here) — separate from the proof/momentum gap identified in
  this audit; do not conflate the two.
- Worlds overlay's own internal design (Volume I/II pills, locked-volume
  preview sheet) — not found to be a problem by this audit; no action
  needed.

## Evidence

Capture tier used: `core compact` — the existing, cheapest lane in
`tools/screen_review_fast_v1.sh` that already targets exactly the six
audited surfaces (`home`, `learn`, `learn_detail`, `practice`, `review`,
`review_empty`, `profile`). This satisfies the "only run cheap,
already-existing touched-screen lanes" constraint; no new capture tooling
was created and no tablet lane was run.

Evidence pack (local only, not committed):

`/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast`

Key screens referenced in this artifact:

- `/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/compact.home.png`
- `/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/compact.learn.png`
- `/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/compact.learn_detail.png`
- `/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/compact.practice.png`
- `/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/compact.review.png`
- `/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/compact.review_empty.png`
- `/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/compact.profile.png`

Contact sheet:

`/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/contact_sheet.png`

Open commands:

```bash
open /Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast
open /Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/contact_sheet.png
open /Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/compact.learn.png
```

**Evidence gap (documented, not filled):** the Worlds menu overlay itself
(opened via the map-icon button) is a runtime `setState` overlay, not a
routed screen, and is not covered by any existing capture lane — the same
class of gap already documented in Wave 6A/6B for the Block Completion
Shell screens. This audit's Worlds-overlay findings are source-verified
only, not screenshot-verified. A future implementation wave touching the
Worlds overlay should capture it via the same kind of one-off, no-new-
tooling approach used in Wave 6B if visual proof of that specific surface
becomes necessary.

## Validation run

- `git diff --check` - clean (docs-only change).
- `graphify hook-check` - clean (exit 0).
- `git status` - see below.

No source, test, or route files were changed. No Flutter tests were run
(not applicable to a docs-only artifact).

## Known limitations

- The two largest shell files (`act0_learn_path_shell_v1.dart`,
  `act0_profile_shell_v1.dart`) were read in targeted sections plus
  key-name inventory, not in full, per the "minimum sufficient context"
  instruction. All specific claims in this artifact are backed by either
  a direct source excerpt or a screenshot; no claim rests on an unread
  part of these files.
- Practice and Review's structural findings rest more heavily on
  screenshot evidence and key-name inventory than on source reads (per
  the mission's instruction not to over-invest in surfaces expected to be
  closer to target); their matrix scores are correspondingly less deeply
  verified than Learn/Worlds and Profile.
- No tablet evidence was captured (out of scope by mission constraint).
- No Human QA, public readiness, or launch readiness signal is available
  or claimed from this audit.

## Recommendation

Proceed to a bounded Learn/Worlds coherence pass (Decision B) as the next
implementation wave. Treat Home's proof/momentum gap (A) and Profile's
stat-tile differentiation (already MB-024) as smaller, separate,
lower-priority follow-ups, not bundled into the same wave. Do not open a
full all-hub role-definition pass (C) until B lands and its evidence is
reviewed.

## Explicit non-claims

This artifact does not claim:

- Human QA approval;
- public readiness;
- launch readiness;
- 10/10 product proof;
- durable learning effect;
- beginner mastery;
- premium commercial readiness;
- route correctness changes;
- telemetry correctness;
- W13+ activation;
- that Wave 6B (W12 terminal payoff) contains any regression — no
  evidence of one was found or looked for beyond confirming it is
  unrelated to hub surfaces;
- that Profile, Practice, or Review require urgent rework — evidence
  found them comparatively closer to target, consistent with (but not
  assumed from) the mission's own framing.
