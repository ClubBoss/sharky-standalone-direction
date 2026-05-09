# R42 Learning Truth Closeout Audit v1

## Milestone purpose/scope recap
- Milestone intent: close one largest-safe bounded TODO/placeholder leakage family from preserved external audit findings.
- Selected family scope: literal `TODO` token leakage in user-visible `session.md` surfaces.
- Scope held: tooling/content-only; no runtime behavior, schema, dependency, or architecture changes.

## Candidate family recap and why selected family won
- Candidate A (include now): literal `TODO` token.
  - Selected: largest safe bounded deterministic family in active session surfaces (`63` hits), low false-positive risk, manageable violation-driven cleanup.
- Candidate B (maybe later): `TBD` token family.
  - Deferred: no high-confidence active user-visible session-surface violations in this pass.
- Candidate C (maybe later): `placeholder` / `coming soon` family.
  - Deferred: requires broader sweep outside selected family and would expand cleanup scope.

## Selected guard and exact closure evidence
- Guard added: `hasSessionTodoPlaceholderLeakV1(...)` in `tools/why_v1_ssot_v1.dart`.
- Contract: deterministic fail on `TODO` token in `session.md` text with case-insensitive whole-token match.
- Validator wiring added in `tools/validate_world_content_v1.dart` via `session_todo_placeholder_leak_v1` error.

## Proof recap (gates + targeted test)
- `flutter analyze` -> PASS
- `./tools/fast_loop_world1_v1.sh` -> PASS
- `dart run tools/validate_world_content_v1.dart` -> PASS
- `dart run tools/run_content_qa_r2_v1.dart` -> PASS
- `dart test test/tools/why_v1_ssot_v1_test.dart` -> PASS

## Cleanup scope summary
- Bounded violation-driven cleanup only for selected family.
- Updated exactly `63` `session.md` files flagged by the new guard:
  - `content/worlds/world0/v1/sessions/w0.s01..w0.s10/session.md`
  - `content/worlds/world1/v1/sessions/w1.s01..w1.s10/session.md`
  - `content/worlds/world6/v1/sessions/w6.s01..w6.s03/session.md`
  - `content/worlds/world7/v1/sessions/w7.s01..w7.s10/session.md`
  - `content/worlds/world8/v1/sessions/w8.s01..w8.s10/session.md`
  - `content/worlds/world9/v1/sessions/w9.s01..w9.s10/session.md`
  - `content/worlds/world10/v1/sessions/w10.s01..w10.s10/session.md`

## Open-risk list
- Remaining placeholder families (`TBD`, `placeholder`, `coming soon`) are still deferred.
- Non-placeholder external-audit classes (runtime presentation and onboarding/binding verify-first) remain out of scope.

## Explicit defer list
- `TBD` / `placeholder` / `coming soon` leakage families.
- Irrelevant generic `why_v1` cleanup class.
- Runtime presentation candidate (`Top leak` for non-strategic sessions).
- Onboarding/binding duplication verify-then-fix class.

## Anti-drift note
- R42 closes exactly one deterministic placeholder family (`TODO` in `session.md`).
- Do not expand this closeout retroactively into multi-family cleanup or runtime redesign.

## Ambiguous P0 status
- No ambiguous P0 status remains for the selected `TODO` leakage family.

## Transition note (next focus only)
- R43 must be defined before execution, using evidence-first selection from deferred external-audit classes.
