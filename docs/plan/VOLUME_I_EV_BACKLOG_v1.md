# Volume I EV Backlog v1

## 1. Verdict

Verdict: `volume_i_claude_findings_triage_ev_backlog_landed`

Purpose: durable EV-ranked backlog for the accepted Claude findings. This is planning only; it does not admit routes, implement fixes, execute Human QA, or move scores.

## 2. Immediate Pre-Route Fix Pack

Recommended next wave: `Volume I Pre-Route Naming Copy Capstone Contract v1`

Objective: resolve the smallest high-EV P1 contract before route admission planning by locking W7 naming/positioning, W9/W10 differentiation from W4, W12 capstone/repair specificity, and the actual-copy/soft-claim review surface.

Focused fixes:

1. W7 naming and W7 learner-facing positioning contract.
   - Covers: C01, C13.
   - Expected EV: high premium trust and clarity; prevents W7 from feeling weaker than W6.
   - Bounded output: accepted W7 display-name/positioning rule plus "Lite" suffix policy.
   - Forbidden scope: no route opening, runtime card unlock, UI redesign, or content expansion.
2. W9/W10 differentiation and soft-copy safety contract.
   - Covers: C04, C05, C11, C15 plus terminology follow-ups C02, C03, C06, C12 where visible in copy.
   - Expected EV: high learning clarity and claim safety before any learner-facing route.
   - Bounded output: copy/spec rules for prompts, choices, feedback, intros/outros, and forbidden implication phrases.
   - Forbidden scope: no task implementation, no Flutter tests unless a later copy/test wave touches source, no screenshot review.
3. W12 capstone scope and repair specificity decision.
   - Covers: C07, C08.
   - Expected EV: high capstone credibility, retention, and route readiness.
   - Bounded output: decide expand vs Review Session vs cue-mapping contract, and define specific W12 repair focus IDs.
   - Forbidden scope: no fixture expansion, route admission, Practice CTA, mapper mutation, or Human QA execution.

Route admission remains blocked until this pack lands or its P1 risks are explicitly accepted in writing.

## 3. EV-Ranked Accepted Backlog

Sorted by EV/scope ratio:

| Rank | IDs | Backlog item | Timing gate | Owner | Scope | EV |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | C01, C13 | Rename/position W7 and remove premium-negative "Lite" semantics. | before route admission planning | product decision, Codex | docs-only, copy-only | premium trust, clarity |
| 2 | C04, C05 | Define W9/W10 differentiation from W4 in learner-facing terms. | before route admission planning | Codex | docs-only, copy-only | learning EV |
| 3 | C07, C08 | Resolve W12 capstone scope and specific repair focus. | before route admission planning | product decision, Codex | docs-only, fixture/spec | learning EV, retention |
| 4 | C11, C15 | Verify actual W7-W12 copy and add soft-overclaim safety rules. | before route admission planning | Codex, Claude follow-up | copy-only, test-only later | claim safety, clarity |
| 5 | C02, C03, C06 | Check visible jargon in W7/W8/W11 and require beginner explanation. | before public copy | Codex | copy-only | clarity |
| 6 | C12 | Add progression-implied claim guard for world order and completion copy. | before public copy | Codex | docs-only, copy-only | claim safety |
| 7 | C09 | Define learner-facing repair signal criteria. | before route admission implementation | Codex | copy-only, runtime later | retention |
| 8 | C10 | Define cross-world W9/W10 repair handling. | before route admission implementation | Codex | docs-only, runtime later | retention, learning EV |
| 9 | C14 | Review scenario richness beyond IDs and concept labels. | before Human QA | Claude follow-up, Human QA | fixture/spec | commercial quality |
| 10 | C16 | Prepare Human QA prerequisites after copy/scenario/repair artifacts exist. | before Human QA | Human QA | Human QA | Human QA readiness |
| 11 | C17 | Convert resolved P1s into route admission planning gates. | before route admission planning | Codex | route-gate later | route readiness |

## 4. Deferred And Rejected Backlog

Deferred:

- Route/stale-resume implementation, mapper allowlist, Practice CTA, and post-W6 progression design. Trigger: route-admission implementation prompt after the immediate fix pack.
- Human QA execution. Trigger: copy, scenario, feedback, repair, and W12 capstone perception are reviewable.
- Scenario richness proof. Trigger: source/copy packet exposes actual scenario text or Human QA protocol is admitted.

Rejected for this wave:

- Broad W1-W6 rewrite. Reason: current capsule freezes W1-W6 absent regression or concrete evidence.
- Modern Table visual polish. Reason: outside scope and no current regression/product EV evidence.
- Monetization/store, W13+, screenshot iteration, broad UI redesign, ML/AI/persona, solver/GTO, and route implementation. Reason: forbidden by this prompt and current route boundaries.

## 5. Route Admission Status

Status: blocked.

Minimum unblockers before route admission planning:

- W7 naming/positioning resolved.
- W9/W10 differentiation from W4 documented.
- W12 capstone scope and repair specificity resolved.
- Actual W7-W12 copy reviewable and soft-claim safe.
- Stale resume, mapper allowlist, Practice CTA, and post-W6 route/progression gates remain future route-admission concerns.

## 6. Score Policy

No W1-W12 readiness movement. No top-1 readiness movement. No Human QA pass, 9.0, monetization, launch, public/playable opening, route admission, or public learning-effect claim becomes safe.

## 7. Validation Plan

Required for this docs-only backlog:

- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- ASCII / trailing whitespace / CRLF / final-newline checks on this artifact and the triage artifact

Flutter tests and `flutter analyze` are not required unless source/product files are unexpectedly touched.

## 8. Next Recommendation

Run `Volume I Pre-Route Naming Copy Capstone Contract v1` next as a docs-only contract wave. Do not open routes or implement fixes inside that wave unless a later prompt explicitly changes scope.
