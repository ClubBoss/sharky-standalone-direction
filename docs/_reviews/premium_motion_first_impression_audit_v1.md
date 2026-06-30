# Premium Motion and First Impression Audit v1

## 1. Verdict
`premium_motion_first_impression_audit_landed`

Decision-only audit landed. No product code, assets, routes, screenshots, output
folders, telemetry, monetization, Modern Table polish, or W7 public opening were
changed.

## 2. Stage 0 sync result
- Synced accepted commit: `664f3762` (`docs: record w7 visible ace evidence consumption audit`).
- Sync artifact: `docs/_reviews/repo_integration_w7_visible_ace_evidence_consumption_audit_v14.md`.
- Stage 0 commit: `aedd0b69` (`docs: record w7 visible ace evidence audit sync`).
- Stage 0 push: pushed `main` to `origin/main`.
- Main after Stage 0: `aedd0b691318f5a696ae67b6b52fdb09798e8d86`.

## 3. Context router usage
- Read `docs/context/CONTEXT_ROUTER_v1.md`.
- Stage 0 used `repo_hygiene` lane and `docs/context/REPO_HYGIENE_CAPSULE_v1.md`.
- Stage 1 used the bounded product-planning lane shape: current capsule,
  durable repair capsule, targeted SSOT slices, and exact owner/seam searches.
- No W1-W6 re-audit, W7-W12 route opening, fixtures, runtime implementation
  changes, screenshots, or output folders were opened as audit evidence.

## 4. Files inspected
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/plan/MONETIZATION_SSOT_v1.md`
- `docs/plan/PRODUCT_SURFACE_READINESS_v1.md`
- `test/ui_v2/wave4_4_premium_first_open_foundation_proof_v1_test.dart`
- `lib/ui_v2/onboarding/onboarding_entry_widget.dart`
- `lib/ui_v2/progression/session_summary_card.dart`
- Targeted seam search under `lib/ui_v2/act0_shell/`, `test/ui_v2/`,
  and `test/guards/`.

## 5. Current premium readiness gap
The real gap is not casino polish or table spectacle. The accepted alpha spine
already proves placement, decision, feedback, repair, Practice, Session Summary,
and Review/Profile proof. The remaining premium-readiness gap is whether that
proof loop feels clear, earned, and emotionally legible on first use:
payoff, hierarchy, rhythm, and first-week confidence.

## 6. Motion candidate list
1. Session Summary proof reveal micro-motion.
2. Practice this next CTA attention micro-motion.
3. Lightweight Sharky splash / first-open brand moment.
4. Correct-feedback payoff micro-motion.
5. Incorrect-feedback repair-focus reveal.
6. Return-session active-focus reminder.
7. Task or world completion payoff.
8. Lesson-start transition.
9. Decision-submitted micro-response.
10. Sharky companion micro-presence.

## 7. EV ranking
1. Session Summary proof reveal micro-motion: highest EV, lowest scope risk.
   It directly supports local proof and payoff, and an existing summary card
   already owns fade/slide behavior.
2. Practice this next CTA attention micro-motion: high EV, but should follow
   proof reveal so CTA attention does not feel pushy or commerce-like.
3. Lightweight Sharky splash / first-open brand moment: useful for first
   impression, but first-open Sharky proof already exists and is test-covered.
4. Correct-feedback or repair-focus reveal: useful, but spreads across feedback
   surfaces and can become a broad animation pass.
5. Route transitions, table/card motion, mascot animation, companion presence,
   badges, and large ceremonies: defer.

## 8. Deferred motion list
- Casino-style table, chip, card-deal, or HUD polish.
- Broad animation-token or component-system rollout.
- Mascot or character animation system.
- Modern Table visual polish.
- Splash work beyond the existing Sharky brand beat.
- Paywall, trial, upsell, price, restore, or Premium Hub motion.
- Badge, radar, level, streak, or broad completion ceremony.
- Screenshot-driven iteration or generated visual assets.

## 9. Existing owner/seam findings
- `lib/ui_v2/progression/session_summary_card.dart` already has a summary owner
  with fade/slide animation behavior.
- Act0 repair/session tests already cover proof, Session Summary receipt,
  Practice CTA, active focus, and local repair-proof copy.
- First-open Sharky brand proof is already covered by the premium first-open
  foundation test.
- `PRODUCT_SURFACE_READINESS_v1` names result/payoff readability and
  next-step clarity as release-grade surface criteria.
- Monetization SSOT keeps premium preview soft and post-value; motion must not
  imply paid access, trial, purchase, or entitlement change.

## 10. Recommended first implementation slice
Implement only `Session Summary proof reveal micro-motion`.

The motion should attach to the existing proof/earned row when local proof is
present, such as the Session Summary proof that the learner later answered the
focus correctly. Use a small existing-style fade/slide/scale or emphasis pulse
on that proof surface only. Do not add new copy, art, route state, telemetry,
premium access behavior, or screenshots.

## 11. Required implementation DoD
- Motion is limited to the existing Session Summary proof/payoff surface.
- Motion appears only when proof evidence exists.
- Reduced-motion or test-stable behavior is supported.
- No layout shift hides proof text, CTA text, or next-step meaning.
- Text-scale and compact-height behavior remain readable.
- No new claims such as mastered, fixed, guaranteed, AI, GTO, solver, win rate,
  trial, price, paywall, or unlock.
- No Modern Table, broad component, asset, screenshot, or route work.

## 12. Required tests/guards
- Widget guard for proof-present versus proof-absent rendering.
- Pump/settle or reduced-motion stability guard.
- Small-height or text-scale no-overflow guard for proof plus next action.
- Copy-safety guard for banned premium, solver, AI, mastery, and guarantee
  claims.
- Existing Session Summary, repair intent, and Practice CTA tests remain in
  scope for the implementation wave.

## 13. Modern Table maintenance compliance
Compliant. The recommended slice does not touch Modern Table, card rendering,
table geometry, HUD, seats, chips, screenshots, or visual redesign.

## 14. Score impact
- W1-W12 score movement: `+0.0`.
- Overall top-1 impact: `+0.1` planning confidence only, because a low-risk
  premium-feel slice is identified but not implemented.
- No Human QA, launch readiness, monetization readiness, public W7 opening, or
  9.0 claim is made.

## 15. Validation
Planned repo-hygiene validation only: `git diff --check`,
`git diff --cached --check`, `graphify hook-check`, and ASCII/trailing
whitespace/CRLF/final-newline checks on this artifact.

## 16. Next recommendation
Run one bounded implementation wave for Session Summary proof reveal
micro-motion, with reduced-motion/test-stable guards and no copy, route,
telemetry, screenshot, Modern Table, or asset expansion.
