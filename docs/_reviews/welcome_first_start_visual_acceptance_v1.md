# Welcome First-Start Visual Acceptance v1

## Scope

Local-only acceptance pass for the Welcome first micro-win at
`3c4268b3378ba84af8b9be7feb6349c373c26e29`. No product code, UI, copy, test,
or tooling changes were made.

## Evidence

- Targeted first-start tests prove the three-beat Welcome flow, local
  micro-win, persisted completion flag, unchanged curriculum progress,
  recommended-start handoff, completed-Welcome boot skip, and replay safety.
- `./tools/screen_review_fast_v1.sh core compact` produced the current core
  packet. The contact sheet shows no obvious layout regression across Home,
  Learn, Practice, Review, and Profile.
- `./tools/screen_review_fast_v1.sh runner compact` produced the current
  decision and feedback packet. The existing `No bet yet -> Check` action
  pattern is readable and its correct/wrong feedback is calm and specific.

## Acceptance verdict

Functional acceptance: pass.

The flow is compact by structure: explanation, one answer, feedback, and
handoff. The micro-win is a guided success rather than placement assessment:
its selection lives only inside Welcome and creates no repair obligation.
Normal Welcome completion reaches Home with W1 focus; a placement-recommended
learner reaches the existing selected W1 hand after the same micro-win.

## Evidence limitation

The supported fast lane exposes only `core compact` and `runner compact`; it
does not have a Welcome capture group. Direct visual proof of the Welcome
container therefore comes from the targeted widget test contract, not a
dedicated screenshot. The runner packet also retains its known local
capture-only blank CTA-label limitation. Neither is a product UI blocker and
this pass does not change screenshot tooling.

## Artifact paths

- `output/screen_review/current/core_fast/contact_sheet.png`
- `output/screen_review/current/core_fast/screen_review_core_fast.zip`
- `output/screen_review/current/runner_fast/contact_sheet.png`
- `output/screen_review/current/runner_fast/screen_review_runner_fast.zip`

All generated artifacts are local-only and uncommitted.

## Recommendation

Accept the flow change. If direct Welcome imagery is needed for release or
design review, scope a separate narrow capture-lane addition; do not use this
acceptance pass to begin the planned broader visual redesign.
