DOCUMENT 1 — UNIFIED LEARNING ARCHITECTURE v4.3.1 (Final Structural Lock)

Файл: docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.3.1.md
Статус: FROZEN (структуру миров не менять)
Правило: любые изменения — только через новый major version (v4.4+), после отдельного аудита.

⸻

UNIFIED LEARNING ARCHITECTURE v4.3.1
(Final Structural Lock)

⸻

0. EXECUTIVE POSITION

Мы строим мобильное покер-обучение для:

Primary:
    •    Absolute beginners
    •    Casual/home players
    •    Weak–medium recreational players

Secondary:
    •    Strong amateurs

Not the focus:
    •    Solver-first grinders

Цель:
    •    Visible cognitive transformation
    •    Habit-forming daily loop
    •    Mass-market accessibility
    •    Long-term 10-world roadmap
    •    MVP = Worlds 0–4 (90 days)

Constraints:
    •    No infinite AI content
    •    No solver-first system
    •    No PvP foundation
    •    Deterministic engineering
    •    No “forever rocket” trap

⸻

I. CORE PHILOSOPHY

Каждый мир = когнитивный сдвиг.
Не “тема”, а смена модели мышления.

⸻

II. 10-WORLD MASTER ROADMAP

🌍 WORLD 0 — TABLE LITERACY

Цель: убрать страх и непонимание.

Навыки:
    •    Card ranking
    •    Hand combinations
    •    Order of action
    •    BTN / SB / BB
    •    Stack
    •    Pot

Метрика:
    •    =85% accuracy
    •    <5s avg decision time

⸻

🌍 WORLD 1 — HAND DISCIPLINE

Сдвиг: не каждая рука заслуживает игру.

Навыки:
    •    Weak ace awareness
    •    Fold discipline
    •    Dominated hands

⸻

🌍 WORLD 2 — POSITION THINKING

Сдвиг: позиция меняет силу.

Навыки:
    •    IP vs OOP
    •    BTN advantage
    •    Same hand != same action

⸻

🌍 WORLD 3 — PREFLOP FRAMEWORK

Сдвиг: есть структура.

Навыки:
    •    Hand categories
    •    Open / Call / Fold
    •    Rule-based logic

Запрещено:
    •    Charts в MVP

⸻

🌍 WORLD 4 — BET PURPOSE + PRICE

Сдвиг: ставка имеет цель.

Навыки:
    •    Value
    •    Bluff
    •    Protection
    •    Price intuition (простая интуиция “сколько стоит колл/ставка”)

⸻

🌍 WORLD 5 — BOARD AWARENESS

Сдвиг: доска важнее руки.

Навыки:
    •    Dry vs wet
    •    Draw awareness
    •    Board connection intuition

⸻

🌍 WORLD 6 — RANGE THINKING (SCAFFOLDED)

Запрещено:
    •    % frequencies
    •    Combinatorics
    •    Solver language

Разрешено:
Stage 1 — Bucket Model:
    •    Strong / Medium / Weak / Missed

Stage 2 — Question:
    •    “Who has more strong hands?”

Stage 3 — Board fit intuition

Stage 4 — Simplifier:
    •    Bet more / Check more

⸻

🌍 WORLD 7 — STACK DEPTH LOGIC

Сдвиг: размер стека меняет стратегию.

Навыки:
    •    100bb vs 20bb intuition
    •    Jam/fold intuition (без таблиц на старте)

⸻

🌍 WORLD 8 — TOURNAMENT CONTEXT + ICM INTRO (INTUITIVE)

Сдвиг: EV != всегда одна цель.

Навыки:
    •    Bubble intuition
    •    Survival pressure
    •    Risk premium intuition (без формул)

⸻

🌍 WORLD 9 — REAL-PLAYER THINKING (MASS-FRIENDLY “EXPLOIT”)

Сдвиг: играть против людей, а не “идеала”.

Навыки:
    •    Simple opponent profiling (loose/tight, passive/aggressive)
    •    Adjust 1 lever at a time (bet size or frequency, not both)
    •    “Do not level yourself” (анти-тильт/анти-оверфинк)

Примечание:
    •    Это не HU-специализация и не solver-эксплойт. Это массовый “real table thinking”.

⸻

III. MVP DEFINITION (STRICT)

MVP включает:
    •    Worlds 0–4 полностью
    •    Deterministic Today loop
    •    Leaks
    •    Cohort promotion (минимально)
    •    Transfer-to-real-play micro tasks (легкие, без нового движка)

MVP не включает:
    •    Deep ICM
    •    HU specialization
    •    Advanced exploit systems
    •    Social systems
    •    Infinite AI content

⸻

IV. NON-NEGOTIABLES
    •    Один доминирующий daily spine (Today loop).
    •    No rocket: никакой системы, которая требует отдельного продукта, чтобы поддерживать.

⸻

V. Post-Core Specialization Policy v1 (DEFERRED IMPLEMENTATION)

After completing Core Levels 0..9, the app introduces specialization as Tracks.

Track options (user-facing):
    •    Cash Mastery
    •    Tournament Mastery (MTT)
    •    Not sure yet (Mixed playlist) - fallback only, not a third full track

Choice timing:
    •    Show a short Transition Explainer after Level 9 completion.
    •    If dismissed, default to Mixed playlist.

Policy notes:
    •    Tracks do not rewrite Core 0..9.
    •    Tracks change post-core playlist emphasis only.
    •    Online vs Live is a later adjustment layer, not an early split.

Anti-drift rules:
    •    No early branching before Core completion.
    •    No schema changes required for Track v1.
    •    Reuse existing deterministic playlist and drill infrastructure.
