# R35 Content/Explanation Closeout Audit v1

## 1) Milestone purpose/scope recap
R35 targeted one bounded deterministic template action-cue leakage guard.
Scope stayed limited to existing content validation tooling, one targeted proof extension, and minimal content cleanup required by the selected guard.
No runtime product behavior, schema, or dependency changes were introduced.

## 2) Candidate guard recap and why the selected guard won
Candidate guards considered:
1. Exact template `In this spot, choose <action>.`
2. Exact template `When the second cue appears, choose <action>.`
3. Broader template family `In this <domain> spot, choose <action>.`

Selected guard:
- Exact template `In this spot, choose <action>.`

Why it won:
- Deterministic and high-confidence, with low false-positive risk.
- Bounded to one exact template class.
- Minimal cleanup surface (10 prompts), avoiding broad rewrite/sprawl.

## 3) Selected guard and exact closure evidence
Implemented in:
- `tools/why_v1_ssot_v1.dart`
- `tools/validate_world_content_v1.dart`

Bounded deterministic contract:
- Fail when normalized prompt matches:
  - `\bin this spot,\s*choose\s+(?:fold|call|raise|check|jam|all-in)(?:\.|$)`
- Guard is enforced via existing `hasPromptAnswerLeakV1` usage for top-level and `hand_chain_v1` step prompts.
- Validator failure key remains deterministic/actionable:
  - `prompt_answer_leak_v1 (...)`

Bounded cleanup required by guard:
- `content/worlds/world10/v1/sessions/w10.s01/drills/d.choose_call_track_baseline.json`
- `content/worlds/world10/v1/sessions/w10.s02/drills/d.choose_call_cash_pressure.json`
- `content/worlds/world10/v1/sessions/w10.s03/drills/d.choose_fold_mtt_pressure.json`
- `content/worlds/world10/v1/sessions/w10.s04/drills/d.choose_call_mixed_stability.json`
- `content/worlds/world10/v1/sessions/w10.s05/drills/d.choose_fold_switch_guardrails.json`
- `content/worlds/world10/v1/sessions/w10.s06/drills/d.choose_call_consistency_check.json`
- `content/worlds/world10/v1/sessions/w10.s07/drills/d.choose_raise_cash_deepening.json`
- `content/worlds/world10/v1/sessions/w10.s08/drills/d.choose_fold_mtt_deepening.json`
- `content/worlds/world10/v1/sessions/w10.s09/drills/d.choose_call_mixed_balance.json`
- `content/worlds/world10/v1/sessions/w10.s10/drills/d.choose_raise_track_synthesis.json`

Targeted proof extension:
- `test/tools/why_v1_ssot_v1_test.dart`
- `prompt answer leak fence is deterministic` now includes template fail/pass assertions.

## 4) Proof recap (gates + targeted test)
Green evidence on closure pass:
- `dart test test/tools/why_v1_ssot_v1_test.dart` -> PASS
- `flutter analyze` -> PASS
- `./tools/fast_loop_world1_v1.sh` -> PASS
- `dart run tools/validate_world_content_v1.dart` -> PASS
- `dart run tools/run_content_qa_r2_v1.dart` -> PASS

## 5) Open-risk list
- P0: none.
- P1: additional template cue families remain outside this bounded class.
- P2: broader explanation consistency/tone improvements remain deferred.

## 6) Explicit defer list
Deferred outside R35:
- `When the second cue appears, choose <action>.` guard family,
- broader `In this <domain> spot, choose <action>.` family,
- semantic policy/contradiction engines,
- content rewrite/scaling programs,
- personalization expansion,
- UX cohesion/visual expansion,
- architecture redesign and ML scope.

## 7) Anti-drift note
R35 closes one exact template action-cue guard only.
Do not widen into broad template families or semantic-engine work in this milestone.

## 8) P0 ambiguity statement
No ambiguous P0 content/explanation sanity status remains for R35 scope.

## 9) Transition note (next focus only)
R35 is formally complete and closed.
`# Milestone R36` must be defined in SSOT before any R36 execution work begins.
