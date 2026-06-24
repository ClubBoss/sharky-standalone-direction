# Daily Repair Depth / Mastery Loop Decision v1

Date: 2026-06-24
Status: `decision_ready_no_code`
Scope: audit and decision only. This artifact is not a new roadmap authority.

## 1. Verdict

`decision_ready_no_code`

The next highest-EV durable-depth wave is **Mastery Tier Contract v1** as a
small, no-code contract/spec wave. It should define how the existing learner
skill atoms can move through `Learn`, `Prove`, and `Speed` without inventing a
dashboard, a new telemetry owner, or a broad scheduler.

Daily Repair Reason is already materially present. Leaks resurfacing is also
partially present through deterministic repair, aged recheck, and owned-skill
states, but it does not yet have a stable atom-level tier contract to govern
when a signal is eligible for mixed recall or a stronger proof mode. Volume I
depth is route truth, not the immediate retention bottleneck.

## 2. Current repo truth

### Repair decision and reason

The active Act0 route already turns a miss into a deterministic repair target
and a learner-facing reason. `Act0RepairIntentV1`, the next-useful-hand reason
receipt, and its copy bridge drive the existing Home, Practice, and Review
repair language. The visible chain is:

`choice -> table signal -> why this repair -> targeted rep -> repair result`

The existing resolver tests cover a stored repair target and a visible Home
reason; Practice reuses the same reason for its reinforcement entry.

### Session repair and Day 2 return proof

The runner already exposes compact repair result and session-repair receipts.
Open repair intents are persisted with retention memory, so after the one-time
first-value carry is consumed a later relaunch can still restore the Home
priority, Practice target, Review repair coach, and non-contradictory Profile
state. The proven priority remains:

1. open repair;
2. aged recheck;
3. owned-skill proof;
4. route continuation.

### Review continuation and Profile mirror

Review owns repair/recheck/replay continuation rather than a daily-planner
dashboard. It can show the active repair coach, deterministic aged rechecks,
and the supported W5/W6 session-drill recheck card. Profile is intentionally a
compact after-action mirror: current focus, recent proof, and progress are
secondary to Home's next action.

### Existing mastery, due-state, and mixed-content seams

- `Act0MasteryStatusV1` already produces per-run outcome labels such as
  `Clean pass`, `Solid`, and `Needs review`; world summaries can also provide
  future recheck/prove direction.
- Retention memory already owns `openRepair`, `agedRecheck`, and
  `ownedCandidate`, with deterministic sequence-based promotion and stable
  Home/Review ordering.
- `skillAtomId` already flows through repair receipts and feedback/telemetry
  ownership. It is a usable identity seam, not yet a durable mastery-tier
  record.
- Authored mixed-concept transfer tasks exist in later Volume I content, but
  there is no active scheduler or selection contract that turns atom evidence
  into recurring mixed recall.
- The content system and content-excellence canon already define the intended
  three tiers: `Learn` (guided), `Prove` (less guidance/mixed recall), and
  `Speed` (low guidance/faster mixed contexts). Those documents are product
  design truth; the active runtime does not yet own their per-atom state,
  eligibility, or transition rules.

### Premium-depth and curriculum boundary

`W1-W12` is the canonical Volume I shared foundation. `W13+` remains an honest
locked/coming-soon frontier until density and seam promotion are explicitly
admitted. The launch monetization boundary remains `W1-W4` free and `W5+`
future paid depth; this decision does not open a paywall, entitlement, trial,
or premium implementation.

## 3. Product target

The durable learner loop is:

`missed signal -> daily repair -> signal becomes stable enough to prove -> mixed recall tests transfer -> a real miss reopens repair -> visible improvement`

It should remain one clear next action, not a personal analytics product.

| Horizon | Learner-visible behavior | System behavior behind it |
| --- | --- | --- |
| Tomorrow | Home names the real clue to repair or recheck, and sends the learner to one targeted spot. | Existing open-repair/aged-recheck priority and reason receipt select the next action. |
| After 7 days | A signal that has survived repair receives a short proof rep with less help; a repeated miss calmly returns it to repair. | A future tier contract defines eligibility and downgrade rules from evidence already owned by the repair/retention seam. |
| After 30 days | Earlier concepts reappear in a small mixed context so the learner can see that the signal transfers, not merely that a single card was memorized. | A future deterministic mixed-recall policy selects only eligible atom families from curated inventory. |

Improvement should be visible as a compact outcome line: `repairing`, `ready to
prove`, `kept sharp`, or `repair again`. It must not become a score, a streak
threat, an XP ladder, or a broad leak dashboard.

## 4. Candidate paths

| Option | Current evidence | Benefit | Constraint / reason not selected now |
| --- | --- | --- | --- |
| A. Daily Repair Reason v1 | Already present in Home's next-useful-hand reason, Practice reinforcement, Review repair coach, and persisted Day 2 repair routing. | Keeps return value connected to a real missed/repaired signal. | **No-op for a new feature wave.** Improve only if a specific surface loses the existing reason contract. |
| B. Mastery Tier Contract v1 | Tier definitions exist in content truth; skill atom IDs, per-run mastery labels, future prove/recheck copy, and retention states already exist. | Gives existing repair/recheck evidence a durable, explainable path to `Learn -> Prove -> Speed` and later mixed recall. | Selected as a contract/spec first: no durable per-atom tier state or transition policy is currently owned. |
| C. Leaks Resurfacing Contract v1 | Open repair, aged recheck, owned candidate, due-priority, and selected W5/W6 recheck queue seams exist. | Makes repeated weak signal families return deterministically without random churn. | Defer until B fixes the eligibility vocabulary; current queue-resolution policy remains deliberately incomplete and should not be hidden with a new scheduler. |
| D. Volume I Visible Depth Plan v1 | Volume I W1-W12 is route truth; W13+ is locked/coming soon; first-week content trust is accepted. | Can later make credible course depth visible without pretending W13+ is playable. | Defer: this is packaging/content-plan work, not the highest-EV retention mechanism; it also risks reopening first-week polish or premium framing too early. |

## 5. EV ranking

Scores use `1` (low) through `5` (high). Risk is inverse: `1` is contained,
`5` is broad or unsafe.

| Rank | Candidate | Local EV | System EV | Strategic EV | Risk | Dependency readiness | Decision |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | B. Mastery Tier Contract v1 | 4 | 5 | 5 | 2 | 4 | Select as no-code contract/spec. |
| 2 | C. Leaks Resurfacing Contract v1 | 3 | 5 | 4 | 4 | 3 | Follow B; do not add a queue scheduler yet. |
| 3 | A. Daily Repair Reason v1 | 2 | 3 | 3 | 1 | 5 | Existing no-op; preserve and regression-lock. |
| 4 | D. Volume I Visible Depth Plan v1 | 2 | 3 | 4 | 3 | 4 | Defer until the mastery contract clarifies durable depth. |

## 6. Recommended next wave

### `Mastery Tier Contract v1 — Local Only`

This is a **spec-first, no-code** wave. Its objective is to make the existing
repair and retention seams capable of one future coherent progression model,
without claiming that mastery already exists.

It should define only:

1. the minimum atom identity required for tiering (`skillAtomId`, visible
   signal family, curated target availability);
2. the three learner-safe states: `Learn`, `Prove`, `Speed`;
3. deterministic promotion, hold, and downgrade evidence from existing repair,
   recheck, and prove outcomes;
4. eligibility for a later mixed-recall selection policy;
5. explicit non-goals: no score, no dashboard, no streak pressure, no broad
   scheduler, no new telemetry schema, and no commerce gate.

The selected wave should not add a tier UI. It should produce one owned
contract and a short candidate inventory of atom families that are safe for a
future tiny implementation slice. If source ownership remains split between
Act0 tasks and session-drill receipts, it must stop at the boundary rather than
invent a cross-family aggregator.

## 7. Guardrails

- Do not continue first-week polish without new P0/P1 evidence.
- Do not broaden authored content or reopen W5/W6 drill coverage in this wave.
- Do not copy Runout taxonomies, dashboards, paywall ceremonies, or progress
  theatre.
- Do not add dashboard, XP economy, ranking, streak pressure, guilt, or random
  notifications.
- Do not implement paywall, premium, entitlement, purchase, or trial behavior.
- Do not claim AI, adaptation, mastery, solver, GTO, or guaranteed improvement.
- Do not change Modern Table, routes, or screenshot tooling.
- Do not add a telemetry owner or schema. Existing local telemetry may remain
  evidence only.
- Do not commit generated screenshots, contact sheets, zips, manifests, or
  graph output.

## 8. Acceptance criteria for the selected next wave

The next wave is complete only when all of the following are true:

1. A compact contract document identifies the canonical owner candidates and
   explicitly distinguishes active Act0 task repair from W5/W6 session-drill
   receipt/recheck state.
2. It defines exact `Learn`, `Prove`, and `Speed` entry/hold/downgrade rules
   using only existing evidence types: initial outcome, repair result, recheck
   result, prove result, and deterministic sequence age.
3. It states the minimum safe mixed-recall eligibility rule and excludes atoms
   without a curated, beginner-safe mixed-context target.
4. It names the smallest later test contract: promotion after the exact proof
   threshold, downgrade after a same-signal miss, stable no-op on normal route
   continuation, and no mutation from a launch/back-out alone.
5. It preserves the existing Home priority and Review ownership; no new UI,
   route, telemetry, or content artifact is introduced.
6. It runs `graphify hook-check`, `flutter analyze`, `git diff --check`, and
   `git status --short`. Stop if the proposed owner cannot safely cover both
   Act0 and session-drill evidence without an explicit cross-family contract.

## Decision record

- Product/code changed in this wave: **no**.
- First-week trust lane: **closed** unless new P0/P1 evidence appears.
- External review packaging: **deferred** because no real external recipient is
  currently in scope.
- Generated artifacts: **local-only and uncommitted**.
