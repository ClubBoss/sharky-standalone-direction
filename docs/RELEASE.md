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

Нужно членство в Apple Developer Program, постоянный bundle ID и запись в App Store Connect.
Шаги допишем, когда этап S5 станет текущим.
