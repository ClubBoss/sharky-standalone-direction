---
status: "current_head_top1_packet_admitted"
status_source: "current-source audit"
doc_date: "2026-08-02"
---

# Current-Head Personalization, Learning, and E2E Truth v1

## Baseline and method

- Exact baseline: `26a39452486726505ceaf733ee8bfb71867defe4` (`origin/main`), the normal merge of PR #129; candidate `827d9302c661f30a985ba348e9ec4fddc2b70d96`.
- PR #129 is closed. Its runner-feedback composition, shared geometry, compact reachability, Modern Table boundary, visual tooling freeze, and Human QA/HNP prohibition are preserved.
- Direct current-source and focused-test tracing was used. Graphify is unavailable because `graphify-out/graph.json` is absent. This is deterministic source proof, not native or Human proof.

## Current-head truth matrix

| Block | Contract and owners | State, telemetry, proof, and visible breadth | Exact gap | Status |
| --- | --- | --- | --- | --- |
| P1 Deterministic personalization | `Act0ShellPreviewScreenV1` records and consumes `action_read`, `table_position_read`, `price_read`, `starting_hand_read`, and `board_read`; family adapters own exact tuples; `Act0LearningRunPayoffPolicyV1` owns shared payoff/next-practice copy. | Active `Act0LearningRunStateV1` retains the visit. Existing owners emit choice, result/error, decision-time bucket, feedback, repair/recheck, family payoff, learning-run outcome, focus, recommendation, and session events. Immediate source-specific feedback exists for all five families; the shared payoff specifically names action, position, and price. | The shared payoff descriptor registry lacks `starting_hand_read` and `board_read`. Its subsequent learner-facing recommendation falls back to generic “this clue” copy despite source-owned guidance. Active-run state is session-local. | **PARTIAL_RUNTIME** |
| P2 Learning Effect | Runner/shell own choice, classification, feedback, repair, reduced-scaffolding recheck, receipt, payoff, and continuation; same-signal mapper retains W2/W4/W5/W6 source identity. | Existing family/payoff/repair-recheck/telemetry tests cover correct-first, wrong-first, ordered lifecycle, and no duplicate terminal outcome. The shared loop is concrete for descriptor-covered families. | The P1 descriptor gap also makes the final continuation generic for two already-live families. No separate P2 mechanism is required before P1 is repaired. | **PARTIAL_RUNTIME** |
| P3 Minimal live E2E Alpha | `AppRoot` enters `Act0ShellPreviewScreenV1`; the shell owns Learn, Home, Review/Practice, close, and payoff. | `e2e_product_integrity_checkpoint_v1_test.dart` proves canonical-root consumption of a production-achievable persisted fixture and Home/Learn continuation; route tests cover repair/recheck owners. | The named E2E checkpoint is persisted-progress replay/route proof, not a fresh-entry learner-operated full wrong → repair → recheck → payoff integration traversal. It waits behind lower-risk P1 consumption repair. | **PARTIAL_RUNTIME** |

## Top-1 admission

Selected packet: **`PERSONALIZATION_CONSUMPTION_AND_NEXT_REP_V1`**.

This is the highest immediate learner-value lift and the smallest safe shared boundary: existing source records five families, while two lose their authored specificity at the shared payoff/next-practice decision. The packet extends the existing descriptor registry and proves live consumption; it does not add content, telemetry semantics, dependencies, or a parallel engine.

P2 waits because its observed residual is P1 consumption. P3 waits because its future full fresh-entry traversal should exercise the corrected personalized continuation.

## Boundaries and evidence

Allowed: one deterministic shared-owner product slice, narrow tests, and one focused complete-capability integration test. Required: correct-first, wrong → repair → recheck, telemetry cardinality, representative family breadth, route regression, analysis, fast loop, release gate, Graphify hook-check when available, and diff/forbidden-scope checks.

Forbidden: ML, remote AI, chat, dependencies, Modern Table, visual redesign, W13+, broad content, general telemetry, screenshots unless pixels change, and Human QA/HNP. Native acceptance is exact-candidate-only after deterministic gates and only with an already-recognized Flutter device.
