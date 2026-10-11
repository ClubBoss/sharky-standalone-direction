# SHARKY — Visual, Screen & Delivery Scorecard v2.2

**Дата базового среза:** 2026-10-11  
**Статус:** Manager working scorecard / proposed project handoff, **не замена** Master Plan и не разрешение на изменения кода.  
**Repo:** `ClubBoss/sharky-standalone-direction`; после merged PR #270 `main` = `4fef6d4471397aeba066180a61fefdd8acddefd9`, `ACTIVE_TASK_ID = S09`.  
**Владение изменениями:** Master Plan v5 §10A → Current Execution Context → S05 approved design → S06/S07 waves. Modern Table protected; PR #224 separate/unmerged.

**v2.2 self-contained update:** Все 18 визуальных baseline, protected Table HOLD, требования native screenshots и Bottleneck-First из v2.1 сохранены ниже. Дополнительно включён **progress burn-up S09** в приложении P. Принятая готовность и выполнение работы учитываются раздельно. Методика новая — это не продуктовая дельта.

## Менеджерское исправление ошибочной оценки

Оценка **92/100** для «Modern Table visual» из прошлого scorecard **отменена как ошибочная**. Она смешивала завершённую/защищённую техническую сцену с *визуально незавершённым* V4 кастом и посадкой персонажей. Freeze/maintenance не является доказательством качества изображения.

- **Техническая основа Modern Table:** защищённый контракт и прошедшие отдельные проверки; статус `MAINTENANCE / PROTECTED`, **не** `FULL VISUAL PASS`.
- **Visual Table / V4 шестиместная композиция:** **40/100 (ориентировочно), `HOLD_VISUAL_PRODUCT`**. В имеющихся визуальных отчётах отмечены неверная распределённость сидящих людей и двойной контур физического стола. Пользователь также отметил незавершённые active/inactive состояния. Неравные посадки/опоры и качество V4 требуют повторной доказательной приёмки на фактическом runtime.
- PR #224 (V4 cast asset integration) `OPEN / UNMERGED` на дату среза, поэтому его артефакты нельзя записывать как принятый production visual.
- **Визуальный индекс 18 блоков:** предварительно **53/100** (был ошибочно 56). Разница **−3 пункта — исправление методологии**, не ухудшение продукта. Другие субъективные значения оставлены как предварительные, без заявления о финальном визуальном PASS.

## Обязательное правило для всех экранов

**Ни чистый `flutter analyze`, ни GREEN CI, ни существование виджета/дизайна/рендера не равны `VISUAL_ACCEPTED`.** Требуются одновременно:

1. **Нативное runtime-доказательство** с точным SHA/версией сборки, стандартным размером текста, основным portrait-профилем; изображения именно запускаемого приложения, а не статического прототипа.
2. **Репрезентативные изображения:** нормальное состояние и только те альтернативы (ошибка/пусто/неактивно/repair/result), которые реально меняют критическую геометрию, информацию или действие. Не все мыслимые комбинации.
3. **Ручная визуально-продуктовая инспекция** скриншотов в натуральном масштабе и, при необходимости, 200%: иерархия, читаемость, композиция, посадка, safe-area, главный CTA, непротиворечивость общему стилю.
4. **Функциональная правда:** переходы и Back, реальные доступные действия, source-owned прогресс/оценки/состояния; несоответствие подтверждается тестом или нативным сценарием.
5. **Архивированное доказательство**: image filename → state/route → exact SHA → native profile → inspector → verdict с отличением наблюдаемого от NOT_VERIFIED.

Статусы: `UNVERIFIED` (нет нужного доказательства), `PARTIAL` (не все обязательные состояния), `HOLD_MATERIAL_VISUAL` (подтверждён дефект), `VISUAL_PASS_BOUNDED` (для конкретной стадии/маршрута), `VISUAL_ACCEPTED` (интегрированный выбранный контракт после native review). Любой экран может иметь `CODE_GREEN / VISUAL_HOLD`. Скриншоты необходимы для визуального вердикта, но сами по себе недостаточны для проверки UX/learning.

**Standard-First scope:** канонический portrait, стандартный размер текста, RU/EN, необходимые CTA, содержательный текст, нормальный Back/exit, genuine progress. Специализированные XXL/VoiceOver/редкие комбинации не создают бесконечную матрицу и могут быть `DEFERRED / NOT_VERIFIED` в рамках принятого owner amendment. Базовая читабельность и реальные значимые состояния не откладываются.

## Персональные показатели экрана — baseline v2

Оценки 0–100 — **управленческая эвристика**, а не измеренный процент выполнения и не основание изменить SSOT/stage. `Δ` от предыдущего визуального среза учитывается только если сравним метод; если оценка исправлена — `REBASE`, не продуктовая дельта.

| № | Область | Визуальный балл | Подтверждённый предел / открытый вопрос | Стадия / статус |
|---:|---|---:|---|---|
| 1 | Table / V4 visual composition | **40** | Посадка/опоры, двойной контур, полноценные live states; PR#224 не принят | **HOLD**, отдельная protected визуальная задача, без самовольного изменения S09 |
| 2 | Placement | 78 | Standard native first-start evidence; не full-product visual certification | S08 `VISUAL_PASS_BOUNDED` |
| 3 | Welcome | 76 | Нативный first-start + ungraded demo; арт/brand whole-product пока впереди | S08 `VISUAL_PASS_BOUNDED` |
| 4 | Home | 79 | Стандартный native PASS по CTA/RU/ложным checkmarks | S08 `VISUAL_PASS_BOUNDED` |
| 5 | Learn / Worlds | 78 | Нативный route и контекст; другие состояния не full-proof | S08 `VISUAL_PASS_BOUNDED` |
| 6 | Theory | 75 | RU обычного размера: содержательный текст и возврат есть | S08 `VISUAL_PASS_BOUNDED` |
| 7 | Decision / Table bridge | 73 | Первый true choice пройден; многосостоянийный bridge ещё не интегрирован S09 | S09 `PARTIAL` |
| 8 | Correct feedback | 60 | Первый feedback пройден; whole-flow redesigned visual proof ещё нет | S09 `PARTIAL` |
| 9 | Wrong feedback | 45 | Требуется exact-source native evidence | S09 `UNVERIFIED` как новый whole-product design |
| 10 | Guided repair | 42 | Требуется штатный ошибочный выбор → guided repair, screenshot & continuity | S09 `UNVERIFIED` как новый whole-product design |
| 11 | Session Summary | 35 | Обе честные ветви и доказанный следующий шаг | S09 `UNVERIFIED` как новый whole-product design |
| 12 | Practice | 43 | Voluntary vs saved/due distinction, actual empty and active state | S09 `UNVERIFIED` как новый whole-product design |
| 13 | Review | 41 | saved/notdue/due/empty по реальным источникам, без fictitious due | S09 `UNVERIFIED` как новый whole-product design |
| 14 | You / Profile | 32 | Подтверждённые earned данные, уменьшение плотности | S10 not authorized |
| 15 | Settings / first-start tools | 25 | Устранение false Account promise, реальное sheet | S10 not authorized |
| 16 | Day-2 Return | 32 | Real persistence source-backed return proof | S10 not authorized |
| 17 | Sharky / Coach | 45 | Идентичность/арт на каждом релевантном экране, реальный proof | S10 not authorized |
| 18 | Whole-product cohesion | 52 | Native integrated flow + shared visual grammar S11 | S11 not authorized |

**Visual index:** (40 + 78 + 76 + 79 + 78 + 75 + 73 + 60 + 45 + 42 + 35 + 43 + 41 + 32 + 25 + 32 + 45 + 52) / 18 = **52.83 ≈ 53/100**. Числа не подтверждают «готовность» сами по себе.

## Раздельный Table subsystem tracker (не прибавлять к 18 для исключения двойного счёта)

| Составляющая | Состояние |
|---|---|
| Scene/renderer contract, engine/table semantics | `PROTECTED / MACHINE-PROVEN within scope` — не визуальный PASS |
| Seating/ring composition of all five opponents + Hero | `HOLD_MATERIAL_VISUAL` — плотная верхняя группа / неравномерность |
| Body-chair/rail physical seated embodiment | `HOLD/NEEDS_RUNTIME_VISUAL_PROOF` |
| All-active, mixed active/folded/inactive, decision, wrong/repair | `PARTIAL / NOT_FULLY_VERIFIED` on accepted production |
| Board/pot/hero, UI-layer stacking, duplicate silhouette | `HOLD_VISUAL_REVIEW` при наличии подтверждённого double-table contour evidence |
| V4 candidate asset integration | PR #224 OPEN / UNMERGED; его собственные PASS на отдельном SHA ≠ принятый main |
| Protected Modern Table authority | Продолжает действовать. Материальный визуальный недостаток регистрируется; исправления только после узкого владельческого допуска в рамках Master Plan, не как «полировка» в S09. |

## Следующее действие

**Не открывать новый table-редизайн автоматически.** Зарегистрировать визуальный table debt и перечень минимальных доказательств, чтобы он не исчез за словом `FROZEN`. Текущий S09 выполняет одобренный Learn-to-Repair, но не подменяет визуальную арт-задачу. При последующем дизайнерском owner gate решить, должен ли отдельный bounded V4 composition fix предшествовать full-product S11 PASS; любое исключение из permanent Maintenance Mode требует доказанной материальности дефекта и отдельного разрешения, не скрытого включения в S09 PR.

## Правило дельты в будущих отчётах

Для каждого экранного блока: `score_previous → score_current | Δ | evidence delta | status | next gate`. Баллы меняются только при новой проверенной визуальной информации или завершении соответствующей задачи; CI-green без image/native visual evidence не поднимает визуальную оценку. Каждый балл должен сопровождаться указанием силы доказательства. `UNKNOWN` лучше искусственного PASS.


## Owner decision 2026-10-11 — BULLDOZER / bottleneck-first execution (v2.1)

**Решение:** сохранить визуальный debt tracker и доказательный screen gate, но **не запускать визуальные работы лишь из-за низкого балла**. Бить по одному максимальному product/learning bottleneck, уважая зависимости и активную стадию Master Plan. Нет разрешения перепрыгивать S09 или самовольно открывать Modern Table/PR #224.

**Приоритизация одной следующей задачи:**

1. **Hard blocker:** дефект или отсутствие доказательства, которое мешает текущему DoD / честному обучающему циклу.
2. **Learning EV:** восстановление настоящего решения → причинный feedback → guided repair → честный результат → source-backed next action.
3. **Dependency / sequencing:** выполнять только разрешённый слой (сейчас S09); S10/S11 позже. Не путать 25/100 Settings с более срочным S09 bottleneck.
4. **Visual EV:** менять визуальный scope при реальной потере понятности/разборчивости/игровых сигналов или на запланированном целостном gate; не идти за косметическими баллами.
5. **Evidence cost and diminishing returns:** минимальный bounded PR, точный DoD, runtime screenshots для материального визуального PASS, без построения бесконечных матриц устройств/масштабов.

**Текущее решение по исполнению:** дождаться результата уже работающего внешнего чата/агента S09. Не отправлять вторую конкурирующую задачу, не переоткрывать S08, не создавать отдельную визуальную ветку сейчас. После отчёта проверить actual HEAD/CI/native evidence, выявить **один** следующий bottleneck, дать один целевой next action. Другой чат работает отдельно: этот Scorecard становится частью его контекста только после явной передачи; локальное обновление файла само по себе не изменяет GitHub SSOT.

**Не обесценивать V4 debt:** неправильная посадка людей, chair support, двойной стол и недоказанные active/folded/inactive состояния остаются `HOLD_VISUAL_PRODUCT`; это не «готовый стол». При наличии материального влияния на понимание игрового решения или перед S11 необходим отдельный доказательный owner gate на минимальный визуальный fix. Modern Table permanent Maintenance остаётся обязательным до такого явно согласованного допуска.

**Правило scorecard дельты:** никакого прироста за CI или PR без соответствующего продуктового/визуального доказательства. Всегда показывать `прошлый балл → текущий`, причину, provenance, `UNVERIFIED/PARTIAL/PASS/HOLD`, самый ценный следующий шаг. Коррекцию методологии маркировать `REBASE`, а не прогрессом/регрессом.

**Статус решения:** `BULLDOZER_BOTTLENECK_FIRST = OWNER_APPROVED` · `ACTIVE = S09` · `NEXT = WAIT_EXISTING_AGENT_EVIDENCE` · `VISUAL_DEBT = TRACKED_NOT_AUTHORIZED_FOR_WORK` · `S10/S11/P02 = NOT_ADMITTED`.


---

## Appendix P — v2.2 Progress & Execution Delta Ledger (2026-10-11)

**Manager working scorecard; no repository SSOT adoption.** Source baseline: `main` `4fef6d4471397aeba066180a61fefdd8acddefd9`; PR #271 `e06b06583c83e37e76ba4665aacebe0ca82a07c7` DRAFT/OPEN/UNMERGED; `ACTIVE_TASK_ID=S09`. All progress credits here are provisional work tracking and cannot confer stage PASS.

### P1. Два типа дельты — оба видны в каждом отчёте

| Метрика | Что измеряет | Состояние при HOLD | Что является доказательством |
|---|---|---|---|
| **Accepted Readiness (A), 0–100** | Принятая зрелость продукта по конкретному экрану, стадии и в целом | **Не увеличивается**, если недостаёт обязательного gate | Exact SHA, требования DoD, независимое native / screenshots / тесты / merge, если они требуются |
| **Earned Execution Work (W), 0–100** | Доля **заранее названных проверяемых work outcomes** внутри активной стадии | Может расти при ещё не принятой стадии; HOLD показывается отдельно | Source audit с задачами/ID, воспроизведение и диагноз, исправление, тесты, runtime evidence, independent review |
| **Forecast / Scope** | Ожидаемый оставшийся объём и новые риски | Меняется при новой подтверждённой сложности | Явное `REFORECAST`, причина, исходная/новая структура весов |

**Поле Delta:** `ΔA / ΔW / Δscope`; не одна магическая цифра. Пример: `S09: +0 A / +10 W / scope unchanged`. Рост W **не означает** закрытый blocker и не может заменять gate. Само нахождение подтверждённого P1 можно зачесть за диагностический outcome, но не за исправление.

**ВАЖНО:** Master Plan §2 запрещает использовать единственный «project % ready» как decision authority. Общий `53,7/100` остаётся **эвристическим управленческим индексом**, а не формальным процентом релиза. Не усреднять A и W автоматически, не начислять W в A, не складывать экранный visual index и product index. Ранее принятые баллы не выдаются повторно при документационном merge.

### P2. Срез v2.2: Accepted readiness без искусственного прироста

| Блок | v2.1 A | v2.2 A | ΔA | Результат |
|---|---:|---:|---:|---|
| Sharky overall (менеджерская эвристика) | 53,7 | 53,7 | 0 | Не появилось принятого product gate после v2.1 |
| Visual & Screen Readiness | 53 | 53 | 0 | Визуальные долги не закрыты; нативные скриншоты B1 не дают full visual PASS |
| Table / V4 visual | 40 | 40 | 0 | `HOLD_VISUAL_PRODUCT`, PR #224 не в main |
| S08 First Value | 96 | 96 | 0 | Уже учтён в v2.1, закрыт и интегрирован |
| S09 Learning Loop | 45 | 45 | 0 | B1 `HOLD_MATERIAL_PRODUCT_DEFECT` |
| Wrong Feedback visual | 45 | 45 | 0 | Native proof partial, integrated wave not accepted |
| Guided Repair visual | 42 | 42 | 0 | Native scenario observed, assisted reward materially contradictory |
| Review visual | 41 | 41 | 0 | F09 исправлен в Draft PR, full native Review F09 ещё не принят |

**Остальные 18 визуальных блоков:** точь-в-точь baseline v2.1. Никаких новых произвольных баллов.

### P3. S09 — заранее объявленный рабочий бюджет 100 пунктов

**Прогноз, а не фактические часы или % качества:** S09-B1 = 45 единиц; S09-B2 = 55 единиц. Подзадача получает вес только за проверяемый outcome; одинаковое событие нельзя засчитать в два outcomes. Внутренний B1 прогресс = `27/45 = 60%`; суммарный S09 execution work = `27/100`. Это **baseline v2.2**, поэтому `ΔW = N/A (новая метрика)`, а не искусственные +27 к прежнему срезу.

#### B1 — Decision → Causal Feedback → Guided Repair (45 units)

| Outcome (доказуемая работа) | Budget | Earned | Proof / ограничение |
|---|---:|---:|---|
| Источники выбора, grading, assistance, evidence, telemetry, W1 semantic-independence изучены | 7 | **7** | Source audit в PR #271; transfer НЕ доказан |
| F09: исходные выбранный/ожидаемый ответы представлены в Review через source IDs; focused tests | 7 | **7** | Реализовано в Draft PR #271, 77/77 tests; **не значит merge/visual acceptance** |
| Реальный native independent correct и wrong → hint → assisted correct/repair подтверждены | 8 | **8** | Native executor evidence exact-SHA; independent QA финальной исправленной версии ещё впереди |
| Воспроизведён и локализован материальный assisted reward UI truth defect | 5 | **5** | Сопоставлены нативный экран и root/runner reward/receipt; P1 открыт |
| Исправлен **весь** assisted-only reward/receipt UI и доказано различие independent vs guided на EN/RU | 10 | **0** | Текущий главный bottleneck; не менять grading/telemetry/schema |
| Native telemetry cardinality/attempt/assistance, safe Back/restart reconciled | 5 | **0** | Не подтверждено; нельзя заявить PASS |
| Независимая native acceptance и интеграция B1 с exact SHA/CI | 3 | **0** | Draft PR #271 unmerged |
| **B1 total** | **45** | **27** | **60% исполнения; gate HOLD** |

#### B2 — Truthful Result → Practice/Review → Home continuity (55 units; NOT STARTED)

| Planned outcome | Budget | Earned |
|---|---:|---:|
| Genuine positive and wrong/assisted Summary, честная provenance | 15 | 0 |
| Summary → Home same source-backed next reason/target | 15 | 0 |
| Practice voluntary vs Review saved/notdue/due/empty; persistence/exit | 10 | 0 |
| EN/RU integrated native screenshots, visual/CTA proof across outcomes | 8 | 0 |
| Full trace continuity/absence duplicate choice/results across joined flow | 4 | 0 |
| Independent B2 acceptance, merge and terminal receipt | 3 | 0 |
| **B2 total** | **55** | **0** |

**Scoring integrity:** B1 45 + B2 55 = S09 100. Реальный результат ≠ число коммитов, строк кода, скриншотов или попыток. Если диагностический результат окажется недействителен или код откатят, явно скорректировать W. Не переименовывать провал в PASS. Не добавлять бонусные единицы за повторный CI.

### P4. Forecast, owner decision, change detection

- **Current blocker:** Assisted correct показывает `Read banked / Table read improved` и заполненный progress, хотя source-owned record исключает независимое доказательство; требуется минимальная presentation/projection correction.
- **Next planned earned work:** +10 W только после правдивого reward/receipt на EN/RU и proof без подмены самостоятельной проверки; +5 W после фактической телеметрии и restart; +3 W после независимой acceptance/merge. Пока всё это **0**.
- **Stop condition:** после двух узких безуспешных фиксов одной UI-инварианты — остановить label patches; проверить общий presentation projection class и предложить bounded source-consistent repair. Не менять engine без отдельного доказательства/допуска.
- **Work reforecast:** если новое доказанное P1 требует новой работы, не занижать знаменатель ради красивого процента; записать `old plan / added or reprioritized work / new 100-point redistribution`, сохранить принятую историю и обозначить `REBASE`, а не фальшивую дельту. Сохранять баллы уже валидных outcomes, если их доказательства не аннулированы.
- **Visual:** только native runtime screenshots + ручная проверка создают VISUAL_PASS. V4/seat/inactive/double-contour debt остаётся HOLD; технический freeze не равен визуальному завершению.
- **No score shopping:** выбирать задачу по material bottleneck и DoD, **не** по возможности получить быстрые +баллы. Ни W, ни A не разрешают S10/S11/P02 до соответствующего gate.

### P5. Отчёт по запросу «Прогресс / Дельта?» (постоянный формат)

| Block | A: было → сейчас (ΔA) | W: было → сейчас (ΔW) | Actual evidence | HOLD/PASS/Unknown | Next bottleneck |
|---|---|---|---|---|---|
| Общий продукт | 53,7 → 53,7 (0) | Нельзя честно суммировать из стадий до калибровки | S08 merged ранее, S09 draft | S09 active | Исправить reward proof |
| S09 | 45 → 45 (0) | Новый baseline **27/100** | F09 draft, native error/repair proof, P1 diagnosed | **HOLD** | Assisted-only receipt truth |
| Visual | 53 → 53 (0) | Tracking по relevant accepted screenshot states, без суммирования W | Native partial, V4 hold | PARTIAL/HOLD | Сохранить доказательство, не прыгать к V4 |

**Ближайшее ожидаемое событие:** результат ремонта S09-B1 на том же PR, подтверждение native reward truth/telemetry, затем independent QA и решение о merge. Никакой дополнительной реализации вне текущей S09 задачи этот Scorecard не разрешает.

### P6. Источник исторической базы

Все 18 screen visual scores, исправление `Table 92 → 40` как **METHODOLOGY REBASE**, и owner-approved Bottleneck-First из `SHARKY_VISUAL_SCREEN_EVIDENCE_SCORECARD_v2_1.md` остаются действительны. Visual 53, product 53,7 и S09 accepted 45 — **не изменяются** этим дополнением. Никакая локальная версия scorecard не подменяет repository Master Plan или Current Context.