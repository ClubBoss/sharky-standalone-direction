part of '../act0_content_copy_v1.dart';

const Map<String, Act0WorldDisplayCopyV1>
_ruWorldCopyByIdV1 = <String, Act0WorldDisplayCopyV1>{
  'world_1': Act0WorldDisplayCopyV1(
    title: 'Покер с нуля',
    subtitle: 'Грамотность за столом: карты, места, блайнды, стек и банк.',
  ),
  'world_2': Act0WorldDisplayCopyV1(
    title: 'Дисциплина рук',
    subtitle: 'Пойми, какие руки стоят фишек, а какие спокойно уходят в пас.',
  ),
  'world_3': Act0WorldDisplayCopyV1(
    title: 'Мышление позицией',
    subtitle: 'Почувствуй, почему порядок мест меняет силу руки и комфорт.',
  ),
  'world_4': Act0WorldDisplayCopyV1(
    title: 'Префлоп-каркас',
    subtitle: 'Смотри на руку, место и действие до того, как выбирать линию.',
  ),
  'world_5': Act0WorldDisplayCopyV1(
    title: 'Смысл ставки и цена',
    subtitle: 'Пойми вэлью, блеф, защиту и цену колла без перегруза.',
  ),
  'world_6': Act0WorldDisplayCopyV1(
    title: 'Борд и дро',
    subtitle: 'Читай текстуру борда, дро и то, как улицы меняют план.',
  ),
  'world_7': Act0WorldDisplayCopyV1(
    title: 'Диапазоны без перегруза',
    subtitle: 'Группируй руки в простые диапазоны без солверного шума.',
  ),
  'world_8': Act0WorldDisplayCopyV1(
    title: 'Глубина стека и риск',
    subtitle: 'Пойми, почему 100 BB и 20 BB требуют разного мышления.',
  ),
  'world_9': Act0WorldDisplayCopyV1(
    title: 'Турнирное давление',
    subtitle: 'Почувствуй давление выживания и риска без формул.',
  ),
  'world_10': Act0WorldDisplayCopyV1(
    title: 'Подстройка под игроков',
    subtitle: 'Меняй один рычаг за раз против реальных типов игроков.',
  ),
  'world_11': Act0WorldDisplayCopyV1(
    title: 'Перенос в реальную игру',
    subtitle: 'Перенеси учебные решения в реальные игровые ритмы.',
  ),
  'world_12': Act0WorldDisplayCopyV1(
    title: 'Мост к мышлению игрока',
    subtitle: 'Собери дисциплину, ясность и устойчивый игровой тон.',
  ),
};

const Map<String, Act0LessonDisplayCopyV1>
_ruLessonCopyByIdV1 = <String, Act0LessonDisplayCopyV1>{
  'what_poker_is': Act0LessonDisplayCopyV1(
    title: 'Что такое покер',
    subtitle: 'Познакомься со столом, игроками и целью раздачи.',
  ),
  'cards_ranks_suits': Act0LessonDisplayCopyV1(
    title: 'Карты, ранги и масти',
    subtitle: '52 карты, 4 масти, 13 рангов.',
  ),
  'your_first_hand': Act0LessonDisplayCopyV1(
    title: 'Твоя первая раздача',
    subtitle: 'Проследи раздачу от старта до шоудауна.',
  ),
  'fold_check_call_raise': Act0LessonDisplayCopyV1(
    title: 'Фолд, чек, колл, рейз',
    subtitle: 'Научись называть каждое действие до решения.',
  ),
  'blinds_action_order': Act0LessonDisplayCopyV1(
    title: 'Блайнды и порядок действий',
    subtitle: 'Почему кто-то всегда кладёт фишки первым.',
  ),
  'positions': Act0LessonDisplayCopyV1(
    title: '6 позиций за столом',
    subtitle: 'У каждого места за столом есть имя и роль.',
  ),
  'hand_rankings_table': Act0LessonDisplayCopyV1(
    title: 'Старшинство рук на борде',
    subtitle: 'Что бьёт что на реальных бордах.',
  ),
  'showdown_winning': Act0LessonDisplayCopyV1(
    title: 'Шоудаун и победа',
    subtitle: 'Как раздача действительно заканчивается.',
  ),
  'hand_discipline_buckets': Act0LessonDisplayCopyV1(
    title: 'Группы стартовых рук',
    subtitle:
        'Сначала разложи руку по простой группе, а уже потом вкладывай фишки.',
  ),
  'hand_discipline_apply': Act0LessonDisplayCopyV1(
    title: 'Дисциплина за столом',
    subtitle:
        'Сначала группа руки, потом место и ситуация. Дальше решение проще.',
  ),
};

const Map<String, String> _ruLessonTitleByEnglishV1 = <String, String>{
  'What poker is': 'Что такое покер',
  'Cards, ranks & suits': 'Карты, ранги и масти',
  'Your first hand, dealt': 'Твоя первая раздача',
  'Fold, check, call, raise': 'Фолд, чек, колл, рейз',
  'Blinds & action order': 'Блайнды и порядок действий',
  'The 6 positions': '6 позиций за столом',
  'Hand rankings, on the table': 'Старшинство рук на борде',
  'Showdown & winning': 'Шоудаун и победа',
};

const Map<String, Act0TaskDisplayCopyV1>
_ruTaskCopyByIdV1 = <String, Act0TaskDisplayCopyV1>{
  'what_poker_is_theory': Act0TaskDisplayCopyV1(
    title: 'Знакомство со столом',
    summary:
        'Разберись в базовой картине: места, фишки, карты и то, что стол пытается определить.',
    runnerPrompt: 'Твоё место всегда внизу. С него и начинай чтение стола.',
    runnerSupport:
        'Сначала найди своё место, блайнды и баттон. Эти ориентиры держат всю раздачу понятной.',
    runnerQuestion: 'Где находится место Hero?',
  ),
  'what_poker_is_find_hero': Act0TaskDisplayCopyV1(
    title: 'Найди своё место',
    summary:
        'Сначала научись видеть, где сидит Hero, и только потом отслеживай остальное.',
    runnerPrompt:
        'Сначала найди своё место, а уже потом смотри на остальной стол.',
    runnerSupport:
        'Привычка простая: сперва свои карты и своё место, потом всё остальное.',
    runnerQuestion: 'Какое место принадлежит Hero?',
  ),
  'what_poker_is_pot_stack': Act0TaskDisplayCopyV1(
    title: 'Банк и стек',
    summary:
        'Отделяй фишки в банке от фишек, которые ещё лежат в стеке игрока.',
    runnerPrompt: 'Стек — это твои фишки. Банк — то, за что сейчас борются.',
    runnerSupport: 'Не смешивай личные фишки игрока с фишками в центре стола.',
    runnerQuestion: 'Где лежат фишки, за которые идёт борьба?',
  ),
  'what_poker_is_win_ways': Act0TaskDisplayCopyV1(
    title: 'Как выигрывают банк',
    summary:
        'Увидь два базовых финала раздачи: все пасуют или карты доходят до шоудауна.',
    runnerPrompt:
        'Банк забирают либо без вскрытия, либо лучшей рукой на шоудауне.',
    runnerSupport:
        'На старте достаточно держать в голове только эти два финала.',
    runnerQuestion: 'Как можно выиграть банк?',
  ),
  'what_poker_is_showdown_win': Act0TaskDisplayCopyV1(
    title: 'Победа на шоудауне',
    summary: 'Определи, какая рука выигрывает, когда все карты уже открыты.',
    runnerPrompt: 'На шоудауне банк уходит лучшей руке.',
    runnerSupport: 'Сравнивай не отдельные карты, а итоговые лучшие пять.',
    runnerQuestion: 'Что решает исход шоудауна?',
  ),
  'what_poker_is_table_read_transfer': Act0TaskDisplayCopyV1(
    title: 'Первое чтение живого стола',
    summary:
        'Перенеси первое чтение стола в живую раздачу: сначала свои карты, потом борд, потом банк.',
    runnerPrompt:
        'Сначала посмотри на свои карты, потом на борд, потом на банк.',
    runnerSupport:
        'Этот порядок не даёт расплыться вниманию: свои карты, общие карты, потом размер банка.',
    runnerQuestion: 'С чего лучше начать быстрое чтение стола?',
  ),
  'what_poker_is_review': Act0TaskDisplayCopyV1(
    title: 'Повтор по столу',
    summary:
        'Пройди чтение стола целиком и чисто: место, банк и финал раздачи.',
    runnerPrompt: 'Сначала прочитай стол, потом уже думай о решении.',
    runnerSupport:
        'Hero — это ты, блайнды запускают первый банк, а стол подсказывает, что происходит.',
    runnerQuestion: 'Что такое банк?',
  ),
  'cards_ranks_suits_theory': Act0TaskDisplayCopyV1(
    title: 'Колода',
    runnerPrompt: 'Каждая карта состоит из ранга и масти.',
    runnerSupport: 'В колоде 52 карты. Ты читаешь карту через эти две части.',
    runnerQuestion: 'Из каких двух частей состоит карта?',
  ),
  'cards_ranks_suits_rank_drill': Act0TaskDisplayCopyV1(
    title: 'Старшая карта',
    runnerPrompt: 'Сначала сравни ранг, потом уже всё остальное.',
    runnerSupport: 'В этом начальном дрилле туз старше короля.',
    runnerQuestion: 'Какой ранг здесь старше?',
  ),
  'cards_ranks_suits_suit_drill': Act0TaskDisplayCopyV1(
    title: 'Назови масть',
    runnerPrompt: 'У карты всегда есть и ранг, и масть.',
    runnerSupport: 'Здесь масти записаны коротко: s, h, d, c.',
    runnerQuestion: 'Какая масть у Ah?',
  ),
  'cards_ranks_suits_private_board': Act0TaskDisplayCopyV1(
    title: 'Карманные и борд',
    runnerPrompt: 'Карманные карты твои, борд общий для всех.',
    runnerSupport:
        'Твои две карты остаются у Hero, а карты борда могут использовать все.',
    runnerQuestion: 'Какие карты доступны всем игрокам?',
  ),
  'cards_ranks_suits_board_count': Act0TaskDisplayCopyV1(
    title: 'Сколько карт на борде',
    runnerPrompt: 'Полный борд всегда состоит из пяти общих карт.',
    runnerSupport: 'Флоп — три, тёрн — четыре, ривер — пять.',
    runnerQuestion: 'Сколько карт борда может быть видно к риверу?',
  ),
  'cards_ranks_suits_best_five': Act0TaskDisplayCopyV1(
    title: 'Идея лучших пяти',
    runnerPrompt:
        'Итоговая рука в покере всегда собирается из лучших пяти карт.',
    runnerSupport:
        'Карманные карты и борд работают вместе, но в зачёт идут только лучшие пять.',
    runnerQuestion: 'Сколько карт составляют итоговую руку?',
  ),
  'cards_ranks_suits_recap': Act0TaskDisplayCopyV1(
    title: 'Повтор по картам',
    summary:
        'Докажи, что уверенно разделяешь ранг, масть, борд и идею лучших пяти карт.',
    runnerPrompt: 'У каждой карты есть своя работа в раздаче.',
    runnerSupport:
        'Ранги сравнивают силу, масти собирают флеши, а борд даёт общие карты.',
    runnerQuestion: 'Что означают карты борда?',
  ),
  'your_first_hand_preflop': Act0TaskDisplayCopyV1(
    title: 'Префлоп',
    runnerPrompt: 'Твои две карты остаются с тобой всю раздачу.',
    runnerSupport:
        'Карты борда появятся позже. Сначала у тебя только две карманные.',
    runnerQuestion: 'Сколько карманных карт ты получаешь на старте?',
  ),
  'your_first_hand_flop': Act0TaskDisplayCopyV1(
    title: 'Флоп',
    runnerPrompt: 'Флоп кладёт в центр три общие карты.',
    runnerSupport:
        'Эти карты уже могут использовать все, кто остался в раздаче.',
    runnerQuestion: 'Сколько карт лежит на этом флопе?',
  ),
  'your_first_hand_turn': Act0TaskDisplayCopyV1(
    title: 'Тёрн',
    runnerPrompt: 'Тёрн — это четвёртая карта борда.',
    runnerSupport: 'После флопа из трёх карт тёрн делает борд из четырёх.',
    runnerQuestion: 'Сколько карт борда видно на тёрне?',
  ),
  'your_first_hand_river': Act0TaskDisplayCopyV1(
    title: 'Ривер',
    runnerPrompt: 'Ривер закрывает борд пятой общей картой.',
    runnerSupport: 'После ривера общий борд уже полностью собран.',
    runnerQuestion: 'Сколько карт борда видно на ривере?',
  ),
  'your_first_hand_showdown': Act0TaskDisplayCopyV1(
    title: 'Чтение шоудауна',
    runnerPrompt: 'На шоудауне банк забирает лучшая рука.',
    runnerSupport:
        'Сравнивай итоговую лучшую пятёрку, а не случайные отдельные карты.',
    runnerQuestion: 'Что решает шоудаун?',
  ),
  'your_first_hand_action_trail': Act0TaskDisplayCopyV1(
    title: 'Цепочка действий',
    runnerPrompt: 'Лента действий показывает, что случилось по улицам.',
    runnerSupport: 'Читай её слева направо как короткую историю раздачи.',
    runnerQuestion: 'Какой элемент в ленте произошёл последним?',
  ),
  'your_first_hand_recap': Act0TaskDisplayCopyV1(
    title: 'Повтор по улицам',
    runnerPrompt: 'Улицы держат порядок времени в раздаче.',
    runnerSupport: 'Сначала идёт префлоп без борда, потом флоп, тёрн и ривер.',
    runnerQuestion: 'Какая улица идёт после тёрна?',
  ),
  'actions_theory': Act0TaskDisplayCopyV1(
    title: 'Слова действий',
    summary: 'Сначала закрепи четыре главных глагола: фолд, чек, колл и рейз.',
    runnerPrompt: 'Сначала назови действие, потом принимай решение.',
    runnerSupport:
        'Держись простого каркаса: фолд уходит, чек не добавляет фишек, колл уравнивает, рейз повышает цену.',
  ),
  'actions_legal_context': Act0TaskDisplayCopyV1(
    title: 'Разрешённые действия',
    summary:
        'Свяжи состояние стола с теми действиями, которые здесь действительно разрешены.',
    lockedSummary:
        'Сначала открой Слова действий, потом этот узел начнёт читаться правильно.',
    runnerPrompt: 'Смотри на ставку на столе и убери невозможные действия.',
    runnerSupport:
        'Сначала прочитай состояние стола, потом оставь только те действия, которые здесь вообще доступны.',
  ),
  'actions_check_drill': Act0TaskDisplayCopyV1(
    title: 'Чек без ставки',
    summary:
        'Распознай единственный момент, когда чек бесплатен и действительно правильный.',
    lockedSummary:
        'Сначала закрой Слова действий, потом откроется чтение спота без ставки.',
    runnerPrompt: 'Если ставки нет, проверь, открыт ли бесплатный чек.',
    runnerSupport:
        'Чек существует только тогда, когда до тебя никто не поставил. Ищи именно это условие.',
  ),
  'actions_fold_drill': Act0TaskDisplayCopyV1(
    title: 'Фолд слабых рук',
    summary:
        'Натренируй чистый выход из спота, где продолжение только сожжёт фишки.',
    lockedSummary:
        'Сначала пройди вступление, потом вернись к этому ремонтному узлу.',
    runnerPrompt: 'Слабая рука без цены не обязана продолжать.',
    runnerSupport:
        'Фолд сохраняет стек, когда продолжение не даёт внятной причины вкладывать фишки дальше.',
  ),
  'actions_call_drill': Act0TaskDisplayCopyV1(
    title: 'Колл по цене',
    summary:
        'Пойми, когда колл по цене остаётся самым дешёвым и верным продолжением.',
    lockedSummary:
        'Этот шаг откроется после Слов действий, когда базовые глаголы станут устойчивыми.',
    runnerPrompt: 'Когда цена разумная, колл просто держит раздачу в игре.',
    runnerSupport:
        'Колл не выигрывает раздачу сразу, но часто остаётся самым спокойным и дешёвым продолжением.',
  ),
  'actions_raise_drill': Act0TaskDisplayCopyV1(
    title: 'Открытие на баттоне',
    summary:
        'Используй рейз в самом чистом споте для новичка: все выбросили, а ты на баттоне.',
    lockedSummary:
        'Сначала выучи меню действий, потом открывай агрессивный вариант.',
    runnerPrompt:
        'Когда все выбросили до тебя на баттоне, рейз забирает инициативу.',
    runnerSupport:
        'Рейз открывает раздачу давлением. На баттоне без предыдущей ставки это самый чистый учебный пример.',
  ),
  'actions_review': Act0TaskDisplayCopyV1(
    title: 'Повтор по действиям',
    summary: 'Докажи, что можешь называть правильное действие без подсказок.',
    lockedSummary:
        'Повтор откроется после того, как дриллы по действиям будут закрыты чисто.',
    runnerPrompt: 'Назови действие быстро и без лишних догадок.',
    runnerSupport:
        'Собери всё вместе: прочитай стол, отсеки невозможное и назови лучшее действие.',
  ),
  'blinds_theory': Act0TaskDisplayCopyV1(title: 'Блайнды ставятся первыми'),
  'blinds_posts_drill': Act0TaskDisplayCopyV1(title: 'Кто ставит 1 BB'),
  'blinds_first_actor': Act0TaskDisplayCopyV1(title: 'Первый на префлопе'),
  'blinds_last_actor': Act0TaskDisplayCopyV1(title: 'Последний на префлопе'),
  'blinds_postflop_button': Act0TaskDisplayCopyV1(
    title: 'Последний на постфлопе',
  ),
  'blinds_button_moves': Act0TaskDisplayCopyV1(title: 'Баттон двигается'),
  'blinds_review': Act0TaskDisplayCopyV1(title: 'Повтор по порядку'),
  'positions_theory': Act0TaskDisplayCopyV1(
    title: 'Шесть мест за столом',
    runnerPrompt:
        'У каждого места за столом своё имя: UTG, HJ, CO, BTN, SB и BB.',
    runnerSupport:
        'Эти названия нужны не для красоты. Они сразу подсказывают, когда и с каким объёмом информации ты действуешь.',
    runnerQuestion: 'Какое место здесь называется баттоном?',
  ),
  'positions_button': Act0TaskDisplayCopyV1(
    title: 'Найди баттон',
    runnerPrompt: 'Баттон показывает позицию дилера в этой раздаче.',
    runnerSupport:
        'Ищи метку BTN. Это самое удобное место для старта знакомства с позициями.',
    runnerQuestion: 'Где здесь баттон?',
  ),
  'positions_utg': Act0TaskDisplayCopyV1(
    title: 'Найди UTG',
    runnerPrompt: 'UTG открывает префлоп раньше всех.',
    runnerSupport:
        'Это ранняя позиция. Здесь действуют с наименьшим количеством информации.',
    runnerQuestion: 'Какое место здесь называется UTG?',
  ),
  'positions_cutoff': Act0TaskDisplayCopyV1(
    title: 'Найди cutoff',
    runnerPrompt: 'Cutoff сидит прямо перед баттоном.',
    runnerSupport:
        'Ищи метку CO. Это уже поздняя позиция, но ещё не самый конец очереди.',
    runnerQuestion: 'Где здесь cutoff?',
  ),
  'positions_late_seat': Act0TaskDisplayCopyV1(
    title: 'Что даёт поздняя позиция',
    runnerPrompt:
        'Поздняя позиция позволяет сначала посмотреть на чужие действия.',
    runnerSupport:
        'Чем позже ты решаешь, тем больше подсказок успеваешь собрать до своего хода.',
    runnerQuestion:
        'Какое место чаще всего действует позже остальных после флопа?',
  ),
  'positions_early_late': Act0TaskDisplayCopyV1(
    title: 'Ранние и поздние места',
    runnerPrompt: 'Ранние места решают вслепую чаще, поздние видят больше.',
    runnerSupport:
        'UTG действует почти сразу, а баттон обычно получает самую полную картину перед решением.',
    runnerQuestion: 'Какое место здесь раннее на префлопе?',
  ),
  'positions_review': Act0TaskDisplayCopyV1(
    title: 'Повтор по позициям',
    runnerPrompt:
        'Главная мысль проста: позиция меняет не силу карты, а удобство решения.',
    runnerSupport:
        'Ранние места требуют большей аккуратности, поздние дают больше информации и свободы.',
    runnerQuestion: 'Какое место здесь действует позже остальных после флопа?',
  ),
  'hand_rankings_theory': Act0TaskDisplayCopyV1(
    title: 'Руки сравнивают по силе',
    runnerPrompt:
        'Названия рук нужны затем, чтобы быстро понять, что старше на шоудауне.',
    runnerSupport:
        'На старте держи в голове короткую лестницу: пара, две пары, сет, стрит, флеш.',
    runnerQuestion: 'Что именно сравнивают старшинства рук?',
  ),
  'hand_rankings_pair_drill': Act0TaskDisplayCopyV1(
    title: 'Найди пару',
    runnerPrompt: 'Пара уже сильнее просто старшей карты.',
    runnerSupport:
        'Ищи два совпадающих ранга. Это первый устойчивый made hand в базовой лестнице.',
    runnerQuestion: 'Что собрал Hero в этом примере?',
  ),
  'hand_rankings_two_pair_drill': Act0TaskDisplayCopyV1(
    title: 'Две пары против одной',
    runnerPrompt: 'Две пары уже старше одной пары.',
    runnerSupport:
        'Сначала посмотри, сколько совпадений по рангам получилось у каждой руки, и только потом сравнивай их силу.',
    runnerQuestion: 'Какая рука здесь старше?',
  ),
  'hand_rankings_trips_drill': Act0TaskDisplayCopyV1(
    title: 'Сет или трипс',
    runnerPrompt: 'Три карты одного ранга уже поднимают руку выше двух пар.',
    runnerSupport:
        'Не цепляйся за название. Важно увидеть саму структуру: три одинаковых ранга.',
    runnerQuestion: 'Что здесь сильнее двух пар?',
  ),
  'hand_rankings_straight_drill': Act0TaskDisplayCopyV1(
    title: 'Найди стрит',
    runnerPrompt: 'Стрит — это пять рангов подряд.',
    runnerSupport:
        'Смотри не на масти, а на последовательность: пять, шесть, семь, восемь, девять и так далее.',
    runnerQuestion: 'Из чего складывается стрит?',
  ),
  'hand_rankings_flush_drill': Act0TaskDisplayCopyV1(
    title: 'Флеш сильнее стрита',
    runnerPrompt: 'Флеш собирается из пяти карт одной масти.',
    runnerSupport:
        'Если перед тобой флеш и стрит, побеждает флеш. Это стоит закрепить отдельно.',
    runnerQuestion: 'Какая рука здесь старше: флеш или стрит?',
  ),
  'hand_rankings_best_five_drill': Act0TaskDisplayCopyV1(
    title: 'Выбери лучшие пять',
    runnerPrompt:
        'На вскрытии всегда сравнивают не все карты подряд, а лучшие пять.',
    runnerSupport:
        'Лишние карты не считаются. Важно собрать самую сильную пятёрку из карманных и борда.',
    runnerQuestion: 'Сколько карт реально считаются на шоудауне?',
  ),
  'hand_rankings_review': Act0TaskDisplayCopyV1(
    title: 'Повтор по старшинству',
    runnerPrompt: 'На вскрытии побеждает та рука, чьи лучшие пять старше.',
    runnerSupport:
        'Пара, две пары, сет, стрит и флеш должны читаться уже без суеты.',
    runnerQuestion: 'Что здесь старше: флеш или стрит?',
  ),
  'showdown_theory': Act0TaskDisplayCopyV1(
    title: 'Два пути к банку',
    runnerPrompt:
        'Раздача заканчивается либо пасами соперников, либо сравнением рук на шоудауне.',
    runnerSupport:
        'Если все выбросили, вскрытия не будет. Если дошли до конца, сравнивают лучшие пять карт.',
    runnerQuestion: 'Какие два главных пути есть к победе в раздаче?',
  ),
  'showdown_foldout_drill': Act0TaskDisplayCopyV1(
    title: 'Все выбросили',
    runnerPrompt: 'Если все соперники выбросили, банк твой сразу.',
    runnerSupport:
        'Здесь не нужно ждать вскрытия. Последний оставшийся игрок просто забирает банк.',
    runnerQuestion: 'Что происходит, если все выбросили до тебя?',
  ),
  'showdown_best_hand_drill': Act0TaskDisplayCopyV1(
    title: 'Лучшая рука на вскрытии',
    runnerPrompt: 'На шоудауне побеждает не красивая, а старшая рука.',
    runnerSupport:
        'Сравнивай лучшие пять карт у каждого игрока и не отвлекайся на лишние детали.',
    runnerQuestion: 'Что решает исход шоудауна?',
  ),
  'showdown_kicker_drill': Act0TaskDisplayCopyV1(
    title: 'Та же пара, лучший кикер',
    runnerPrompt:
        'Если основная пара у обоих одна и та же, решает боковая карта.',
    runnerSupport:
        'Эта боковая карта называется кикером. Она часто ломает кажущуюся ничью.',
    runnerQuestion: 'Что может разбить ничью при одинаковой паре?',
  ),
  'showdown_board_plays_drill': Act0TaskDisplayCopyV1(
    title: 'Играет борд',
    runnerPrompt:
        'Иногда лучшая пятёрка уже целиком лежит на борде, без помощи карманных карт.',
    runnerSupport:
        'Если оба игрока используют одну и ту же пятёрку с борда, никто не получает преимущества.',
    runnerQuestion:
        'Что может случиться, если у обоих играет один и тот же борд?',
  ),
  'showdown_tie_drill': Act0TaskDisplayCopyV1(
    title: 'Разделить банк',
    runnerPrompt: 'Ничья на шоудауне значит, что банк делят.',
    runnerSupport:
        'Так бывает, когда лучшие пять карт у обоих игроков полностью совпадают.',
    runnerQuestion: 'Что происходит с банком при ничьей?',
  ),
  'showdown_review': Act0TaskDisplayCopyV1(
    title: 'Повтор по победе',
    runnerPrompt:
        'Теперь ты уже видишь оба финала раздачи: все выбросили или лучшая рука дошла до вскрытия.',
    runnerSupport:
        'Это завершает первый круг чтения раздачи: стол, улицы, старшинство рук и способы забрать банк.',
    runnerQuestion: 'Что выигрывает на шоудауне?',
  ),
  'hand_discipline_buckets_intro': Act0TaskDisplayCopyV1(
    title: 'Четыре группы',
    summary:
        'Перед действием сначала назови группу руки: премиум, сильная, средняя или мусор.',
    runnerPrompt: 'Сначала назови группу руки, а уже потом думай о действии.',
    runnerSupport:
        'Этот первый фильтр убирает суету: премиум и сильные руки играются иначе, чем средние и мусорные.',
    runnerQuestion: 'Что лучше назвать до действия?',
  ),
  'hand_discipline_buckets_premium': Act0TaskDisplayCopyV1(
    title: 'Премиум-рука',
    summary:
        'Закрепи верхнюю группу стартовых рук, с которой банк чаще хочется разгонять.',
    runnerPrompt: 'Сначала определи группу руки.',
    runnerSupport:
        'Премиум-руки не требуют сложных оправданий: они чаще хотят строить банк, а не прятаться.',
    runnerQuestion: 'Какая группа у АА?',
  ),
  'hand_discipline_buckets_strong': Act0TaskDisplayCopyV1(
    title: 'Сильная рука',
    summary:
        'Отделяй очень играбельные руки от настоящего премиума без лишней драматизации.',
    runnerPrompt: 'Назови группу руки до выбора линии.',
    runnerSupport:
        'Сильная рука почти всегда играбельна, но это ещё не вершина диапазона.',
    runnerQuestion: 'Какая группа у JJ?',
  ),
  'hand_discipline_buckets_medium': Act0TaskDisplayCopyV1(
    title: 'Средняя рука',
    summary:
        'Средние руки любят аккуратность: им уже важны место за столом и удобный контекст.',
    runnerPrompt: 'Сначала пойми, насколько рука пограничная.',
    runnerSupport:
        'Средняя рука не обязана лезть в каждый банк. Ей нужен более удобный спот, чем премиуму.',
    runnerQuestion: 'Какая группа у KQo?',
  ),
  'hand_discipline_buckets_trash': Act0TaskDisplayCopyV1(
    title: 'Мусорная рука',
    summary:
        'Слабый оффсьют без хорошего места и цены чаще приносит только лишние проблемы.',
    runnerPrompt: 'Слабая рука не обязана становиться приключением.',
    runnerSupport:
        'Если рука не тянет на продолжение, дисциплина экономит фишки простым фолдом.',
    runnerQuestion: 'К какой группе отнести J8o в ранней позиции?',
  ),
  'hand_discipline_buckets_borderline': Act0TaskDisplayCopyV1(
    title: 'Погранично сильная',
    summary:
        'Некоторые руки уже сильные, хотя внешне ещё не выглядят как абсолютный топ.',
    runnerPrompt: 'Не путай просто сильную руку с премиумом.',
    runnerSupport:
        'Эта группа всё ещё играет уверенно, но ей не нужно приписывать силу самого верха.',
    runnerQuestion: 'Какая группа здесь ближе всего?',
  ),
  'hand_discipline_buckets_recap': Act0TaskDisplayCopyV1(
    title: 'Повтор по группам',
    summary:
        'Собери привычку целиком: сначала группа руки, потом уже всё остальное.',
    runnerPrompt: 'До действия сначала назови группу руки.',
    runnerSupport:
        'Когда рука быстро попадает в нужную группу, префлоп-решения становятся спокойнее и чище.',
    runnerQuestion: 'Какая префлоп-привычка здесь первая?',
  ),
  'apply_intro': Act0TaskDisplayCopyV1(
    title: 'Привычка в три шага',
    summary:
        'Группа руки, место и ситуация дают простую опору ещё до выбора действия.',
    runnerPrompt:
        'Иди по порядку: группа руки, место, ситуация, потом действие.',
    runnerSupport:
        'Этот каркас убирает суету: сначала пойми, что за рука и где ты сидишь, а потом решай, стоят ли фишки входа.',
    runnerQuestion: 'Какой порядок здесь самый чистый?',
  ),
  'apply_utg_fold': Act0TaskDisplayCopyV1(
    title: 'UTG, мусорная рука',
    summary:
        'Когда рука слабая, а место раннее, дисциплина чаще всего экономит стек простым фолдом.',
    runnerPrompt: 'Ранняя позиция плюс мусорная рука редко требуют героизма.',
    runnerSupport:
        'Не усложняй спот. Если рука слабая и ты говоришь первым, фолд сохраняет фишки и внимание.',
    runnerQuestion: 'Какое действие здесь самое чистое?',
  ),
  'apply_btn_open': Act0TaskDisplayCopyV1(
    title: 'Баттон, сильная рука',
    summary:
        'Сильная рука на баттоне в чистом банке часто превращается в спокойное открытие.',
    runnerPrompt: 'Сильная рука на баттоне любит инициативу.',
    runnerSupport:
        'Когда до тебя все выбросили, поздняя позиция и хорошая рука дают чистый повод открыть раздачу.',
    runnerQuestion: 'Какое действие здесь самое чистое?',
  ),
  'apply_hj_decision': Act0TaskDisplayCopyV1(
    title: 'HJ, средняя рука',
    summary:
        'Средняя рука в средней позиции просит аккуратного решения, а не автоматического продолжения.',
    runnerPrompt: 'Средняя рука любит контекст сильнее, чем автопилот.',
    runnerSupport:
        'Здесь важно не упрямство, а трезвый каркас: группа руки, место и ситуация должны дать чистую причину продолжать.',
    runnerQuestion: 'Какое решение здесь выглядит наиболее дисциплинированным?',
  ),
  'apply_recap': Act0TaskDisplayCopyV1(
    title: 'Дисциплина держится',
    summary:
        'Проверь, что каркас не разваливается под давлением: группа руки, место, ситуация, действие.',
    runnerPrompt: 'Собери весь каркас в один спокойный префлоп-ритм.',
    runnerSupport:
        'Хорошая дисциплина не ищет подвигов. Она снова и снова приводит к чистому решению по понятным причинам.',
    runnerQuestion: 'Чего должны избегать знакомые, но слабые руки?',
  ),
  'position_apply_intro': Act0TaskDisplayCopyV1(
    title: 'Позиция меняет решение',
    runnerPrompt: 'Позиция заранее подсказывает, насколько руке будет удобно.',
    runnerSupport:
        'Баттон даёт больше свободы, ранние места требуют большей аккуратности. Чарты пока не нужны.',
    runnerQuestion: 'Почему позиция так важна за столом?',
  ),
  'position_apply_btn_open': Act0TaskDisplayCopyV1(
    title: 'Баттон: открыть сильную руку',
    runnerPrompt: 'До баттона все выбросили, у тебя KTs.',
    runnerSupport:
        'Поздняя позиция и вход первым делают открытие самым чистым продолжением.',
    runnerQuestion: 'Какое здесь самое простое первое действие?',
  ),
  'position_apply_late_open': Act0TaskDisplayCopyV1(
    title: 'Поздняя позиция: открыть или зайти пассивно?',
    runnerPrompt: 'Банк не открыт. Hero в поздней позиции с ATo.',
    runnerSupport:
        'В поздней позиции такая рука спокойно тянет на открытие, а не на пассивный вход.',
    runnerQuestion: 'Какое действие здесь выглядит самым простым?',
  ),
  'position_apply_early_fold': Act0TaskDisplayCopyV1(
    title: 'Ранняя позиция: та же рука уходит в пас',
    runnerPrompt: 'Банк не открыт. Hero в ранней позиции с ATo.',
    runnerSupport:
        'Та же рука в ранней позиции чувствует себя заметно хуже и не требует упрямства.',
    runnerQuestion: 'Какое действие здесь будет дисциплинированным?',
  ),
  'position_apply_hj_fold': Act0TaskDisplayCopyV1(
    title: 'HJ: держим дисциплину',
    runnerPrompt: 'Банк не открыт. Hero в раннем участке стола с ATo.',
    runnerSupport:
        'Даже знакомая рука не обязана продолжать, если место за столом делает спот неудобным.',
    runnerQuestion: 'Какое действие здесь будет дисциплинированным?',
  ),
  'position_apply_recap': Act0TaskDisplayCopyV1(
    title: 'Повтор по позиции',
    runnerPrompt:
        'Главная мысль проста: позиция меняет комфорт ещё до действия.',
    runnerSupport:
        'Поздние места помогают, ранние требуют более крепкой руки и более чистой причины продолжать.',
    runnerQuestion: 'На что нужно смотреть сразу после группы руки?',
  ),
};

const Map<String, Act0SurfaceAtomCopyV1>
_ruSurfaceAtomCopyByIdV1 = <String, Act0SurfaceAtomCopyV1>{
  'play_title': Act0SurfaceAtomCopyV1(text: 'Практика'),
  'play_screen_subtitle': Act0SurfaceAtomCopyV1(
    text: 'Запусти один короткий сет и держи маршрут в движении.',
  ),
  'play_quick_practice_label': Act0SurfaceAtomCopyV1(text: 'Быстрая практика'),
  'play_recommended_repair_label': Act0SurfaceAtomCopyV1(
    text: 'Рекомендуемый фикс',
  ),
  'play_practice_lanes_label': Act0SurfaceAtomCopyV1(text: 'Линии практики'),
  'play_topic_preflop': Act0SurfaceAtomCopyV1(text: 'Префлоп'),
  'play_topic_position': Act0SurfaceAtomCopyV1(text: 'Позиция'),
  'play_topic_postflop': Act0SurfaceAtomCopyV1(text: 'Постфлоп'),
  'play_topic_hand_reading': Act0SurfaceAtomCopyV1(text: 'Чтение руки'),
  'play_topic_showdown': Act0SurfaceAtomCopyV1(text: 'Шоудаун'),
  'play_repair_empty_title': Act0SurfaceAtomCopyV1(
    text: 'Сейчас нечего чинить.',
  ),
  'play_repair_empty_body': Act0SurfaceAtomCopyV1(
    text: 'Используй практику по темам, чтобы добрать дополнительные репы.',
  ),
  'play_later_cta': Act0SurfaceAtomCopyV1(text: 'Позже'),
  'review_fix_next_label': Act0SurfaceAtomCopyV1(text: 'Чиним дальше'),
  'review_title': Act0SurfaceAtomCopyV1(text: 'Доска фиксов'),
  'review_subtitle': Act0SurfaceAtomCopyV1(
    text: 'Разбери один промах, прежде чем двигаться дальше.',
  ),
  'review_recovered_lately_label': Act0SurfaceAtomCopyV1(
    text: 'Недавно восстановлено',
  ),
  'review_board_title_fix': Act0SurfaceAtomCopyV1(text: 'Чиним следующим'),
  'review_board_title_clean': Act0SurfaceAtomCopyV1(text: 'Повтор'),
  'review_board_headline_clean': Act0SurfaceAtomCopyV1(text: 'Стол снова чист'),
  'review_board_body_clean': Act0SurfaceAtomCopyV1(
    text:
        'Срочных фиксов сейчас нет. Держи стол чистым через один спокойный прогон.',
  ),
  'review_board_support_fix': Act0SurfaceAtomCopyV1(
    text: 'Один чистый фикс здесь важнее, чем беглый взгляд на весь стол.',
  ),
  'review_board_support_clean_empty': Act0SurfaceAtomCopyV1(
    text: 'Пока чинить нечего. Просто держи маршрут в движении.',
  ),
  'review_board_support_clean_strong': Act0SurfaceAtomCopyV1(
    text: 'Сейчас всё чисто. Просто держи маршрут в движении.',
  ),
  'review_board_fix_cta': Act0SurfaceAtomCopyV1(text: 'Чинить сейчас'),
  'profile_title': Act0SurfaceAtomCopyV1(text: 'Ты'),
  'profile_recommended_focus_label': Act0SurfaceAtomCopyV1(
    text: 'Следующий фокус',
  ),
  'profile_working_well_label': Act0SurfaceAtomCopyV1(text: 'Уже получается'),
  'profile_next_reps_label': Act0SurfaceAtomCopyV1(text: 'Следующие репы'),
  'profile_consistency_label': Act0SurfaceAtomCopyV1(text: 'Ритм'),
  'profile_streak_label': Act0SurfaceAtomCopyV1(text: 'Серия'),
  'profile_momentum_streak_7': Act0SurfaceAtomCopyV1(
    text:
        'Семь дней подряд уже не выглядят случайностью. Это становится частью твоей игры.',
  ),
  'profile_momentum_streak_3': Act0SurfaceAtomCopyV1(
    text:
        'Серия уже настоящая. Продолжай набирать чистые репы, пока ритм тёплый.',
  ),
  'profile_momentum_worlds_cleared': Act0SurfaceAtomCopyV1(
    text: 'Закрытый мир важнее шумной цифры. Просто держи маршрут в движении.',
  ),
  'profile_momentum_first_habit': Act0SurfaceAtomCopyV1(
    text:
        'Первая устойчивая привычка здесь простая: вернуться ещё на один чистый реп.',
  ),
  'profile_support_no_streak_with_fix': Act0SurfaceAtomCopyV1(
    text: 'Ты уже починил живой промах. Ещё один чистый реп запускает ритм.',
  ),
  'profile_support_no_streak_plain': Act0SurfaceAtomCopyV1(
    text: 'Один чистый реп запускает ритм.',
  ),
  'profile_support_streak_7': Act0SurfaceAtomCopyV1(
    text: 'Это уже не случайная серия. Ритм становится частью твоей игры.',
  ),
  'profile_support_worlds_cleared': Act0SurfaceAtomCopyV1(
    text: 'Ритм уже оставляет после себя доказательства. Держи маршрут тёплым.',
  ),
  'profile_support_default': Act0SurfaceAtomCopyV1(
    text:
        'Держи ритм тёплым. Постоянство постепенно превращается в ощущение игры.',
  ),
};

const Map<String, Act0LanguageCopyBundleV1> _act0CopyByLanguageCodeV1 =
    <String, Act0LanguageCopyBundleV1>{
      'ru': Act0LanguageCopyBundleV1(
        worlds: _ruWorldCopyByIdV1,
        lessons: _ruLessonCopyByIdV1,
        tasks: _ruTaskCopyByIdV1,
        surfaceAtoms: _ruSurfaceAtomCopyByIdV1,
        lessonTitlesByEnglish: _ruLessonTitleByEnglishV1,
      ),
    };
