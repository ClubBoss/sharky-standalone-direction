# First-Week Learning Proof Packet v1

- Date: 2026-06-23
- Origin main: `fb02a68220c8d0f15177b496a444c48732c83fbc`
- Status: `first_week_proof_ready_for_review`

## Scope / non-scope

This packet summarizes the current first-week learning proof after the
multi-family Review repair queue display landed. It is an evidence and product
readiness note only.

No product code, UI, copy, route, telemetry, Modern Table, content, glossary,
monetization, screenshot tooling, queue resolution, queue clear, or new repair
family work changed in this wave.

## Executive verdict

The first-week proof is ready for product/design/commercial review as an
internal evidence packet.

The strongest current claim is:

`mistake -> table signal -> why -> targeted recheck -> proof/return context`

This is enough to show Sharky's core learning value before monetization. It is
not enough to claim final store-grade commercial polish, broad content depth,
or completed repair-resolution lifecycle.

## Current first-week learner loop

The current first-week evidence chain is:

1. Placement and Welcome get the learner to one tiny real decision.
2. The W1 runner shows a real table decision.
3. Correct and wrong feedback explain the table signal.
4. Wrong/suboptimal feedback can expose `Repair focus`.
5. Repair completion can expose `Repair result`.
6. Session closure can expose `Session repair`.
7. Review can show repair continuation and supported session-drill recheck
   items.
8. Profile can reflect compact progress/proof without becoming a dashboard.

Existing accepted packet artifacts:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/manifest.json`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/manifest.json`
- `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `output/screen_review/current/core_fast/contact_sheet.png`

Generated artifacts remain local-only and uncommitted.

## Repair loop proof

### W6 range-bucket family

W6 range-bucket proof is contract-backed:

- failed `range_bucket_classifier_v1` drills create repair receipt candidates;
- persisted receipts become internal recheck candidates;
- recheck candidates become `SessionDrillRecheckLaunchQueueItemV1` items;
- Review displays a visible recheck queue card;
- CTA launch preserves `launchSessionId`, `targetDrillId`, and
  `isRecheckLaunchV1`;
- targeted recheck launch suppresses normal session completion/progress.

This proves deterministic repair routing without fabricating
`Act0RepairIntentV1`.

### W5 board-texture family

W5 board-texture proof now reuses the same infrastructure:

- supported W5 s01 `board_texture_classifier_v1` misses create receipt
  candidates;
- source signal is `expected_action_mismatch` plus board texture identity;
- exact replay targets are mapped for dry, wet, and paired texture drills;
- persisted receipts become internal recheck candidates;
- launch queue items preserve exact session/drill identity;
- Review displays the same generic recheck queue card for board texture.

This makes deterministic repair proof multi-family instead of W6-only.

## What the user sees

In the current proof surfaces, the learner can see:

- a real decision rather than abstract study;
- a short table-signal explanation after feedback;
- repair focus and result language that stays calm and beginner-safe;
- Review as a coach surface, not an analytics dashboard;
- a visible `Practice this spot again` queue card for supported session-drill
  rechecks;
- compact Profile proof without fake mastery or XP pressure.

## What the system guarantees

The system guarantees, through source and focused tests:

- supported W6 range-bucket misses map to deterministic recheck targets;
- supported W5 board-texture misses map to deterministic exact replay targets;
- unsupported/malformed receipts are ignored safely;
- Review does not reuse `Act0MistakeCardV1` for session-drill recheck items;
- route launch passes exact `sessionId`, `initialDrillId`, and recheck flag;
- recheck launch does not emit normal session completion/progress side effects;
- no telemetry schema or route schema expansion is needed for current proof.

## What is intentionally deferred

- Queue clear/resolution policy.
- One-drill-only recheck result flow.
- Recheck-specific telemetry.
- Home/Practice ranking for session-drill recheck items.
- Third repair family.
- Broad action-choice mapping.
- Content/glossary expansion.
- Premium/paywall/trial work.
- Modern Table visual work.
- Sharky character/persona expansion.
- Dashboard, XP, economy, or analytics proof.

## Commercial readiness assessment

The first-week route shows enough learning value before monetization:

- the learner makes a real table choice;
- Sharky explains the missed signal;
- Sharky can route to a targeted recheck;
- Review can show that recheck visibly;
- the proof is deterministic and auditable.

Commercial readiness remains evidence-limited rather than mechanism-limited.
The current packet is appropriate for product/design/commercial review, but not
yet final app-store/storefront proof.

## Runout comparison

Runout remains ahead in commercial packaging, paywall/subscription ceremony,
motion, and perceived ecosystem breadth.

Sharky's current advantage is honest learning causality before paywall:

`choice -> table signal -> why -> repair -> proof`

The correct next move is to review this proof quality and content depth, not to
copy Runout's dashboards, paywall timing, or broad feature packaging.

## Top blockers before first commercial review

1. **Queue resolution remains open.** Launching a recheck is not yet durable
   proof that the recheck was fixed.
2. **Content depth remains the main product-risk blocker.** Current proof is
   strong, but broader first-week and W5+ premium credibility still depends on
   enough examples, term safety, and same-signal repetition.
3. **External packet polish is not final.** Current fast packets are usable for
   review, but contact sheets are not store-grade assets.
4. **Review displays the first queue item only.** This is acceptable for proof,
   but not a full queue-management product.

## Must-not-build list

- No queue clear or resolution without an owned resolution event.
- No telemetry schema before product semantics are settled.
- No paywall, trial, or premium route gate before proof review.
- No dashboards, charts, XP, economy, or fake mastery.
- No Modern Table polish unless a concrete proof blocker appears.
- No generic action-choice repair mapper.
- No third repair family before current proof is reviewed.
- No Runout asset/layout/copy imitation.

## Recommended next wave

Run `Content Depth / Term Introduction / Drill Coverage Audit` next if the goal
is commercial trust and monetization readiness.

Reason: repair routing now has enough visible deterministic proof for v1. The
highest remaining risk is whether the first-week and W5+ route has enough
authored depth, safe term introduction, and same-signal coverage to support the
commercial promise.

Queue resolution can follow after that audit if the proof review says the
visible repair loop is strong but unresolved rechecks weaken trust.

## Validation run

Required for this docs-only wave:

- `graphify hook-check`
- `flutter analyze`
- `git diff --check`
- `git status --short`

No product tests or screenshot commands are required because this wave changes
only this review note and references already-generated local evidence.
