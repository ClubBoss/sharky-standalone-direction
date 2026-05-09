# World Spine SSOT v1

Status: documentation-only specification for the first 10 worlds.
Scope: naming + structure only. No runtime behavior changes.

## 1) Overview

- World: a themed learning block in the campaign spine (W1..W10).
- Node: one playable step inside a world (Duolingo-style ladder item).
- Progression model: worlds are completed in order; each world adds one new skill constraint on top of previous worlds.

## 2) World Spine (W1..W10)

### W1
- EN: Foundations
- RU: Osnovy
- Theme: table literacy, turn order, basic action understanding.
- Difficulty intent: establish baseline correctness and pacing.
- Node target: 12-18
- Completion signal: unlock W2; player can finish basic decision loops reliably.

### W2
- EN: Position Basics
- RU: Pozitsiya Baza
- Theme: relative seat value and acting order impact.
- Difficulty intent: add positional context to preflop choices.
- Node target: 12-18
- Completion signal: unlock W3; player distinguishes in-position vs out-of-position spots.

### W3
- EN: Pot Odds Intro
- RU: Pot Oddsy Vvedenie
- Theme: call/fold logic using simple pot odds.
- Difficulty intent: add numeric call threshold discipline.
- Node target: 12-18
- Completion signal: unlock W4; player avoids obvious -EV calls.

### W4
- EN: Bet Sizing Basics
- RU: Razmery Betov Baza
- Theme: standard bet and raise sizing patterns.
- Difficulty intent: add deterministic sizing quality checks.
- Node target: 12-18
- Completion signal: unlock W5; player uses consistent baseline sizings.

### W5
- EN: Board Texture
- RU: Tekstura Borda
- Theme: dry vs wet boards and pressure adjustment.
- Difficulty intent: add texture-driven action selection.
- Node target: 12-18
- Completion signal: unlock W6; player adapts action to board class.

### W6
- EN: Turn Pressure
- RU: Davlenie Turna
- Theme: second-barrel and turn defense fundamentals.
- Difficulty intent: add multi-street commitment discipline.
- Node target: 12-18
- Completion signal: unlock W7; player sustains coherent plans past flop.

### W7
- EN: River Decisions
- RU: River Resheniya
- Theme: value vs bluff boundaries on river.
- Difficulty intent: add thin value and bluff-catch constraints.
- Node target: 12-18
- Completion signal: unlock W8; player improves final-street clarity.

### W8
- EN: Exploit Adjustments
- RU: Eksploit Adaptatsii
- Theme: population tendencies and simple exploit shifts.
- Difficulty intent: add controlled deviations from baseline.
- Node target: 12-18
- Completion signal: unlock W9; player can explain exploit reason for adjustments.

### W9
- EN: High Leverage Spots
- RU: Vysokiy Leverage Spoty
- Theme: large-pot and high-pressure branches.
- Difficulty intent: add error-cost awareness under pressure.
- Node target: 12-18
- Completion signal: unlock W10; player maintains quality in costly spots.

### W10
- EN: Mastery Integration
- RU: Integratsiya Mastery
- Theme: full-loop integration across streets and contexts.
- Difficulty intent: combine all prior constraints in stable execution.
- Node target: 12-18
- Completion signal: campaign spine completion; mastery-ready confidence gate.

## 3) Guardrails

- This document does not imply content expansion.
- This document does not change engine behavior.
- This document does not change routing/navigation.
- This document is SSOT for naming and progression structure only.
