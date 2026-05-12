# Act0 RU Consolidated Editor Export v1

Status: GENERATED
Scope: `world_1` to `world_12`
Purpose: one-file bilingual handoff for external translation review

## How To Use
1. Review or improve only `*_ru` fields.
2. Keep ids unchanged.
3. Keep tone compact, learner-facing, and poker-literate.
4. Do not treat this file as runtime truth; it is an editorial handoff artifact.

## Runtime Truth
- Runtime language file: `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart`
- Core API/reader layer: `lib/ui_v2/act0_shell/act0_content_copy_v1.dart`

## Included World Packs

---

## Pack: world_1

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
- Teaching step titles: 7/68
- Teaching step bodies: 7/68

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
  teachingStep0_title_en: We start with Hold'em cash.
  teachingStep0_body_en: Hold'em gives every player 2 private hole cards and deals 5 community cards the whole table shares — you build the best 5-card hand from those 7. Poker has many formats, but this course starts with No-Limit Hold'em cash games. Cash is the cleanest base: chips keep one stable value and the same core decisions repeat hand after hand. The other main format is tournaments, where you buy in once and play for a prize pool.
  teachingStep0_title_ru: Начинаем с кэш-игры в холдем.
  teachingStep0_body_ru: В холдеме у каждого игрока 2 закрытые карты, а на стол выходят 5 общих. Итоговая рука собирается из лучших пяти карт из этих семи. Есть разные форматы покера, но курс стартует с No-Limit Hold’em cash: здесь ценность фишек не меняется, а одни и те же базовые решения повторяются раз за разом.
  teachingStep1_title_en: This is a poker table.
  teachingStep1_body_en: You are the hero. The other seats are opponents.
  teachingStep1_title_ru: Перед тобой покерный стол.
  teachingStep1_body_ru: Ты играешь за нижнее место. Остальные места за столом — соперники.
  teachingStep2_title_en: The goal is the pot.
  teachingStep2_body_en: Players put chips in the middle. The winner takes that pot.
  teachingStep2_title_ru: Цель раздачи — забрать банк.
  teachingStep2_body_ru: Игроки вкладывают фишки в центр стола. Тот, кто выигрывает раздачу, забирает этот банк.
  teachingStep3_title_en: Blinds start the hand.
  teachingStep3_body_en: SB posts 0.5 BB. BB posts 1 BB before anyone chooses. Hole cards stay hidden at first so you can read the table without extra noise.
  teachingStep3_title_ru: Раздачу запускают блайнды.
  teachingStep3_body_ru: Сначала SB ставит 0.5 BB, а BB — 1 BB. Эти обязательные ставки появляются ещё до первого решения. Карты пока скрыты, чтобы ты сначала спокойно прочитал сам стол.
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
  runner: _findHeroSeatRunner
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
  teachingStep0_title_en: Pot and stack are different.
  teachingStep0_body_en: The pot is in the middle. Your stack stays with your seat.
  teachingStep0_title_ru: Банк и стек — разные вещи.
  teachingStep0_body_ru: Банк лежит в центре стола. Твой стек остаётся рядом с твоим местом. Эти фишки нельзя путать.
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
  teachingStep0_title_en: A pot can end two ways.
  teachingStep0_body_en: Everyone else folds, or players compare hands at showdown.
  teachingStep0_title_ru: У банка два финала.
  teachingStep0_body_ru: Банк заканчивается либо пасами всех остальных, либо сравнением рук на шоудауне. Этого пока достаточно.
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
  teachingStep0_title_ru: Шоудаун сравнивает руки.
  teachingStep0_body_ru: Если в раздаче осталось несколько игроков, карты открываются и сравниваются лучшие готовые руки.
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
  teachingStep0_title_en: Carry the first table scan.
  teachingStep0_body_en: Real tables still start with the same simple scan: your two cards, the shared board, and how many chips sit in the pot.
  teachingStep0_title_ru: Перенеси первое чтение на живой стол.
  teachingStep0_body_ru: Даже на живом столе порядок тот же: сначала твои две карты, потом общий борд, потом размер банка.
  title_ru: Первое чтение живого стола
  summary_ru: Перенеси первое чтение стола в живую раздачу: сначала свои карты, потом борд, потом банк.
  runnerPrompt_ru: Сначала посмотри на свои карты, потом на борд, потом на банк.
  runnerSupport_ru: Этот порядок не даёт расплыться вниманию: свои карты, общие карты, потом размер банка.
  runnerQuestion_ru: С чего лучше начать быстрое чтение стола?

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
  teachingStep0_title_en: Table checklist.
  teachingStep0_body_en: Find hero, opponents, blinds, and pot before any decision.
  teachingStep0_title_ru: Короткая проверка стола.
  teachingStep0_body_ru: Найди своё место, соперников, блайнды и банк до любого решения. Это и есть первый чистый ритуал за столом.
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
  teachingStep0_body_en: Rank compares height. Suit groups cards. Board cards are shared.
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
  title_en: Action trail
  phase: drill
  stepKind: practice
  runner: _actionTrailRunner
  runnerPrompt_en: The action trail records what happened street by street.
  runnerSupport_en: Read it left to right.
  runnerQuestion_en: Which trail item happened last?
  teachingStep0_title_en: Action trail is history.
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
  teachingStep0_body_en: Fold exits. Check waits. Call matches. Raise adds.
  teachingStep0_title_ru: Действия — это глаголы стола.
  teachingStep0_body_ru: Фолд сдаётся, чек ждёт, колл уравнивает, рейз добавляет цену. Сначала запомни именно этот скелет.
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
  teachingStep0_body_en: UTG, HJ, CO, BTN, SB, and BB describe table position.
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


---

## Pack: world_2

# world_2 RU Translation Pack

Status: GENERATED
World number: 2
EN title: Hand Discipline
EN subtitle: Learn which hands deserve chips and which can fold.
title_ru: Дисциплина рук
subtitle_ru: Пойми, какие руки стоят фишек, а какие спокойно уходят в пас.

## Coverage
- Lessons: 2/6
- Tasks: 12/35
- Runner prompts: 12/35
- Runner supports: 12/35
- Runner questions: 12/35
- Teaching step titles: 0/35
- Teaching step bodies: 0/35

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson hand_discipline_buckets
status: landed_or_partial
title_en: Hand buckets
subtitle_en: Sort hands before putting chips in.
title_ru: Группы стартовых рук
subtitle_ru: Сначала разложи руку по простой группе, а уже потом вкладывай фишки.

- taskId: hand_discipline_buckets_intro
  status: landed_or_partial
  title_en: Four buckets
  phase: theory
  stepKind: learn
  runner: _world3BucketsIntroRunner
  runnerPrompt_en: Preflop starts by sorting the hand into a simple bucket.
  runnerSupport_en: Use premium, strong, medium, and trash before choosing. No charts needed at this stage.
  runnerQuestion_en: What should you name before the action?
  teachingStep0_title_en: Bucket first.
  teachingStep0_body_en: Name the hand bucket before choosing open, call, or fold. Keep it simple and repeatable.
  teachingStep0_title_ru: Сначала группа.
  teachingStep0_body_ru: До открытия, колла или паса сначала назови группу руки. Этот порядок должен стать простым и повторяемым.
  title_ru: Четыре группы
  runnerPrompt_ru: Сначала назови группу руки, а уже потом думай о действии.
  runnerSupport_ru: Этот первый фильтр убирает суету: премиум и сильные руки играются иначе, чем средние и мусорные.
  runnerQuestion_ru: Что лучше назвать до действия?

- taskId: hand_discipline_buckets_premium
  status: landed_or_partial
  title_en: Premium hand
  phase: drill
  stepKind: practice
  runner: _world3PremiumBucketRunner
  runnerPrompt_en: AA is a premium preflop hand.
  runnerSupport_en: Premium hands usually want to build the pot.
  runnerQuestion_en: Which bucket is AA?
  teachingStep0_title_en: Premium means top bucket.
  teachingStep0_body_en: AA starts in the premium bucket before context changes anything.
  teachingStep0_title_ru: Премиум — это верхняя группа.
  teachingStep0_body_ru: AA сразу попадает в премиум. Здесь контекст уже потом уточняет линию, но не меняет базовую силу руки.
  title_ru: Премиум-рука
  runnerPrompt_ru: Сначала определи группу руки.
  runnerSupport_ru: Премиум-руки не требуют сложных оправданий: они чаще хотят строить банк, а не прятаться.
  runnerQuestion_ru: Какая группа у АА?

- taskId: hand_discipline_buckets_strong
  status: landed_or_partial
  title_en: Strong hand
  phase: drill
  stepKind: practice
  runner: _w1StrongBucketRunner
  runnerPrompt_en: JJ is a strong preflop hand.
  runnerSupport_en: Strong hands play well but are not the absolute top bucket.
  runnerQuestion_en: Which bucket is JJ?
  teachingStep0_title_en: Strong, not premium.
  teachingStep0_body_en: JJ is strong but can face an ace on the flop. Strong is the second bucket.
  teachingStep0_title_ru: Сильная, но не премиум.
  teachingStep0_body_ru: JJ — сильная рука, но не самый верх диапазона. Это вторая группа, а не абсолютная вершина.
  title_ru: Сильная рука
  runnerPrompt_ru: Назови группу руки до выбора линии.
  runnerSupport_ru: Сильная рука почти всегда играбельна, но это ещё не вершина диапазона.
  runnerQuestion_ru: Какая группа у JJ?

- taskId: hand_discipline_buckets_medium
  status: landed_or_partial
  title_en: Medium hand
  phase: drill
  stepKind: practice
  runner: _w1MediumBucketRunner
  runnerPrompt_en: KQo is a medium preflop hand.
  runnerSupport_en: Medium hands play best in good positions with the right frame.
  runnerQuestion_en: Which bucket is KQo?
  teachingStep0_title_en: Medium needs position.
  teachingStep0_body_en: KQo is playable but not strong enough to play from anywhere.
  teachingStep0_title_ru: Средней руке нужна опора.
  teachingStep0_body_ru: KQo играется, но не отовсюду одинаково хорошо. Средней руке важнее позиция и чистая ситуация.
  title_ru: Средняя рука
  runnerPrompt_ru: Сначала пойми, насколько рука пограничная.
  runnerSupport_ru: Средняя рука не обязана лезть в каждый банк. Ей нужен более удобный спот, чем премиуму.
  runnerQuestion_ru: Какая группа у KQo?

- taskId: hand_discipline_buckets_trash
  status: landed_or_partial
  title_en: Trash hand
  phase: drill
  stepKind: practice
  runner: _world3TrashBucketRunner
  runnerPrompt_en: J8o is a weak offsuit starter from early position.
  runnerSupport_en: Weak early hands should not be forced into action.
  runnerQuestion_en: Which bucket fits J8o early?
  teachingStep0_title_en: Weak and early is trouble.
  teachingStep0_body_en: J8o has little help, especially before seeing others act.
  teachingStep0_title_ru: Слабая рука рано — это проблема.
  teachingStep0_body_ru: У J8o слишком мало запаса, особенно когда ты ещё не видел действий остальных. Такой спот лучше не форсировать.
  title_ru: Мусорная рука
  runnerPrompt_ru: Слабая рука не обязана становиться приключением.
  runnerSupport_ru: Если рука не тянет на продолжение, дисциплина экономит фишки простым фолдом.
  runnerQuestion_ru: К какой группе отнести J8o в ранней позиции?

- taskId: hand_discipline_buckets_borderline
  status: landed_or_partial
  title_en: Borderline strong
  phase: drill
  stepKind: practice
  runner: _w1StrongBucketRunner
  runnerPrompt_en: JJ is a strong preflop hand.
  runnerSupport_en: Strong hands play well but are not the absolute top bucket.
  runnerQuestion_en: Which bucket is JJ?
  teachingStep0_title_en: Strong, not premium.
  teachingStep0_body_en: JJ is strong but can face an ace on the flop. Strong is the second bucket.
  teachingStep0_title_ru: Сильная, но не верхняя.
  teachingStep0_body_ru: Такая рука всё ещё хороша, но ей не нужно приписывать силу абсолютного топа. Это просто крепкая вторая группа.
  title_ru: Погранично сильная
  runnerPrompt_ru: Не путай просто сильную руку с премиумом.
  runnerSupport_ru: Эта группа всё ещё играет уверенно, но ей не нужно приписывать силу самого верха.
  runnerQuestion_ru: Какая группа здесь ближе всего?

- taskId: hand_discipline_buckets_recap
  status: landed_or_partial
  title_en: Bucket recap
  phase: review
  stepKind: review
  runner: _world3BucketsRecapRunner
  runnerPrompt_en: Lesson learned: bucket the hand before the action.
  runnerSupport_en: Premium, strong, medium, or trash is the first preflop read.
  runnerQuestion_en: What is the first preflop habit?
  teachingStep0_title_en: Bucket checklist.
  teachingStep0_body_en: Name the hand bucket, then read position and action frame.
  teachingStep0_title_ru: Проверка по группе.
  teachingStep0_body_ru: Сначала назови группу руки, потом смотри на позицию и на то, кто уже вошёл в банк. Так префлоп читается заметно чище.
  title_ru: Повтор по группам
  runnerPrompt_ru: До действия сначала назови группу руки.
  runnerSupport_ru: Когда рука быстро попадает в нужную группу, префлоп-решения становятся спокойнее и чище.
  runnerQuestion_ru: Какая префлоп-привычка здесь первая?

## lesson fold_discipline
status: missing
title_en: Fold discipline
subtitle_en: Learn that folding weak hands saves chips.
title_ru: Дисциплина паса
subtitle_ru: Пойми, что пас слабых рук не трусость, а защита фишек.

- taskId: discipline_intro
  status: missing
  title_en: Fold is a tool
  phase: theory
  stepKind: learn
  runner: _foldActionRunner
  runnerPrompt_en: HJ bets and your hand is weak.
  runnerSupport_en: Folding saves chips when continuing is not worth it.
  runnerQuestion_en: Which action gives up the hand?
  teachingStep0_title_en: A bet creates a price.
  teachingStep0_body_en: If your hand is not worth the price, folding saves chips.
  teachingStep0_title_ru: Ставка создаёт цену.
  teachingStep0_body_ru: Если рука не стоит этой цены, пас просто сохраняет фишки. Это не слабость, а нормальный рабочий ответ.
  title_ru: Пас — это инструмент
  runnerPrompt_ru: HJ ставит, а твоя рука слишком слаба для продолжения.
  runnerSupport_ru: Пас экономит фишки в спотах, где дальше платить уже невыгодно.
  runnerQuestion_ru: Какое действие сразу сдаёт эту руку?

- taskId: early_fold
  status: missing
  title_en: Early weak hand
  phase: drill
  stepKind: practice
  runner: _world3EarlyFoldRunner
  runnerPrompt_en: Unopened pot. Hero is early with J8o.
  runnerSupport_en: Early position removes the comfort from weak offsuit hands.
  runnerQuestion_en: What is the clean action?
  teachingStep0_title_en: Discipline is allowed.
  teachingStep0_body_en: Opening weak early hands creates hard spots later.
  teachingStep0_title_ru: Дисциплина здесь уместна.
  teachingStep0_body_ru: Слабое открытие из ранней позиции слишком часто создаёт тяжёлые решения дальше. Чистый пас обычно лучше лишней надежды.
  title_ru: Слабая рука рано
  runnerPrompt_ru: Банк не открыт. Ты в ранней позиции с J8o.
  runnerSupport_ru: Ранняя позиция лишает слабые разномастные руки любого комфорта.
  runnerQuestion_ru: Какое действие здесь самое чистое?

- taskId: facing_fold
  status: missing
  title_en: Facing pressure
  phase: drill
  stepKind: practice
  runner: _world3WeakFacingFoldRunner
  runnerPrompt_en: CO opened. Hero is BTN with J8o.
  runnerSupport_en: Position helps, but this hand is still too weak to continue.
  runnerQuestion_en: What is the clean response?
  teachingStep0_title_en: Position is not a free pass.
  teachingStep0_body_en: J8o still folds when the hand bucket is too weak.
  teachingStep0_title_ru: Позиция — не индульгенция.
  teachingStep0_body_ru: Даже на баттоне J8o остаётся слишком слабой рукой против открытия. Позиция помогает не всему подряд.
  title_ru: Пас под давлением
  runnerPrompt_ru: CO открылся. Ты на баттоне с J8o.
  runnerSupport_ru: Позиция помогает, но эта рука всё равно слишком слаба для продолжения.
  runnerQuestion_ru: Какой ответ здесь будет самым чистым?

- taskId: discipline_stack_protect
  status: missing
  title_en: Protect stack
  phase: drill
  stepKind: practice
  runner: _world3DominatedFoldRunner
  runnerPrompt_en: CO opened. Hero is BTN with A7o.
  runnerSupport_en: This can be behind stronger aces, so folding is clean.
  runnerQuestion_en: What is the disciplined response?
  teachingStep0_title_en: Weak ace caution.
  teachingStep0_body_en: A7o can be dominated when someone opened first.
  teachingStep0_title_ru: Осторожно со слабым тузом.
  teachingStep0_body_ru: A7o легко оказывается позади более сильных тузов, если кто-то уже открылся. Здесь дисциплина важнее любопытства.
  title_ru: Сохрани стек
  runnerPrompt_ru: CO открылся. Ты на баттоне с A7o.
  runnerSupport_ru: Такая рука часто доминируется более сильными тузами, поэтому пас здесь чистый.
  runnerQuestion_ru: Какой ответ здесь будет дисциплинированным?

- taskId: fold_recap
  status: missing
  title_en: Discipline recap
  phase: review
  stepKind: review
  runner: _world3DominatedRecapRunner
  runnerPrompt_en: Lesson learned: familiar cards still need context.
  runnerSupport_en: Do not continue just because one card looks high.
  runnerQuestion_en: What should weak familiar hands avoid?
  teachingStep0_title_en: Trouble-hand checklist.
  teachingStep0_body_en: High card alone is not enough. Read the opener and bucket.
  teachingStep0_title_ru: Проверка на проблемные руки.
  teachingStep0_body_ru: Одной высокой карты мало. Сначала смотри на открытие соперника и на группу своей руки, а уже потом решай.
  title_ru: Повтор по дисциплине
  runnerPrompt_ru: Главная мысль урока: знакомые карты всё равно требуют контекста.
  runnerSupport_ru: Не продолжай только потому, что одна карта выглядит красиво.
  runnerQuestion_ru: Чего должны избегать такие знакомые, но слабые руки?

## lesson weak_ace_warning
status: missing
title_en: Weak ace warning
subtitle_en: Familiar hands can still be dominated.
title_ru: Осторожно со слабым тузом
subtitle_ru: Знакомая рука всё ещё может оказаться под доминацией.

- taskId: w3_dominated_intro
  status: missing
  title_en: Trouble hands
  phase: theory
  stepKind: learn
  runner: _world3DominatedIntroRunner
  runnerPrompt_en: Some familiar hands are trouble when stronger versions open.
  runnerSupport_en: A weak ace can be behind a better ace.
  runnerQuestion_en: What kind of hand needs caution?
  teachingStep0_title_en: Familiar is not always safe.
  teachingStep0_body_en: Weak aces and weak broadways can run into stronger versions.
  teachingStep0_title_ru: Знакомое — не значит безопасное.
  teachingStep0_body_ru: Слабые тузы и слабые бродвеи часто упираются в более сильные версии тех же рук. Важно заметить это заранее.
  title_ru: Проблемные руки
  runnerPrompt_ru: Некоторые знакомые руки превращаются в проблему, если впереди уже открылись сильнее.
  runnerSupport_ru: Слабый туз легко оказывается позади более сильного туза.
  runnerQuestion_ru: Какая рука здесь требует осторожности?

- taskId: w3_dominated_fold
  status: missing
  title_en: Fold trouble
  phase: drill
  stepKind: practice
  runner: _world3DominatedFoldRunner
  runnerPrompt_en: CO opened. Hero is BTN with A7o.
  runnerSupport_en: This can be behind stronger aces, so folding is clean.
  runnerQuestion_en: What is the disciplined response?
  teachingStep0_title_en: Weak ace caution.
  teachingStep0_body_en: A7o can be dominated when someone opened first.
  teachingStep0_title_ru: Осторожно со слабым тузом.
  teachingStep0_body_ru: A7o может оказаться под доминацией, если кто-то уже открыл раздачу. Такой пас часто не слабость, а дисциплина.
  title_ru: Пас с проблемной рукой
  runnerPrompt_ru: CO открылся. Ты на баттоне с A7o.
  runnerSupport_ru: Такая рука нередко уже позади более сильных тузов, поэтому чистый пас здесь нормален.
  runnerQuestion_ru: Какой ответ здесь будет самым дисциплинированным?

- taskId: w3_strong_continue
  status: missing
  title_en: Strong continue
  phase: drill
  stepKind: practice
  runner: _world3PlayableCallRunner
  runnerPrompt_en: CO opened. Hero is BTN with KQo.
  runnerSupport_en: Playable hand in position: call keeps the hand in.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Playable and in position.
  teachingStep0_body_en: KQo can call a simple open when hero acts after CO.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo можно спокойно коллировать простое открытие, когда ты действуешь после CO. Здесь уже есть и сила, и удобство позиции.
  title_ru: Сильное продолжение
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может спокойно остаться в раздаче через колл.
  runnerQuestion_ru: Какой ответ здесь будет самым простым?

- taskId: weak_ace_pressure_fold
  status: missing
  title_en: Pressure fold
  phase: drill
  stepKind: practice
  runner: _world3WeakFacingFoldRunner
  runnerPrompt_en: CO opened. Hero is BTN with J8o.
  runnerSupport_en: Position helps, but this hand is still too weak to continue.
  runnerQuestion_en: What is the clean response?
  teachingStep0_title_en: Position is not a free pass.
  teachingStep0_body_en: J8o still folds when the hand bucket is too weak.
  teachingStep0_title_ru: Позиция — не индульгенция.
  teachingStep0_body_ru: J8o всё равно идёт в пас, если сама рука слишком слаба. Позиция не обязана спасать плохой старт.
  title_ru: Пас под давлением
  runnerPrompt_ru: CO открылся. Ты на баттоне с J8o.
  runnerSupport_ru: Позиция помогает, но эта рука всё ещё слишком слаба для продолжения.
  runnerQuestion_ru: Какой ответ здесь будет самым чистым?

- taskId: weak_ace_kicker_compare
  status: missing
  title_en: A7 vs KQ spot
  phase: drill
  stepKind: practice
  runner: _world3PlayableCallRunner
  runnerPrompt_en: CO opened. Hero is BTN with KQo.
  runnerSupport_en: Playable hand in position: call keeps the hand in.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Playable and in position.
  teachingStep0_body_en: KQo can call a simple open when hero acts after CO.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo может продолжать против простого открытия, а A7o чаще страдает от доминации. Важна не знакомость руки, а её реальное качество.
  title_ru: A7 против KQ
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может продолжать, когда слабый туз чаще уже отстаёт.
  runnerQuestion_ru: Какой ответ здесь выглядит чище всего?

- taskId: w3_dominated_recap
  status: missing
  title_en: Discipline recap
  phase: review
  stepKind: review
  runner: _world3DominatedRecapRunner
  runnerPrompt_en: Lesson learned: familiar cards still need context.
  runnerSupport_en: Do not continue just because one card looks high.
  runnerQuestion_en: What should weak familiar hands avoid?
  teachingStep0_title_en: Trouble-hand checklist.
  teachingStep0_body_en: High card alone is not enough. Read the opener and bucket.
  teachingStep0_title_ru: Проверка по проблемным рукам.
  teachingStep0_body_ru: Одной высокой карты мало. Сначала смотри, кто открылся, и не путай знакомую руку с действительно сильной.
  title_ru: Повтор по доминации
  runnerPrompt_ru: Главная мысль урока: знакомые карты всё равно требуют контекста.
  runnerSupport_ru: Не продолжай только потому, что одна карта выглядит высокой.
  runnerQuestion_ru: Чего должны избегать такие слабые знакомые руки?

## lesson continue_or_let_go
status: missing
title_en: Continue or let go
subtitle_en: Separate strong continues from weak hopes.
title_ru: Продолжать или отпустить
subtitle_ru: Отделяй уверенное продолжение от слабой надежды.

- taskId: continue_intro
  status: missing
  title_en: Strong enough
  phase: theory
  stepKind: learn
  runner: _world3BucketsIntroRunner
  runnerPrompt_en: Preflop starts by sorting the hand into a simple bucket.
  runnerSupport_en: Use premium, strong, medium, and trash before choosing. No charts needed at this stage.
  runnerQuestion_en: What should you name before the action?
  teachingStep0_title_en: Bucket first.
  teachingStep0_body_en: Name the hand bucket before choosing open, call, or fold. Keep it simple and repeatable.
  teachingStep0_title_ru: Сначала группа.
  teachingStep0_body_ru: До открытия, колла или паса сначала назови группу руки. Это делает решение чище и повторяемее.
  title_ru: Достаточно ли силы
  runnerPrompt_ru: Префлоп начинается с простой группы руки.
  runnerSupport_ru: Премиум, сильная, средняя или мусорная — этого уже достаточно для первого решения. Чарты на старте не нужны.
  runnerQuestion_ru: Что нужно назвать до действия?

- taskId: premium_continue
  status: missing
  title_en: Premium continue
  phase: drill
  stepKind: practice
  runner: _world3PremiumBucketRunner
  runnerPrompt_en: AA is a premium preflop hand.
  runnerSupport_en: Premium hands usually want to build the pot.
  runnerQuestion_en: Which bucket is AA?
  teachingStep0_title_en: Premium means top bucket.
  teachingStep0_body_en: AA starts in the premium bucket before context changes anything.
  teachingStep0_title_ru: Премиум — это верх.
  teachingStep0_body_ru: AA начинает в премиум-группе ещё до любого контекста. Такая рука не ищет оправдания, чтобы продолжать.
  title_ru: Премиум продолжает
  runnerPrompt_ru: AA — это премиум-рука на префлопе.
  runnerSupport_ru: Премиум-руки обычно хотят строить банк, а не прятаться.
  runnerQuestion_ru: К какой группе относится AA?

- taskId: medium_open
  status: missing
  title_en: Medium hand opens
  phase: drill
  stepKind: practice
  runner: _w1MediumOpenRunner
  runnerPrompt_en: BTN. Pot unopened. Hero holds K♦ Q♣.
  runnerSupport_en: Medium hand in the best seat. Raising is sharper than limping.
  runnerQuestion_en: What is the best first-in action?
  teachingStep0_title_en: Medium hand, good seat.
  teachingStep0_body_en: KQo is medium bucket. The Button is the best seat. Raise to open cleanly.
  teachingStep0_title_ru: Средняя рука, хорошее место.
  teachingStep0_body_ru: KQo — средняя группа. Баттон — лучшее место за столом. Здесь чистый рейз выглядит естественно.
  title_ru: Средняя рука открывает
  runnerPrompt_ru: Баттон. Банк не открыт. У тебя K♦ Q♣.
  runnerSupport_ru: Средняя рука в лучшем месте за столом чаще открывается, чем заходит пассивно.
  runnerQuestion_ru: Какое первое действие здесь лучше всего?

- taskId: weak_let_go
  status: missing
  title_en: Weak let go
  phase: drill
  stepKind: practice
  runner: _world3WeakFacingFoldRunner
  runnerPrompt_en: CO opened. Hero is BTN with J8o.
  runnerSupport_en: Position helps, but this hand is still too weak to continue.
  runnerQuestion_en: What is the clean response?
  teachingStep0_title_en: Position is not a free pass.
  teachingStep0_body_en: J8o still folds when the hand bucket is too weak.
  teachingStep0_title_ru: Позиция — не индульгенция.
  teachingStep0_body_ru: J8o всё равно идёт в пас, если рука слишком слаба для продолжения. Надежда без опоры здесь не помогает.
  title_ru: Слабое лучше отпустить
  runnerPrompt_ru: CO открылся. Ты на баттоне с J8o.
  runnerSupport_ru: Позиция помогает, но эта рука всё ещё слишком слаба для продолжения.
  runnerQuestion_ru: Какой ответ здесь будет самым чистым?

- taskId: medium_call_or_fold
  status: missing
  title_en: Medium facing open
  phase: drill
  stepKind: practice
  runner: _world3PlayableCallRunner
  runnerPrompt_en: CO opened. Hero is BTN with KQo.
  runnerSupport_en: Playable hand in position: call keeps the hand in.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Playable and in position.
  teachingStep0_body_en: KQo can call a simple open when hero acts after CO.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo может просто коллировать открытие, когда ты действуешь после CO. Это уже не надежда, а нормальное продолжение.
  title_ru: Средняя рука против открытия
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может спокойно остаться в раздаче через колл.
  runnerQuestion_ru: Какой ответ здесь самый простой?

- taskId: continue_recap
  status: missing
  title_en: Continue recap
  phase: review
  stepKind: review
  runner: _world3FacingOpenRecapRunner
  runnerPrompt_en: Lesson learned: facing an open creates a price.
  runnerSupport_en: Playable hands can call; weak hands can still fold.
  runnerQuestion_en: What did the opener create?
  teachingStep0_title_en: Facing-open checklist.
  teachingStep0_body_en: Read the hand bucket, your position, and the price.
  teachingStep0_title_ru: Проверка против открытия.
  teachingStep0_body_ru: Смотри на группу руки, свою позицию и цену входа. Так сильное продолжение и слабая надежда перестают путаться.
  title_ru: Повтор по продолжению
  runnerPrompt_ru: Главная мысль урока: открытие до тебя создаёт цену входа.
  runnerSupport_ru: Играбельные руки могут коллировать, а слабые спокойно уходят в пас.
  runnerQuestion_ru: Что создал рейз до тебя?

## lesson hand_discipline_apply
status: landed_or_partial
title_en: Discipline at the table
subtitle_en: Bucket, seat, and frame — then the action is simple.
title_ru: Дисциплина за столом
subtitle_ru: Сначала группа руки, потом место и ситуация. Дальше решение проще.

- taskId: apply_intro
  status: landed_or_partial
  title_en: Three-step habit
  phase: theory
  stepKind: learn
  runner: _w1DisciplineApplyIntroRunner
  runnerPrompt_en: Three steps make the decision easier.
  runnerSupport_en: Bucket the hand, read the seat, read the frame — then act. No chart memorization required.
  runnerQuestion_en: What order helps most?
  teachingStep0_title_en: Bucket, seat, frame.
  teachingStep0_body_en: Name the hand bucket. Check the seat. Read who acted first.
  teachingStep0_title_ru: Группа, место, ситуация.
  teachingStep0_body_ru: Сначала назови группу руки, потом посмотри на место за столом и уже после этого на ситуацию. Такой порядок делает решение заметно проще.
  title_ru: Привычка в три шага
  runnerPrompt_ru: Иди по порядку: группа руки, место, ситуация, потом действие.
  runnerSupport_ru: Этот каркас убирает суету: сначала пойми, что за рука и где ты сидишь, а потом решай, стоит ли входить в игру.
  runnerQuestion_ru: Какой порядок здесь самый чистый?

- taskId: apply_utg_fold
  status: landed_or_partial
  title_en: UTG, trash hand
  phase: drill
  stepKind: fixMistakes
  runner: _w1DisciplineApplyEarlyFoldRunner
  runnerPrompt_en: UTG. Pot unopened. Hero holds 8♠ 4♦.
  runnerSupport_en: Early position, trash bucket. Discipline says fold.
  runnerQuestion_en: What is the clean action?
  teachingStep0_title_en: Trash in early seat.
  teachingStep0_body_en: 8♠4♦ from UTG is clear trash. No context rescues it.
  teachingStep0_title_ru: Мусор в ранней позиции.
  teachingStep0_body_ru: 8♠4♦ из UTG — это чистый мусор. Никакой контекст здесь не обязан спасать такую руку.
  title_ru: UTG, мусорная рука
  runnerPrompt_ru: Ранняя позиция плюс мусорная рука редко требуют героизма.
  runnerSupport_ru: Не усложняй спот. Если рука слабая и ты говоришь первым, фолд сохраняет фишки и внимание.
  runnerQuestion_ru: Какое действие здесь самое чистое?

- taskId: apply_btn_open
  status: landed_or_partial
  title_en: BTN, strong hand
  phase: drill
  stepKind: fixMistakes
  runner: _w1DisciplineApplyLateOpenRunner
  runnerPrompt_en: BTN. Pot unopened. Hero holds A♠ J♦.
  runnerSupport_en: Late position, strong hand, no one entered. Clean open.
  runnerQuestion_en: What is the clean action?
  teachingStep0_title_en: Strong hand, good seat.
  teachingStep0_body_en: AJo is a strong bucket. BTN acts last. Pot is clean. Open.
  teachingStep0_title_ru: Сильная рука, хорошее место.
  teachingStep0_body_ru: AJo — это сильная группа. Баттон действует позже остальных. Банк чистый, значит открытие выглядит естественно.
  title_ru: Баттон, сильная рука
  runnerPrompt_ru: Сильная рука на баттоне любит инициативу.
  runnerSupport_ru: Когда до тебя все выбросили, поздняя позиция и хорошая рука дают чистый повод открыть раздачу.
  runnerQuestion_ru: Какое действие здесь самое чистое?

- taskId: apply_hj_decision
  status: landed_or_partial
  title_en: HJ, medium hand
  phase: drill
  stepKind: fixMistakes
  runner: _w1DisciplineApplyEarlyFoldRunner
  runnerPrompt_en: UTG. Pot unopened. Hero holds 8♠ 4♦.
  runnerSupport_en: Early position, trash bucket. Discipline says fold.
  runnerQuestion_en: What is the clean action?
  teachingStep0_title_en: Trash in early seat.
  teachingStep0_body_en: 8♠4♦ from UTG is clear trash. No context rescues it.
  teachingStep0_title_ru: Средняя рука просит честности.
  teachingStep0_body_ru: Средняя рука в неудобной ситуации не обязана продолжать только потому, что выглядит знакомо. Сначала каркас, потом амбиции.
  title_ru: HJ, средняя рука
  runnerPrompt_ru: Средняя рука требует оценки ситуации, а не игры на автопилоте.
  runnerSupport_ru: Здесь важно не упрямство, а трезвый каркас: группа руки, место и ситуация должны дать чистую причину продолжать.
  runnerQuestion_ru: Какое решение здесь выглядит наиболее дисциплинированным?

- taskId: apply_recap
  status: landed_or_partial
  title_en: Discipline holds
  phase: review
  stepKind: proveIt
  runner: _world3DominatedRecapRunner
  runnerPrompt_en: Lesson learned: familiar cards still need context.
  runnerSupport_en: Do not continue just because one card looks high.
  runnerQuestion_en: What should weak familiar hands avoid?
  teachingStep0_title_en: Trouble-hand checklist.
  teachingStep0_body_en: High card alone is not enough. Read the opener and bucket.
  teachingStep0_title_ru: Проверка проблемной руки.
  teachingStep0_body_ru: Одной высокой карты мало. Сначала смотри на открытие соперника и на группу руки, а уже потом решай продолжать ли.
  title_ru: Дисциплина держится
  runnerPrompt_ru: Собери весь каркас в один спокойный префлоп-ритм.
  runnerSupport_ru: Хорошая дисциплина не ищет подвигов. Она снова и снова приводит к чистому решению по понятным причинам.
  runnerQuestion_ru: Чего должны избегать знакомые, но слабые руки?

## lesson discipline_checkpoint
status: missing
title_en: Hand discipline checkpoint
subtitle_en: Name the bucket, then protect your stack.
title_ru: Контрольная по дисциплине рук
subtitle_ru: Сначала назови группу руки, потом защищай стек.

- taskId: checkpoint_intro
  status: missing
  title_en: Bucket first
  phase: theory
  stepKind: learn
  runner: _world3BucketsRecapRunner
  runnerPrompt_en: Lesson learned: bucket the hand before the action.
  runnerSupport_en: Premium, strong, medium, or trash is the first preflop read.
  runnerQuestion_en: What is the first preflop habit?
  teachingStep0_title_en: Bucket checklist.
  teachingStep0_body_en: Name the hand bucket, then read position and action frame.
  teachingStep0_title_ru: Проверка по группе.
  teachingStep0_body_ru: Сначала назови группу руки, потом смотри на позицию и на рамку действия. Это и есть первый префлоп-ритм.
  title_ru: Сначала группа
  runnerPrompt_ru: Главная мысль урока: группу руки нужно назвать ещё до действия.
  runnerSupport_ru: Премиум, сильная, средняя или мусорная — это первый префлоп-сигнал.
  runnerQuestion_ru: Какая привычка на префлопе идёт первой?

- taskId: checkpoint_premium
  status: missing
  title_en: Premium hand
  phase: drill
  stepKind: practice
  runner: _world3PremiumBucketRunner
  runnerPrompt_en: AA is a premium preflop hand.
  runnerSupport_en: Premium hands usually want to build the pot.
  runnerQuestion_en: Which bucket is AA?
  teachingStep0_title_en: Premium means top bucket.
  teachingStep0_body_en: AA starts in the premium bucket before context changes anything.
  teachingStep0_title_ru: Премиум — это верхняя группа.
  teachingStep0_body_ru: AA начинает в премиум-группе ещё до контекста. Такая рука обычно хочет строить банк, а не отказываться от инициативы.
  title_ru: Премиум-рука
  runnerPrompt_ru: AA — это премиум-рука на префлопе.
  runnerSupport_ru: Премиум-руки чаще всего хотят вложить деньги в банк и сохранить инициативу.
  runnerQuestion_ru: К какой группе относится AA?

- taskId: checkpoint_fold
  status: missing
  title_en: Disciplined fold
  phase: drill
  stepKind: practice
  runner: _world3DominatedFoldRunner
  runnerPrompt_en: CO opened. Hero is BTN with A7o.
  runnerSupport_en: This can be behind stronger aces, so folding is clean.
  runnerQuestion_en: What is the disciplined response?
  teachingStep0_title_en: Weak ace caution.
  teachingStep0_body_en: A7o can be dominated when someone opened first.
  teachingStep0_title_ru: Осторожно со слабым тузом.
  teachingStep0_body_ru: A7o легко оказывается под доминацией, если кто-то уже открылся. Пас здесь чаще защищает стек, чем лишает тебя шанса.
  title_ru: Дисциплинированный пас
  runnerPrompt_ru: CO открылся. Ты на баттоне с A7o.
  runnerSupport_ru: Такая рука часто уже позади более сильных тузов, поэтому пас здесь выглядит чисто.
  runnerQuestion_ru: Какой ответ здесь будет дисциплинированным?

- taskId: checkpoint_borderline_continue
  status: missing
  title_en: Borderline continue
  phase: drill
  stepKind: practice
  runner: _world3PlayableCallRunner
  runnerPrompt_en: CO opened. Hero is BTN with KQo.
  runnerSupport_en: Playable hand in position: call keeps the hand in.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Playable and in position.
  teachingStep0_body_en: KQo can call a simple open when hero acts after CO.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo может спокойно продолжать простое открытие, когда ты действуешь после CO. Здесь рука и место работают вместе.
  title_ru: Пограничное продолжение
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может оставаться в раздаче через колл.
  runnerQuestion_ru: Какой ответ здесь будет самым простым?

- taskId: checkpoint_table_discipline
  status: missing
  title_en: Real-table discipline read
  phase: drill
  stepKind: practice
  runner: _w2DisciplineTableNoticeRunner
  runnerPrompt_en: Real table. Hero is HJ with J4o and the pot is unopened.
  runnerSupport_en: Use the bucket first before hope or curiosity shows up.
  runnerQuestion_en: What is the clean discipline read?
  teachingStep0_title_en: Bucket before curiosity.
  teachingStep0_body_en: Some live-table leaks start because a weak hand looks tempting. Name the bucket first, then act with discipline.
  teachingStep0_title_ru: Группа важнее любопытства.
  teachingStep0_body_ru: Некоторые live-утечки начинаются с того, что слабая рука вдруг кажется соблазнительной. Сначала назови группу, а потом действуй дисциплинированно.
  title_ru: Дисциплина за живым столом
  runnerPrompt_ru: Живой стол. Ты в HJ с J4o, банк не открыт.
  runnerSupport_ru: Сначала определи группу руки, пока надежда и любопытство не полезли вперёд.
  runnerQuestion_ru: Какое чтение здесь будет самым чистым?

- taskId: checkpoint_review
  status: missing
  title_en: Discipline recap
  phase: review
  stepKind: proveIt
  runner: _w1DisciplineCheckpointRunner
  runnerPrompt_en: Lesson learned: discipline comes before action.
  runnerSupport_en: Next world adds position: the same bucket can change action by seat.
  runnerQuestion_en: What comes right after naming the bucket?
  teachingStep0_title_en: W1 to W2 bridge.
  teachingStep0_body_en: Bucket first. Position second. Then choose the action frame.
  teachingStep0_title_ru: Мост к следующему миру.
  teachingStep0_body_ru: Сначала группа руки. Потом позиция. И только после этого рамка действия. Этот порядок понесёт тебя дальше.
  title_ru: Повтор по дисциплине
  runnerPrompt_ru: Главная мысль урока: дисциплина приходит раньше действия.
  runnerSupport_ru: Следующий мир добавит позицию: та же группа руки может играться по-разному в разных местах.
  runnerQuestion_ru: Что идёт сразу после группы руки?


---

## Pack: world_3

# world_3 RU Translation Pack

Status: GENERATED
World number: 3
EN title: Position Thinking
EN subtitle: See why seat order changes hand value and comfort.
title_ru: Мышление позицией
subtitle_ru: Почувствуй, почему порядок мест меняет силу руки и комфорт.

## Coverage
- Lessons: 0/6
- Tasks: 13/38
- Runner prompts: 13/38
- Runner supports: 13/38
- Runner questions: 13/38
- Teaching step titles: 0/39
- Teaching step bodies: 0/39

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson position_six_seats
status: missing
title_en: The 6 positions
subtitle_en: Recognize UTG, HJ, CO, BTN, SB, and BB.
title_ru: Шесть позиций
subtitle_ru: Научись узнавать UTG, HJ, CO, BTN, SB и BB.

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
  teachingStep0_body_en: UTG, HJ, CO, BTN, SB, and BB describe table position.
  teachingStep0_title_ru: У мест есть имена.
  teachingStep0_body_ru: UTG, HJ, CO, BTN, SB и BB — это названия позиций за столом. Они сразу объясняют, где именно ты сидишь.
  teachingStep1_title_en: Position changes information.
  teachingStep1_body_en: Late seats see more actions before they decide.
  teachingStep1_title_ru: Позиция меняет информацию.
  teachingStep1_body_ru: Поздние места успевают увидеть больше действий до своего решения. Поэтому одно и то же место за столом уже даёт разный комфорт.
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
  teachingStep0_title_ru: BTN отмечает баттон.
  teachingStep0_body_ru: Баттон показывает место дилера в этой раздаче. После флопа это обычно самое позднее место по действию.
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
  teachingStep0_title_ru: UTG — ранняя позиция.
  teachingStep0_body_ru: UTG действует первым на префлопе и получает меньше всего информации. Поэтому к этой позиции нужен больший запас аккуратности.
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
  teachingStep0_title_ru: CO сидит перед BTN.
  teachingStep0_body_ru: Cutoff — это место прямо перед баттоном. Оно уже позднее, но всё ещё не самое последнее.
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
  teachingStep0_title_ru: Поздно — значит информированнее.
  teachingStep0_body_ru: Поздние позиции успевают увидеть больше чужих решений. Это и делает их удобнее для игры.
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
  teachingStep0_title_ru: Ранние места решают раньше.
  teachingStep0_body_ru: UTG действует ещё до того, как большинство игроков показали свои намерения. Поэтому ранние позиции всегда жёстче к руке.
  title_ru: Ранние и поздние места
  runnerPrompt_ru: Ранние места решают вслепую чаще, поздние видят больше.
  runnerSupport_ru: UTG действует почти сразу, а баттон обычно получает самую полную картину перед решением.
  runnerQuestion_ru: Какое место здесь раннее на префлопе?

- taskId: seat_order_decision
  status: missing
  title_en: Who acts earlier?
  phase: drill
  stepKind: practice
  runner: _earlyLatePositionRunner
  runnerPrompt_en: Early seats act with less information than late seats.
  runnerSupport_en: UTG is early. BTN is late.
  runnerQuestion_en: Which seat is early preflop?
  teachingStep0_title_en: Early seats decide sooner.
  teachingStep0_body_en: UTG acts before seeing what most players will do.
  teachingStep0_title_ru: Ранние места решают раньше.
  teachingStep0_body_ru: Когда ты говоришь первым, у тебя меньше подсказок и меньше права на надежду. Поэтому ранняя позиция всегда требует большей силы.
  title_ru: Кто действует раньше?
  runnerPrompt_ru: Ранние места принимают решение с меньшим количеством информации, чем поздние.
  runnerSupport_ru: UTG — ранняя позиция. BTN — поздняя.
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
  teachingStep0_title_ru: Короткая проверка по позиции.
  teachingStep0_body_ru: Назови место, посмотри, кто действует раньше, и только потом оцени руку. Так позиция перестаёт быть абстракцией.
  title_ru: Повтор по позициям
  runnerPrompt_ru: Главная мысль проста: позиция меняет не силу карты, а удобство решения.
  runnerSupport_ru: Ранние места требуют большей аккуратности, поздние дают больше информации и свободы.
  runnerQuestion_ru: Какое место здесь действует позже остальных после флопа?

## lesson button_advantage
status: missing
title_en: Button advantage
subtitle_en: The Button often acts last and sees more.
title_ru: Преимущество баттона
subtitle_ru: Баттон часто действует последним и видит больше остальных.

- taskId: button_intro
  status: missing
  title_en: Best seat
  phase: theory
  stepKind: learn
  runner: _world2PositionIntroRunner
  runnerPrompt_en: The same hand feels different from early and late seats.
  runnerSupport_en: Late seats act after seeing more decisions.
  runnerQuestion_en: Why can late position help?
  teachingStep0_title_en: Position is information.
  teachingStep0_body_en: Early seats decide sooner. Late seats see more before acting.
  teachingStep0_title_ru: Позиция — это информация.
  teachingStep0_body_ru: Ранние места решают раньше. Поздние сначала смотрят на остальных. Поэтому одна и та же рука ощущается по-разному.
  title_ru: Лучшее место
  runnerPrompt_ru: Одна и та же рука ощущается по-разному в ранней и поздней позиции.
  runnerSupport_ru: Поздние места принимают решение уже после того, как увидели больше чужих действий.
  runnerQuestion_ru: Почему поздняя позиция вообще помогает?

- taskId: find_button
  status: missing
  title_en: Tap BTN
  phase: drill
  stepKind: practice
  runner: _buttonSeatRunner
  runnerPrompt_en: Button is the dealer seat in this hand.
  runnerSupport_en: Tap BTN.
  runnerQuestion_en: Tap the Button.
  teachingStep0_title_en: BTN marks the Button.
  teachingStep0_body_en: The dealer button shows the late seat for this hand.
  teachingStep0_title_ru: BTN отмечает баттон.
  teachingStep0_body_ru: Баттон показывает место дилера в этой раздаче. После флопа он часто закрывает действие.
  title_ru: Найди BTN
  runnerPrompt_ru: Баттон показывает место дилера в этой раздаче.
  runnerSupport_ru: Нажми на BTN.
  runnerQuestion_ru: Где здесь баттон?

- taskId: button_open
  status: missing
  title_en: BTN first-in open
  phase: drill
  stepKind: practice
  runner: _world3ButtonOpenRunner
  runnerPrompt_en: Folded to BTN with KTs.
  runnerSupport_en: First in and late position: opening is the clean action.
  runnerQuestion_en: What is the simple first-in action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Играбельная рука поздно.
  teachingStep0_body_ru: KTs на баттоне спокойно открывается, если до тебя никто не вошёл в банк. Позиция здесь работает на тебя.
  title_ru: Баттон открывает первым
  runnerPrompt_ru: До баттона все выбросили, у тебя KTs.
  runnerSupport_ru: Поздняя позиция и вход первым делают открытие самым чистым действием.
  runnerQuestion_ru: Какое первое действие здесь выглядит самым простым?

- taskId: button_last
  status: missing
  title_en: Acts last
  phase: drill
  stepKind: practice
  runner: _postflopButtonActorRunner
  runnerPrompt_en: After the flop, Button often acts last.
  runnerSupport_en: Tap BTN.
  runnerQuestion_en: Tap the last postflop actor.
  teachingStep0_title_en: Postflop order changes.
  teachingStep0_body_en: After the flop, blinds act early and Button often acts last.
  teachingStep0_title_ru: Порядок после флопа меняется.
  teachingStep0_body_ru: После флопа блайнды действуют раньше, а баттон часто заканчивает круг последним. Это и есть его главное удобство.
  title_ru: Действует последним
  runnerPrompt_ru: После флопа баттон часто действует последним.
  runnerSupport_ru: Нажми на BTN.
  runnerQuestion_ru: Какое место здесь закрывает действие после флопа?

- taskId: button_vs_cutoff
  status: missing
  title_en: BTN vs CO
  phase: drill
  stepKind: practice
  runner: _latePositionRunner
  runnerPrompt_en: Late seats see more actions before deciding.
  runnerSupport_en: Button is the clearest late seat.
  runnerQuestion_en: Which seat acts latest after the flop?
  teachingStep0_title_en: Late means more information.
  teachingStep0_body_en: Late seats see more choices before they decide.
  teachingStep0_title_ru: Поздно — значит видеть больше.
  teachingStep0_body_ru: И баттон, и cutoff поздние, но баттон обычно получает ещё больше информации. Это и делает его лучшим местом.
  title_ru: Баттон против cutoff
  runnerPrompt_ru: Поздние места видят больше действий до решения.
  runnerSupport_ru: Баттон — самый чистый пример поздней позиции.
  runnerQuestion_ru: Какое место здесь действует позже остальных после флопа?

- taskId: button_recap
  status: missing
  title_en: Button recap
  phase: review
  stepKind: review
  runner: _world2PositionRecapRunner
  runnerPrompt_en: Lesson learned: hand value depends on seat context.
  runnerSupport_en: A later seat usually has more information before choosing.
  runnerQuestion_en: Which seat usually sees more first?
  teachingStep0_title_en: Position-value checklist.
  teachingStep0_body_en: Name the seat, note who acts first, then compare the hand.
  teachingStep0_title_ru: Проверка ценности позиции.
  teachingStep0_body_ru: Сначала назови место, потом посмотри, кто действует раньше, и только потом оценивай удобство руки. Так баттон перестаёт быть просто значком.
  title_ru: Повтор по баттону
  runnerPrompt_ru: Главная мысль урока: ценность руки зависит от места за столом.
  runnerSupport_ru: Более поздняя позиция обычно даёт больше информации до решения.
  runnerQuestion_ru: Какое место чаще всего видит больше остальных?

## lesson early_vs_late
status: missing
title_en: Early vs late
subtitle_en: Early seats decide with less information.
title_ru: Ранние и поздние места
subtitle_ru: Ранние позиции принимают решение с меньшим количеством информации.

- taskId: w2_position_intro
  status: missing
  title_en: Info changes
  phase: theory
  stepKind: learn
  runner: _world2PositionIntroRunner
  runnerPrompt_en: The same hand feels different from early and late seats.
  runnerSupport_en: Late seats act after seeing more decisions.
  runnerQuestion_en: Why can late position help?
  teachingStep0_title_en: Position is information.
  teachingStep0_body_en: Early seats decide sooner. Late seats see more before acting.
  teachingStep0_title_ru: Позиция — это информация.
  teachingStep0_body_ru: Ранние места действуют раньше. Поздние успевают увидеть больше чужих решений. Поэтому одна и та же рука играет по-разному.
  title_ru: Информация меняется
  runnerPrompt_ru: Одна и та же рука ощущается по-разному в ранней и поздней позиции.
  runnerSupport_ru: Поздние места принимают решение уже после того, как увидели больше действий.
  runnerQuestion_ru: Почему поздняя позиция вообще может помочь?

- taskId: w2_late_position
  status: missing
  title_en: Late seat
  phase: drill
  stepKind: practice
  runner: _latePositionRunner
  runnerPrompt_en: Late seats see more actions before deciding.
  runnerSupport_en: Button is the clearest late seat.
  runnerQuestion_en: Which seat acts latest after the flop?
  teachingStep0_title_en: Late means more information.
  teachingStep0_body_en: Late seats see more choices before they decide.
  teachingStep0_title_ru: Поздно — значит видеть больше.
  teachingStep0_body_ru: Поздние места успевают собрать больше подсказок до своего решения. Это и создаёт их преимущество.
  title_ru: Поздняя позиция
  runnerPrompt_ru: Поздние места видят больше действий до решения.
  runnerSupport_ru: Баттон — самый наглядный пример поздней позиции.
  runnerQuestion_ru: Какое место здесь действует позже остальных после флопа?

- taskId: w2_early_position
  status: missing
  title_en: Early seat
  phase: drill
  stepKind: practice
  runner: _earlyLatePositionRunner
  runnerPrompt_en: Early seats act with less information than late seats.
  runnerSupport_en: UTG is early. BTN is late.
  runnerQuestion_en: Which seat is early preflop?
  teachingStep0_title_en: Early seats decide sooner.
  teachingStep0_body_en: UTG acts before seeing what most players will do.
  teachingStep0_title_ru: Ранние места решают раньше.
  teachingStep0_body_ru: UTG действует ещё до того, как большинство игроков что-то показали. Поэтому ранняя позиция всегда требует большей осторожности.
  title_ru: Ранняя позиция
  runnerPrompt_ru: Ранние места принимают решение с меньшим количеством информации, чем поздние.
  runnerSupport_ru: UTG — ранняя позиция. BTN — поздняя.
  runnerQuestion_ru: Какое место здесь раннее на префлопе?

- taskId: early_pressure_choice
  status: missing
  title_en: Early pressure
  phase: drill
  stepKind: practice
  runner: _earlyLatePositionRunner
  runnerPrompt_en: Early seats act with less information than late seats.
  runnerSupport_en: UTG is early. BTN is late.
  runnerQuestion_en: Which seat is early preflop?
  teachingStep0_title_en: Early seats decide sooner.
  teachingStep0_body_en: UTG acts before seeing what most players will do.
  teachingStep0_title_ru: Раннее давление реально.
  teachingStep0_body_ru: Когда ты говоришь первым, ошибиться легче, потому что подсказок меньше. Поэтому ранняя позиция и давит сильнее.
  title_ru: Давление ранней позиции
  runnerPrompt_ru: Ранние места действуют с меньшим количеством информации, чем поздние.
  runnerSupport_ru: UTG — ранняя позиция. BTN — поздняя.
  runnerQuestion_ru: Какое место здесь раннее на префлопе?

- taskId: late_info_choice
  status: missing
  title_en: Late info edge
  phase: drill
  stepKind: practice
  runner: _latePositionRunner
  runnerPrompt_en: Late seats see more actions before deciding.
  runnerSupport_en: Button is the clearest late seat.
  runnerQuestion_en: Which seat acts latest after the flop?
  teachingStep0_title_en: Late means more information.
  teachingStep0_body_en: Late seats see more choices before they decide.
  teachingStep0_title_ru: Поздняя позиция даёт край.
  teachingStep0_body_ru: Позднее место не делает руку сильнее само по себе, но даёт больше информации и чаще облегчает решение.
  title_ru: Преимущество поздней позиции
  runnerPrompt_ru: Поздние места видят больше действий до решения.
  runnerSupport_ru: Баттон — самый понятный пример места с информационным преимуществом.
  runnerQuestion_ru: Какое место здесь действует позже остальных после флопа?

- taskId: w2_position_recap
  status: missing
  title_en: Position recap
  phase: review
  stepKind: review
  runner: _world2PositionRecapRunner
  runnerPrompt_en: Lesson learned: hand value depends on seat context.
  runnerSupport_en: A later seat usually has more information before choosing.
  runnerQuestion_en: Which seat usually sees more first?
  teachingStep0_title_en: Position-value checklist.
  teachingStep0_body_en: Name the seat, note who acts first, then compare the hand.
  teachingStep0_title_ru: Проверка по позиции.
  teachingStep0_body_ru: Назови место, посмотри, кто действует раньше, и только потом сравни комфорт руки. Так раннее и позднее место читаются без путаницы.
  title_ru: Повтор по позиции
  runnerPrompt_ru: Главная мысль урока: ценность руки зависит от места за столом.
  runnerSupport_ru: Более поздняя позиция обычно даёт больше информации до решения.
  runnerQuestion_ru: Какое место чаще видит больше остальных?

## lesson same_hand_different_seat
status: missing
title_en: Same hand, different seat
subtitle_en: A seat can change how comfortable a hand is.
title_ru: Та же рука, другое место
subtitle_ru: Позиция может полностью поменять комфорт одной и той же руки.

- taskId: w3_same_hand_intro
  status: missing
  title_en: Context first
  phase: theory
  stepKind: learn
  runner: _world3SameHandIntroRunner
  runnerPrompt_en: The same hand can change action when the frame changes.
  runnerSupport_en: First in, facing open, and early position are different frames.
  runnerQuestion_en: What should you re-check?
  teachingStep0_title_en: No permanent answer.
  teachingStep0_body_en: Re-check bucket, seat, and whether someone already opened.
  teachingStep0_title_ru: У руки нет вечного ответа.
  teachingStep0_body_ru: Перед действием снова проверь группу руки, своё место и то, открылся ли кто-то уже до тебя. Контекст важнее привычки.
  title_ru: Сначала контекст
  runnerPrompt_ru: Одна и та же рука может играться по-разному, если меняется ситуация.
  runnerSupport_ru: Вход первым, игра против открытия и ранняя позиция — это разные рамки.
  runnerQuestion_ru: Что нужно перепроверить до действия?

- taskId: w3_same_hand_open
  status: missing
  title_en: Open frame
  phase: drill
  stepKind: practice
  runner: _world3ButtonOpenRunner
  runnerPrompt_en: Folded to BTN with KTs.
  runnerSupport_en: First in and late position: opening is the clean action.
  runnerQuestion_en: What is the simple first-in action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Играбельная рука поздно.
  teachingStep0_body_ru: KTs на баттоне спокойно открывается, если до тебя никто не вошёл в банк. Здесь и рука, и место работают вместе.
  title_ru: Та же рука открывает
  runnerPrompt_ru: До баттона все выбросили, у тебя KTs.
  runnerSupport_ru: Поздняя позиция и вход первым делают открытие самым чистым действием.
  runnerQuestion_ru: Какое первое действие здесь самое простое?

- taskId: w3_same_hand_call
  status: missing
  title_en: Call frame
  phase: drill
  stepKind: practice
  runner: _world3PlayableCallRunner
  runnerPrompt_en: CO opened. Hero is BTN with KQo.
  runnerSupport_en: Playable hand in position: call keeps the hand in.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Playable and in position.
  teachingStep0_body_en: KQo can call a simple open when hero acts after CO.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo можно просто коллировать открытие, когда ты действуешь после CO. Та же категория руки в новой рамке ведёт уже к другому действию.
  title_ru: Та же рука коллирует
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может спокойно остаться в раздаче через колл.
  runnerQuestion_ru: Какой ответ здесь будет самым простым?

- taskId: same_hand_early_fold
  status: missing
  title_en: Early seat fold
  phase: drill
  stepKind: practice
  runner: _world3PositionDisciplineRunner
  runnerPrompt_en: Unopened pot. Hero is early with ATo.
  runnerSupport_en: The same hand is less comfortable from early position.
  runnerQuestion_en: What is the disciplined action?
  teachingStep0_title_en: Same hand, worse seat.
  teachingStep0_body_en: Early position can turn a close hand into a fold.
  teachingStep0_title_ru: Та же рука, но место хуже.
  teachingStep0_body_ru: Ранняя позиция легко превращает пограничную руку в спокойный пас. Здесь комфорт руки уже совсем другой.
  title_ru: Та же рука уходит в пас
  runnerPrompt_ru: Банк не открыт. Ты в ранней позиции с ATo.
  runnerSupport_ru: Та же рука в ранней позиции чувствует себя заметно хуже.
  runnerQuestion_ru: Какое действие здесь будет дисциплинированным?

- taskId: same_hand_late_open
  status: missing
  title_en: Late seat open
  phase: drill
  stepKind: practice
  runner: _world3LateOpenRunner
  runnerPrompt_en: Unopened pot. Hero is late with ATo.
  runnerSupport_en: Late position supports a clean open with this playable hand.
  runnerQuestion_en: What is the simple action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Поздняя позиция облегчает решение.
  teachingStep0_body_ru: В поздней позиции ATo уже играет заметно комфортнее. Та же рука получает больше свободы просто из-за места.
  title_ru: Поздняя позиция открывает
  runnerPrompt_ru: Банк не открыт. Ты в поздней позиции с ATo.
  runnerSupport_ru: Поздняя позиция поддерживает чистое открытие с такой играбельной рукой.
  runnerQuestion_ru: Какое действие здесь выглядит самым простым?

- taskId: w3_same_hand_recap
  status: missing
  title_en: Frame recap
  phase: review
  stepKind: review
  runner: _world3SameHandRecapRunner
  runnerPrompt_en: Lesson learned: context can change the action.
  runnerSupport_en: A hand can open first in, call facing an open, or fold in a worse frame.
  runnerQuestion_en: What prevents one-hand-one-answer thinking?
  teachingStep0_title_en: Frame checklist.
  teachingStep0_body_en: Ask if the pot is unopened or if a raise already happened.
  teachingStep0_title_ru: Проверка по рамке.
  teachingStep0_body_ru: Сначала спроси, банк уже открыт или нет, и только потом ищи действие. Так исчезает ловушка мышления «одна рука — один ответ».
  title_ru: Повтор по рамке
  runnerPrompt_ru: Главная мысль урока: контекст меняет действие той же самой руки.
  runnerSupport_ru: Одна и та же рука может открыть первой, коллировать против открытия или уйти в пас в худшей рамке.
  runnerQuestion_ru: Что защищает от мышления «одна рука — один ответ»?

## lesson position_apply
status: missing
title_en: Position at the table
subtitle_en: Seat shapes the decision before anything else.
title_ru: Позиция за столом
subtitle_ru: Место за столом меняет решение ещё до действия.

- taskId: position_apply_intro
  status: landed_or_partial
  title_en: Position shapes action
  phase: theory
  stepKind: learn
  runner: _w3PositionApplyIntroRunner
  runnerPrompt_en: Position tells you how comfortable a hand is before you act.
  runnerSupport_en: BTN is the best seat. UTG needs stronger hands to open. No charts needed yet.
  runnerQuestion_en: Why does position matter at the table?
  teachingStep0_title_en: Seat, then hand.
  teachingStep0_body_en: Check where you sit before deciding what to do with the hand.
  teachingStep0_title_ru: Сначала место, потом рука.
  teachingStep0_body_ru: Сначала посмотри, где ты сидишь, и только потом решай, что делать с рукой.
  title_ru: Позиция меняет решение
  runnerPrompt_ru: Позиция заранее подсказывает, насколько руке будет удобно.
  runnerSupport_ru: Баттон даёт больше свободы, ранние места требуют большей аккуратности. Чарты пока не нужны.
  runnerQuestion_ru: Почему позиция так важна за столом?

- taskId: position_apply_btn_open
  status: landed_or_partial
  title_en: BTN: open strong hand
  phase: drill
  stepKind: practice
  runner: _world3ButtonOpenRunner
  runnerPrompt_en: Folded to BTN with KTs.
  runnerSupport_en: First in and late position: opening is the clean action.
  runnerQuestion_en: What is the simple first-in action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Играбельная рука в поздней позиции.
  teachingStep0_body_ru: KTs на баттоне спокойно играет открытием, если до тебя никто не вошёл в банк.
  title_ru: Баттон: открыть сильную руку
  runnerPrompt_ru: До баттона все выбросили, у тебя KTs.
  runnerSupport_ru: Поздняя позиция и вход первым делают открытие самым чистым продолжением.
  runnerQuestion_ru: Какое здесь самое простое первое действие?

- taskId: position_apply_late_open
  status: landed_or_partial
  title_en: Late: open or limp?
  phase: drill
  stepKind: practice
  runner: _world3LateOpenRunner
  runnerPrompt_en: Unopened pot. Hero is late with ATo.
  runnerSupport_en: Late position supports a clean open with this playable hand.
  runnerQuestion_en: What is the simple action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Играбельная рука в поздней позиции.
  teachingStep0_body_ru: Поздняя позиция делает такую руку удобной для простого открытия, а не для пассивного входа.
  title_ru: Поздняя позиция: открыть или зайти пассивно?
  runnerPrompt_ru: Банк не открыт. Ты в поздней позиции с ATo.
  runnerSupport_ru: В поздней позиции такая рука спокойно тянет на открытие, а не на пассивный вход.
  runnerQuestion_ru: Какое действие здесь выглядит самым простым?

- taskId: position_apply_early_fold
  status: landed_or_partial
  title_en: Early: same hand folds
  phase: drill
  stepKind: fixMistakes
  runner: _world3PositionDisciplineRunner
  runnerPrompt_en: Unopened pot. Hero is early with ATo.
  runnerSupport_en: The same hand is less comfortable from early position.
  runnerQuestion_en: What is the disciplined action?
  teachingStep0_title_en: Same hand, worse seat.
  teachingStep0_body_en: Early position can turn a close hand into a fold.
  teachingStep0_title_ru: Та же рука, но место хуже.
  teachingStep0_body_ru: Ранняя позиция часто превращает пограничную руку в спокойный пас.
  title_ru: Ранняя позиция: та же рука уходит в пас
  runnerPrompt_ru: Банк не открыт. Ты в ранней позиции с ATo.
  runnerSupport_ru: Та же рука в ранней позиции чувствует себя заметно хуже и не требует упрямства.
  runnerQuestion_ru: Какое действие здесь будет дисциплинированным?

- taskId: position_apply_hj_fold
  status: landed_or_partial
  title_en: HJ: discipline hold
  phase: drill
  stepKind: fixMistakes
  runner: _world3PositionDisciplineRunner
  runnerPrompt_en: Unopened pot. Hero is early with ATo.
  runnerSupport_en: The same hand is less comfortable from early position.
  runnerQuestion_en: What is the disciplined action?
  teachingStep0_title_en: Same hand, worse seat.
  teachingStep0_body_en: Early position can turn a close hand into a fold.
  teachingStep0_title_ru: Та же рука, но место хуже.
  teachingStep0_body_ru: Если место за столом неудобное, даже знакомая рука не обязана продолжать.
  title_ru: HJ: держим дисциплину
  runnerPrompt_ru: Банк не открыт. Ты в HJ с ATo.
  runnerSupport_ru: Даже знакомая рука не обязана продолжать, если место за столом делает спот неудобным.
  runnerQuestion_ru: Какое действие здесь будет дисциплинированным?

- taskId: position_apply_recap
  status: landed_or_partial
  title_en: Position apply recap
  phase: review
  stepKind: proveIt
  runner: _world3PositionRecapRunner
  runnerPrompt_en: Lesson learned: position changes preflop comfort.
  runnerSupport_en: Late helps. Early demands stronger buckets and cleaner frames.
  runnerQuestion_en: What should you check after the bucket?
  teachingStep0_title_en: Position checklist.
  teachingStep0_body_en: Bucket the hand, then ask if the seat helps or hurts.
  teachingStep0_title_ru: Короткая проверка по позиции.
  teachingStep0_body_ru: Сначала определи группу руки, потом спроси себя, помогает тебе это место или мешает.
  title_ru: Повтор по позиции
  runnerPrompt_ru: Главная мысль проста: позиция меняет комфорт ещё до действия.
  runnerSupport_ru: Поздние места помогают, ранние требуют более крепкой руки и более чистой причины продолжать.
  runnerQuestion_ru: На что нужно смотреть сразу после группы руки?

## lesson position_checkpoint
status: missing
title_en: Position checkpoint
subtitle_en: Use seat order before choosing an action.
title_ru: Контрольная по позиции
subtitle_ru: Сначала прочитай порядок мест, а уже потом выбирай действие.

- taskId: position_checkpoint_intro
  status: missing
  title_en: Seat before action
  phase: theory
  stepKind: learn
  runner: _world2PositionIntroRunner
  runnerPrompt_en: The same hand feels different from early and late seats.
  runnerSupport_en: Late seats act after seeing more decisions.
  runnerQuestion_en: Why can late position help?
  teachingStep0_title_en: Position is information.
  teachingStep0_body_en: Early seats decide sooner. Late seats see more before acting.
  teachingStep0_title_ru: Позиция — это информация.
  teachingStep0_body_ru: Ранние места решают раньше, поздние видят больше. Поэтому позицию нужно читать ещё до самого действия.
  title_ru: Место раньше действия
  runnerPrompt_ru: Одна и та же рука ощущается по-разному в ранней и поздней позиции.
  runnerSupport_ru: Поздние места успевают увидеть больше решений перед своим ходом.
  runnerQuestion_ru: Почему поздняя позиция вообще может помогать?

- taskId: position_checkpoint_late_open
  status: missing
  title_en: Late: open or limp?
  phase: drill
  stepKind: practice
  runner: _world3LateOpenRunner
  runnerPrompt_en: Unopened pot. Hero is late with ATo.
  runnerSupport_en: Late position supports a clean open with this playable hand.
  runnerQuestion_en: What is the simple action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Поздняя рука открывает.
  teachingStep0_body_ru: В поздней позиции ATo уже может спокойно идти в открытие, если банк не открыт. Здесь место помогает руке.
  title_ru: Поздняя: открыть или зайти пассивно?
  runnerPrompt_ru: Банк не открыт. Ты в поздней позиции с ATo.
  runnerSupport_ru: Поздняя позиция поддерживает чистое открытие с такой играбельной рукой.
  runnerQuestion_ru: Какое действие здесь самое простое?

- taskId: position_checkpoint_early_fold
  status: missing
  title_en: Early: same hand folds
  phase: drill
  stepKind: practice
  runner: _world3PositionDisciplineRunner
  runnerPrompt_en: Unopened pot. Hero is early with ATo.
  runnerSupport_en: The same hand is less comfortable from early position.
  runnerQuestion_en: What is the disciplined action?
  teachingStep0_title_en: Same hand, worse seat.
  teachingStep0_body_en: Early position can turn a close hand into a fold.
  teachingStep0_title_ru: Та же рука, но место хуже.
  teachingStep0_body_ru: Ранняя позиция может превратить пограничную руку в пас. Здесь уже важно не упрямство, а дисциплина.
  title_ru: Ранняя: та же рука уходит в пас
  runnerPrompt_ru: Банк не открыт. Ты в ранней позиции с ATo.
  runnerSupport_ru: Та же рука в ранней позиции чувствует себя заметно хуже.
  runnerQuestion_ru: Какое действие здесь будет дисциплинированным?

- taskId: position_checkpoint_btn_call
  status: missing
  title_en: BTN: callable spot
  phase: drill
  stepKind: practice
  runner: _world3PlayableCallRunner
  runnerPrompt_en: CO opened. Hero is BTN with KQo.
  runnerSupport_en: Playable hand in position: call keeps the hand in.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Playable and in position.
  teachingStep0_body_en: KQo can call a simple open when hero acts after CO.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo может просто коллировать простое открытие, когда ты действуешь после CO. Здесь место помогает руке продолжать.
  title_ru: Баттон: колл в удобной рамке
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может остаться в раздаче через спокойный колл.
  runnerQuestion_ru: Какой ответ здесь будет самым простым?

- taskId: position_checkpoint_table_notice
  status: missing
  title_en: Real-table seat read
  phase: drill
  stepKind: practice
  runner: _w3TablePositionNoticeRunner
  runnerPrompt_en: Real table. Hero is CO with QJs and three seats still act after.
  runnerSupport_en: Before choosing an action, notice what the seat order gives you.
  runnerQuestion_en: What is the clean seat read here?
  teachingStep0_title_en: Seat read before action.
  teachingStep0_body_en: Late position helps, but Cutoff still leaves Button and the blinds behind you.
  teachingStep0_title_ru: Сначала место, потом действие.
  teachingStep0_body_ru: Поздняя позиция помогает, но cutoff всё ещё оставляет за спиной баттон и блайнды. Даже поздние места имеют разный вес.
  title_ru: Чтение места за живым столом
  runnerPrompt_ru: Живой стол. Ты в cutoff с QJs, и после тебя ещё три места.
  runnerSupport_ru: До действия сначала пойми, что именно даёт тебе это место и кто ещё остаётся за спиной.
  runnerQuestion_ru: Какое чтение позиции здесь будет самым чистым?

- taskId: position_checkpoint_review
  status: missing
  title_en: Position recap
  phase: review
  stepKind: proveIt
  runner: _world3PositionRecapRunner
  runnerPrompt_en: Lesson learned: position changes preflop comfort.
  runnerSupport_en: Late helps. Early demands stronger buckets and cleaner frames.
  runnerQuestion_en: What should you check after the bucket?
  teachingStep0_title_en: Position checklist.
  teachingStep0_body_en: Bucket the hand, then ask if the seat helps or hurts.
  teachingStep0_title_ru: Проверка по позиции.
  teachingStep0_body_ru: Сначала назови группу руки, потом спроси, помогает тебе место или мешает. Именно это и закрывает тему позиции.
  title_ru: Повтор по позиции
  runnerPrompt_ru: Главная мысль урока: позиция меняет префлоп-комфорт ещё до действия.
  runnerSupport_ru: Поздние места помогают, ранние требуют более крепкой группы руки и более чистой рамки.
  runnerQuestion_ru: На что нужно посмотреть сразу после группы руки?


---

## Pack: world_4

# world_4 RU Translation Pack

Status: GENERATED
World number: 4
EN title: Preflop Framework
EN subtitle: Use bucket, seat, and action frame before choosing.
title_ru: Префлоп-каркас
subtitle_ru: Смотри на руку, место и действие до того, как выбирать линию.

## Coverage
- Lessons: 0/5
- Tasks: 0/21
- Runner prompts: 0/21
- Runner supports: 0/21
- Runner questions: 0/21
- Teaching step titles: 0/21
- Teaching step bodies: 0/21

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson preflop_first_in_open
status: missing
title_en: First-in open
subtitle_en: When nobody entered, raising can start the hand.
title_ru: Открытие первым
subtitle_ru: Если в банк ещё никто не вошёл, раздачу можно начать рейзом.

- taskId: w3_first_in_intro
  status: missing
  title_en: Unopened pot
  phase: theory
  stepKind: learn
  runner: _world3FirstInIntroRunner
  runnerPrompt_en: First in means nobody has entered the pot yet.
  runnerSupport_en: You can limp by calling the blind, but open or fold is cleaner.
  runnerQuestion_en: What is cleaner than limping first in?
  teachingStep0_title_en: Unopened pot.
  teachingStep0_body_en: When nobody entered, raising is called opening. Calling is limping.
  teachingStep0_title_ru: Банк не открыт.
  teachingStep0_body_ru: Если до тебя никто не вошёл в банк, рейз называется открытием. Просто колл — это лимп.
  title_ru: Банк не открыт
  runnerPrompt_ru: Если ты входишь первым, в банке ещё никого нет.
  runnerSupport_ru: Можно зайти лимпом, но опен-рейз или пас обычно чище.
  runnerQuestion_ru: Что чище, чем пассивно входить первым?

- taskId: w3_button_open
  status: missing
  title_en: Button open
  phase: drill
  stepKind: practice
  runner: _world3ButtonOpenRunner
  runnerPrompt_en: Folded to BTN with KTs.
  runnerSupport_en: First in and late position: opening is the clean action.
  runnerQuestion_en: What is the simple first-in action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Играбельная рука в поздней позиции.
  teachingStep0_body_ru: KTs на баттоне спокойно играется через открытие, если до тебя никто не вошёл в банк.
  title_ru: Открытие с баттона
  runnerPrompt_ru: До баттона все выбросили, у тебя KTs.
  runnerSupport_ru: Поздняя позиция и вход первым делают открытие самым чистым действием.
  runnerQuestion_ru: Какое первое действие здесь самое простое?

- taskId: w3_early_fold
  status: missing
  title_en: Early fold
  phase: drill
  stepKind: practice
  runner: _world3EarlyFoldRunner
  runnerPrompt_en: Unopened pot. Hero is early with J8o.
  runnerSupport_en: Early position removes the comfort from weak offsuit hands.
  runnerQuestion_en: What is the clean action?
  teachingStep0_title_en: Discipline is allowed.
  teachingStep0_body_en: Opening weak early hands creates hard spots later.
  teachingStep0_title_ru: Дисциплина здесь уместна.
  teachingStep0_body_ru: Открытие слабых ранних рук часто создаёт тяжёлые споты на следующих решениях.
  title_ru: Ранний пас
  runnerPrompt_ru: Банк не открыт. Ты в ранней позиции с J8o.
  runnerSupport_ru: Ранняя позиция лишает слабые разномастные руки любого комфорта.
  runnerQuestion_ru: Какое действие здесь будет самым чистым?

- taskId: w3_first_in_recap
  status: missing
  title_en: Open recap
  phase: review
  stepKind: review
  runner: _world3FirstInRecapRunner
  runnerPrompt_en: Lesson learned: first in means open or fold.
  runnerSupport_en: Calling the blind is a limp; it is legal, but not the clean default.
  runnerQuestion_en: What is the passive first-in action?
  teachingStep0_title_en: First-in takeaway.
  teachingStep0_body_en: Unopened pots ask whether to open or let the hand go.
  teachingStep0_title_ru: Вывод по входу первым.
  teachingStep0_body_ru: Если банк не открыт, сначала решай: открыть раздачу или спокойно отпустить руку.
  title_ru: Повтор по открытию
  runnerPrompt_ru: Главная мысль: если входишь первым, обычно выбираешь между открытием и пасом.
  runnerSupport_ru: Колл блайнда — это лимп: он допустим, но не выглядит чистым вариантом по умолчанию.
  runnerQuestion_ru: Как называется пассивный вход первым?

## lesson preflop_facing_open
status: missing
title_en: Facing an open
subtitle_en: A raise before you changes the decision.
title_ru: Против открытия
subtitle_ru: Рейз до тебя меняет решение.

- taskId: w3_facing_open_intro
  status: missing
  title_en: Someone opened
  phase: theory
  stepKind: learn
  runner: _world3FacingOpenIntroRunner
  runnerPrompt_en: Facing an open means someone raised before you.
  runnerSupport_en: Now calling can exist, and weak continues can fold.
  runnerQuestion_en: What changed from first in?
  teachingStep0_title_en: The frame changed.
  teachingStep0_body_en: An opener created a price. Now call or fold can be natural.
  teachingStep0_title_ru: Рамка изменилась.
  teachingStep0_body_ru: Открытие до тебя создаёт цену входа. Теперь колл или пас часто становятся естественными вариантами.
  title_ru: Кто-то уже открылся
  runnerPrompt_ru: Против открытия — значит, кто-то уже сделал рейз до тебя.
  runnerSupport_ru: Теперь колл уже может быть нормальным, а слабые продолжения спокойно уходят в пас.
  runnerQuestion_ru: Что изменилось по сравнению со входом первым?

- taskId: w3_playable_call
  status: missing
  title_en: Playable call
  phase: drill
  stepKind: practice
  runner: _world3PlayableCallRunner
  runnerPrompt_en: CO opened. Hero is BTN with KQo.
  runnerSupport_en: Playable hand in position: call keeps the hand in.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Playable and in position.
  teachingStep0_body_en: KQo can call a simple open when hero acts after CO.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo может просто заколлить открытие, если ты действуешь после CO.
  title_ru: Играбельный колл
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может спокойно остаться в раздаче через колл.
  runnerQuestion_ru: Какой ответ здесь самый простой?

- taskId: w3_weak_facing_fold
  status: missing
  title_en: Weak facing fold
  phase: drill
  stepKind: practice
  runner: _world3WeakFacingFoldRunner
  runnerPrompt_en: CO opened. Hero is BTN with J8o.
  runnerSupport_en: Position helps, but this hand is still too weak to continue.
  runnerQuestion_en: What is the clean response?
  teachingStep0_title_en: Position is not a free pass.
  teachingStep0_body_en: J8o still folds when the hand bucket is too weak.
  teachingStep0_title_ru: Позиция — не бесплатный пропуск.
  teachingStep0_body_ru: J8o всё равно идёт в пас, если группа руки слишком слабая.
  title_ru: Слабая рука против открытия
  runnerPrompt_ru: CO открылся. Ты на баттоне с J8o.
  runnerSupport_ru: Позиция помогает, но эта рука всё ещё слишком слаба для продолжения.
  runnerQuestion_ru: Какой ответ здесь будет самым чистым?

- taskId: w3_facing_open_recap
  status: missing
  title_en: Facing-open recap
  phase: review
  stepKind: review
  runner: _world3FacingOpenRecapRunner
  runnerPrompt_en: Lesson learned: facing an open creates a price.
  runnerSupport_en: Playable hands can call; weak hands can still fold.
  runnerQuestion_en: What did the opener create?
  teachingStep0_title_en: Facing-open checklist.
  teachingStep0_body_en: Read the hand bucket, your position, and the price.
  teachingStep0_title_ru: Проверка против открытия.
  teachingStep0_body_ru: Смотри на группу руки, свою позицию и цену входа.
  title_ru: Повтор против открытия
  runnerPrompt_ru: Главное правило: чужой рейз устанавливает цену за просмотр флопа.
  runnerSupport_ru: Играбельные руки могут коллировать, а слабые спокойно уходят в пас.
  runnerQuestion_ru: Что создал рейз до тебя?

## lesson open_call_fold
status: missing
title_en: Open, call, fold
subtitle_en: Read first-in, facing-open, then act.
title_ru: Открыть, заколлить, выбросить
subtitle_ru: Сначала пойми рамку, потом действуй.

- taskId: frame_intro
  status: missing
  title_en: Frame first
  phase: theory
  stepKind: learn
  runner: _world3FirstInIntroRunner
  runnerPrompt_en: First in means nobody has entered the pot yet.
  runnerSupport_en: You can limp by calling the blind, but open or fold is cleaner.
  runnerQuestion_en: What is cleaner than limping first in?
  teachingStep0_title_en: Unopened pot.
  teachingStep0_body_en: When nobody entered, raising is called opening. Calling is limping.
  teachingStep0_title_ru: Банк не открыт.
  teachingStep0_body_ru: Если до тебя никто не вошёл в банк, рейз называется открытием. Просто колл — это лимп.
  title_ru: Сначала рамка
  runnerPrompt_ru: Если ты входишь первым, в банке ещё никого нет.
  runnerSupport_ru: Можно заколлить блайнд и зайти пассивно, но открыть или выбросить обычно чище.
  runnerQuestion_ru: Что чище, чем пассивно входить первым?

- taskId: frame_open
  status: missing
  title_en: Open
  phase: drill
  stepKind: practice
  runner: _world3ButtonOpenRunner
  runnerPrompt_en: Folded to BTN with KTs.
  runnerSupport_en: First in and late position: opening is the clean action.
  runnerQuestion_en: What is the simple first-in action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Играбельная рука в поздней позиции.
  teachingStep0_body_ru: KTs на баттоне спокойно играется через открытие, если до тебя никто не вошёл в банк.
  title_ru: Открыть
  runnerPrompt_ru: До баттона все выбросили, у тебя KTs.
  runnerSupport_ru: Поздняя позиция и вход первым делают открытие самым чистым действием.
  runnerQuestion_ru: Какое первое действие здесь самое простое?

- taskId: frame_call
  status: missing
  title_en: Call
  phase: drill
  stepKind: practice
  runner: _world3PlayableCallRunner
  runnerPrompt_en: CO opened. Hero is BTN with KQo.
  runnerSupport_en: Playable hand in position: call keeps the hand in.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Playable and in position.
  teachingStep0_body_en: KQo can call a simple open when hero acts after CO.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo может просто заколлить открытие, если ты действуешь после CO.
  title_ru: Колл
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может спокойно остаться в раздаче через колл.
  runnerQuestion_ru: Какой ответ здесь самый простой?

- taskId: frame_recap
  status: missing
  title_en: Action frame recap
  phase: review
  stepKind: review
  runner: _world3FirstInRecapRunner
  runnerPrompt_en: Lesson learned: first in means open or fold.
  runnerSupport_en: Calling the blind is a limp; it is legal, but not the clean default.
  runnerQuestion_en: What is the passive first-in action?
  teachingStep0_title_en: First-in takeaway.
  teachingStep0_body_en: Unopened pots ask whether to open or let the hand go.
  teachingStep0_title_ru: Проверка рамки.
  teachingStep0_body_ru: Сначала спроси, банк не открыт или рейз уже был. Только потом выбирай действие.
  title_ru: Повтор по рамке решения
  runnerPrompt_ru: Главная мысль: контекст меняет действие.
  runnerSupport_ru: Одна и та же рука может открыться первой, заколлить против открытия или уйти в пас в худшей рамке.
  runnerQuestion_ru: Что не даёт мышлению сводиться к «одна рука — один ответ»?

## lesson preflop_frame_before_action
status: missing
title_en: Frame before action
subtitle_en: Same hand, different action frame.
title_ru: Рамка до действия
subtitle_ru: Одна и та же рука ведёт себя по-разному в разной рамке.

- taskId: w3_same_hand_intro
  status: missing
  title_en: Context first
  phase: theory
  stepKind: learn
  runner: _world3SameHandIntroRunner
  runnerPrompt_en: The same hand can change action when the frame changes.
  runnerSupport_en: First in, facing open, and early position are different frames.
  runnerQuestion_en: What should you re-check?
  teachingStep0_title_en: No permanent answer.
  teachingStep0_body_en: Re-check bucket, seat, and whether someone already opened.
  teachingStep0_title_ru: Постоянного ответа нет.
  teachingStep0_body_ru: Снова посмотри на группу руки, место за столом и на то, был ли уже рейз.
  title_ru: Сначала контекст
  runnerPrompt_ru: Одна и та же рука может менять действие, если меняется рамка.
  runnerSupport_ru: Вход первым, игра против открытия и ранняя позиция — это разные условия.
  runnerQuestion_ru: Что нужно перепроверить?

- taskId: w3_same_hand_open
  status: missing
  title_en: Open frame
  phase: drill
  stepKind: practice
  runner: _world3ButtonOpenRunner
  runnerPrompt_en: Folded to BTN with KTs.
  runnerSupport_en: First in and late position: opening is the clean action.
  runnerQuestion_en: What is the simple first-in action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Играбельная рука в поздней позиции.
  teachingStep0_body_ru: KTs на баттоне спокойно играется через открытие, если до тебя никто не вошёл в банк.
  title_ru: Рамка открытия
  runnerPrompt_ru: До баттона все выбросили, у тебя KTs.
  runnerSupport_ru: Поздняя позиция и вход первым делают открытие самым чистым действием.
  runnerQuestion_ru: Какое первое действие здесь самое простое?

- taskId: w3_same_hand_call
  status: missing
  title_en: Call frame
  phase: drill
  stepKind: practice
  runner: _world3PlayableCallRunner
  runnerPrompt_en: CO opened. Hero is BTN with KQo.
  runnerSupport_en: Playable hand in position: call keeps the hand in.
  runnerQuestion_en: What is the simple response?
  teachingStep0_title_en: Playable and in position.
  teachingStep0_body_en: KQo can call a simple open when hero acts after CO.
  teachingStep0_title_ru: Играбельно и в позиции.
  teachingStep0_body_ru: KQo может просто заколлить открытие, если ты действуешь после CO.
  title_ru: Рамка колла
  runnerPrompt_ru: CO открылся. Ты на баттоне с KQo.
  runnerSupport_ru: Играбельная рука в позиции может спокойно остаться в раздаче через колл.
  runnerQuestion_ru: Какой ответ здесь самый простой?

- taskId: w3_same_hand_recap
  status: missing
  title_en: Frame recap
  phase: review
  stepKind: review
  runner: _world3SameHandRecapRunner
  runnerPrompt_en: Lesson learned: context can change the action.
  runnerSupport_en: A hand can open first in, call facing an open, or fold in a worse frame.
  runnerQuestion_en: What prevents one-hand-one-answer thinking?
  teachingStep0_title_en: Frame checklist.
  teachingStep0_body_en: Ask if the pot is unopened or if a raise already happened.
  teachingStep0_title_ru: Проверка рамки.
  teachingStep0_body_ru: Сначала пойми, банк не открыт или рейз уже был.
  title_ru: Повтор по рамке
  runnerPrompt_ru: Главная мысль: контекст меняет действие.
  runnerSupport_ru: Одна и та же рука может открываться первой, коллировать против открытия или уходить в пас в худшей рамке.
  runnerQuestion_ru: Что мешает мышлению «одна рука — один ответ»?

## lesson preflop_framework_checkpoint
status: missing
title_en: Preflop checkpoint
subtitle_en: Bucket, seat, frame, then action.
title_ru: Префлоп-контрольная
subtitle_ru: Группа, место, рамка, потом действие.

- taskId: w3_checkpoint_intro
  status: missing
  title_en: Three checks
  phase: theory
  stepKind: learn
  runner: _world3CheckpointIntroRunner
  runnerPrompt_en: Checkpoint: bucket, position, frame, then action.
  runnerSupport_en: Keep one reason in focus for each preflop decision.
  runnerQuestion_en: What is the World 3 preflop order?
  teachingStep0_title_en: Preflop order.
  teachingStep0_body_en: Name the bucket, read position, read frame, choose action.
  teachingStep0_title_ru: Префлоп-порядок.
  teachingStep0_body_ru: Назови группу руки, прочитай позицию, пойми рамку и только потом выбирай действие.
  title_ru: Три проверки
  runnerPrompt_ru: Контрольная проста: группа руки, позиция, рамка, потом действие.
  runnerSupport_ru: Держи в голове одну причину на каждое префлоп-решение.
  runnerQuestion_ru: Какой порядок нужен в World 4?

- taskId: w3_checkpoint_open
  status: missing
  title_en: Open decision
  phase: drill
  stepKind: practice
  runner: _world3ButtonOpenRunner
  runnerPrompt_en: Folded to BTN with KTs.
  runnerSupport_en: First in and late position: opening is the clean action.
  runnerQuestion_en: What is the simple first-in action?
  teachingStep0_title_en: Late playable hand.
  teachingStep0_body_en: KTs on the Button is playable when nobody entered.
  teachingStep0_title_ru: Играбельная рука в поздней позиции.
  teachingStep0_body_ru: KTs на баттоне спокойно играется через открытие, если до тебя никто не вошёл в банк.
  title_ru: Решение на открытие
  runnerPrompt_ru: До баттона все выбросили, у тебя KTs.
  runnerSupport_ru: Поздняя позиция и вход первым делают открытие самым чистым действием.
  runnerQuestion_ru: Какое первое действие здесь самое простое?

- taskId: w3_checkpoint_fold
  status: missing
  title_en: Fold decision
  phase: drill
  stepKind: practice
  runner: _world3EarlyFoldRunner
  runnerPrompt_en: Unopened pot. Hero is early with J8o.
  runnerSupport_en: Early position removes the comfort from weak offsuit hands.
  runnerQuestion_en: What is the clean action?
  teachingStep0_title_en: Discipline is allowed.
  teachingStep0_body_en: Opening weak early hands creates hard spots later.
  teachingStep0_title_ru: Дисциплина здесь уместна.
  teachingStep0_body_ru: Открытие слабых ранних рук часто создаёт тяжёлые споты на следующих решениях.
  title_ru: Решение на пас
  runnerPrompt_ru: Банк не открыт. Ты в ранней позиции с J8o.
  runnerSupport_ru: Ранняя позиция убирает комфорт у слабых разномастных рук.
  runnerQuestion_ru: Какое действие здесь будет самым чистым?

- taskId: checkpoint_table_frame
  status: missing
  title_en: Real-table frame read
  phase: drill
  stepKind: practice
  runner: _w4TableFrameNoticeRunner
  runnerPrompt_en: Real table. HJ opens 2.5 BB and hero is CO with AJo.
  runnerSupport_en: Before deciding call, fold, or raise, name the frame cleanly.
  runnerQuestion_en: What frame are you in?
  teachingStep0_title_en: Frame before action.
  teachingStep0_body_en: Real tables get simpler when you first ask whether the pot is unopened or facing an open.
  teachingStep0_title_ru: Рамка до действия.
  teachingStep0_body_ru: За живым столом всё становится проще, если сначала понять: банк не открыт или ты играешь против открытия.
  title_ru: Живая рамка раздачи
  runnerPrompt_ru: Живой стол. HJ открылся 2.5 BB, ты на CO с AJo.
  runnerSupport_ru: Перед тем как коллировать, пасовать или рейзить, сначала чисто назови рамку.
  runnerQuestion_ru: В какой рамке ты сейчас находишься?

- taskId: w3_checkpoint_review
  status: missing
  title_en: Preflop recap
  phase: review
  stepKind: proveIt
  runner: _world3CheckpointRunner
  runnerPrompt_en: Lesson learned: simple preflop choices need a framework.
  runnerSupport_en: No charts yet. Just bucket, position, frame, action.
  runnerQuestion_en: What makes preflop less random?
  teachingStep0_title_en: World 3 checkpoint.
  teachingStep0_body_en: Use one compact read instead of guessing the first action.
  teachingStep0_title_ru: Контрольная по World 4.
  teachingStep0_body_ru: Используй один компактный порядок вместо того, чтобы гадать первое действие.
  title_ru: Префлоп-повтор
  runnerPrompt_ru: Главная мысль: простым префлоп-решениям нужен каркас.
  runnerSupport_ru: Пока без чартов. Только группа руки, позиция, рамка и действие.
  runnerQuestion_ru: Что делает префлоп менее случайным?


---

## Pack: world_5

# world_5 RU Translation Pack

Status: GENERATED
World number: 5
EN title: Bet Purpose And Price
EN subtitle: Understand value, bluff, protection, and call price.
title_ru: Смысл ставки и цена
subtitle_ru: Пойми вэлью, блеф, защиту и цену колла без перегруза.

## Coverage
- Lessons: 0/7
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

## lesson why_bets_happen
status: missing
title_en: Why bets happen
subtitle_en: Every bet should have a simple purpose.
title_ru: Зачем вообще ставят
subtitle_ru: У каждой ставки должна быть простая и понятная цель.

- taskId: w4_purpose_intro
  status: missing
  title_en: Bet purpose
  phase: theory
  stepKind: learn
  runner: _world4PurposeIntroRunner
  runnerPrompt_en: A bet should have a reason before it has a size.
  runnerSupport_en: Start with purpose: value, bluff, or protection.
  runnerQuestion_en: What should you name before sizing a bet?
  teachingStep0_title_en: Purpose first.
  teachingStep0_body_en: Before choosing chips, ask what the bet is trying to do. Pot is 6 BB on the flop. Are you betting to collect chips from weaker hands (value), to fold out better hands (bluff), or to charge the next card before it arrives free (protection)? Name one reason, then pick a size.
  teachingStep0_title_ru: Сначала цель.
  teachingStep0_body_ru: До выбора размера сначала пойми, что ставка пытается сделать. На флопе в банке 6 BB. Ты ставишь, чтобы добрать с рук хуже, выбить руки лучше или заставить следующую карту стоить денег. Сначала назови цель, потом выбирай размер.
  title_ru: Смысл ставки
  runnerPrompt_ru: У ставки должна быть причина раньше, чем размер.
  runnerSupport_ru: Начни с цели: вэлью, блеф или защита.
  runnerQuestion_ru: Что нужно назвать до размера ставки?

- taskId: w4_value_purpose
  status: missing
  title_en: Value reason
  phase: drill
  stepKind: practice
  runner: _world4ValuePurposeRunner
  runnerPrompt_en: Hero has top pair. Worse hands can call.
  runnerSupport_en: This bet is not just noise. It wants calls from weaker hands.
  runnerQuestion_en: What is the main purpose?
  teachingStep0_title_en: Value wants calls.
  teachingStep0_body_en: With top pair, weaker pairs and worse aces may continue.
  teachingStep0_title_ru: Вэлью хочет колл.
  teachingStep0_body_ru: С топ-парой хуже могут платить: более слабые пары и худшие тузы ещё часто продолжают.
  title_ru: Причина для вэлью
  runnerPrompt_ru: У тебя топ-пара. Руки слабее могут заплатить.
  runnerSupport_ru: Эта ставка нужна не для шума, а чтобы руки хуже продолжали за деньги.
  runnerQuestion_ru: Какая здесь главная цель ставки?

- taskId: w4_bluff_purpose
  status: missing
  title_en: Bluff reason
  phase: drill
  stepKind: practice
  runner: _world4BluffPurposeRunner
  runnerPrompt_en: Hero missed. The bet tries to win by folds.
  runnerSupport_en: A bluff needs fold pressure, not a made hand.
  runnerQuestion_en: What is the main purpose?
  teachingStep0_title_en: Bluff wants folds.
  teachingStep0_body_en: When hero has no pair, the bet works only if folds happen.
  teachingStep0_title_ru: Блеф хочет пас.
  teachingStep0_body_ru: Если у тебя ничего не собрано, ставка работает только тогда, когда соперник выбрасывает.
  title_ru: Причина для блефа
  runnerPrompt_ru: Ты не попал. Ставка пытается забрать банк пасом соперника.
  runnerSupport_ru: Блеф держится на давлении на пас, а не на готовой руке.
  runnerQuestion_ru: Какая здесь главная цель ставки?

- taskId: w4_purpose_recap
  status: missing
  title_en: Purpose recap
  phase: review
  stepKind: review
  runner: _world4PurposeRecapRunner
  runnerPrompt_en: Lesson learned: name the purpose before the size.
  runnerSupport_en: Value gets calls. Bluff gets folds. Protection denies free cards.
  runnerQuestion_en: What comes before the bet size?
  teachingStep0_title_en: Purpose checklist.
  teachingStep0_body_en: Ask what the bet wants before asking how big it should be.
  teachingStep0_title_ru: Короткая проверка цели.
  teachingStep0_body_ru: Сначала пойми, чего хочет ставка, и только потом думай, какого она должна быть размера.
  title_ru: Повтор по цели ставки
  runnerPrompt_ru: Главное правило: сначала цель, потом размер.
  runnerSupport_ru: Вэлью добирает, блеф выбивает, защита не даёт увидеть карту бесплатно.
  runnerQuestion_ru: Что должно появиться раньше размера ставки?

## lesson value_bets
status: missing
title_en: Value bets
subtitle_en: Bet when worse hands can still call.
title_ru: Вэлью-ставки
subtitle_ru: Ставь, когда руки хуже ещё готовы платить.

- taskId: w4_value_intro
  status: missing
  title_en: Worse calls
  phase: theory
  stepKind: learn
  runner: _world4ValueIntroRunner
  runnerPrompt_en: A value bet targets weaker hands that can call.
  runnerSupport_en: If no weaker hand can call, value is thin or missing.
  runnerQuestion_en: Who should a value bet get called by?
  teachingStep0_title_en: Worse calls.
  teachingStep0_body_en: Value is simple: bet because worse hands can still pay. Hero has top pair with AQ on an A-7-2 board. Pot is 6 BB. Betting 3 BB asks every weaker ace, every pair of sevens, every pair of twos to put in chips you win on average.
  teachingStep0_title_ru: Вэлью добирает с рук хуже.
  teachingStep0_body_ru: Вэлью простое: ты ставишь, потому что руки хуже ещё заплатят. У тебя топ-пара с AQ на доске A-7-2. Банк 6 BB. Более слабые тузы и младшие пары ещё могут вложить фишки, которые ты будешь выигрывать в среднем.
  title_ru: Колл от рук слабее
  runnerPrompt_ru: Вэлью-ставка нацелена на руки слабее, которые ещё могут коллировать.
  runnerSupport_ru: Если хуже уже не платит, вэлью становится тонким или исчезает совсем.
  runnerQuestion_ru: Кто должен платить в ответ на вэлью-ставку?

- taskId: w4_value_bet
  status: missing
  title_en: Bet top pair
  phase: drill
  stepKind: practice
  runner: _world4ValueBetRunner
  runnerPrompt_en: Top pair on a safe flop. BB can call worse.
  runnerSupport_en: A half-pot bet is a simple value size here.
  runnerQuestion_en: What action fits the purpose?
  teachingStep0_title_en: Value wants calls.
  teachingStep0_body_en: With top pair, weaker pairs and worse aces may continue.
  teachingStep0_title_ru: Вэлью хочет колл.
  teachingStep0_body_ru: С топ-парой хуже ещё может заплатить, поэтому ставка здесь выглядит естественно.
  title_ru: Ставка с топ-парой
  runnerPrompt_ru: Топ-пара на безопасном флопе. BB может платить хуже.
  runnerSupport_ru: Полбанка здесь выглядит как простой и чистый размер на вэлью.
  runnerQuestion_ru: Какое действие лучше всего соответствует этой цели?

- taskId: w4_value_missed
  status: missing
  title_en: Do not hide value
  phase: drill
  stepKind: practice
  runner: _world4ValueCheckMissRunner
  runnerPrompt_en: Hero has top pair. Checking gives up a value chance.
  runnerSupport_en: When worse hands can call, betting is the lesson.
  runnerQuestion_en: Which action misses value?
  teachingStep0_title_en: Value wants calls.
  teachingStep0_body_en: With top pair, weaker pairs and worse aces may continue.
  teachingStep0_title_ru: Не прячь вэлью.
  teachingStep0_body_ru: Если руки хуже готовы платить, чек часто просто отдаёт им бесплатный выход.
  title_ru: Не прячь добор
  runnerPrompt_ru: У тебя топ-пара. Чек отдаёт шанс на добор.
  runnerSupport_ru: Если хуже может платить, ставка и есть главный учебный вывод.
  runnerQuestion_ru: Какое действие здесь упускает вэлью?

- taskId: w4_value_recap
  status: missing
  title_en: Value recap
  phase: review
  stepKind: review
  runner: _world4ValueRecapRunner
  runnerPrompt_en: Lesson learned: value means worse can call.
  runnerSupport_en: Do not hide strong but call-able hands every time.
  runnerQuestion_en: What makes a bet value?
  teachingStep0_title_en: Value checklist.
  teachingStep0_body_en: Ask what worse hands can call before choosing a size.
  teachingStep0_title_ru: Проверка на вэлью.
  teachingStep0_body_ru: До выбора размера сначала спроси себя, какие руки хуже реально могут платить.
  title_ru: Повтор по вэлью
  runnerPrompt_ru: Вывод простой: вэлью значит, что хуже ещё платит.
  runnerSupport_ru: Не прячь сильные, но оплачиваемые руки слишком часто.
  runnerQuestion_ru: Что делает ставку именно вэлью-ставкой?

## lesson bluff_pressure
status: missing
title_en: Bluff pressure
subtitle_en: A bluff tries to make better hands fold.
title_ru: Давление блефом
subtitle_ru: Блеф работает тогда, когда руки лучше ещё могут выбросить.

- taskId: w4_bluff_intro
  status: missing
  title_en: Fold pressure
  phase: theory
  stepKind: learn
  runner: _world4BluffIntroRunner
  runnerPrompt_en: A bluff tries to win when better hands fold.
  runnerSupport_en: No fold chance, no clean bluff.
  runnerQuestion_en: What does a bluff need?
  teachingStep0_title_en: Fold pressure.
  teachingStep0_body_en: A bluff is a story backed by chips, not random betting.
  teachingStep0_title_ru: Блефу нужен пас.
  teachingStep0_body_ru: Блеф — это не случайная ставка, а история, за которой стоят фишки. Если лучшая рука не собирается выбрасывать, чистого блефа здесь уже нет.
  title_ru: Давление на пас
  runnerPrompt_ru: Блеф пытается выиграть банк тогда, когда лучшая рука выбрасывает.
  runnerSupport_ru: Без реального шанса на пас чистого блефа не получается.
  runnerQuestion_ru: Что обязательно нужно блефу?

- taskId: w4_bluff_pressure
  status: missing
  title_en: Apply pressure
  phase: drill
  stepKind: practice
  runner: _world4BluffPressureRunner
  runnerPrompt_en: Hero missed, but BB checked and can fold.
  runnerSupport_en: A small bet can apply pressure without risking too much.
  runnerQuestion_en: What action matches the bluff purpose?
  teachingStep0_title_en: Bluff wants folds.
  teachingStep0_body_en: When hero has no pair, the bet works only if folds happen.
  teachingStep0_title_ru: Блеф хочет выбить.
  teachingStep0_body_ru: Если у тебя нет пары, ставка работает только тогда, когда соперник сдаётся под давлением.
  title_ru: Дай давление
  runnerPrompt_ru: Ты не попал, но BB чекнул и ещё может выбросить.
  runnerSupport_ru: Небольшая ставка здесь может дать давление без лишнего риска.
  runnerQuestion_ru: Какое действие лучше совпадает с целью блефа?

- taskId: w4_bad_bluff
  status: missing
  title_en: Bad pressure
  phase: drill
  stepKind: practice
  runner: _world4BadBluffRunner
  runnerPrompt_en: Villain called big already. Fold pressure is low.
  runnerSupport_en: A bluff is weaker when the opponent is not folding.
  runnerQuestion_en: What is the safer beginner action?
  teachingStep0_title_en: Bluff wants folds.
  teachingStep0_body_en: When hero has no pair, the bet works only if folds happen.
  teachingStep0_title_ru: Плохой блеф не работает.
  teachingStep0_body_ru: Если соперник уже показал готовность платить, давление на пас становится заметно слабее.
  title_ru: Плохое давление
  runnerPrompt_ru: Соперник уже много вложил и не выглядит готовым выбрасывать.
  runnerSupport_ru: Когда пас маловероятен, блеф становится заметно хуже для новичка.
  runnerQuestion_ru: Какое действие здесь безопаснее для новичка?

- taskId: w4_bluff_recap
  status: missing
  title_en: Bluff recap
  phase: review
  stepKind: review
  runner: _world4BluffRecapRunner
  runnerPrompt_en: Lesson learned: bluff only when folds can happen.
  runnerSupport_en: Pressure matters, but not every missed hand must fire.
  runnerQuestion_en: What does a bluff try to create?
  teachingStep0_title_en: Bluff checklist.
  teachingStep0_body_en: Ask whether better hands can fold before betting a miss.
  teachingStep0_title_ru: Проверка на блеф.
  teachingStep0_body_ru: Перед ставкой с промахом сначала спроси себя, могут ли руки лучше реально выбросить.
  title_ru: Повтор по блефу
  runnerPrompt_ru: Вывод простой: блефовать стоит только там, где пас реально возможен.
  runnerSupport_ru: Давление важно, но не каждый промах обязан превращаться в ставку.
  runnerQuestion_ru: Что именно пытается создать блеф?

## lesson protection_and_denial
status: missing
title_en: Protection and denial
subtitle_en: Bet so the next card is not free.
title_ru: Защита от бесплатной карты
subtitle_ru: Ставь так, чтобы следующая карта не доставалась даром.

- taskId: w4_protection_intro
  status: missing
  title_en: Deny free card
  phase: theory
  stepKind: learn
  runner: _world4ProtectionIntroRunner
  runnerPrompt_en: Protection bets make the next card cost something.
  runnerSupport_en: This is value-adjacent, but the key word is deny.
  runnerQuestion_en: What does protection deny?
  teachingStep0_title_en: Deny free cards.
  teachingStep0_body_en: If the next card can help villain, betting makes it cost something. Board is Q♥9♥4♣ and villain could be holding two hearts. Checking lets a third heart arrive free. A 3 BB bet into a 6 BB pot charges that possibility and still wins chips when villain misses.
  teachingStep0_title_ru: Не давай бесплатную карту.
  teachingStep0_body_ru: Если следующая карта может усилить соперника, ставка заставляет его платить за это улучшение. На доске Qh-9h-4c чек позволяет третьей черве прийти бесплатно. Ставка в 3 BB в банк 6 BB делает это улучшение платным и всё ещё может добрать, когда соперник не попал.
  title_ru: Не дать карту бесплатно
  runnerPrompt_ru: Защита делает следующую карту платной.
  runnerSupport_ru: Это рядом с вэлью, но здесь ключевое слово именно лишить бесплатного усиления.
  runnerQuestion_ru: Чего именно лишает защитная ставка?

- taskId: w4_protection_bet
  status: missing
  title_en: Protect pair
  phase: drill
  stepKind: practice
  runner: _world4ProtectionBetRunner
  runnerPrompt_en: Hero has top pair. Checking gives villain a free next card.
  runnerSupport_en: Betting protects value by denying that free card.
  runnerQuestion_en: What action fits protection?
  teachingStep0_title_en: Deny free cards.
  teachingStep0_body_en: If the next card can help villain, betting makes it cost something. Board is Q♥9♥4♣ and villain could be holding two hearts. Checking lets a third heart arrive free. A 3 BB bet into a 6 BB pot charges that possibility and still wins chips when villain misses.
  teachingStep0_title_ru: Не давай бесплатную карту.
  teachingStep0_body_ru: Если следующая карта может усилить соперника, ставка заставляет его платить за просмотр этой карты.
  title_ru: Защитить пару
  runnerPrompt_ru: У тебя топ-пара. Чек отдаёт сопернику бесплатную следующую карту.
  runnerSupport_ru: Ставка защищает твоё вэлью, потому что бесплатной карты уже не будет.
  runnerQuestion_ru: Какое действие лучше всего подходит для защиты?

- taskId: w4_protection_check
  status: missing
  title_en: Free card risk
  phase: drill
  stepKind: practice
  runner: _world4ProtectionCheckRunner
  runnerPrompt_en: Hero checks. Villain gets a free next card.
  runnerSupport_en: This is the risk protection bets are trying to avoid.
  runnerQuestion_en: What did checking allow?
  teachingStep0_title_en: Deny free cards.
  teachingStep0_body_en: If the next card can help villain, betting makes it cost something. Board is Q♥9♥4♣ and villain could be holding two hearts. Checking lets a third heart arrive free. A 3 BB bet into a 6 BB pot charges that possibility and still wins chips when villain misses.
  teachingStep0_title_ru: Чек отдал карту даром.
  teachingStep0_body_ru: Когда ты чекаешь, соперник может увидеть следующую карту бесплатно, даже если она опасна для твоей руки.
  title_ru: Риск бесплатной карты
  runnerPrompt_ru: Ты чекаешь. Соперник получает бесплатную следующую карту.
  runnerSupport_ru: Именно этот риск и пытаются убрать защитные ставки.
  runnerQuestion_ru: Что именно позволил чек?

- taskId: w4_protection_recap
  status: missing
  title_en: Protection recap
  phase: review
  stepKind: review
  runner: _world4ProtectionRecapRunner
  runnerPrompt_en: Lesson learned: protection denies a free next card.
  runnerSupport_en: Denying a free card is a real purpose.
  runnerQuestion_en: What does a protection bet deny?
  teachingStep0_title_en: Protection checklist.
  teachingStep0_body_en: Ask if checking gives away the next card too cheaply.
  teachingStep0_title_ru: Проверка на защиту.
  teachingStep0_body_ru: Сначала спроси себя, не отдаёт ли чек следующую карту слишком дёшево.
  title_ru: Повтор по защите
  runnerPrompt_ru: Вывод простой: защита не даёт следующей карте прийти бесплатно.
  runnerSupport_ru: Лишить бесплатной карты — это уже полноценная причина для ставки.
  runnerQuestion_ru: Чего лишает защитная ставка?

## lesson call_price
status: missing
title_en: Call price
subtitle_en: A bet gives you a price to continue.
title_ru: Цена колла
subtitle_ru: Любая ставка задаёт цену, за которую ты можешь продолжать.

- taskId: w4_price_intro
  status: missing
  title_en: Facing a price
  phase: theory
  stepKind: learn
  runner: _world4PriceIntroRunner
  runnerPrompt_en: When someone bets, they set your price to continue.
  runnerSupport_en: Small price can invite a call. Big price can force a fold.
  runnerQuestion_en: What does a bet give the caller?
  teachingStep0_title_en: Price to continue.
  teachingStep0_body_en: Calling means paying the listed price to see more cards.
  teachingStep0_title_ru: Цена продолжения.
  teachingStep0_body_ru: Колл значит, что ты платишь указанную цену за то, чтобы увидеть следующие карты и остаться в раздаче.
  title_ru: Перед тобой цена
  runnerPrompt_ru: Когда соперник ставит, он задаёт цену твоего продолжения.
  runnerSupport_ru: Маленькая цена чаще тянет на колл, большая уже часто толкает к пасу.
  runnerQuestion_ru: Что даёт ставка тому, кто думает о колле?

- taskId: w4_good_price_call
  status: missing
  title_en: Call small price
  phase: drill
  stepKind: practice
  runner: _world4GoodPriceCallRunner
  runnerPrompt_en: Pot is 8 BB. To call is 1 BB with one pair.
  runnerSupport_en: Small price, paired hand: calling is acceptable.
  runnerQuestion_en: What action fits the price?
  teachingStep0_title_en: Price to continue.
  teachingStep0_body_en: Calling means paying the listed price to see more cards.
  teachingStep0_title_ru: Цена продолжения.
  teachingStep0_body_ru: Маленькая цена с готовой рукой часто позволяет спокойно продолжить.
  title_ru: Колл по хорошей цене
  runnerPrompt_ru: В банке 8 BB. За колл нужно 1 BB, а у тебя пара.
  runnerSupport_ru: Маленькая цена и готовая рука делают колл здесь нормальным продолжением.
  runnerQuestion_ru: Какое действие лучше всего соответствует этой цене?

- taskId: w4_bad_price_fold
  status: missing
  title_en: Fold high price
  phase: drill
  stepKind: practice
  runner: _world4BadPriceFoldRunner
  runnerPrompt_en: Pot is 8 BB. To call is 7 BB with a weak pair.
  runnerSupport_en: The price is high and the hand is not strong enough.
  runnerQuestion_en: What action fits the price?
  teachingStep0_title_en: Price to continue.
  teachingStep0_body_en: Calling means paying the listed price to see more cards.
  teachingStep0_title_ru: Цена продолжения.
  teachingStep0_body_ru: Когда цена почти догоняет банк, а рука слабая, продолжение становится слишком дорогим.
  title_ru: Пас на высокой цене
  runnerPrompt_ru: В банке 8 BB. За колл нужно 7 BB, а у тебя слабая пара.
  runnerSupport_ru: Цена слишком высокая, а рука слишком слабая для такого продолжения.
  runnerQuestion_ru: Какое действие лучше всего соответствует этой цене?

- taskId: w4_price_recap
  status: missing
  title_en: Price recap
  phase: review
  stepKind: review
  runner: _world4PriceRecapRunner
  runnerPrompt_en: Lesson learned: every call has a price.
  runnerSupport_en: Compare the price to hand strength and future cards.
  runnerQuestion_en: What should you read before calling?
  teachingStep0_title_en: Price checklist.
  teachingStep0_body_en: Read pot, to-call, and hand strength before calling.
  teachingStep0_title_ru: Короткая проверка цены.
  teachingStep0_body_ru: Перед коллом сначала прочитай банк, цену продолжения и силу своей руки.
  title_ru: Повтор по цене
  runnerPrompt_ru: Вывод простой: у каждого колла есть своя цена.
  runnerSupport_ru: Сравни цену с силой руки и тем, что может случиться дальше.
  runnerQuestion_ru: Что нужно прочитать перед коллом?

## lesson small_half_pot
status: missing
title_en: Small, half, pot
subtitle_en: Size says how much pressure you create.
title_ru: Маленькая, полбанка, банк
subtitle_ru: Размер ставки задаёт, сколько давления и цены ты создаёшь.

- taskId: w4_sizing_intro
  status: missing
  title_en: Size language
  phase: theory
  stepKind: learn
  runner: _world4SizingIntroRunner
  runnerPrompt_en: Bet size changes pressure and price.
  runnerSupport_en: One-third is light, half-pot is common, pot-size is heavy.
  runnerQuestion_en: What does size change?
  teachingStep0_title_en: Size is pressure.
  teachingStep0_body_en: One-third, half-pot, and pot-size bets create different prices. One-third probes lightly, half-pot is the clean middle size, and pot-size applies heavy pressure.
  teachingStep0_title_ru: Размер — это давление.
  teachingStep0_body_ru: Ставки в треть банка, полбанка и банк создают разную цену и разное давление. Треть банка — лёгкий пробный размер, полбанка — середина, банк — уже тяжёлое давление.
  title_ru: Язык размеров
  runnerPrompt_ru: Размер ставки меняет и давление, и цену.
  runnerSupport_ru: Треть банка лёгкая, полбанка стандартная, банк уже тяжёлый размер.
  runnerQuestion_ru: Что именно меняет размер ставки?

- taskId: w4_small_bet
  status: missing
  title_en: One-third bet
  phase: drill
  stepKind: practice
  runner: _world4SmallBetRunner
  runnerPrompt_en: Pot is 6 BB. Hero wants light pressure.
  runnerSupport_en: One-third pot is the smallest simple pressure size here.
  runnerQuestion_en: Which size is one-third pot?
  teachingStep0_title_en: Size is pressure.
  teachingStep0_body_en: One-third, half-pot, and pot-size bets create different prices. One-third probes lightly, half-pot is the clean middle size, and pot-size applies heavy pressure.
  teachingStep0_title_ru: Размер — это давление.
  teachingStep0_body_ru: Треть банка создаёт самый лёгкий и дешёвый вариант давления в этой базовой линейке.
  title_ru: Ставка в треть банка
  runnerPrompt_ru: В банке 6 BB. Ты хочешь дать лёгкое давление.
  runnerSupport_ru: Треть банка здесь — самый маленький из простых размеров давления.
  runnerQuestion_ru: Какой размер здесь равен трети банка?

- taskId: w4_half_pot_bet
  status: missing
  title_en: Half-pot bet
  phase: drill
  stepKind: practice
  runner: _world4HalfPotRunner
  runnerPrompt_en: Pot is 6 BB. Hero wants the clean middle size.
  runnerSupport_en: Half-pot means betting half the pot, not the smallest or biggest size.
  runnerQuestion_en: Which size is half-pot?
  teachingStep0_title_en: Size is pressure.
  teachingStep0_body_en: One-third, half-pot, and pot-size bets create different prices. One-third probes lightly, half-pot is the clean middle size, and pot-size applies heavy pressure.
  teachingStep0_title_ru: Размер — это давление.
  teachingStep0_body_ru: Полбанка — это средний и самый универсальный учебный размер между маленьким и тяжёлым давлением.
  title_ru: Ставка в полбанка
  runnerPrompt_ru: В банке 6 BB. Ты хочешь выбрать чистый средний размер.
  runnerSupport_ru: Полбанка — это половина банка, а не самый маленький и не самый тяжёлый размер.
  runnerQuestion_ru: Какой размер здесь равен половине банка?

- taskId: w4_pot_bet
  status: missing
  title_en: Pot-size bet
  phase: drill
  stepKind: practice
  runner: _world4PotBetRunner
  runnerPrompt_en: Pot is 6 BB. A pot-size bet is heavy pressure.
  runnerSupport_en: Pot-size means the bet matches the pot.
  runnerQuestion_en: Which size is pot-size?
  teachingStep0_title_en: Size is pressure.
  teachingStep0_body_en: One-third, half-pot, and pot-size bets create different prices. One-third probes lightly, half-pot is the clean middle size, and pot-size applies heavy pressure.
  teachingStep0_title_ru: Размер — это давление.
  teachingStep0_body_ru: Ставка в банк создаёт тяжёлое давление, потому что цена продолжения становится самой жёсткой в этой базовой тройке.
  title_ru: Ставка в банк
  runnerPrompt_ru: В банке 6 BB. Ставка размером в банк — это уже тяжёлое давление.
  runnerSupport_ru: Размер в банк означает, что ставка по величине равна самому банку.
  runnerQuestion_ru: Какой размер здесь равен банку?

- taskId: w4_sizing_recap
  status: missing
  title_en: Sizing recap
  phase: review
  stepKind: review
  runner: _world4SizingRecapRunner
  runnerPrompt_en: Lesson learned: size sets pressure and price.
  runnerSupport_en: Small, half-pot, and pot-size should match the purpose.
  runnerQuestion_en: What should size match?
  teachingStep0_title_en: Sizing checklist.
  teachingStep0_body_en: Name purpose, then choose a size that fits the pressure: light, middle, or heavy.
  teachingStep0_title_ru: Проверка по размеру.
  teachingStep0_body_ru: Сначала назови цель ставки, а потом подбери под неё лёгкий, средний или тяжёлый размер.
  title_ru: Повтор по размерам
  runnerPrompt_ru: Вывод простой: размер задаёт давление и цену.
  runnerSupport_ru: Маленький, полбанка и банк должны совпадать с тем, чего ты хочешь от ставки.
  runnerQuestion_ru: С чем должен совпадать размер ставки?

## lesson price_checkpoint
status: missing
title_en: Price checkpoint
subtitle_en: Read purpose, size, and price before action.
title_ru: Проверка цели, размера и цены
subtitle_ru: Перед действием прочитай цель ставки, её размер и цену продолжения.

- taskId: w4_checkpoint_intro
  status: missing
  title_en: Three reads
  phase: theory
  stepKind: learn
  runner: _world4CheckpointIntroRunner
  runnerPrompt_en: Checkpoint: purpose, size, and price work together.
  runnerSupport_en: The bettor sets pressure. The caller reads the price.
  runnerQuestion_en: What are the three World 4 reads?
  teachingStep0_title_en: Three reads.
  teachingStep0_body_en: Purpose explains why. Size creates pressure. Price decides calls.
  teachingStep0_title_ru: Три чтения.
  teachingStep0_body_ru: Цель объясняет зачем, размер создаёт давление, а цена отвечает, стоит ли продолжать.
  title_ru: Три чтения
  runnerPrompt_ru: Контрольная точка: цель, размер и цена работают вместе.
  runnerSupport_ru: Тот, кто ставит, создаёт давление. Тот, кто думает о колле, читает цену.
  runnerQuestion_ru: Какие три чтения собирает World 5?

- taskId: w4_checkpoint_value
  status: missing
  title_en: Value or bluff
  phase: drill
  stepKind: practice
  runner: _world4ValuePurposeRunner
  runnerPrompt_en: Hero has top pair. Worse hands can call.
  runnerSupport_en: This bet is not just noise. It wants calls from weaker hands.
  runnerQuestion_en: What is the main purpose?
  teachingStep0_title_en: Value wants calls.
  teachingStep0_body_en: With top pair, weaker pairs and worse aces may continue.
  teachingStep0_title_ru: Вэлью хочет колл.
  teachingStep0_body_ru: С топ-парой хуже ещё платит, значит цель ставки здесь остаётся простой и чистой.
  title_ru: Вэлью или блеф
  runnerPrompt_ru: У тебя топ-пара. Руки слабее ещё могут платить.
  runnerSupport_ru: Эта ставка нужна не для шума, а для коллов от рук хуже.
  runnerQuestion_ru: Какая здесь главная цель ставки?

- taskId: w4_checkpoint_price
  status: missing
  title_en: Call or fold
  phase: drill
  stepKind: practice
  runner: _world4BadPriceFoldRunner
  runnerPrompt_en: Pot is 8 BB. To call is 7 BB with a weak pair.
  runnerSupport_en: The price is high and the hand is not strong enough.
  runnerQuestion_en: What action fits the price?
  teachingStep0_title_en: Price to continue.
  teachingStep0_body_en: Calling means paying the listed price to see more cards.
  teachingStep0_title_ru: Цена продолжения.
  teachingStep0_body_ru: Колл — это всегда плата за продолжение. Когда цена слишком велика для силы руки, спокойный пас лучше.
  title_ru: Колл или пас
  runnerPrompt_ru: В банке 8 BB. За колл нужно 7 BB, а у тебя слабая пара.
  runnerSupport_ru: Цена высокая, а рука слишком слабая, чтобы продолжать с комфортом.
  runnerQuestion_ru: Какое действие лучше всего соответствует этой цене?

- taskId: w4_checkpoint_review
  status: missing
  title_en: Price recap
  phase: review
  stepKind: proveIt
  runner: _world4CheckpointRunner
  runnerPrompt_en: Lesson learned: betting is purpose plus price.
  runnerSupport_en: Value, bluff, protection, and call price are now one system.
  runnerQuestion_en: What makes a bet easier to understand?
  teachingStep0_title_en: World 4 checkpoint.
  teachingStep0_body_en: Read what the bet wants and what it costs to continue.
  teachingStep0_title_ru: Контрольная точка World 5.
  teachingStep0_body_ru: Сначала прочитай, чего ставка хочет, потом посмотри, какой размер она создаёт и сколько стоит продолжение.
  title_ru: Повтор по цене и смыслу
  runnerPrompt_ru: Вывод простой: ставка читается через цель и цену вместе.
  runnerSupport_ru: Вэлью, блеф, защита и цена колла теперь складываются в одну систему.
  runnerQuestion_ru: Что делает ставку понятнее для игрока?


---

## Pack: world_6

# world_6 RU Translation Pack

Status: GENERATED
World number: 6
EN title: Board And Draws
EN subtitle: Read board texture, draws, and changing streets.
title_ru: Борд и дро
subtitle_ru: Читай текстуру борда, дро и то, как улицы меняют план.

## Coverage
- Lessons: 0/6
- Tasks: 0/25
- Runner prompts: 0/25
- Runner supports: 0/25
- Runner questions: 0/25
- Teaching step titles: 0/25
- Teaching step bodies: 0/25

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


---

## Pack: world_7

# world_7 RU Translation Pack

Status: GENERATED
World number: 7
EN title: Range Thinking Lite
EN subtitle: Group hands into simple buckets without solver talk.
title_ru: Диапазоны без перегруза
subtitle_ru: Группируй руки просто, без лишней теории.

## Coverage
- Lessons: 0/5
- Tasks: 0/27
- Runner prompts: 0/27
- Runner supports: 0/27
- Runner questions: 0/27
- Teaching step titles: 0/27
- Teaching step bodies: 0/27

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson range_bucket_basics
status: missing
title_en: Range buckets
subtitle_en: Sort hands into value, bluff candidate, and missed buckets.
title_ru: Группы диапазона
subtitle_ru: Сначала раздели руки на вэлью, кандидаты для блефа и полный промах.

- taskId: w6_range_intro
  status: missing
  title_en: Three buckets
  phase: theory
  stepKind: learn
  runner: _w6RangeIntroRunner
  runnerPrompt_en: A range is the group of hands that fit a situation.
  runnerSupport_en: Value, bluff candidate, and missed are the three range buckets.
  runnerQuestion_en: What are range buckets?
  teachingStep0_title_en: Three buckets.
  teachingStep0_body_en: After the flop, sort your hand into value (can bet for profit),
  teachingStep0_title_ru: Три группы.
  teachingStep0_body_ru: После флопа сначала пойми, где стоит твоя рука: вэлью, кандидат для блефа или полный промах. Это даёт опору ещё до выбора действия.
  title_ru: Три группы
  runnerPrompt_ru: Диапазон — это группа рук, которые подходят под ситуацию.
  runnerSupport_ru: Дели руки на три простые группы: вэлью, возможный блеф и полный промах.
  runnerQuestion_ru: Что такое группы диапазона?

- taskId: w6_value_dry_board
  status: missing
  title_en: Value on dry board
  phase: drill
  stepKind: practice
  runner: _w6ValueDryBoardRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds K-Q.
  runnerSupport_en: Top pair with the best possible kicker.
  runnerQuestion_en: Which range bucket is K-Q on this board?
  teachingStep0_title_en: Three buckets.
  teachingStep0_body_en: After the flop, sort your hand into value (can bet for profit),
  teachingStep0_title_ru: Три группы.
  teachingStep0_body_ru: Если рука уже уверенно сильнее диапазона продолжения соперника, это обычно вэлью. Здесь сначала важна сама группа, а не размер ставки.
  title_ru: Вэлью на сухой доске
  runnerPrompt_ru: K-7-2 радугой. У тебя K-Q.
  runnerSupport_ru: Топ-пара с лучшим кикером на такой доске.
  runnerQuestion_ru: В какую группу попадает K-Q на этой доске?

- taskId: w6_missed_dry_board
  status: missing
  title_en: Missed on dry board
  phase: drill
  stepKind: practice
  runner: _w6MissedDryBoardRunner
  runnerPrompt_en: Same K-7-2 rainbow. Hero holds J-T.
  runnerSupport_en: No pair, no draw on a dry board.
  runnerQuestion_en: Which range bucket is J-T on this board?
  teachingStep0_title_en: Three buckets.
  teachingStep0_body_en: After the flop, sort your hand into value (can bet for profit),
  teachingStep0_title_ru: Три группы.
  teachingStep0_body_ru: Если у руки нет ни пары, ни дро, ни заметного давления на соперника, это обычно промах. Сначала честно назови эту группу.
  title_ru: Промах на сухой доске
  runnerPrompt_ru: Та же доска K-7-2 радугой. У тебя J-T.
  runnerSupport_ru: Ни пары, ни дро на сухом флопе.
  runnerQuestion_ru: В какую группу попадает J-T здесь?

- taskId: w6_table_bucket_notice
  status: missing
  title_en: First live read
  phase: drill
  stepKind: practice
  runner: _w6TableBucketNoticeRunner
  runnerPrompt_en: Real table. K-7-2 rainbow lands and you hold A-Q.
  runnerSupport_en: Before picking a size, make the first useful read.
  runnerQuestion_en: What should you ask first?
  teachingStep0_title_en: Three buckets.
  teachingStep0_body_en: After the flop, sort your hand into value (can bet for profit),
  teachingStep0_title_ru: Три группы.
  teachingStep0_body_ru: За живым столом сначала не выбирай размер, а быстро пойми, что у тебя вообще за история на этой доске. Группа важнее первого импульса.
  title_ru: Первый живой вывод
  runnerPrompt_ru: Реальный стол. На флоп приходит K-7-2 радугой, у тебя A-Q.
  runnerSupport_ru: До выбора сайза сначала сделай первый полезный вывод.
  runnerQuestion_ru: Что нужно спросить себя первым?

- taskId: w6_buckets_recap
  status: missing
  title_en: Buckets recap
  phase: review
  stepKind: review
  runner: _w6BucketsRecapRunner
  runnerPrompt_en: Lesson learned: range buckets start with board fit.
  runnerSupport_en: Ask which bucket before choosing an action.
  runnerQuestion_en: Which range bucket reads the board first?
  teachingStep0_title_en: Bucket before action.
  teachingStep0_body_en: Assign your hand to a range bucket before choosing to bet, check, or fold.
  teachingStep0_title_ru: Сначала группа.
  teachingStep0_body_ru: До ставки, чека или паса сначала разложи руку по группам. Это убирает хаос и делает решение чище.
  title_ru: Повтор по группам
  runnerPrompt_ru: Главная мысль урока: группы диапазона начинаются с того, как рука попала в доску.
  runnerSupport_ru: Сначала пойми группу, потом выбирай действие.
  runnerQuestion_ru: Что в этой модели сначала читает доску?

## lesson range_board_fit
status: missing
title_en: Range meets board
subtitle_en: Board texture can shift a hand from value to missed.
title_ru: Как диапазон встречает доску
subtitle_ru: Одна и та же рука может стать вэлью на одной доске и промахом на другой.

- taskId: w6_board_fit_intro
  status: missing
  title_en: Board shifts bucket
  phase: theory
  stepKind: learn
  runner: _w6BoardFitIntroRunner
  runnerPrompt_en: Board texture can shift a hand from value to missed.
  runnerSupport_en: The same hand can be value on one board and missed on another.
  runnerQuestion_en: What changes a hand's range bucket?
  teachingStep0_title_en: Board changes the bucket.
  teachingStep0_body_en: A preflop strong hand can become missed if it does not connect with the flop.
  teachingStep0_title_ru: Доска меняет группу.
  teachingStep0_body_ru: Сильная рука префлоп ещё не гарантирует сильную руку на флопе. Сначала посмотри, во что именно попала доска.
  title_ru: Доска меняет группу
  runnerPrompt_ru: Текстура доски может перевести руку из вэлью в промах.
  runnerSupport_ru: Одни и те же карты могут быть сильными на одном флопе и совсем пустыми на другом.
  runnerQuestion_ru: Что меняет группу руки?

- taskId: w6_wrong_board
  status: missing
  title_en: Missed on wet board
  phase: drill
  stepKind: practice
  runner: _w6WrongBoardRunner
  runnerPrompt_en: 8-7-6 two-tone. Hero holds K-Q.
  runnerSupport_en: K-Q was strong preflop, but this board changed everything.
  runnerQuestion_en: Which range bucket is K-Q on 8-7-6?
  teachingStep0_title_en: Board changes the bucket.
  teachingStep0_body_en: A preflop strong hand can become missed if it does not connect with the flop.
  teachingStep0_title_ru: Доска меняет группу.
  teachingStep0_body_ru: K-Q выглядела красиво префлоп, но доска 8-7-6 с мастевым дро проходит мимо неё. Здесь важно отпустить прежнюю силу руки.
  title_ru: Промах на мокрой доске
  runnerPrompt_ru: 8-7-6 с двумя картами одной масти. У тебя K-Q.
  runnerSupport_ru: K-Q была сильной префлоп, но эта доска всё изменила.
  runnerQuestion_ru: В какую группу попадает K-Q на 8-7-6?

- taskId: w6_value_wet_board
  status: missing
  title_en: Value on wet board
  phase: drill
  stepKind: practice
  runner: _w6ValueWetBoardRunner
  runnerPrompt_en: Same 8-7-6 two-tone. Hero holds 9-8.
  runnerSupport_en: 9-8 flopped two pair on a connected board.
  runnerQuestion_en: Which range bucket is 9-8 on 8-7-6?
  teachingStep0_title_en: Board changes the bucket.
  teachingStep0_body_en: A preflop strong hand can become missed if it does not connect with the flop.
  teachingStep0_title_ru: Доска меняет группу.
  teachingStep0_body_ru: На связанной доске две пары всё равно остаются сильной готовой рукой. Здесь доска опасная, но твоя группа по-прежнему вэлью.
  title_ru: Вэлью на мокрой доске
  runnerPrompt_ru: Та же доска 8-7-6 с двумя картами одной масти. У тебя 9-8.
  runnerSupport_ru: 9-8 попали в две пары на связанной доске.
  runnerQuestion_ru: В какую группу попадает 9-8 на 8-7-6?

- taskId: w6_turn_shift_bucket
  status: missing
  title_en: Turn changes bucket
  phase: drill
  stepKind: practice
  runner: _w6TurnShiftBucketRunner
  runnerPrompt_en: Flop gave you a bluff candidate. Turn bricks and pairs the board.
  runnerSupport_en: When pressure drops, the bucket can slide.
  runnerQuestion_en: What often happens to the hand now?
  teachingStep0_title_en: Board changes the bucket.
  teachingStep0_body_en: A preflop strong hand can become missed if it does not connect with the flop.
  teachingStep0_title_ru: Доска меняет группу.
  teachingStep0_body_ru: Если тёрн убирает давление и делает твоё полублефовое продолжение слабее, рука может сдвинуться вниз по группам. Эту смену нужно замечать сразу.
  title_ru: Тёрн меняет группу
  runnerPrompt_ru: На флопе у тебя был кандидат для блефа. На тёрне бланк и спарка доски.
  runnerSupport_ru: Когда давление падает, группа руки тоже может сдвинуться.
  runnerQuestion_ru: Что часто происходит с рукой теперь?

- taskId: w6_board_fit_recap
  status: missing
  title_en: Board fit recap
  phase: review
  stepKind: review
  runner: _w6BoardFitRecapRunner
  runnerPrompt_en: Lesson learned: the same hand hits different buckets on different boards.
  runnerSupport_en: Always read the board before assigning a bucket.
  runnerQuestion_en: What decides which bucket a hand lands in?
  teachingStep0_title_en: Texture shifts buckets.
  teachingStep0_body_en: Read the board, then assign the bucket. Preflop hand strength is only the starting point.
  teachingStep0_title_ru: Текстура двигает группы.
  teachingStep0_body_ru: Не оценивай руку в вакууме. Сначала смотри на доску, потом уже называй группу.
  title_ru: Повтор по попаданию в доску
  runnerPrompt_ru: Главная мысль урока: одна и та же рука попадает в разные группы на разных досках.
  runnerSupport_ru: Всегда сначала читай доску, а уже потом назначай группу.
  runnerQuestion_ru: Что решает, в какую группу попадает рука?

## lesson range_pressure_lines
status: missing
title_en: Value, bluff, missed
subtitle_en: Each bucket suggests a different action direction.
title_ru: Вэлью, блеф, промах
subtitle_ru: Каждая группа ведёт к своему типу действия.

- taskId: w6_pressure_lines_intro
  status: missing
  title_en: Bucket shapes action
  phase: theory
  stepKind: learn
  runner: _w6PressureLinesIntroRunner
  runnerPrompt_en: Each range bucket suggests a different action direction.
  runnerSupport_en: Value bets to get called. Bluff candidates can bet to fold out better hands.
  runnerQuestion_en: What does a value hand do?
  teachingStep0_title_en: Bucket shapes action.
  teachingStep0_body_en: Value hands bet for profit. Bluff candidates bet for fold equity.
  teachingStep0_title_ru: Группа ведёт действие.
  teachingStep0_body_ru: Вэлью обычно ставит ради колла хуже. Кандидат для блефа давит на пас. Полный промах чаще не хочет разгонять банк.
  title_ru: Группа задаёт ход
  runnerPrompt_ru: Каждая группа рук ведёт к своему типу действия.
  runnerSupport_ru: Вэлью ставит ради оплаты. Кандидат для блефа ставит ради пасов.
  runnerQuestion_ru: Что обычно делает рука из группы вэлью?

- taskId: w6_value_range_action
  status: missing
  title_en: Value bets
  phase: drill
  stepKind: practice
  runner: _w6ValueRangeActionRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds K-Q. You are in the value range.
  runnerSupport_en: Value hands want to build the pot.
  runnerQuestion_en: What does K-Q do here?
  teachingStep0_title_en: Bucket shapes action.
  teachingStep0_body_en: Value hands bet for profit. Bluff candidates bet for fold equity.
  teachingStep0_title_ru: Группа ведёт действие.
  teachingStep0_body_ru: Если рука относится к вэлью, она обычно хочет вложить деньги в банк. Здесь действие должно продолжать силу руки, а не прятать её.
  title_ru: Вэлью ставит
  runnerPrompt_ru: K-7-2 радугой. У тебя K-Q. Ты находишься в группе вэлью.
  runnerSupport_ru: Вэлью-руки хотят строить банк.
  runnerQuestion_ru: Что делает K-Q в такой ситуации?

- taskId: w6_bluff_candidate
  status: missing
  title_en: Bluff candidate
  phase: drill
  stepKind: practice
  runner: _w6BluffCandidateRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds A-Q.
  runnerSupport_en: Two overcards, no pair. Some fold equity exists.
  runnerQuestion_en: Which range bucket is A-Q here?
  teachingStep0_title_en: Bucket shapes action.
  teachingStep0_body_en: Value hands bet for profit. Bluff candidates bet for fold equity.
  teachingStep0_title_ru: Группа ведёт действие.
  teachingStep0_body_ru: A-Q без пары на сухой доске не готовая сила, но ещё может давить на пас. Это не чистое вэлью и не полный ноль.
  title_ru: Кандидат для блефа
  runnerPrompt_ru: K-7-2 радугой. У тебя A-Q.
  runnerSupport_ru: Две оверкарты, пары нет. Есть небольшой шанс забрать банк пасом соперника.
  runnerQuestion_ru: В какую группу попадает A-Q здесь?

- taskId: w6_missed_hand_action
  status: missing
  title_en: Missed hand direction
  phase: drill
  stepKind: practice
  runner: _w6MissedHandActionRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds J-T with no draw.
  runnerSupport_en: Pure missed hands usually do not want a big pot.
  runnerQuestion_en: What is the clean action direction?
  teachingStep0_title_en: Bucket shapes action.
  teachingStep0_body_en: Value hands bet for profit. Bluff candidates bet for fold equity.
  teachingStep0_title_ru: Группа ведёт действие.
  teachingStep0_body_ru: Если у руки нет ни шоудаун-вэлью, ни давления, она редко хочет большой банк. Здесь чистое направление обычно спокойнее и уже.
  title_ru: Куда идёт промах
  runnerPrompt_ru: K-7-2 радугой. У тебя J-T без дро.
  runnerSupport_ru: Чистый промах обычно не хочет большой банк.
  runnerQuestion_ru: Какое направление действия здесь самое чистое?

- taskId: w6_wet_board_repair
  status: missing
  title_en: Repair wet-board read
  phase: drill
  stepKind: fixMistakes
  runner: _w6WetBoardRepairRunner
  runnerPrompt_en: Turn card connected the board, but hero still treats one pair like the flop stayed dry.
  runnerSupport_en: Repair the board read before forcing the same old action.
  runnerQuestion_en: What needs fixing first?
  teachingStep0_title_en: Repair story before line.
  teachingStep0_body_en: Board texture changed. Fix the story first, then decide whether the old value plan still belongs.
  teachingStep0_title_ru: Сначала почини историю.
  teachingStep0_body_ru: Если доска изменилась, сначала пересобери чтение ситуации, а уже потом думай, осталось ли старое действие верным. Линия без новой истории часто ломается.
  title_ru: Почини чтение мокрой доски
  runnerPrompt_ru: Тёрн связал доску, но ты всё ещё играешь одну пару так, будто флоп остался сухим.
  runnerSupport_ru: Сначала почини чтение доски, а не повторяй старое действие по инерции.
  runnerQuestion_ru: Что здесь нужно исправить первым?

- taskId: w6_pressure_lines_recap
  status: missing
  title_en: Pressure recap
  phase: review
  stepKind: review
  runner: _w6PressureLinesRecapRunner
  runnerPrompt_en: Lesson learned: bucket decides the action direction.
  runnerSupport_en: Value bets. Bluff candidates can bet or fold. Missed usually folds.
  runnerQuestion_en: What does each range bucket suggest?
  teachingStep0_title_en: Action follows bucket.
  teachingStep0_body_en: Assign the bucket first, then let it guide your action.
  teachingStep0_title_ru: Действие идёт за группой.
  teachingStep0_body_ru: Сначала назови группу руки, и только потом решай, нужен ли бет, чек или пас. Так решение не разваливается на ходу.
  title_ru: Повтор по давлению
  runnerPrompt_ru: Главная мысль урока: группа задаёт направление действия.
  runnerSupport_ru: Вэлью чаще ставит. Кандидат для блефа может ставить или сдаться. Промах чаще выбрасывает.
  runnerQuestion_ru: К какому действию обычно ведёт каждая группа?

## lesson range_combo_counts
status: missing
title_en: Count the combos
subtitle_en: AK has 16 combos. A pocket pair has 6.
title_ru: Считай комбинации
subtitle_ru: AK даёт 16 комбинаций, карманная пара — 6.

- taskId: w6_combo_counts_intro
  status: missing
  title_en: Why combo counts matter
  phase: theory
  stepKind: learn
  runner: _w6ComboCountsIntroRunner
  runnerPrompt_en: Ranges are not just hand names. They also have combo counts.
  runnerSupport_en: More combos means that hand family appears more often in a range.
  runnerQuestion_en: Why do combo counts matter?
  teachingStep0_title_en: Families have counts.
  teachingStep0_body_en: A non-pair hand like A-K has 16 combos before blockers. A pocket pair
  teachingStep0_title_ru: У каждой руки есть свой вес.
  teachingStep0_body_ru: Диапазон — это не только названия рук, но и то, как часто они вообще встречаются. Чем больше комбинаций, тем тяжелее это семейство внутри диапазона.
  title_ru: Зачем считать комбинации
  runnerPrompt_ru: Диапазоны состоят не только из названий рук, но и из количества комбинаций.
  runnerSupport_ru: Чем больше комбинаций, тем чаще это семейство появляется в диапазоне.
  runnerQuestion_ru: Почему количество комбинаций важно?

- taskId: w6_ak_combos
  status: missing
  title_en: AK combo count
  phase: drill
  stepKind: practice
  runner: _w6AkComboRunner
  runnerPrompt_en: A-K can be suited or offsuit.
  runnerSupport_en: Four aces can pair with four kings.
  runnerQuestion_en: How many combos does A-K have before blockers?
  teachingStep0_title_en: Families have counts.
  teachingStep0_body_en: A non-pair hand like A-K has 16 combos before blockers. A pocket pair
  teachingStep0_title_ru: У каждой руки есть свой вес.
  teachingStep0_body_ru: У A-K четыре туза и четыре короля, поэтому до блокеров получается шестнадцать сочетаний. Это и даёт вес этой руке в диапазоне.
  title_ru: Сколько комбинаций у AK
  runnerPrompt_ru: A-K бывают одномастными и разномастными.
  runnerSupport_ru: Четыре туза можно сочетать с четырьмя королями.
  runnerQuestion_ru: Сколько комбинаций у A-K до блокеров?

- taskId: w6_pair_combos
  status: missing
  title_en: Pocket pair combo count
  phase: drill
  stepKind: practice
  runner: _w6PairComboRunner
  runnerPrompt_en: Pocket eights are one pair family.
  runnerSupport_en: You pick 2 suits out of the 4 eights in the deck.
  runnerQuestion_en: How many combos does 8-8 have?
  teachingStep0_title_en: Families have counts.
  teachingStep0_body_en: A non-pair hand like A-K has 16 combos before blockers. A pocket pair
  teachingStep0_title_ru: У каждой руки есть свой вес.
  teachingStep0_body_ru: Карманная пара собирается из двух мастей из четырёх доступных карт одного ранга. Поэтому её комбинаций заметно меньше, чем у непарной руки.
  title_ru: Сколько комбинаций у пары
  runnerPrompt_ru: Карманные восьмёрки — это одно семейство пар.
  runnerSupport_ru: Ты выбираешь две масти из четырёх восьмёрок в колоде.
  runnerQuestion_ru: Сколько комбинаций у 8-8?

- taskId: w6_combo_weight_compare
  status: missing
  title_en: Which family appears more?
  phase: drill
  stepKind: practice
  runner: _w6ComboWeightCompareRunner
  runnerPrompt_en: Compare A-K with pocket eights before blockers.
  runnerSupport_en: One family has 16 combos. The other has 6.
  runnerQuestion_en: Which family appears more often in a range?
  teachingStep0_title_en: Families have counts.
  teachingStep0_body_en: A non-pair hand like A-K has 16 combos before blockers. A pocket pair
  teachingStep0_title_ru: У каждой руки есть свой вес.
  teachingStep0_body_ru: Если одно семейство имеет 16 комбинаций, а другое 6, первое будет попадаться в диапазоне заметно чаще. Чем больше комбинаций, тем чаще ты будешь встречать эту руку.
  title_ru: Что встречается чаще
  runnerPrompt_ru: Сравни A-K и карманные восьмёрки до блокеров.
  runnerSupport_ru: У одного семейства 16 комбинаций, у другого 6.
  runnerQuestion_ru: Какое семейство чаще встречается в диапазоне?

- taskId: w6_combo_counts_recap
  status: missing
  title_en: Combo recap
  phase: review
  stepKind: review
  runner: _w6ComboCountsRecapRunner
  runnerPrompt_en: Lesson learned: combo counts measure how often a hand family appears.
  runnerSupport_en: A-K = 16 combos. A pocket pair = 6 combos.
  runnerQuestion_en: What do combo counts help you measure?
  teachingStep0_title_en: Count before you guess.
  teachingStep0_body_en: Range thinking is not only names like A-K or pocket eights. The combo count shows how much weight that family carries.
  teachingStep0_title_ru: Сначала считай, потом гадай.
  teachingStep0_body_ru: Важно не только название руки, но и её частота внутри диапазона. Количество комбинаций показывает, сколько веса у семейства.
  title_ru: Повтор по комбинациям
  runnerPrompt_ru: Главная мысль урока: количество комбинаций показывает, как часто семейство рук вообще встречается.
  runnerSupport_ru: A-K = 16 комбинаций. Карманная пара = 6 комбинаций.
  runnerQuestion_ru: Что помогает измерять подсчёт комбинаций?

## lesson range_thinking_checkpoint
status: missing
title_en: Range thinking checkpoint
subtitle_en: Bucket, board fit, combo count, then pressure.
title_ru: Контрольная по диапазонам
subtitle_ru: Сначала группа, потом попадание в доску, вес комбинаций и только затем давление.

- taskId: range_checkpoint_intro
  status: missing
  title_en: Three-step read
  phase: theory
  stepKind: learn
  runner: _w6RangeIntroRunner
  runnerPrompt_en: A range is the group of hands that fit a situation.
  runnerSupport_en: Value, bluff candidate, and missed are the three range buckets.
  runnerQuestion_en: What are range buckets?
  teachingStep0_title_en: Three buckets.
  teachingStep0_body_en: After the flop, sort your hand into value (can bet for profit),
  teachingStep0_title_ru: Три группы.
  teachingStep0_body_ru: Контрольная собирает весь путь вместе: сначала группа руки, потом её связь с доской, затем вес комбинаций и только после этого действие.
  title_ru: Чтение в три шага
  runnerPrompt_ru: Диапазон — это группа рук, которые подходят под ситуацию.
  runnerSupport_ru: Здесь три базовые группы: вэлью, кандидат для блефа и промах.
  runnerQuestion_ru: Что такое группы диапазона?

- taskId: range_checkpoint_value
  status: missing
  title_en: Value on dry board
  phase: drill
  stepKind: practice
  runner: _w6ValueDryBoardRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds K-Q.
  runnerSupport_en: Top pair with the best possible kicker.
  runnerQuestion_en: Which range bucket is K-Q on this board?
  teachingStep0_title_en: Three buckets.
  teachingStep0_body_en: After the flop, sort your hand into value (can bet for profit),
  teachingStep0_title_ru: Три группы.
  teachingStep0_body_ru: Сначала назови силу руки на этой доске, а не пытайся сразу угадывать действие. Группа остаётся первой опорой.
  title_ru: Вэлью на сухой доске
  runnerPrompt_ru: K-7-2 радугой. У тебя K-Q.
  runnerSupport_ru: Топ-пара с лучшим кикером на такой доске.
  runnerQuestion_ru: В какую группу попадает K-Q на этой доске?

- taskId: range_checkpoint_board_fit
  status: missing
  title_en: Board changes bucket
  phase: drill
  stepKind: practice
  runner: _w6WrongBoardRunner
  runnerPrompt_en: 8-7-6 two-tone. Hero holds K-Q.
  runnerSupport_en: K-Q was strong preflop, but this board changed everything.
  runnerQuestion_en: Which range bucket is K-Q on 8-7-6?
  teachingStep0_title_en: Board changes the bucket.
  teachingStep0_body_en: A preflop strong hand can become missed if it does not connect with the flop.
  teachingStep0_title_ru: Доска меняет группу.
  teachingStep0_body_ru: Даже сильная префлоп-рука может резко ослабнуть, если доска ей не подходит. Здесь важно увидеть именно смену группы.
  title_ru: Доска меняет группу
  runnerPrompt_ru: 8-7-6 с двумя картами одной масти. У тебя K-Q.
  runnerSupport_ru: K-Q была сильной префлоп, но эта доска всё изменила.
  runnerQuestion_ru: В какую группу попадает K-Q на 8-7-6?

- taskId: range_checkpoint_combos
  status: missing
  title_en: Count the family
  phase: drill
  stepKind: practice
  runner: _w6AkComboRunner
  runnerPrompt_en: A-K can be suited or offsuit.
  runnerSupport_en: Four aces can pair with four kings.
  runnerQuestion_en: How many combos does A-K have before blockers?
  teachingStep0_title_en: Families have counts.
  teachingStep0_body_en: A non-pair hand like A-K has 16 combos before blockers. A pocket pair
  teachingStep0_title_ru: У семейства есть вес.
  teachingStep0_body_ru: Контрольная напоминает: диапазон — это не только названия рук, но и их частота. Вес семейства помогает не переоценивать редкие варианты.
  title_ru: Посчитай семейство
  runnerPrompt_ru: A-K бывают одномастными и разномастными.
  runnerSupport_ru: Четыре туза можно сочетать с четырьмя королями.
  runnerQuestion_ru: Сколько комбинаций у A-K до блокеров?

- taskId: range_checkpoint_pressure
  status: missing
  title_en: Bluff candidate
  phase: drill
  stepKind: practice
  runner: _w6BluffCandidateRunner
  runnerPrompt_en: K-7-2 rainbow. Hero holds A-Q.
  runnerSupport_en: Two overcards, no pair. Some fold equity exists.
  runnerQuestion_en: Which range bucket is A-Q here?
  teachingStep0_title_en: Bucket shapes action.
  teachingStep0_body_en: Value hands bet for profit. Bluff candidates bet for fold equity.
  teachingStep0_title_ru: Группа ведёт действие.
  teachingStep0_body_ru: После группы, доски и веса руки уже проще понять, есть ли давление на пас или нет. Только теперь действие начинает складываться чисто.
  title_ru: Кандидат для блефа
  runnerPrompt_ru: K-7-2 радугой. У тебя A-Q.
  runnerSupport_ru: Две оверкарты, пары нет. Есть небольшой шанс забрать банк пасом соперника.
  runnerQuestion_ru: В какую группу попадает A-Q здесь?

- taskId: range_checkpoint_review
  status: missing
  title_en: Range recap
  phase: review
  stepKind: proveIt
  runner: _world6RangeCheckpointRunner
  runnerPrompt_en: Lesson learned: range buckets need board-fit context.
  runnerSupport_en: Bucket first, board fit second, stack depth next.
  runnerQuestion_en: What carries this read into World 8?
  teachingStep0_title_en: World 7 checkpoint.
  teachingStep0_body_en: Group hands into ranges, fit them to texture, then adjust risk by stack depth.
  teachingStep0_title_ru: Контрольная мира 7.
  teachingStep0_body_ru: Сначала собери руки в диапазоны, потом привяжи их к текстуре доски, а затем уже смотри, как глубина стека меняет риск и план.
  title_ru: Повтор по диапазонам
  runnerPrompt_ru: Главная мысль урока: группы диапазона нужно читать вместе с попаданием в доску.
  runnerSupport_ru: Сначала группа, потом доска, а дальше уже глубина и риск.
  runnerQuestion_ru: Что переносит это чтение дальше, в Мир 8?


---

## Pack: world_8

# world_8 RU Translation Pack

Status: GENERATED
World number: 8
EN title: Stack Depth And Risk
EN subtitle: See why 100 BB and 20 BB need different plans.
title_ru: Глубина стека и риск
subtitle_ru: Пойми, почему 100 BB и 20 BB требуют разного мышления.

## Coverage
- Lessons: 0/4
- Tasks: 0/21
- Runner prompts: 0/21
- Runner supports: 0/21
- Runner questions: 0/21
- Teaching step titles: 0/21
- Teaching step bodies: 0/21

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson effective_stack_basics
status: missing
title_en: Effective stack
subtitle_en: The smaller stack sets the maximum risk in the hand.
title_ru: Эффективный стек
subtitle_ru: Меньший стек задаёт предел риска в раздаче.

- taskId: w7_effective_stack_intro
  status: missing
  title_en: Smaller stack rules
  phase: theory
  stepKind: learn
  runner: _w7EffectiveStackIntroRunner
  runnerPrompt_en: The smaller stack sets the maximum risk in the hand.
  runnerSupport_en: No one can win or lose more than the smaller stack.
  runnerQuestion_en: What is the effective stack?
  teachingStep0_title_en: Smaller stack rules.
  teachingStep0_body_en: If you have 200 BB and the other player has 30 BB, the effective stack is 30 BB. That smaller stack sets the real risk.
  teachingStep0_title_ru: Меньший стек решает.
  teachingStep0_body_ru: Если у тебя 200 BB, а у соперника 30 BB, реально в раздаче разыгрываются только 30 BB. Именно этот меньший стек и задаёт настоящий риск.
  title_ru: Меньший стек решает
  runnerPrompt_ru: Максимальный риск в раздаче задаёт меньший стек.
  runnerSupport_ru: Никто не может выиграть или проиграть больше, чем меньший стек.
  runnerQuestion_ru: Что такое эффективный стек?

- taskId: w7_effective_stack_30bb
  status: missing
  title_en: 200 vs 30
  phase: drill
  stepKind: practice
  runner: _w7EffectiveStackThirtyRunner
  runnerPrompt_en: Hero has 200 BB. Villain has 30 BB.
  runnerSupport_en: Look for the smaller stack.
  runnerQuestion_en: What is the effective stack?
  teachingStep0_title_en: Smaller stack rules.
  teachingStep0_body_en: If you have 200 BB and the other player has 30 BB, the effective stack is 30 BB. That smaller stack sets the real risk.
  teachingStep0_title_ru: Меньший стек решает.
  teachingStep0_body_ru: Не смотри на то, сколько покрываешь сам. Сначала найди меньший стек между двумя игроками.
  title_ru: 200 против 30
  runnerPrompt_ru: У тебя 200 BB. У соперника 30 BB.
  runnerSupport_ru: Ищи меньший стек.
  runnerQuestion_ru: Какой здесь эффективный стек?

- taskId: w7_effective_stack_100bb
  status: missing
  title_en: 100 vs 100
  phase: drill
  stepKind: practice
  runner: _w7EffectiveStackEvenRunner
  runnerPrompt_en: Hero has 100 BB. Villain has 100 BB.
  runnerSupport_en: Equal stacks keep the full depth in play.
  runnerQuestion_en: What is the effective stack?
  teachingStep0_title_en: Smaller stack rules.
  teachingStep0_body_en: If you have 200 BB and the other player has 30 BB, the effective stack is 30 BB. That smaller stack sets the real risk.
  teachingStep0_title_ru: Меньший стек решает.
  teachingStep0_body_ru: Когда стеки равны, в игре остаётся вся их глубина. Здесь эффективный стек совпадает с обоими.
  title_ru: 100 против 100
  runnerPrompt_ru: У тебя 100 BB. У соперника 100 BB.
  runnerSupport_ru: Равные стеки оставляют в игре полную глубину.
  runnerQuestion_ru: Какой здесь эффективный стек?

- taskId: w7_table_effective_notice
  status: missing
  title_en: Find the real risk
  phase: drill
  stepKind: practice
  runner: _w7EffectiveStackTableNoticeRunner
  runnerPrompt_en: You cover a player 120 BB to 18 BB on a real table.
  runnerSupport_en: Notice the number that caps the real risk.
  runnerQuestion_en: What should you notice first before planning?
  teachingStep0_title_en: Smaller stack rules.
  teachingStep0_body_en: If you have 200 BB and the other player has 30 BB, the effective stack is 30 BB. That smaller stack sets the real risk.
  teachingStep0_title_ru: Меньший стек решает.
  teachingStep0_body_ru: За живым столом легко смотреть на свой большой стек и забыть о лимите риска. Полезнее сразу заметить, сколько реально можно проиграть или выиграть.
  title_ru: Найди реальный риск
  runnerPrompt_ru: Ты покрываешь соперника: 120 BB против 18 BB за реальным столом.
  runnerSupport_ru: Заметь число, которое ставит потолок настоящему риску.
  runnerQuestion_ru: Что нужно увидеть первым до любого плана?

- taskId: w7_effective_stack_recap
  status: missing
  title_en: Effective stack recap
  phase: review
  stepKind: review
  runner: _w7EffectiveStackRecapRunner
  runnerPrompt_en: Lesson learned: the smaller stack sets the hand risk.
  runnerSupport_en: Effective stack tells you how much room the hand really has.
  runnerQuestion_en: Why does effective stack matter?
  teachingStep0_title_en: Risk starts here.
  teachingStep0_body_en: Find the smaller stack first. That tells you how deep the hand really plays.
  teachingStep0_title_ru: Риск начинается здесь.
  teachingStep0_body_ru: Сначала найди меньший стек. Он сразу показывает, насколько глубоко реально будет сыграна раздача.
  title_ru: Повтор по эффективному стеку
  runnerPrompt_ru: Главная мысль урока: меньший стек задаёт риск раздачи.
  runnerSupport_ru: Эффективный стек показывает, сколько пространства у руки на самом деле.
  runnerQuestion_ru: Почему эффективный стек так важен?

## lesson same_hand_different_depth
status: missing
title_en: Same hand, different depth
subtitle_en: A hand can widen at 20 BB and tighten at 100 BB.
title_ru: Одна рука, разная глубина
subtitle_ru: Одна и та же рука при 20 BB играется шире, чем при 100 BB.

- taskId: w7_depth_shift_intro
  status: missing
  title_en: Depth changes the plan
  phase: theory
  stepKind: learn
  runner: _w7DepthShiftIntroRunner
  runnerPrompt_en: The same hand can widen at 20 BB and tighten at 100 BB.
  runnerSupport_en: Short stacks simplify decisions. Deep stacks create more future risk.
  runnerQuestion_en: Why does stack depth change the plan?
  teachingStep0_title_en: Depth changes commitment.
  teachingStep0_body_en: At 20 BB, many hands play more simply because less money is left behind. At 100 BB, more streets mean more risk and more caution.
  teachingStep0_title_ru: Глубина меняет план.
  teachingStep0_body_ru: При 20 BB решений на будущих улицах меньше, поэтому многие руки играются проще. При 100 BB остаётся больше денег позади, и риск второй по силе руки растёт.
  title_ru: Глубина меняет план
  runnerPrompt_ru: Одна и та же рука при 20 BB может открываться шире, чем при 100 BB.
  runnerSupport_ru: Короткие стеки упрощают решение. Глубокие стеки добавляют будущий риск.
  runnerQuestion_ru: Почему глубина стека меняет план?

- taskId: w7_20bb_wider
  status: missing
  title_en: 20 BB decision
  phase: drill
  stepKind: practice
  runner: _w7TwentyBbWiderRunner
  runnerPrompt_en: You hold A-J suited with 20 BB effective.
  runnerSupport_en: Shorter stacks reduce the postflop burden.
  runnerQuestion_en: Which depth usually plays this hand more simply and more often?
  teachingStep0_title_en: Depth changes commitment.
  teachingStep0_body_en: At 20 BB, many hands play more simply because less money is left behind. At 100 BB, more streets mean more risk and more caution.
  teachingStep0_title_ru: Глубина меняет план.
  teachingStep0_body_ru: С коротким стеком меньше пространства для тяжёлых постфлоп-ошибок, поэтому многие руки играются прямее и чаще.
  title_ru: Решение при 20 BB
  runnerPrompt_ru: У тебя одномастные A-J и эффективный стек 20 BB.
  runnerSupport_ru: Короткий стек снимает часть постфлоп-нагрузки.
  runnerQuestion_ru: При какой глубине эта рука обычно играется проще и чаще?

- taskId: w7_100bb_tighter
  status: missing
  title_en: 100 BB decision
  phase: drill
  stepKind: practice
  runner: _w7HundredBbTighterRunner
  runnerPrompt_en: Now look at the same hand with 100 BB effective.
  runnerSupport_en: More streets create more ways to make a second-best hand.
  runnerQuestion_en: What changes when the hand is 100 BB deep?
  teachingStep0_title_en: Depth changes commitment.
  teachingStep0_body_en: At 20 BB, many hands play more simply because less money is left behind. At 100 BB, more streets mean more risk and more caution.
  teachingStep0_title_ru: Глубина меняет план.
  teachingStep0_body_ru: При 100 BB впереди больше улиц и больше шансов попасть во вторую по силе руку. Поэтому диапазон часто становится аккуратнее.
  title_ru: Решение при 100 BB
  runnerPrompt_ru: Теперь посмотри на ту же руку при 100 BB эффективных.
  runnerSupport_ru: Больше улиц — больше способов проиграть второй по силе рукой.
  runnerQuestion_ru: Что меняется, когда глубина уже 100 BB?

- taskId: w7_40bb_middle
  status: missing
  title_en: 40 BB middle plan
  phase: drill
  stepKind: practice
  runner: _w7FortyBbMiddleRunner
  runnerPrompt_en: Now the same hand plays 40 BB effective.
  runnerSupport_en: This is not pure jam depth and not carefree deep depth.
  runnerQuestion_en: What is the cleaner 40 BB read?
  teachingStep0_title_en: Depth changes commitment.
  teachingStep0_body_en: At 20 BB, many hands play more simply because less money is left behind. At 100 BB, more streets mean more risk and more caution.
  teachingStep0_title_ru: Глубина меняет план.
  teachingStep0_body_ru: 40 BB — это уже не пуш-фолд, но ещё и не беззаботная глубина. Здесь нужен средний, более дисциплинированный план.
  title_ru: План при 40 BB
  runnerPrompt_ru: Теперь та же рука играется при 40 BB эффективных.
  runnerSupport_ru: Это уже не чистый пуш-стек, но и не свободная глубокая игра.
  runnerQuestion_ru: Какой вывод о 40 BB здесь самый чистый?

- taskId: w7_depth_shift_recap
  status: missing
  title_en: Depth recap
  phase: review
  stepKind: review
  runner: _w7DepthShiftRecapRunner
  runnerPrompt_en: Lesson learned: stack depth changes hand value and plan.
  runnerSupport_en: Short stacks simplify. Deep stacks ask for more caution.
  runnerQuestion_en: What changes when stack depth changes?
  teachingStep0_title_en: Same hand, new plan.
  teachingStep0_body_en: Do not memorize one answer for every hand. Depth changes what the hand can safely do.
  teachingStep0_title_ru: Та же рука, новый план.
  teachingStep0_body_ru: Не запоминай один ответ на руку навсегда. Глубина меняет, что эта рука может делать безопасно.
  title_ru: Повтор по глубине
  runnerPrompt_ru: Главная мысль урока: глубина стека меняет ценность руки и план розыгрыша.
  runnerSupport_ru: Короткий стек упрощает. Глубокий просит больше аккуратности.
  runnerQuestion_ru: Что меняется, когда меняется глубина стека?

## lesson spr_and_commitment
status: missing
title_en: Room or commitment
subtitle_en: Low SPR means less room. High SPR means more room to maneuver.
title_ru: Пространство или привязка
subtitle_ru: Низкий SPR, то есть отношение стека к банку, оставляет мало пространства, высокий — больше манёвра.

- taskId: w7_spr_intro
  status: missing
  title_en: Low room vs high room
  phase: theory
  stepKind: learn
  runner: _w7SprIntroRunner
  runnerPrompt_en: SPR tells you how much room is left after the flop.
  runnerSupport_en: Low SPR means little room. High SPR means more room to maneuver.
  runnerQuestion_en: What does low SPR usually mean?
  teachingStep0_title_en: Low room, high room.
  teachingStep0_body_en: When SPR is low, one bet can commit the hand. When SPR is high, you still have room to fold, bluff, or control the pot.
  teachingStep0_title_ru: Мало места, много места.
  teachingStep0_body_ru: Когда SPR, то есть отношение стека к банку, низкий, одна ставка уже может почти привязать тебя к банку. Когда SPR высокий, ещё остаётся пространство для паса, блефа или контроля банка.
  title_ru: Мало места против большого
  runnerPrompt_ru: SPR, то есть отношение стека к банку, показывает, сколько пространства остаётся после флопа.
  runnerSupport_ru: Низкий SPR — это мало места. Высокий SPR — больше манёвра.
  runnerQuestion_ru: Что обычно означает низкий SPR?

- taskId: w7_low_spr_commit
  status: missing
  title_en: SPR 2
  phase: drill
  stepKind: practice
  runner: _w7LowSprCommitRunner
  runnerPrompt_en: SPR is 2 on the flop and you hold top pair.
  runnerSupport_en: Little room is left.
  runnerQuestion_en: What does low SPR usually tell you?
  teachingStep0_title_en: Low room, high room.
  teachingStep0_body_en: When SPR is low, one bet can commit the hand. When SPR is high, you still have room to fold, bluff, or control the pot.
  teachingStep0_title_ru: Мало места, много места.
  teachingStep0_body_ru: При SPR 2 на решение остаётся совсем немного воздуха. Здесь раздача часто быстро идёт к привязке.
  title_ru: SPR 2
  runnerPrompt_ru: На флопе SPR равен 2, и у тебя топ-пара.
  runnerSupport_ru: Пространства осталось совсем мало.
  runnerQuestion_ru: О чём обычно говорит низкий SPR?

- taskId: w7_high_spr_room
  status: missing
  title_en: SPR 8
  phase: drill
  stepKind: practice
  runner: _w7HighSprRoomRunner
  runnerPrompt_en: SPR is 8 on the flop.
  runnerSupport_en: A lot of stack is still behind.
  runnerQuestion_en: What does high SPR usually give you?
  teachingStep0_title_en: Low room, high room.
  teachingStep0_body_en: When SPR is low, one bet can commit the hand. When SPR is high, you still have room to fold, bluff, or control the pot.
  teachingStep0_title_ru: Мало места, много места.
  teachingStep0_body_ru: При SPR 8 за спиной ещё много стека, поэтому раздача не обязана ускоряться сразу. У тебя остаётся выбор на следующих улицах.
  title_ru: SPR 8
  runnerPrompt_ru: На флопе SPR равен 8.
  runnerSupport_ru: За спиной ещё много стека.
  runnerQuestion_ru: Что обычно даёт высокий SPR?

- taskId: w7_spr4_middle
  status: missing
  title_en: SPR 4
  phase: drill
  stepKind: practice
  runner: _w7SprFourRunner
  runnerPrompt_en: SPR is 4 with one pair and some stack still behind.
  runnerSupport_en: Middle SPR is neither pure jam nor huge freedom.
  runnerQuestion_en: What does SPR 4 usually feel like?
  teachingStep0_title_en: Low room, high room.
  teachingStep0_body_en: When SPR is low, one bet can commit the hand. When SPR is high, you still have room to fold, bluff, or control the pot.
  teachingStep0_title_ru: Мало места, много места.
  teachingStep0_body_ru: SPR 4 — это середина: не мгновенная привязка, но и не полная свобода. Здесь особенно важно чувствовать баланс пространства.
  title_ru: SPR 4
  runnerPrompt_ru: SPR равен 4, у тебя одна пара и часть стека ещё позади.
  runnerSupport_ru: Средний SPR — это не чистый олл-ин и не полная свобода.
  runnerQuestion_ru: Как обычно ощущается SPR 4?

- taskId: w7_spr_recap
  status: missing
  title_en: SPR recap
  phase: review
  stepKind: review
  runner: _w7SprRecapRunner
  runnerPrompt_en: Lesson learned: low SPR pushes commitment, high SPR keeps room.
  runnerSupport_en: Do not treat every flop the same when stack room changes.
  runnerQuestion_en: What does SPR help you feel?
  teachingStep0_title_en: Room matters.
  teachingStep0_body_en: Low SPR speeds up commitment. High SPR keeps later-street choices alive.
  teachingStep0_title_ru: Пространство имеет значение.
  teachingStep0_body_ru: Низкий SPR ускоряет привязку к банку. Высокий SPR оставляет живыми решения на следующих улицах.
  title_ru: Повтор по SPR
  runnerPrompt_ru: Главная мысль урока: низкий SPR тянет к привязке, высокий оставляет место.
  runnerSupport_ru: Не играй каждый флоп одинаково, если пространство в раздаче разное.
  runnerQuestion_ru: Что помогает почувствовать SPR?

## lesson format_pressure
status: missing
title_en: 6-max vs full ring
subtitle_en: The same hand can open wider in 6-max than in full ring.
title_ru: 6-max и полный стол
subtitle_ru: Одна и та же рука в 6-max открывается шире, чем за полным столом.

- taskId: w7_format_intro
  status: missing
  title_en: Format changes pressure
  phase: theory
  stepKind: learn
  runner: _w7FormatPressureIntroRunner
  runnerPrompt_en: The same hand can open wider in 6-max than in full ring.
  runnerSupport_en: Fewer players behind means less chance someone wakes up with a premium hand.
  runnerQuestion_en: Why does 6-max usually widen ranges?
  teachingStep0_title_en: Fewer players behind.
  teachingStep0_body_en: In 6-max, fewer players can wake up with a stronger hand. That usually lets ranges widen compared with full ring.
  teachingStep0_title_ru: Меньше игроков позади.
  teachingStep0_body_ru: В 6-max за тобой меньше игроков, которые могут найти руку сильнее. Поэтому диапазоны открытия там обычно шире, чем за полным столом.
  title_ru: Формат меняет давление
  runnerPrompt_ru: Одна и та же рука в 6-max может открываться шире, чем за полным столом.
  runnerSupport_ru: Чем меньше игроков позади, тем ниже шанс, что кто-то проснётся с премиум-рукой.
  runnerQuestion_ru: Почему 6-max обычно расширяет диапазоны?

- taskId: w7_6max_wider
  status: missing
  title_en: 6-max opens wider
  phase: drill
  stepKind: practice
  runner: _w7SixMaxWiderRunner
  runnerPrompt_en: A-J offsuit in early position.
  runnerSupport_en: Compare 6-max with 9-handed full ring.
  runnerQuestion_en: Where does this hand usually open wider?
  teachingStep0_title_en: Fewer players behind.
  teachingStep0_body_en: In 6-max, fewer players can wake up with a stronger hand. That usually lets ranges widen compared with full ring.
  teachingStep0_title_ru: Меньше игроков позади.
  teachingStep0_body_ru: При одинаковой руке и позиции 6-max даёт меньше давления со стороны оставшихся игроков. Поэтому открытие там чаще выглядит нормальным.
  title_ru: В 6-max шире
  runnerPrompt_ru: Разномастные A-J на ранней позиции.
  runnerSupport_ru: Сравни 6-max и полный стол на 9 игроков.
  runnerQuestion_ru: Где эта рука обычно открывается шире?

- taskId: w7_fullring_tighter
  status: missing
  title_en: Full ring tightens
  phase: drill
  stepKind: practice
  runner: _w7FullRingTighterRunner
  runnerPrompt_en: Now imagine the same hand in full ring.
  runnerSupport_en: More players still need to act.
  runnerQuestion_en: What usually changes in full ring?
  teachingStep0_title_en: Fewer players behind.
  teachingStep0_body_en: In 6-max, fewer players can wake up with a stronger hand. That usually lets ranges widen compared with full ring.
  teachingStep0_title_ru: Меньше игроков позади.
  teachingStep0_body_ru: За полным столом больше людей ещё ждут решения, поэтому давление на открытие возрастает. Та же рука часто требует больше дисциплины.
  title_ru: Полный стол сужает
  runnerPrompt_ru: Теперь представь ту же руку за полным столом.
  runnerSupport_ru: Игроков, которым ещё предстоит сказать слово, стало больше.
  runnerQuestion_ru: Что обычно меняется за полным столом?

- taskId: w7_format_table_notice
  status: missing
  title_en: Count players behind
  phase: drill
  stepKind: practice
  runner: _w7FormatTableNoticeRunner
  runnerPrompt_en: You jump from 6-max online to a 9-handed live table.
  runnerSupport_en: Start by counting how many players are still behind you.
  runnerQuestion_en: What is the first useful adjustment?
  teachingStep0_title_en: Fewer players behind.
  teachingStep0_body_en: In 6-max, fewer players can wake up with a stronger hand. That usually lets ranges widen compared with full ring.
  teachingStep0_title_ru: Меньше игроков позади.
  teachingStep0_body_ru: При смене формата не начинай с самой руки. Сначала посчитай, сколько игроков ещё позади, и только потом решай, насколько широко можно открываться.
  title_ru: Посчитай игроков позади
  runnerPrompt_ru: Ты пересел с онлайн 6-max за живой стол на 9 игроков.
  runnerSupport_ru: Начни с подсчёта тех, кто ещё сидит за тобой.
  runnerQuestion_ru: Какая первая полезная поправка нужна здесь?

- taskId: w7_format_recap
  status: missing
  title_en: Format recap
  phase: review
  stepKind: review
  runner: _w7FormatRecapRunner
  runnerPrompt_en: Lesson learned: the same hand can open wider in 6-max and tighter in full ring.
  runnerSupport_en: Format changes pressure before the cards even hit the flop.
  runnerQuestion_en: Why does format change opening pressure?
  teachingStep0_title_en: Format shapes pressure.
  teachingStep0_body_en: The hand is the same, but table format changes how often someone behind wakes up with strength.
  teachingStep0_title_ru: Формат задаёт давление.
  teachingStep0_body_ru: Сама рука не изменилась, но формат меняет, как часто за спиной найдётся сила. Именно это и двигает диапазон открытия.
  title_ru: Повтор по формату
  runnerPrompt_ru: Главная мысль урока: одна и та же рука в 6-max открывается шире, а за полным столом уже.
  runnerSupport_ru: Формат меняет давление ещё до того, как карты попадут на флоп.
  runnerQuestion_ru: Почему формат меняет давление на открытие?

- taskId: w7_stack_checkpoint
  status: missing
  title_en: Stack-depth checkpoint
  phase: review
  stepKind: proveIt
  runner: _world7StackCheckpointRunner
  runnerPrompt_en: Lesson learned: depth, SPR, and format all change risk.
  runnerSupport_en: Next you will see how tournament pressure makes stack risk even sharper.
  runnerQuestion_en: What does stack-depth thinking add to range thinking?
  teachingStep0_title_en: Carry the range into risk.
  teachingStep0_body_en: Group the range first, then ask how deep the hand plays, how much room is left, and what the format changes.
  teachingStep0_title_ru: Перенеси диапазон в риск.
  teachingStep0_body_ru: Сначала собери диапазон, потом спроси, насколько глубоко играется рука, сколько пространства осталось и как формат меняет давление. Так риск становится читаемым.
  title_ru: Контрольная по глубине стека
  runnerPrompt_ru: Главная мысль блока: глубина, SPR и формат вместе меняют риск раздачи.
  runnerSupport_ru: Дальше ты увидишь, как турнирное давление делает стековый риск ещё острее.
  runnerQuestion_ru: Что добавляет к мышлению диапазонами взгляд на глубину стека?


---

## Pack: world_9

# world_9 RU Translation Pack

Status: GENERATED
World number: 9
EN title: Tournament Pressure
EN subtitle: Learn survival pressure and risk without equations.
title_ru: Турнирное давление
subtitle_ru: Почувствуй давление выживания и риска без формул.

## Coverage
- Lessons: 0/4
- Tasks: 0/21
- Runner prompts: 0/21
- Runner supports: 0/21
- Runner questions: 0/21
- Teaching step titles: 0/21
- Teaching step bodies: 0/21

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


---

## Pack: world_10

# world_10 RU Translation Pack

Status: GENERATED
World number: 10
EN title: Player Adjustment
EN subtitle: Adjust one lever at a time against real player types.
title_ru: Подстройка под игроков
subtitle_ru: Меняй один рычаг за раз против реальных типов игроков.

## Coverage
- Lessons: 0/4
- Tasks: 0/21
- Runner prompts: 0/21
- Runner supports: 0/21
- Runner questions: 0/21
- Teaching step titles: 0/21
- Teaching step bodies: 0/21

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


---

## Pack: world_11

# world_11 RU Translation Pack

Status: GENERATED
World number: 11
EN title: Real Play Transfer
EN subtitle: Combine the course into a practical table-ready checkpoint.
title_ru: Перенос в реальную игру
subtitle_ru: Перенеси учебные решения в реальные игровые ритмы.

## Coverage
- Lessons: 0/4
- Tasks: 0/17
- Runner prompts: 0/17
- Runner supports: 0/17
- Runner questions: 0/17
- Teaching step titles: 0/17
- Teaching step bodies: 0/17

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson session_plan_basics
status: missing
title_en: Session plan in 30 seconds
subtitle_en: Pick one focus before cards are dealt.
title_ru: План сессии за 30 секунд
subtitle_ru: Выбери один фокус ещё до первой раздачи.

- taskId: w11_session_plan_intro
  status: missing
  title_en: One-focus plan
  phase: theory
  stepKind: learn
  runner: _w11SessionPlanIntroRunner
  runnerPrompt_en: Pick one concrete focus before each real session starts.
  runnerSupport_en: One focus keeps decisions clear under pressure.
  runnerQuestion_en: What is the best pre-session plan style?
  teachingStep0_title_en: One focus, many reps.
  teachingStep0_body_en: Choose one focus like blind steals, value sizing, or fold discipline. Then evaluate that same focus after the session.
  teachingStep0_title_ru: Один фокус, много повторов.
  teachingStep0_body_ru: Выбери один фокус вроде стила блайндов, размера вэлью-ставок или дисциплины паса. После сессии оценивай именно его, а не всё сразу.
  title_ru: План с одним фокусом
  runnerPrompt_ru: До начала реальной сессии выбери один конкретный фокус.
  runnerSupport_ru: Один фокус делает решения чище под давлением.
  runnerQuestion_ru: Какой стиль плана до сессии здесь самый лучший?

- taskId: w11_plan_focus_choice
  status: missing
  title_en: Choose one focus
  phase: drill
  stepKind: practice
  runner: _w11PlanFocusChoiceRunner
  runnerPrompt_en: You have 45 minutes and noisy tables today.
  runnerSupport_en: Simple focus beats wide ambition.
  runnerQuestion_en: What is the cleaner session objective?
  teachingStep0_title_en: One focus, many reps.
  teachingStep0_body_en: Choose one focus like blind steals, value sizing, or fold discipline. Then evaluate that same focus after the session.
  teachingStep0_title_ru: Один фокус, много повторов.
  teachingStep0_body_ru: Когда времени мало и столы шумные, слишком широкий план распадается. Один конкретный навык обычно даёт лучший перенос в игру.
  title_ru: Выбери один фокус
  runnerPrompt_ru: У тебя сегодня 45 минут и шумные столы.
  runnerSupport_ru: Простой фокус почти всегда лучше широкой амбиции.
  runnerQuestion_ru: Какая цель сессии здесь будет чище?

- taskId: w11_plan_avoid_overload
  status: missing
  title_en: Avoid overload plan
  phase: drill
  stepKind: practice
  runner: _w11PlanAvoidOverloadRunner
  runnerPrompt_en: Your prior session had scattered notes and no clear pattern.
  runnerSupport_en: Reduce cognitive load first.
  runnerQuestion_en: What is the sharper adjustment?
  teachingStep0_title_en: One focus, many reps.
  teachingStep0_body_en: Choose one focus like blind steals, value sizing, or fold discipline. Then evaluate that same focus after the session.
  teachingStep0_title_ru: Один фокус, много повторов.
  teachingStep0_body_ru: Если в прошлой сессии заметки разъехались во все стороны, сначала убери перегруз. Простая цель обычно чинит это лучше всего.
  title_ru: Не перегружай план
  runnerPrompt_ru: В прошлой сессии у тебя были разбросанные заметки и ни одного ясного паттерна.
  runnerSupport_ru: Сначала снизь когнитивную нагрузку.
  runnerQuestion_ru: Какая подстройка здесь будет острее?

- taskId: w11_session_plan_recap
  status: missing
  title_en: Session-plan recap
  phase: review
  stepKind: review
  runner: _w11SessionPlanRecapRunner
  runnerPrompt_en: Lesson learned: one focus plan creates cleaner real-play transfer.
  runnerSupport_en: Simple plan first, then repetitions.
  runnerQuestion_en: What is the session-plan takeaway?
  teachingStep0_title_en: One focus, many reps.
  teachingStep0_body_en: Choose one focus like blind steals, value sizing, or fold discipline. Then evaluate that same focus after the session.
  teachingStep0_title_ru: Один фокус, много повторов.
  teachingStep0_body_ru: Сессия переносится в реальную игру лучше, когда у неё одна ясная тема и серия повторов, а не длинный список идей.
  title_ru: Повтор по плану сессии
  runnerPrompt_ru: Главная мысль урока: один фокус делает перенос в реальную игру чище.
  runnerSupport_ru: Сначала простой план, потом серия повторов.
  runnerQuestion_ru: Какой главный вывод по плану сессии здесь нужен?

## lesson table_trigger_reads
status: missing
title_en: In-session trigger reads
subtitle_en: Spot one trigger and apply one adjustment immediately.
title_ru: Сигналы во время сессии
subtitle_ru: Заметь один сигнал и сразу привяжи к нему одну подстройку.

- taskId: w11_trigger_intro
  status: missing
  title_en: Trigger-first loop
  phase: theory
  stepKind: learn
  runner: _w11TriggerReadIntroRunner
  runnerPrompt_en: When a trigger appears, apply one prepared adjustment quickly.
  runnerSupport_en: Trigger -> one lever -> observe result.
  runnerQuestion_en: What is a trigger read for transfer play?
  teachingStep0_title_en: Pattern to action.
  teachingStep0_body_en: If blinds overfold, steal a bit wider. If a player overcalls, value heavier. Use one lever per trigger.
  teachingStep0_title_ru: От наблюдения к действию.
  teachingStep0_body_ru: Если блайнды часто пасуют, стил чуть расширяется. Если соперник переплачивает коллами, вэлью становится тяжелее. На каждый сигнал нужна одна простая подстройка.
  title_ru: Сигнал и подстройка
  runnerPrompt_ru: Когда появляется понятный сигнал, быстро применяй одну заранее подготовленную подстройку.
  runnerSupport_ru: Один сигнал, один рычаг, потом наблюдение за результатом.
  runnerQuestion_ru: Что такое сигнал для чтения за реальным столом?

- taskId: w11_trigger_overfold_blinds
  status: missing
  title_en: Blind overfold trigger
  phase: drill
  stepKind: practice
  runner: _w11TriggerOverfoldBlindsRunner
  runnerPrompt_en: Both blinds folded to 5 of your last 6 steals.
  runnerSupport_en: Overfold trigger supports a preflop widen lever.
  runnerQuestion_en: What is the cleaner transfer action?
  teachingStep0_title_en: Pattern to action.
  teachingStep0_body_en: If blinds overfold, steal a bit wider. If a player overcalls, value heavier. Use one lever per trigger.
  teachingStep0_title_ru: От паттерна к действию.
  teachingStep0_body_ru: Если оба блайнда слишком часто сдаются, это уже не шум, а рабочий сигнал. Первый ответ здесь должен быть простым и отслеживаемым.
  title_ru: Сигнал: блайнды часто пасуют
  runnerPrompt_ru: Оба блайнда выбросили на 5 из 6 последних твоих стилов.
  runnerSupport_ru: Такой сигнал поддерживает расширение префлоп-стила.
  runnerQuestion_ru: Какое действие переноса здесь самое чистое?

- taskId: w11_trigger_overcall_flop
  status: missing
  title_en: Overcall trigger
  phase: drill
  stepKind: practice
  runner: _w11TriggerOvercallFlopRunner
  runnerPrompt_en: Villain keeps calling flop and turn with weak pairs.
  runnerSupport_en: Overcall trigger points to value-density change.
  runnerQuestion_en: What is the sharper one-lever response?
  teachingStep0_title_en: Pattern to action.
  teachingStep0_body_en: If blinds overfold, steal a bit wider. If a player overcalls, value heavier. Use one lever per trigger.
  teachingStep0_title_ru: От паттерна к действию.
  teachingStep0_body_ru: Если игрок снова и снова доплачивает слабыми руками, усиливай добор, а не изобретай сложную подстройку. Один рычаг здесь снова лучший путь.
  title_ru: Сигнал: соперник переплачивает коллами
  runnerPrompt_ru: Соперник снова и снова платит флоп и тёрн со слабыми парами.
  runnerSupport_ru: Такой сигнал подсказывает ставить плотнее на вэлью.
  runnerQuestion_ru: Какой ответ одним рычагом здесь будет острее?

- taskId: w11_trigger_recap
  status: missing
  title_en: Trigger recap
  phase: review
  stepKind: review
  runner: _w11TriggerReadRecapRunner
  runnerPrompt_en: Lesson learned: trigger reads convert pattern into one action lever.
  runnerSupport_en: Trigger must be repeated, not imagined.
  runnerQuestion_en: What is the trigger-read takeaway?
  teachingStep0_title_en: Pattern to action.
  teachingStep0_body_en: If blinds overfold, steal a bit wider. If a player overcalls, value heavier. Use one lever per trigger.
  teachingStep0_title_ru: От паттерна к действию.
  teachingStep0_body_ru: Сигнал должен повторяться, а не быть фантазией после одной руки. Только тогда перенос в реальную игру остаётся устойчивым.
  title_ru: Повтор по сигналам
  runnerPrompt_ru: Главная мысль урока: сигналы переводят наблюдение в одно рабочее действие.
  runnerSupport_ru: Сигнал должен повторяться, а не придумыватьcя на ходу.
  runnerQuestion_ru: Какой главный вывод по чтению сигналов здесь нужен?

## lesson post_session_review_loop
status: missing
title_en: Post-session review loop
subtitle_en: Convert one leak into one repair target for tomorrow.
title_ru: Цикл разбора сессии
subtitle_ru: Переводи один лик в одну задачу на исправление к завтрашней игре.

- taskId: w11_review_loop_intro
  status: missing
  title_en: One leak one fix
  phase: theory
  stepKind: learn
  runner: _w11ReviewLoopIntroRunner
  runnerPrompt_en: After play, name one leak and one repair target for tomorrow.
  runnerSupport_en: One leak, one fix, one next session test.
  runnerQuestion_en: What makes review actionable?
  teachingStep0_title_en: Close the loop daily.
  teachingStep0_body_en: Session plan starts the day, trigger reads guide live play, review loop sets tomorrow focus. That cycle compounds skill.
  teachingStep0_title_ru: Закрывай цикл каждый день.
  teachingStep0_body_ru: План запускает день, сигналы ведут игру, а разбор после сессии ставит завтрашний фокус. Именно этот цикл и накапливает навык.
  title_ru: Один лик, одно исправление
  runnerPrompt_ru: После игры назови один лик, то есть слабое место в игре, и одну цель на исправление к завтрашней сессии.
  runnerSupport_ru: Один лик, одно исправление, один тест в следующей игре.
  runnerQuestion_ru: Что делает разбор действительно рабочим?

- taskId: w11_review_pick_leak
  status: missing
  title_en: Pick priority leak
  phase: drill
  stepKind: practice
  runner: _w11ReviewPickLeakRunner
  runnerPrompt_en: Today you missed thin value and overcalled one river.
  runnerSupport_en: Pick the leak that repeats most often first.
  runnerQuestion_en: What is the clean first review action?
  teachingStep0_title_en: Close the loop daily.
  teachingStep0_body_en: Session plan starts the day, trigger reads guide live play, review loop sets tomorrow focus. That cycle compounds skill.
  teachingStep0_title_ru: Закрывай цикл каждый день.
  teachingStep0_body_ru: Если ошибок несколько, сначала выбери ту, что повторяется чаще всего и сильнее всего стоит фишек. Это и будет лучший первый ремонт.
  title_ru: Выбери главный лик
  runnerPrompt_ru: Сегодня ты недобрал тонкое вэлью и один раз переплатил ривер.
  runnerSupport_ru: Сначала выбирай тот лик, который повторяется чаще всего.
  runnerQuestion_ru: Какое первое действие в разборе здесь самое чистое?

- taskId: w11_review_define_fix
  status: missing
  title_en: Define tomorrow fix
  phase: drill
  stepKind: practice
  runner: _w11ReviewDefineFixRunner
  runnerPrompt_en: Priority leak: overcalling rivers vs tight players.
  runnerSupport_en: Define an if-then fix for next session.
  runnerQuestion_en: Which repair target is most actionable?
  teachingStep0_title_en: Close the loop daily.
  teachingStep0_body_en: Session plan starts the day, trigger reads guide live play, review loop sets tomorrow focus. That cycle compounds skill.
  teachingStep0_title_ru: Закрывай цикл каждый день.
  teachingStep0_body_ru: Хороший разбор не заканчивается абстрактным “играть лучше”. Он должен превратиться в конкретное правило на следующую сессию.
  title_ru: Сформулируй завтрашнее исправление
  runnerPrompt_ru: Главный лик: лишние коллы на ривере против тайтовых игроков.
  runnerSupport_ru: Сформулируй для следующей сессии правило в формате «если-то».
  runnerQuestion_ru: Какая цель на исправление здесь самая рабочая?

- taskId: w11_review_loop_recap
  status: missing
  title_en: Review-loop recap
  phase: review
  stepKind: review
  runner: _w11ReviewLoopRecapRunner
  runnerPrompt_en: Lesson learned: review closes the transfer loop into tomorrow.
  runnerSupport_en: Write one leak and one fix before ending session.
  runnerQuestion_en: What is the review-loop takeaway?
  teachingStep0_title_en: Close the loop daily.
  teachingStep0_body_en: Session plan starts the day, trigger reads guide live play, review loop sets tomorrow focus. That cycle compounds skill.
  teachingStep0_title_ru: Закрывай цикл каждый день.
  teachingStep0_body_ru: Разбор сессии работает только тогда, когда даёт тебе один понятный фокус на следующую игру.
  title_ru: Повтор по петле разбора
  runnerPrompt_ru: Главная мысль урока: разбор замыкает петлю переноса в завтрашнюю игру.
  runnerSupport_ru: До конца сессии запиши один лик и одно исправление.
  runnerQuestion_ru: Какой главный вывод по петле разбора здесь нужен?

## lesson real_play_transfer_checkpoint
status: missing
title_en: Real-play transfer checkpoint
subtitle_en: Plan, trigger, review, then repeat as a daily loop.
title_ru: Контрольная по переносу в реальную игру
subtitle_ru: План, сигнал, разбор и повторение в ежедневной петле.

- taskId: w11_checkpoint_intro
  status: missing
  title_en: Transfer loop map
  phase: theory
  stepKind: learn
  runner: _w11SessionPlanIntroRunner
  runnerPrompt_en: Pick one concrete focus before each real session starts.
  runnerSupport_en: One focus keeps decisions clear under pressure.
  runnerQuestion_en: What is the best pre-session plan style?
  teachingStep0_title_en: One focus, many reps.
  teachingStep0_body_en: Choose one focus like blind steals, value sizing, or fold discipline. Then evaluate that same focus after the session.
  teachingStep0_title_ru: Один фокус, много повторов.
  teachingStep0_body_ru: Контрольная собирает весь цикл: до сессии один фокус, во время игры один сигнал и одна подстройка, после игры один разбор и новая цель на завтра.
  title_ru: Карта петли переноса
  runnerPrompt_ru: До начала каждой реальной сессии выбери один конкретный фокус.
  runnerSupport_ru: Один фокус держит решения ясными под давлением.
  runnerQuestion_ru: Какой стиль плана до сессии здесь самый лучший?

- taskId: w11_checkpoint_plan_line
  status: missing
  title_en: Plan line
  phase: drill
  stepKind: practice
  runner: _w11CheckpointPlanLineRunner
  runnerPrompt_en: You start a session after a long workday with low energy.
  runnerSupport_en: Plan should stay simple and executable.
  runnerQuestion_en: What is the clean transfer plan?
  teachingStep0_title_en: Close the loop daily.
  teachingStep0_body_en: Session plan starts the day, trigger reads guide live play, review loop sets tomorrow focus. That cycle compounds skill.
  teachingStep0_title_ru: Закрывай цикл каждый день.
  teachingStep0_body_ru: После тяжёлого дня план должен становиться проще, а не шире. Рабочий перенос любит исполнимость, а не амбициозность.
  title_ru: Линия плана
  runnerPrompt_ru: Ты начинаешь сессию после длинного рабочего дня и с низкой энергией.
  runnerSupport_ru: План должен оставаться простым и исполнимым.
  runnerQuestion_ru: Какой план переноса здесь самый чистый?

- taskId: w11_checkpoint_trigger_line
  status: missing
  title_en: Trigger line
  phase: drill
  stepKind: practice
  runner: _w11CheckpointTriggerLineRunner
  runnerPrompt_en: You detect repeated blind overfold and river underbluff patterns.
  runnerSupport_en: Pick one trigger-action pair first.
  runnerQuestion_en: Which transfer action is best?
  teachingStep0_title_en: Close the loop daily.
  teachingStep0_body_en: Session plan starts the day, trigger reads guide live play, review loop sets tomorrow focus. That cycle compounds skill.
  teachingStep0_title_ru: Закрывай цикл каждый день.
  teachingStep0_body_ru: Даже если ты видишь несколько перекосов, сначала выбери одну пару «сигнал -> действие». Это помогает держать реальную игру под контролем.
  title_ru: Линия сигнала
  runnerPrompt_ru: Ты замечаешь частые пасы блайндов и редкий доблеф на ривере.
  runnerSupport_ru: Сначала выбери одну пару сигнал-действие.
  runnerQuestion_ru: Какое действие переноса здесь лучше всего?

- taskId: w11_checkpoint_review_line
  status: missing
  title_en: Review line
  phase: drill
  stepKind: practice
  runner: _w11CheckpointReviewLineRunner
  runnerPrompt_en: Session ends with mixed results and two recurring mistakes.
  runnerSupport_en: Review should output one next-session repair task.
  runnerQuestion_en: What is the strongest closeout action?
  teachingStep0_title_en: Close the loop daily.
  teachingStep0_body_en: Session plan starts the day, trigger reads guide live play, review loop sets tomorrow focus. That cycle compounds skill.
  teachingStep0_title_ru: Закрывай цикл каждый день.
  teachingStep0_body_ru: Правильное завершение сессии — это не эмоции, а чёткая цель. Даже после тяжёлого дня найди одну конкретную ошибку, которую исправишь завтра.
  title_ru: Линия разбора
  runnerPrompt_ru: Сессия заканчивается смешанным результатом и двумя повторяющимися ошибками.
  runnerSupport_ru: Разбор должен выдать одну задачу на исправление к следующей игре.
  runnerQuestion_ru: Какое завершающее действие здесь самое сильное?

- taskId: w11_checkpoint_review
  status: missing
  title_en: Real-play recap
  phase: review
  stepKind: proveIt
  runner: _world11RealPlayCheckpointRunner
  runnerPrompt_en: Lesson learned: plan, trigger, and review form one daily transfer loop.
  runnerSupport_en: This closes the core route and feeds your daily play-review habit loop. Next you build the mindset bridge.
  runnerQuestion_en: What does real-play transfer produce when done well?
  teachingStep0_title_en: Loop beats intensity.
  teachingStep0_body_en: Sustainable progress comes from repeating a clean transfer loop daily, not from occasional complex sessions.
  teachingStep0_title_ru: Цикл сильнее разового рывка.
  teachingStep0_body_ru: Устойчивый прогресс строится на чистой ежедневной петле, а не на редких сложных сессиях. В этом и есть настоящий перенос в живую игру.
  title_ru: Повтор по реальной игре
  runnerPrompt_ru: Главная мысль урока: план, сигнал и разбор образуют одну ежедневную петлю переноса.
  runnerSupport_ru: Это закрывает базовый маршрут и кормит ежедневную привычку играть и разбирать. Дальше идёт мост к игровому мышлению.
  runnerQuestion_ru: Что даёт хороший перенос в реальную игру?


---

## Pack: world_12

# world_12 RU Translation Pack

Status: GENERATED
World number: 12
EN title: Mindset Bridge
EN subtitle: Stabilize process, reset, and discipline for deeper postflop work.
title_ru: Мост к мышлению игрока
subtitle_ru: Собери дисциплину, ясность и устойчивый игровой тон.

## Coverage
- Lessons: 0/4
- Tasks: 0/17
- Runner prompts: 0/16
- Runner supports: 0/16
- Runner questions: 0/16
- Teaching step titles: 0/16
- Teaching step bodies: 0/16

## Translator Rules
- Keep ids unchanged.
- Translate only `*_ru` fields.
- Keep tone calm, compact, and table-literate.
- Do not mirror English word order mechanically.
- Improve stiff landed lines here instead of patching UI-local strings.

## Return Format
Edit this file in place or return the same structure with updated `*_ru` fields.

## lesson decision_over_outcome
status: missing
title_en: Decision quality over outcome
subtitle_en: Judge decisions by process, not one result.
title_ru: Качество решения важнее результата
subtitle_ru: Оценивай раздачи по процессу, а не по одному исходу.

- taskId: w12_decision_quality_intro
  status: missing
  title_en: Process first
  phase: theory
  stepKind: learn
  runner: _w12DecisionQualityIntroRunner
  runnerPrompt_en: Short-term outcomes can lie. Process quality must stay the anchor.
  runnerSupport_en: Judge choices by logic, not one card on river.
  runnerQuestion_en: What should be judged first after a hand?
  teachingStep0_title_en: Process beats variance.
  teachingStep0_body_en: Good decisions can lose and bad decisions can win. Improvement comes from process quality, not short-term emotional swings.
  teachingStep0_title_ru: Процесс сильнее дисперсии.
  teachingStep0_body_ru: Хорошее решение может проиграть, а плохое — выиграть. Рост приходит из качества процесса, а не из коротких эмоциональных качелей результата.
  title_ru: Сначала процесс
  runnerPrompt_ru: Короткий результат может врать. Опорой должно оставаться качество процесса.
  runnerSupport_ru: Оценивай выбор по логике, а не по одной карте на ривере.
  runnerQuestion_ru: Что нужно судить первым после раздачи?

- taskId: w12_good_fold_bad_result
  status: missing
  title_en: Good fold, bad result
  phase: drill
  stepKind: practice
  runner: _w12GoodFoldBadResultRunner
  runnerPrompt_en: You folded a marginal bluff-catcher and villain later showed a bluff.
  runnerSupport_en: Do not auto-label by reveal result only.
  runnerQuestion_en: What is the sharper review reaction?
  teachingStep0_title_en: Process beats variance.
  teachingStep0_body_en: Good decisions can lose and bad decisions can win. Improvement comes from process quality, not short-term emotional swings.
  teachingStep0_title_ru: Процесс сильнее дисперсии.
  teachingStep0_body_ru: Если соперник потом показал блеф, это ещё не доказывает, что твой фолд был плохим. Сначала проверь логику решения, а не сам факт вскрытия.
  title_ru: Хороший пас, плохой результат
  runnerPrompt_ru: Ты выбросил пограничную руку для колла, а потом соперник показал блеф.
  runnerSupport_ru: Не вешай ярлык только по открытому результату.
  runnerQuestion_ru: Какая реакция разбора здесь будет острее?

- taskId: w12_bad_call_good_result
  status: missing
  title_en: Bad call, lucky win
  phase: drill
  stepKind: practice
  runner: _w12BadCallGoodResultRunner
  runnerPrompt_en: You made a loose call and got lucky on river.
  runnerSupport_en: Winning the pot does not guarantee a good decision.
  runnerQuestion_en: What is the best mindset response?
  teachingStep0_title_en: Process beats variance.
  teachingStep0_body_en: Good decisions can lose and bad decisions can win. Improvement comes from process quality, not short-term emotional swings.
  teachingStep0_title_ru: Процесс сильнее дисперсии.
  teachingStep0_body_ru: Выигранный банк не автоматически делает колл правильным. Удача не должна закрывать глаза на слабую логику.
  title_ru: Плохой колл, удачная победа
  runnerPrompt_ru: Ты сделал слишком широкий колл и доехал на ривере.
  runnerSupport_ru: Выигранный банк сам по себе не подтверждает качество решения.
  runnerQuestion_ru: Какой ответ по мышлению здесь лучший?

- taskId: w12_decision_quality_recap
  status: missing
  title_en: Process recap
  phase: review
  stepKind: review
  runner: _w12DecisionQualityRecapRunner
  runnerPrompt_en: Lesson learned: process quality is the anchor under variance.
  runnerSupport_en: Outcome is data, not verdict.
  runnerQuestion_en: What is the process-quality takeaway?
  teachingStep0_title_en: Process beats variance.
  teachingStep0_body_en: Good decisions can lose and bad decisions can win. Improvement comes from process quality, not short-term emotional swings.
  teachingStep0_title_ru: Процесс сильнее дисперсии.
  teachingStep0_body_ru: Исход — это данные, но не приговор качеству игры. Устойчивый игрок сначала проверяет процесс.
  title_ru: Повтор по процессу
  runnerPrompt_ru: Главная мысль урока: качество процесса остаётся опорой под дисперсией.
  runnerSupport_ru: Исход раздачи — это данные, а не финальный вердикт.
  runnerQuestion_ru: Какой главный вывод по качеству процесса здесь нужен?

## lesson tilt_reset_protocol
status: missing
title_en: Tilt reset protocol
subtitle_en: Use a short reset so one hand does not own the session.
title_ru: Протокол перезагрузки после тильта
subtitle_ru: Короткая перезагрузка не даёт одной раздаче захватить всю сессию.

- taskId: w12_tilt_reset_intro
  status: missing
  title_en: Reset in under 20s
  phase: theory
  stepKind: learn
  runner: _w12TiltResetIntroRunner
  runnerPrompt_en: One short reset can protect decision quality after emotional spikes.
  runnerSupport_en: Pause, breathe, re-anchor to plan.
  runnerQuestion_en: What is the purpose of a tilt reset?
  teachingStep0_title_en: Fast reset loop.
  teachingStep0_body_en: Name the emotion, take one breath cycle, restate your one-focus plan, then continue with smaller decision scope.
  teachingStep0_title_ru: Быстрая перезагрузка.
  teachingStep0_body_ru: Назови эмоцию, сделай один спокойный цикл дыхания, повтори свой текущий фокус и сузь масштаб следующего решения. Этого часто уже достаточно.
  title_ru: Перезагрузка меньше чем за 20 секунд
  runnerPrompt_ru: Одна короткая перезагрузка помогает сохранить качество решений после эмоционального всплеска.
  runnerSupport_ru: Пауза, дыхание, возврат к плану.
  runnerQuestion_ru: В чём цель быстрой перезагрузки после тильта?

- taskId: w12_after_bad_beat_reset
  status: missing
  title_en: After bad beat
  phase: drill
  stepKind: practice
  runner: _w12AfterBadBeatResetRunner
  runnerPrompt_en: You lose a big all-in as favorite and feel immediate anger.
  runnerSupport_en: Reset before next hand starts.
  runnerQuestion_en: What is the cleaner immediate action?
  teachingStep0_title_en: Fast reset loop.
  teachingStep0_body_en: Name the emotion, take one breath cycle, restate your one-focus plan, then continue with smaller decision scope.
  teachingStep0_title_ru: Быстрая перезагрузка.
  teachingStep0_body_ru: После болезненного переезда важнее всего не нести гнев в следующую раздачу. Сначала короткая перезагрузка, потом новое решение.
  title_ru: После болезненного переезда
  runnerPrompt_ru: Ты проиграл крупный олл-ин фаворитом и сразу чувствуешь злость.
  runnerSupport_ru: Сначала короткая перезагрузка, потом следующая раздача.
  runnerQuestion_ru: Какое действие здесь самое чистое прямо сейчас?

- taskId: w12_after_mistake_reset
  status: missing
  title_en: After your own mistake
  phase: drill
  stepKind: practice
  runner: _w12AfterMistakeResetRunner
  runnerPrompt_en: You realize you made an avoidable call error.
  runnerSupport_en: Use reset to prevent second error spiral.
  runnerQuestion_en: What response keeps discipline highest?
  teachingStep0_title_en: Fast reset loop.
  teachingStep0_body_en: Name the emotion, take one breath cycle, restate your one-focus plan, then continue with smaller decision scope.
  teachingStep0_title_ru: Быстрая перезагрузка.
  teachingStep0_body_ru: Собственная ошибка легко запускает вторую ошибку подряд. Перезагрузка здесь нужна не для красоты, а чтобы оборвать спираль.
  title_ru: После собственной ошибки
  runnerPrompt_ru: Ты понимаешь, что только что сделал тяжёлый колл на эмоциях.
  runnerSupport_ru: Используй короткую перезагрузку, чтобы не допустить вторую ошибку подряд.
  runnerQuestion_ru: Какой ответ здесь лучше всего сохраняет дисциплину?

- taskId: w12_tilt_reset_recap
  status: missing
  title_en: Reset recap
  phase: review
  stepKind: review
  runner: _w12TiltResetRecapRunner
  runnerPrompt_en: Lesson learned: reset protects process under emotional pressure.
  runnerSupport_en: Fast reset now prevents leak cascade later.
  runnerQuestion_en: What is the reset takeaway?
  teachingStep0_title_en: Fast reset loop.
  teachingStep0_body_en: Name the emotion, take one breath cycle, restate your one-focus plan, then continue with smaller decision scope.
  teachingStep0_title_ru: Быстрая перезагрузка.
  teachingStep0_body_ru: Быстрая перезагрузка защищает процесс до того, как мелкий срыв превратится в целую цепочку ошибок. Именно скорость здесь и ценна.
  title_ru: Повтор по перезагрузке
  runnerPrompt_ru: Главная мысль урока: перезагрузка защищает процесс под эмоциональным давлением.
  runnerSupport_ru: Быстрая перезагрузка сейчас не даёт ошибкам разрастись позже.
  runnerQuestion_ru: Какой главный вывод по перезагрузке здесь нужен?

## lesson confidence_and_discipline
status: missing
title_en: Confidence with discipline
subtitle_en: Play assertively without drifting into ego calls.
title_ru: Уверенность с дисциплиной
subtitle_ru: Играй уверенно, но не скатывайся в упрямые коллы и споры с собой.

- taskId: w12_confidence_intro
  status: missing
  title_en: Calm assertive baseline
  phase: theory
  stepKind: learn
  runner: _w12ConfidenceDisciplineIntroRunner
  runnerPrompt_en: Confident play means clear actions, not ego battles.
  runnerSupport_en: Assertive decisions still obey plan and evidence.
  runnerQuestion_en: What balance should confidence hold?
  teachingStep0_title_en: Assertive, not reckless.
  teachingStep0_body_en: Take clear lines when evidence supports them. Avoid ego calls, revenge bluffs, or proving points.
  teachingStep0_title_ru: Уверенно, не безрассудно.
  teachingStep0_body_ru: Чёткие линии хороши, когда их держит доказательство. Уверенность не должна превращаться в обиду, месть или желание что-то доказать.
  title_ru: Спокойная уверенная база
  runnerPrompt_ru: Уверенная игра — это ясные действия, а не попытка что-то себе доказать.
  runnerSupport_ru: Уверенные решения всё равно подчиняются плану и доказательствам.
  runnerQuestion_ru: Какой баланс должна держать уверенность?

- taskId: w12_assertive_not_ego
  status: missing
  title_en: Assertive, not ego
  phase: drill
  stepKind: practice
  runner: _w12AssertiveNotEgoRunner
  runnerPrompt_en: Villain needles you after winning a pot.
  runnerSupport_en: Decision quality should not react to table talk.
  runnerQuestion_en: What is the stronger mindset line?
  teachingStep0_title_en: Assertive, not reckless.
  teachingStep0_body_en: Take clear lines when evidence supports them. Avoid ego calls, revenge bluffs, or proving points.
  teachingStep0_title_ru: Уверенно, не безрассудно.
  teachingStep0_body_ru: Реплика соперника не должна толкать тебя в упрямый колл или блеф из злости. Сильная линия здесь — не кормить разговор своим решением.
  title_ru: Уверенно, без упрямства
  runnerPrompt_ru: Соперник поддевает тебя после выигранного банка.
  runnerSupport_ru: Качество решения не должно зависеть от разговоров за столом.
  runnerQuestion_ru: Какая линия мышления здесь сильнее?

- taskId: w12_discipline_under_pressure
  status: missing
  title_en: Discipline under pressure
  phase: drill
  stepKind: practice
  runner: _w12DisciplineUnderPressureRunner
  runnerPrompt_en: Deep in session, fatigue rises and decisions speed up.
  runnerSupport_en: Discipline means slowing only the critical spots.
  runnerQuestion_en: What is the best pressure adjustment?
  teachingStep0_title_en: Assertive, not reckless.
  teachingStep0_body_en: Take clear lines when evidence supports them. Avoid ego calls, revenge bluffs, or proving points.
  teachingStep0_title_ru: Уверенно, не безрассудно.
  teachingStep0_body_ru: Усталость не требует тормозить всё подряд. Дисциплина здесь чаще значит чуть замедлить только критические споты.
  title_ru: Дисциплина под давлением
  runnerPrompt_ru: Ближе к концу сессии усталость растёт, и решения начинают ускоряться.
  runnerSupport_ru: Дисциплина здесь значит замедлять только по-настоящему важные споты.
  runnerQuestion_ru: Какая подстройка под давление здесь будет лучшей?

- taskId: w12_confidence_recap
  status: missing
  title_en: Confidence recap
  phase: review
  stepKind: review
  runner: _w12ConfidenceDisciplineRecapRunner
  title_ru: Повтор по уверенности

## lesson mindset_bridge_checkpoint
status: missing
title_en: Mindset bridge checkpoint
subtitle_en: Carry process, reset, and discipline into postflop growth.
title_ru: Контрольная по игровому мышлению
subtitle_ru: Забери процесс, перезагрузку и дисциплину с собой в более глубокую постфлоп-игру.

- taskId: w12_checkpoint_intro
  status: missing
  title_en: Mindset loop map
  phase: theory
  stepKind: learn
  runner: _w12DecisionQualityIntroRunner
  runnerPrompt_en: Short-term outcomes can lie. Process quality must stay the anchor.
  runnerSupport_en: Judge choices by logic, not one card on river.
  runnerQuestion_en: What should be judged first after a hand?
  teachingStep0_title_en: Process beats variance.
  teachingStep0_body_en: Good decisions can lose and bad decisions can win. Improvement comes from process quality, not short-term emotional swings.
  teachingStep0_title_ru: Процесс сильнее дисперсии.
  teachingStep0_body_ru: Контрольная собирает весь мост: сначала процесс против результата, потом быстрая перезагрузка и затем уверенная дисциплина. Только на такой базе сложная стратегия закрепляется.
  title_ru: Карта цикла мышления
  runnerPrompt_ru: Короткий результат может врать. Опорой должно оставаться качество процесса.
  runnerSupport_ru: Оценивай выбор по логике, а не по одной карте на ривере.
  runnerQuestion_ru: Что нужно судить первым после раздачи?

- taskId: w12_checkpoint_process_line
  status: missing
  title_en: Process line
  phase: drill
  stepKind: practice
  runner: _w12CheckpointProcessLineRunner
  runnerPrompt_en: A correct line loses in a high-variance pot.
  runnerSupport_en: Process verdict comes before emotional verdict.
  runnerQuestion_en: What is the best immediate checkpoint reaction?
  teachingStep0_title_en: Assertive, not reckless.
  teachingStep0_body_en: Take clear lines when evidence supports them. Avoid ego calls, revenge bluffs, or proving points.
  teachingStep0_title_ru: Уверенно, не безрассудно.
  teachingStep0_body_ru: Даже если правильная линия проиграла большой банк, первый чекпоинт — не эмоция, а качество решения. Именно это удерживает рост.
  title_ru: Фокус на процессе
  runnerPrompt_ru: Правильная линия проиграла банк в споте с высокой дисперсией.
  runnerSupport_ru: Вердикт по процессу должен прийти раньше эмоционального вердикта.
  runnerQuestion_ru: Какая реакция на таком checkpoint здесь самая лучшая?

- taskId: w12_checkpoint_reset_line
  status: missing
  title_en: Reset line
  phase: drill
  stepKind: practice
  runner: _w12CheckpointResetLineRunner
  runnerPrompt_en: You feel tilt signs after two rough spots in a row.
  runnerSupport_en: Reset should be fast and repeatable.
  runnerQuestion_en: What is the cleaner bridge action?
  teachingStep0_title_en: Assertive, not reckless.
  teachingStep0_body_en: Take clear lines when evidence supports them. Avoid ego calls, revenge bluffs, or proving points.
  teachingStep0_title_ru: Уверенно, не безрассудно.
  teachingStep0_body_ru: Если ты чувствуешь признаки тильта, мост обратно в стабильность должен быть коротким и повторяемым. Перезагрузка здесь важнее анализа на полстраницы.
  title_ru: Линия перезагрузки
  runnerPrompt_ru: После двух тяжёлых спотов подряд ты чувствуешь признаки тильта.
  runnerSupport_ru: Перезагрузка должна быть быстрой и повторяемой.
  runnerQuestion_ru: Какое мостовое действие здесь самое чистое?

- taskId: w12_checkpoint_discipline_line
  status: missing
  title_en: Discipline line
  phase: drill
  stepKind: practice
  runner: _w12CheckpointDisciplineLineRunner
  runnerPrompt_en: A player taunts you into marginal high-variance spots.
  runnerSupport_en: Discipline means evidence over ego.
  runnerQuestion_en: Which line is strongest?
  teachingStep0_title_en: Assertive, not reckless.
  teachingStep0_body_en: Take clear lines when evidence supports them. Avoid ego calls, revenge bluffs, or proving points.
  teachingStep0_title_ru: Уверенно, не безрассудно.
  teachingStep0_body_ru: Когда соперник провоцирует тебя на пограничные споты, дисциплина значит держать факты выше эмоций. Это и есть зрелая уверенность.
  title_ru: Линия дисциплины
  runnerPrompt_ru: Игрок пытается поддеть тебя и втянуть в пограничные, высокодисперсионные споты.
  runnerSupport_ru: Дисциплина здесь значит ставить факты выше эмоций.
  runnerQuestion_ru: Какая линия здесь будет самой сильной?

- taskId: w12_checkpoint_review
  status: missing
  title_en: Mindset recap
  phase: review
  stepKind: proveIt
  runner: _world12MindsetCheckpointRunner
  runnerPrompt_en: Lesson learned: process, reset, and discipline stabilize your game.
  runnerSupport_en: Next you carry this mindset into deeper postflop decision trees and pressure spots.
  runnerQuestion_en: What does mindset bridge add before deeper strategy worlds?
  teachingStep0_title_en: Stability before complexity.
  teachingStep0_body_en: Strong strategy growth requires stable mindset loops. Process audits, resets, and discipline make advanced learning stick.
  teachingStep0_title_ru: Стабильность раньше сложности.
  teachingStep0_body_ru: Рост в сложной стратегии начинается не с блестящих линий, а со стабильного процесса, умения быстро перезагружаться и дисциплины.
  title_ru: Повтор по игровому мышлению
  runnerPrompt_ru: Главная мысль: фокус на процессе, быстрая перезагрузка и дисциплина — фундамент стабильной игры.
  runnerSupport_ru: Дальше это игровое мышление переносится уже в более глубокие постфлоп-деревья и споты под давлением.
  runnerQuestion_ru: Что даёт этот mindset bridge перед более глубокими стратегическими мирами?

