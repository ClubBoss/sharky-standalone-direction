# Volume I Claude Findings Triage v1

## 1. Verdict

Verdict: `volume_i_claude_findings_triage_ev_backlog_landed`

Scope: docs-only triage of the supplied Claude red-team findings. This is not route admission, implementation, Human QA, launch, or score movement.

## 2. Inputs

- Stage 0 status: `docs/_reviews/repo_integration_volume_i_claude_findings_triage_v30.md`
- Current capsule: `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- Durable repair capsule: `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
- Human QA capsule: `docs/context/HUMAN_QA_CAPSULE_v1.md`
- Volume I certification: `docs/_reviews/volume_i_internal_source_certification_v1.md`
- W1-W12 checkpoint: `docs/_reviews/w1_w12_internal_source_checkpoint_v1.md`
- World Factory Contract: `docs/plan/WORLD_FACTORY_CONTRACT_v1.md`
- Claude packet/prompt: `docs/_reviews/volume_i_claude_gap_audit_packet_v1.md`, `docs/prompts/claude_volume_i_gap_audit_prompt_v1.md`
- External Claude findings: user-supplied prompt attachment for this wave.

## 3. Executive Triage

- P0: none.
- P1: C01, C04, C05, C07, C08, C11, C15, C17.
- P2: C02, C03, C06, C09, C10, C12, C13, C14, C16.
- Defer: C18 scope-lock items with explicit future triggers.
- Rejected: none of C01-C17. C18 items that contradict the current stage remain rejected for this wave.

Route admission remains blocked until selected P1 findings are resolved or explicitly accepted as risk.

## 4. Findings Classification

| ID | Summary | Area | Severity | EV type | Scope | Timing | Decision | Owner |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| C01 | W7 "Range Thinking Lite" reads backward after W6 "Range Thinking". | naming | P1 | premium trust, clarity, route readiness | docs-only, copy-only | before route admission planning | accept immediate | product decision, Codex |
| C02 | W7 "combo density" / "card removal" may be opaque. | copy | P2 | clarity, learning EV | copy-only | before public copy | accept backlog | Codex, Claude follow-up |
| C03 | W8 "gutshot" needs explanation if surfaced. | copy | P2 | clarity | copy-only | before public copy | accept backlog | Codex |
| C04 | W9 must differ from W4: call price worth it vs bet-size meaning. | learning depth | P1 | learning EV, route readiness | docs-only, copy-only | before route admission planning | accept immediate | Codex |
| C05 | W10 must differ from W4; "thin value" and "fold pressure" need beginner framing. | learning depth | P1 | learning EV, clarity, route readiness | docs-only, copy-only | before route admission planning | accept immediate | Codex |
| C06 | W11 is strongest, but learner copy must avoid "suited texture pressure" leakage and emphasize one-pair danger. | copy | P2 | clarity, commercial quality | copy-only | before public copy | accept backlog | Codex |
| C07 | W12 capstone may be undersized at 4 tasks for its ambition. | capstone | P1 | learning EV, premium trust, route readiness | product decision, fixture/spec | before route admission planning | accept immediate | product decision, Codex |
| C08 | W12 repair concept `w12_review_decision_intuition` is too broad. | capstone, repair/proof loop | P1 | retention, learning EV | docs-only, fixture/spec | before route admission planning | accept immediate | Codex |
| C09 | Learner-facing repair signal is not verified despite technical evidence/projection. | repair/proof loop | P2 | retention, clarity | copy-only, runtime later | before route admission implementation | accept backlog | Codex |
| C10 | Cross-world repair for same-session W9 plus W10 misses is not described. | repair/proof loop | P2 | retention, learning EV | docs-only, runtime later | before route admission implementation | accept backlog | Codex |
| C11 | Soft overclaim risk: implication phrases can bypass hard forbidden-term tests. | claim safety | P1 | claim safety, premium trust | docs-only, test-only later | before route admission planning | accept immediate | Codex |
| C12 | Progression order can imply competence even without explicit claim text. | claim safety | P2 | claim safety | docs-only, copy-only | before public copy | accept backlog | Codex |
| C13 | "Lite" suffix can imply incompleteness and weaken premium perception. | naming | P2 | premium trust, commercial quality | docs-only, copy-only | before public copy | accept backlog | product decision |
| C14 | Scenario richness is not verified by task IDs/concept families alone. | scenario richness | P2 | learning EV, commercial quality | fixture/spec, Human QA later | before Human QA | accept backlog | Claude follow-up, Human QA |
| C15 | Actual task copy was not reviewed: prompts, choices, feedback, intros/outros. | copy, claim safety | P1 | clarity, claim safety, route readiness | copy-only, test-only later | before route admission planning | accept immediate | Codex, Claude follow-up |
| C16 | Human QA prerequisites need actual copy, scenario fidelity, feedback quality, repair experience, W12 perception. | Human QA readiness | P2 | Human QA readiness | Human QA later | before Human QA | accept backlog | Human QA |
| C17 | Route admission prerequisites remain unresolved: naming, W9/W10 copy, W12, copy review, stale resume, mapper, Practice CTA, post-W6 route design. | route readiness | P1 | route readiness | route-gate later | before route admission planning | accept immediate | Codex |
| C18 | Defer/do-not-fix list: no broad W1-W6 rewrite, Modern Table polish, monetization, W13+, ML/AI/persona/GTO, screenshots, broad UI redesign, or route implementation in triage. | defer/do-not-fix | defer | scope safety | none now | later only by explicit prompt | defer or reject for this wave | Codex |

## 5. Rationale By Severity

P0: none. The findings do not show unsafe current public exposure because W7-W12 remain hidden/internal and route locked.

P1: C01, C04, C05, C07, C08, C11, C15, and C17 directly affect whether route admission planning can start honestly. They do not require immediate runtime work, but they should not be silently deferred.

P2: C02, C03, C06, C09, C10, C12, C13, C14, and C16 materially affect clarity, retention, Human QA readiness, or commercial quality. They can be planned after the first P1 contract if the P1s remain explicitly tracked.

Defer/reject: C18 is valid as a guardrail list. Items that are future-route prerequisites are deferred with triggers; items that contradict this wave are rejected for this wave.

## 6. Deferred And Rejected

Deferred with future trigger:

- Route/stale-resume, mapper allowlist, Practice CTA, and progression implementation: defer until a route-admission implementation wave after P1 copy/capstone decisions.
- Human QA execution: defer until actual copy, scenario fidelity, feedback quality, repair experience, and W12 perception are reviewable.
- Scenario richness proof: defer until copy/spec artifacts expose actual scenario detail or a Human QA protocol is admitted.

Rejected for this wave:

- Broad W1-W6 rewrite: frozen by current capsule unless new regression or concrete evidence appears.
- Modern Table visual polish: outside task and no regression/product EV evidence supplied.
- Monetization/store, W13+, screenshot-driven iteration, broad UI redesign, route implementation, ML/AI/persona, solver/GTO claims: forbidden by prompt and current capsules.

## 7. Forbidden Scope Proof

This triage changes no runtime/product/test files and does not inspect or stage output folders. It does not open W7-W12, unlock cards, add stale resume, add Practice CTA, mutate mapper allowlists, execute Human QA, expand telemetry, activate monetization, add ML/AI/persona, make solver/GTO claims, or move W1-W12/top-1 scores.

## 8. Next Link

Backlog and next fix-pack recommendation are recorded in `docs/plan/VOLUME_I_EV_BACKLOG_v1.md`.
