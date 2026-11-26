# Beta gate · остаток к бете

Пересчитать из PLAN: `python3 tools/release/beta_gate_report_v1.py`.
Команды — из корня репозитория; замените параметры в `<...>` своими значениями. Отчёт ничего не запускает и не закрывает.
Открыто: **10** · agent: **2** · отложено: **1**.

| Пункт | Блокер / кто | Подготовка / команда | Оценка, мин |
|---|---|---|---|
| A8 | owner · открыто: Подписанный RC после O4; замеры и переустановка на iPhone | `tools/release/ios_release_dryrun_v1.sh && python3 tools/release/owner_day_preflight_v1.py`<br>[OWNER_DEVICE_DAY_v1.md](OWNER_DEVICE_DAY_v1.md) · [SIGNING_CHECKLIST_v1.md](SIGNING_CHECKLIST_v1.md) · [RELEASE.md](../RELEASE.md) | 45–90 (dry run + подпись) |
| L0 | agent · открыто: Сверить незакрытый статус карты L0 и B76 | no prep yet<br>[b76_l01_c5_w1w4_exceptions_v1.md](../_reviews/b76_l01_c5_w1w4_exceptions_v1.md) | — |
| Q3 | iPhone · открыто: F1: замер запуска и первого вопроса на устройстве | `python3 tools/measure_w1_startup_v1.py <device-id>`<br>[RELEASE.md](../RELEASE.md) | — |
| Q14 | agent · открыто: Сверить статус Q14 в PLAN: запись о закрытии внутри строки не закрывает блок | no prep yet<br>[b77_q142_w1w12_gap_audit_v1.md](../_reviews/b77_q142_w1w12_gap_audit_v1.md) | — |
| V6 | visual · открыто: Финальный скин, проверка экранов и нативная читаемость | `./tools/capture_act0_screens_v1.sh all compact; ./tools/capture_act0_screens_v1.sh v9 walkthrough; python3 tools/designer_pack_v1.py`<br>[DESIGNER_PACK_v1.md](DESIGNER_PACK_v1.md) · [SKIN_LAYER_v1.md](../plan/SKIN_LAYER_v1.md) | — |
| V7 | visual · открыто: Арт, права, иконка, launch screen, подключение и нативная проверка | `flutter test test/ui_v2/act0_skin_asset_slots_v1_test.dart`<br>[README.md](../../assets/skin_v1/README.md) | — |
| V9 | iPhone · открыто: Полный захват и проверка финального скина на физическом iPhone | `./tools/capture_act0_screens_v1.sh v9 walkthrough`<br>[V9_CHECKLIST_v1.md](V9_CHECKLIST_v1.md) · [OWNER_DEVICE_DAY_v1.md](OWNER_DEVICE_DAY_v1.md) | 30 (на телефоне) |
| O1 | owner · открыто: Установить подписанную сборку и лично пройти W1 | `open ios/Runner.xcworkspace`<br>[OWNER_DEVICE_DAY_v1.md](OWNER_DEVICE_DAY_v1.md) · [RELEASE.md](../RELEASE.md) | 10–15 (только установка) |
| O4 | owner · открыто: Решение о переустановке, Apple Developer и доступы | `open ios/Runner.xcworkspace`<br>[SIGNING_CHECKLIST_v1.md](SIGNING_CHECKLIST_v1.md) · [RELEASE.md](../RELEASE.md) | — |
| Бета | owner · открыто: Внешний TestFlight: метаданные, upload и Beta App Review после ворот и O4 | `open build/ios/archive/Runner.xcarchive`<br>[RELEASE.md](../RELEASE.md) · [APP_STORE_TEXT_v1.md](drafts/APP_STORE_TEXT_v1.md) · [PRIVACY_POLICY_DRAFT_v1.md](drafts/PRIVACY_POLICY_DRAFT_v1.md) · [SUPPORT_PAGE_DRAFT_v1.md](drafts/SUPPORT_PAGE_DRAFT_v1.md) · [REVIEW_NOTES_v1.md](drafts/REVIEW_NOTES_v1.md) · [HALT_ROLLBACK_RUNBOOK_v1.md](drafts/HALT_ROLLBACK_RUNBOOK_v1.md) | 20 (метаданные + upload; не ожидание Apple) |
| **Итого (известное время)** | 6 без оценки | Без ожиданий Apple, дизайна и неоценённых проверок | **105–155** |

Оценки — только указанные в подготовительных документах этапы, не полный срок до беты. Подписание и установка считаются отдельно; общий бюджет owner day не прибавляется повторно.

## Отложено владельцем (не входит в итог)

| Пункт | Блокер / кто | Подготовка / команда | Оценка, мин |
|---|---|---|---|
| O2 | owner · отложено: Тихий тест и F1M после разрешения владельца | `python3 tools/f1m_report_v1.py --observations <private-observations.csv>`<br>[OWNER_RUN_v1.md](quiet_test/OWNER_RUN_v1.md) · [OWNER_DEVICE_DAY_v1.md](OWNER_DEVICE_DAY_v1.md) | 75–165 (setup + 3–5 участников) |

## Перед днём на устройстве

Единый порядок: [OWNER_DEVICE_DAY_v1.md](OWNER_DEVICE_DAY_v1.md). Дополнительный GRO-прогон: [GRO_PHONE_CHECKLIST_v1.md](GRO_PHONE_CHECKLIST_v1.md) (B113, 1.5, не отдельный блок беты; в итог не включён).

Agent: L0, Q14 — требуется сверка/работа агента (exit 1).
