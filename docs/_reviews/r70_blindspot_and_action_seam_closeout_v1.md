# R70 Blindspot and Action Seam Closeout Audit v1

## Milestone purpose/scope recap
- Execute one bounded dual-track recovery strike:
  - tooling blindspot hardening,
  - one exact runtime action-layer seam fix.
- Keep scope deterministic and bounded; no broad UX/runtime/content redesign.

## Tooling blindspots added
- Added deterministic prompt leak guard for action cues:
  - fail on `Focus:\s*(fold|call|raise|check|bet|jam|all-in)` (case-insensitive).
- Tightened deterministic contradictory correct-feedback guard:
  - fail when `feedback_correct_v1` contains `worse than our recommended play`.
- Wired prompt-focus guard into validator root prompt checks and `hand_chain_v1` step prompt checks.

## Early-world cleanup scope
- Validator run after guard additions produced no violations in:
  - `content/worlds/world0/`
  - `content/worlds/world1/`
  - `content/worlds/world2/`
- Cleanup result: NO-OP (no direct failures for the two added guard classes).

## Exact runtime seam chosen
- Selected seam family: facing-bet action affordance label coherence in World1 spine action-chip branch.
- File/surface:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
- Bounded rule:
  - suppress `BET` affordance only when the user is facing a bet and a raise-family affordance exists in the same allowed-action set.
- Why this seam:
  - directly user-visible in early action mode,
  - one deterministic branch-family fix,
  - avoids action-bar redesign or multi-seam changes.

## Proof recap
- Targeted tooling proof:
  - `dart test test/tools/why_v1_ssot_v1_test.dart`
- Targeted runtime seam proof:
  - `flutter test test/guards/world1_foundations_microtask_contract_test.dart --plain-name "world1 spine action bar renders exact allowedActions set deterministically"`
  - regression guard:
    - `flutter test test/guards/world1_foundations_microtask_contract_test.dart --plain-name "world1 spine multi-street progression advances exactly one step per commit"`
- Required gates:
  - `flutter analyze`
  - `./tools/fast_loop_world1_v1.sh`
  - `dart run tools/validate_world_content_v1.dart`
  - `dart run tools/run_content_qa_r2_v1.dart`
- All green.

## Open risks
- Prompt/focus leak and contradiction checks remain lexical by design; broader semantic leakage remains intentionally out of scope.
- Additional action-layer seams outside selected facing-bet branch may still exist and are deferred.

## Explicit defer list
- Any generic prompt semantic scoring expansion.
- Any broad world0-2 editorial cleanup not triggered by validator failures.
- Any action-bar redesign, finish-screen overhaul, progression redesign, personalization/scoring/schema work.

## Anti-drift note
- Scope remained bounded to exactly:
  - two tooling guard families,
  - one runtime action-layer seam family,
  - minimum proving contracts.
