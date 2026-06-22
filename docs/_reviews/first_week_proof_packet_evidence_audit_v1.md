# First-Week Proof Packet Evidence Audit v1

## Scope

Local-only evidence-readiness audit on `main` at
`c8e87f2256f92a93338dc0d2f9c428307970058e`. This records what the existing
real-text fast capture lane can prove today. It does not add product states,
change UI or copy, or create a new capture system.

## Inspected authority and evidence seams

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- recent Welcome, repair, and capture review records under `docs/_reviews/`
- `tools/screen_review_fast_v1.sh`
- `tools/act0_real_text_surface_capture_v1.dart`
- `tools/package_screen_review_v1.sh` and its packager
- deterministic Act0 debug entries in
  `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- existing repair feedback/result rendering in
  `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`

## Proof-story map

| Story beat | Product state exists | Fast real-text capture | Current evidence |
| --- | --- | --- | --- |
| First open and placement | Yes | No | Product/test and direct debug-entry evidence only. |
| Welcome route explanation | Yes | No | Targeted Welcome test evidence; no fast Welcome packet. |
| Welcome micro-win decision and feedback | Yes | No | Targeted Welcome test evidence; no direct stateful capture entry. |
| W1 decision / answer choice | Yes | Yes | `runner compact` decision image. |
| Correct feedback | Yes | Yes | `runner compact` correct-feedback image. |
| Wrong feedback | Yes | Yes | `runner compact` wrong-feedback image. |
| Repair focus | Yes | No | Rendered only when an active repair intent/reason exists; the direct wrong-feedback entry does not create one. |
| Repair result | Yes | No | A resolved repair attempt has no named deterministic capture entry. |
| Session repair | Yes | No | The resolved session-summary state has no named deterministic capture entry. |
| Review repair continuation | Yes | Yes | `core compact` Review image shows the repair-coach handoff. |
| Profile growth / return mirror | Yes | Partially | `core compact` captures Profile, but not a deterministic dynamic repair-return state. |

## Capturable now

```bash
./tools/screen_review_fast_v1.sh core compact
./tools/screen_review_fast_v1.sh runner compact
```

The supported packet can show these real-text states:

- Home, Learn, Practice, Review, and Profile first-week surfaces;
- a runner answer-choice state;
- first correct feedback;
- first wrong feedback;
- Review's repair-continuation handoff and CTA.

Expected local-only packets are:

- `output/screen_review/current/core_fast/contact_sheet.png`
- `output/screen_review/current/core_fast/screen_review_core_fast.zip`
- `output/screen_review/current/runner_fast/contact_sheet.png`
- `output/screen_review/current/runner_fast/screen_review_runner_fast.zip`

The runner renderer can leave the bottom feedback CTA label blank. The visible
decision and feedback content above it remains readable; this is a known
capture-only limitation, not evidence of missing product copy.

## Existing states that are not capturable

- placement and placement result;
- the Welcome micro-win's decision, feedback, and Home/W1 handoff;
- active `Repair focus` with its actual repair reason;
- `Repair result` after the repair attempt resolves;
- `Session repair` after session closure;
- a deterministic Profile rendering of the current repair-return reason.

These are product-existing states. Their absence is a named-state/capture
coverage gap, not a product-state gap.

## Missing product states

None required for the stated repair proof loop are missing. The app already
contains the Welcome micro-win, repair focus, repair result, session repair,
Review pattern/repair coaching, and Profile progress/return seams. What is
missing is deterministic visual evidence assembly for several of those states.

## Best current evidence packet

Today the strongest honest packet is a mixed evidence bundle:

1. `core compact` contact sheet for the five primary surfaces and the Review
   repair handoff;
2. `runner compact` contact sheet for decision, correct feedback, and wrong
   feedback;
3. targeted Welcome and repair lifecycle test contracts for the first-open,
   micro-win, repair focus/result, and session-summary claims.

This is sufficient for a product-state audit, but it is not yet a single
coherent visual first-session packet from placement through repair outcome.

## Verdict and recommended next wave

Choose **B: add one narrow capture-lane state group** before a broad Surface
UX/UI Coherence Audit.

Scope it as `First-Week Proof Packet Capture Lane v1`: extend the existing
fast Flutter-rendered lane only, using deterministic existing state setup, to
capture placement, the Welcome micro-win, active repair focus, repair result,
and session repair. Do not invent product states, synthesize outcomes, or
change learner-facing behavior. The capture group should also provide a
deterministic Profile return-reason state if that existing seam can be reached
through the same setup.

## Not now

- no Welcome or Placement redesign;
- no repair/result/session product implementation;
- no broad screenshot platform or native/web capture fallback work;
- no screenshot-polish loop;
- no Full Surface UX/UI Coherence Audit until the proof packet has the needed
  visual states;
- no monetization, Sharky Character, AI/chat/ML, Modern Table, dashboard,
  chart, or XP/economy work.
