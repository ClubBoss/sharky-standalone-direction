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
    subtitle: 'Группируй руки просто, без лишней теории.',
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
    runnerQuestion: 'Где находится твоё место?',
    teachingSteps: <Act0TeachingStepDisplayCopyV1>[
      Act0TeachingStepDisplayCopyV1(
        title: 'Начинаем с кэш-игры в холдем.',
        body:
            'В холдеме у каждого игрока 2 закрытые карты, а на стол выходят 5 общих. Итоговая рука собирается из лучших пяти карт из этих семи. Есть разные форматы покера, но курс стартует с No-Limit Hold’em cash: здесь ценность фишек не меняется, а одни и те же базовые решения повторяются раз за разом.',
      ),
      Act0TeachingStepDisplayCopyV1(
        title: 'Перед тобой покерный стол.',
        body:
            'Ты играешь за нижнее место. Остальные места за столом — соперники.',
      ),
      Act0TeachingStepDisplayCopyV1(
        title: 'Цель раздачи — забрать банк.',
        body:
            'Игроки вкладывают фишки в центр стола. Тот, кто выигрывает раздачу, забирает этот банк.',
      ),
      Act0TeachingStepDisplayCopyV1(
        title: 'Раздачу запускают блайнды.',
        body:
            'Сначала SB ставит 0.5 BB, а BB — 1 BB. Эти обязательные ставки появляются ещё до первого решения. Карты пока скрыты, чтобы ты сначала спокойно прочитал сам стол.',
      ),
    ],
  ),
  'what_poker_is_find_hero': Act0TaskDisplayCopyV1(
    title: 'Найди своё место',
    summary:
        'Сначала научись видеть, где сидишь ты, и только потом отслеживай остальное.',
    runnerPrompt:
        'Сначала найди своё место, а уже потом смотри на остальной стол.',
    runnerSupport:
        'Привычка простая: сперва свои карты и своё место, потом всё остальное.',
    runnerQuestion: 'Какое место принадлежит тебе?',
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
        'Ты играешь из нижнего места, блайнды запускают первый банк, а стол подсказывает, что происходит.',
    runnerQuestion: 'Что такое банк?',
  ),
  'cards_ranks_suits_theory': Act0TaskDisplayCopyV1(
    title: 'Колода',
    runnerPrompt: 'Каждая карта состоит из ранга и масти.',
    runnerSupport: 'В колоде 52 карты. Ты читаешь карту через эти две части.',
    runnerQuestion: 'Из каких двух частей состоит карта?',
    teachingSteps: <Act0TeachingStepDisplayCopyV1>[
      Act0TeachingStepDisplayCopyV1(
        title: 'Сначала разберём саму колоду.',
        body: 'В холдеме 52 карты: 13 рангов и 4 масти.',
      ),
    ],
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
    runnerSupport:
        'Здесь масти записаны английскими буквами: s — пики, h — черви, d — бубны, c — трефы.',
    runnerQuestion: 'Какая масть у Ah?',
  ),
  'cards_ranks_suits_private_board': Act0TaskDisplayCopyV1(
    title: 'Карманные и борд',
    runnerPrompt: 'Карманные карты твои, борд общий для всех.',
    runnerSupport:
        'Твои две карты остаются у тебя, а карты борда могут использовать все.',
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
    teachingSteps: <Act0TeachingStepDisplayCopyV1>[
      Act0TeachingStepDisplayCopyV1(
        title: 'Раздача начинается на префлопе.',
        body: 'Ты получаешь две закрытые карты. Карт борда на столе пока нет.',
      ),
      Act0TeachingStepDisplayCopyV1(
        title: 'Закрытые карты принадлежат только тебе.',
        body: 'Эти две карты видишь и используешь только ты.',
      ),
    ],
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
        'Ищи два совпадающих ранга. Это первая устойчивая готовая рука в базовой лестнице.',
    runnerQuestion: 'Что собрал ты в этом примере?',
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
        'Этот каркас убирает суету: сначала пойми, что за рука и где ты сидишь, а потом решай, стоит ли входить в игру.',
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
    runnerPrompt:
        'Средняя рука требует оценки ситуации, а не игры на автопилоте.',
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
    runnerPrompt: 'Банк не открыт. Ты в поздней позиции с ATo.',
    runnerSupport:
        'В поздней позиции такая рука спокойно тянет на открытие, а не на пассивный вход.',
    runnerQuestion: 'Какое действие здесь выглядит самым простым?',
  ),
  'position_apply_early_fold': Act0TaskDisplayCopyV1(
    title: 'Ранняя позиция: та же рука уходит в пас',
    runnerPrompt: 'Банк не открыт. Ты в ранней позиции с ATo.',
    runnerSupport:
        'Та же рука в ранней позиции чувствует себя заметно хуже и не требует упрямства.',
    runnerQuestion: 'Какое действие здесь будет дисциплинированным?',
  ),
  'position_apply_hj_fold': Act0TaskDisplayCopyV1(
    title: 'HJ: держим дисциплину',
    runnerPrompt: 'Банк не открыт. Ты в HJ с ATo.',
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
  'runner_badge_your_move': Act0SurfaceAtomCopyV1(text: 'Твой ход'),
  'runner_task_check_reason_continue': Act0SurfaceAtomCopyV1(
    text: 'Сверь причину и продолжай',
  ),
  'runner_task_read_table_first': Act0SurfaceAtomCopyV1(
    text: 'Сначала прочитай стол',
  ),
  'runner_task_tap_correct_seat': Act0SurfaceAtomCopyV1(
    text: 'Нажми на правильное место',
  ),
  'runner_task_choose_best_size': Act0SurfaceAtomCopyV1(
    text: 'Выбери лучший сайзинг',
  ),
  'runner_task_choose_winning_hand': Act0SurfaceAtomCopyV1(
    text: 'Выбери руку-победителя',
  ),
  'runner_task_choose_correct_count': Act0SurfaceAtomCopyV1(
    text: 'Выбери правильный счёт',
  ),
  'runner_task_choose_best_action': Act0SurfaceAtomCopyV1(
    text: 'Выбери лучшее действие',
  ),
  'runner_prompt_read_table_then_tap': Act0SurfaceAtomCopyV1(
    text: 'Сначала прочитай стол, потом нажми на одно место.',
  ),
  'runtime_label_fold': Act0SurfaceAtomCopyV1(text: 'Пас'),
  'runtime_label_check': Act0SurfaceAtomCopyV1(text: 'Чек'),
  'runtime_label_call': Act0SurfaceAtomCopyV1(text: 'Колл'),
  'runtime_label_raise': Act0SurfaceAtomCopyV1(text: 'Рейз'),
  'runtime_label_one': Act0SurfaceAtomCopyV1(text: 'Один'),
  'runtime_label_two': Act0SurfaceAtomCopyV1(text: 'Два'),
  'runtime_label_three': Act0SurfaceAtomCopyV1(text: 'Три'),
  'runtime_label_four': Act0SurfaceAtomCopyV1(text: 'Четыре'),
  'runtime_label_five': Act0SurfaceAtomCopyV1(text: 'Пять'),
  'runtime_label_six': Act0SurfaceAtomCopyV1(text: 'Шесть'),
  'runtime_label_king': Act0SurfaceAtomCopyV1(text: 'Король'),
  'runtime_label_ace': Act0SurfaceAtomCopyV1(text: 'Туз'),
  'runtime_label_pot_short': Act0SurfaceAtomCopyV1(text: 'Банк'),
  'runtime_label_stack': Act0SurfaceAtomCopyV1(text: 'Стек'),
  'runtime_label_board_cards': Act0SurfaceAtomCopyV1(text: 'Карты борда'),
  'runtime_label_private_cards': Act0SurfaceAtomCopyV1(text: 'Карманные карты'),
  'runtime_label_everyone_folds': Act0SurfaceAtomCopyV1(text: 'Все выбросили'),
  'runtime_label_largest_stack': Act0SurfaceAtomCopyV1(
    text: 'Самый большой стек',
  ),
  'runtime_label_pair': Act0SurfaceAtomCopyV1(text: 'Пара'),
  'runtime_label_high_card': Act0SurfaceAtomCopyV1(text: 'Старшая карта'),
  'runtime_label_flush': Act0SurfaceAtomCopyV1(text: 'Флеш'),
  'runtime_label_straight': Act0SurfaceAtomCopyV1(text: 'Стрит'),
  'runtime_label_two_pair': Act0SurfaceAtomCopyV1(text: 'Две пары'),
  'runtime_label_one_pair': Act0SurfaceAtomCopyV1(text: 'Одна пара'),
  'runtime_label_win_now': Act0SurfaceAtomCopyV1(text: 'Забрать сразу'),
  'runtime_label_show_cards': Act0SurfaceAtomCopyV1(text: 'Открыть карты'),
  'runtime_label_best_hand': Act0SurfaceAtomCopyV1(text: 'Лучшая рука'),
  'runtime_label_first_actor': Act0SurfaceAtomCopyV1(text: 'Кто ходит первым'),
  'runtime_label_kicker': Act0SurfaceAtomCopyV1(text: 'Кикер'),
  'runtime_label_seat_name': Act0SurfaceAtomCopyV1(text: 'Название места'),
  'runtime_label_premium': Act0SurfaceAtomCopyV1(text: 'Премиум'),
  'runtime_label_strong': Act0SurfaceAtomCopyV1(text: 'Сильная'),
  'runtime_label_medium': Act0SurfaceAtomCopyV1(text: 'Средняя'),
  'runtime_label_trash': Act0SurfaceAtomCopyV1(text: 'Мусор'),
  'runtime_label_value': Act0SurfaceAtomCopyV1(text: 'Вэлью'),
  'runtime_label_bluff': Act0SurfaceAtomCopyV1(text: 'Блеф'),
  'runtime_label_dry': Act0SurfaceAtomCopyV1(text: 'Сухой'),
  'runtime_label_wet': Act0SurfaceAtomCopyV1(text: 'Связный'),
  'runtime_label_flush_draw': Act0SurfaceAtomCopyV1(text: 'Флеш-дро'),
  'runtime_label_straight_draw': Act0SurfaceAtomCopyV1(text: 'Стрит-дро'),
  'runtime_label_no': Act0SurfaceAtomCopyV1(text: 'Нет'),
  'runtime_label_yes': Act0SurfaceAtomCopyV1(text: 'Да'),
  'runtime_label_heart': Act0SurfaceAtomCopyV1(text: 'Червь'),
  'runtime_label_club': Act0SurfaceAtomCopyV1(text: 'Трефа'),
  'runtime_label_tie': Act0SurfaceAtomCopyV1(text: 'Ничья'),
  'runtime_label_split': Act0SurfaceAtomCopyV1(text: 'Поделить банк'),
  'runtime_label_missed': Act0SurfaceAtomCopyV1(text: 'Мимо'),
  'runtime_label_bluff_candidate': Act0SurfaceAtomCopyV1(
    text: 'Кандидат в блеф',
  ),
  'runtime_label_spot_check': Act0SurfaceAtomCopyV1(text: 'Проверка спота'),
  'runtime_feedback_you_picked': Act0SurfaceAtomCopyV1(text: 'Ты выбрал'),
  'runtime_feedback_better_option': Act0SurfaceAtomCopyV1(
    text: 'Лучший вариант',
  ),
  'runtime_feedback_sharper_line': Act0SurfaceAtomCopyV1(
    text: 'Более точная линия',
  ),
  'runtime_feedback_best_play': Act0SurfaceAtomCopyV1(text: 'Лучшее решение'),
  'runtime_feedback_almost_there': Act0SurfaceAtomCopyV1(text: 'Почти.'),
  'runtime_feedback_playable_move': Act0SurfaceAtomCopyV1(text: 'Играбельно.'),
  'runtime_feedback_nice_read': Act0SurfaceAtomCopyV1(text: 'Хорошее чтение.'),
  'runtime_feedback_not_quite': Act0SurfaceAtomCopyV1(text: 'Не совсем так.'),
  'runtime_feedback_fold_reason_btn': Act0SurfaceAtomCopyV1(
    text:
        'Когда до тебя все выбросили на баттоне, пас слишком легко отдаёт играбельный спот.',
  ),
  'runtime_feedback_call_reason_btn': Act0SurfaceAtomCopyV1(
    text:
        'Колл здесь допустим, но слишком пассивен. Рейз может сразу забрать блайнды и строит банк лучше.',
  ),
  'runtime_feedback_raise_reason_btn': Act0SurfaceAtomCopyV1(
    text:
        'Когда ты входишь первым на баттоне, рейз открывает раздачу и давит на блайнды.',
  ),
  'runtime_context_limp_legal': Act0SurfaceAtomCopyV1(text: 'Лимп допустим'),
  'runtime_context_raise_sharper': Act0SurfaceAtomCopyV1(text: 'Рейз точнее'),
  'runtime_context_button_open': Act0SurfaceAtomCopyV1(
    text: 'Открытие с баттона',
  ),
  'runtime_phrase_widen_late_steals_slightly': Act0SurfaceAtomCopyV1(
    text: 'Чуть шире крадём из поздней позиции',
  ),
  'runtime_phrase_bet_half_pot': Act0SurfaceAtomCopyV1(text: 'Ставь полбанка'),
  'runtime_phrase_bet_for_value': Act0SurfaceAtomCopyV1(text: 'Ставь на вэлью'),
  'runtime_phrase_repeatable_daily_transfer_loop': Act0SurfaceAtomCopyV1(
    text: 'Повторяемый ежедневный цикл переноса в игру',
  ),
  'runtime_phrase_stable_bridge_deeper_strategy': Act0SurfaceAtomCopyV1(
    text: 'Надёжный мост к более глубокой стратегии',
  ),
  'runtime_phrase_ak_appears_more_often': Act0SurfaceAtomCopyV1(
    text: 'A-K встречается чаще',
  ),
  'runtime_phrase_activate_one_trigger_lever_now': Act0SurfaceAtomCopyV1(
    text: 'Сейчас включи один триггер и один рычаг',
  ),
  'runtime_phrase_apply_selective_open_pressure': Act0SurfaceAtomCopyV1(
    text: 'Точечно дави открытием',
  ),
  'runtime_phrase_audit_process_first_then_outcome': Act0SurfaceAtomCopyV1(
    text: 'Сначала разбери процесс, потом результат',
  ),
  'runtime_phrase_btn_sb_bb_still_act_after_you': Act0SurfaceAtomCopyV1(
    text: 'После тебя ещё действуют BTN, SB и BB',
  ),
  'runtime_phrase_bet_value_heavier_trim_bluffs': Act0SurfaceAtomCopyV1(
    text: 'Ставь на вэлью плотнее и сокращай блефы',
  ),
  'runtime_phrase_bluffcatch_wider_with_blockers': Act0SurfaceAtomCopyV1(
    text: 'Коллируй блефы чуть шире, если есть блокеры',
  ),
  'runtime_phrase_choose_one_tendency_and_act': Act0SurfaceAtomCopyV1(
    text: 'Выбери одну тенденцию и подстройся под неё',
  ),
  'runtime_phrase_count_more_players_behind': Act0SurfaceAtomCopyV1(
    text: 'Считай больше игроков позади и чуть зажимай ранние открытия',
  ),
  'runtime_phrase_disciplined_urgency_reasonable_spots': Act0SurfaceAtomCopyV1(
    text: 'Действуй срочно, но дисциплинированно, в разумных спотах',
  ),
  'runtime_phrase_facing_an_open': Act0SurfaceAtomCopyV1(
    text: 'Перед тобой уже было открытие',
  ),
  'runtime_phrase_flag_loose_call_possible_leak': Act0SurfaceAtomCopyV1(
    text: 'Пометь этот лузовый колл как возможную утечку',
  ),
  'runtime_phrase_fold_more_marginal_bluffcatchers': Act0SurfaceAtomCopyV1(
    text: 'Чаще пасуй с пограничными руками для колла против блефа',
  ),
  'runtime_phrase_if_villain_underbluffs_fold_marginal_bluffcatchers':
      Act0SurfaceAtomCopyV1(
        text:
            'Если соперник недоблефовывает, пасуй с пограничными руками для колла против блефа',
      ),
  'runtime_phrase_it_can_slide_toward_missed': Act0SurfaceAtomCopyV1(
    text: 'Рука может сместиться ближе к категории "мимо"',
  ),
  'runtime_phrase_log_leak_and_reset': Act0SurfaceAtomCopyV1(
    text: 'Коротко запиши утечку и вернись в текущую раздачу',
  ),
  'runtime_phrase_loose_passive_caller': Act0SurfaceAtomCopyV1(
    text: 'Лузово-пассивный коллер',
  ),
  'runtime_phrase_make_small_adjustment_gather_evidence': Act0SurfaceAtomCopyV1(
    text: 'Сделай маленькую подстройку и собери ещё доказательства',
  ),
  'runtime_phrase_make_only_small_adjustment_keep_watching':
      Act0SurfaceAtomCopyV1(
        text: 'Сделай только маленькую подстройку и продолжай наблюдать',
      ),
  'runtime_phrase_map_pressure_first_then_adjust': Act0SurfaceAtomCopyV1(
    text: 'Сначала оцени давление, потом подстраивайся под игрока',
  ),
  'runtime_phrase_medium_stack_faces_bubble_pressure': Act0SurfaceAtomCopyV1(
    text:
        'Средний стек сильнее чувствует баббл и не может так свободно коллировать',
  ),
  'runtime_phrase_middle_ground_room_and_commitment': Act0SurfaceAtomCopyV1(
    text:
        'Промежуточная глубина: есть место для манёвра, но уже можно привязаться к банку',
  ),
  'runtime_phrase_more_room_more_risk': Act0SurfaceAtomCopyV1(
    text: 'Больше пространства, но и больше риска',
  ),
  'runtime_phrase_more_room_to_maneuver': Act0SurfaceAtomCopyV1(
    text: 'Больше пространства для манёвра',
  ),
  'runtime_phrase_narrow_to_one_transfer_goal': Act0SurfaceAtomCopyV1(
    text: 'Сузь фокус до одной цели переноса на следующую сессию',
  ),
  'runtime_phrase_one_bet_can_commit_hand': Act0SurfaceAtomCopyV1(
    text: 'Одна ставка уже может привязать тебя к банку',
  ),
  'runtime_phrase_one_measurable_focus_session': Act0SurfaceAtomCopyV1(
    text: 'Один измеримый фокус на всю сессию',
  ),
  'runtime_phrase_open_slightly_wider_late_position': Act0SurfaceAtomCopyV1(
    text: 'Открывайся чуть шире в поздней позиции',
  ),
  'runtime_phrase_over_aggressive_bluffer': Act0SurfaceAtomCopyV1(
    text: 'Слишком агрессивный блефер',
  ),
  'runtime_phrase_patience_and_table_selection': Act0SurfaceAtomCopyV1(
    text: 'Терпение и выбор стола',
  ),
  'runtime_phrase_pause_on_high_ev_nodes': Act0SurfaceAtomCopyV1(
    text: 'Коротко тормози в узлах с высоким EV',
  ),
  'runtime_phrase_prepare_action_windows_before_red_zone_panic':
      Act0SurfaceAtomCopyV1(
        text: 'Готовь окна для действия до паники в красной зоне',
      ),
  'runtime_phrase_range_plus_stack_depth': Act0SurfaceAtomCopyV1(
    text: 'Диапазон плюс глубина стека',
  ),
  'runtime_phrase_range_plus_stack_risk': Act0SurfaceAtomCopyV1(
    text: 'Диапазон плюс риск стека',
  ),
  'runtime_phrase_range_tightens': Act0SurfaceAtomCopyV1(
    text: 'Диапазон сужается',
  ),
  'runtime_phrase_red_zone_player': Act0SurfaceAtomCopyV1(
    text: 'Игрок в красной зоне',
  ),
  'runtime_phrase_review_process_before_result': Act0SurfaceAtomCopyV1(
    text: 'Сначала оцени процесс, потом суди по результату',
  ),
  'runtime_phrase_run_brief_reset_reanchor_plan': Act0SurfaceAtomCopyV1(
    text: 'Сделай короткий reset и вернись к плану',
  ),
  'runtime_phrase_run_short_reset_before_next_major_spot':
      Act0SurfaceAtomCopyV1(
        text: 'Перед следующим большим спотом сделай короткий reset',
      ),
  'runtime_phrase_select_one_repeated_leak_priority': Act0SurfaceAtomCopyV1(
    text: 'Выбери одну повторяющуюся утечку как приоритет',
  ),
  'runtime_phrase_set_one_low_friction_focus_target': Act0SurfaceAtomCopyV1(
    text: 'Поставь одну цель, которую легко удерживать в фокусе',
  ),
  'runtime_phrase_some_room_not_carefree_deep': Act0SurfaceAtomCopyV1(
    text: 'Место для манёвра ещё есть, но это уже не беззаботная глубина',
  ),
  'runtime_phrase_stick_to_process_planned_exploit': Act0SurfaceAtomCopyV1(
    text: 'Держись процесса и заранее намеченной exploit-линии',
  ),
  'runtime_phrase_take_practical_jam_spots_before_blinded_out':
      Act0SurfaceAtomCopyV1(
        text: 'Забирай практичные jam-споты до того, как тебя съедят блайнды',
      ),
  'runtime_phrase_structured_exploit_before_transfer': Act0SurfaceAtomCopyV1(
    text: 'Сначала структурный exploit, потом перенос в живую игру',
  ),
  'runtime_phrase_survival_pressure_matters_more': Act0SurfaceAtomCopyV1(
    text: 'Давление на выживание здесь важнее',
  ),
  'runtime_phrase_take_reasonable_jam_or_reshove': Act0SurfaceAtomCopyV1(
    text: 'Ищи разумный jam или reshove-спот',
  ),
  'runtime_phrase_take_only_evidence_backed_lines': Act0SurfaceAtomCopyV1(
    text: 'Играй только линии, за которыми есть доказательства',
  ),
  'runtime_phrase_texture_draw_outs': Act0SurfaceAtomCopyV1(
    text: 'Текстура, дро, ауты',
  ),
  'runtime_phrase_tight_folding_profile_nit': Act0SurfaceAtomCopyV1(
    text: 'Слишком тайтовый профиль (нит)',
  ),
  'runtime_phrase_tighten_marginal_calls': Act0SurfaceAtomCopyV1(
    text: 'Поджимай пограничные коллы',
  ),
  'runtime_phrase_tighten_weakest_steals_keep_stronger_value':
      Act0SurfaceAtomCopyV1(
        text: 'Срежь самые слабые кражи и оставь более сильное вэлью',
      ),
  'runtime_phrase_tournament_table': Act0SurfaceAtomCopyV1(
    text: 'Турнирный стол',
  ),
  'runtime_phrase_use_controlled_urgency': Act0SurfaceAtomCopyV1(
    text: 'Используй контролируемую срочность',
  ),
  'runtime_phrase_usually_check_or_fold': Act0SurfaceAtomCopyV1(
    text: 'Обычно чек или пас',
  ),
  'runtime_phrase_which_bucket_is_my_hand_in': Act0SurfaceAtomCopyV1(
    text: 'В какой группе моя рука?',
  ),
  'runtime_phrase_write_one_priority_leak_one_fix': Act0SurfaceAtomCopyV1(
    text: 'Запиши одну приоритетную утечку и один фикс на завтра',
  ),
  'runtime_phrase_draw_hit': Act0SurfaceAtomCopyV1(text: 'Дро доехало'),
  'runtime_phrase_bet_one_third': Act0SurfaceAtomCopyV1(
    text: 'Ставь одну треть банка',
  ),
  'runtime_phrase_purpose_and_price': Act0SurfaceAtomCopyV1(
    text: 'Цель и цена',
  ),
  'runtime_phrase_seat_context': Act0SurfaceAtomCopyV1(text: 'Контекст места'),
  'runtime_feedback_too_passive': Act0SurfaceAtomCopyV1(
    text: 'Слишком пассивно.',
  ),
  'runtime_phrase_board_got_more_dangerous_easy_value_caution':
      Act0SurfaceAtomCopyV1(
        text:
            'Борд стал опаснее, так что старая лёгкая вэлью-линия уже требует осторожности',
      ),
  'runtime_phrase_board_got_wetter_thin_value_caution': Act0SurfaceAtomCopyV1(
    text:
        'Борд стал более связным, так что старая тонкая вэлью-линия уже требует осторожности',
  ),
  'runtime_phrase_tighten_defend_avoid_thin_allins': Act0SurfaceAtomCopyV1(
    text: 'Подожми защиту и не лезь в тонкие олл-ины',
  ),
  'runtime_phrase_trash_bucket_clean_fold': Act0SurfaceAtomCopyV1(
    text: 'Мусорная группа, чистый пас',
  ),
  'runtime_phrase_valuebet_heavier_bluff_less': Act0SurfaceAtomCopyV1(
    text: 'Ставь на вэлью плотнее, блефуй реже',
  ),
  'runtime_phrase_widen_late_steals_keep_change_small': Act0SurfaceAtomCopyV1(
    text: 'Чуть шире крадём поздно, но подстройку держим маленькой',
  ),
  'runtime_phrase_bottom_seat': Act0SurfaceAtomCopyV1(text: 'Нижнее место'),
  'runtime_phrase_bucket_seat_frame': Act0SurfaceAtomCopyV1(
    text: 'Группа, место, фрейм',
  ),
  'runtime_feedback_close_idea': Act0SurfaceAtomCopyV1(text: 'Мысль рядом.'),
  'runtime_phrase_free_card': Act0SurfaceAtomCopyV1(text: 'Бесплатная карта'),
  'runtime_feedback_playable_caution': Act0SurfaceAtomCopyV1(
    text: 'Играбельно, но осторожно.',
  ),
  'runtime_feedback_playable_start': Act0SurfaceAtomCopyV1(
    text: 'Играбельное начало.',
  ),
  'runtime_phrase_five_in_a_row': Act0SurfaceAtomCopyV1(text: 'Пять подряд'),
  'runtime_phrase_hand_seat_action': Act0SurfaceAtomCopyV1(
    text: 'Рука, место, действие',
  ),
  'runtime_feedback_nice_count': Act0SurfaceAtomCopyV1(text: 'Хороший счёт.'),
  'runtime_feedback_playable_read': Act0SurfaceAtomCopyV1(
    text: 'Играбельное чтение.',
  ),
  'runtime_feedback_playable_thought': Act0SurfaceAtomCopyV1(
    text: 'Играбельная мысль.',
  ),
  'runtime_feedback_too_broad': Act0SurfaceAtomCopyV1(text: 'Слишком широко.'),
  'runtime_feedback_too_loose': Act0SurfaceAtomCopyV1(text: 'Слишком лузово.'),
  'runtime_feedback_too_rigid': Act0SurfaceAtomCopyV1(text: 'Слишком жёстко.'),
  'runtime_phrase_trips': Act0SurfaceAtomCopyV1(text: 'Трипс'),
  'runtime_feedback_wrong_direction': Act0SurfaceAtomCopyV1(
    text: 'Неверное направление.',
  ),
  'table_word_pot': Act0SurfaceAtomCopyV1(text: 'Банк'),
  'table_word_to_call': Act0SurfaceAtomCopyV1(text: 'До колла'),
  'table_word_to_act': Act0SurfaceAtomCopyV1(text: 'Ход'),
  'table_word_dealer': Act0SurfaceAtomCopyV1(text: 'Дилер'),
  'table_word_small_blind': Act0SurfaceAtomCopyV1(text: 'Малый блайнд'),
  'table_word_big_blind': Act0SurfaceAtomCopyV1(text: 'Большой блайнд'),
  'table_word_now': Act0SurfaceAtomCopyV1(text: 'Сейчас'),
  'table_word_you': Act0SurfaceAtomCopyV1(text: 'Ты'),
  'table_word_blind': Act0SurfaceAtomCopyV1(text: 'блайнд'),
  'table_word_acts': Act0SurfaceAtomCopyV1(text: 'действует'),
  'table_word_opens': Act0SurfaceAtomCopyV1(text: 'открывает'),
  'table_word_bets': Act0SurfaceAtomCopyV1(text: 'ставит'),
  'table_word_calls': Act0SurfaceAtomCopyV1(text: 'коллирует'),
  'table_word_raises': Act0SurfaceAtomCopyV1(text: 'рейзит до'),
  'table_word_checks': Act0SurfaceAtomCopyV1(text: 'чекает'),
  'table_word_folds': Act0SurfaceAtomCopyV1(text: 'пас'),
  'table_trail_flop_dealt': Act0SurfaceAtomCopyV1(text: 'Флоп открыт'),
  'table_street_preflop': Act0SurfaceAtomCopyV1(text: 'Префлоп'),
  'table_street_flop': Act0SurfaceAtomCopyV1(text: 'Флоп'),
  'table_street_turn': Act0SurfaceAtomCopyV1(text: 'Тёрн'),
  'table_street_river': Act0SurfaceAtomCopyV1(text: 'Ривер'),
  'table_center_blinds_posted': Act0SurfaceAtomCopyV1(
    text: 'Блайнды поставлены',
  ),
  'table_center_action_on_hero': Act0SurfaceAtomCopyV1(text: 'Ход за тобой'),
  'table_center_private_cards': Act0SurfaceAtomCopyV1(text: 'Карманные карты'),
  'table_center_shared_board': Act0SurfaceAtomCopyV1(text: 'Общий борд'),
  'table_center_ranks_and_suits': Act0SurfaceAtomCopyV1(text: 'Ранги и масти'),
  'table_center_pot_vs_stack': Act0SurfaceAtomCopyV1(text: 'Банк и стек'),
  'table_center_no_bet_yet': Act0SurfaceAtomCopyV1(text: 'Ставки ещё нет'),
  'table_center_facing_a_bet': Act0SurfaceAtomCopyV1(
    text: 'Перед тобой ставка',
  ),
  'table_center_facing_a_price': Act0SurfaceAtomCopyV1(
    text: 'Перед тобой цена',
  ),
  'table_center_read_hand_board_pot': Act0SurfaceAtomCopyV1(
    text: 'Читай руку, борд и банк',
  ),
  'table_center_five_board_cards': Act0SurfaceAtomCopyV1(
    text: 'Пять карт борда',
  ),
  'table_center_premium_bucket': Act0SurfaceAtomCopyV1(text: 'Премиум-группа'),
  'table_center_trash_bucket': Act0SurfaceAtomCopyV1(text: 'Мусорная группа'),
  'table_center_co_opened': Act0SurfaceAtomCopyV1(text: 'CO открылся'),
  'table_center_weak_continue': Act0SurfaceAtomCopyV1(
    text: 'Слабое продолжение?',
  ),
  'table_center_unopened_pot': Act0SurfaceAtomCopyV1(
    text: 'Никто ещё не вошёл',
  ),
  'table_center_early_position': Act0SurfaceAtomCopyV1(text: 'Ранняя позиция'),
  'table_center_co_three_behind': Act0SurfaceAtomCopyV1(
    text: 'CO и ещё три игрока позади',
  ),
  'table_center_weak_ace': Act0SurfaceAtomCopyV1(text: 'Слабый туз'),
  'table_center_hj_unopened_pot': Act0SurfaceAtomCopyV1(
    text: 'HJ, никто ещё не вошёл',
  ),
  'table_center_strong_bucket': Act0SurfaceAtomCopyV1(text: 'Сильная группа'),
  'table_center_medium_bucket': Act0SurfaceAtomCopyV1(text: 'Средняя группа'),
  'table_center_medium_good_seat': Act0SurfaceAtomCopyV1(
    text: 'Средняя рука, хорошее место',
  ),
  'table_center_trash_early': Act0SurfaceAtomCopyV1(text: 'Мусорная рука рано'),
  'table_center_strong_late': Act0SurfaceAtomCopyV1(
    text: 'Сильная рука поздно',
  ),
  'table_center_hj_opens_2_5_bb': Act0SurfaceAtomCopyV1(
    text: 'HJ открывает 2.5 BB',
  ),
  'table_center_name_purpose': Act0SurfaceAtomCopyV1(text: 'Назови цель'),
  'table_center_top_pair': Act0SurfaceAtomCopyV1(text: 'Топ-пара'),
  'table_center_missed_hand': Act0SurfaceAtomCopyV1(text: 'Рука мимо'),
  'table_center_value_spot': Act0SurfaceAtomCopyV1(text: 'Вэлью-спот'),
  'table_center_fold_pressure': Act0SurfaceAtomCopyV1(text: 'Давление на пас'),
  'table_center_low_fold_pressure': Act0SurfaceAtomCopyV1(
    text: 'Мало давления на пас',
  ),
  'table_center_next_card_matters': Act0SurfaceAtomCopyV1(
    text: 'Следующая карта важна',
  ),
  'table_center_facing_price': Act0SurfaceAtomCopyV1(text: 'Перед тобой цена'),
  'table_center_small_price': Act0SurfaceAtomCopyV1(text: 'Небольшая цена'),
  'table_center_high_price': Act0SurfaceAtomCopyV1(text: 'Высокая цена'),
  'table_center_one_third': Act0SurfaceAtomCopyV1(text: 'Одна треть?'),
  'table_center_half_pot': Act0SurfaceAtomCopyV1(text: 'Полбанка?'),
  'table_center_pot_size': Act0SurfaceAtomCopyV1(text: 'В банк?'),
  'table_center_texture_read': Act0SurfaceAtomCopyV1(text: 'Чтение текстуры'),
  'table_center_wet_board': Act0SurfaceAtomCopyV1(text: 'Связанный борд'),
  'table_center_disconnected': Act0SurfaceAtomCopyV1(text: 'Разрозненный'),
  'table_center_9_8_7': Act0SurfaceAtomCopyV1(text: '9-8-7'),
  'table_center_two_hearts': Act0SurfaceAtomCopyV1(text: 'Две черви'),
  'table_center_connected_ranks': Act0SurfaceAtomCopyV1(text: 'Связные ранги'),
  'table_center_rainbow_flop': Act0SurfaceAtomCopyV1(text: 'Радужный флоп'),
  'table_center_4_or_9_helps': Act0SurfaceAtomCopyV1(text: '4 или 9 помогают'),
  'table_center_big_gaps': Act0SurfaceAtomCopyV1(text: 'Большие разрывы'),
  'table_center_outs_help': Act0SurfaceAtomCopyV1(text: 'Ауты помогают'),
  'table_center_turn_changes': Act0SurfaceAtomCopyV1(text: 'Тёрн меняет план'),
  'table_center_heart_lands': Act0SurfaceAtomCopyV1(text: 'Червь доехала'),
  'table_center_draw_missed': Act0SurfaceAtomCopyV1(text: 'Дро не доехало'),
  'table_center_range_bucket': Act0SurfaceAtomCopyV1(
    text: 'Какая группа диапазона?',
  ),
  'table_center_range_shift': Act0SurfaceAtomCopyV1(text: 'Сдвиг диапазона'),
  'table_center_value_action': Act0SurfaceAtomCopyV1(text: 'Вэлью-действие'),
  'table_center_bucket': Act0SurfaceAtomCopyV1(text: 'Какая группа?'),
  'table_center_combo_count': Act0SurfaceAtomCopyV1(text: 'Сколько комбинаций'),
  'table_center_effective_stack': Act0SurfaceAtomCopyV1(
    text: 'Эффективный стек',
  ),
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
