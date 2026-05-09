# R40 Learning Truth Closeout Audit v1

## Milestone purpose/scope recap
- Milestone intent: close one bounded contradictory primary-correct feedback class from the external audit with deterministic tooling-first enforcement.
- Scope held: one guard family only, no runtime/product redesign, no schema/dependency changes.

## Candidate guard recap and winner
- Candidate A (include now): `feedback_correct_v1` contains soft-pass contradiction phrase family: `legal, but worse than (our) recommended play`.
- Candidate B (maybe later): broader suboptimality wording on correct channel (higher false-positive risk without narrow phrase contract).
- Candidate C (exclude from R40): generic/irrelevant `why_v1` quality classes (different family).
- Selected winner: Candidate A due to highest trust-restoration EV with lowest deterministic scope risk.

## Selected guard and exact closure evidence
- Added guard: `hasPrimaryCorrectContradictionV1(...)` in `tools/why_v1_ssot_v1.dart`.
- Guard contract: fail when normalized `feedback_correct_v1` matches exact soft-pass contradiction regex:
  - `\blegal,\s*but\s*worse\s+than\s+(?:our\s+)?recommended\s+play\b`
- Validator integration:
  - drill-level check in `tools/validate_world_content_v1.dart` with key `feedback_primary_correct_contradiction_v1`.
  - `hand_chain_v1` step-level check with the same key.

## Proof recap (gates + targeted test)
- `flutter analyze` -> PASS
- `./tools/fast_loop_world1_v1.sh` -> PASS
- `dart run tools/validate_world_content_v1.dart` -> PASS
- `dart run tools/run_content_qa_r2_v1.dart` -> PASS
- `dart test test/tools/why_v1_ssot_v1_test.dart` -> PASS

## Open-risk list
- Broader contradictory phrasing outside the exact selected phrase family is still possible and deferred.
- Generic correctness-channel text quality variance remains outside this bounded fence.

## Explicit defer list
- Prompt leakage family continuation.
- Placeholder/TODO cleanup batches.
- Runtime presentation candidates (onboarding duplication / misleading Top leak).
- Broader semantic contradiction detection beyond exact bounded phrase family.

## Anti-drift note
- R40 closed exactly one contradictory-feedback family.
- Do not combine deferred families into the same pass retroactively.

## Ambiguous P0 status
- No ambiguous R40 P0 status remains for the selected contradictory-feedback class.

## Transition note (next focus only)
- Next milestone should be defined before execution (`R41`) using bounded evidence-first weakest-link selection from deferred classes.
