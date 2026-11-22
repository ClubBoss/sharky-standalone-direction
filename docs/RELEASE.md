# Сборка на iPhone

## Бесплатно: свой iPhone через Xcode (до беты)

Нужно: Mac с Xcode, iPhone, кабель, обычный Apple ID. Подписка Apple Developer не нужна.

1. `flutter pub get`, затем открыть `ios/Runner.xcworkspace` в Xcode.
2. Xcode → Settings → Accounts → добавить свой Apple ID.
3. Target Runner → Signing & Capabilities → Team: ваш Personal Team.
4. В `ios/Flutter/AppIdentity.xcconfig` заменить `SHARKY_BUNDLE_ID` на свой временный ID, например
   `com.<имя>.sharky.dev`. Оставить эту правку локальной до выбора постоянного ID.
5. Подключить iPhone, разрешить «Trust This Computer». Если Developer Mode выключен: открыть
   Xcode → Window → Devices and Simulators, затем на iPhone Settings → Privacy & Security →
   Developer Mode → включить и перезагрузить. Выбрать iPhone как устройство, Run (⌘R).
6. На iPhone: Настройки → Основные → VPN и управление устройством → доверять разработчику.
7. Подпись живёт 7 дней; потом снова Run из Xcode.

Тихий тест (S2) — на этом же iPhone: дать телефон участнику, сценарий в `docs/PLAN.md`.

**Замер скорости (P1)** на этом же iPhone: profile-сборка проходит W1–W4 сама, с ошибкой и
повторным открытием в каждом мире, и пишет отклик, кадры и память в `build/p1_perf_report.json`.
Прогон стирает сохранённый прогресс этой сборки на телефоне, длится около 17 минут, телефон
должен быть разблокирован и подключён кабелем. Тестовые пакеты подключаются только на время
прогона и в release-сборку не попадают. Если после `All tests passed` команда не завершается, остановить её (Ctrl+C):
отчёт уже записан, файлы проекта восстановятся. Перед каждым прогоном iPhone снова просит
доверять разработчику (Settings → General → VPN & Device Management): приложение
переустанавливается.

```bash
SHARKY_BUNDLE_ID=com.<имя>.sharky.dev SHARKY_TEAM=<Team ID> tools/p1/run_p1_on_iphone.sh <device id>
```

Бюджеты P1 (iPhone 14 Pro, 120 Гц): первый кадр после нажатия ≤ 150 мс у 99% нажатий, следующая
кнопка нажимаема в тот же срок; кадров дольше 16,7 мс ≤ 1% в каждом мире; память после W1–W4 не
растёт от мира к миру (разница между концом W2 и W4 ≤ 30 МБ). Перемерить после V9 и перед бетой.

## Платно: TestFlight (к S5)

### Чек-лист на первый час после O4

Час — ориентир на подготовку и отправку сборки после получения доступов, согласования
материалов и заполнения данных ниже. Обработка у Apple и проверка внешней беты идут отдельно.

1. **ждёт O4** · 0–10 мин. Владелец предоставляет активное членство Apple Developer,
   доступ к команде и приложению в App Store Connect, Team ID, согласованный постоянный
   Bundle ID, имя и страну оператора, публичный HTTPS URL политики, e-mail поддержки,
   имя, телефон и e-mail контакта для Beta App Review. Для первой записи нужны согласованные
   название приложения и SKU. Владелец подтверждает право на материалы, политику переустановки,
   первый список тестеров и страны внешней беты. Доступ выдаётся приглашением в команду.
2. **ждёт O4** · 10–15 мин. Зарегистрировать явный App ID и создать запись iOS в App Store
   Connect с этим ID, названием, SKU и языком English (U.S.). В
   [`ios/Flutter/AppIdentity.xcconfig`](../ios/Flutter/AppIdentity.xcconfig) заменить
   `SHARKY_BUNDLE_ID` (строка 2) и раскомментировать `DEVELOPMENT_TEAM` со своим Team ID
   (строка 5). В Xcode → Settings → Accounts выбрать аккаунт с доступом к команде,
   в Runner → Signing & Capabilities проверить Automatically manage signing.
3. **готово** · Команды и правило версии. `CFBundleShortVersionString` берётся из части
   до `+` в [`pubspec.yaml`](../pubspec.yaml), сейчас `1.0.0`. Перед каждой загрузкой
   увеличивать `CFBundleVersion` через `--build-number`. Первый номер — `1`, если такой
   сборки ещё нет в App Store Connect. Работать из чистого коммита с постоянным ID.
   Минимум iOS 13.0 задан одинаково в проекте Xcode, Podfile и Flutter framework;
   программа тестирования ограничена iPhone 14 Pro, английским и портретным режимом.
4. **ждёт O4** · 15–40 мин. До подписания использовать согласованные в V7 иконку Sharky и экран
   запуска. В репетиции иконка 1024×1024 без альфы, с логотипом Flutter, а экран запуска
   белый. Собрать подписанный архив и IPA. [Загрузка сборок Apple](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds).

   ```bash
   flutter clean
   flutter pub get --enforce-lockfile
   sharky_build_number=1  # заменить следующим номером перед новой загрузкой
   flutter build ipa --release --no-pub --build-number="$sharky_build_number" \
     --dart-define=SHARKY_BETA_METRICS=true --export-method app-store
   python3 tools/ios_candidate_guard_v1.py --source-commit "$(git rev-parse HEAD)" \
     --app build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app
   open build/ios/archive/Runner.xcarchive
   ```

   Очистка пересобирает пакет после обновления зависимостей и исключает старые
   файлы SDK в `Runner.app`. В Organizer проверить идентификатор, версию и номер.
5. **ждёт O4** · 40–50 мин. Заполнить поля ниже готовыми текстами T1 и реальными контактами.
   В App Privacy указать **Data Not Collected**. Учебные данные и Beta activity
   остаются на устройстве. Runner и встроенные библиотеки не заявляют сбор и трекинг.
   Сверить Privacy Report в Organizer для подписанного архива.
   В Info.plist установлено `ITSAppUsesNonExemptEncryption = NO`. Firestore,
   BoringSSL и gRPC убраны из поставки, SHA-256 используется для контрольных сумм.
6. **ждёт O4** · В App Information → Age Rating для текущей беты отметить
   **Gambling — No**, **Simulated Gambling — Frequent**: решения с учебными фишками
   повторяются в уроках. **Contests**, **Loot Boxes**, покупки, реклама, пользовательский
   контент, чат, свободный веб-доступ и родительские ограничения отсутствуют. Остальные
   категории контента отметить **None** после сверки с финальной сборкой. Возрастную
   маркировку рассчитывает Apple. Content Rights заполнить по подтверждённым правам.
   [Определения Apple](https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions).
7. **ждёт O4** · 50–60 мин. В Organizer выбрать **Distribute App → App Store Connect → Upload**.
   Формат **TestFlight Internal Only** подходит для сборки, которую будут тестировать
   только внутри команды. После обработки у Apple в TestFlight выбрать сборку и группу.
   Внутренние тестеры — пользователи App Store Connect с доступом к приложению.
   Для внешних создать отдельную группу, заполнить Beta App Review Information, добавить
   сборку и отправить её на Beta App Review. Приглашения внешним отправить после одобрения.
   [Как работает TestFlight](https://developer.apple.com/testflight/).
8. **ждёт O4 и O1** · На физическом iPhone установить эту подписанную сборку, пройти W1
   и проверить прогресс после перезапуска. Заранее согласовать бюджет запуска и первого
   доступного действия, затем замерить оба. Отдельно проверить переустановку по решению
   владельца. Текущий план беты предполагает начать заново, перенос истории не заявлен.

### Поля TestFlight → Test Information

| Поле App Store Connect | Значение |
|---|---|
| Beta App Description | текст «Beta description» ниже |
| What to Test (на каждую сборку) | текст «What to test» ниже |
| Feedback Email | `<support e-mail владельца>` — тот же адрес, что в privacy-странице |
| Privacy Policy URL | `<публичный URL страницы приватности>` — текст ниже, публикует владелец |
| Marketing URL | не нужен для беты |
| Beta App Review: контакт | `<имя, телефон, e-mail контакта для проверки>` |
| Beta App Review: Sign-in required | No |
| Beta App Review: Notes | No account is required. Open Learn, start World 1 and answer incorrectly once to try the feedback and repair loop. Settings are under You. All chips are for training and have no cash value. |

**Beta description** (до 4000 символов):

```text
Sharky helps new and micro-stakes No-Limit Hold'em players fix common mistakes fast.

For this beta, please focus on Worlds 1–4 of the learning route: table basics, positions and action order, showdowns and hand strength, and first real decisions. Each lesson explains one idea, asks you to decide in a real table spot, then shows why your answer was right or what to do instead. A mistake comes back as a short repeat until you get it right.

The beta is English only, iPhone only, portrait. It works offline, needs no account and stores your progress only on this device.
```

**What to test** (до 4000 символов; правится к каждой сборке):

```text
Thank you for testing Sharky! Please play for 20–30 minutes, as you normally would.

1. Start as a new player and finish the first lessons of World 1.
2. Get at least one answer wrong on purpose. Can you name the clue you missed after reading the explanation? If Review offers a repair, open it and check whether it practices that clue. If a scheduled review is due, does its card make clear what you are coming back to practice?
3. Close the app fully and open it again. You should continue where you stopped, with the same XP.
4. Try Practice and the You tab. Do they show what you actually did?

Please tell us:
- where you stopped or did not know what to do;
- any text you had to read twice or did not understand;
- any table spot that looks wrong (cards, pot, bets, whose turn it is);
- anything slow, frozen or broken.

On Day 2 and Day 7, open You → Settings → Beta activity → Copy summary and paste it into your beta feedback.

To send feedback, take a screenshot in the app and tap Share Beta Feedback, or open TestFlight and tap Send Beta Feedback. Please do not include private information.

Known: the visual design is still in progress. The test scope is Worlds 1–4.
```

### Локальные метрики беты

Для бета-сборки передать Flutter флаг `--dart-define=SHARKY_BETA_METRICS=true`.
Сводка и пять необязательных вопросов доступны в You → Settings → Beta activity.
Завершение первого урока, W1 и число исправлений берутся из сохранённого прогресса.
Отметки возврата считаются от первого открытия бета-сборки: Day 2 — [24, 48) ч,
Day 7 — [144, 168) ч. Засчитываются запуск или возврат приложения из фона в окне.
Данные остаются на устройстве и удаляются через Delete local data.

**Copy summary** помещает текст версии 1 в буфер обмена. В нём номер дня беты
(0–7), состояние первого урока и W1, возвраты, результаты самостоятельных ответов
и ответов с помощью, текущий и самый дальний открытый урок, счётчик уроков,
результат проверки правил W1, повторы после ошибки, состояние напоминания и
ответы анкеты. Строки по дням содержат число уроков и шагов Daily Practice,
зафиксированных этой версией. По каждому уроку с ответом есть число первых
ответов, ошибок в них и ответов с помощью по сохранённым учебным записям.
В тексте нет имён, идентификатора устройства, точного времени и свободного
текста. Тестер сам решает, прикладывать ли сводку к отзыву.

На наборе тестовых установок доля завершения — число завершивших из установок с
доступными данными. Доля возврата — число вернувшихся из установок, у которых
соответствующее окно закончилось. Пустой знаменатель оставляем без процента.
Сводка на телефоне показывает данные одной установки.

#### Пять проверок B0

| Проверка карты V0 | Что смотреть |
| --- | --- |
| Быстро прошёл первый шаг и понял его | После первого ответа попросить игрока объяснить выбор и найти свои карты на другом столе без подписей. В Beta activity сверить завершение урока и ответ на первый вопрос анкеты. |
| Ответы с помощью и без неё | В Day 1 сравнить On your own и With help. В каждой задаче берётся первый ответ в первые 24 часа бета-сборки. Записи без достоверного признака помощи исключаются. |
| Выход после второй ошибки | Дважды ошибиться, прочитать разбор, продолжить урок, перезапустить приложение и сверить Review и XP. Спросить в анкете, удалось ли продолжить; число исправлений показывает только подтверждённые исходы. |
| Home на Day 2 | Подготовить прерванный урок и повтор к сроку. До нажатия спросить, куда ведёт главное действие; сверить результат и ответ анкеты. |
| Возврат и знания на Day 7 | Считать возврат отдельно от правильных первых ответов на новых заданиях повтора без помощи в окне [144, 168) ч. Если новых ответов нет, результат точности пустой. Текущее состояние напоминания видно на устройстве; для сравнения групп зафиксировать выбор в начале беты и учитывать изменения отдельно. |

Все пять проверок остаются локальными или проходят в присутствии тестера. Для
каждого вывода указать число наблюдений и причину, если данных мало.

После беты для CMP-01 нужен один сценарий на сопоставимых установленных сборках.
Отправная точка для выбора сценария — [сравнение пяти конкурентов](plan/COMPETITOR_COMPARISON_v1.md)
по открытым материалам и текущему курсу Sharky.


**Privacy page.** Публикуется текст `PrivacyScreen._body` из `lib/ui/settings/privacy_terms.dart`
(тот же, что в приложении: You → Settings → Privacy Policy; A7) дословно, затем блок контакта:

```text
Who we are and how to reach us
Sharky is operated by <operator name, country>. Questions about this notice or your data: <support e-mail>.
```

Если текст в приложении меняется, страница обновляется в том же PR. Страницу публикует владелец,
например на GitHub Pages.

## 0.3.3 · Черновики для публичного выпуска 1.0

### Тексты App Store Connect для English (U.S.)

**Name**

Sharky Poker

**Subtitle**

Learn Texas Hold’em

**Promotional Text**

Practice poker decisions in short lessons. See why an answer works, then revisit the clues you missed.

**Description**

```text
Learn Texas Hold'em one decision at a time. Sharky Poker teaches table positions, hand strength and betting basics through short lessons and simulated hands.

Read the table, choose an answer and see why it works. When you miss a clue, try it again or revisit it in Review. Sharky saves your progress on your iPhone so you can pick up where you left off.

The lessons work offline and require no account. Training chips have no cash value.
```

**Keywords**

no limit,positions,hand rankings,pot odds,bet sizing,practice,table decisions

**App Review Notes**

```text
No sign-in is required. On first launch, choose Start with the basics, then tap Next in the first lesson. In the first table question, choose “The shared cards in the middle” to see the explanation. Tap Try same clue, then choose “Board cards” on the repeat. Open You → Settings for Privacy Policy and Delete local data. The app uses simulated poker hands and training chips with no cash value.
```

**Release summary для первого выпуска**

Practice table positions, hand strength and betting decisions in short Texas Hold’em lessons, with explanations and a chance to revisit missed decisions.

Эта фраза подходит для сводки первого выпуска. Поле What’s New появляется с первым обновлением. Его текст заполняют по реально выпущенным изменениям. Сверить кнопки из App Review Notes с подписанным RC.
Ограничения полей сверены с документацией Apple.
[Имя и подзаголовок](https://developer.apple.com/help/app-store-connect/reference/app-information/app-and-compliance-information/),
[описание, ключевые слова и данные для проверки](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/).

### Политика конфиденциальности и поддержка

- Текст страницы для 1.0 — [Sharky Poker Privacy Policy](release/privacy_policy_1_0_en.md).
  Перед публикацией владелец добавляет подтверждённые имя, страну, контактный адрес,
  почту и дату вступления в силу. Он подтверждает обработку и хранение писем и правила хостинга страницы. Если хостинг или поддержка собирают дополнительные данные, это
  отражается в политике до публикации. Адрес и сведения об операторе должны
  соответствовать требованиям выбранных стран.
- В App Store Connect указываются проверенные публичные HTTPS-адреса для
  **Privacy Policy URL** и **Support URL**. На странице поддержки должны быть
  действующая почта, информация об операторе и путь **You → Settings → Delete local data**.
  Перед GO открыть обе ссылки без входа и отправить тестовое обращение с получением
  ответа. Контакт App Review вносится в закрытые поля консоли.
- На подписанном публичном RC проверить состав SDK, Privacy Report, отсутствие
  передачи учебных записей, трекинга и beta-метрик, а также удаление данных при
  выключенной сети. Для сборки 1.0 не передавать `SHARKY_BETA_METRICS=true`.
  **Data Not Collected** подходит для данных, остающихся на устройстве. Ответы в
  App Privacy сверить по фактическому сбору в RC, включая данные, доступные через
  интеграции Apple, и условия Apple для добровольной поддержки. Перед подачей
  версия текста в A7 всё ещё озаглавлена «English iPhone beta» и описывает
  TestFlight. Перед GO требуется отдельное изменение A7 с текстом для
  публичной сборки. Сверить его с политикой по типам данных, локальному хранению,
  напоминанию, резервным копиям, удалению и обработке обращений.
  [Критерии App Privacy](https://developer.apple.com/app-store/app-privacy-details/),
  [App Review Guidelines, разделы 1.5 и 5.1.1](https://developer.apple.com/app-store/review/guidelines/).
- В анкете возраста для текущего формата уроков заложены **Gambling — No** и
  **Simulated Gambling — Frequent**. Владелец сверяет остальные поля с RC,
  подтверждает права на все материалы и выбирает страны. При Frequent
  Simulated Gambling таблица Apple даёт 18+ на новых версиях ОС, итог по
  регионам берётся из App Store Connect. Экспортное соответствие сверяется с
  подписанным архивом.
  [Определения возрастных категорий Apple](https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions).

### Права на продукт и материалы

Владелец подтверждает права на название и логотип, иллюстрации и карточную графику,
шрифты, звук, тексты и материалы зависимостей для конкретного RC. В реестр идут
источник, правообладатель и разрешение на распространение. Поле **Copyright**
получает год возникновения исключительных прав и юридическое имя правообладателя
после подтверждения. Сведения для подачи остаются открытыми.
[Владелец метаданных](release/submission_metadata_truth_v1.md).
[Требование Apple к полю Copyright](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/).

### Текст для страницы поддержки

For help with Sharky Poker, use the contact details on this page. Include the
app version, your iPhone model and what you were doing when the issue occurred.
Keep personal information out of screenshots. To clear progress and settings
on this iPhone, open You → Settings → Delete local data.

### GO / HOLD

Текущее решение — **HOLD**. Для 1.0 выбрать **Manually release this version**.
Apple оставляет одобренную сборку в **Pending Developer Release** до действия
оператора. [Ручной выпуск](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/select-an-app-store-version-release-option/).

1. **Условия Roadmap.** Владелец письменно определяет, как применить к 1.0
   исходный release gate и расхождение 94/119 из REL-03. До решения действуют
   исходные условия. Подготовка плана не засчитывает ни REL-02, ни REL-03.
   [Roadmap 2.0, критерии REL-01–03](https://docs.google.com/spreadsheets/d/1gPCmABS47i6dhO2JHeFyOd6WH4upspRUSWYmbz7Na00/edit#gid=2026111401&range=B172:J175).
2. **Точный RC.** Записать коммит, Bundle ID, Team ID, версию и номер сборки,
   ссылку на архив и запись App Store Connect. Собрать из чистого коммита с
   постоянным ID, проверить `tools/ios_candidate_guard_v1.py`, применимые CI и
   проверку подписи. Для выбранного архива записать рабочий канал поддержки,
   ссылку на политику, проверенные возрастную анкету и права. Финальные материалы
   магазина берутся после утверждения экрана и V9.
3. **Физический iPhone.** Из того же подписанного RC пройти запуск, W1, ошибку,
   повтор, продолжение и выход с возвратом к сохранённому шагу. Проверить
   офлайн-режим, обновление поверх допустимой предыдущей сборки без потери XP и
   истории, локальное удаление, Reduce Motion, VoiceOver и Dynamic Type.
   Сверить бюджеты P1 выше. Для первой поставки согласовать с владельцем, как
   обрабатываются существующие установки TestFlight.
4. **Решение владельца.** Владелец проверяет материалы, протокол и результаты,
   назначает оператора и дублёра с ролью App Store Connect, фиксирует сборку и
   совместимую базу восстановления в
   [шаблоне решения](release/release_owner_decision_template_v1.md).
   При сбое запуска, потере прогресса, неверной оценке или цене колла,
   противоречии политике, проблеме с правами или невыполненном условии релиза —
   HOLD. Оператор нажимает **Release This Version** только для номера сборки
   из зафиксированного GO владельца.
5. **После выхода.** В день выпуска проверить доступность в выбранных странах,
   страницу магазина, ссылки и установку на физический iPhone. Оператор и
   дублёр проверяют поддержку и доступные отчёты Apple в день выпуска и на
   следующий день. Для инцидента записывают время, версию/build, влияние,
   воспроизведение и решение владельца. Учебные записи остаются на устройстве.

### Остановка распространения и восстановление

| Когда | Действие оператора | Как подтвердить |
|---|---|---|
| Критический дефект до публикации | HOLD в Pending Developer Release. Если ранее началось распространение и кнопка ещё доступна, нажать **Cancel This Release**. Загрузить исправленную сборку с новым номером и заново проверить её. | В консоли выпуск остановлен, публичная установка не началась. Для нового номера повторены затронутые проверки. |
| Критический дефект после выхода 1.0 | По решению владельца через **Pricing and Availability** снять затронутые страны или выбрать **Remove App From Sale**. Зафиксировать прежний список стран и время действия. | Проверить статусы стран в консоли и доступность с витрины, учитывая до 24 часов на распространение изменения. Уже скачавшие пользователи сохраняют установленное приложение, могут получать обновления и, пока действует соглашение, могут повторно скачать его из истории. |
| Сбой в будущем поэтапном обновлении | Приостановить **Phased Release**. При серьёзном риске оценить снятие с витрины, поскольку ручная загрузка остаётся доступной при паузе. | Консоль показывает паузу. Пауза влияет на автоматическое обновление. |
| Возврат к стабильной работе | Собрать новую версию с тем же Bundle ID и следующими версией и номером. Взять минимальное исправление либо совместимый проверенный код из зафиксированной базы. Для критического бага запросить ускоренную проверку, приложив шаги воспроизведения. | На iPhone выполнить обновление поверх проблемной версии без удаления приложения. Проверить XP, историю, запуск, урок и исправленный сценарий. Владелец заново фиксирует GO для исправления и доступность стран. |

App Store не может заменить уже вышедшую версию старой. Восстановление
установленных копий выполняется новым обновлением. При выборе базы сравнить
формат локального прогресса и совместимость обратного чтения. Не просить
переустанавливать приложение для устранения инцидента с потерей прогресса.
Кнопку удаления записи приложения из App Store Connect не использовать.
[Ограничение на возврат версии](https://developer.apple.com/help/app-store-connect/update-your-app/create-a-new-version),
[управление доступностью](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/manage-availability-for-your-app-on-the-app-store),
[пауза обновления](https://developer.apple.com/help/app-store-connect/update-your-app/release-a-version-update-in-phases/),
[ускоренная проверка](https://developer.apple.com/help/app-review/after-submitting-for-review/request-expedited-review).
