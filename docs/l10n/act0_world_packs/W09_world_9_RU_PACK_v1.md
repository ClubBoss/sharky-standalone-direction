# world_9 RU Translation Pack

Status: GENERATED
World number: 9
EN title: Tournament Pressure
EN subtitle: Learn survival pressure and risk without equations.
title_ru: Турнирное давление
subtitle_ru: Почувствуй давление выживания и риска без формул.

## Coverage
- Lessons: 0/4
- Tasks: 0/22
- Runner prompts: 0/22
- Runner supports: 0/22
- Runner questions: 0/22
- Teaching step titles: 0/22
- Teaching step bodies: 0/22

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson survival_pressure_basics
status: missing
title_en: Chips are not life
subtitle_en: Tournament chips have survival pressure that cash chips do not.
title_ru: Фишки — это ещё и жизнь
subtitle_ru: Научись чувствовать риск вылета и давление без сложных формул.

- taskId: w9_survival_intro
  status: missing
  title_en: Tournament life pressure
  phase: theory
  stepKind: learn
  runner: _w9SurvivalIntroRunner
  runnerPrompt_en: Tournament chips carry survival value, not only chip EV.
  runnerSupport_en: When you bust, your tournament run ends.
  runnerQuestion_en: What makes tournament chips different from cash chips?
  teachingStep0_title_en: Life has value.
  teachingStep0_body_en: In cash you can reload. In tournaments, stack loss can end your whole run. That creates survival pressure before payouts and near the bubble.
  teachingStep0_title_ru: У турнирной жизни есть цена.
  teachingStep0_body_ru: В кэше можно докупиться. В турнире потеря стека может закончить весь забег. Поэтому у фишек здесь есть не только денежный, но и турнирный вес.
  title_ru: Давление турнирной жизни
  runnerPrompt_ru: Турнирные фишки важны не только сами по себе, но и как твоя жизнь в турнире.
  runnerSupport_ru: Если ты вылетаешь, турнир для тебя заканчивается.
  runnerQuestion_ru: Что отличает турнирные фишки от кэшевых?

- taskId: w9_cash_vs_tournament
  status: missing
  title_en: Cash vs tournament
  phase: drill
  stepKind: practice
  runner: _w9CashVsTournamentRunner
  runnerPrompt_en: You face a thin all-in edge with 20 BB.
  runnerSupport_en: Compare cash-game reload logic with tournament survival.
  runnerQuestion_en: Which frame should be stronger in a tournament?
  teachingStep0_title_en: Life has value.
  teachingStep0_body_en: In cash you can reload. In tournaments, stack loss can end your whole run. That creates survival pressure before payouts and near the bubble.
  teachingStep0_title_ru: Жизнь имеет цену.
  teachingStep0_body_ru: Тонкий олл-ин в кэше и в турнире ощущается по-разному. В турнире цена вылета делает такие грани заметно тяжелее.
  title_ru: Кэш против турнира
  runnerPrompt_ru: Ты видишь тонкое выставление с перевесом при 20 BB.
  runnerSupport_ru: Сравни логику докупки в кэше с ценой выживания в турнире.
  runnerQuestion_ru: Какая рамка должна быть сильнее именно в турнире?

- taskId: w9_short_stack_survival
  status: missing
  title_en: Short stack survival
  phase: drill
  stepKind: practice
  runner: _w9ShortStackSurvivalRunner
  runnerPrompt_en: You have 9 BB with blinds about to hit.
  runnerSupport_en: Very short stacks cannot wait forever.
  runnerQuestion_en: What is usually the sharper plan?
  teachingStep0_title_en: Life has value.
  teachingStep0_body_en: In cash you can reload. In tournaments, stack loss can end your whole run. That creates survival pressure before payouts and near the bubble.
  teachingStep0_title_ru: Жизнь имеет цену.
  teachingStep0_body_ru: Очень короткий стек не может просто ждать идеала. Давление выживания иногда требует искать окно раньше, чем тебя доедят блайнды.
  title_ru: Выживание с коротким стеком
  runnerPrompt_ru: У тебя 9 BB, и блайнды скоро съедят заметную часть стека.
  runnerSupport_ru: Очень короткий стек не может ждать бесконечно.
  runnerQuestion_ru: Какой план здесь обычно становится острее?

- taskId: w9_survival_stack_tradeoff
  status: missing
  title_en: Life vs reload
  phase: drill
  stepKind: practice
  runner: _w9SurvivalTradeoffRunner
  runnerPrompt_en: Cash table can reload. Tournament table cannot.
  runnerSupport_en: The same thin edge does not carry the same downside.
  runnerQuestion_en: Which table should pass more thin stack-off spots?
  teachingStep0_title_en: Life has value.
  teachingStep0_body_en: In cash you can reload. In tournaments, stack loss can end your whole run. That creates survival pressure before payouts and near the bubble.
  teachingStep0_title_ru: Жизнь имеет цену.
  teachingStep0_body_ru: В кэше тонкая грань часто принимается спокойнее, потому что можно вернуться. В турнире та же грань иногда не стоит цены вылета.
  title_ru: Жизнь против докупки
  runnerPrompt_ru: В кэше можно докупиться. В турнире — нет.
  runnerSupport_ru: Одна и та же тонкая грань несёт разную цену ошибки.
  runnerQuestion_ru: За каким столом чаще стоит пасовать тонкие выставления?

- taskId: w9_survival_recap
  status: missing
  title_en: Survival recap
  phase: review
  stepKind: review
  runner: _w9SurvivalRecapRunner
  runnerPrompt_en: Lesson learned: tournament chips include survival value.
  runnerSupport_en: Life pressure changes which thin spots are worth taking.
  runnerQuestion_en: What is the key survival takeaway?
  teachingStep0_title_en: Life has value.
  teachingStep0_body_en: In cash you can reload. In tournaments, stack loss can end your whole run. That creates survival pressure before payouts and near the bubble.
  teachingStep0_title_ru: Жизнь имеет цену.
  teachingStep0_body_ru: Турнирные фишки — это не просто абстрактные BB. Они ещё и держат твою жизнь в событии, а значит меняют порог риска.
  title_ru: Повтор по выживанию
  runnerPrompt_ru: Главная мысль урока: турнирные фишки содержат цену выживания.
  runnerSupport_ru: Давление жизни меняет то, какие тонкие споты реально стоит брать.
  runnerQuestion_ru: Какой главный вывод про выживание здесь нужно унести?

## lesson m_ratio_zones_lite
status: missing
title_en: M-ratio zones
subtitle_en: Use simple zones to choose urgency without formulas.
title_ru: Зоны M-ratio
subtitle_ru: Используй простые зоны, чтобы чувствовать срочность без формул.

- taskId: w9_m_ratio_intro
  status: missing
  title_en: Zone thinking
  phase: theory
  stepKind: learn
  runner: _w9MRatioIntroRunner
  runnerPrompt_en: M-ratio gives a quick urgency signal for tournament decisions.
  runnerSupport_en: Think in simple zones first, not formulas.
  runnerQuestion_en: What does M-ratio help you read?
  teachingStep0_title_en: Urgency by zone.
  teachingStep0_body_en: Green zone has room. Yellow zone needs planning. Red zone demands action soon. Use this to avoid both panic and passivity.
  teachingStep0_title_ru: Срочность по зоне.
  teachingStep0_body_ru: Зелёная зона даёт воздух. Жёлтая просит плана. Красная требует действий в ближайшее время. Это защищает и от паники, и от пассивности.
  title_ru: Мышление зонами
  runnerPrompt_ru: M-ratio быстро подсказывает срочность турнирного решения.
  runnerSupport_ru: Сначала думай простыми зонами, а не формулами.
  runnerQuestion_ru: Что помогает считывать M-ratio?

- taskId: w9_m_ratio_red_zone
  status: missing
  title_en: Red zone urgency
  phase: drill
  stepKind: practice
  runner: _w9MZoneRedRunner
  runnerPrompt_en: Your M-ratio is in the red zone.
  runnerSupport_en: Low zone means blinds are hurting fast.
  runnerQuestion_en: What is the sharper mindset?
  teachingStep0_title_en: Urgency by zone.
  teachingStep0_body_en: Green zone has room. Yellow zone needs planning. Red zone demands action soon. Use this to avoid both panic and passivity.
  teachingStep0_title_ru: Срочность по зоне.
  teachingStep0_body_ru: Красная зона означает, что блайнды уже бьют быстро и времени почти не осталось. Здесь мышление должно становиться резче.
  title_ru: Срочность красной зоны
  runnerPrompt_ru: Твой M-ratio уже в красной зоне.
  runnerSupport_ru: Низкая зона значит, что блайнды давят очень быстро.
  runnerQuestion_ru: Какой настрой здесь обычно самый острый?

- taskId: w9_m_ratio_green_zone
  status: missing
  title_en: Green zone patience
  phase: drill
  stepKind: practice
  runner: _w9MZoneGreenRunner
  runnerPrompt_en: Your M-ratio is in the green zone.
  runnerSupport_en: You still have room to pick spots.
  runnerQuestion_en: What usually improves in green zone?
  teachingStep0_title_en: Urgency by zone.
  teachingStep0_body_en: Green zone has room. Yellow zone needs planning. Red zone demands action soon. Use this to avoid both panic and passivity.
  teachingStep0_title_ru: Срочность по зоне.
  teachingStep0_body_ru: В зелёной зоне ещё есть возможность выбирать споты и не спешить без причины. Это не повод расслабляться, но пространство пока есть.
  title_ru: Терпение в зелёной зоне
  runnerPrompt_ru: Твой M-ratio находится в зелёной зоне.
  runnerSupport_ru: У тебя ещё есть пространство выбирать споты.
  runnerQuestion_ru: Что обычно улучшается в зелёной зоне?

- taskId: w9_m_ratio_yellow_zone
  status: missing
  title_en: Yellow zone planning
  phase: drill
  stepKind: practice
  runner: _w9MZoneYellowRunner
  runnerPrompt_en: Your M-ratio is in the yellow zone.
  runnerSupport_en: Yellow zone asks for planning before panic.
  runnerQuestion_en: What usually becomes sharper in yellow zone?
  teachingStep0_title_en: Urgency by zone.
  teachingStep0_body_en: Green zone has room. Yellow zone needs planning. Red zone demands action soon. Use this to avoid both panic and passivity.
  teachingStep0_title_ru: Срочность по зоне.
  teachingStep0_body_ru: Жёлтая зона просит уже не расслабляться, но и не паниковать. Здесь особенно важен план на ближайшие круги.
  title_ru: План в жёлтой зоне
  runnerPrompt_ru: Твой M-ratio находится в жёлтой зоне.
  runnerSupport_ru: Жёлтая зона просит плана раньше, чем начнётся паника.
  runnerQuestion_ru: Что обычно становится острее в жёлтой зоне?

- taskId: w9_m_ratio_table_window_transfer
  status: missing
  title_en: Yellow-zone table read
  phase: drill
  stepKind: proveIt
  runner: _w9MTableWindowTransferRunner
  runnerPrompt_en: Real table. Hero is BTN with A-J offsuit at 12 BB in yellow zone.
  runnerSupport_en: This is not red-zone panic yet, but the stack should not drift. Read what yellow-zone urgency changes first.
  runnerQuestion_en: What is the cleaner first zone adjustment here?
  teachingStep0_title_en: Yellow zone starts the countdown.
  teachingStep0_body_en: This is the changed frame: same M-ratio idea, live table now. Yellow zone is not freeze mode and not red-zone panic. It is the spot where urgency becomes actionable before the stack gets desperate.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w9_m_ratio_recap
  status: missing
  title_en: M-ratio recap
  phase: review
  stepKind: review
  runner: _w9MRatioRecapRunner
  runnerPrompt_en: Lesson learned: M-ratio zones map urgency.
  runnerSupport_en: Green keeps room. Red needs action soon.
  runnerQuestion_en: What is the M-ratio takeaway?
  teachingStep0_title_en: Urgency by zone.
  teachingStep0_body_en: Green zone has room. Yellow zone needs planning. Red zone demands action soon. Use this to avoid both panic and passivity.
  teachingStep0_title_ru: Срочность по зоне.
  teachingStep0_body_ru: Зоны не говорят точное действие, но хорошо показывают, сколько времени у тебя ещё есть на выбор. Это и есть их практическая сила.
  title_ru: Повтор по M-ratio
  runnerPrompt_ru: Главная мысль урока: зоны M-ratio показывают срочность.
  runnerSupport_ru: Зелёная оставляет место, красная требует решения скоро.
  runnerQuestion_ru: Какой главный вывод по M-ratio здесь нужен?

## lesson bubble_risk_premium
status: missing
title_en: Bubble risk premium
subtitle_en: Medium stacks tighten while big stacks can apply pressure.
title_ru: Цена риска на баббле
subtitle_ru: Средние стеки сужаются, а большие получают больше давления.

- taskId: w9_bubble_intro
  status: missing
  title_en: Bubble pressure basics
  phase: theory
  stepKind: learn
  runner: _w9BubblePressureIntroRunner
  runnerPrompt_en: Near the bubble, losing chips can hurt more than winning chips helps.
  runnerSupport_en: Medium stacks often feel this pressure most.
  runnerQuestion_en: What is risk premium in simple terms?
  teachingStep0_title_en: Bubble pressure shifts ranges.
  teachingStep0_body_en: Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.
  teachingStep0_title_ru: Баббл двигает диапазоны.
  teachingStep0_body_ru: Средние стеки особенно не любят вылетать рядом с деньгами, поэтому сужаются. Большие стеки могут сильнее давить. Коротким всё равно нужны реальные окна для выживания.
  title_ru: База по давлению баббла
  runnerPrompt_ru: Рядом с бабблом потеря фишек иногда болит сильнее, чем радует их прибавка.
  runnerSupport_ru: Средние стеки обычно чувствуют это давление сильнее всех.
  runnerQuestion_ru: Что означает надбавка за риск вылета простыми словами?

- taskId: w9_medium_stack_tighten
  status: missing
  title_en: Medium stack discipline
  phase: drill
  stepKind: practice
  runner: _w9MediumStackTightenRunner
  runnerPrompt_en: You are a medium stack two spots from the money.
  runnerSupport_en: Bust risk is expensive here.
  runnerQuestion_en: What is usually the sharper adjustment?
  teachingStep0_title_en: Bubble pressure shifts ranges.
  teachingStep0_body_en: Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.
  teachingStep0_title_ru: Баббл двигает диапазоны.
  teachingStep0_body_ru: Средний стек около денег платит особенно высокую цену за ошибку на стек. Поэтому дисциплина там обычно становится жёстче.
  title_ru: Дисциплина среднего стека
  runnerPrompt_ru: Ты средний стек за два места до денег.
  runnerSupport_ru: Риск вылета здесь особенно дорогой.
  runnerQuestion_ru: Какая подстройка здесь обычно самая чистая?

- taskId: w9_big_stack_leverage
  status: missing
  title_en: Big stack leverage
  phase: drill
  stepKind: practice
  runner: _w9BigStackLeverageRunner
  runnerPrompt_en: You cover both blinds near the bubble.
  runnerSupport_en: Leverage works because others face elimination risk.
  runnerQuestion_en: What usually improves for the big stack?
  teachingStep0_title_en: Bubble pressure shifts ranges.
  teachingStep0_body_en: Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.
  teachingStep0_title_ru: Баббл двигает диапазоны.
  teachingStep0_body_ru: Когда ты покрываешь тех, кто боится вылета, твоя возможность давить растёт. Именно страх вылета делает это давление рабочим.
  title_ru: Давление большого стека
  runnerPrompt_ru: Рядом с бабблом ты покрываешь оба блайнда.
  runnerSupport_ru: Давление работает, потому что для других вылет очень дорог.
  runnerQuestion_ru: Что обычно улучшается для большого стека?

- taskId: w9_bubble_short_stack
  status: missing
  title_en: Short stack urgency
  phase: drill
  stepKind: practice
  runner: _w9BubbleShortStackRunner
  runnerPrompt_en: You are the short stack near the bubble.
  runnerSupport_en: Short stacks still need survival spots, not endless folding.
  runnerQuestion_en: What usually stays true for the short stack?
  teachingStep0_title_en: Bubble pressure shifts ranges.
  teachingStep0_body_en: Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.
  teachingStep0_title_ru: Баббл двигает диапазоны.
  teachingStep0_body_ru: Короткий стек не может просто смотреть, как все тянут время. Ему всё ещё нужны рабочие споты, даже рядом с деньгами.
  title_ru: Срочность короткого стека
  runnerPrompt_ru: Ты короткий стек рядом с бабблом.
  runnerSupport_ru: Короткий стек всё равно должен находить споты на выживание, а не только бесконечно ждать.
  runnerQuestion_ru: Что обычно остаётся правдой для короткого стека?

- taskId: w9_bubble_recap
  status: missing
  title_en: Bubble recap
  phase: review
  stepKind: review
  runner: _w9BubbleRecapRunner
  runnerPrompt_en: Lesson learned: bubble pressure changes who can risk chips.
  runnerSupport_en: Medium stacks tighten more; big stacks can lean with leverage.
  runnerQuestion_en: What is the bubble-pressure takeaway?
  teachingStep0_title_en: Bubble pressure shifts ranges.
  teachingStep0_body_en: Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.
  teachingStep0_title_ru: Баббл двигает диапазоны.
  teachingStep0_body_ru: На баббле не все стеки чувствуют одно и то же. Именно разница в цене вылета и создаёт разное давление.
  title_ru: Повтор по бабблу
  runnerPrompt_ru: Главная мысль урока: баббл меняет, кто может рисковать фишками свободнее.
  runnerSupport_ru: Средние стеки сужаются сильнее, большие могут давить рычагом покрытия.
  runnerQuestion_ru: Какой главный вывод про давление баббла здесь нужен?

## lesson tournament_pressure_checkpoint
status: missing
title_en: Tournament pressure checkpoint
subtitle_en: Survival, M-ratio, and bubble pressure before player adjustment.
title_ru: Контрольная по турнирному давлению
subtitle_ru: Выживание, M-ratio и баббл сначала, подстройка под игроков потом.

- taskId: w9_checkpoint_intro
  status: missing
  title_en: Three-part pressure read
  phase: theory
  stepKind: learn
  runner: _w9SurvivalIntroRunner
  runnerPrompt_en: Tournament chips carry survival value, not only chip EV.
  runnerSupport_en: When you bust, your tournament run ends.
  runnerQuestion_en: What makes tournament chips different from cash chips?
  teachingStep0_title_en: Life has value.
  teachingStep0_body_en: In cash you can reload. In tournaments, stack loss can end your whole run. That creates survival pressure before payouts and near the bubble.
  teachingStep0_title_ru: Жизнь имеет цену.
  teachingStep0_body_ru: Контрольная собирает три уровня давления вместе: цену вылета, срочность по зоне и цену баббла. Только после этого логично думать о подстройке под игрока.
  title_ru: Чтение давления в три шага
  runnerPrompt_ru: Турнирные фишки важны не только сами по себе, но и как твоя жизнь в турнире.
  runnerSupport_ru: Если ты вылетаешь, турнир для тебя заканчивается.
  runnerQuestion_ru: Что отличает турнирные фишки от кэшевых?

- taskId: w9_checkpoint_survival_line
  status: missing
  title_en: Preserve tournament life
  phase: drill
  stepKind: practice
  runner: _w9CheckpointSurvivalLineRunner
  runnerPrompt_en: You are short with one orbit left.
  runnerSupport_en: Tournament life still needs action windows.
  runnerQuestion_en: What is the best pressure line?
  teachingStep0_title_en: Bubble pressure shifts ranges.
  teachingStep0_body_en: Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.
  teachingStep0_title_ru: Баббл двигает диапазоны.
  teachingStep0_body_ru: Даже короткому стеку нужно окно для действия, а не просто ожидание конца. Давление выживания не отменяет необходимость двигаться.
  title_ru: Сохрани турнирную жизнь
  runnerPrompt_ru: У тебя короткий стек и остался примерно один круг.
  runnerSupport_ru: Чтобы выжить в турнире, нельзя просто сидеть и ждать. Ищи окна для активных действий.
  runnerQuestion_ru: Какая линия давления здесь будет лучшей?

- taskId: w9_checkpoint_zone_line
  status: missing
  title_en: Urgency by zone
  phase: drill
  stepKind: practice
  runner: _w9CheckpointZoneLineRunner
  runnerPrompt_en: Two players face similar hand strength in different M-ratio zones.
  runnerSupport_en: Zone changes urgency.
  runnerQuestion_en: Which player should act sooner?
  teachingStep0_title_en: Bubble pressure shifts ranges.
  teachingStep0_body_en: Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.
  teachingStep0_title_ru: Баббл двигает диапазоны.
  teachingStep0_body_ru: Две похожие руки могут требовать разной скорости решения, если одна уже в красной зоне, а другая ещё нет. Срочность тоже часть силы спота.
  title_ru: Срочность по зоне
  runnerPrompt_ru: Два игрока видят похожую по силе руку, но находятся в разных зонах M-ratio.
  runnerSupport_ru: Зона меняет срочность решения.
  runnerQuestion_ru: Кто должен действовать раньше?

- taskId: w9_checkpoint_bubble_line
  status: missing
  title_en: Bubble risk premium line
  phase: drill
  stepKind: practice
  runner: _w9CheckpointBubbleLineRunner
  runnerPrompt_en: Near bubble: medium stack faces big-stack open.
  runnerSupport_en: Risk premium should influence the response.
  runnerQuestion_en: What is often the cleaner medium-stack plan?
  teachingStep0_title_en: Bubble pressure shifts ranges.
  teachingStep0_body_en: Medium stacks tighten because busting hurts. Big stacks can apply leverage. Short stacks still need practical spots to survive.
  teachingStep0_title_ru: Баббл двигает диапазоны.
  teachingStep0_body_ru: Для среднего стека на баббле цена ошибки максимальна, поэтому ответ на давление большого стека обычно становится осторожнее.
  title_ru: Линия надбавки за риск вылета на баббле
  runnerPrompt_ru: Рядом с бабблом средний стек получает открытие от большого стека.
  runnerSupport_ru: Надбавка за риск вылета должна повлиять на ответ.
  runnerQuestion_ru: Какой план для среднего стека здесь часто чище?

- taskId: w9_checkpoint_table_notice
  status: missing
  title_en: Real-table pressure read
  phase: drill
  stepKind: practice
  runner: _w9TablePressureNoticeRunner
  runnerPrompt_en: Real table. Medium stack near the bubble faces a covering big-stack open.
  runnerSupport_en: Read the pressure before you click call or jam.
  runnerQuestion_en: What is the clean first pressure read?
  teachingStep0_title_en: Name pressure before action.
  teachingStep0_body_en: Real tournament spots get easier when you first identify who can pressure and who pays the bigger busting cost.
  teachingStep0_title_ru: Сначала назови давление.
  teachingStep0_body_ru: За реальным турнирным столом сначала пойми, кто давит, кто покрывает и кто больше платит за вылет. Уже потом выбирай колл, фолд или олл-ин.
  title_ru: Давление за реальным столом
  runnerPrompt_ru: Реальный стол. Средний стек рядом с бабблом сталкивается с открытием от покрывающего большого стека.
  runnerSupport_ru: Прочитай давление до того, как жать колл или олл-ин.
  runnerQuestion_ru: Какое первое чтение давления здесь самое чистое?

- taskId: w9_checkpoint_review
  status: missing
  title_en: Tournament pressure recap
  phase: review
  stepKind: proveIt
  runner: _world9TournamentCheckpointRunner
  runnerPrompt_en: Lesson learned: tournament pressure changes risk and adjustment windows.
  runnerSupport_en: Next you will convert pressure reads into opponent-specific player adjustments.
  runnerQuestion_en: What does tournament-pressure thinking add before player adjustment?
  teachingStep0_title_en: Pressure before exploit.
  teachingStep0_body_en: First map pressure with stack and payout context. Then choose exploit lines based on who is overfolding, calling too wide, or avoiding risk.
  teachingStep0_title_ru: Сначала давление, потом подстройка.
  teachingStep0_body_ru: Сначала карта давления по стеку и выплатам, потом уже адаптация под игрока. Так подстройка не ломает турнирную логику.
  title_ru: Повтор по турнирному давлению
  runnerPrompt_ru: Главная мысль урока: турнирное давление меняет риск и окна для подстройки.
  runnerSupport_ru: Дальше ты переведёшь это давление уже в подстройки против конкретных типов игроков.
  runnerQuestion_ru: Что даёт мышление турнирным давлением до подстройки под игрока?
