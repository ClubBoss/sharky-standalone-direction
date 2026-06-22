# Sharky Character & Coaching Presence v1

## Scope

Audit / PIEC only after the completed first-week visual hierarchy slices.

No product UI, copy, tests, assets, animation, routes, telemetry, Modern
Table, screenshot tooling, monetization, AI/persona behavior, dashboard, XP,
or economy behavior changed.

## Evidence used

- `docs/_reviews/full_surface_visual_design_spec_v1.md`
- `docs/_reviews/visual_slice_completion_next_gap_audit_v1.md`
- `docs/_reviews/sharky_character_coaching_presence_piec_v1.md`
- `docs/_reviews/surface_role_cta_coherence_audit_v1.md`
- `docs/_reviews/first_week_proof_packet_acceptance_v1.md`
- `lib/ui_v2/act0_shell/act0_sharky_presence_v1.dart`
- Placement, Welcome, runner/feedback, Review, Profile, and preview-shell
  seams
- existing fresh `first_week` compact packet at
  `output/screen_review/current/first_week_fast/`

The packet was already refreshed during the preceding Profile / Review pass,
so this audit did not rerun capture tooling.

## Current Sharky presence map

| Surface | Current presence | Coaching value | Verdict |
| --- | --- | --- | --- |
| Placement | Sharky names the calm starting-route choice and appears in result/route framing. | Useful when tied to the learner's two-question start evidence. | Keep bounded. |
| Welcome | `Act0SharkyGuideCardV1` frames route explanation and first-start reassurance. | High: it lowers first-hand uncertainty before the micro-win. | Keep. |
| Runner prompt / theory | Authored pre-session cue and mood can focus the next table read. | High only when prompt-specific and table-adjacent. | Keep, no expansion. |
| Correct / wrong feedback | Mascot reaction sits with the table signal, reason, Repair focus, Repair result, and Session repair. | Highest: the character reinforces concrete evidence rather than generic encouragement. | Keep as the primary Sharky seam. |
| Session / block summary | Presence bubble can close a real outcome and next action. | Positive when it summarizes actual result state. | Keep conditional. |
| Home / Learn | State-driven route/return cues exist. | Useful only as secondary orientation; static reassurance can duplicate the primary route card. | Keep constrained. |
| Practice / Play | No standalone Sharky layer. | Correct role boundary: the repair recommendation owns the repetition handoff. | Do not add Sharky for coverage. |
| Review | Repair coach and pattern cards are copy-led, with only a clean-state support line. | Correct: a mascot wrapper would compete with repair hierarchy and risk a dashboard/mascot surface. | Do not add a coach card. |
| Profile | Neutral mascot is identity framing; focus/proof cards carry learning meaning. | Mostly decorative; the proof hierarchy should remain text/state-led. | Do not expand. |

## Coaching value versus decorative risk

Sharky improves the product when the character has a narrow, evidence-backed
job:

`orient -> focus a visible clue -> acknowledge outcome -> carry the next useful action`

That is already present in the highest-EV first-week moments. The completed
visual passes made the underlying proof hierarchy clearer, so adding more
character surfaces would not make the learning loop more causal.

Decorative risk is high when Sharky repeats existing route, repair, or profile
copy; appears in every tab; wraps Review's repair card; or uses generic praise
without a visible table signal or real result. That would reduce the premium
trainer feel by making the character feel ornamental or childlike.

## Usage rules

1. Show Sharky only next to route orientation, a current table clue, concrete
   feedback, repair closure, or a real next-useful-action transition.
2. The line must be supported by existing learner state or the visible table;
   no invented personalization.
3. One Sharky element per proof beat is sufficient. Do not stack guide card,
   mascot, and speech bubble around the same message.
4. Review remains repair-copy-led; Profile remains progress-proof-led.
5. Do not use Sharky as a chat, an AI coach, a solver proxy, a fake mastery
   signal, or a commercial persuasion device.
6. Favor specific table-signal or repair-outcome language over generic praise.
7. Keep motion/asset work out of scope unless a future evidence test proves
   that static presence cannot carry the relevant learning job.

## Implementation candidates

| Rank | Candidate | Value | Risk | Verdict |
| ---: | --- | --- | --- | --- |
| 1 | No Sharky implementation; use the existing evidence-adjacent rules. | Preserves current causal proof and visual hierarchy. | Low. | Recommended now. |
| 2 | Tighten generic static Home/Learn Sharky fallback lines. | Could reduce duplicated route reassurance. | Medium: copy-only polish without new proof. | Defer until a focused copy/role audit identifies a concrete duplicate. |
| 3 | Add a new Sharky surface in Review/Profile. | Low: existing proof cards already own these roles. | High decorative/childlike risk. | Reject. |
| 4 | Add animation, chat, persona, or AI-coach behavior. | No current evidence requirement. | Very high scope and trust risk. | Reject. |

## Final recommendation

**B. Defer Sharky implementation and start the Daily / Habit layer.**

Sharky is not the current top blocker for 10/10. The character can support a
premium coaching feel, but the first-week packet already places it at the
right evidence-adjacent moments. The higher-EV next layer is a calm return
loop that carries real repaired/missed signals into Day 2 / Day 7 value, not
additional mascot coverage.

## Not now

- no new Sharky assets, animation, chat, or persona system;
- no AI/adaptive, solver, or GTO claims;
- no Review mascot wrapper or Profile coach card;
- no generic Home/Learn reassurance expansion;
- no monetization/premium persuasion through Sharky;
- no Modern Table, route, telemetry, dashboard, XP, or screenshot-tooling
  work.

## Exact recommended next prompt title

`Daily Trainer / Habit Loop Expansion and Learning Depth v1 — Audit / PIEC Only`
