# EXECUTION_POLICY_SSOT_v1

Status: ACTIVE
Purpose: compact execution-policy SSOT so future Codex prompts can reference
one default policy file instead of repeating the same global rules, while still
allowing larger admitted rebuilds when they are the highest-EV path toward
practical `100 / 100`.
Last updated: 2026-05-22

## Authority

Use this file beneath:

- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/ACT0_PRODUCT_100_EXECUTION_ROUTE_v1.md`
- `docs/plan/FULL_PRODUCT_READINESS_LEDGER_v1.md`
- `docs/l10n/TRANSLATION_SSOT_v1.md`

This file is the compact execution-policy wrapper for current Act0 work.

Use it for:

- default execution-policy rules
- prompt compactness
- default reopen / rebuild discipline
- current deferred-lane and closed-watch rules
- next-wave recommendation rules

Do not use it for:

- replacing `MASTER_PLAN_v3.0.md` as route-order authority
- replacing `FULL_PRODUCT_READINESS_LEDGER_v1.md` as readiness authority
- replacing `TRANSLATION_SSOT_v1.md` as localization-owner authority
- justifying uncontrolled scope expansion

## 1. Primary Route

- `W1-W12` must become scale-ready before any `W13-W24` expansion.
- Do not recommend `W13-W24` expansion until `W1-W12` scale-ready gates are
  met.
- The goal is not endless micro-polish.
- The goal is a reusable, high-quality world factory that makes further world
  expansion cheaper, safer, and more consistent.

## 2. Human Novice QA

- Human Novice QA remains deferred until a stronger visible `W1-W12`
  demo-quality threshold is met.
- Do not recommend Human Novice QA as the next wave by default.
- Controlled internal demo ready does not automatically mean Human Novice QA
  ready.
- Reopen it only after the pre-human visible-quality gate is green enough that
  novice feedback will measure the product instead of known unfinished tails.
- Required pre-human visible-quality gate:
  - full controlled-demo packet is green
  - no dominant visible UX or visual blocker is known
  - the `Learn -> Runner -> Feedback -> Review -> Practice -> Profile` story is
    understandable in one walkthrough
  - Practice, Profile, and World Completion payoff do not feel obviously thin
  - compact phone presentation is demo-safe
  - content transfer gaps are not obvious in the walkthrough
  - fast loop is green
- This gate does not require:
  - broad RU completeness
  - `W13-W24`
  - monetization or paywall readiness
  - public store, legal, or release readiness
  - final brand-polish or Deep Ocean completion
- Until that gate is clearly met, prefer:
  - a visible `W1-W12` demo-quality push, or
  - one top blocker from the controlled-demo packet
  instead of novice testing.

## 3. Closed-Watch Areas

- Home composition / daily checklist is `closed-watch`.
- Do not reopen Home without fresh blocker evidence.
- `ModernTableScreenV1` remains out of scope unless active route proof requires
  it.

## 4. Deferred Lanes

- Broad RU localization remains deferred; use `docs/l10n/TRANSLATION_SSOT_v1.md`
  for localization ownership.
- Deep Ocean Gold remains a separate visual/theme lane; do not run token
  migration unless it is explicitly admitted.
- Store / legal / release ops are not primary product-hardening by default and
  should only be admitted when the wave is explicitly release-facing.
- Monetization / paywall remains deferred unless explicitly admitted.
- Telemetry implementation remains deferred unless explicitly admitted.
- `Telemetry Truth Map` may be admitted separately as a planning / proof-owner
  wave without reopening broad implementation.

## 5. High-EV Reopen / Rebuild Gate

Default mode is small bounded waves, but larger changes are allowed when they
are the highest-EV path to `100 / 100`.

A closed area, deferred lane, or bigger rebuild may be admitted only if all of
the following are true:

- there is fresh evidence of a real blocker or major opportunity
- the issue cannot be solved well by a smaller local repair
- expected product/readiness gain is materially higher than a micro-fix
- the owner seam is clear
- the rollback plan is clear
- verification / DoD is clear
- the change moves `W1-W12` closer to scale-ready `100 / 100` or improves full
  product readiness
- it does not create uncontrolled scope drift

Allowed examples:

- Learn presentation rebuild if compact density / utility feel cannot be fixed
  locally
- Profile payoff restructure if the current card-stack model blocks learner
  identity
- Review flow restructure if repair / recheck / prove feels system-shaped and
  hurts retention
- telemetry spine if the learning loop cannot be validated without it
- Deep Ocean Gold token migration if `v1.1` is proven readable and
  product-positive
- World Completion visual milestone rebuild if the current stacked payoff model
  blocks milestone emotion

Not allowed examples:

- reopening Home for taste-only polish
- expanding to `W13-W24` before `W1-W12` are scale-ready
- broad RU localization without admission
- `ModernTableScreenV1` work without active route dependency
- redesigning because a new idea is interesting but not proven high-EV

## 6. Anti-Stagnation Rule

- Do not get trapped in endless `+0.5` micro-waves if a structural change would
  produce a larger, cleaner EV gain.
- If `2-3` consecutive waves in one area produce only small proof/copy deltas
  while the same core issue remains, Codex must explicitly consider whether a
  higher-EV restructure should be proposed through the Reopen / Rebuild Gate.

## 7. Prompt Compactness Rules

- Future prompts should reference this file instead of repeating long global
  policy blocks.
- Prompts should include only:
  - wave admission
  - exact scope
  - allowed changes
  - wave-specific forbidden changes
  - target files / seams if known
  - tests / verification
  - report format
- Do not repeat long global policy blocks unless policy changed.

## 7A. Screenshot Acceptance Contract

For every screenshot-driven visual or product wave, define the acceptance target
before editing:

- `Acceptance target:` exact visual artifact to remove or change
- `Must disappear/change:` the exact bad artifact that should no longer be
  visible
- `Must remain:` the required visible artifacts that preserve route truth
- `Target surface:` the screen being judged
- `Target viewport:` exact width and height
- `Target route/progress state:` the specific selected lesson, backlog, XP, or
  similar state that matters
- `Target platform:` web, iOS/native, or another live platform when the issue
  came from user evidence there

After editing, Codex must verify the same artifact, state, viewport, and
platform when practical.

Rules:

- manifest success, semantics success, or widget-test success alone are not
  enough when screenshot or live user evidence contradicts them
- if the selected target artifact is still visible, the wave is not complete
- if the artifact remains visible, readiness delta must stay `0`
- if the exact artifact/state/viewport cannot be recaptured, Codex must state
  the limitation explicitly instead of claiming success

Future screenshot-driven reports should include only this compact block:

- `Acceptance target:`
- `Must disappear/change:`
- `Must remain:`
- `Verified viewport/state:`
- `After-screenshot verdict:`
- `Divergence verdict, if applicable:`
- `Readiness delta:`

Do not add long screenshot descriptions unless a failure requires explanation.

## 7B. Runtime Divergence Protocol

If user or live screenshot evidence contradicts harness output, treat the user
or live screenshot as failing evidence.

Codex must compare:

- viewport width and height
- route and progress state
- platform: web versus iOS/native or other live runtime
- build freshness and stale simulator / stale app possibility
- the active visible renderer branch

Closure is not allowed until the divergence is:

- explained and fixed
- explained and proven stale with fresh matching proof
- or explicitly waived as a known limitation

Do not treat a cleaner harness artifact from a different state or width as
closure for the live issue.

## 7C. Responsive UI Rule

If the issue depends on responsive layout:

- do not rely only on the default `393x852` proof lane
- test the observed live width and state when practical
- add focused proof for the observed width and state when practical
- if the observed width or state cannot be reproduced, report the limitation
  and do not move readiness

## 7D. Verification Tiering

Use the smallest relevant proof lane by default.

- Tier A — Local visual/layout sprint
  - `git diff --check`
  - focused syntax checks for touched shell tools when applicable (`bash -n`)
  - `flutter analyze`
  - the relevant mini-loop only, with `./tools/fast_loop_runner_compact_v1.sh`
    as the default runner-layout proof lane
  - targeted screenshot or live-check when the wave is visual
  - do not run `./tools/fast_loop_world1_v1.sh` by default for runner-only
    visual/layout work
- Tier B — Product state change
  - `git diff --check`
  - `flutter analyze`
  - targeted state/progression tests and touched-surface tests
  - use the state-first `./tools/fast_loop_world1_v1.sh` lane when the change
    crosses route, progression, review/recheck/prove, or shell state truth
- Tier C — Final closeout
  - `./tools/fast_loop_world1_v1.sh`
  - add the selected full proof for the active feature family when the wave
    touched copy, campaign packs, localization, telemetry, or other guarded
    seams outside the default state-first lane
- Tier D — Release gate
  - `./tools/release_gate_world1.sh`
  - include l10n, residue, campaign/legal, telemetry, and other release-facing
    guards only when the touched files or explicit release mode require them

Rules:

- Avoid rerunning the same selected test family twice in one default local loop.
- Keep route/state/progression/recovery guards available for state-change waves.
- Keep copy, localization, campaign, and telemetry guards opt-in or
  change-triggered outside release/checkpoint lanes.

## 7E. Agent Fast-Lane Protocol

Goal: reduce Codex / Antigravity execution time per admitted wave without
dropping the safety core.

### Agent modes

- Visual Sprint Mode, mostly Antigravity
  - use for local UI, layout, typography, spacing, focus, and other bounded
    visual changes
  - edit only the named file or clearly admitted fence unless stopping to
    report or ask
  - do not create `implementation_plan.md`, `task.md`, `walkthrough.md`, or
    similar planning artifacts by default
  - do not run a broad repo scan
  - do not run a baseline test first unless the task is to diagnose the current
    red state
  - do not add tests by default
  - do not touch docs or readiness ledgers by default
  - do not run `./tools/fast_loop_world1_v1.sh` by default
  - finish with Tier A proof only
- Contract Mode, mostly Codex
  - use for route, state, capability, telemetry, content, and other contract
    seams
  - keep investigation bounded to the owner seam and direct dependents
  - reproduce only what is needed when the seam is red
  - run targeted tests first
  - run `./tools/fast_loop_world1_v1.sh` only when policy requires or when the
    change crosses state/progression truth
  - give a detailed report only when proof is red or the contract actually
    changed
- Closeout Mode
  - use only at feature-family closeout
  - full proof is allowed here
  - a broader report is allowed here
  - do not start new product work unless the closeout proof exposes a real
    regression

### Fast-lane command budget

- Tier A local visual/layout waves should end with only:
  - `dart format` on the touched Dart file when needed
  - `flutter analyze`
  - the relevant mini-loop
  - `git diff --check`
  - a targeted screenshot or live check when the wave is visual
- Forbidden by default in Tier A:
  - `./tools/fast_loop_world1_v1.sh`
  - `./tools/release_gate_world1.sh`
  - full controlled-demo packets
  - broad test discovery
  - baseline plus final reruns of the same suite
  - planning artifacts

### Exploration budget

- For local waves:
  - inspect only the target file and the direct owner seam first
  - use search only for referenced symbols or explicit owner confirmation
  - stop and report if a second owner file not admitted in the prompt becomes
    necessary
  - do not read broad SSOT docs unless the task is policy, state, or contract
    work

### Report compression

- Default Tier A report shape:
  - `Files changed`
  - `Change`
  - `Proof`
  - `Visual verdict`
  - `Next`
- Use a detailed report only for:
  - failing proof
  - state, route, or content changes
  - acceptance or recovery waves
  - final closeout
  - release gate

### Auto-stop rules

- Stop and report instead of continuing when:
  - a forbidden file would need to change
  - route, state, content, or shared-shell seams become implicated
  - a mini-loop fails from an unrelated family
  - a screenshot or live check contradicts the claimed closure
  - the next step would require adding tests or docs
  - the task is drifting into a broader refactor

### Auto-admission rules

- One additional micro-fix in the same run is allowed only when all are true:
  - same file
  - same visual family
  - no new tests or docs
  - same verification tier
  - no forbidden files
  - the first fix is already green
  - the second issue is obvious and directly adjacent
- Otherwise, stop after one fix and report.

## 8. Readiness Reporting Rules

- Follow `docs/plan/FULL_PRODUCT_READINESS_LEDGER_v1.md`.
- Default wave delta is `0`.
- Report only changed blocks and unit deltas.
- Aggregate readiness must come from unit-based scoring, not optimism:
  - `earned_units = sum(current block units)`
  - `max_units = sum(max block units)`
  - `aggregate_readiness = earned_units / max_units`
- Separate delta types:
  - `Product Quality Delta`
  - `Proof Confidence Delta`
  - `Release Readiness Delta`
  - `Documentation / SSOT Clarity Delta`
- Do not move readiness unless the wave materially reduced a named risk:
  - `user-facing quality risk`
  - `proof / confidence risk`
  - `release / commercial risk`
  - `operational clarity risk`
- Do not move `Act0 Route Mechanics` above `93` without a broad route
  milestone.
- Do not confuse `Act0 Route Mechanics` with `Full Product Readiness` or
  `Commercial / Release Readiness`.
- Proof-only waves mostly move `Technical Proof / CI`.
- Visual waves move `Visual Premium / Cross-Screen` or `Deep Ocean Gold /
  Brand Theme` only.
- Audit-only visual proof may move evidence confidence without moving visual
  quality if no UI changed.
- Translation cleanup moves `RU / Localization` only if SSOT clarity improves.
- Store / legal audits do not move product readiness unless artifacts
  materially improve.
- Documentation-only waves do not move product quality unless they materially
  unblock execution.
- If no underlying block units changed, aggregate scores do not move.
- Future unit movement must reference the relevant block DoD criteria in
  `docs/plan/FULL_PRODUCT_READINESS_LEDGER_v1.md`.
- Remaining units are readiness gaps, not tiny implementation tickets; do not
  score local details unless they materially reduce a named block risk.
- Future reports must also state whether a wave affects additive readiness
  units, a dependency gate, both, or neither.
- Gate movement does not automatically change units, and unit movement does not
  automatically open a readiness gate.

## 8A. Foundation Depth / Transfer Standard

Coverage is not enough for foundation readiness.

A concept is not readiness-complete unless it has enough depth across this
ladder:

1. `Recognition`
2. `Explanation`
3. `Visual table proof`
4. `Comparison`
5. `Guided decision`
6. `Independent transfer`
7. `Mistake recovery / review reuse`

Execution rules:

- do not close a foundation concept family from concept presence alone
- use this ladder when auditing `Hand Strength`, `Best Five / Showdown`,
  `Positions / Action Order`, `Legal Actions`, `Pot / Stack`, `Board
  Reading / Draws`, and similar table-first families
- where relevant, require best-five proof, visible winner proof, or
  misconception-specific feedback instead of relying only on answer-key truth
- treat review/practice/recheck/prove reuse as part of readiness, not as a
  nice-to-have after content coverage is done

Coverage illusion:

- a concept can be present in content and still not be ready
- common illusion cases:
  - no visual table proof
  - no adjacent comparison
  - no transfer into a decision drill
  - no best-five / showdown proof where relevant
  - generic wrong-answer feedback instead of misconception teaching
  - no mistake-recovery or review reuse

External benchmark rule:

- `docs/curriculum/CONCEPT_BENCHMARK_v1.md` may be used as an external
  benchmark/checklist for detecting coverage illusion
- do not import all items from
  `docs/curriculum/CONCEPT_BENCHMARK_v1.md` as a giant backlog
- use it to rank concept-family gaps by EV and choose the next bounded repair
  wave
- use `docs/curriculum/LEARNING_UNIT_ACCEPTANCE_STANDARD_v1.md` when judging
  whether a concept is carried by a real byte, lesson, or world instead of a
  shallow prompt fragment
- future content/depth waves must classify unit ownership, placement type,
  prerequisites, and chronology fit before implementation

Learning-unit rule:

- do not treat one question as a real byte unless it forms a minimal reusable
  skill loop
- do not treat one byte as a full lesson unless it forms part of one practical
  skill sequence
- do not treat one lesson as a full world unless the world also proves staged
  progression, transfer, review/recovery, and milestone payoff
- if a learner-facing task renders a table/card scene, the learner action
  should use that visible scene unless the task explicitly teaches notation
- raw notation such as `Ah`, `Qh`, `h`, or `A` is not enough by itself for core
  poker understanding; notation must be connected to visible cards and human
  poker language

## 9. Agent Recommendation Rules

- Codex should recommend the next highest-EV bounded wave inside the active
  route.
- The default active route is `W1-W12` scale-ready foundation.
- If recommending a deferred lane or larger rebuild, Codex must state which
  Reopen / Rebuild Gate trigger was met.
- If no trigger is met, recommend the next bounded `W1-W12` scale-ready wave.

## Bottom Line

- Keep the default lane compact, bounded, and evidence-led.
- Do not confuse compact prompts with small-thinking policy.
- The default is narrow execution.
- The exception is a clearly proven higher-EV rebuild that moves the active
  route or full product meaningfully closer to `100 / 100`.
