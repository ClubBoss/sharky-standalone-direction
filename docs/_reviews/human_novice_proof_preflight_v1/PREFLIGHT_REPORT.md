# Preflight Report

Verdict: `HUMAN_NOVICE_PROOF_PREFLIGHT_READY`.

- Baseline: `main`, HEAD and `origin/main` both `11715b50d81c59377174dcc02a0ffeb2f9d7a5c7`; no tracked/staged drift.
- Deterministic: 94 focused tests, `flutter analyze`, fresh `./tools/fast_loop_world1_v1.sh`, `graphify hook-check`, and diff checks passed.
- Live: one iPhone 16 Pro/iOS 18.3 Debug Simulator run built from `build/ios/iphonesimulator/Runner.app` and completed a real non-debug route: onboarding → Learn → real wrong table decision → Review → `Practice this spot` → focused retry → `Save this read` → completed Review.
- Assertions 1-12 passed: build/launch, canonical entry, learner entry, direct decision/options, wrong feedback, real Review, CTA tap, repair open, save CTA, completed Review, and no observed clipping/blank/dead-tap/safe-area blocker.
- No confirmed P0/P1/P2 blocker. The preferred transfer/recheck task identity remains deterministic-only in this run; it is a documented non-blocking route selection limitation, not a product failure.

Proposed cohort: 5 true poker novices, one participant per session on the same
frozen candidate. Admit a first evidence cycle when there are zero P0/P1
findings; at least 4/5 discover the primary entry with level-0/1 intervention;
at least 4/5 identify private cards, board, and pot without directional help;
at least 4/5 can explain one concrete feedback clue and recall one specific
learning rule; at least three naturally exposed repair loops complete without
level-2/3 intervention before Review comprehension is admitted; and there are
zero dead ends, unreachable CTAs, clipping blockers, or blank product frames.
If fewer than three participants naturally expose the repair loop, classify
Review human evidence as insufficient exposure rather than product failure.
Median time-to-decision is recorded rather than pre-judged. Five participants
is a compact formative cohort suitable for finding repeated usability patterns,
not population-level proof.
