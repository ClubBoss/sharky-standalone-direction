# world_1 RU Translation Pack

Status: GENERATED
World number: 1
EN title: Poker from Zero
EN subtitle: Table literacy: cards, seats, blinds, stack, and pot.
title_ru: Покер с нуля
subtitle_ru: Грамотность за столом: карты, места, блайнды, стек и банк.

## Coverage
- Lessons: 8/8
- Tasks: 57/57
- Runner prompts: 50/57
- Runner supports: 50/57
- Runner questions: 43/57

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson what_poker_is
status: landed_or_partial
title_en: What poker is
subtitle_en: Meet the table, the players, and the goal.
title_ru: Что такое покер
subtitle_ru: Познакомься со столом, игроками и целью раздачи.

- taskId: what_poker_is_theory
  status: landed_or_partial
  title_en: Meet the table
  summary_en: Get the basic layout: seats, chips, cards, and what the table is trying to decide.
  phase: theory
  stepKind: learn
  runner: _meetTableRunner
  runnerPrompt_en: You are always the hero seat at the bottom.
  runnerSupport_en: Button, blinds, and your seat stay visible.
  runnerQuestion_en: Which seat is the hero seat?
  title_ru: Знакомство со столом
  summary_ru: Разберись в базовой картине: места, фишки, карты и то, что стол пытается определить.
  runnerPrompt_ru: Твоё место всегда внизу. С него и начинай чтение стола.
  runnerSupport_ru: Сначала найди своё место, блайнды и баттон. Эти ориентиры держат всю раздачу понятной.
  runnerQuestion_ru: Где находится место Hero?

- taskId: what_poker_is_find_hero
  status: landed_or_partial
  title_en: Find your seat
  summary_en: Spot where Hero sits before anything else starts moving.
  phase: drill
  stepKind: practice
  runner: _findHeroSeatRunner
  runnerPrompt_en: Your seat is marked as Hero.
  runnerSupport_en: Start every hand by finding your own cards and seat.
  runnerQuestion_en: Which seat is the hero seat?
  title_ru: Найди своё место
  summary_ru: Сначала научись видеть, где сидит Hero, и только потом отслеживай остальное.
  runnerPrompt_ru: Сначала найди своё место, а уже потом смотри на остальной стол.
  runnerSupport_ru: Привычка простая: сперва свои карты и своё место, потом всё остальное.
  runnerQuestion_ru: Какое место принадлежит Hero?

- taskId: what_poker_is_pot_stack
  status: landed_or_partial
  title_en: Pot and stack
  summary_en: Separate chips in the middle from chips still in a player stack.
  phase: drill
  stepKind: practice
  runner: _potStackRunner
  runnerPrompt_en: Stack is your chips. Pot is what players fight for.
  runnerSupport_en: Do not mix your stack with the pot.
  runnerQuestion_en: Which label shows the chips in the middle?
  title_ru: Банк и стек
  summary_ru: Отделяй фишки в банке от фишек, которые ещё лежат в стеке игрока.
  runnerPrompt_ru: Стек — это твои фишки. Банк — то, за что сейчас борются.
  runnerSupport_ru: Не смешивай личные фишки игрока с фишками в центре стола.
  runnerQuestion_ru: Где лежат фишки, за которые идёт борьба?

- taskId: what_poker_is_win_ways
  status: landed_or_partial
  title_en: How pots are won
  summary_en: See the two basic ways a hand ends: folds or showdown.
  phase: drill
  stepKind: practice
  runner: _winWaysRunner
  runnerPrompt_en: You win when others fold or when your hand wins showdown.
  runnerSupport_en: Early lessons only need these two endings.
  runnerQuestion_en: Which is a way to win a pot?
  title_ru: Как выигрывают банк
  summary_ru: Увидь два базовых финала раздачи: все пасуют или карты доходят до шоудауна.
  runnerPrompt_ru: Банк забирают либо без вскрытия, либо лучшей рукой на шоудауне.
  runnerSupport_ru: На старте достаточно держать в голове только эти два финала.
  runnerQuestion_ru: Как можно выиграть банк?

- taskId: what_poker_is_showdown_win
  status: landed_or_partial
  title_en: Win at showdown
  summary_en: Pick which hand wins once the cards are all face up.
  phase: drill
  stepKind: practice
  runner: _showdownBestHandRunner
  runnerPrompt_en: At showdown, the best hand wins the pot.
  runnerSupport_en: Compare the final five-card hand.
  runnerQuestion_en: What decides a showdown?
  title_ru: Победа на шоудауне
  summary_ru: Определи, какая рука выигрывает, когда все карты уже открыты.
  runnerPrompt_ru: На шоудауне банк уходит лучшей руке.
  runnerSupport_ru: Сравнивай не отдельные карты, а итоговые лучшие пять.
  runnerQuestion_ru: Что решает исход шоудауна?

- taskId: what_poker_is_table_read_transfer
  status: landed_or_partial
  title_en: Real-table first read
  summary_en: Carry the first table scan into a live-looking spot: private cards, board, then pot.
  phase: drill
  stepKind: practice
  runner: _w1TableReadTransferRunner
  runnerPrompt_en: Real table. Hero has two cards, flop has three board cards, pot is 6 BB.
  runnerSupport_en: Separate private cards, board cards, and pot before any action.
  runnerQuestion_en: What is the clean first table read?
  title_ru: Первое чтение живого стола
  summary_ru: Перенеси первое чтение стола в живой спот: карманные карты, борд, потом банк.
  runnerPrompt_ru: Смотри в одном порядке: карманные карты, борд, потом банк.
  runnerSupport_ru: Этот короткий ритм помогает не теряться даже в живом на вид споте.
  runnerQuestion_ru: С чего начинается чистое чтение стола?

- taskId: what_poker_is_review
  status: landed_or_partial
  title_en: Table recap
  summary_en: Run the full table read once clean, from seat to pot to finish.
  phase: review
  stepKind: proveIt
  runner: _tableRecapRunner
  runnerPrompt_en: Lesson learned: read the table before choosing.
  runnerSupport_en: Hero is you, opponents fight you, blinds create the first pot.
  runnerQuestion_en: What is the pot?
  title_ru: Повтор по столу
  summary_ru: Пройди чтение стола целиком и чисто: место, банк и финал раздачи.
  runnerPrompt_ru: Сначала прочитай стол, потом уже думай о решении.
  runnerSupport_ru: Hero — это ты, блайнды запускают первый банк, а стол подсказывает, что происходит.
  runnerQuestion_ru: Что такое банк?

## lesson cards_ranks_suits
status: landed_or_partial
title_en: Cards, ranks & suits
subtitle_en: 52 cards, 4 suits, 13 ranks.
title_ru: Карты, ранги и масти
subtitle_ru: 52 карты, 4 масти, 13 рангов.

- taskId: cards_ranks_suits_theory
  status: landed_or_partial
  title_en: The deck
  phase: theory
  stepKind: learn
  runner: _deckIntroRunner
  runnerPrompt_en: A deck has 52 cards.
  runnerSupport_en: Each card combines one rank with one suit.
  runnerQuestion_en: What are the two parts of a card?
  title_ru: Колода
  runnerPrompt_ru: Каждая карта состоит из ранга и масти.
  runnerSupport_ru: В колоде 52 карты. Ты читаешь карту через эти две части.
  runnerQuestion_ru: Из каких двух частей состоит карта?

- taskId: cards_ranks_suits_rank_drill
  status: landed_or_partial
  title_en: Higher card
  phase: drill
  stepKind: practice
  runner: _cardsRanksRunner
  runnerPrompt_en: Poker uses ranks and suits.
  runnerSupport_en: Aces are high in this beginner drill.
  runnerQuestion_en: Which rank is higher here?
  title_ru: Старшая карта
  runnerPrompt_ru: Сначала сравни ранг, потом уже всё остальное.
  runnerSupport_ru: В этом начальном дрилле туз старше короля.
  runnerQuestion_ru: Какой ранг здесь старше?

- taskId: cards_ranks_suits_suit_drill
  status: landed_or_partial
  title_en: Name a suit
  phase: drill
  stepKind: practice
  runner: _suitsRunner
  runnerPrompt_en: Each card has a rank and a suit.
  runnerSupport_en: We write suits as s, h, d, c here.
  runnerQuestion_en: In Ah, what is the suit?
  title_ru: Назови масть
  runnerPrompt_ru: У карты всегда есть и ранг, и масть.
  runnerSupport_ru: Здесь масти записаны коротко: s, h, d, c.
  runnerQuestion_ru: Какая масть у Ah?

- taskId: cards_ranks_suits_private_board
  status: landed_or_partial
  title_en: Private vs board
  phase: drill
  stepKind: practice
  runner: _privateBoardRunner
  runnerPrompt_en: Private cards belong to you. Board cards are shared.
  runnerSupport_en: Your two cards stay near the hero seat.
  runnerQuestion_en: Which cards can everyone use?
  title_ru: Карманные и борд
  runnerPrompt_ru: Карманные карты твои, борд общий для всех.
  runnerSupport_ru: Твои две карты остаются у Hero, а карты борда могут использовать все.
  runnerQuestion_ru: Какие карты доступны всем игрокам?

- taskId: cards_ranks_suits_board_count
  status: landed_or_partial
  title_en: Board count
  phase: drill
  stepKind: practice
  runner: _boardCountRunner
  runnerPrompt_en: A full board has five shared cards.
  runnerSupport_en: Flop 3, turn 4, river 5.
  runnerQuestion_en: How many board cards can be visible by the river?
  title_ru: Сколько карт на борде
  runnerPrompt_ru: Полный борд всегда состоит из пяти общих карт.
  runnerSupport_ru: Флоп — три, тёрн — четыре, ривер — пять.
  runnerQuestion_ru: Сколько карт борда может быть видно к риверу?

- taskId: cards_ranks_suits_best_five
  status: landed_or_partial
  title_en: Best five idea
  phase: drill
  stepKind: practice
  runner: _bestFiveCardsRunner
  runnerPrompt_en: A poker hand uses the best five cards available.
  runnerSupport_en: Use your private cards and the shared board together.
  runnerQuestion_en: How many cards make your final hand?
  title_ru: Идея лучших пяти
  runnerPrompt_ru: Итоговая рука в покере всегда собирается из лучших пяти карт.
  runnerSupport_ru: Карманные карты и борд работают вместе, но в зачёт идут только лучшие пять.
  runnerQuestion_ru: Сколько карт составляют итоговую руку?

- taskId: cards_ranks_suits_recap
  status: landed_or_partial
  title_en: Cards recap
  summary_en: Prove you can separate rank, suit, board, and best-five ideas cleanly.
  phase: review
  stepKind: proveIt
  runner: _cardsRecapRunner
  runnerPrompt_en: Lesson learned: cards have a job.
  runnerSupport_en: Ranks compare strength, suits make flushes, board cards are shared.
  runnerQuestion_en: What do board cards mean?
  title_ru: Повтор по картам
  summary_ru: Докажи, что уверенно разделяешь ранг, масть, борд и идею лучших пяти карт.
  runnerPrompt_ru: У каждой карты есть своя работа в раздаче.
  runnerSupport_ru: Ранги сравнивают силу, масти собирают флеши, а борд даёт общие карты.
  runnerQuestion_ru: Что означают карты борда?

## lesson your_first_hand
status: landed_or_partial
title_en: Your first hand, dealt
subtitle_en: Watch a hand from start to showdown.
title_ru: Твоя первая раздача
subtitle_ru: Проследи раздачу от старта до шоудауна.

- taskId: your_first_hand_preflop
  status: landed_or_partial
  title_en: Preflop
  phase: theory
  stepKind: learn
  runner: _firstHandRunner
  runnerPrompt_en: Your two cards stay with you through the hand.
  runnerSupport_en: Board cards arrive later.
  runnerQuestion_en: How many private cards do you start with?
  title_ru: Префлоп
  runnerPrompt_ru: Твои две карты остаются с тобой всю раздачу.
  runnerSupport_ru: Карты борда появятся позже. Сначала у тебя только две карманные.
  runnerQuestion_ru: Сколько карманных карт ты получаешь на старте?

- taskId: your_first_hand_flop
  status: landed_or_partial
  title_en: Flop
  phase: drill
  stepKind: practice
  runner: _readBoardRunner
  runnerPrompt_en: The flop puts three shared cards in the middle.
  runnerSupport_en: Everyone can use the board.
  runnerQuestion_en: How many cards are on this flop?
  title_ru: Флоп
  runnerPrompt_ru: Флоп кладёт в центр три общие карты.
  runnerSupport_ru: Эти карты уже могут использовать все, кто остался в раздаче.
  runnerQuestion_ru: Сколько карт лежит на этом флопе?

- taskId: your_first_hand_turn
  status: landed_or_partial
  title_en: Turn card
  phase: drill
  stepKind: practice
  runner: _turnBoardRunner
  runnerPrompt_en: The turn is the fourth board card.
  runnerSupport_en: Flop has three cards. Turn makes four.
  runnerQuestion_en: How many board cards are visible on the turn?
  title_ru: Тёрн
  runnerPrompt_ru: Тёрн — это четвёртая карта борда.
  runnerSupport_ru: После флопа из трёх карт тёрн делает борд из четырёх.
  runnerQuestion_ru: Сколько карт борда видно на тёрне?

- taskId: your_first_hand_river
  status: landed_or_partial
  title_en: River card
  phase: drill
  stepKind: practice
  runner: _riverBoardRunner
  runnerPrompt_en: The river is the fifth board card.
  runnerSupport_en: Now the shared board is complete.
  runnerQuestion_en: How many board cards are visible on the river?
  title_ru: Ривер
  runnerPrompt_ru: Ривер закрывает борд пятой общей картой.
  runnerSupport_ru: После ривера общий борд уже полностью собран.
  runnerQuestion_ru: Сколько карт борда видно на ривере?

- taskId: your_first_hand_showdown
  status: landed_or_partial
  title_en: Showdown read
  phase: review
  stepKind: review
  runner: _showdownBestHandRunner
  runnerPrompt_en: At showdown, the best hand wins the pot.
  runnerSupport_en: Compare the final five-card hand.
  runnerQuestion_en: What decides a showdown?
  title_ru: Чтение шоудауна
  runnerPrompt_ru: На шоудауне банк забирает лучшая рука.
  runnerSupport_ru: Сравнивай итоговую лучшую пятёрку, а не случайные отдельные карты.
  runnerQuestion_ru: Что решает шоудаун?

- taskId: your_first_hand_action_trail
  status: landed_or_partial
  title_en: Action trail
  phase: drill
  stepKind: practice
  runner: _actionTrailRunner
  runnerPrompt_en: The action trail records what happened street by street.
  runnerSupport_en: Read it left to right.
  runnerQuestion_en: Which trail item happened last?
  title_ru: Цепочка действий
  runnerPrompt_ru: Лента действий показывает, что случилось по улицам.
  runnerSupport_ru: Читай её слева направо как короткую историю раздачи.
  runnerQuestion_ru: Какой элемент в ленте произошёл последним?

- taskId: your_first_hand_recap
  status: landed_or_partial
  title_en: Street recap
  phase: review
  stepKind: proveIt
  runner: _streetOrderRecapRunner
  runnerPrompt_en: Lesson learned: streets tell time.
  runnerSupport_en: Preflop has no board, then flop 3, turn 4, river 5.
  runnerQuestion_en: Which street comes after the turn?
  title_ru: Повтор по улицам
  runnerPrompt_ru: Улицы держат порядок времени в раздаче.
  runnerSupport_ru: Сначала идёт префлоп без борда, потом флоп, тёрн и ривер.
  runnerQuestion_ru: Какая улица идёт после тёрна?

## lesson fold_check_call_raise
status: landed_or_partial
title_en: Fold, check, call, raise
subtitle_en: Name each action before the table asks you.
title_ru: Фолд, чек, колл, рейз
subtitle_ru: Научись называть каждое действие до решения.

- taskId: actions_theory
  status: landed_or_partial
  title_en: Action words
  summary_en: Lock in the four core verbs first: fold, check, call, raise.
  phase: theory
  stepKind: learn
  runner: _actionWordsRunner
  runnerPrompt_en: Four action words matter first: fold, check, call, raise.
  runnerSupport_en: The table state tells which actions are legal.
  runnerQuestion_en: Which action adds more chips first in?
  title_ru: Слова действий
  summary_ru: Сначала закрепи четыре главных глагола: фолд, чек, колл и рейз.
  runnerPrompt_ru: Сначала назови действие, потом принимай решение.
  runnerSupport_ru: Держись простого каркаса: фолд уходит, чек не добавляет фишек, колл уравнивает, рейз повышает цену.
  runnerQuestion_ru: 

- taskId: actions_legal_context
  status: landed_or_partial
  title_en: Legal actions
  summary_en: Match the table state to the actions that are actually allowed.
  lockedSummary_en: Open Action words first, then this node starts making sense.
  phase: drill
  stepKind: practice
  runner: _legalActionRunner
  runnerPrompt_en: Legal actions depend on whether a bet is facing you.
  runnerSupport_en: No bet means check is available; facing a bet means call or fold.
  runnerQuestion_en: No bet faces you. Which action is legal and free?
  title_ru: Разрешённые действия
  summary_ru: Свяжи состояние стола с теми действиями, которые здесь действительно разрешены.
  lockedSummary_ru: Сначала открой Слова действий, потом этот узел начнёт читаться правильно.
  runnerPrompt_ru: Смотри на ставку на столе и убери невозможные действия.
  runnerSupport_ru: Сначала прочитай состояние стола, потом оставь только те действия, которые здесь вообще доступны.
  runnerQuestion_ru: 

- taskId: actions_check_drill
  status: landed_or_partial
  title_en: Check when no bet
  summary_en: Recognize the one moment checking is free and correct.
  lockedSummary_en: Clear Action words first, then unlock the no-bet read.
  phase: drill
  stepKind: practice
  runner: _checkActionRunner
  runnerPrompt_en: No one has bet on this street.
  runnerSupport_en: Checking keeps your hand without adding chips.
  runnerQuestion_en: What action keeps playing for free?
  title_ru: Чек без ставки
  summary_ru: Распознай единственный момент, когда чек бесплатен и действительно правильный.
  lockedSummary_ru: Сначала закрой Слова действий, потом откроется чтение спота без ставки.
  runnerPrompt_ru: Если ставки нет, проверь, открыт ли бесплатный чек.
  runnerSupport_ru: Чек существует только тогда, когда до тебя никто не поставил. Ищи именно это условие.
  runnerQuestion_ru: 

- taskId: actions_fold_drill
  status: landed_or_partial
  title_en: Fold weak hands
  summary_en: Train the clean exit when continuing would only burn chips.
  lockedSummary_en: Finish the opener first, then come back to this repair node.
  phase: drill
  stepKind: fixMistakes
  runner: _foldActionRunner
  runnerPrompt_en: HJ bets and your hand is weak.
  runnerSupport_en: Folding saves chips when continuing is not worth it.
  runnerQuestion_en: Which action gives up the hand?
  title_ru: Фолд слабых рук
  summary_ru: Натренируй чистый выход из спота, где продолжение только сожжёт фишки.
  lockedSummary_ru: Сначала пройди вступление, потом вернись к этому ремонтному узлу.
  runnerPrompt_ru: Слабая рука без цены не обязана продолжать.
  runnerSupport_ru: Фолд сохраняет стек, когда продолжение не даёт внятной причины вкладывать фишки дальше.
  runnerQuestion_ru: 

- taskId: actions_call_drill
  status: landed_or_partial
  title_en: Call a price
  summary_en: Read when matching the bet is the cheapest correct continue.
  lockedSummary_en: This opens after Action words, once the basic verbs are stable.
  phase: drill
  stepKind: practice
  runner: _callActionRunner
  runnerPrompt_en: You face a small bet and want the cheapest continue.
  runnerSupport_en: Call means match the bet.
  runnerQuestion_en: Which action matches the 1 BB price?
  title_ru: Колл по цене
  summary_ru: Пойми, когда колл по цене остаётся самым дешёвым и верным продолжением.
  lockedSummary_ru: Этот шаг откроется после Слов действий, когда базовые глаголы станут устойчивыми.
  runnerPrompt_ru: Когда цена разумная, колл просто держит раздачу в игре.
  runnerSupport_ru: Колл не выигрывает раздачу сразу, но часто остаётся самым спокойным и дешёвым продолжением.
  runnerQuestion_ru: 

- taskId: actions_raise_drill
  status: landed_or_partial
  title_en: Open on the Button
  summary_en: Use raise in the cleanest beginner spot: unopened action on the Button.
  lockedSummary_en: First learn the action menu, then unlock the aggressive option.
  phase: drill
  stepKind: practice
  runner: _whatYouCanDoRunner
  runnerPrompt_en: You are on the Button with KTs.
  runnerSupport_en: Folded to you. Opening can win blinds or build a pot.
  runnerQuestion_en: Choose how to play your first action.
  title_ru: Открытие на баттоне
  summary_ru: Используй рейз в самом чистом споте для новичка: все выбросили, а ты на баттоне.
  lockedSummary_ru: Сначала выучи меню действий, потом открывай агрессивный вариант.
  runnerPrompt_ru: Когда все выбросили до тебя на баттоне, рейз забирает инициативу.
  runnerSupport_ru: Рейз открывает раздачу давлением. На баттоне без предыдущей ставки это самый чистый учебный пример.
  runnerQuestion_ru: 

- taskId: actions_review
  status: landed_or_partial
  title_en: Action recap
  summary_en: Prove you can name the right action without prompts.
  lockedSummary_en: The recap opens after the action drills are clean.
  phase: review
  stepKind: proveIt
  runner: _actionRecapRunner
  runnerPrompt_en: Lesson learned: action words depend on price.
  runnerSupport_en: No bet allows check. Facing a bet creates fold, call, or raise.
  runnerQuestion_en: First in on the Button. What is cleaner than limping?
  title_ru: Повтор по действиям
  summary_ru: Докажи, что можешь называть правильное действие без подсказок.
  lockedSummary_ru: Повтор откроется после того, как дриллы по действиям будут закрыты чисто.
  runnerPrompt_ru: Назови действие быстро и без лишних догадок.
  runnerSupport_ru: Собери всё вместе: прочитай стол, отсеки невозможное и назови лучшее действие.
  runnerQuestion_ru: 

## lesson blinds_action_order
status: landed_or_partial
title_en: Blinds & action order
subtitle_en: Why someone always puts money in first.
title_ru: Блайнды и порядок действий
subtitle_ru: Почему кто-то всегда кладёт фишки первым.

- taskId: blinds_theory
  status: landed_or_partial
  title_en: Blinds post first
  phase: theory
  stepKind: learn
  runner: _blindsOrderRunner
  runnerPrompt_en: SB and BB post before cards are played.
  runnerSupport_en: The first decision comes after the big blind.
  runnerQuestion_en: Which blind posts 1 BB?
  title_ru: Блайнды ставятся первыми
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: blinds_posts_drill
  status: landed_or_partial
  title_en: Who posts 1 BB
  phase: drill
  stepKind: practice
  runner: _bigBlindPostRunner
  runnerPrompt_en: BB posts the full 1 BB blind.
  runnerSupport_en: SB posts the smaller 0.5 BB blind.
  runnerQuestion_en: Tap the big blind.
  title_ru: Кто ставит 1 BB
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: blinds_first_actor
  status: landed_or_partial
  title_en: First preflop actor
  phase: drill
  stepKind: practice
  runner: _firstPreflopActorRunner
  runnerPrompt_en: Preflop starts left of the big blind.
  runnerSupport_en: Tap the first preflop actor.
  runnerQuestion_en: Tap UTG.
  title_ru: Первый на префлопе
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: blinds_last_actor
  status: landed_or_partial
  title_en: Last preflop actor
  phase: drill
  stepKind: practice
  runner: _lastPreflopActorRunner
  runnerPrompt_en: The big blind closes preflop when nobody raises.
  runnerSupport_en: Tap the last preflop actor.
  runnerQuestion_en: Tap BB.
  title_ru: Последний на префлопе
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: blinds_postflop_button
  status: landed_or_partial
  title_en: Last postflop actor
  phase: drill
  stepKind: practice
  runner: _postflopButtonActorRunner
  runnerPrompt_en: After the flop, Button often acts last.
  runnerSupport_en: Tap BTN.
  runnerQuestion_en: Tap the last postflop actor.
  title_ru: Последний на постфлопе
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: blinds_button_moves
  status: landed_or_partial
  title_en: Button moves
  phase: drill
  stepKind: practice
  runner: _buttonMovesRunner
  runnerPrompt_en: The Button moves one seat after each hand.
  runnerSupport_en: That keeps blinds and late position rotating.
  runnerQuestion_en: Which marker shows the dealer button this hand?
  title_ru: Баттон двигается
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

- taskId: blinds_review
  status: landed_or_partial
  title_en: Order recap
  phase: review
  stepKind: proveIt
  runner: _blindsOrderRecapRunner
  runnerPrompt_en: Lesson learned: blinds start the order.
  runnerSupport_en: SB posts 0.5, BB posts 1, then action begins around the table.
  runnerQuestion_en: Who acts first preflop?
  title_ru: Повтор по порядку
  runnerPrompt_ru: 
  runnerSupport_ru: 
  runnerQuestion_ru: 

## lesson positions
status: landed_or_partial
title_en: The 6 positions
subtitle_en: Each seat has a name and a job.
title_ru: 6 позиций за столом
subtitle_ru: У каждого места за столом есть имя и роль.

- taskId: positions_theory
  status: landed_or_partial
  title_en: Six seats
  phase: theory
  stepKind: learn
  runner: _positionsRunner
  runnerPrompt_en: The six seats are UTG, HJ, CO, BTN, SB, and BB.
  runnerSupport_en: Button acts last after the flop.
  runnerQuestion_en: Which seat is the Button?
  title_ru: Шесть мест за столом
  runnerPrompt_ru: У каждого места за столом своё имя: UTG, HJ, CO, BTN, SB и BB.
  runnerSupport_ru: Эти названия нужны не для красоты. Они сразу подсказывают, когда и с каким объёмом информации ты действуешь.
  runnerQuestion_ru: Какое место здесь называется баттоном?

- taskId: positions_button
  status: landed_or_partial
  title_en: Tap the Button
  phase: drill
  stepKind: practice
  runner: _buttonSeatRunner
  runnerPrompt_en: Button is the dealer seat in this hand.
  runnerSupport_en: Tap BTN.
  runnerQuestion_en: Tap the Button.
  title_ru: Найди баттон
  runnerPrompt_ru: Баттон показывает позицию дилера в этой раздаче.
  runnerSupport_ru: Ищи метку BTN. Это самое удобное место для старта знакомства с позициями.
  runnerQuestion_ru: Где здесь баттон?

- taskId: positions_utg
  status: landed_or_partial
  title_en: Tap UTG
  phase: drill
  stepKind: practice
  runner: _utgSeatRunner
  runnerPrompt_en: UTG is the earliest preflop seat.
  runnerSupport_en: Tap UTG.
  runnerQuestion_en: Tap UTG.
  title_ru: Найди UTG
  runnerPrompt_ru: UTG открывает префлоп раньше всех.
  runnerSupport_ru: Это ранняя позиция. Здесь действуют с наименьшим количеством информации.
  runnerQuestion_ru: Какое место здесь называется UTG?

- taskId: positions_cutoff
  status: landed_or_partial
  title_en: Tap the cutoff
  phase: drill
  stepKind: practice
  runner: _cutoffSeatRunner
  runnerPrompt_en: CO means cutoff. It is one seat before the Button.
  runnerSupport_en: Tap CO.
  runnerQuestion_en: Tap the cutoff.
  title_ru: Найди cutoff
  runnerPrompt_ru: Cutoff сидит прямо перед баттоном.
  runnerSupport_ru: Ищи метку CO. Это уже поздняя позиция, но ещё не самый конец очереди.
  runnerQuestion_ru: Где здесь cutoff?

- taskId: positions_late_seat
  status: landed_or_partial
  title_en: Late seat meaning
  phase: drill
  stepKind: practice
  runner: _latePositionRunner
  runnerPrompt_en: Late seats see more actions before deciding.
  runnerSupport_en: Button is the clearest late seat.
  runnerQuestion_en: Which seat acts latest after the flop?
  title_ru: Что даёт поздняя позиция
  runnerPrompt_ru: Поздняя позиция позволяет сначала посмотреть на чужие действия.
  runnerSupport_ru: Чем позже ты решаешь, тем больше подсказок успеваешь собрать до своего хода.
  runnerQuestion_ru: Какое место чаще всего действует позже остальных после флопа?

- taskId: positions_early_late
  status: landed_or_partial
  title_en: Early vs late
  phase: drill
  stepKind: practice
  runner: _earlyLatePositionRunner
  runnerPrompt_en: Early seats act with less information than late seats.
  runnerSupport_en: UTG is early. BTN is late.
  runnerQuestion_en: Which seat is early preflop?
  title_ru: Ранние и поздние места
  runnerPrompt_ru: Ранние места решают вслепую чаще, поздние видят больше.
  runnerSupport_ru: UTG действует почти сразу, а баттон обычно получает самую полную картину перед решением.
  runnerQuestion_ru: Какое место здесь раннее на префлопе?

- taskId: positions_review
  status: landed_or_partial
  title_en: Position recap
  phase: review
  stepKind: proveIt
  runner: _positionsRecapRunner
  runnerPrompt_en: Lesson learned: position changes information.
  runnerSupport_en: Early seats decide sooner. Late seats see more before acting.
  runnerQuestion_en: Which seat is latest after the flop here?
  title_ru: Повтор по позициям
  runnerPrompt_ru: Главная мысль проста: позиция меняет не силу карты, а удобство решения.
  runnerSupport_ru: Ранние места требуют большей аккуратности, поздние дают больше информации и свободы.
  runnerQuestion_ru: Какое место здесь действует позже остальных после флопа?

## lesson hand_rankings_table
status: landed_or_partial
title_en: Hand rankings, on the table
subtitle_en: What beats what with real boards.
title_ru: Старшинство рук на борде
subtitle_ru: Что бьёт что на реальных бордах.

- taskId: hand_rankings_theory
  status: landed_or_partial
  title_en: Hands use five cards
  phase: theory
  stepKind: learn
  runner: _handRankingIntroRunner
  runnerPrompt_en: Hand rank names describe made hands.
  runnerSupport_en: Start with the ladder: pair, two pair, trips, straight, flush.
  runnerQuestion_en: What do hand rankings compare?
  title_ru: Руки сравнивают по силе
  runnerPrompt_ru: Названия рук нужны затем, чтобы быстро понять, что старше на шоудауне.
  runnerSupport_ru: На старте держи в голове короткую лестницу: пара, две пары, сет, стрит, флеш.
  runnerQuestion_ru: Что именно сравнивают старшинства рук?

- taskId: hand_rankings_pair_drill
  status: landed_or_partial
  title_en: Find the pair
  phase: drill
  stepKind: practice
  runner: _handRankingsRunner
  runnerPrompt_en: Hands are compared by their best five cards.
  runnerSupport_en: A pair beats one high card.
  runnerQuestion_en: What does hero have here?
  title_ru: Найди пару
  runnerPrompt_ru: Пара уже сильнее просто старшей карты.
  runnerSupport_ru: Ищи два совпадающих ранга. Это первый устойчивый made hand в базовой лестнице.
  runnerQuestion_ru: Что собрал Hero в этом примере?

- taskId: hand_rankings_two_pair_drill
  status: landed_or_partial
  title_en: Two pair vs one pair
  phase: drill
  stepKind: practice
  runner: _twoPairRunner
  runnerPrompt_en: Two pair beats one pair.
  runnerSupport_en: Count matching ranks on the board and in hand.
  runnerQuestion_en: Which hand is stronger?
  title_ru: Две пары против одной
  runnerPrompt_ru: Две пары уже старше одной пары.
  runnerSupport_ru: Сначала посмотри, сколько совпадений по рангам получилось у каждой руки, и только потом сравнивай их силу.
  runnerQuestion_ru: Какая рука здесь старше?

- taskId: hand_rankings_trips_drill
  status: landed_or_partial
  title_en: Trips or set
  phase: drill
  stepKind: practice
  runner: _tripsRankRunner
  runnerPrompt_en: Trips and sets are three cards of one rank.
  runnerSupport_en: Three of a kind beats two pair.
  runnerQuestion_en: Which hand ranks higher?
  title_ru: Сет или трипс
  runnerPrompt_ru: Три карты одного ранга уже поднимают руку выше двух пар.
  runnerSupport_ru: Не цепляйся за название. Важно увидеть саму структуру: три одинаковых ранга.
  runnerQuestion_ru: Что здесь сильнее двух пар?

- taskId: hand_rankings_straight_drill
  status: landed_or_partial
  title_en: Find the straight
  phase: drill
  stepKind: practice
  runner: _straightRankRunner
  runnerPrompt_en: A straight is five ranks in a row.
  runnerSupport_en: Example: 5, 6, 7, 8, 9.
  runnerQuestion_en: What makes a straight?
  title_ru: Найди стрит
  runnerPrompt_ru: Стрит — это пять рангов подряд.
  runnerSupport_ru: Смотри не на масти, а на последовательность: пять, шесть, семь, восемь, девять и так далее.
  runnerQuestion_ru: Из чего складывается стрит?

- taskId: hand_rankings_flush_drill
  status: landed_or_partial
  title_en: Flush beats straight
  phase: drill
  stepKind: practice
  runner: _flushRankRunner
  runnerPrompt_en: A flush uses five cards of one suit.
  runnerSupport_en: Flush beats straight in Holdem.
  runnerQuestion_en: Which hand ranks higher?
  title_ru: Флеш сильнее стрита
  runnerPrompt_ru: Флеш собирается из пяти карт одной масти.
  runnerSupport_ru: Если перед тобой флеш и стрит, побеждает флеш. Это стоит закрепить отдельно.
  runnerQuestion_ru: Какая рука здесь старше: флеш или стрит?

- taskId: hand_rankings_best_five_drill
  status: landed_or_partial
  title_en: Choose best five
  phase: drill
  stepKind: practice
  runner: _bestFiveShowdownRunner
  runnerPrompt_en: At showdown, compare each player best five cards.
  runnerSupport_en: Unused extra cards do not count.
  runnerQuestion_en: How many cards count at showdown?
  title_ru: Выбери лучшие пять
  runnerPrompt_ru: На вскрытии всегда сравнивают не все карты подряд, а лучшие пять.
  runnerSupport_ru: Лишние карты не считаются. Важно собрать самую сильную пятёрку из карманных и борда.
  runnerQuestion_ru: Сколько карт реально считаются на шоудауне?

- taskId: hand_rankings_review
  status: landed_or_partial
  title_en: Ranking recap
  phase: review
  stepKind: proveIt
  runner: _rankingRecapRunner
  runnerPrompt_en: Lesson learned: compare the best five.
  runnerSupport_en: Pair, two pair, trips, straight, and flush are the first ladder.
  runnerQuestion_en: Which ranks higher: flush or straight?
  title_ru: Повтор по старшинству
  runnerPrompt_ru: На вскрытии побеждает та рука, чьи лучшие пять старше.
  runnerSupport_ru: Пара, две пары, сет, стрит и флеш должны читаться уже без суеты.
  runnerQuestion_ru: Что здесь старше: флеш или стрит?

## lesson showdown_winning
status: landed_or_partial
title_en: Showdown & winning
subtitle_en: How a hand actually ends.
title_ru: Шоудаун и победа
subtitle_ru: Как раздача действительно заканчивается.

- taskId: showdown_theory
  status: landed_or_partial
  title_en: Two ways to win
  phase: theory
  stepKind: learn
  runner: _showdownIntroRunner
  runnerPrompt_en: A hand can end before or at showdown.
  runnerSupport_en: Folds end it early. Showdown compares hands.
  runnerQuestion_en: What are the two broad ways to win?
  title_ru: Два пути к банку
  runnerPrompt_ru: Раздача заканчивается либо пасами соперников, либо сравнением рук на шоудауне.
  runnerSupport_ru: Если все выбросили, вскрытия не будет. Если дошли до конца, сравнивают лучшие пять карт.
  runnerQuestion_ru: Какие два главных пути есть к победе в раздаче?

- taskId: showdown_foldout_drill
  status: landed_or_partial
  title_en: Everyone folds
  phase: drill
  stepKind: practice
  runner: _showdownRunner
  runnerPrompt_en: A hand can end by folds or by showdown.
  runnerSupport_en: If everyone folds, the last player wins now.
  runnerQuestion_en: What happens if everyone folds to you?
  title_ru: Все выбросили
  runnerPrompt_ru: Если все соперники выбросили, банк твой сразу.
  runnerSupport_ru: Здесь не нужно ждать вскрытия. Последний оставшийся игрок просто забирает банк.
  runnerQuestion_ru: Что происходит, если все выбросили до тебя?

- taskId: showdown_best_hand_drill
  status: landed_or_partial
  title_en: Best hand at showdown
  phase: drill
  stepKind: practice
  runner: _showdownBestHandRunner
  runnerPrompt_en: At showdown, the best hand wins the pot.
  runnerSupport_en: Compare the final five-card hand.
  runnerQuestion_en: What decides a showdown?
  title_ru: Лучшая рука на вскрытии
  runnerPrompt_ru: На шоудауне побеждает не красивая, а старшая рука.
  runnerSupport_ru: Сравнивай лучшие пять карт у каждого игрока и не отвлекайся на лишние детали.
  runnerQuestion_ru: Что решает исход шоудауна?

- taskId: showdown_kicker_drill
  status: landed_or_partial
  title_en: Same pair, better kicker
  phase: drill
  stepKind: practice
  runner: _showdownKickerRunner
  runnerPrompt_en: If both players share a pair, the side card can matter.
  runnerSupport_en: That side card is called a kicker.
  runnerQuestion_en: Same pair. What can break the tie?
  title_ru: Та же пара, лучший кикер
  runnerPrompt_ru: Если основная пара у обоих одна и та же, решает боковая карта.
  runnerSupport_ru: Эта боковая карта называется кикером. Она часто ломает кажущуюся ничью.
  runnerQuestion_ru: Что может разбить ничью при одинаковой паре?

- taskId: showdown_board_plays_drill
  status: landed_or_partial
  title_en: Board plays
  phase: drill
  stepKind: fixMistakes
  runner: _boardPlaysRunner
  runnerPrompt_en: Sometimes the best five cards are all on the board.
  runnerSupport_en: Then both players may play the board.
  runnerQuestion_en: If both players use the same board, what can happen?
  title_ru: Играет борд
  runnerPrompt_ru: Иногда лучшая пятёрка уже целиком лежит на борде, без помощи карманных карт.
  runnerSupport_ru: Если оба игрока используют одну и ту же пятёрку с борда, никто не получает преимущества.
  runnerQuestion_ru: Что может случиться, если у обоих играет один и тот же борд?

- taskId: showdown_tie_drill
  status: landed_or_partial
  title_en: Tie the pot
  phase: drill
  stepKind: practice
  runner: _tiePotRunner
  runnerPrompt_en: A tie means the pot is split.
  runnerSupport_en: This can happen when the same best five cards play.
  runnerQuestion_en: What happens to the pot on a tie?
  title_ru: Разделить банк
  runnerPrompt_ru: Ничья на шоудауне значит, что банк делят.
  runnerSupport_ru: Так бывает, когда лучшие пять карт у обоих игроков полностью совпадают.
  runnerQuestion_ru: Что происходит с банком при ничьей?

- taskId: showdown_review
  status: landed_or_partial
  title_en: Win recap
  phase: review
  stepKind: proveIt
  runner: _worldOneCheckpointRunner
  runnerPrompt_en: Lesson learned: now you can follow a hand.
  runnerSupport_en: Next, you will sort starting hands into buckets before deciding to continue.
  runnerQuestion_en: What wins at showdown?
  title_ru: Повтор по победе
  runnerPrompt_ru: Теперь ты уже видишь оба финала раздачи: все выбросили или лучшая рука дошла до вскрытия.
  runnerSupport_ru: Это завершает первый круг чтения раздачи: стол, улицы, старшинство рук и способы забрать банк.
  runnerQuestion_ru: Что выигрывает на шоудауне?

