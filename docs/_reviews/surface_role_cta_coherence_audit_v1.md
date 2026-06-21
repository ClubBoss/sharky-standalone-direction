# Surface Role / CTA Coherence Audit v1

## Scope

Audit only on local `main` at `0a545ee2963027a2e2f6f6eea3f84804a1e1da71`.
No product, UI, copy, test, asset, navigation, screenshot, or tooling changes.

## Inspected files

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/sharky_character_coaching_presence_piec_v1.md`
- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`

## Surface roles and CTA ownership

| Surface | Main job | Dominant action | Secondary actions / risk | Verdict |
| --- | --- | --- | --- | --- |
| Home | Decide the next useful learning action. | Mission-card filled CTA. | Checklist rows are actionable, but only the first pending row is active; the visible next-best-action block is explanatory. | One primary action exists structurally. Compact visual evidence should verify the mission CTA still dominates the checklist. |
| Learn | Teach the route and current concept. | `Start` on the current mission. | Path expansion, completed replay/review, and world continuation are subordinate route controls. | Distinct from Practice: route, Now, and Why it matters are explicit. |
| Practice / Play | Reinforce a useful rep. | Featured recommendation or repair handoff. | Daily, weak-spot, continue-route, and placement groups can coexist. | Distinct from Learn, but the `continue` practice group can look route-like in an incomplete artifact. |
| Review | Repair a missed clue or repeated pattern. | `Repair this clue`. | Recovered proof and pattern context are secondary. | Clear repair ownership. |
| Profile | Reflect growth and return the learner to current focus. | Next-focus handoff to Home. | Skill snapshot, recent gains, and repaired proof are secondary. | Compact mirror, not a competing training surface. |
| Runner / decision / feedback | Teach, let the learner choose, then explain outcome. | Contextual theory/answer/feedback continuation. | Generic `Continue` is normal for an in-flow transition but must remain adjacent to the current instruction or outcome. | Decision state is not adequately represented in the external packet. |
| Welcome / Placement | Route entry and explain the starting point. | Start / recommended route handoff. | Replay/diagnostic paths are conditional. | Present but not admitted for implementation from this audit. |

## CTA inventory and coherence

- `Start` is route-owned in Learn and task-owned in lesson cards; this is clear.
- `Repair this clue` is Review-owned and repair-specific; this is clear.
- Play uses recommendation-specific groups: repair, daily, quick reps, or
  `Continue lesson`. The latter is a valid resume-route action but is the main
  source of Learn/Practice artifact confusion.
- Runner uses `Continue` for sequenced theory and feedback transitions. It is
  not inherently generic because it follows a displayed instruction, answer,
  or receipt.
- Home falls back to `Continue your first lesson` when no repair reason exists,
  while repair states render a signal-specific next-best action. This is
  appropriate, but the checklist creates multiple secondary taps below the
  primary mission CTA.

## Home hierarchy verdict

Home has one clear primary CTA in code: the mission-card filled button. It also
contains a ranked checklist, not several equal primary CTAs. The Claude signal
is therefore **needs visual evidence**, not a confirmed hierarchy defect. A
future capture should verify compact portrait ordering and emphasis before any
Home implementation wave is admitted.

## Learn vs Practice verdict

The current implementation is not redundant:

- Learn owns the learning path, current mission, `Now`, and `Why it matters`.
- Practice owns repetition through featured repair, weak spots, daily sets, and
  quick reps.

The ambiguity is presentation evidence, not a proven architecture problem.
The Play `continue` group is a narrow copy/role seam worth inspecting only if a
complete capture shows it competing with Learn's route entry.

## Profile verdict

Profile closes the loop through Next focus, recent progress, skill gains, and
stabilized repair proof. XP, streak, and skill snapshots are present but are
secondary to the focus card and derive from real state. The serious-player
mismatch is **not confirmed**; evaluate it only in a true beginner-state
capture before considering any metric change.

## Sharky role verdict

Keep Sharky only where it reinforces a concrete learning job: current route
orientation, table prompt, repair feedback, or summary transition. Do not
expand static Home reassurance, Learn guide repetition, or Profile identity
into extra decorative character surfaces.

## Claude signal classification

| Signal | Classification | Result |
| --- | --- | --- |
| Home competing actions | Needs evidence | Structural ownership is ranked; compact visual hierarchy remains unproven. |
| Generic `Continue` | Needs evidence | Contextual runner use is sound; Play `continue` and Home fallback merit targeted visual review. |
| Learn / Practice redundancy | Needs evidence | Jobs are distinct in code; incomplete artifact can hide that distinction. |
| Profile beginner mismatch | Needs evidence | Metrics are secondary and real-state-backed; no redesign evidence. |
| Missing decision / answer-choice state | Confirmed issue | The review packet cannot support a full surface/CTA verdict without it. |
| Learning-grounded Sharky only | Confirmed issue | Evidence-adjacent feedback is valuable; decorative expansion is not. |
| Verdicts from omitted Result, Onboarding, Premium, and latest repair states | Invalid/stale | The artifact is incomplete and cannot override active-shell evidence. |

## Recommendation

Recommended next wave: **Decision-State Review Packet Capture v1**.

It should capture existing real-text compact states only: one decision/answer
screen, correct feedback, wrong/repair feedback, and the existing Review or
result handoff as supported by current tooling. Its purpose is evidence, not
UI revision. After that packet, admit at most one narrowly evidenced product
wave: Home Action Hierarchy / CTA Ownership v1 or Learn vs Practice Role
Clarity v1.

## Not now

- No Home hierarchy rewrite, CTA copy sweep, or navigation redesign.
- No Learn/Practice merge or Profile metric redesign.
- No Sharky Character implementation, chat/persona system, animation, or
  decorative mascot expansion.
- No Welcome/Placement implementation without first-start evidence.
- No monetization, dashboard, XP/economy, Modern Table, or screenshot-tooling
  changes in this audit.

## Proposed next prompt title

`Decision-State Review Packet Capture v1 — Local Only`
