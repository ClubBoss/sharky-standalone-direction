# Retired decisions

Run `python3 tools/decision_drift_check.py` before handing a brief to an executor or designer. Mark retained quotes with `RETIRED:` or place them under a `History` heading.

The visual timing entry records the November 23 reversal of the V6/V7 prerequisites. The November 24 owner decision defers external testing until the designer's visuals are ready, with the dark look used for internal alpha ([PLAN, «Решения по обучению»](../PLAN.md#карты-и-решения)).

| id | retired phrase (regex) | replaced by | decided (date, who) | scope globs |
|---|---|---|---|---|
| NAV-3-TABS | `3 tabs\|Three tabs\|three tabs` | 5 tabs kept (24.11, Codex option A) | 2026-11-24, owner (B34 decision) | default |
| TABLE-9-DEFAULT | `9-max default` | 6-max default, 9 seats after beta | 2026-11-20 and 2026-11-23, owner (PLAN «Решения по обучению») | default |
| W9-EARLY-ACCESS | `early access.*W9` | no early-access label (2026-11-21) | 2026-11-21, owner (PLAN «Решения по обучению») | default |
| VISUAL-PRE-BETA | `(?i)\bV[67](?:\s*(?:/\|and)\s*V[67])?\s+(?:are\s+)?(?:before\s+\|pre[- ]?)beta\b\|цепочка V6 → V9 → Бета\|Бета ждёт визуал \(V9\)\|Визуал \(ждёт дизайнера\).*V6, V7, V9\|До подписания.*\bV7\b` | beta on today's dark look; V6/V7 after beta (owner 2026-11-23 23:30). Owner update 2026-11-24: dark look for internal alpha; external testing waits for designer visuals. | 2026-11-23 23:30, owner (PLAN «Решения по обучению») | default, `docs/PLAN.md`, `docs/RELEASE.md` |
