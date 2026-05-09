# Scenario-Driven Training Engine / Contract Plan v1
Status: SSOT-lite
Purpose: Record the next architecture pivot after the first bounded World 2 bridge block so future rollout can move from scattered per-slice UI logic toward one canonical scenario-driven training system.
Last updated: 2026-03-09

## Use

Use this document when deciding how future training slices should be modeled, authored, and rendered.
It does not start a broad runtime rewrite.
It defines the intended direction so future pilots and migrations converge on one stable system shape.

Core rule:

- scenario/task source should carry more truth than scattered UI logic
- runner surfaces should become stable interpreters and renderers, not hidden owners of mode-specific behavior

## Why This Pivot Is Needed

The current bounded World 2 bridge block proved that multiple mode families can ship on the existing session-drill surface:

- showdown comparison
- position thinking
- initiative / aggressor logic
- board texture
- connector review
- outs / improvement counting

That proof is enough to justify the next architecture pivot.

The problem is not that the current slices are invalid.
The problem is that future scale gets more expensive if each slice keeps adding local UI logic, local answer handling, and local interpretation rules.

The goal of the scenario-driven direction is to make:

- scenario/task source more authoritative
- runner behavior more predictable
- authoring easier to validate
- bug localization easier
- mode-family rollout less ad hoc

## Canonical Scenario Payload Direction

The long-term source of truth should explicitly carry the scenario state needed by the runner.
V1 should support the following truth categories:

| Category | What the source should carry |
| --- | --- |
| intro / pre-task framing | short instruction shown before the task when needed |
| table / seat state | seat layout, occupied seats, empty seats, folded seats, active seats |
| player count | how many live players are in the hand |
| hero / villain identity | which seat is hero, which seats matter for the task |
| card visibility | visible vs hidden hole cards by seat |
| board / street | current board cards and current street |
| acting player | who acts now |
| action order truth | who acts later / earlier when the task depends on position |
| last aggressor / initiative owner | who raised last or carries pressure ownership |
| available actions | stable source-driven choices the runner should present |
| expected answer | single best answer when deterministic |
| acceptable answer(s) | legal-but-weaker answers when the slice uses them |
| feedback / reveal behavior | what becomes visible after correct/incorrect resolution |
| reinforcement / recap | compact review text after or between steps |
| mode-specific parameters | bounded extras needed by a given mode family without breaking the common structure |

## Runner Responsibilities vs Source Responsibilities

### Source responsibilities

The source should provide:

- the scenario state
- what the learner is being asked to determine
- what answer set is allowed
- what answer is best
- what reveal / feedback behavior is intended
- any bounded mode-specific parameters required for the slice

### Runner responsibilities

The runner should:

- interpret the provided scenario state
- render the stable seat / board / action surface
- present the source-driven action set without phantom or unstable changes
- evaluate deterministic answers against source truth
- reveal feedback and reinforcement according to source rules
- manage bounded step transitions cleanly

### What the runner should not guess

The runner should not implicitly guess:

- who is active if the source does not say
- whether a seat is folded or empty from display context alone
- who owns initiative unless the source defines it
- which actions are available unless the source defines them
- whether cards should be visible or hidden unless the source defines it
- whether a wrong answer should trigger a reveal path unless the source defines it

## Stable Action Presentation

Stable action presentation is part of the contract.
For a scenario-driven system:

- the action set should come from the source
- the visible order of buttons should stay deterministic
- actions should not appear or disappear unpredictably inside the same step
- mode-family variation should come from source truth, not from ad hoc widget branching

## V1 vs V2 Split

### V1

The first realistic, high-EV version should focus on:

- variable player count
- empty / folded / active seat states
- hero / villain identity
- visible vs hidden hole cards
- board / street state
- acting player
- last aggressor / initiative owner
- source-driven available actions
- deterministic correct / acceptable answer handling
- deterministic reveal and reinforcement behavior

### V2

Important later extensions should remain explicit so they are not lost:

- richer animations and micro-pauses
- deeper branching and longer multi-step chains
- tournament-specific richer state
- richer chips / stack / sizing presentation
- broader reveal choreography and presentation polish
- more complex cross-step memory or evolving scenario state

## Essential Invariants / Guard Directions

Future guards should validate at least the following:

- impossible seat states
- folded player acting
- empty seat treated as active
- hidden / visible card contradictions
- invalid available-action sets
- acting-order violations
- initiative / aggressor contradictions
- malformed expected / acceptable answer definitions
- bad reveal paths
- phantom or unstable button behavior
- malformed authored scenarios

## Practical Rollout Plan

Do not do a big-bang rewrite.
Use a staged route:

1. architecture audit  
   identify which current slices already fit this model and which local UI seams still own too much truth
2. contract definition  
   define the first realistic shared scenario payload and interpreter contract
3. one bounded pilot  
   migrate one carefully chosen slice or mode family onto the new contract
4. guarded scale  
   add guard coverage and migrate additional slices only after the pilot proves the contract shape

## Near-Term Implication

After the first bounded World 2 bridge block, the project should not keep scaling by adding more scattered local training logic indefinitely.
Future rollout should increasingly move toward:

- source-driven scenario truth
- stable interpreter-style runners
- reusable contract shapes
- stronger authored-scenario validation

This document is the reference point for that pivot.
