# Wave 2.7 - Active Shell Visual Premium Proof v1

Date: 2026-06-26
Base: `origin/main` at `83ee71366264f5169fe70d0a129d7a48ee16ee09`
Verdict: `proceed_to_claude_top1_challenger`

## 1. Verdict

`proceed_to_claude_top1_challenger`

Wave 2.7 is proof-only. Fresh active-shell screenshot packets show no concrete
P1 visual premium contradiction that warrants product code changes in this
wave.

## 2. TOP1 Matrix Row Target

Primary row:

- visual premium feel

Secondary rows:

- first-start clarity
- first proof loop
- Session Summary payoff
- Practice usefulness

TOP1 bar: the active Act0 shell should feel premium, modern, poker-specific,
and calm across the learner-facing first proof loop without decorative redesign,
Modern Table reopening, fake RPG proof, or broad UI drift.

## 3. Wave Goal And Scope

Goal: prove whether the current active Act0 shell surfaces are visually premium
enough for the TOP1 route, and fix at most one small high-EV visual premium
blocker only if the proof reveals a concrete screenshot-visible issue.

Scope stayed audit/proof-only:

- refreshed active-shell screenshots;
- inspected the current `day2_return` and `first_week` compact contact sheets;
- created this visual premium verdict artifact;
- prepared Claude TOP1 Visual/UX Challenger handoff evidence.

No implementation was needed.

## 4. Screenshot Packets Run And Freshness

Required packets run:

```bash
./tools/screen_review_fast_v1.sh day2_return compact
./tools/screen_review_fast_v1.sh first_week compact
```

Both commands passed.

Fresh packet paths:

- `output/screen_review/current/day2_return_fast/`
- `output/screen_review/current/first_week_fast/`

Fresh contact sheets:

- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/contact_sheet.png`

Metadata records both generated packets from:

`83ee71366264f5169fe70d0a129d7a48ee16ee09`

`full_scroll compact` was not run. The first two packets did not reveal a broad
shell-level issue, and the review artifact / Claude handoff has enough active
first-loop evidence from day-2 return plus first-week compact packets.

## 5. Surface-by-surface Visual Premium Verdict

Home / first re-entry clarity:

- Day-2 Home has a strong single hero: `Repair one weak spot`.
- The CTA hierarchy is clear; `Practice this spot` reads as the primary action.
- The top rhythm and daily sequence support the hero without competing with it.
- Verdict: premium enough for challenger review; no P1 blocker.

Practice current-fix priority:

- The active repair target keeps the table as the product center.
- The repair label and compact proof prompt make the current fix feel specific,
  not generic.
- The screen avoids broad drill-catalog pressure.
- Verdict: useful and visually coherent; no P1 blocker.

Repair outcome / Fix landed moment:

- First-week repair result keeps the table visible and the feedback area calm.
- The local proof moment is clear without noisy celebration or fake permanent
  resolution.
- Verdict: supports premium proof loop; no P1 blocker.

Session Summary proof hero and What next:

- The proof hero is visually differentiated and reads as a real session close.
- `What next` sits in a clear supporting block below the proof hero.
- The summary is dense but no longer reads like an internal/debug shell.
- Verdict: acceptable for Wave 2.7 proof; density is a challenger question, not
  a local P1 implementation trigger.

Review proof surface:

- Review shows a single active repair and a concise `What to fix next` block.
- The surface avoids fake clearing, recovered, or durable-history claims.
- Verdict: honest and premium enough for active-shell proof; no P1 blocker.

Profile proof surface:

- Profile uses `Learning profile`, route proof, current focus, and compact
  proof cards.
- It avoids rating/radar/level-as-proof visual framing.
- The card rhythm matches the broader shell.
- Verdict: visually coherent and claim-safe; no P1 blocker.

Active shell rhythm / density / hierarchy:

- The shell uses a consistent dark premium palette, restrained blue/gold
  emphasis, table-first imagery, and calm proof cards.
- The first-loop rhythm reads as table -> clue -> repair -> proof -> next step.
- Some cards remain dense, but no surface feels broken, placeholder, debug, or
  strong-alpha in the refreshed packets.
- Verdict: proceed to external TOP1 challenger rather than local redesign.

## 6. Any P0/P1/P2 Issues Found

P0:

- None.

P1:

- None concrete enough to justify implementation in this wave.

P2 / challenger questions:

- Session Summary is still the densest surface; ask Claude whether its proof
  hero is emotionally memorable enough for TOP1.
- Profile bottom density may need later identity/reward work, but not as part of
  visual premium proof.
- The active shell is calm and coherent, but external review should judge
  whether the palette and card rhythm feel premium-public or only narrow-beta.

## 7. Implementation Summary If Any Code Changed

No product code changed.

No Dart files, tests, routes, widgets, data models, telemetry, or screenshot
tooling were modified.

## 8. Why Any Implemented Fix Supports TOP1 Visual Premium Rather Than Decoration

No fix was implemented.

Proof-only was the correct bounded outcome because the refreshed screenshots did
not reveal one concrete small blocker that met all implementation admission
criteria:

- visible in the refreshed screenshots;
- blocks the TOP1 visual premium bar;
- fixable with a small localized presentation change;
- safe without reopening Modern Table, route truth, progression, model, or
  telemetry.

## 9. Claim-safety Proof

No new visible claim copy was introduced.

The inspected packets did not require adding claim families for:

- AI;
- GTO;
- solver;
- leak fixed;
- fixed forever;
- mastered;
- cleared;
- resolved;
- recovered;
- all-time;
- rating;
- radar;
- Level / Lv as proof;
- paywall or premium pressure.

Existing packet language remains local and deterministic around table clues,
repair focus, current fix, proof, and next step.

## 10. No Route/Progression/Model/Telemetry Boundary Proof

No changes were made to:

- route or shell navigation;
- progression;
- telemetry;
- model semantics;
- repair queue resolution or clearing;
- Review clearing;
- durable all-time history;
- Modern Table;
- broad drill engine;
- W5-W36 content;
- AI coach/chat/persona;
- premium/paywall route;
- badge art;
- rating/radar/levels.

## 11. Tests And Validation Run

Screenshot proof:

- `./tools/screen_review_fast_v1.sh day2_return compact` - passed.
- `./tools/screen_review_fast_v1.sh first_week compact` - passed.

Docs/proof validation:

- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- `git status --short`

No Flutter tests were required because no product code changed.

## 12. Generated/Untracked Artifact Status

Generated local-only artifacts:

- `output/screen_review/current/day2_return_fast/`
- `output/screen_review/current/first_week_fast/`

Pre-existing/generated output remains untracked:

- `output/claude_review/`
- `output/screen_review/`

Generated screenshots and zips must not be committed.

## 13. Expected Score Movement

Expected movement is conservative because this wave proved current visual state
instead of changing product code:

- visual premium feel: `7.2-8.0` -> `7.4-8.1`
- first proof loop: `8.9-9.3` -> `8.9-9.3`
- Practice usefulness: `8.0-8.6` -> `8.1-8.7`
- Session Summary payoff: `8.4-8.9` -> `8.4-8.9`

The main value is confidence: current active-shell screenshots are fresh and
ready for an external TOP1 visual/UX challenge.

## 14. Claude TOP1 Visual/UX Challenger Readiness

Ready.

Use these fresh packet paths:

- `output/screen_review/current/day2_return_fast/`
- `output/screen_review/current/first_week_fast/`

Ask Claude to judge:

- whether the active shell feels premium-public or only beta-polished;
- whether Session Summary payoff is memorable enough;
- whether Practice feels like a real training surface;
- whether Review/Profile proof surfaces feel honest and product-grade;
- whether any one P1 visual blocker should be fixed before the next TOP1 wave.

Do not ask Claude to propose broad redesign, Modern Table changes, public
premium/paywall, AI/chat/persona, rating/radar/level systems, badge art, or
Runout/Duolingo copying.

## 15. Caveats

- This is a compact screenshot proof, not a full device-matrix visual QA pass.
- Motion and tap feel are not fully visible in static screenshots; Wave 2.6
  covered the focused interaction seams.
- External review may still find a P1 perception issue. That should be handled
  as one bounded follow-up, not as broad redesign.
- `git status` reports generated output folders as untracked because screenshot
  artifacts are local-only.

## 16. Next Recommendation

Proceed to Claude TOP1 Visual/UX Challenger using the fresh `day2_return_fast`
and `first_week_fast` packets.

If Claude finds no P0 and at most one concrete P1, move to the next TOP1 route
wave. If Claude identifies a single concrete screenshot-grounded P1, fix only
that blocker in a bounded active-shell presentation wave.
