DOCUMENT 2 — CONTENT SYSTEM v2.1 (Final Operating System)

Файл: docs/content/CONTENT_SYSTEM_v2.1.md
Статус: LOCK после принятия
Назначение: “как мы производим контент без методистов и без ошибок”.

⸻

CONTENT SYSTEM v2.1
(Final Operating System for Content Production)

⸻

1) SSOT HIERARCHY (что главнее)
    1.    UNIFIED LEARNING ARCHITECTURE v4.3.1 (структура миров) — frozen.
    2.    CONTENT SYSTEM v2.1 (правила производства и QA) — этот документ.
    3.    CONTENT PLAN PER WORLD v2.1 (что именно делаем в каждом мире).
    4.    Любые заметки/агентские идеи — non-SSOT, пока не внесены в (2)-(3).

Rule:
    •    Если что-то противоречит (1) — это “proposal”, а не правка.

⸻

2) CONTENT UNIT = “MICRO-SESSION”

Единица контента — не “урок”, а micro-session (3–7 минут):

Скелет:
    1.    1 цель (1 skill atom)
    2.    6–12 решений (table-first)
    3.    Ошибка -> 1–2 строки factual feedback
    4.    1 короткое повторение (variation) или увод в Leaks
    5.    Закрытие (компетентность/прогресс)

Запрещено:
    •    длинные лекции
    •    “советы” вместо фактов
    •    “психология” как вода

⸻

3) ATOMS (единые “атомы навыков”)

Каждый атом = одно измеримое изменение поведения, которое можно показать на столе.

Шаблон атома:
    •    Name
    •    Trigger situation (когда возникает)
    •    Correct action (что делать)
    •    Why (1 причина, простая)
    •    Common mistake
    •    One variation

⸻

4) THREE-LAYER DEPTH (бесконечная глубина без бесконечного контента)

Чтобы продукт жил годами (Duolingo-like) без генерации бесконечного контента:

Layer A — Core Path (finite, Worlds 0–9)
    •    фиксированные micro-sessions, curated

Layer B — Mastery Tiers (vertical, deterministic)
    •    тот же контент/атомы, но:
    •    меньше подсказок
    •    быстрее темп
    •    tighter thresholds
    •    больше “mixed recall” (смешение ранее пройденного)

Layer C — Personal Crucible (Leaks 2.0 логика)
    •    персональные слабости resurfacing
    •    детерминированно, не “AI”

Важно:
    •    Layer B/C добавляют годы “подписочной глубины” без строительства нового курса.

⸻

5) TODAY SPINE (одна доминирующая петля)

Today = одна CTA и один смысл открытия приложения.

Today session types (детерминированный ladder уже реализован в коде):
    1.    Gauntlet (если не пройдено)
    2.    Leaks (если due)
    3.    Practice (иначе)

Контентное правило:
    •    Today header всегда говорит человечески:
    •    “Today you forge: [Skill Focus]”
    •    а не “Daily Plan”

⸻

6) TRANSFER-TO-REAL-PLAY (чтобы не было “я прошел и удалил”)

После некоторых ключевых точек (минимум после World 4):
    •    “Take to the Table” checklist (3 пункта)
    •    это не новый движок, а 30–60 сек задания-наблюдения

Пример формата:
    •    Observe 3 hands: who acts first preflop? who acts first postflop?
    •    Spot 1 value bet vs 1 bluff attempt (в реальной игре/стриме)

⸻

7) SHARKY (маскот) — правила, чтобы не уйти в “AI-rocket”

Sharky = эмоциональный проводник, но:
    •    НЕ генератор контента
    •    НЕ чат-бот
    •    НЕ “умный коач”

Роль Sharky v1:
    •    1 фраза перед сессией (цель дня)
    •    1 реакция на успех/ошибку (коротко)
    •    1 “identity reinforcement” (“you are becoming a shark”)

Жесткие ограничения:
    •    0 open-ended диалогов
    •    0 infinite content
    •    только curated фразы из словаря

⸻

8) QA WITHOUT METHODOLOGISTS (как не ошибиться)

Мы используем pipeline, где агенты = “редакционный комитет”.

Stages:
S0 — Authoring (генерация контента агентом/пакетом)
S1 — Lint (ASCII/формат/схемы/валидаторы)
S2 — Pedagogy check (другой агент: когнитивная нагрузка, ясность)
S3 — Poker correctness check (другой агент: правила/очередность/термины)
S4 — Product check (virality/TTFV/retention)
S5 — Merge gate (только после прохождения S1–S4)

“Two-person rule”:
    •    ни один модуль не попадает в main без минимум 2 независимых одобрений (S2+S3).

⸻

9) MVP PRODUCTION RULES (90 дней)

MVP Worlds 0–4:
    •    20–40 тщательно отобранных спотов на мир
    •    5–10 ключевых micro-sessions (как “уровни”)
    •    controlled variation, без деревьев

Запрещено:
    •    “200 спотов на мир”
    •    solver-first глубина
    •    любые системы, которые требуют переписывать курс

⸻

10) Track Overlay Rules v1 (DEFERRED IMPLEMENTATION)

Tracks are deterministic playlist overlays over existing content units.
Track v1 does not require new drill kinds or schema changes.

Track selection values:
    •    cash
    •    mtt
    •    mixed (fallback only)

Overlay rules:
    •    Core Levels 0..9 remain canonical and unchanged.
    •    Track changes future post-core recommendations, not completed-core history.
    •    Ordering must be deterministic and contract-testable.

Switching rules:
    •    User can switch Track later.
    •    Switching updates future playlist emphasis and leaks resurfacing priority only.

⸻

11) Retention Without Infinite Content v1 (DEFERRED IMPLEMENTATION)

Retention is driven by tiers and resurfacing, not by infinite content generation.

Mastery tier model (3-tier):
    •    Tier 1 (Learn): hints allowed, standard pace
    •    Tier 2 (Prove): fewer hints, higher accuracy requirement
    •    Tier 3 (Speed): hints off, tighter pace, mixed recall

Leaks resurfacing model:
    •    Deterministic queue of weak error classes (3-6 items per cycle).
    •    Resurfacing reuses existing content/drill inventory.
    •    No generated content required.
