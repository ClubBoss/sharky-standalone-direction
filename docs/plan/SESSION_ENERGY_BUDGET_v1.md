# SESSION_ENERGY_BUDGET_v1

## Purpose

Define the first canonical session-energy truth layer for learner-facing session stretches so future expansion does not rely on local intuition about how heavy, tiring, or grindy one bounded run is allowed to feel.

This layer governs immediate session weight. It does not replace:
- world progression pacing truth
- prerequisite / difficulty truth
- release-gate truth
- long-horizon retention rhythm

## Governs Now

This SSOT governs:
- target weight for one micro-session or local session stretch
- how many heavy challenge steps may appear consecutively
- when lighter confidence/review interruption is required
- how a session should usually resolve or taper
- how to distinguish acceptable effort from fatigue-inducing density

This SSOT does not yet govern:
- monetization timing
- adaptive scheduling or personalization
- long-horizon mastery mapping
- runtime enforcement logic
- reward systems or gamification loops

## Core Unit

For this SSOT, a `local session stretch` means one bounded learner-visible run that feels like a coherent effort block rather than an entire world.

Examples:
- one short guided drill run
- one compact applied cluster
- one review burst with a small recap/checkpoint ending

## Target Session Weight

Default target:
- a local session stretch should feel completable in one focused sitting without requiring recovery from sustained overload

Operational interpretation:
- a stretch should usually contain one dominant effort mode, not repeated stack-ups of multiple heavy demands
- a stretch may feel demanding, but should not feel like an endless escalation ladder
- if a stretch introduces difficulty, it must still preserve at least one clear stabilizing moment before exit

## Step Weight Classes

Use these classes for planning only:

- `light`
  - recognition, recap, confidence check, low-branch reinforcement
- `medium`
  - applied but still bounded decisions, modest comparison load, stable transfer
- `heavy`
  - high-branch decisions, new applied pressure, stacked reasoning, or checkpoint-like challenge

## Heavy-Step Limit

Default rule:
- no more than `2` heavy steps should appear consecutively inside one local session stretch

Escalation rule:
- if two heavy steps occur back-to-back, the next step should usually be light or lighter-medium reinforcement
- a third consecutive heavy step requires explicit justification in design planning and should be treated as an exception, not a default rhythm

## Confidence Interruption Rule

A lighter confidence/review step should interrupt a heavy run when any of the following is true:
- two consecutive heavy steps already occurred
- a new concept was just asked to transfer under pressure
- the session has already used its main challenge beat
- the next step would otherwise continue the same demand shape without variation

Acceptable interruption forms:
- recap of the just-used concept
- easier same-family confirmation
- nearby-family recognition step
- short review / settle step before a close

## Session Ending Rule

A local session stretch should usually end in one of these shapes:
- confidence close
- recap close
- bounded checkpoint close
- progress-confirming mixed review close

Avoid as default endings:
- pure failure-loop endings
- repeated same-shape hard questions as the final beat
- unresolved fatigue endings where the last learner impression is only grind

If a session ends on a challenge step, it should still feel like a contained checkpoint rather than an abrupt drain.

## Stability vs Fatigue

Repetition is allowed when it creates stability. Repetition becomes too heavy when:
- the same challenge shape persists without an easier interruption
- the learner is asked for repeated high-branch effort with no recap or confidence step
- the session keeps escalating but never consolidates

The goal is:
- enough repetition to stabilize
- not so much same-shape pressure that the session feels draining

## Default Session Shapes

Preferred bounded shapes:
- `light -> medium -> medium -> light`
- `medium -> heavy -> light`
- `light -> medium -> heavy -> recap`
- `medium -> heavy -> heavy -> light`

Discouraged default shapes:
- `heavy -> heavy -> heavy`
- `medium -> heavy -> heavy -> heavy`
- long runs of same-family pressure with no lighter interruption

## Relationship To Other SSOTs

This layer works below `WORLD_PROGRESSION_PACING_SSOT_v1`:
- pacing truth governs broader curriculum rhythm
- session energy truth governs immediate learner load inside a bounded stretch

This layer works alongside `RETENTION_RHYTHM_ANTI_BOREDOM_v1`:
- retention truth governs anti-grind rhythm over longer learning horizons
- session energy truth governs whether one local stretch is too tiring even before long-horizon boredom appears

This layer does not replace `PREREQUISITE_DIFFICULTY_MATRIX_v1`:
- prerequisite truth decides what may come before what
- session energy truth decides how much effort can be stacked at once

## Decision Table

| Condition | Required response |
| --- | --- |
| Two heavy steps already occurred consecutively | Insert light or lighter-medium reinforcement next |
| New transfer pressure just landed | Prefer recap/confidence interruption before another heavy ask |
| Session already delivered its main challenge beat | Bias toward consolidation rather than escalation |
| Ending would otherwise be pure repeated pressure | Convert close into recap, confidence, or bounded checkpoint resolution |

## Out Of Scope

This SSOT does not yet define:
- exact minute counts
- adaptive difficulty per user
- live stamina estimation
- reward-loop timing
- monetization pacing
- mastery-map surfacing
- runtime enforcement rules

Those belong to later systems if needed.
