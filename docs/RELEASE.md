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


**Privacy page.** Публикуется текст `PrivacyScreen._body` из `lib/ui/settings/privacy_terms.dart`
(тот же, что в приложении: You → Settings → Privacy Policy; A7) дословно, затем блок контакта:

```text
Who we are and how to reach us
Sharky is operated by <operator name, country>. Questions about this notice or your data: <support e-mail>.
```

Если текст в приложении меняется, страница обновляется в том же PR. Страницу публикует владелец,
например на GitHub Pages.
