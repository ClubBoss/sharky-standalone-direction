# INDEPENDENT_ACT0_AUDIT_LOG_v1

Status: ACTIVE
Purpose: code-first, test-first audit log for repeatable Act0 quality checks that do not depend on pre-scored planning docs.
Last updated: 2026-05-13

## Scope

This log is intentionally independent from route score docs.

Use this file to:
- snapshot current product truth from code and tests
- compare wave-to-wave deltas with stable metrics
- drive bounded closure tasks to reach practical product 100/100

Do not use this file to:
- replace product direction authority in master planning docs
- claim launch/store readiness by itself

## Audit Method (repeat every wave)

Run these commands and record exact outputs:

```bash
flutter analyze
flutter test test/ui_v2/act0_play_shell_v1_test.dart -r compact
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact
dart run tools/act0_feedback_floor_audit.dart
wc -l \
  lib/ui_v2/act0_shell/act0_shell_state_v1.dart \
  lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart \
  lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart \
  lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart \
  lib/ui_v2/act0_shell/act0_profile_shell_v1.dart
```

Optional classification helper:

```bash
rg -o -e "--plain-name '[^']+'" /tmp/audit_preview_test.txt \
  | sed "s/--plain-name '//; s/'$//"
```

## Readable Audit Format (Narrative + Trace)

Use this section layout for every next independent wave so the report is both
human-readable and machine-comparable.

### Section 1. Short narrative verdict

Write 5-10 lines in plain language:
- what improved since previous wave
- what is still blocked
- whether practical product confidence moved up or down

### Section 2. Command trace

List the exact commands used during the wave in execution order.

### Section 3. Block-by-block status

For each block, keep one compact card:
- Status: green / yellow / red
- Score: 0-100
- Evidence: concrete metrics or failing tests
- To reach 100: bounded actions with exit criteria

### Section 4. Composite score and blockers

Always include:
- independent composite score
- top 5 delivery blockers
- one next-wave execution order

## Snapshot 2026-05-13 (Independent Code/Test Pass)

### Short Narrative Verdict (preferred format)

Independent pass confirms that the core route is materially functional but not
closure-grade yet.

What is strong now:
- static analysis is clean
- Play quick-return is stable in focused tests
- visual token system and Sharky presence are strong and coherent

What still blocks 100/100:
- integration suite still has 26 active failures
- architecture remains monolithic in key owners
- feedback voice still too generic at source level
- value/trial path is partially wired and not closure-proof

Direction of travel vs prior run:
- integration moved from 34 failures to 26 failures (improved)
- core blockers remain in the same owner families

### Raw Baseline

- `flutter analyze`: clean (`No issues found`)
- Play shell tests: `+2 -0` (`All tests passed`)
- Preview integration tests: `+254 -26` (`Some tests failed`)
- Integration pass rate: `254 / 280 = 90.7%`
- Feedback floor audit:
  - Feedback titles: `500`
  - Feedback reasons: `501`
  - Empty feedback titles: `0`
  - Empty feedback reasons: `0`
  - Empty synthetic feedback pairs: `1`
  - Generic title reuse: `156x Nice read.` + `128x Almost there.`
- Architecture scale (line counts):
  - `act0_shell_state_v1.dart`: `15183`
  - `act0_shell_preview_screen_v1.dart`: `6462`
  - `act0_lesson_runner_shell_v1.dart`: `5936`
  - `act0_learn_path_shell_v1.dart`: `3051`
  - `act0_profile_shell_v1.dart`: `1640`

### Command Trace (this wave)

1. `flutter analyze`
2. `flutter test test/ui_v2/act0_play_shell_v1_test.dart -r compact`
3. `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart -r compact`
4. `rg -n "Some tests failed|All tests passed|\+[0-9]+ -[0-9]+" /tmp/audit_preview_test.txt`
5. `rg -n "^══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK|^The following TestFailure|^Expected:|^Actual:|To run this test again" /tmp/audit_preview_test.txt`
6. `rg -o -e "--plain-name '[^']+'" /tmp/audit_preview_test.txt | sed "s/--plain-name '//; s/'$//"`
7. `dart run tools/act0_feedback_floor_audit.dart`
8. `wc -l lib/ui_v2/act0_shell/act0_shell_state_v1.dart lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`
9. `rg -n "purchase|restore|trial|entitlement|paywall|billing|iap" lib/ui_v2/act0_shell/ lib/services/ lib/`

### Block-by-Block Status (preferred compact cards)

1. Architecture, Scale, and Simplicity
- Status: red
- Score: 52/100
- Evidence: `act0_shell_state_v1.dart` is 15183 LOC; preview coordinator is 6462 LOC
- To reach 100:
  - split state by owner seams (runner, review, profile, localization)
  - split preview coordinator into recommendation, routing, placement mapping
  - exit: largest Act0 file under 8k LOC

2. Integration Stability
- Status: red
- Score: 63/100
- Evidence: preview suite is +254/-26 (90.7% pass)
- To reach 100:
  - close failing families in strict order: entry -> runner semantics -> progression -> cross-shell routing -> token isolation
  - add one regression test per fixed defect
  - exit: 0 failures in preview suite

3. Profile and Identity
- Status: yellow
- Score: 74/100
- Evidence: streak and momentum framing exists, but profile-related continuity tests still fail
- To reach 100:
  - close profile habit and achievement continuity failures
  - add one end-to-end profile identity assertion after first repair cycle
  - exit: profile flows green in preview suite

4. Sharky Mascot and Product Soul
- Status: yellow-green
- Score: 79/100
- Evidence: sharky is cross-shell (Home/Placement/Review/Runner), mood-based motion and tone are active
- To reach 100:
  - tie Sharky variants to mistake family + lesson phase + streak state
  - reduce repeated openers and generic reinforcement lines
  - exit: no single Sharky opener dominates over 15% in sampled sessions

5. Feedback Coaching Quality
- Status: red
- Score: 46/100
- Evidence: top-2 title reuse is 56.8% (`Nice read.` + `Almost there.`)
- To reach 100:
  - enforce diversity gate in audit tool (top-2 share threshold + synthetic fallback zero)
  - author targeted replacements by concept family
  - exit: top-2 share below 25% and synthetic fallback count 0

6. Play Quick Return
- Status: green-yellow
- Score: 80/100
- Evidence: focused Play tests are fully green (+2/-0), one cross-shell Play contract still fails
- To reach 100:
  - close placement-separation and lane-coherence integration assertions
  - exit: all Play-related integration contracts green

7. Learn and Runner Coherence
- Status: yellow
- Score: 68/100
- Evidence: active-seat semantics, next-task continue, and autoscroll contracts fail
- To reach 100:
  - normalize seat activity source-of-truth and runner continuation rules
  - lock autoscroll behavior with deterministic viewport assertions
  - exit: runner semantic family fully green

8. Review Repair Loop
- Status: yellow
- Score: 70/100
- Evidence: review loop exists, but wrong-answer continuity and resurfacing contracts fail
- To reach 100:
  - harden wrong-answer -> review -> fix -> resume chain
  - ensure open mistakes resurface independent of transient lesson context
  - exit: review continuity tests green

9. Value, Trial, Commerce
- Status: red
- Score: 41/100
- Evidence: preview UI exists, but closure-grade purchase/restore wiring is not proven in active route
- To reach 100:
  - bind premium preview surfaces to unified entitlement truth
  - replace mock purchase path in production path (keep mock for tests only)
  - add deterministic integration tests for purchase, restore, trial expiry
  - exit: full entitlement and commerce contract green

10. Visual System Coherence
- Status: green-yellow
- Score: 83/100
- Evidence: broad tokenization and coherent shell language, but detached token-source assertion fails
- To reach 100:
  - close local-token-source isolation contract
  - keep all shell visual surfaces on shared token source
  - exit: token isolation tests green

### Legacy Wording Parity (from earlier narrative audit)

This subsection keeps the older naming so no signal is lost across formats.

- Simplicity (code): `52/100` (mapped to Architecture, Scale, and Simplicity)
- Feedback quality: `46/100`
- Sharky/Habit/Soul: `79/100`
- Profile/Identity: `74/100`
- Play quick-return: `80/100`
- Visual coherence: `83/100`
- Value/Trial: `41/100`
- Test stability (integration): `63/100`

### Failing Integration Families (26)

1. Boot/entry contract
- `AppRoot boots directly into the Act0 dev shell`

2. RU localization and compact safety
- runner prompt localization and headroom checks
- home/play/profile RU two-line safety checks

3. Runner table-state semantics
- active seat and `To act` behavior
- stale `seat.isActive` override handling
- seat tap feedback rendering

4. Progression and unlock continuity
- next lesson unlock expectation
- review continue to next task
- wrong answer -> review -> fix path continuity

5. Cross-shell routing coherence
- play keeping placement out of main loop
- home weak-spot routing and CTA pivoting
- review resurfacing open mistake by context

6. Visual token isolation
- detached shell local token source assertion

### Composite Score and Top Delivery Blockers

Independent composite score: `66/100`.

Top 5 blockers by delivery risk:
1. integration family residue (26 preview failures)
2. architecture monolith risk (15k state owner)
3. feedback genericity concentration (56.8% top-2 share)
4. incomplete value/trial closure wiring
5. RU compact/localization contract failures

### Next-wave execution order

1. close integration families in this order: entry -> runner semantics -> progression continuity -> cross-shell routing -> token isolation
2. run one bounded architecture split pass without behavior change
3. run feedback diversity pass with measurable title-share reduction
4. close entitlement wiring and commerce integration contracts
5. lock RU compact localization matrix in CI

## Repeatable Comparison Table (fill each wave)

| Metric | 2026-05-13 baseline | Next wave | Delta |
|---|---:|---:|---:|
| Analyze issues | 0 |  |  |
| Play tests failed | 0 |  |  |
| Preview tests failed | 26 |  |  |
| Preview pass rate | 90.7% |  |  |
| Largest file LOC | 15183 |  |  |
| Feedback top-2 share | 56.8% |  |  |
| Empty synthetic feedback pairs | 1 |  |  |
| Architecture score | 52 |  |  |
| Simplicity (code) score | 52 |  |  |
| Integration score | 63 |  |  |
| Profile/Identity score | 74 |  |  |
| Sharky/Soul score | 79 |  |  |
| Feedback quality score | 46 |  |  |
| Value/Commerce score | 41 |  |  |
| Composite independent score | 66 |  |  |

## Closure Rule For This Log

This log can claim practical 100/100 only when all are true:

1. Preview integration suite is green (`0` failures) for active route contracts.
2. Feedback top-2 title share is below `25%` with `0` empty synthetic pairs.
3. Largest Act0 file is below `8k` LOC.
4. Value/trial flow is wired to real entitlement and purchase/restore proof.
5. RU compact localization matrix is green.
