# world_1 RU Translation Pack

Status: GENERATED
World number: 1
EN title: Poker from Zero
EN subtitle: Table literacy: cards, seats, blinds, stack, and pot.
title_ru: Покер с нуля
subtitle_ru: Грамотность за столом: карты, места, блайнды, стек и банк.

## Coverage
- Lessons: 8/9
- Tasks: 57/60
- Runner prompts: 50/60
- Runner supports: 50/60
- Runner questions: 43/60
- Teaching step titles: 6/71
- Teaching step bodies: 6/71

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
title_en: First Table Guide
subtitle_en: Learn the table, answer once, and see why.
title_ru: Что такое покер
subtitle_ru: Познакомься со столом, игроками и целью раздачи.

- taskId: what_poker_is_theory
  status: landed_or_partial
  title_en: Meet the table
  summary_en: Start with one calm read: hero, blinds, table, and the Sharky loop.
  phase: theory
  stepKind: learn
  runner: _firstTableGuideMeetTableRunner
  runnerPrompt_en: You are always the hero seat at the bottom.
  runnerSupport_en: Button, blinds, and your seat stay visible.
  runnerQuestion_en: Which seat is the hero seat?
  teachingStep0_title_en: One loop first.
  teachingStep0_body_en: Sharky teaches one spot at a time: read the table, answer once, then get one clear why.
  teachingStep0_title_ru: Начинаем с кэш-игры в холдем.
  teachingStep0_body_ru: У каждого игрока 2 закрытые карты. На стол выходят 5 общих карт. Лучшая рука собирается из любых пяти карт из этих семи. Мы начинаем с кэш-игры, где ценность фишек не меняется.
  teachingStep1_title_en: Start with the table.
  teachingStep1_body_en: Hero is you, blinds start the pot, and the table stays readable before the route speeds up.
  teachingStep1_title_ru: Перед тобой покерный стол.
  teachingStep1_body_ru: Ты играешь за нижнее место. Остальные места за столом — соперники.
  title_ru: Знакомство со столом
  summary_ru: Разберись в базовой картине: места, фишки, карты и то, что стол пытается определить.
  runnerPrompt_ru: Твоё место всегда внизу. С него и начинай чтение стола.
  runnerSupport_ru: Сначала найди своё место, блайнды и баттон. Эти ориентиры держат всю раздачу понятной.
  runnerQuestion_ru: Где находится твоё место?

- taskId: what_poker_is_find_hero
  status: landed_or_partial
  title_en: Find your seat
  summary_en: Spot where Hero sits before anything else starts moving.
  phase: drill
  stepKind: practice
  runner: _firstTableGuideFindHeroRunner
  runnerPrompt_en: Your seat is marked as Hero.
  runnerSupport_en: Start every hand by finding your own cards and seat.
  runnerQuestion_en: Which seat is the hero seat?
  teachingStep0_title_en: Hero means you.
  teachingStep0_body_en: Your decisions happen from the seat marked Hero.
  teachingStep0_title_ru: Hero — это ты.
  teachingStep0_body_ru: Все твои решения идут из места с меткой Hero. Сначала найди его, и только потом смотри на остальной стол.
  title_ru: Найди своё место
  summary_ru: Сначала научись видеть, где сидишь ты, и только потом отслеживай остальное.
  runnerPrompt_ru: Сначала найди своё место, а уже потом смотри на остальной стол.
  runnerSupport_ru: Привычка простая: сперва свои карты и своё место, потом всё остальное.
  runnerQuestion_ru: Какое место принадлежит тебе?

- taskId: what_poker_is_table_read_transfer
  status: landed_or_partial
  title_en: Read the table
  summary_en: Read one live-looking spot: your cards, the board, and the pot.
  phase: drill
  stepKind: practice
  runner: _firstTableGuideReadTableRunner
  runnerPrompt_en: Real table. Hero has two cards, flop has three board cards, pot is 6 BB.
  runnerSupport_en: Separate private cards, board cards, and pot before any action.
  runnerQuestion_en: What is the clean first table read?
  teachingStep0_title_en: Carry the first table scan.
  teachingStep0_body_en: Real tables still start with the same simple scan: your two cards, the shared board, and how many chips sit in the pot.
  teachingStep0_title_ru: Перенеси первое чтение на живой стол.
  teachingStep0_body_ru: Даже на живом столе порядок тот же: сначала твои две карты, потом общий борд, потом размер банка.
  title_ru: Первое чтение живого стола
  summary_ru: Перенеси первое чтение стола в живую раздачу: сначала свои карты, потом борд, потом банк.
  runnerPrompt_ru: Сначала посмотри на свои карты, потом на борд, потом на банк.
  runnerSupport_ru: Этот порядок не даёт расплыться вниманию: свои карты, общие карты, потом размер банка.
  runnerQuestion_ru: С чего лучше начать быстрое чтение стола?

- taskId: first_table_guide_one_clear_choice
  status: missing
  title_en: Make one choice
  summary_en: Answer once in one clean beginner spot, then let Sharky show the reason.
  phase: drill
  stepKind: practice
  runner: _firstTableGuideActionRunner
  runnerPrompt_en: One clear beginner choice is enough for the first Sharky loop.
  runnerSupport_en: Read the spot, choose once, then let the reason land.
  runnerQuestion_en: Choose how to play your first action.
  teachingStep0_title_en: One answer is enough.
  teachingStep0_body_en: Sharky is not asking for a long explanation. Read the spot, choose once, then compare the reason.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  summary_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: first_table_guide_route_roles
  status: missing
  title_en: Where to go next
  summary_en: Lock in what Home, Learn, Practice, Review, and You do after the first loop.
  phase: review
  stepKind: proveIt
  runner: _firstTableGuideRouteRunner
  runnerPrompt_en: After the first loop, each surface has one clear job.
  runnerSupport_en: Use Review to fix misses. The rest of the tabs support the route.
  runnerQuestion_en: Where do you go to fix mistakes after a miss?
  teachingStep0_title_en: Know the five jobs.
  teachingStep0_body_en: Home shows what to do now. Learn keeps the route visible. Practice gives extra reps. Review fixes mistakes. You shows progress and settings.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  summary_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

## lesson what_poker_is_content
status: missing
title_en: What poker is
subtitle_en: How the pot, folds, and showdown decide the hand.
title_ru:
subtitle_ru:

- taskId: what_poker_is_pot_stack
  status: landed_or_partial
  title_en: Pot and stack
  summary_en: Separate chips in the middle from chips that still belong to a player.
  phase: theory
  stepKind: learn
  runner: _potStackRunner
  runnerPrompt_en: Texas Hold'em gives you 2 private cards, up to 5 community cards, and one pot to win.
  runnerSupport_en: Best 5 wins at showdown. Folds can win the pot earlier.
  runnerQuestion_en: Which label shows the chips in the middle?
  teachingStep0_title_en: Texas Hold'em first.
  teachingStep0_body_en: You start with 2 private cards. The table can share up to 5 community cards. At showdown, the best 5-card hand wins.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  teachingStep1_title_en: Cash-style fundamentals first.
  teachingStep1_body_en: Sharky starts with cash-style fundamentals because cards, position, pot, action, and reason stay stable hand to hand. Tournament pressure comes later.
  teachingStep1_title_ru:
  teachingStep1_body_ru:
  teachingStep2_title_en: Pot and stack are different.
  teachingStep2_body_en: The pot is in the middle. Your stack stays with your seat.
  teachingStep2_title_ru:
  teachingStep2_body_ru:
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
  runnerQuestion_en: Which is a way to win the pot before showdown?
  teachingStep0_title_en: A pot can end two ways.
  teachingStep0_body_en: Everyone else folds, or players compare hands at showdown.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
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
  teachingStep0_title_en: Showdown compares hands.
  teachingStep0_body_en: When players remain, reveal cards and compare best hands.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru: Победа на шоудауне
  summary_ru: Определи, какая рука выигрывает, когда все карты уже открыты.
  runnerPrompt_ru: На шоудауне банк уходит лучшей руке.
  runnerSupport_ru: Сравнивай не отдельные карты, а итоговые лучшие пять.
  runnerQuestion_ru: Что решает исход шоудауна?

- taskId: what_poker_is_live_win_transfer
  status: missing
  title_en: Live win paths
  summary_en: Carry folds and showdown into one live table frame before strategy starts.
  phase: drill
  stepKind: practice
  runner: _w1LiveWinTransferRunner
  runnerPrompt_en: Real table. Hero is BTN, blinds are posted, and the pot starts at 1.5 BB.
  runnerSupport_en: After the first read, remember how this pot can still finish.
  runnerQuestion_en: In this live hand, what can still decide the pot?
  teachingStep0_title_en: Live table, same endings.
  teachingStep0_body_en: Even in a live-looking hand, the pot still ends one of two ways: everyone folds or players reach showdown.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru:
  summary_ru:
  runnerPrompt_ru:
  runnerSupport_ru:
  runnerQuestion_ru:

- taskId: what_poker_is_review
  status: landed_or_partial
  title_en: Poker recap
  summary_en: Close the lesson by separating hero, pot, folds, and showdown cleanly.
  phase: review
  stepKind: proveIt
  runner: _tableRecapRunner
  runnerPrompt_en: Lesson learned: read the table before choosing.
  runnerSupport_en: Hero is you, opponents fight you, blinds create the first pot.
  runnerQuestion_en: What is the pot?
  teachingStep0_title_en: Table checklist.
  teachingStep0_body_en: Find hero, opponents, blinds, and pot before any decision.
  teachingStep0_title_ru:
  teachingStep0_body_ru:
  title_ru: Повтор по столу
  summary_ru: Пройди чтение стола целиком и чисто: место, банк и финал раздачи.
  runnerPrompt_ru: Сначала прочитай стол, потом уже думай о решении.
  runnerSupport_ru: Ты играешь из нижнего места, блайнды запускают первый банк, а стол подсказывает, что происходит.
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
  teachingStep0_title_en: Deck first.
  teachingStep0_body_en: Holdem uses a 52-card deck: 13 ranks across 4 suits.
  teachingStep0_title_ru: Сначала разберём саму колоду.
  teachingStep0_body_ru: В холдеме 52 карты: 13 рангов и 4 масти.
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
  teachingStep0_title_en: Every card has two parts.
  teachingStep0_body_en: Rank tells how high it is. Suit tells the symbol family.
  teachingStep0_title_ru: У карты две части.
  teachingStep0_body_ru: Ранг показывает старшинство карты, а масть — к какой семье символов она относится.
  teachingStep1_title_en: Ranks have an order.
  teachingStep1_body_en: In this beginner drill, ace is higher than king.
  teachingStep1_title_ru: У рангов есть порядок.
  teachingStep1_body_ru: В этом базовом дрилле туз старше короля. Сначала научись уверенно видеть именно этот порядок.
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
  teachingStep0_title_en: Suits are card families.
  teachingStep0_body_en: Use s, h, d, and c for spades, hearts, diamonds, and clubs.
  teachingStep0_title_ru: Масти — это семьи карт.
  teachingStep0_body_ru: Здесь масти сокращаются до s, h, d и c: пики, черви, бубны и трефы. Эти буквы нужно читать без паузы.
  title_ru: Назови масть
  runnerPrompt_ru: У карты всегда есть и ранг, и масть.
  runnerSupport_ru: Здесь масти записаны английскими буквами: s — пики, h — черви, d — бубны, c — трефы.
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
  teachingStep0_title_en: Private cards stay private.
  teachingStep0_body_en: Board cards are shared by every player still in the hand.
  teachingStep0_title_ru: Карманные карты остаются личными.
  teachingStep0_body_ru: Карты борда общие для всех игроков в раздаче, а твои две карманные видишь и используешь только ты.
  title_ru: Карманные и борд
  runnerPrompt_ru: Карманные карты твои, борд общий для всех.
  runnerSupport_ru: Твои две карты остаются у тебя, а карты борда могут использовать все.
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
  teachingStep0_title_en: Board count grows by street.
  teachingStep0_body_en: Flop shows 3, turn shows 4, and river shows 5.
  teachingStep0_title_ru: Борд растёт по улицам.
  teachingStep0_body_ru: На флопе видно три карты, на тёрне — четыре, на ривере — пять. Этот порядок не меняется.
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
  teachingStep0_title_en: Seven seen, five count.
  teachingStep0_body_en: Two private cards plus five board cards are available.
  teachingStep0_title_ru: Руки сравнивают по лучшим пяти.
  teachingStep0_body_ru: Ты соединяешь карманные карты с бордом и сравниваешь не всё подряд, а самую сильную пятёрку.
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
  teachingStep0_title_en: Card takeaway.
  teachingStep0_body_en: Rank compares height. Suit groups cards, and board cards are shared.
  teachingStep0_title_ru: Короткий вывод по картам.
  teachingStep0_body_ru: Ранг отвечает за силу, масть — за семейство карты, а борд даёт общие карты всем. Это и есть базовая грамматика стола.
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
  teachingStep0_title_en: A hand starts preflop.
  teachingStep0_body_en: You get two private cards. No board cards are out yet.
  teachingStep0_title_ru: Раздача начинается на префлопе.
  teachingStep0_body_ru: Ты получаешь две закрытые карты. Карт борда на столе пока нет.
  teachingStep1_title_en: Private means yours.
  teachingStep1_body_en: Only you can use your private cards.
  teachingStep1_title_ru: Закрытые карты принадлежат только тебе.
  teachingStep1_body_ru: Эти две карты видишь и используешь только ты.
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
  teachingStep0_title_en: The board is shared.
  teachingStep0_body_en: Everyone still in the hand can use these middle cards.
  teachingStep0_title_ru: Борд общий для всех.
  teachingStep0_body_ru: Флоп выкладывает в центр три общие карты. Их может использовать каждый игрок, который остался в раздаче.
  teachingStep1_title_en: The flop has three cards.
  teachingStep1_body_en: Turn adds one more. River adds the fifth.
  teachingStep1_title_ru: На флопе три карты.
  teachingStep1_body_ru: Потом тёрн добавляет четвёртую карту, а ривер — пятую. Так и достраивается полный борд.
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
  teachingStep0_title_en: Turn means one more board card.
  teachingStep0_body_en: After the flop, exactly one shared card is added.
  teachingStep0_title_ru: Тёрн добавляет одну карту.
  teachingStep0_body_ru: После флопа в центр выходит ровно одна новая общая карта. Поэтому тёрн всегда делает борд из четырёх карт.
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
  teachingStep0_title_en: River completes the board.
  teachingStep0_body_en: The fifth shared card is the last board card.
  teachingStep0_title_ru: Ривер закрывает борд.
  teachingStep0_body_ru: Пятая общая карта завершает борд. После ривера новые карты уже не появляются.
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
  teachingStep0_title_en: Showdown compares hands.
  teachingStep0_body_en: When players remain, reveal cards and compare best hands.
  teachingStep0_title_ru: Шоудаун сравнивает руки.
  teachingStep0_body_ru: Если в раздаче остались игроки, карты открываются и сравниваются их лучшие пятёрки.
  title_ru: Чтение шоудауна
  runnerPrompt_ru: На шоудауне банк забирает лучшая рука.
  runnerSupport_ru: Сравнивай итоговую лучшую пятёрку, а не случайные отдельные карты.
  runnerQuestion_ru: Что решает шоудаун?

- taskId: your_first_hand_action_trail
  status: landed_or_partial
  title_en: Action history
  phase: drill
  stepKind: practice
  runner: _actionTrailRunner
  runnerPrompt_en: The action history records what happened street by street.
  runnerSupport_en: Read it left to right.
  runnerQuestion_en: Which previous action happened last?
  teachingStep0_title_en: Action history shows the hand.
  teachingStep0_body_en: Read left to right to see what already happened.
  teachingStep0_title_ru: Лента действий — это история.
  teachingStep0_body_ru: Читай её слева направо, чтобы увидеть, что уже произошло в раздаче и в каком порядке.
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
  teachingStep0_title_en: Street order never skips.
  teachingStep0_body_en: Preflop comes first, then flop, turn, and river.
  teachingStep0_title_ru: Порядок улиц не перескакивает.
  teachingStep0_body_ru: Сначала идёт префлоп, потом флоп, затем тёрн и только после него ривер. Улицы всегда идут в этой последовательности.
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
  teachingStep0_title_en: Actions are table verbs.
  teachingStep0_body_en: Fold exits and check waits. Call matches the price, and raise adds more.
  teachingStep0_title_ru: Действия — это глаголы за столом.
  teachingStep0_body_ru: Фолд уходит, а чек ждёт. Колл уравнивает цену, а рейз добавляет ещё.
  title_ru: Слова действий
  summary_ru: Сначала закрепи четыре главных глагола: фолд, чек, колл и рейз.
  runnerPrompt_ru: Сначала назови действие, потом принимай решение.
  runnerSupport_ru: Держись простого каркаса: фолд уходит, чек не добавляет фишек, колл уравнивает, рейз повышает цену.
  runnerQuestion_ru: Какое действие первым добавляет фишки в банк?

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
  teachingStep0_title_en: Legality depends on price.
  teachingStep0_body_en: No price means check is available. A price unlocks call.
  teachingStep0_title_ru: Разрешённость зависит от цены.
  teachingStep0_body_ru: Если цены нет, тебе доступен чек. Если цена появилась, уже открываются колл или пас.
  title_ru: Разрешённые действия
  summary_ru: Свяжи состояние стола с теми действиями, которые здесь действительно разрешены.
  lockedSummary_ru: Сначала открой Слова действий, потом этот узел начнёт читаться правильно.
  runnerPrompt_ru: Смотри на ставку на столе и убери невозможные действия.
  runnerSupport_ru: Сначала прочитай состояние стола, потом оставь только те действия, которые здесь вообще доступны.
  runnerQuestion_ru: Ставки перед тобой нет. Какое действие здесь бесплатное и законное?

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
  teachingStep0_title_en: No bet is facing you.
  teachingStep0_body_en: When no one has bet, check keeps playing for free.
  teachingStep0_title_ru: Перед тобой нет ставки.
  teachingStep0_body_ru: Если никто не поставил, чек позволяет остаться в раздаче бесплатно. Это и есть его смысл.
  title_ru: Чек без ставки
  summary_ru: Распознай единственный момент, когда чек бесплатен и действительно правильный.
  lockedSummary_ru: Сначала закрой Слова действий, потом откроется чтение спота без ставки.
  runnerPrompt_ru: Если ставки нет, проверь, открыт ли бесплатный чек.
  runnerSupport_ru: Чек существует только тогда, когда до тебя никто не поставил. Ищи именно это условие.
  runnerQuestion_ru: Какое действие позволяет продолжать бесплатно?

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
  teachingStep0_title_en: A bet creates a price.
  teachingStep0_body_en: If your hand is not worth the price, folding saves chips.
  teachingStep0_title_ru: Ставка создаёт цену.
  teachingStep0_body_ru: Если рука не стоит этой цены, пас просто экономит фишки. Здесь не нужно искать героизма.
  title_ru: Фолд слабых рук
  summary_ru: Натренируй чистый выход из спота, где продолжение только сожжёт фишки.
  lockedSummary_ru: Сначала пройди вступление, потом вернись к этому ремонтному узлу.
  runnerPrompt_ru: Слабая рука без цены не обязана продолжать.
  runnerSupport_ru: Фолд сохраняет стек, когда продолжение не даёт внятной причины вкладывать фишки дальше.
  runnerQuestion_ru: Какое действие сразу сдаёт руку?

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
  teachingStep0_title_en: Calling matches the price.
  teachingStep0_body_en: Call means put in exactly enough chips to continue.
  teachingStep0_title_ru: Колл уравнивает цену.
  teachingStep0_body_ru: Колл значит вложить ровно столько, сколько нужно для продолжения. Не больше и не меньше.
  title_ru: Колл по цене
  summary_ru: Пойми, когда колл по цене остаётся самым дешёвым и верным продолжением.
  lockedSummary_ru: Этот шаг откроется после Слов действий, когда базовые глаголы станут устойчивыми.
  runnerPrompt_ru: Когда цена разумная, колл просто держит раздачу в игре.
  runnerSupport_ru: Колл не выигрывает раздачу сразу, но часто остаётся самым спокойным и дешёвым продолжением.
  runnerQuestion_ru: Какое действие уравнивает цену в 1 BB?

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
  teachingStep0_title_en: Look before you act.
  teachingStep0_body_en: First ask: is anyone already in the pot?
  teachingStep0_title_ru: Сначала посмотри на стол.
  teachingStep0_body_ru: До выбора действия сначала спроси себя, вошёл ли уже кто-то в банк. От этого и зависит меню решений.
  teachingStep1_title_en: No one entered yet.
  teachingStep1_body_en: Calling would limp. First in usually means raise or fold.
  teachingStep1_title_ru: До тебя никто не вошёл.
  teachingStep1_body_ru: Пассивный вход здесь будет лимпом. Если ты входишь первым, обычно выбор чище между рейзом и пасом.
  title_ru: Открытие на баттоне
  summary_ru: Используй рейз в самом чистом споте для новичка: все выбросили, а ты на баттоне.
  lockedSummary_ru: Сначала выучи меню действий, потом открывай агрессивный вариант.
  runnerPrompt_ru: Когда все выбросили до тебя на баттоне, рейз забирает инициативу.
  runnerSupport_ru: Рейз открывает раздачу давлением. На баттоне без предыдущей ставки это самый чистый учебный пример.
  runnerQuestion_ru: Какое первое действие здесь выглядит чище всего?

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
  teachingStep0_title_en: Action takeaway.
  teachingStep0_body_en: First read the price. Then choose the matching action family.
  teachingStep0_title_ru: Сначала прочитай цену.
  teachingStep0_body_ru: Перед действием сначала пойми, есть ли ставка и какую семью действий она открывает. Так ошибки становятся реже.
  title_ru: Повтор по действиям
  summary_ru: Докажи, что можешь называть правильное действие без подсказок.
  lockedSummary_ru: Повтор откроется после того, как дриллы по действиям будут закрыты чисто.
  runnerPrompt_ru: Назови действие быстро и без лишних догадок.
  runnerSupport_ru: Собери всё вместе: прочитай стол, отсеки невозможное и назови лучшее действие.
  runnerQuestion_ru: Что на баттоне обычно чище, чем лимп первым?

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
  teachingStep0_title_en: Blinds force a starting pot.
  teachingStep0_body_en: Blinds are real chips or money put in first. Players often count them in big blinds because BB is the clean shortcut for the price.
  teachingStep0_title_ru: Блайнды создают стартовый банк.
  teachingStep0_body_ru: Блайнды — это реальные фишки, которые кладут в банк ещё до первого решения. Именно поэтому префлоп никогда не начинается с пустого стола.
  teachingStep1_title_en: Action starts after BB.
  teachingStep1_body_en: If the big blind is 1 BB, then a 3 BB open means three times that price. Preflop, UTG is first to choose after the blinds post.
  teachingStep1_title_ru: Действие стартует после BB.
  teachingStep1_body_ru: Если большой блайнд равен 1 BB, то открытие 3 BB значит цену в три таких блайнда. Первым после блайндов на префлопе действует UTG.
  title_ru: Блайнды ставятся первыми
  runnerPrompt_ru: Сначала малый и большой блайнд ставят обязательные фишки.
  runnerSupport_ru: Первый выбор за столом появляется только после того, как BB уже поставлен.
  runnerQuestion_ru: Какой блайнд ставит полный 1 BB?

- taskId: blinds_posts_drill
  status: landed_or_partial
  title_en: Who posts 1 BB
  phase: drill
  stepKind: practice
  runner: _bigBlindPostRunner
  runnerPrompt_en: BB posts the full 1 BB blind.
  runnerSupport_en: SB posts the smaller 0.5 BB blind.
  runnerQuestion_en: Tap the big blind.
  teachingStep0_title_en: Big blind is the full blind.
  teachingStep0_body_en: Find the seat marked BB with the 1 BB post.
  teachingStep0_title_ru: Большой блайнд — полный блайнд.
  teachingStep0_body_ru: Найди место с меткой BB и ставкой 1 BB. Это и есть полный обязательный блайнд.
  title_ru: Кто ставит 1 BB
  runnerPrompt_ru: BB ставит полный блайнд в 1 BB.
  runnerSupport_ru: SB ставит меньший блайнд — 0.5 BB.
  runnerQuestion_ru: Где здесь большой блайнд?

- taskId: blinds_first_actor
  status: landed_or_partial
  title_en: First preflop actor
  phase: drill
  stepKind: practice
  runner: _firstPreflopActorRunner
  runnerPrompt_en: Preflop starts left of the big blind.
  runnerSupport_en: Tap the first preflop actor.
  runnerQuestion_en: Tap UTG.
  teachingStep0_title_en: Preflop begins after BB.
  teachingStep0_body_en: The first seat left of the big blind is UTG.
  teachingStep0_title_ru: Префлоп начинается после BB.
  teachingStep0_body_ru: Первое место слева от большого блайнда называется UTG. Именно оно открывает круг решений на префлопе.
  title_ru: Первый на префлопе
  runnerPrompt_ru: На префлопе действие начинается слева от большого блайнда.
  runnerSupport_ru: Нажми на первого игрока, который принимает решение на префлопе.
  runnerQuestion_ru: Где здесь UTG?

- taskId: blinds_last_actor
  status: landed_or_partial
  title_en: Last preflop actor
  phase: drill
  stepKind: practice
  runner: _lastPreflopActorRunner
  runnerPrompt_en: The big blind closes preflop when nobody raises.
  runnerSupport_en: Tap the last preflop actor.
  runnerQuestion_en: Tap BB.
  teachingStep0_title_en: BB closes the first round.
  teachingStep0_body_en: If nobody raises, the big blind can act last preflop.
  teachingStep0_title_ru: BB закрывает первый круг.
  teachingStep0_body_ru: Если никто не рейзил, большой блайнд получает последнее префлоп-решение. Это завершает первый круг торговли.
  title_ru: Последний на префлопе
  runnerPrompt_ru: Если никто не рейзил, префлоп закрывает большой блайнд.
  runnerSupport_ru: Нажми на последнего игрока в первом круге торговли.
  runnerQuestion_ru: Где здесь BB?

- taskId: blinds_postflop_button
  status: landed_or_partial
  title_en: Last postflop actor
  phase: drill
  stepKind: practice
  runner: _postflopButtonActorRunner
  runnerPrompt_en: After the flop, Button often acts last.
  runnerSupport_en: Tap BTN.
  runnerQuestion_en: Tap the last postflop actor.
  teachingStep0_title_en: Postflop order changes.
  teachingStep0_body_en: After the flop, blinds act early and Button often acts last.
  teachingStep0_title_ru: После флопа порядок меняется.
  teachingStep0_body_ru: На постфлопе блайнды говорят раньше, а баттон часто остаётся последним. Это важно держать в голове сразу.
  title_ru: Последний на постфлопе
  runnerPrompt_ru: После флопа баттон часто закрывает действие.
  runnerSupport_ru: Нажми на место, которое чаще всего говорит последним на постфлопе.
  runnerQuestion_ru: Где здесь последний игрок после флопа?

- taskId: blinds_button_moves
  status: landed_or_partial
  title_en: Button moves
  phase: drill
  stepKind: practice
  runner: _buttonMovesRunner
  runnerPrompt_en: The Button moves one seat after each hand.
  runnerSupport_en: That keeps blinds and late position rotating.
  runnerQuestion_en: Which marker shows the dealer button this hand?
  teachingStep0_title_en: Button rotates.
  teachingStep0_body_en: After each hand, the button moves so blinds rotate too.
  teachingStep0_title_ru: Баттон двигается.
  teachingStep0_body_ru: После каждой раздачи баттон смещается на одно место. Вместе с ним вращаются и блайнды, и поздняя позиция.
  title_ru: Баттон двигается
  runnerPrompt_ru: Баттон двигается на одно место после каждой раздачи.
  runnerSupport_ru: Именно так блайнды и поздняя позиция честно переходят по кругу.
  runnerQuestion_ru: Какая метка показывает баттон в этой раздаче?

- taskId: blinds_review
  status: landed_or_partial
  title_en: Order recap
  phase: review
  stepKind: proveIt
  runner: _blindsOrderRecapRunner
  runnerPrompt_en: Lesson learned: blinds start the order.
  runnerSupport_en: SB posts 0.5, BB posts 1, then action begins around the table.
  runnerQuestion_en: Who acts first preflop?
  teachingStep0_title_en: Order takeaway.
  teachingStep0_body_en: Blinds post first. Then each street follows the table order.
  teachingStep0_title_ru: Короткий вывод по порядку.
  teachingStep0_body_ru: Сначала в банк идут блайнды. Потом каждая улица проходит по порядку действий стола. Этот ритм нельзя терять.
  title_ru: Повтор по порядку
  runnerPrompt_ru: Главная мысль урока: порядок действий запускают блайнды.
  runnerSupport_ru: SB ставит 0.5 BB, BB ставит 1 BB, а потом действие идёт по кругу.
  runnerQuestion_ru: Кто действует первым на префлопе?

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
  teachingStep0_title_en: Seats have names.
  teachingStep0_body_en: UTG means under the gun, the first seat to act. HJ is hijack. CO is cutoff. BTN is button, and SB plus BB are the blinds.
  teachingStep0_title_ru: BTN показывает баттон.
  teachingStep0_body_ru: Метка BTN отмечает место дилера в этой раздаче. После флопа оно часто действует последним.
  teachingStep1_title_en: Position changes information.
  teachingStep1_body_en: Late seats see more actions before they decide.
  teachingStep1_title_ru: Пара старше старшей карты.
  teachingStep1_body_ru: Два одинаковых ранга дают первую готовую руку, которую новичку нужно узнавать без задержки.
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
  teachingStep0_title_en: BTN marks the Button.
  teachingStep0_body_en: The dealer button shows the late seat for this hand.
  teachingStep0_title_ru: UTG — ранняя позиция.
  teachingStep0_body_ru: UTG действует первым на префлопе и получает меньше всего информации. Поэтому здесь нужна большая аккуратность.
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
  teachingStep0_title_en: UTG is early.
  teachingStep0_body_en: UTG acts first preflop and has the least information.
  teachingStep0_title_ru: Две пары — это два совпадения.
  teachingStep0_body_ru: Здесь собираются два разных совпадающих ранга. Именно они делают две пары старше одной пары.
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
  teachingStep0_title_en: CO is before BTN.
  teachingStep0_body_en: Cutoff is the seat immediately before the Button.
  teachingStep0_title_ru: Тройка сильнее двух пар.
  teachingStep0_body_ru: Три карты одного ранга всегда старше двух отдельных пар. Сначала ищи саму структуру руки.
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
  teachingStep0_title_en: Late means more information.
  teachingStep0_body_en: Late seats see more choices before they decide.
  teachingStep0_title_ru: Стрит — это последовательность.
  teachingStep0_body_ru: Стрит собирается из пяти рангов подряд. Ему не нужна одна масть, ему нужен порядок карт.
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
  teachingStep0_title_en: Early seats decide sooner.
  teachingStep0_body_en: UTG acts before seeing what most players will do.
  teachingStep0_title_ru: Флеш — это одна масть.
  teachingStep0_body_ru: Пять карт одной масти дают флеш. Он старше стрита, и этот порядок важно запомнить отдельно.
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
  teachingStep0_title_en: Position takeaway.
  teachingStep0_body_en: Seat name tells when you act and how much you can observe.
  teachingStep0_title_ru: Лишние карты не играют.
  teachingStep0_body_ru: На вскрытии считаются только лучшие пять карт. Всё, что не вошло в эту пятёрку, просто остаётся фоном.
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
  teachingStep0_title_en: Ranking ladder.
  teachingStep0_body_en: Hand names tell which made hand is stronger.
  teachingStep0_title_ru: Короткий вывод по старшинству.
  teachingStep0_body_ru: Сначала определи тип руки, а потом сравни его по лестнице старшинства. Так путаницы станет намного меньше.
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
  teachingStep0_title_en: Hands use the best five cards.
  teachingStep0_body_en: You combine private cards with the board, then compare hand rank.
  teachingStep0_title_ru: Руки сравнивают по лучшим пяти.
  teachingStep0_body_ru: Ты соединяешь карманные карты с бордом и сравниваешь не всё подряд, а самую сильную пятёрку.
  teachingStep1_title_en: A pair beats high card.
  teachingStep1_body_en: Matching ranks make the first made hand beginners need.
  teachingStep1_title_ru: Пара старше старшей карты.
  teachingStep1_body_ru: Два одинаковых ранга дают первую готовую руку, которую новичку нужно узнавать без задержки.
  title_ru: Найди пару
  runnerPrompt_ru: Пара уже сильнее просто старшей карты.
  runnerSupport_ru: Ищи два совпадающих ранга. Это первая устойчивая готовая рука в базовой лестнице.
  runnerQuestion_ru: Что собрал ты в этом примере?

- taskId: hand_rankings_two_pair_drill
  status: landed_or_partial
  title_en: Two pair vs one pair
  phase: drill
  stepKind: practice
  runner: _twoPairRunner
  runnerPrompt_en: Two pair beats one pair.
  runnerSupport_en: Count matching ranks on the board and in hand.
  runnerQuestion_en: Which hand is stronger?
  teachingStep0_title_en: Two pair uses two ranks.
  teachingStep0_body_en: Hero uses A with A and 7 with 7. That makes two pair, with the J as the fifth card.
  teachingStep0_title_ru: Две пары — это два совпадения.
  teachingStep0_body_ru: Здесь собираются два разных совпадающих ранга. Именно они делают две пары старше одной пары.
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
  teachingStep0_title_en: Three of a kind is above two pair.
  teachingStep0_body_en: Three cards of one rank beat two separate pairs.
  teachingStep0_title_ru: Тройка сильнее двух пар.
  teachingStep0_body_ru: Три карты одного ранга всегда старше двух отдельных пар. Сначала ищи саму структуру руки.
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
  teachingStep0_title_en: Straight means sequence.
  teachingStep0_body_en: A straight is five ranks in a row, not five of one suit.
  teachingStep0_title_ru: Стрит — это последовательность.
  teachingStep0_body_ru: Стрит собирается из пяти рангов подряд. Ему не нужна одна масть, ему нужен порядок карт.
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
  teachingStep0_title_en: Flush means same suit.
  teachingStep0_body_en: Five cards of one suit make a flush. Flushes rank above straights because they are rarer: roughly 5,100 flush combinations exist in a deck versus about 10,200 straights. Rarer combinations rank higher.
  teachingStep0_title_ru: Флеш — это одна масть.
  teachingStep0_body_ru: Пять карт одной масти дают флеш. Он старше стрита, и этот порядок важно запомнить отдельно.
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
  teachingStep0_title_en: Extra cards are ignored.
  teachingStep0_body_en: Here the best five are A, A, 7, 7, and J. The 4 is visible, but it does not play.
  teachingStep0_title_ru: Лишние карты не играют.
  teachingStep0_body_ru: На вскрытии считаются только лучшие пять карт. Всё, что не вошло в эту пятёрку, просто остаётся фоном.
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
  teachingStep0_title_en: Ranking takeaway.
  teachingStep0_body_en: First identify the hand type, then compare the ladder.
  teachingStep0_title_ru: Короткий вывод по старшинству.
  teachingStep0_body_ru: Сначала определи тип руки, а потом сравни его по лестнице старшинства. Так путаницы становится меньше.
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
  teachingStep0_title_en: Two endings.
  teachingStep0_body_en: Win when everyone folds, or win by best hand at showdown.
  teachingStep0_title_ru: У раздачи два финала.
  teachingStep0_body_ru: Банк можно выиграть либо пасами всех соперников, либо лучшей рукой на шоудауне. Это два базовых конца любой раздачи.
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
  teachingStep0_title_en: Showdown means reveal.
  teachingStep0_body_en: If players remain after the river, hands are compared.
  teachingStep0_title_ru: Шоудаун — это вскрытие.
  teachingStep0_body_ru: Если игроки дошли до конца раздачи, они открывают карты и сравнивают лучшие готовые руки.
  teachingStep1_title_en: Folds can end earlier.
  teachingStep1_body_en: If everyone else folds, no reveal is needed.
  teachingStep1_title_ru: Пасы могут закончить всё раньше.
  teachingStep1_body_ru: Если все остальные выбросили, вскрытие больше не нужно. Последний оставшийся игрок сразу забирает банк.
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
  teachingStep0_title_en: Showdown compares hands.
  teachingStep0_body_en: When players remain, reveal cards and compare best hands.
  teachingStep0_title_ru: Шоудаун сравнивает руки.
  teachingStep0_body_ru: Когда в раздаче остаётся несколько игроков, открываются карты и сравниваются их лучшие пятёрки.
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
  teachingStep0_title_en: Kickers break some ties.
  teachingStep0_body_en: If the main hand matches, the best side card can decide.
  teachingStep0_title_ru: Кикер ломает часть ничьих.
  teachingStep0_body_ru: Если основная рука у игроков совпала, решающей может стать лучшая боковая карта. Именно её и называют кикером.
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
  teachingStep0_title_en: Sometimes the board plays.
  teachingStep0_body_en: If the same five board cards are best, private cards do not help.
  teachingStep0_title_ru: Иногда играет сам борд.
  teachingStep0_body_ru: Если лучшая пятёрка уже целиком лежит на борде, карманные карты ничего не добавляют. Тогда оба игрока могут играть одну и ту же доску.
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
  teachingStep0_title_en: Split means share.
  teachingStep0_body_en: When tied players have the same best hand, they split the pot.
  teachingStep0_title_ru: Делёжка — это общий банк.
  teachingStep0_body_ru: Если лучшие руки у игроков полностью совпали, банк делится между ними. Здесь никто не получает дополнительного преимущества.
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
  teachingStep0_title_en: World 1 checkpoint.
  teachingStep0_body_en: Read table flow first, then sort the starting hand into the right bucket.
  teachingStep0_title_ru: Контрольная первого мира.
  teachingStep0_body_ru: Сначала научись читать ход раздачи и устройство стола, а уже потом переходи к группам стартовых рук и следующим решениям.
  title_ru: Повтор по победе
  runnerPrompt_ru: Теперь ты уже видишь оба финала раздачи: все выбросили или лучшая рука дошла до вскрытия.
  runnerSupport_ru: Это завершает первый круг чтения раздачи: стол, улицы, старшинство рук и способы забрать банк.
  runnerQuestion_ru: Что выигрывает на шоудауне?
