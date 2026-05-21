# world_10 RU Translation Pack

Status: GENERATED
World number: 10
EN title: Player Adjustment
EN subtitle: Adjust one lever at a time against real player types.
title_ru: Подстройка под игроков
subtitle_ru: Меняй один рычаг за раз против реальных типов игроков.

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

## lesson player_type_basics
status: missing
title_en: Who is at the table
subtitle_en: Tag players by one tendency before changing your line.
title_ru: Кто сидит за столом
subtitle_ru: Сначала отметь одну тенденцию игрока, а уже потом меняй линию.

- taskId: w10_player_type_intro
  status: missing
  title_en: One tendency first
  phase: theory
  stepKind: learn
  runner: _w10PlayerTypeIntroRunner
  runnerPrompt_en: Tag one clear tendency before you change strategy.
  runnerSupport_en: One useful read beats five vague labels.
  runnerQuestion_en: What is the first step in player adjustment?
  teachingStep0_title_en: Tag first, exploit second.
  teachingStep0_body_en: Look for repeated behavior: overfolding, calling too wide, bluffing too much, or bluffing too little. Build the exploit from that one signal.
  teachingStep0_title_ru: Сначала ярлык, потом подстройка.
  teachingStep0_body_ru: Ищи повторяющееся поведение: лишние пасы, слишком частые коллы, переблеф или недоблеф. Именно из одного чёткого сигнала и строится первая подстройка.
  title_ru: Сначала одна тенденция
  runnerPrompt_ru: Отметь одну явную тенденцию до того, как менять стратегию.
  runnerSupport_ru: Один полезный вывод лучше пяти расплывчатых ярлыков.
  runnerQuestion_ru: С чего начинается подстройка под игрока?

- taskId: w10_nit_tag
  status: missing
  title_en: Nit profile
  phase: drill
  stepKind: practice
  runner: _w10NitTagRunner
  runnerPrompt_en: Villain folds to steals repeatedly and rarely 3-bets.
  runnerSupport_en: Tight fold-heavy behavior has one obvious label.
  runnerQuestion_en: What is the most useful quick tag?
  teachingStep0_title_en: Tag first, exploit second.
  teachingStep0_body_en: Look for repeated behavior: overfolding, calling too wide, bluffing too much, or bluffing too little. Build the exploit from that one signal.
  teachingStep0_title_ru: Сначала тег, потом подстройка.
  teachingStep0_body_ru: Если соперник часто выбрасывает и редко оказывает давление, это уже даёт рабочий тег. Не нужно усложнять его раньше времени.
  title_ru: Профиль нита
  runnerPrompt_ru: Соперник снова и снова выбрасывает на стилы и почти не 3-бетит.
  runnerSupport_ru: Очень тайтовое и фолд-ориентированное поведение даёт очевидный ярлык.
  runnerQuestion_ru: Какой быстрый тег здесь самый полезный?

- taskId: w10_loose_passive_tag
  status: missing
  title_en: Loose-passive profile
  phase: drill
  stepKind: practice
  runner: _w10LoosePassiveTagRunner
  runnerPrompt_en: Villain calls often preflop and postflop but rarely raises.
  runnerSupport_en: Calling wide without raises signals a common profile.
  runnerQuestion_en: What quick tag fits best?
  teachingStep0_title_en: Tag first, exploit second.
  teachingStep0_body_en: Look for repeated behavior: overfolding, calling too wide, bluffing too much, or bluffing too little. Build the exploit from that one signal.
  teachingStep0_title_ru: Сначала тег, потом подстройка.
  teachingStep0_body_ru: Если соперник много коллирует и почти не поднимает, это уже отдельный тип давления на твои линии. Сначала назови его честно.
  title_ru: Широкий пассивный игрок
  runnerPrompt_ru: Соперник часто коллирует префлоп и постфлоп, но почти не рейзит.
  runnerSupport_ru: Широкие коллы без агрессии обычно дают очень узнаваемый профиль.
  runnerQuestion_ru: Какой быстрый тег подходит здесь лучше всего?

- taskId: w10_overaggressive_tag
  status: missing
  title_en: Over-aggressive profile
  phase: drill
  stepKind: practice
  runner: _w10OveraggressiveTagRunner
  runnerPrompt_en: Villain double-barrels missed boards and raises often.
  runnerSupport_en: Frequent pressure with weak showdowns points to one useful tag.
  runnerQuestion_en: What quick tag fits best?
  teachingStep0_title_en: Tag first, exploit second.
  teachingStep0_body_en: Look for repeated behavior: overfolding, calling too wide, bluffing too much, or bluffing too little. Build the exploit from that one signal.
  teachingStep0_title_ru: Сначала тег, потом подстройка.
  teachingStep0_body_ru: Если соперник часто давит и потом показывает слабые вскрытия, это уже даёт рабочую гипотезу о переблефе. Важно сначала зафиксировать именно её.
  title_ru: Профиль переагрессора
  runnerPrompt_ru: Соперник часто ставит второй баррель на промазанных досках и много рейзит.
  runnerSupport_ru: Частое давление со слабыми шоудаунами даёт один очень полезный тег.
  runnerQuestion_ru: Какой быстрый тег здесь подходит лучше всего?

- taskId: w10_player_type_recap
  status: missing
  title_en: Player-type recap
  phase: review
  stepKind: review
  runner: _w10PlayerTypeRecapRunner
  runnerPrompt_en: Lesson learned: one tendency tag creates a cleaner exploit plan.
  runnerSupport_en: Avoid complex labels before evidence is stable.
  runnerQuestion_en: What is the tagging takeaway?
  teachingStep0_title_en: Tag first, exploit second.
  teachingStep0_body_en: Look for repeated behavior: overfolding, calling too wide, bluffing too much, or bluffing too little. Build the exploit from that one signal.
  teachingStep0_title_ru: Сначала тег, потом подстройка.
  teachingStep0_body_ru: Не строй сложную модель соперника раньше, чем увидел повторяемую черту. Один устойчивый тег уже сильно чище хаотичных описаний.
  title_ru: Повтор по типам игроков
  runnerPrompt_ru: Главная мысль урока: один тег по тенденции делает план подстройки чище.
  runnerSupport_ru: Не усложняй ярлыки, пока доказательств ещё мало.
  runnerQuestion_ru: Какой главный вывод по тегам здесь нужен?

## lesson adjust_one_lever
status: missing
title_en: Adjust one lever
subtitle_en: Change one action size or frequency, not everything at once.
title_ru: Меняй один рычаг
subtitle_ru: Сначала меняй одну частоту или один размер, а не всё сразу.

- taskId: w10_one_lever_intro
  status: missing
  title_en: One change at a time
  phase: theory
  stepKind: learn
  runner: _w10OneLeverIntroRunner
  runnerPrompt_en: Change one lever first: opening width, value density, or bluff rate.
  runnerSupport_en: Small precise changes are easier to trust and test.
  runnerQuestion_en: Why adjust one lever at a time?
  teachingStep0_title_en: Precision over chaos.
  teachingStep0_body_en: If a player overfolds, widen steals first. If a player overcalls, value-bet heavier first. Do not rewrite everything at once.
  teachingStep0_title_ru: Точность важнее хаоса.
  teachingStep0_body_ru: Если соперник слишком часто пасует, сначала расширь стилы. Если он переплачивает коллами, сначала ставь плотнее на вэлью. Не переписывай всю стратегию одной мыслью.
  title_ru: Одно изменение за раз
  runnerPrompt_ru: Сначала меняй один рычаг: ширину открытия, плотность вэлью или частоту блефа.
  runnerSupport_ru: Маленькие точные изменения легче проверять и держать под контролем.
  runnerQuestion_ru: Почему лучше менять по одному рычагу?

- taskId: w10_vs_nit_open_wider
  status: missing
  title_en: Steal more vs tight folds
  phase: drill
  stepKind: practice
  runner: _w10VsNitOpenWiderRunner
  runnerPrompt_en: Blinds fold too much to late-position steals.
  runnerSupport_en: Overfolding behind you increases steal EV.
  runnerQuestion_en: What is the clean first exploit?
  teachingStep0_title_en: Precision over chaos.
  teachingStep0_body_en: If a player overfolds, widen steals first. If a player overcalls, value-bet heavier first. Do not rewrite everything at once.
  teachingStep0_title_ru: Точность важнее хаоса.
  teachingStep0_body_ru: Если блайнды выбрасывают слишком часто, самая чистая первая подстройка — просто чуть чаще забирать их стилом. Не нужно сразу выдумывать пять новых линий.
  title_ru: Стилы чаще против тайтовых пасов
  runnerPrompt_ru: Блайнды слишком часто выбрасывают на поздние стилы.
  runnerSupport_ru: Частые пасы за спиной поднимают EV кражи блайндов.
  runnerQuestion_ru: Какая первая подстройка здесь самая чистая?

- taskId: w10_vs_caller_value_heavier
  status: missing
  title_en: Value heavier vs callers
  phase: drill
  stepKind: practice
  runner: _w10VsCallerValueHeavierRunner
  runnerPrompt_en: Villain calls down too wide with weak pairs.
  runnerSupport_en: Call-heavy opponents pay off thin value more often.
  runnerQuestion_en: What is the cleaner exploit lever?
  teachingStep0_title_en: Precision over chaos.
  teachingStep0_body_en: If a player overfolds, widen steals first. If a player overcalls, value-bet heavier first. Do not rewrite everything at once.
  teachingStep0_title_ru: Точность важнее хаоса.
  teachingStep0_body_ru: Если соперник платит слишком широко, сначала не блефуй больше, а добирай тяжелее. Это и есть более чистый первый рычаг.
  title_ru: Тяжелее на вэлью против коллеров
  runnerPrompt_ru: Соперник слишком широко проплачивает слабые пары до конца.
  runnerSupport_ru: Колл-ориентированные соперники чаще оплачивают тонкое вэлью.
  runnerQuestion_ru: Какой рычаг подстройки здесь чище всего?

- taskId: w10_vs_sticky_defender_tighten_steals
  status: missing
  title_en: Tighten steals vs sticky defenders
  phase: drill
  stepKind: practice
  runner: _w10VsStickyDefenderTightenStealsRunner
  runnerPrompt_en: Blinds defend wide and call postflop too often.
  runnerSupport_en: A sticky defender changes the cleanest steal lever.
  runnerQuestion_en: What is the better first adjustment?
  teachingStep0_title_en: Precision over chaos.
  teachingStep0_body_en: If a player overfolds, widen steals first. If a player overcalls, value-bet heavier first. Do not rewrite everything at once.
  teachingStep0_title_ru: Точность важнее хаоса.
  teachingStep0_body_ru: Если защитник редко сдаётся и широко продолжает, автоматическое расширение стилов уже не так чисто. Здесь первый шаг часто наоборот — чуть сузить открытие.
  title_ru: Сужай стилы против несдающихся защитников
  runnerPrompt_ru: Блайнды широко защищаются и слишком часто продолжают постфлоп.
  runnerSupport_ru: Упрямый защитник ломает стандартную логику стилов.
  runnerQuestion_ru: Какая первая подстройка здесь лучше?

- taskId: w10_table_value_vs_caller_transfer
  status: missing
  title_en: Value shift at the table
  phase: drill
  stepKind: proveIt
  runner: _w10TableValueVsCallerTransferRunner
  runnerPrompt_en: Real table. BTN opens K-Q, BB calls too wide, and the flop is K-7-2 rainbow.
  runnerSupport_en: Call-heavy opponents pay value more often. Ask what changes first before adding more bluffs.
  runnerQuestion_en: What is the cleaner first adjustment here?
  teachingStep0_title_en: Caller changes the mix.
  teachingStep0_body_en: This is the changed frame: same one-lever idea, now at a live table. When BB calls too wide, value hands move up in priority and bluffs move down.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w10_one_lever_recap
  status: missing
  title_en: One-lever recap
  phase: review
  stepKind: review
  runner: _w10OneLeverRecapRunner
  runnerPrompt_en: Lesson learned: one lever gives cleaner exploit feedback loops.
  runnerSupport_en: Test one change before stacking new assumptions.
  runnerQuestion_en: What is the one-lever takeaway?
  teachingStep0_title_en: Precision over chaos.
  teachingStep0_body_en: If a player overfolds, widen steals first. If a player overcalls, value-bet heavier first. Do not rewrite everything at once.
  teachingStep0_title_ru: Точность важнее хаоса.
  teachingStep0_body_ru: Один изменённый рычаг даёт чистую обратную связь. Несколько новых идей сразу делают результат мутным.
  title_ru: Повтор по одному рычагу
  runnerPrompt_ru: Главная мысль урока: один рычаг даёт более чистую петлю обратной связи по подстройке.
  runnerSupport_ru: Сначала проверь одно изменение, а уже потом добавляй новые допущения.
  runnerQuestion_ru: Какой главный вывод по одному рычагу здесь нужен?

## lesson exploit_guardrails
status: missing
title_en: Exploit guardrails
subtitle_en: Exploit with discipline so your line stays coherent.
title_ru: Ограждения для подстройки
subtitle_ru: Подстраивайся с дисциплиной, чтобы линия не разваливалась.

- taskId: w10_guardrails_intro
  status: missing
  title_en: Exploit without chaos
  phase: theory
  stepKind: learn
  runner: _w10ExploitGuardrailsIntroRunner
  runnerPrompt_en: Exploit does not mean abandoning discipline or hand quality.
  runnerSupport_en: Guardrails keep you from over-adjusting on thin evidence.
  runnerQuestion_en: Why do exploit guardrails matter?
  teachingStep0_title_en: Exploit with control.
  teachingStep0_body_en: Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.
  teachingStep0_title_ru: Подстройка под контролем.
  teachingStep0_body_ru: Учитывай размер выборки, держи базовую опору и не делай огромных выводов из одной-двух рук. Ограждения не дают подстройке превратиться в хаос.
  title_ru: Подстройка без хаоса
  runnerPrompt_ru: Подстройка не должна ломать дисциплину и качество рук.
  runnerSupport_ru: Ограждения защищают от переадаптации по тонким уликам.
  runnerQuestion_ru: Почему такие ограждения вообще важны?

- taskId: w10_overbluff_punish
  status: missing
  title_en: Punish overbluffs
  phase: drill
  stepKind: practice
  runner: _w10OverbluffPunishRunner
  runnerPrompt_en: Villain barrels many missed draws in obvious spots.
  runnerSupport_en: Overbluffing can be punished by wider bluff-catch windows.
  runnerQuestion_en: What is the cleaner exploit response?
  teachingStep0_title_en: Exploit with control.
  teachingStep0_body_en: Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.
  teachingStep0_title_ru: Подстройка под контролем.
  teachingStep0_body_ru: Если соперник действительно переблефовывает, окна для колла против блефа можно расширять. Но это надо делать из сигнала, а не из эмоции.
  title_ru: Наказывай переблеф
  runnerPrompt_ru: Соперник часто баррелит промазавшие дро в очевидных спотах.
  runnerSupport_ru: Переблеф можно наказывать более широкими окнами для колла против блефа.
  runnerQuestion_ru: Какой ответ подстройки здесь чище всего?

- taskId: w10_underbluff_fold_more
  status: missing
  title_en: Fold more vs underbluffs
  phase: drill
  stepKind: practice
  runner: _w10UnderbluffFoldMoreRunner
  runnerPrompt_en: Villain reaches river with strong value and few bluffs.
  runnerSupport_en: Underbluffing changes bluff-catch requirements.
  runnerQuestion_en: What is the sharper adjustment?
  teachingStep0_title_en: Exploit with control.
  teachingStep0_body_en: Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.
  teachingStep0_title_ru: Подстройка под контролем.
  teachingStep0_body_ru: Если до ривера доходят в основном сильные вэлью-руки и почти нет блефов, геройские коллы теряют смысл. Здесь дисциплина чаще ведёт к более частым пасам.
  title_ru: Чаще пасуй против недоблефа
  runnerPrompt_ru: Соперник доходит до ривера в основном с сильным вэлью и почти без блефов.
  runnerSupport_ru: Недоблеф меняет требования к коллу против блефа.
  runnerQuestion_ru: Какая подстройка здесь острее?

- taskId: w10_guardrail_sample_size
  status: missing
  title_en: Respect sample size
  phase: drill
  stepKind: practice
  runner: _w10GuardrailSampleSizeRunner
  runnerPrompt_en: You saw two odd hands but no long pattern yet.
  runnerSupport_en: Guardrails protect you when evidence is still thin.
  runnerQuestion_en: What is the cleaner exploit posture?
  teachingStep0_title_en: Exploit with control.
  teachingStep0_body_en: Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.
  teachingStep0_title_ru: Подстройка под контролем.
  teachingStep0_body_ru: Две странные руки — это ещё не паттерн. Пока выборка тонкая, ограждения важнее желания немедленно перестроить всю игру.
  title_ru: Уважай размер выборки
  runnerPrompt_ru: Ты увидел две странные руки, но длинного паттерна пока нет.
  runnerSupport_ru: Ограждения особенно важны, когда доказательств ещё мало.
  runnerQuestion_ru: Какая позиция подстройки здесь будет чище?

- taskId: w10_guardrails_recap
  status: missing
  title_en: Guardrails recap
  phase: review
  stepKind: review
  runner: _w10ExploitGuardrailsRecapRunner
  runnerPrompt_en: Lesson learned: exploits work best with guardrails and evidence.
  runnerSupport_en: Do not let one read become a full strategy collapse.
  runnerQuestion_en: What is the guardrail takeaway?
  teachingStep0_title_en: Exploit with control.
  teachingStep0_body_en: Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.
  teachingStep0_title_ru: Подстройка под контролем.
  teachingStep0_body_ru: Подстройка работает лучше всего, когда у неё есть и доказательство, и рамка. Одна заметка не должна обрушивать всю стратегию.
  title_ru: Повтор по ограждениям
  runnerPrompt_ru: Главная мысль урока: подстройка работает лучше всего вместе с доказательствами и ограждениями.
  runnerSupport_ru: Не позволяй одному риду превращаться в полный обвал стратегии.
  runnerQuestion_ru: Какой главный вывод по ограждениям здесь нужен?

## lesson player_adjustment_checkpoint
status: missing
title_en: Player-adjustment checkpoint
subtitle_en: Tag tendency, adjust one lever, keep guardrails, then transfer to real play.
title_ru: Контрольная по подстройке
subtitle_ru: Сначала тенденция, потом один рычаг, затем ограждения и перенос в реальную игру.

- taskId: w10_checkpoint_intro
  status: missing
  title_en: Three-step exploit loop
  phase: theory
  stepKind: learn
  runner: _w10PlayerTypeIntroRunner
  runnerPrompt_en: Tag one clear tendency before you change strategy.
  runnerSupport_en: One useful read beats five vague labels.
  runnerQuestion_en: What is the first step in player adjustment?
  teachingStep0_title_en: Tag first, exploit second.
  teachingStep0_body_en: Look for repeated behavior: overfolding, calling too wide, bluffing too much, or bluffing too little. Build the exploit from that one signal.
  teachingStep0_title_ru: Сначала тег, потом подстройка.
  teachingStep0_body_ru: Контрольная собирает весь цикл: замечаешь одну тенденцию, выбираешь один рычаг, держишь ограждения и только потом переносишь это за реальный стол.
  title_ru: Цикл подстройки в три шага
  runnerPrompt_ru: Отметь одну явную тенденцию до того, как менять стратегию.
  runnerSupport_ru: Один полезный вывод лучше пяти расплывчатых ярлыков.
  runnerQuestion_ru: С чего начинается подстройка под игрока?

- taskId: w10_checkpoint_tag_line
  status: missing
  title_en: Tag then act
  phase: drill
  stepKind: practice
  runner: _w10CheckpointTagLineRunner
  runnerPrompt_en: Opponent folds blinds often but calls rivers too wide.
  runnerSupport_en: You can tag both tendencies, then choose one main lever first.
  runnerQuestion_en: What is the cleaner first step?
  teachingStep0_title_en: Exploit with control.
  teachingStep0_body_en: Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.
  teachingStep0_title_ru: Подстройка под контролем.
  teachingStep0_body_ru: Даже если у соперника несколько перекосов, первым всё равно должен стать один рабочий тег. Это сохраняет чистоту решения.
  title_ru: Сначала тег, потом ход
  runnerPrompt_ru: Соперник часто выбрасывает блайнды, но на ривере слишком широко платит.
  runnerSupport_ru: Можно заметить обе тенденции, но первый рычаг всё равно должен быть один.
  runnerQuestion_ru: Какой первый шаг здесь самый чистый?

- taskId: w10_checkpoint_lever_line
  status: missing
  title_en: One-lever exploit line
  phase: drill
  stepKind: practice
  runner: _w10CheckpointLeverLineRunner
  runnerPrompt_en: A tight blind fold profile appears in your sample.
  runnerSupport_en: Single-lever adjustment is the test.
  runnerQuestion_en: Which exploit line is the cleanest first move?
  teachingStep0_title_en: Exploit with control.
  teachingStep0_body_en: Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.
  teachingStep0_title_ru: Подстройка под контролем.
  teachingStep0_body_ru: Если видно, что игрок стабильно и слишком часто выбрасывает на блайндах, первую подстройку лучше делать через стил, а не через случайный набор новых идей. Один рычаг — одна проверка.
  title_ru: Линия одного рычага
  runnerPrompt_ru: Оппонент стабильно и слишком часто выбрасывает на блайндах.
  runnerSupport_ru: Подстройка одним рычагом и есть главный тест.
  runnerQuestion_ru: Какая линия подстройки здесь будет самым чистым первым ходом?

- taskId: w10_checkpoint_guardrail_line
  status: missing
  title_en: Guardrail discipline
  phase: drill
  stepKind: practice
  runner: _w10CheckpointGuardrailLineRunner
  runnerPrompt_en: You saw one wild bluff from villain this orbit.
  runnerSupport_en: Single hand reads can be noisy.
  runnerQuestion_en: What is the best guardrail action?
  teachingStep0_title_en: Exploit with control.
  teachingStep0_body_en: Use sample-aware reads, keep baseline anchors, and avoid extreme swings from one or two hands.
  teachingStep0_title_ru: Подстройка под контролем.
  teachingStep0_body_ru: Один дикий блеф ещё не даёт права переворачивать всю стратегию против игрока. Ограждение здесь — не терять базовую дисциплину.
  title_ru: Дисциплина ограждений
  runnerPrompt_ru: За этот круг ты увидел от соперника один очень дикий блеф.
  runnerSupport_ru: Один розыгрыш может быть шумом, а не настоящим паттерном.
  runnerQuestion_ru: Какое действие здесь лучше всего держит ограждения?

- taskId: w10_checkpoint_table_notice
  status: missing
  title_en: Real-table exploit read
  phase: drill
  stepKind: practice
  runner: _w10TableAdjustmentNoticeRunner
  runnerPrompt_en: Real table. Both blinds have folded to your late steals again and again.
  runnerSupport_en: Choose the first exploit you can actually track at the table.
  runnerQuestion_en: What is the clean first live adjustment?
  teachingStep0_title_en: Carry one exploit to the table.
  teachingStep0_body_en: Tag the tendency, pick one lever, and keep the change small enough that you can see whether it is working.
  teachingStep0_title_ru: Одна подстройка за раз.
  teachingStep0_body_ru: За реальным столом важно выбрать такую подстройку, которую ты реально можешь отслеживать. Одна маленькая подстройка лучше, чем пять идей без контроля.
  title_ru: Подстройка за реальным столом
  runnerPrompt_ru: Реальный стол. Оба блайнда снова и снова выбрасывают на твои поздние стилы.
  runnerSupport_ru: Выбери первую подстройку, которую реально можно держать в голове прямо за столом.
  runnerQuestion_ru: Какое первое живое изменение здесь самое чистое?

- taskId: w10_checkpoint_review
  status: missing
  title_en: Player-adjustment recap
  phase: review
  stepKind: proveIt
  runner: _world10PlayerAdjustmentCheckpointRunner
  runnerPrompt_en: Lesson learned: tag tendency, adjust one lever, keep guardrails.
  runnerSupport_en: Next you will transfer these guardrails-based adjustments into real-play decisions across mixed table conditions.
  runnerQuestion_en: What does player adjustment add before real-play transfer?
  teachingStep0_title_en: Exploit with structure.
  teachingStep0_body_en: Tag one tendency, choose one lever, keep guardrails, then test across table dynamics instead of one isolated hand.
  teachingStep0_title_ru: Подстройка со структурой.
  teachingStep0_body_ru: Сначала тег, потом один рычаг, затем ограждения и уже потом перенос в смешанную реальную среду. Так подстройка остаётся рабочей, а не случайной.
  title_ru: Повтор по подстройке
  runnerPrompt_ru: Главная мысль урока: сначала тенденция, потом один рычаг и только потом ограждения.
  runnerSupport_ru: Дальше ты перенесёшь такие подстройки уже в реальные игровые решения за разными столами.
  runnerQuestion_ru: Что добавляет подстройка под игрока перед переносом в реальную игру?
