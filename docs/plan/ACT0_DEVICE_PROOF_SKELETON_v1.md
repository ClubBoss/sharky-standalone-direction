# ACT0_DEVICE_PROOF_SKELETON_v1

Status: ACTIVE
Purpose: minimum real-device proof checklist for Act0 route before novice gate closure and release proof packaging.

## 1. Device Matrix

Run on at least these physical devices:

- iPhone compact: 5.4in class (or closest available)
- iPhone large: 6.7in class (or closest available)
- iPad/tablet: 11in class (or closest available)
- Android compact: ~6.1in class
- Android large: ~6.7in class

For each device capture:

- OS version
- app build hash
- locale
- text scale setting
- orientation used

## 2. Core Surfaces (Must Capture)

For each device, validate and screenshot all:

- Placement intro
- Home
- Learn
- Play
- Review
- Profile
- Table runner (first actionable state)
- Result

Store artifacts under:

- output/device_audit/act0_product_100/

## 3. First-Start / Framing Checks

Verify on fresh install state:

- app does not flash legacy placement before shell
- onboarding/trust primer appears when expected
- first CTA is obvious and actionable
- no premium/trial pressure before value proof
- no clipped trust text at bottom safe area

## 4. Placement Manual-Flow Checks

Verify from manual entry points (dev menu/profile):

- placement opens intentionally (not auto-flash)
- intro copy reads product-current, not legacy/internal
- reassurance line remains visible on compact devices
- route recommendation and trust line readable
- handoff returns to main route cleanly

## 5. Home / Habit Voice Checks

Validate with streakDays = 0, 3, 7 scenarios:

- footer Sharky line matches mood and state
- daily trust line is short and readable
- no contradictory tone between card CTA and Sharky cue
- EN and RU do not regress into robotic wording

## 6. Result Surface Coaching Checks

Validate in first-session and follow-up sessions:

- why line is concrete (reason over guess)
- continuation line points to clear next action
- Sharky reinforcement line aligns with lesson outcome
- primary CTA remains visible at all tested text scales

## 7. Accessibility / Readability Quick Pass

For each device:

- text scale 100% and 120%
- dark/light contrast remains readable
- primary CTA always reachable without hidden scroll traps
- no overlap between sticky action bar and core text

## 8. Evidence Packet Format

For each device run, append one short record:

- device id + OS + build
- pass/fail per section (1-7)
- blocker list (if any)
- screenshot paths

Recommended destination for summary notes:

- docs/plan/NOVICE_WALKTHROUGH_EVIDENCE_v1.md

## 9. Exit Criteria

Device proof skeleton is considered complete when:

- all required surfaces captured on 3+ physical devices (including one tablet)
- no P0/P1 readability or CTA visibility failures remain
- first-start/placement framing checks pass without legacy flashes
- Home/Result coaching voice checks pass in EN and RU
