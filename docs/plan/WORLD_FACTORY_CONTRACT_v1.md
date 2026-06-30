# World Factory Contract v1

Status: ACTIVE internal source-template contract after W7 certification.

This contract defines the reusable pattern for W8-W12 internal source work. It
does not open routes, admit learner-facing play, authorize implementation by
itself, or replace active roadmap authority.

## 1. Required Minimum Task Count

Each internal world candidate must include at least 3 tasks. Preferred minimum:
4 tasks, matching W7. Fewer than 3 means seed only.

## 2. Required Task Arc

Each world must carry one coherent parent concept family and this task arc:

1. Intro/example task: introduces the parent concept with one clean example.
2. Variation task: repeats the same concept in a materially different surface.
3. Repair-relevant mistake task: targets a predictable misconception.
4. Transfer/check task: asks the learner to generalize the same concept.

The tasks must teach distinct angles of the same concept.

## 3. Required IDs

Every task/source task must define:

- `world_id`
- `module_id` or lesson/session id
- `task_id`
- `source_task_id`
- `concept_family_id`
- `repair_focus_id`
- `skill_atom_id`
- `error_type`
- `expected_choice`

## 4. Required Evidence Fields

Every completed decision must preserve:

- world id
- lesson/session id
- task id
- source task id
- selected choice
- expected choice
- correctness
- concept family id
- repair focus id
- skill atom id
- error type
- decision time bucket when available
- run kind / started-by source when evidence is emitted by an internal owner

Evidence must support same-concept matching without screen text.

## 5. Hidden Owner And Harness Pattern

Each hidden/internal world must use a small owner/harness shape:

- const task specs or equivalent source-owned immutable task records;
- explicit `supports(worldId, lessonId, taskId)` gate;
- correct/incorrect decision creation for each task;
- unknown task and unknown choice rejection;
- evidence append through the accepted learning evidence owner;
- no Flutter widget, navigation, route owner, queue owner, or telemetry writer;
- no Practice launch request unless a later route-admission wave authorizes it.
- harness may delegate to the owner but must remain internal and route-safe.

## 6. Required Projection Tests

Each internal world must prove:

- incorrect evidence is consumable by concept-family repair memory;
- later correct evidence is recognized as same-concept later-correct signal;
- practice-action join behavior stays non-causal unless ordered repair evidence
  exists;
- legacy/fallback behavior is not broken when applicable;
- unknown concepts or unsupported targets remain safe no-target states.

Projection proof is internal only, not Human QA or public learning-effect proof.

## 7. Route And Practice Policy

Default policy for W8-W12 internal worlds:

- route locked;
- not learner-playable;
- not public;
- no card unlock;
- no stale resume into the world;
- no Practice CTA;
- no mapper allowlist;
- no queue mutation.

Route/Practice admission needs separate route, stale-resume, mapper, copy, and
progression proof.

## 8. Copy-Safety Checks

Task prompt, choice label, feedback, and repair copy must avoid:

- raw task ids;
- GTO, solver, optimal, perfect, mastered, fixed;
- guaranteed improvement, proven improvement, win-rate;
- public, playable, launch-ready, Human-QA-proven;
- AI, persona, or coaching claims unless explicitly admitted by a later scope.

Copy should be beginner-readable and limited to the local concept.

## 9. World Quality Parity Gate

A future world may use the W7 template only if it has:

- content depth beyond a single seed;
- coherent learning arc;
- at least one transfer/check task;
- evidence/projection compatibility;
- claim-safe copy;
- route/Practice safety;
- explicit deferred public-route admission boundary.

If any item fails, the world remains a seed or blocker.

## 10. Batching Rules

Batching is allowed when:

- tasks share one parent concept family;
- the same owner/harness pattern handles all tasks;
- focused tests cover all tasks in the batch;
- copy-safety and route/Practice safety checks run for the full batch;
- no product route, screen, telemetry, monetization, or W1-W6 behavior changes.

Batching stops when tasks cross concept families, require route owners, need new
fixture/schema policy, or create non-trivial conflicts.

## 11. Stop And Block Conditions

Stop and document gaps when:

- fewer than 3 tasks exist;
- tasks do not form one parent concept arc;
- transfer/check task is missing;
- evidence fields are incomplete;
- projection tests fail or are absent;
- route/Practice policy is ambiguous;
- copy contains forbidden claims;
- product/runtime files would need route or UI admission;
- W1-W6, Modern Table, telemetry, monetization, Human QA, or route work would
  be pulled into the same wave.

## 12. Deferred Until Route Admission

- learner-facing W7-W12 route opening;
- public/playable world cards;
- progression handoff into the world;
- stale-resume support;
- Practice CTA or mapper allowlist;
- queue launchability;
- visible route copy and screen work.

## 13. Deferred Until Human QA

- learner mastery claims;
- durable learning-effect claims;
- launch-ready claims;
- 9.0 or higher learner-facing readiness claims;
- novice comprehension proof.

## 14. Deferred Until Claude Full Gap Audit

- broad world parity comparison;
- poker-theory completeness review;
- W8-W12 sequencing critique;
- public premium positioning;
- full route/content/readiness gap audit.
