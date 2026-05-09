# R25 Personalization Closeout Audit v1

## 1) Milestone purpose/scope recap
R25 scoped one bounded Personalization / Profile EV refinement after R24:
- add exactly one deterministic signal layer to adaptive followup routing,
- preserve explicit precedence and deterministic tie-break behavior,
- avoid schema/dependency/content/UI/ML drift.

## 2) Selected signal layer and precedence/tie-break recap
Selected layer (from baseline): `focus-review-due` using existing `lessonFocusLabel` + due-state.

R25 precedence contract (deterministic):
1. Existing higher-priority routing paths stay unchanged.
2. LearningStats winner remains first adaptive signal.
3. Checkpoint top-error fallback remains next.
4. New `focus-review-due` fallback runs only if still unresolved.
5. If focus mapping is invalid/unusable, preserve prior band fallback behavior.

Tie-break/fallback rules:
- identical input state => identical selected followup,
- checkpoint fallback wins over focus-review-due when both are available,
- no new ranking/scoring engine introduced.

## 3) Included slice and exact closure evidence
Included slice: insert `focus-review-due` fallback branch after checkpoint fallback and before band fallback in adaptive routing.

Closure evidence:
- Baseline decision doc: `docs/_reviews/r25_signal_layer_baseline_v1.md`
- P0.2 implementation commit: `61e9ba792` (`runtime+test: r25 focus-review-due fallback v1`)
  - touched: `lib/services/progress_service.dart`, `test/services/review_queue_v1_test.dart`
- P0.3 deterministic contract extension commit: `28f994570` (`test: r25 p0.3 deterministic routing contracts v1`)
  - touched: `test/services/review_queue_v1_test.dart`

## 4) Deterministic contract evidence recap
Contract coverage now includes:
- focus-review-due used only when higher-priority adaptive signals do not resolve,
- checkpoint fallback precedence over focus-review-due,
- stable selection under identical input state,
- stable behavior across repeated runs with controlled `debugNow` state,
- invalid/absent/stale focus label preserves prior fallback behavior,
- no time-state leakage across tests for this route.

Primary proof surface:
- `test/services/review_queue_v1_test.dart`

## 5) Open-risk list
- No open P0 risk found within R25 scoped slice.
- Residual risk is limited to deferred non-scoped personalization expansion (see defer list), not current deterministic routing correctness.

## 6) Explicit defer list for non-included personalization ideas
Deferred after R25:
- weighted/multi-signal scoring,
- profile dashboard/explanatory personalization UI,
- personalization-driven content scaling,
- telemetry/schema redesign for personalization,
- ML/recommendation model work,
- expansion into broader UX cohesion programs.

## 7) Anti-drift note
R25 remained a single bounded deterministic signal-layer refinement. No feature-family expansion was pulled in.

## 8) Ambiguous P0 status statement
No ambiguous P0 personalization status remains for R25 scope.

## 9) Transition note for next personalization increment
Next increment should add at most one additional deterministic signal layer (or one deterministic refinement to existing mapping quality), with explicit precedence/tie-break contracts and tests-first closure, while keeping deferred items above out of scope.
