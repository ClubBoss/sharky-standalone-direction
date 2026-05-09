DOCUMENT 3 — CONTENT PLAN PER WORLD v2.1 (MVP-first, Worlds 0–9)

Файл: docs/content/CONTENT_PLAN_PER_WORLD_v2.1.md
Назначение: “что именно делаем по мирам” (без разночтений).

CONTENT PLAN PER WORLD v2.1
(MVP-first; compatible with ULA v4.3.1)

Global scope

MVP = Worlds 0–4:

Каждый мир: 6–10 micro-sessions

Каждая micro-session: 6–12 решений

Каждая micro-session: 1 атом

Worlds 5–9:

планируем структуру (skeleton) сейчас,

производим после MVP, без рефакторинга ядра.

WORLD 0 — Table Literacy (Zero-knowledge)

Goal:

“Я не боюсь стола и понимаю что происходит”.

Micro-session groups:
0.1 Cards & ranks (tap-to-identify)
0.2 Hands (pair, two pair, trips, straight, flush) — через примеры
0.3 Action order (preflop vs postflop)
0.4 BTN/SB/BB (что это и зачем)
0.5 Stack & pot (визуально)
0.6 Mini game: “who acts first?” + “what wins?”

Exit criteria:

=85% accuracy

decision time <5s on identify tasks

Risks:

академичность; лечим “все через действия”

WORLD 1 — Hand Discipline

Goal:

Fold как “сила”, а не “слабость”.

Atoms:

dominated aces

trash hands

overplaying top pair (в легкой форме)

Sessions:

“Play or fold?” with immediate consequence framing

минимум терминов, максимум повторения

WORLD 2 — Position Thinking (largest “aha”)

Goal:

“та же рука, другая позиция — другое решение”.

Atoms:

IP advantage

OOP pain

BTN vs early seats intuition

Sessions:

same hand, different seats

show consequence: “you act last” vs “you act first”

WORLD 3 — Preflop Framework (no charts)

Goal:

дать структуру без таблиц.

Atoms:

categories (premium/strong/medium/trash)

open/call/fold logic

“one reason” rules (простые if/then)

Sessions:

scenario-driven

start with heads-up/simple, потом добавлять context

WORLD 4 — Bet Purpose + Price

Goal:

“ставка = цель” + “колл имеет цену”.

Atoms:

value bet vs bluff bet (интуитивно)

protection (как частный случай)

price intuition (pot odds без формул)

Sessions:

choose action + choose size (в ограниченном наборе)

show: what are you trying to achieve?

Transfer hook:

Take to the Table checklist (3 tasks)

WORLD 5 — Board Awareness (post-MVP production)

Skeleton:

dry/wet

draws recognition

“board changed relative strength”

WORLD 6 — Range Thinking (Scaffolded)

Skeleton:

bucket model only

“who has more strong hands?” only

no % / no combos

WORLD 7 — Stack Depth Logic

Skeleton:

100bb vs 20bb different plan

jam/fold intuition, no charts in first pass

WORLD 8 — Tournament Context + ICM Intro

Skeleton:

bubble intuition

survival pressure

risk premium without equations

WORLD 9 — Real-Player Thinking (mass-friendly exploit)

Skeleton:

profile opponent in 2x2 (tight/loose x passive/aggressive)

adjust 1 lever at a time

avoid leveling wars

Note:

NOT HU specialization. Not solver exploit.

After Core (Level 9) - Specialization Tracks v1 (DEFERRED)

Flow:
1) Transition Explainer (60-120s): variance, time structure, skill emphasis.
2) Track selection:
   - Cash Mastery
   - Tournament Mastery (MTT)
   - Not sure yet (Mixed playlist fallback)
3) Unlock post-core Track chapters (3-5 chapters per Track in v1).
4) Keep Mastery tiers and Leaks resurfacing active across Tracks.

Rule:
Core Levels 0..9 stay shared and canonical; no early branching before Core completion.

## Format-Context Boundary Contract (Shared Core vs Specialization)

Purpose:

Define which context axes exist in the product, which are intentionally abstracted during the shared core, and when content/copy/routing may begin teaching context-dependent policy.

Context axes that exist:

- game type: cash / MTT / mixed
- table format: 6-max / 9-max
- stack depth bands
- ante / blind structure
- rake / cash incentives
- ICM / survival pressure

Shared core abstraction boundary:

- Core Worlds 0..9 may teach durable anchors, local action logic, simple bet-purpose logic, price intuition, and early heuristics that survive across many formats.
- Core Worlds 0..9 may reference context lightly only to improve orientation, not to claim final policy for every format.
- Core Worlds 0..9 intentionally suppress format-specific policy branching across the axes above.

Shared core may teach invariant foundations only:

- table orientation
- seat order and street order
- local hand and board recognition
- action-selection basics
- basic bet purpose
- basic price and consequence awareness
- early stack/pressure intuition at a non-track-specific level

Shared core must not be framed as final context-independent policy for:

- preflop range policy by format
- stack-depth-specific plan changes
- ante-driven opening or defense shifts
- rake-driven cash adjustments
- ICM-driven tournament deviations
- 6-max vs 9-max final action thresholds
- endgame or bubble risk tradeoffs

Allowed specialization split triggers after Core:

- track routing
- policy copy
- content variants
- guards/contracts

Meaning:

- routing may split into Cash / Tournament / Mixed only after Core completion
- policy wording may become context-dependent only after the split is explicit
- content variants may diverge by format only after the split is explicit
- guards/contracts should protect against early-core drift into false universal teaching or premature track-specific policy

Wording boundary:

- Shared core teaches durable anchors and early heuristics.
- Specialization owns final context-dependent policy.
- Early worlds must not imply that one answer is final across cash, MTT, 6-max, 9-max, ante, rake, stack-depth, or ICM contexts.
