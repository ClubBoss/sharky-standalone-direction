# R41 Learning Truth Closeout Audit v1

## Milestone purpose/scope recap
- Milestone intent: close one largest-safe bounded prompt leakage family from preserved external audit findings.
- Selected family scope: prompt strings containing `proxy` plus direct `choose <action>` answer cue.
- Scope held: tooling/content-only; no runtime behavior, schema, dependency, or architecture changes.

## Candidate family recap and why selected family won
- Candidate A (include now): generic `choose <action>` prompt family.
  - Deferred: too broad (`148` hits) and higher false-positive risk for baseline instructional drills.
- Candidate B (include now): `proxy ... choose <action>` family.
  - Selected: largest safe bounded deterministic family (`23` hits), low false-positive risk, manageable violation-driven cleanup.
- Candidate C (maybe later): narrow `in this <...> spot, choose <action>` family.
  - Deferred: bounded but too small (`3` hits) versus selected class EV.

## Selected guard and exact closure evidence
- Guard update: `hasPromptAnswerLeakV1(...)` now fences `proxy ... choose <action>` template class via:
  - `_kPromptLeakProxyCueTemplateV1` in `tools/why_v1_ssot_v1.dart`.
- Existing validator wiring reused:
  - `tools/validate_world_content_v1.dart` already raises `prompt_answer_leak_v1` for drill and `hand_chain_v1` prompts.

## Proof recap (gates + targeted test)
- `flutter analyze` -> PASS
- `./tools/fast_loop_world1_v1.sh` -> PASS
- `dart run tools/validate_world_content_v1.dart` -> PASS
- `dart run tools/run_content_qa_r2_v1.dart` -> PASS
- `dart test test/tools/why_v1_ssot_v1_test.dart` -> PASS

## Cleanup scope summary
- Bounded violation-driven cleanup only for selected family.
- Updated exactly `23` content drill files (Worlds 6-9) where prompts matched `proxy ... choose <action>`.
- Cleanup transformation: replace direct `choose <action>` cue in selected family with `choose the best action`.

## Open-risk list
- Remaining prompt leak families outside selected class (for example broader generic `choose <action>` templates) are still deferred.
- Potential non-template leakage classes requiring separate bounded selection remain open.

## Explicit defer list
- Generic `choose <action>` family (broad cleanup risk).
- `in this <...> spot, choose <action>` narrow family.
- Placeholder/TODO content family.
- Runtime presentation candidates (misleading Top leak, onboarding/binding verify-then-fix).

## Anti-drift note
- R41 closes exactly one deterministic prompt leakage family.
- Do not combine remaining prompt families or non-prompt audit classes into the same milestone retroactively.

## Ambiguous P0 status
- No ambiguous P0 status remains for the selected `proxy ... choose <action>` family.

## Transition note (next focus only)
- Define R42 before execution using evidence-first selection among deferred leak families and quality classes.
