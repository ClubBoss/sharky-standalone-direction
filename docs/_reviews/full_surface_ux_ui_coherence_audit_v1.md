# Full Surface UX/UI Coherence Audit v1

## Scope

Local-only audit / product-spec pass on `main` after:

- `a8edf2fc` - Audit first-week proof packet evidence;
- `3974cca3` - Add first-week proof capture lane;
- `775f476a` - Accept first-week proof packet.

No product code, UI, copy, tests, assets, capture tooling, screenshot outputs,
routes, telemetry, Modern Table visuals, Sharky Character work, monetization,
AI/chat/ML behavior, dashboard/charts, XP, or economy work changed.

## Evidence used

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/welcome_placement_micro_aha_alignment_piec_v1.md`
- `docs/_reviews/welcome_first_micro_win_alignment_v1.md`
- `docs/_reviews/welcome_first_start_visual_acceptance_v1.md`
- `docs/_reviews/first_week_proof_packet_evidence_audit_v1.md`
- `docs/_reviews/first_week_proof_packet_capture_lane_v1.md`
- `docs/_reviews/first_week_proof_packet_acceptance_v1.md`
- `docs/_reviews/surface_role_cta_coherence_audit_v1.md`
- `docs/_reviews/sharky_character_coaching_presence_piec_v1.md`
- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/manifest.json`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`

The first-week packet was inspected locally. The current packet includes 12
states: placement, Welcome decision, Welcome feedback, Welcome handoff, W1
decision, correct feedback, wrong feedback, Repair focus, Repair result,
Session repair, Review handoff, and Profile proof.

## Surface-by-surface verdict

| Surface | Learner job | Coherence verdict | Finding class |
| --- | --- | --- | --- |
| Placement | Establish a short starting route without feeling like setup work. | Compact, clear, and low-friction in the captured intro state. Completed result is not captured, but this is not blocking the current review packet. | B: evidence limitation. |
| Welcome | Convert explanation into one tiny real win. | Strongest activation improvement: the packet now shows a real table decision, calm feedback, and handoff. It feels like guided success, not a diagnostic. | Pass. |
| Welcome handoff | Make the path after micro-win understandable. | The handoff is understandable: Home opens next and W1 remains the focus. Visual CTA text is partially obscured by renderer white bars, so final CTA-copy proof is incomplete. | B: capture limitation. |
| Home | Own the top-level next action. | Home is not separately visible in this first-week packet, but prior core evidence and role audit support the ownership model. No new blocker found here. | Non-blocker for this packet. |
| Learn | Teach route/current concept. | Not in the first-week packet, but already accepted in core proof. No evidence that Learn competes with Practice in the current first-week proof story. | Non-blocker. |
| Practice | Reinforce or route to useful reps. | Not central in this packet; Review/repair handoff and runner proof cover the immediate learning loop. | Non-blocker. |
| Runner decision | Let the learner make one real table decision. | Clear enough: table, prompt, and options are visible. Table remains readable on compact phone. | Pass. |
| Correct feedback | Explain why the answer was correct. | Signal-based feedback is visible and concrete. It proves value without dashboard or generic score framing. | Pass. |
| Wrong feedback | Make the mistake useful and emotionally light. | Strong: wrong answer becomes a missed-clue explanation and next repair direction, not shame or analytics. | Pass. |
| Repair focus | Connect the mistake to the repair reason. | Strongest proof surface. It shows missed clue, reason for the next useful hand, and next focus. | Pass. |
| Repair result | Show whether the repair resolved. | Receipt is visible and understandable. It connects the hand back to the prior signal. | Pass. |
| Session repair | Close the repair loop at session level. | Visible inside the feedback receipt seam. This is acceptable for proof, though future visual spec should decide whether result/session hierarchy needs separation. | C: future visual design candidate. |
| Review | Own repair/pattern continuation. | Review reads as repair coach, not dashboard/error log. CTA and repair continuation are visible. | Pass. |
| Profile / You | Reflect growth without becoming analytics. | Shows compact progress proof and return context. It does not show dynamic personalized repair-return reason, but that gap is documented and not required now. | B: evidence limitation. |
| First-week handoff | Make the chain coherent across surfaces. | The packet tells a coherent story from placement through proof. The learner-facing cause/effect chain is visible. | Pass. |

## First-week flow verdict

The first-week flow is coherent enough for product/design/commercial review:

`placement -> Welcome micro-win -> W1 decision -> feedback -> repair proof -> Review/Profile proof`

The product now proves the key Sharky promise: a learner can make a real
choice, see the table signal, understand why, repair the miss, and see proof
without a dashboard or fake gamification.

This is not final visual-design acceptance. It is evidence readiness for the
next review stage.

## Top blockers

No product blocker is stronger than evidence/design-readiness right now.

Current blockers are review-process / evidence-level:

1. The latest evidence/capture acceptance commits are local and should be
   packaged/pushed before new product implementation starts.
2. The fast renderer can still show some button labels as white bars, so the
   packet is not final CTA-copy screenshot proof.
3. Completed placement result and dynamic Profile repair-return reason remain
   uncaptured, but they are not required for the current review stage.

## Non-blockers

- Completed placement-result capture is not required now.
- Dynamic Profile repair-return capture is not required now.
- Perfect visual polish is not required for this evidence packet.
- Home/Learn/Practice role boundaries are not contradicted by the current
  packet or recent audits.
- Sharky presence is adequate where it supports learning evidence; more
  character coverage is not needed before design review.
- Monetization is intentionally absent and should remain absent before value
  proof is accepted.

## Future visual redesign candidates

These are candidates for a visual design spec/audit, not implementation now:

- first-week surface rhythm: how Placement, Welcome, Runner, Review, and
  Profile should share a premium visual language without becoming samey;
- CTA/button hierarchy and renderer-proof label legibility;
- feedback card density, especially when Repair result and Session repair are
  both visible;
- table-to-card vertical rhythm on compact phone;
- Profile proof hierarchy so progress feels like a growth mirror rather than
  a stat card;
- Review repair card polish while preserving coach-not-dashboard behavior;
- Sharky presence rules for evidence-adjacent moments only.

## Deferred / not-now list

- no product implementation before the local evidence wave is packaged/pushed;
- no broad visual redesign implementation;
- no Welcome or Placement redesign;
- no completed-placement capture unless release/design review explicitly asks;
- no dynamic Profile return-reason capture unless release/design review asks;
- no Sharky Character implementation;
- no monetization, premium/paywall, trial, or commercial CTA work;
- no Modern Table visual work;
- no AI/chat/ML behavior;
- no dashboard/charts/XP/economy systems;
- no screenshot tooling change unless white-bar rendering blocks the next
  review stage.

## Ranked next-wave candidates

| Rank | Candidate | EV | Risk | Verdict |
| ---: | --- | --- | --- | --- |
| 1 | Package and push current first-week evidence/capture acceptance wave. | High | Low | Recommended next. It preserves the now-accepted evidence base before more work stacks on local main. |
| 2 | Full Surface Visual Design Spec v1. | High | Low/Medium | Next after packaging. It should define a design target and hierarchy rules, not implement UI. |
| 3 | Fast renderer CTA-label repair. | Medium | Low/Medium | Only if product/design/commercial review requires final CTA-copy screenshot proof. |
| 4 | Completed placement/Profile dynamic capture extension. | Low/Medium | Medium | Defer unless those exact states are requested. |
| 5 | Sharky Character implementation. | Medium | Medium/High | Not next; current evidence says learning-EV seams are already adequate and decorative expansion is risky. |
| 6 | Monetization / paywall / premium packaging. | Medium later | High now | Not next; value proof and visual coherence must be accepted first. |

## Recommended next implementation wave

Do **not** start a product implementation wave yet.

Recommended immediate wave:

`Package and Push First-Week Evidence Wave — One Pass`

Goal: push the local evidence/capture/doc commits that establish the accepted
first-week proof packet, without adding product changes.

After that, the next product-design step should be:

`Full Surface Visual Design Spec v1 — Audit / Spec Only`

It should turn this evidence packet into a clear visual system target before
any broad UI implementation begins.

## Why not broad visual redesign immediately

The packet proves the learning loop, but it also shows that visual/system work
needs a spec-level target first: surface rhythm, CTA hierarchy, card density,
and proof hierarchy should be decided before implementation. Starting broad UI
changes now risks polishing symptoms without locking the desired surface
system.

## Why not Sharky expansion immediately

The Sharky audit already found character presence is highest-EV when adjacent
to concrete learning proof. The current packet has enough coaching presence in
Welcome, runner feedback, repair focus/result, and session proof. More Sharky
coverage now would likely become decorative noise.

## Why not monetization immediately

The top-1 plan requires value before paywall. The first-week proof packet is
now accepted as evidence, but the product still needs design coherence review
before premium packaging or commercial CTA work. Monetization before visual
and proof acceptance would weaken trust.

## Exact recommended next prompt title

`Package and Push First-Week Evidence Wave — One Pass`
