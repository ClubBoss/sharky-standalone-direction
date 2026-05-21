# world_6 RU Translation Pack

Status: GENERATED
World number: 6
EN title: Board And Draws
EN subtitle: Read board texture, draws, and changing streets.
title_ru: Борд и дро
subtitle_ru: Читай текстуру борда, дро и то, как улицы меняют план.

## Coverage
- Lessons: 0/6
- Tasks: 0/29
- Runner prompts: 0/29
- Runner supports: 0/29
- Runner questions: 0/29
- Teaching step titles: 0/29
- Teaching step bodies: 0/29

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson board_texture_basics
status: missing
title_en: Dry or wet board
subtitle_en: Start by asking how much the board can change.
title_ru: Сухой или мокрый борд
subtitle_ru: Сначала пойми, насколько борд может измениться.

- taskId: w5_texture_intro
  status: missing
  title_en: Board texture
  phase: theory
  stepKind: learn
  runner: _world5TextureIntroRunner
  runnerPrompt_en: Board texture asks how much the next cards can change.
  runnerSupport_en: Dry boards change less. Wet boards create more threats.
  runnerQuestion_en: What does board texture describe?
  teachingStep0_title_en: Texture first.
  teachingStep0_body_en: Before action, ask if the board is calm or changing fast.
  teachingStep0_title_ru: Сначала текстура.
  teachingStep0_body_ru: До действия спроси себя: борд спокойный или может быстро измениться?
  title_ru: Текстура борда
  runnerPrompt_ru: Сначала спроси: борд спокойный или опасный?
  runnerSupport_ru: Сухие борды меняются медленнее. Мокрые быстрее создают новые угрозы.
  runnerQuestion_ru: Что описывает текстура борда?

- taskId: w5_dry_board
  status: missing
  title_en: Dry board
  phase: drill
  stepKind: practice
  runner: _world5DryBoardRunner
  runnerPrompt_en: K-7-2 rainbow is spread out and different suits.
  runnerSupport_en: Few obvious straight or flush paths are visible.
  runnerQuestion_en: What texture is this?
  teachingStep0_title_en: Texture first.
  teachingStep0_body_en: Before action, ask if the board is calm or changing fast.
  teachingStep0_title_ru: Сначала текстура.
  teachingStep0_body_ru: До действия спроси себя: борд спокойный или может быстро измениться?
  title_ru: Сухой борд
  runnerPrompt_ru: K-7-2 радугой: карты разбросаны и масти разные.
  runnerSupport_ru: Здесь почти не видно очевидных стрит- или флеш-путей.
  runnerQuestion_ru: Какая это текстура?

- taskId: w5_wet_board
  status: missing
  title_en: Wet board
  phase: drill
  stepKind: practice
  runner: _world5WetBoardRunner
  runnerPrompt_en: T-9-8 with two hearts can change quickly.
  runnerSupport_en: Connected ranks and suit pressure make this wet.
  runnerQuestion_en: What texture is this?
  teachingStep0_title_en: Texture first.
  teachingStep0_body_en: Before action, ask if the board is calm or changing fast.
  teachingStep0_title_ru: Сначала текстура.
  teachingStep0_body_ru: До действия спроси себя: борд спокойный или может быстро измениться?
  title_ru: Мокрый борд
  runnerPrompt_ru: T-9-8 с двумя червами может быстро измениться.
  runnerSupport_ru: Связанные ранги и мастевая угроза делают такой борд мокрым.
  runnerQuestion_ru: Какая это текстура?

- taskId: w5_texture_recap
  status: missing
  title_en: Texture recap
  phase: review
  stepKind: review
  runner: _world5TextureRecapRunner
  runnerPrompt_en: Lesson learned: texture says how fast a board can change.
  runnerSupport_en: Dry is calmer. Wet has more obvious improvement paths.
  runnerQuestion_en: What is the first board read?
  teachingStep0_title_en: Texture checklist.
  teachingStep0_body_en: Look at rank connection and suits before choosing an action.
  teachingStep0_title_ru: Проверка текстуры.
  teachingStep0_body_ru: Сначала смотри на связность рангов и масти, а уже потом выбирай действие.
  title_ru: Повтор по текстуре
  runnerPrompt_ru: Главная мысль: текстура показывает, как быстро может меняться борд.
  runnerSupport_ru: Сухой борд спокойнее. Мокрый даёт больше очевидных путей усиления.
  runnerQuestion_ru: Какое первое чтение борда здесь нужно?

## lesson connected_boards
status: missing
title_en: Connected boards
subtitle_en: Connected ranks create more ways to improve.
title_ru: Связанные борды
subtitle_ru: Связанные ранги дают больше путей к усилению.

- taskId: w5_connected_intro
  status: missing
  title_en: Connected ranks
  phase: theory
  stepKind: learn
  runner: _world5ConnectedIntroRunner
  runnerPrompt_en: Connected ranks sit close together, like 9-8-7.
  runnerSupport_en: Close ranks create more straight paths.
  runnerQuestion_en: What makes a board connected?
  teachingStep0_title_en: Ranks can connect.
  teachingStep0_body_en: Cards close in rank create more straight possibilities.
  teachingStep0_title_ru: Ранги могут связываться.
  teachingStep0_body_ru: Карты, близкие по рангу, создают больше возможностей для стрита.
  title_ru: Связанные ранги
  runnerPrompt_ru: Связанные ранги стоят рядом, как 9-8-7.
  runnerSupport_ru: Близкие ранги создают больше стрит-путей.
  runnerQuestion_ru: Что делает борд связанным?

- taskId: w5_disconnected_board
  status: missing
  title_en: Disconnected board
  phase: drill
  stepKind: practice
  runner: _world5DisconnectedBoardRunner
  runnerPrompt_en: A-K-4 is high-card heavy but not connected.
  runnerSupport_en: The ranks are far apart.
  runnerQuestion_en: Is this board connected?
  teachingStep0_title_en: Texture first.
  teachingStep0_body_en: Before action, ask if the board is calm or changing fast.
  teachingStep0_title_ru: Сначала текстура.
  teachingStep0_body_ru: До действия спроси себя: борд спокойный или может быстро измениться?
  title_ru: Несвязанный борд
  runnerPrompt_ru: A-K-4 выглядит тяжёлым по картам, но не связан по рангам.
  runnerSupport_ru: Между рангами слишком большие разрывы.
  runnerQuestion_ru: Связан ли этот борд?

- taskId: w5_connected_board
  status: missing
  title_en: Connected board
  phase: drill
  stepKind: practice
  runner: _world5ConnectedBoardRunner
  runnerPrompt_en: 9-8-7 is connected.
  runnerSupport_en: Many nearby ranks can complete a straight.
  runnerQuestion_en: What is the key board clue?
  teachingStep0_title_en: Texture first.
  teachingStep0_body_en: Before action, ask if the board is calm or changing fast.
  teachingStep0_title_ru: Сначала текстура.
  teachingStep0_body_ru: До действия спроси себя: борд спокойный или может быстро измениться?
  title_ru: Связанный борд
  runnerPrompt_ru: 9-8-7 — это связанный борд.
  runnerSupport_ru: Много соседних рангов дают больше способов собрать стрит.
  runnerQuestion_ru: Какой главный сигнал у этого борда?

- taskId: w5_connected_recap
  status: missing
  title_en: Connected recap
  phase: review
  stepKind: review
  runner: _world5ConnectedRecapRunner
  runnerPrompt_en: Lesson learned: connected boards create straight pressure.
  runnerSupport_en: Close ranks matter even before anyone bets.
  runnerQuestion_en: What do connected ranks create?
  teachingStep0_title_en: Connected checklist.
  teachingStep0_body_en: If ranks sit close together, slow down and watch straight paths.
  teachingStep0_title_ru: Проверка связанности.
  teachingStep0_body_ru: Если ранги стоят рядом, замедлись и посмотри на стрит-пути.
  title_ru: Повтор по связанности
  runnerPrompt_ru: Главная мысль: связанные борды создают стрит-давление.
  runnerSupport_ru: Близкие ранги важны ещё до любого действия.
  runnerQuestion_ru: Что создают связанные ранги?

## lesson flush_draws
status: missing
title_en: Flush draws
subtitle_en: Three or four cards of a suit make suit pressure visible.
title_ru: Флеш-дро
subtitle_ru: Три или четыре карты одной масти сразу создают мастевую угрозу.

- taskId: w5_flush_intro
  status: missing
  title_en: Same suit pressure
  phase: theory
  stepKind: learn
  runner: _world5FlushIntroRunner
  runnerPrompt_en: A flush draw appears when one more suit card can help.
  runnerSupport_en: Count suits on the board and in hand.
  runnerQuestion_en: What does a flush draw need?
  teachingStep0_title_en: Same suit clue.
  teachingStep0_body_en: When you hold two hearts and the board has hearts, more hearts matter.
  teachingStep0_title_ru: Подсказка по масти.
  teachingStep0_body_ru: Если у тебя и на борде уже есть карты одной масти, следующая карта этой масти начинает иметь значение.
  title_ru: Мастевая угроза
  runnerPrompt_ru: Флеш-дро появляется, когда ещё одна карта масти может усилить руку.
  runnerSupport_ru: Считай масти на борде и в своих картах.
  runnerQuestion_ru: Что нужно для флеш-дро?

- taskId: w5_flush_draw_find
  status: missing
  title_en: Find flush draw
  phase: drill
  stepKind: practice
  runner: _world5FlushDrawRunner
  runnerPrompt_en: Hero has hearts and the board has hearts.
  runnerSupport_en: One more heart can improve Hero to a flush.
  runnerQuestion_en: What draw is visible?
  teachingStep0_title_en: Same suit clue.
  teachingStep0_body_en: When you hold two hearts and the board has hearts, more hearts matter.
  teachingStep0_title_ru: Подсказка по масти.
  teachingStep0_body_ru: Если у тебя и на борде уже есть карты одной масти, следующая карта этой масти начинает иметь значение.
  title_ru: Найди флеш-дро
  runnerPrompt_ru: У тебя червы, и на борде тоже лежат червы.
  runnerSupport_ru: Ещё одна черва может усилить тебя до флеша.
  runnerQuestion_ru: Какое дро здесь видно?

- taskId: w5_no_flush_draw
  status: missing
  title_en: No flush draw
  phase: drill
  stepKind: practice
  runner: _world5NoFlushDrawRunner
  runnerPrompt_en: Hero has mixed suits and the board is rainbow.
  runnerSupport_en: Rainbow means three different suits on the flop.
  runnerQuestion_en: Is a flush draw obvious?
  teachingStep0_title_en: Texture first.
  teachingStep0_body_en: Before action, ask if the board is calm or changing fast.
  teachingStep0_title_ru: Сначала текстура.
  teachingStep0_body_ru: До действия спроси себя: борд спокойный или может быстро измениться?
  title_ru: Нет флеш-дро
  runnerPrompt_ru: У тебя карты разных мастей, и борд радугой.
  runnerSupport_ru: Радуга на флопе — это три разные масти.
  runnerQuestion_ru: Есть ли здесь очевидное флеш-дро?

- taskId: w5_flush_recap
  status: missing
  title_en: Flush recap
  phase: review
  stepKind: review
  runner: _world5FlushRecapRunner
  runnerPrompt_en: Lesson learned: suits can create flush pressure.
  runnerSupport_en: Count matching suits before calling a board safe.
  runnerQuestion_en: What do you count for flush draws?
  teachingStep0_title_en: Flush checklist.
  teachingStep0_body_en: Same-suit cards show whether one more suit can change the hand.
  teachingStep0_title_ru: Проверка флеш-дро.
  teachingStep0_body_ru: Карты одной масти показывают, может ли ещё одна карта этой масти всё изменить.
  title_ru: Повтор по флеш-дро
  runnerPrompt_ru: Главная мысль: масти могут создавать давление флеш-дро.
  runnerSupport_ru: Сначала посчитай совпадающие масти, а уже потом называй борд безопасным.
  runnerQuestion_ru: Что нужно считать для флеш-дро?

## lesson straight_draws
status: missing
title_en: Straight draws
subtitle_en: Neighboring ranks can point to a straight.
title_ru: Стрит-дро
subtitle_ru: Соседние ранги могут указывать на стрит.

- taskId: w5_straight_intro
  status: missing
  title_en: Rank ladder
  phase: theory
  stepKind: learn
  runner: _world5StraightIntroRunner
  runnerPrompt_en: A straight draw uses nearby ranks to chase a five-card line.
  runnerSupport_en: Look for rank ladders.
  runnerQuestion_en: What does a straight draw use?
  teachingStep0_title_en: Rank ladder.
  teachingStep0_body_en: Straight pressure comes from nearby ranks, not suits.
  teachingStep0_title_ru: Лестница по рангам.
  teachingStep0_body_ru: Стрит-угроза рождается из близких рангов, а не из мастей.
  title_ru: Лестница по рангам
  runnerPrompt_ru: Стрит-дро использует близкие ранги, чтобы собирать линию из пяти карт.
  runnerSupport_ru: Смотри на лестницу по рангам.
  runnerQuestion_ru: На чём держится стрит-дро?

- taskId: w5_straight_draw_find
  status: missing
  title_en: Find straight draw
  phase: drill
  stepKind: practice
  runner: _world5StraightDrawRunner
  runnerPrompt_en: Hero has 6-5 and the board shows 8-7-2.
  runnerSupport_en: A 4 or 9 can improve the rank ladder.
  runnerQuestion_en: What draw is visible?
  teachingStep0_title_en: Rank ladder.
  teachingStep0_body_en: Straight pressure comes from nearby ranks, not suits.
  teachingStep0_title_ru: Лестница по рангам.
  teachingStep0_body_ru: Стрит-угроза рождается из близких рангов, а не из мастей.
  title_ru: Найди стрит-дро
  runnerPrompt_ru: У тебя 6-5, на борде 8-7-2.
  runnerSupport_ru: 4 или 9 усиливают эту лестницу по рангам.
  runnerQuestion_ru: Какое дро здесь видно?

- taskId: w5_gap_board
  status: missing
  title_en: Gap board
  phase: drill
  stepKind: practice
  runner: _world5GapBoardRunner
  runnerPrompt_en: A-Q-4 has large rank gaps.
  runnerSupport_en: Big gaps mean no obvious straight draw.
  runnerQuestion_en: Is straight pressure obvious?
  teachingStep0_title_en: Rank ladder.
  teachingStep0_body_en: Straight pressure comes from nearby ranks, not suits.
  teachingStep0_title_ru: Лестница по рангам.
  teachingStep0_body_ru: Стрит-угроза рождается из близких рангов, а не из мастей.
  title_ru: Борд с разрывами
  runnerPrompt_ru: A-Q-4 даёт большие разрывы по рангам.
  runnerSupport_ru: Большие разрывы означают, что очевидного стрита нет.
  runnerQuestion_ru: Видно ли здесь явное стрит-давление?

- taskId: w5_straight_recap
  status: missing
  title_en: Straight recap
  phase: review
  stepKind: review
  runner: _world5StraightRecapRunner
  runnerPrompt_en: Lesson learned: straight draws are rank stories.
  runnerSupport_en: Suits do not make straights. Nearby ranks do.
  runnerQuestion_en: What do you inspect for straight draws?
  teachingStep0_title_en: Straight checklist.
  teachingStep0_body_en: Find nearby ranks, then ask which next cards complete the line.
  teachingStep0_title_ru: Проверка стрит-дро.
  teachingStep0_body_ru: Сначала найди близкие ранги, потом спроси, какие карты завершают линию.
  title_ru: Повтор по стрит-дро
  runnerPrompt_ru: Главная мысль: стрит-дро — это история про ранги.
  runnerSupport_ru: Стриты делают не масти, а соседние ранги.
  runnerQuestion_ru: На что смотришь, когда ищешь стрит-дро?

## lesson outs_improvement
status: missing
title_en: Outs as improvement cards
subtitle_en: Outs are cards that can improve a hand.
title_ru: Ауты как карты усиления
subtitle_ru: Ауты — это карты, которые улучшают руку.

- taskId: w5_outs_intro
  status: missing
  title_en: Improvement cards
  phase: theory
  stepKind: learn
  runner: _world5OutsIntroRunner
  runnerPrompt_en: Outs are cards that can improve your hand.
  runnerSupport_en: At this level, just name the kind of card that helps.
  runnerQuestion_en: What is an out?
  teachingStep0_title_en: Outs are helpers.
  teachingStep0_body_en: An out is a future card that can improve your hand.
  teachingStep0_title_ru: Ауты помогают.
  teachingStep0_body_ru: Аут — это будущая карта, которая может улучшить твою руку.
  title_ru: Карты усиления
  runnerPrompt_ru: Ауты — это карты, которые могут усилить твою руку.
  runnerSupport_ru: На этом уровне достаточно назвать тип карты, который помогает.
  runnerQuestion_ru: Что такое аут?

- taskId: w5_flush_out
  status: missing
  title_en: Flush out
  phase: drill
  stepKind: practice
  runner: _world5FlushOutRunner
  runnerPrompt_en: Hero needs one more heart.
  runnerSupport_en: Any heart is the improvement card type.
  runnerQuestion_en: Which card type is the out?
  teachingStep0_title_en: Same suit clue.
  teachingStep0_body_en: When you hold two hearts and the board has hearts, more hearts matter.
  teachingStep0_title_ru: Подсказка по масти.
  teachingStep0_body_ru: Если у тебя и на борде уже есть карты одной масти, следующая карта этой масти начинает иметь значение.
  title_ru: Аут на флеш
  runnerPrompt_ru: Тебе нужна ещё одна черва.
  runnerSupport_ru: Любая черва здесь — карта усиления.
  runnerQuestion_ru: Какой тип карты здесь является аутом?

- taskId: w5_straight_out
  status: missing
  title_en: Straight out
  phase: drill
  stepKind: practice
  runner: _world5StraightOutRunner
  runnerPrompt_en: With 6-5 on 8-7-2, a 4 or 9 helps.
  runnerSupport_en: Those cards complete the straight line.
  runnerQuestion_en: Which out improves Hero?
  teachingStep0_title_en: Rank ladder.
  teachingStep0_body_en: Straight pressure comes from nearby ranks, not suits.
  teachingStep0_title_ru: Лестница по рангам.
  teachingStep0_body_ru: Стрит-угроза рождается из близких рангов, а не из мастей.
  title_ru: Аут на стрит
  runnerPrompt_ru: С 6-5 на 8-7-2 тебе помогают 4 и 9.
  runnerSupport_ru: Эти карты замыкают стритовую линию.
  runnerQuestion_ru: Какой аут усилит тебя?

- taskId: w5_table_outs_flush_transfer
  status: missing
  title_en: Live heart outs
  phase: drill
  stepKind: proveIt
  runner: _world5TableOutsFlushTransferRunner
  runnerPrompt_en: Real table. Pot 10 BB. Hero has A-heart and 7-heart on T-heart, 4-heart, 2-club, 9-spade.
  runnerSupport_en: Before calling a small bet, name the live improvement cards that still help.
  runnerQuestion_en: Which improvement cards still matter first?
  teachingStep0_title_en: Name outs before price.
  teachingStep0_body_en: A live table adds pressure, but the same transfer rule still holds: name the cards that improve Hero first, then judge the price.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w5_table_outs_straight_transfer
  status: missing
  title_en: Live straight outs
  phase: drill
  stepKind: proveIt
  runner: _world5TableOutsStraightTransferRunner
  runnerPrompt_en: Real table. Pot 9 BB. Hero has 6-spade and 5-diamond on 8-club, 7-heart, 2-spade, K-diamond.
  runnerSupport_en: Keep the same rank ladder and ask which cards still finish it on a live turn.
  runnerQuestion_en: Which improvement cards still matter first?
  teachingStep0_title_en: Blank turns do not erase outs.
  teachingStep0_body_en: A live turn card can miss without killing the draw. Keep the same straight ladder in mind and name the 4 or 9 outs before deciding.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w5_outs_recap
  status: missing
  title_en: Outs recap
  phase: review
  stepKind: review
  runner: _world5OutsRecapRunner
  runnerPrompt_en: Lesson learned: outs are improvement cards.
  runnerSupport_en: Name what can help before paying a price.
  runnerQuestion_en: What is an out?
  teachingStep0_title_en: Outs checklist.
  teachingStep0_body_en: Ask what future card improves you, then decide if the price fits.
  teachingStep0_title_ru: Проверка аутов.
  teachingStep0_body_ru: Сначала спроси, какая будущая карта тебя усиливает, а уже потом решай, подходит ли цена.
  title_ru: Повтор по аутам
  runnerPrompt_ru: Главная мысль: ауты — это карты усиления.
  runnerSupport_ru: Сначала назови, что именно может помочь, а уже потом плати цену.
  runnerQuestion_ru: Что такое аут?

## lesson turn_river_changes
status: missing
title_en: Turn and river changes
subtitle_en: Later streets can complete or miss a draw.
title_ru: Тёрн и ривер меняют расклад
subtitle_ru: Поздние улицы могут закрыть дро или оставить его пустым.

- taskId: w5_street_change_intro
  status: missing
  title_en: One new card
  phase: theory
  stepKind: learn
  runner: _world5StreetChangeIntroRunner
  runnerPrompt_en: Turn and river can complete draws or miss them.
  runnerSupport_en: Read the same draw story again after each new street card.
  runnerQuestion_en: What changes after the flop?
  teachingStep0_title_en: One card can matter.
  teachingStep0_body_en: The turn and river each add one shared card. Re-read the same board: did the draw hit, miss, or become stronger?
  teachingStep0_title_ru: Одна карта может решить многое.
  teachingStep0_body_ru: Тёрн и ривер добавляют по одной общей карте. Перечитай ту же историю: дро закрылось, промахнулось или стало сильнее?
  title_ru: Одна новая карта
  runnerPrompt_ru: Тёрн и ривер могут либо закрыть дро, либо оставить его пустым.
  runnerSupport_ru: После каждой новой общей карты перечитывай ту же историю заново.
  runnerQuestion_ru: Что меняется после флопа?

- taskId: w5_turn_hits
  status: missing
  title_en: Turn hits
  phase: drill
  stepKind: practice
  runner: _world5TurnHitsRunner
  runnerPrompt_en: The turn brings a heart. The same flush story now completes.
  runnerSupport_en: The next street did not start a new story. It finished the heart draw.
  runnerQuestion_en: What happened on the turn?
  teachingStep0_title_en: One card can matter.
  teachingStep0_body_en: The turn and river each add one shared card. Re-read the same board: did the draw hit, miss, or become stronger?
  teachingStep0_title_ru: Одна карта может решить многое.
  teachingStep0_body_ru: Тёрн и ривер добавляют по одной общей карте. Перечитай ту же историю: дро закрылось, промахнулось или стало сильнее?
  title_ru: Тёрн доезжает
  runnerPrompt_ru: На тёрне приходит черва. Та же история с флеш-дро закрывается.
  runnerSupport_ru: Новая улица не начала новую историю, а завершила старую.
  runnerQuestion_ru: Что произошло на тёрне?

- taskId: w5_river_misses
  status: missing
  title_en: River misses
  phase: drill
  stepKind: practice
  runner: _world5RiverMissesRunner
  runnerPrompt_en: The river is a black 2. The same heart story now misses.
  runnerSupport_en: The river did not help the draw you were tracking.
  runnerQuestion_en: What happened by the river?
  teachingStep0_title_en: One card can matter.
  teachingStep0_body_en: The turn and river each add one shared card. Re-read the same board: did the draw hit, miss, or become stronger?
  teachingStep0_title_ru: Одна карта может решить многое.
  teachingStep0_body_ru: Тёрн и ривер добавляют по одной общей карте. Перечитай ту же историю: дро закрылось, промахнулось или стало сильнее?
  title_ru: Ривер мимо
  runnerPrompt_ru: На ривере выходит чёрная двойка. Та же история с червами теперь не доезжает.
  runnerSupport_ru: Ривер не помог тому дро, за которым ты следил.
  runnerQuestion_ru: Чем закончилась история к риверу?

- taskId: w5_street_repair
  status: missing
  title_en: Repair the turn read
  phase: drill
  stepKind: fixMistakes
  runner: _world5StreetRepairRunner
  runnerPrompt_en: The turn connected the board, but hero still treats one pair like the flop stayed easy.
  runnerSupport_en: Repair the street-change read before repeating the flop plan.
  runnerQuestion_en: What needs fixing first?
  teachingStep0_title_en: Repair story before line.
  teachingStep0_body_en: Turn and river are not cosmetic. If the board got more connected or completed a draw, re-read the whole story before acting.
  teachingStep0_title_ru: Сначала почини историю, потом линию.
  teachingStep0_body_ru: Тёрн и ривер — не косметика. Если борд стал более связанным или закрыл дро, заново прочитай всю историю и только потом действуй.
  title_ru: Почини чтение тёрна
  runnerPrompt_ru: Тёрн связал борд, но ты всё ещё играешь одну пару так, будто флоп остался простым.
  runnerSupport_ru: Сначала почини чтение новой улицы, а уже потом повторяй план с флопа.
  runnerQuestion_ru: Что здесь нужно исправить первым?

- taskId: w5_turn_texture_shift_transfer
  status: missing
  title_en: Turn changes the texture
  phase: drill
  stepKind: proveIt
  runner: _world5TurnTextureShiftTransferRunner
  runnerPrompt_en: Real table. Flop K-9-2 looked calm, but the turn brings the T of hearts.
  runnerSupport_en: Do not replay the flop read. Ask what the new turn card changed first.
  runnerQuestion_en: What changed first on the turn?
  teachingStep0_title_en: Street changes can change texture.
  teachingStep0_body_en: On a real table, a turn card can make the same board wetter, more connected, and less comfortable for one-pair autopilot.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w5_river_draw_story_transfer
  status: missing
  title_en: River keeps the draw story honest
  phase: drill
  stepKind: proveIt
  runner: _world5RiverDrawStoryTransferRunner
  runnerPrompt_en: Real table. The flop and turn showed a heart draw, but the river bricks with the black 3.
  runnerSupport_en: Keep the same draw story in mind and decide whether it finished or missed.
  runnerQuestion_en: What is the clean river read first?
  teachingStep0_title_en: One draw story across all streets.
  teachingStep0_body_en: Do not start over on the river. Follow the same draw story through flop, turn, and river, then say clearly whether it hit or missed.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: w5_board_checkpoint
  status: missing
  title_en: Board checkpoint
  phase: review
  stepKind: proveIt
  runner: _world5BoardCheckpointRunner
  runnerPrompt_en: Lesson learned: board reading starts before the action.
  runnerSupport_en: Board first. Action second.
  runnerQuestion_en: What is the World 5 read?
  teachingStep0_title_en: World 5 checkpoint.
  teachingStep0_body_en: Pause the board, name texture, find draws, then re-read the same story when the next card lands.
  teachingStep0_title_ru: Контрольная по World 6.
  teachingStep0_body_ru: Останови взгляд на борде, назови текстуру, найди дро и перечитай ту же историю после следующей карты.
  title_ru: Контрольная по борду
  runnerPrompt_ru: Главная мысль: чтение борда начинается ещё до действия.
  runnerSupport_ru: Сначала борд, потом действие.
  runnerQuestion_ru: Какое чтение нужно в World 6?
