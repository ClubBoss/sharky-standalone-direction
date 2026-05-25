Status: ACTIVE
Purpose: define when a concept, byte, lesson, or world is strong enough to
count as learner-ready instead of merely present.

## Why This Exists

Coverage is not enough.

One question is not automatically a byte.
One byte is not automatically a lesson.
One lesson is not automatically a world.

This standard exists to stop shallow completion from being mistaken for
learning readiness.

Use this file with:

- `docs/plan/EXECUTION_POLICY_SSOT_v1.md`
- `docs/plan/FULL_PRODUCT_READINESS_LEDGER_v1.md`
- `docs/curriculum/CONCEPT_BENCHMARK_v1.md`

Do not use it to:

- import every benchmark concept as an immediate backlog
- treat trivial concept presence as readiness closure
- justify broad curriculum rewrite inside one bounded wave

## Unit Hierarchy

- `Concept`
  - what must be learned
  - example: flush draw, acting last, side pot, top pair with weak kicker

- `Byte`
  - the smallest reusable skill loop that teaches one learner action around one
    concept
  - a byte should do more than name a topic; it should give the learner a
    usable read, decision, or correction

- `Lesson`
  - a connected sequence of bytes that builds one practical skill
  - a lesson should feel like one coherent learning job, not a checklist of
    unrelated prompts

- `World`
  - a coherent progression arc made from connected lessons
  - a world should promise one skill layer, build it in stages, and end with
    transfer/review/milestone proof

## Byte Acceptance

- `Trivial recognition byte`
  - may be short
  - acceptable when the job is narrow and explicit, such as introducing a
    notation element before deeper use

- `Core byte`
  - must include:
    - clear concept/prompt
    - visual or contextual proof
    - at least one learner action
    - feedback explaining why

- `Strong core byte`
  - should include, when relevant:
    - contrast or transfer
    - misconception-specific feedback
    - review/reuse path

Rules:

- a byte that only asks a notation-style recognition question is not enough for
  a core poker skill unless the byte explicitly teaches notation itself
- if the byte renders a table/card scene, that scene should carry the skill,
  not just decorate the prompt

## Lesson Acceptance

A lesson should usually include:

- intro/concept
- visual demo
- recognition
- guided decision
- contrast or transfer
- recap/next-step bridge

Rules:

- a lesson should combine bytes into one practical skill, not scatter them
  across unrelated subtopics
- a lesson may start simple, but it should move beyond pure recognition when
  the concept is central to table play

## World Acceptance

A world should provide:

- clear skill promise
- staged progression
- mixed practice
- review/recovery loop
- transfer to new spots
- milestone payoff

Rules:

- a world is not a topic bucket
- it should feel like one progression arc with increasing pressure, not a flat
  list of labels
- a world should prove that the learner can reuse the skill beyond the first
  example

## Visual-Context Alignment

- if a task renders a table/card scene, the learner action should use that
  visible scene unless the task explicitly teaches notation
- table/card visuals must not be decorative when the prompt asks about a poker
  concept
- prompts, options, highlights, and feedback should all align with the visible
  table truth

## Notation Safety

- raw codes such as `Ah`, `Qh`, `h`, or `A` are not a substitute for poker
  understanding
- if notation is used, it must be introduced, translated, and connected to
  visible cards
- learner-facing labels should prefer human poker language where possible:
  `hearts`, `ace of hearts`, `spades`, `board card`, `private card`

## One-Example Risk

- a concept may appear once and still not be learned
- core concepts need enough repetition, contrast, transfer, or recovery to
  avoid coverage illusion
- one clean example can introduce a concept, but it should not be mistaken for
  full readiness by itself

## Content Placement / Unit Ownership Standard

Every new learning unit must have:

- a clear owner
- a placement type
- a chronology check

Do not add content only because a file seam is convenient.
Do not add orphan drills with no clear byte, lesson, or world job.

### Placement Decision Rules

- `Expand existing byte`
  - use when:
    - same micro-skill
    - same learner action family
    - only missing visual proof, contrast, or misconception feedback
    - no new skill promise

- `Add new byte to existing lesson`
  - use when:
    - new micro-skill
    - same practical lesson promise
    - the skill fits one short reusable loop
    - no separate progression arc is needed

- `Create or reshape lesson`
  - use when:
    - 3-7 connected bytes form one practical skill
    - the topic needs intro, demo, recognition, guided decision, and transfer
    - the concept group can support review or practice reuse

- `Create or reshape world segment`
  - use when:
    - the topic changes the progression promise
    - a new stage of player development is needed
    - multiple lessons are required for mastery

- `Defer`
  - use when:
    - the concept is too advanced for the current arc
    - a safe owner seam is missing
    - scaffolding does not exist yet
    - implementation would cause scope explosion

## Progression Placement / Chronology Safety

- do not introduce a concept before its prerequisites
- do not add transfer before recognition and explanation exist
- do not add recovery before the learner has seen the base concept
- do not place advanced concepts in early worlds just because the file seam is
  easy
- do not place review, recheck, or prove variants before the base task exists
- if chronology is unclear, defer instead of inserting

Every future content wave should report:

- `Unit owner`
- `Placement type`
- `Prerequisite concepts`
- `Where those prerequisites are taught`
- `Why this unit belongs here in the path`
- `Downstream role / what it unlocks`
- `Whether an existing byte or lesson should be merged, split, or deferred`

## Placement Examples

- `Flush draw not made yet`
  - expand existing byte when the job is still the same flush-draw skill

- `Gutshot draw`
  - add a new byte inside the draws lesson

- `Clean vs risky outs`
  - add a new byte inside the board/draw/outs lesson after draw and outs
    scaffolding exists

- `Full house / quads / royal flush`
  - add new hand-strength bytes inside the hand-strength arc

- `Full house vs flush / quads vs full house`
  - add transfer/comparison bytes only after recognition exists

- `All-in meaning`
  - add a new byte after pot/stack basics

- `Matched chips`
  - add a new byte after all-in meaning

- `Side pot`
  - defer, or add only after pot/stack, all-in, and matched-chips scaffolding
    exist and the representation seam is honest

## Placement Anti-Patterns

- orphan drill
- one giant byte that teaches multiple skills at once
- one-question lesson for a core concept
- concept placed only where a file seam is convenient
- advanced concept before scaffolding
- transfer before recognition
- recovery before original concept
- table shown but not used by the learner action

## Family Parking Rule

A content family can park only when its new or changed units have:

- stable owners
- clear placement
- chronology fit
- no obvious placement drift

## Relationship To The Depth / Transfer Standard

Use this unit-acceptance standard together with the depth/transfer ladder:

1. `Recognition`
2. `Explanation`
3. `Visual table proof`
4. `Comparison`
5. `Guided decision`
6. `Independent transfer`
7. `Mistake recovery / review reuse`

The ladder judges concept depth.
This file judges whether bytes, lessons, and worlds are structurally strong
enough to carry that depth.
