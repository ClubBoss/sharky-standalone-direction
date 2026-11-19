# Сборка на iPhone

## Бесплатно: свой iPhone через Xcode (до беты)

Нужно: Mac с Xcode, iPhone, кабель, обычный Apple ID. Подписка Apple Developer не нужна.

1. `flutter pub get`, затем открыть `ios/Runner.xcworkspace` в Xcode.
2. Xcode → Settings → Accounts → добавить свой Apple ID.
3. Target Runner → Signing & Capabilities → Team: ваш Personal Team.
4. Bundle Identifier: заменить `com.example.pokerAnalyzer` на свой, например `com.<имя>.sharky.dev`
   (`com.example` Apple не регистрирует). Не коммитить эту правку, пока не выбран постоянный ID.
5. Подключить iPhone, выбрать его как устройство, Run (⌘R).
6. На iPhone: Настройки → Основные → VPN и управление устройством → доверять разработчику.
7. Подпись живёт 7 дней; потом снова Run из Xcode.

Тихий тест (S2) — на этом же iPhone: дать телефон участнику, сценарий в `docs/PLAN.md`.

## Платно: TestFlight (к S5)

Нужно членство в Apple Developer Program, постоянный bundle ID и запись в App Store Connect (O4).
Шаги загрузки допишем после O4. Тексты для App Store Connect готовы ниже (T1, REL-02.a):
их вставляют как есть, менять нужно только строки с `<...>`.

### Поля TestFlight → Test Information

| Поле App Store Connect | Значение |
|---|---|
| Beta App Description | текст «Beta description» ниже |
| What to Test (на каждую сборку) | текст «What to test» ниже |
| Feedback Email | `<support e-mail владельца>` — тот же адрес, что в privacy-странице |
| Privacy Policy URL | `<публичный URL страницы приватности>` — текст ниже, публикует владелец |
| Marketing URL | не нужен для беты |
| Beta App Review: контакт | имя, телефон и e-mail владельца; вход не нужен (аккаунтов нет) |

**Beta description** (до 4000 символов):

```text
Sharky helps new and micro-stakes No-Limit Hold'em players fix common mistakes fast.

This beta covers Worlds 1–4 of the learning route: table basics, positions and action order, showdowns and hand strength, and first real decisions. Each lesson explains one idea, asks you to decide in a real table spot, then shows why your answer was right or what to do instead. A mistake comes back as a short repeat until you get it right.

The beta is English only, iPhone only, portrait. It works offline, needs no account and stores your progress only on this device.
```

**What to test** (до 4000 символов; правится к каждой сборке):

```text
Thank you for testing Sharky! Please play for 20–30 minutes, as you normally would.

1. Start as a new player and finish the first lessons of World 1.
2. Get at least one answer wrong on purpose. Does the explanation make clear why, and does the repeat help?
3. Close the app fully and open it again. You should continue where you stopped, with the same XP.
4. Try Practice and the You tab. Do they show what you actually did?

Please tell us:
- where you stopped or did not know what to do;
- any text you had to read twice or did not understand;
- any table spot that looks wrong (cards, pot, bets, whose turn it is);
- anything slow, frozen or broken.

To send feedback, take a screenshot in the app and tap Share Beta Feedback, or open TestFlight and tap Send Beta Feedback. Please do not include private information.

Known: the visual design is not final yet; worlds after World 4 are not in this beta.
```

### Локальные метрики беты

Для бета-сборки передать Flutter флаг `--dart-define=SHARKY_BETA_METRICS=true`.
Сводка и три необязательных вопроса доступны в You → Settings → Beta activity.
Завершение первого урока, W1 и число исправлений берутся из сохранённого прогресса.
Отметки возврата считаются от первого открытия бета-сборки: Day 2 — [24, 48) ч,
Day 7 — [144, 168) ч. Засчитываются запуск или возврат приложения из фона в окне.
Данные остаются на устройстве и удаляются через Delete local data.

На наборе тестовых установок доля завершения — число завершивших из установок с
доступными данными. Доля возврата — число вернувшихся из установок, у которых
соответствующее окно закончилось. Пустой знаменатель оставляем без процента.
Сводка на телефоне показывает данные одной установки.

**Privacy page.** Публикуется текст `PrivacyScreen._body` из `lib/ui/settings/privacy_terms.dart`
(тот же, что в приложении: You → Settings → Privacy Policy; A7) дословно, затем блок контакта:

```text
Who we are and how to reach us
Sharky is operated by <operator name, country>. Questions about this notice or your data: <support e-mail>.
```

Если текст в приложении меняется, страница обновляется в том же PR. Онлайн-функций нет, поэтому
App Privacy в App Store Connect: «Data Not Collected».

**Нужно от владельца (вместе с O4):** e-mail поддержки, имя оператора и страна, публичный URL
страницы приватности (подойдёт бесплатный GitHub Pages / Cloudflare Pages).
