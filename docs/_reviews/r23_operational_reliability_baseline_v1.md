# R23 Operational Reliability Baseline v1

## 1) Scope and Evidence Sources
This baseline covers recurring post-launch operational reliability/process friction only.
No feature scope is included.

Evidence sources:
- `docs/ROADMAP_FINAL_100_SSOT.md` (R23 scope, DoD, gates, stop rules)
- `docs/_reviews/r22_post_launch_execution_focus_v1.md`
- `docs/_reviews/r22_production_reality_audit_v1.md`
- `docs/_reviews/r22_stabilization_plan_v1.md`
- `docs/_reviews/r21_launch_checklist_v1.md`
- `docs/_reviews/r21_launch_verdict_v1.md`
- `tools/fast_loop_world1_v1.sh`
- `tools/release_gate_world1.sh`

## 2) Ranked Recurring Failure/Friction Modes

### 1. Milestone continuity gap (ACTIVE advanced before milestone section existed)
- Classification: P1 important reliability issue.
- Recurrence evidence: R22 evidence block explicitly recorded missing R23 section while ACTIVE had already moved.
- Impact: execution stalls and ambiguous scope boundaries.
- Deterministic handling rule:
  1) Before switching ACTIVE to `RX`, assert `# Milestone RX` exists in SSOT.
  2) If missing, block switch and create the milestone definition first.
  3) Keep exactly one authoritative `Current execution state` line at document end.

### 2. Formatter-driven release-gate block recurrence
- Classification: P1 important reliability issue.
- Recurrence evidence:
  - `r22_production_reality_audit_v1.md` logs gate caveat: `dart format --set-exit-if-changed` can block release cut.
  - `tools/release_gate_world1.sh` enforces formatter step before gates.
- Impact: operational delays and avoidable gate failures on otherwise valid commits.
- Deterministic handling rule:
  1) Run `dart format --set-exit-if-changed .` before `release_gate_world1.sh` on release candidates.
  2) If red, allow only a format-only commit; no mixed logic changes.
  3) Re-run release gate on the format-unblocked commit.

### 3. Late proof-gap closure pattern (behavior exists, contract evidence lags)
- Classification: P1 important reliability issue.
- Recurrence evidence:
  - `r22_stabilization_plan_v1.md` included convergence hardening as contract-first gap closure.
  - Closed by deterministic tests in commit `464f915f1` after audits identified proof gap.
- Impact: false ambiguity in risk status and delayed closeout.
- Deterministic handling rule:
  1) When audit finds "partially proven", add the smallest contract test first.
  2) Runtime change is allowed only if new contract fails and proves mismatch.
  3) Close item only after gate pass on contract-hardening commit.

### 4. PRE/POST cleanliness friction
- Classification: P2 minor process friction.
- Recurrence evidence:
  - Checklist and SSOT tasks repeatedly require clean PRE/POST; failures are mostly hygiene, not runtime defects.
- Impact: small execution delays, low product risk.
- Deterministic handling rule:
  1) Hard-check `git status --porcelain` before and after each slice.
  2) If dirty PRE, run hygiene-only resolution first (revert/commit), then restart slice.

### 5. Not a real recurring issue
- Feature/runtime route integrity regressions in launch-critical loop.
- Classification: Not a recurring issue in current evidence.
- Evidence: R21 launch verdict GO + R22 production audit report no P0 route/checkpoint regressions.

## 3) Included R23 Reliability Slice for P0.2 (exactly one)
Recommended bounded slice:
- **R23 P0.2 target: formatter gate-block recurrence hardening (process/contract only).**

Why this single target:
- Highest repeated operational friction with direct gate impact.
- Fully bounded to process/runbook/contract handling; no product behavior changes required.
- Aligns with R23 scope: operational reliability and anti-drift.

Expected bounded output in P0.2:
- One deterministic handling contract/runbook update that enforces pre-gate formatter discipline and format-only unblock policy.

## 4) Explicit Defer List (non-reliability)
Defer outside R23:
- feature expansion,
- schema or telemetry redesign,
- monetization architecture redesign/store unification,
- new content/world/track scope,
- broad refactors or UI polish.

## 5) Anti-Drift Note
R23 execution is reliability-only. Any proposed task that does not reduce recurring operational failure risk should be rejected or deferred.
