# MASTER PLAN v2.2 (SSOT)
Status: ACTIVE
Readiness scoring SSOT:
- docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md
Supersedes:
- docs/plan/MASTER_PLAN_v2.1.md
- docs/MASTER_PLAN_6.0_SSOT.md
- docs/archive/MASTER_PLAN_5.0_CLOSEOUT.md
- docs/_archive/DEPRECATED__Master_Plan_5.0.md
- docs/_archive/DEPRECATED__Grand_master_plan.md
Last updated: 2026-03-23

⸻

MASTER PLAN v2.2

(FROZEN Execution Plan + Deterministic Economy Integration)
Compatible with ULA v4.3.1 + Deterministic Engineering
Status: ACTIVE SSOT

Project-readiness scoring and final-`100/100` interpretation are governed by
`docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`. Use that document for progress
reporting, bottleneck calibration, and final-readiness interpretation; do not
replace it with seam-only percentage estimates or reuse the historical beta-path
score.

⸻

0) Non-Negotiable Invariants

These cannot be violated.
    1.    Deterministic runtime — no RNG in runtime logic.
    2.    Fail-fast content — invalid refs/content → hard fail (validator gate).
    3.    ASCII-only keys; append-only enums; versioned parsers.
    4.    Exactly-once spend — idempotent ledger; no double charge.
    5.    One primary CTA — “Today” dominates.
    6.    Low ops burden — no daily manual curation.
    7.    Proof-first — deterministic tests + screenshot proofs are contract.

⸻

1) Product North Star

We build a deterministic, table-first poker trainer for the mass market.

Target transformation:
absolute beginner → confident poker thinker.

Core properties:
    •    daily ritual loop (Today)
    •    visible cognitive shift per world
    •    long-term depth without infinite AI content
    •    no solver-first complexity
    •    no PvP dependency
    •    deterministic engineering at all layers

⸻

2) Milestones (Frozen Order)

M0 — Foundation Locked (DONE)
    •    deterministic runner/table harness
    •    Today spine deterministic
    •    Leaks + resolution suppression
    •    cohort persistence + promotion (minimal)
    •    validator gates active

⸻

M1 — MVP Content (Worlds 0–4)

Scope:
    •    curated micro-sessions per ULA
    •    deterministic content pipeline
    •    strict QA gates (lint + poker correctness + pedagogy)

Constraints:
    •    no reordering worlds
    •    no new engine
    •    no solver trees
    •    no infinite content

MVP Definition:
Worlds 0–4 complete and stable.

⸻

M2 — Post-MVP Expansion (Worlds 5–9)
    •    Continue content production.
    •    Keep deterministic system unchanged.
    •    Introduce Mastery Tiers v1.
    •    Introduce Personal Crucible (Leaks v2 rules first, no backend).

No structural refactors allowed.

⸻

M3 — Sharky v1 (Emotion Layer)
    •    curated phrases only
    •    no AI chat
    •    1 phrase before session
    •    1 reaction after outcome
    •    1 identity reinforcement

No open-ended conversations.

⸻

2A) Runner / Launcher Closure Snapshot

Accepted / close enough:
    •    SessionDrillPlayerV1Screen
    •    DrillRunnerScreen
    •    SessionResultScreen
    •    World 10 cluster inside SessionDrillPlayerV1Screen
    •    runner-route hardening wave
    •    canonical truth/runtime hardening wave
    •    learning-path / launcher boundary convergence

Deferred:
    •    World1FoundationsMicroTaskRunnerScreen felt-caption / runner-instruction seam

Residual seams below threshold:
    •    SessionResultScreen continuation / primary execution routing

⸻

2B) Runner / Launcher Reopen Trigger Register

Reopen SessionDrillPlayerV1Screen only on:
    •    regression, or
    •    materially new bounded seam

Reopen DrillRunnerScreen only on:
    •    regression, or
    •    materially new bounded seam

Reopen SessionResultScreen only if:
    •    continuation / execution routing becomes materially load-bearing

Reopen World1FoundationsMicroTaskRunnerScreen only if:
    •    a bounded entry seam is isolated from geometry / mode-switching entanglement

⸻

2C) Current Route Note

    •    No better bounded implementation frontier is admitted now.
    •    Do not force more runner / launcher micro-steps.
    •    If later evidence justifies reopening a route, the next candidate is
         SessionResultScreen continuation / primary execution routing ownership.

⸻

3) Today Loop Contract (Primary Habit Engine)

Today Router Ladder (SSOT):
    1.    If daily gauntlet not completed → open gauntlet
    2.    Else if leaks due → open leaks (capped)
    3.    Else → Practice Mode (no farming rewards)

UX Rules:
    •    3–10 minutes “done for today”
    •    no dashboard overload
    •    one dominant CTA only
    •    minimal theory text (1–2 lines before action)

⸻

4) Deterministic Gauntlet System

Daily gauntlets are NOT authored manually.

They are generated via:

templates → deterministic compiler → schedule snapshots (90 days)

Version boundaries (mandatory):
    •    gauntlet_template_version
    •    schedule_version
    •    content_schema_version

Invariants:
    •    no RNG
    •    no unlock_if logic in v1
    •    no weighted randomness
    •    stable ordering
    •    no state bleed between steps

Snapshots are immutable.
Changes require new schedule_version.

⸻

5) Economy & Monetization Architecture (Integrated Layer)

Economy is architecturally integrated but operationally minimal in MVP.

v1 Rules
    1.    Core Worlds are free.
    2.    One free Today entry per UTC day.
    3.    Paid retries disabled until retention validated.
    4.    Subscription is defined but not UI-exposed initially.

Subscription (future activation):
    •    +N or unlimited Today entries/day
    •    Mastery Tier access
    •    Leaks insights analytics

No aggressive paywalls.
No energy mechanics.

⸻

Chips Policy (Anti-Inflation / Anti-Lockout)
    •    Earn via first-time completions.
    •    Small deterministic daily drip.
    •    No infinite farming loops.
    •    No decay/reset in v1.

⸻

Exactly-Once Spend (Mandatory Contract)

All economy actions must be idempotent:
    •    txn_id required
    •    duplicate application returns “already applied”
    •    rebuild-safe

Ledger must be deterministic and test-covered.

⸻

Entitlement Model (Hooks-Only in MVP)

Even if UI paywall is not enabled:
    •    entitlement state must exist
    •    Today entry consumption must respect entitlement
    •    1 free/day enforced by contract

UI gating may be added later without refactoring core logic.

⸻

6) Mastery Tiers v1 (Vertical Depth Multiplier)

Goal:
Multiply lifespan of content without rewriting it.

v1 scope:
    •    2 tiers: micro, high
    •    knobs <= 3:
    •    timer
    •    hints_off
    •    lives=1

Config versioned:
    •    tier_config_version

No balancing explosion.

⸻

7) Leaks v1-lite (Value Loop)

Purpose:
Make the app a tool, not just a course.

Scope:
    •    local append-only log
    •    UTC timestamps
    •    deterministic due function
    •    daily cap (5–10)
    •    stable ordering

Version boundary:
    •    queue_algo_version

No backend yet.

⸻

8) Stop Rules (No Rocket Clause)

Hard stops:
    •    no infinite AI content
    •    no solver trees
    •    no rewriting world order
    •    no parallel product
    •    no “while we’re here” features

Any new idea must answer:
    1.    Does it increase D7 or conversion materially?
    2.    Can it be implemented without structural refactor?

If not — defer.

⸻

9) Release Criteria — Definition of Ready 1.0

App is considered “ready” when:
    1.    Today loop fully deterministic and stable.
    2.    Endless perception exists (gauntlets + tiers + leaks).
    3.    Content platform fully validated and versioned.
    4.    Exactly-once spend proven by contract tests.
    5.    1 free Today/day enforced.
    6.    Subscription hooks defined (UI optional).
    7.    90-day schedule snapshot generated and immutable.
    8.    Low ops burden (no manual daily curation).

⸻

10) M4 — Placement + Trial Onboarding (v1)

Goal:
    •    Determine player level quickly with a short deterministic placement path.
    •    Personalize the entry point into worlds/sessions using existing progression rails.
    •    Offer a clear 7-day trial path using existing subscription hooks (no payments in v1).

Constraints:
    •    deterministic execution only (no RNG)
    •    reuse existing drill kinds: action_choice, seat_tap, board_tap, hole_cards_tap
    •    no schema changes in v1
    •    no new dependencies in v1
    •    no Today loop or economy regressions
    •    telemetry required: placement_start, placement_end, placement_result_bucket, time_to_decision

Definition of Done:
    •    placement test completes in <= 3 minutes with 6-12 items
    •    produces PlacementResultV1: bucket, confidence, weakAreas
    •    adaptive entry routing selects deterministic starting world/session set
    •    7-day trial entitlement skeleton wired through existing premium facade (no payment flow)
    •    cohort gate defined for placement vs no-placement
    •    Tier0 gates listed and passing for placement surfaces

Stop Rules / Anti-Drift:
    •    no UI redesign while wiring placement v1
    •    no new content schema or drill kind
    •    no “while we are here” routing changes outside placement path
    •    if implementation needs refactor across >3 files in first step, stop and split
    •    if deterministic telemetry contract is unclear, stop and define contract first

⸻

11) M5 — Unified Visual + UX Cohesion Pass (v1)

Objective:
    •    unify look and feel across Progress Map, Intake/Today Plan, Runner, and Session Result
    •    keep primary CTA placement, typography scale, spacing rhythm, and copy tone consistent
    •    enforce consistent token and color usage with no screen-specific random styling

Scope (strict):
    •    allowed zones: lib/ui_v2/** screens/components, SSOT token file in lib/ui_v2/** if already approved, docs/** closeout
    •    forbidden: content/** changes except broken references, tools/** changes, schema changes, new dependencies
    •    forbidden: large refactors, renames, moves, and beauty polish without measurable UX reason

Definition of Done:
    •    unified behavior and visual rhythm across 4 core surfaces: Progress Map, Universal Intake/Today Plan, Runner table-first, Session Result
    •    single dominant primary CTA pattern is consistent across surfaces
    •    header spacing rhythm is consistent and no split-app feel remains
    •    typography clamp rules are consistent: maxLines/ellipsis and no overflow regressions
    •    token and color usage is consistent across surfaces with no mismatched neutral/accent use
    •    determinism and performance constraints preserved: no RNG visuals, no heavy BackdropFilter/Opacity stacks
    •    Tier0 plus fast loop remain green after each PR

Execution protocol:
    •    max 2-3 controlled PRs:
    •    PR1: layout hierarchy, CTA standardization, header rhythm
    •    PR2: typography and spacing normalization
    •    PR3 optional: token usage cleanup only if needed
    •    every PR must include PIEC, narrow change-zone list, PASS evidence (dart format/analyze plus fast_loop_world1_v1.sh), and clean git status
    •    STOP rule: reject any change justified only as looks nicer without inconsistency, clarity, or overflow evidence

Audit readiness:
    •    rerun Audit 1 core consensus with UX cohesion focus after M5 closes

⸻

12) M6 — Visual Perfection Pass (v1)

Objective:
    •    deliver one unified visual language across Map, Intake, Runner, Result, and Table surfaces
    •    eliminate mixed token usage so palette, contrast, and iconography are consistent
    •    remove stitched-feel inconsistencies without drifting into open-ended polish work

Scope (strict):
    •    allowed zones: lib/ui_v2/** and approved design token contract file(s) only
    •    forbidden: content/**, tools/**, schema changes, new dependencies, and broad refactors
    •    forbidden: changes justified only as visual preference without a concrete inconsistency

Definition of Done:
    •    token usage audit completed with no ad-hoc random neutrals/accents per screen
    •    table visuals are coherent with app surfaces while preserving determinism and performance constraints
    •    map visuals are coherent with intake/runner/result visual language
    •    screenshot and fast-loop invariants remain green after each pass

Execution protocol:
    •    max 2-3 controlled PRs:
    •    PR1: token usage audit and removal of ad-hoc colors
    •    PR2: table plus map visual coherence fixes
    •    PR3 optional: micro cleanup only when tied to a checklist inconsistency
    •    STOP rule: reject any change that is only nicer with no checklist-backed inconsistency

⸻

13) M7 — Journey Unification (v1)

Naming decision:
    •    user-facing term is "Level" across progression UI
    •    internal ids remain world0..world9 and are not renamed

Objective:
    •    unify progression into one journey model from Level 0 through Level 9
    •    use a single circular path renderer across all levels
    •    make level progression transitions explicit and deterministic

Definition of Done:
    •    Level 0 uses the same circular node renderer as Level 1+ (no Act0 card model in production UI)
    •    one canonical renderer is used across all levels
    •    explicit "Level complete -> Next level" CTA is present and deterministic
    •    "Levels" button opens a locked/unlocked list and allows replay for completed levels
    •    no schema/content/tools changes and no new dependencies
    •    ./tools/fast_loop_world1_v1.sh remains green

Stop rules:
    •    no redesign beyond renderer/journey unification
    •    no new mechanics or economy coupling
    •    no routing expansion beyond level transition clarity and levels-list access

⸻

14) Repo SSOT Placement

The following documents are canonical:
    •    docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.3.1.md
    •    docs/content/CONTENT_SYSTEM_v2.1.md
    •    docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md
    •    docs/plan/MASTER_PLAN_v2.2.md

All older versions moved to:
docs/_archive/ and marked DEPRECATED.

⸻

Status

MASTER PLAN v2.2 is the only active execution SSOT.
It supersedes v2.1 and integrates the economy invariants from v1.1.1 without expanding MVP scope.

⸻
