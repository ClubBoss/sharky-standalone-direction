# Act0 RU Translation Master Workbook v1

Status: GENERATED
Scope: `Act0` canonical route in `/Users/elmarsalimzade/Sharky_1.0`

This is the master handoff index for all current Act0 worlds.
Use the per-world pack files in this folder for actual translation work.

## Workflow
1. Pick a world pack from the table below, starting with the highest visible-value gaps.
2. Translate or improve only the `*_ru` fields inside that world pack.
3. Keep ids unchanged and return the edited Markdown.
4. Integrate the returned copy into `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart`.
5. Re-run gap, coverage, and copy-fit audits.
6. If landed copy sounds wooden, rewrite it in the world pack first. Editorial polish uses the same pipeline as missing translations.

## Commands
- `dart run tools/act0_translation_workbook_sync.dart --lang ru`
- `dart run tools/act0_content_copy_coverage_report.dart --lang ru`
- `dart run tools/act0_translation_pack_audit.dart --lang ru`
- `dart run tools/act0_translation_pack_ingest.dart --lang ru <pack files>`
- `dart run tools/act0_content_copy_priority_audit.dart`
- `dart run tools/act0_content_copy_gap_audit.dart`
- `dart run tools/act0_copy_fit_audit.dart`

## Coverage Snapshot
- Worlds localized: 12/12 (100.0%)
- Lessons localized: 10/43 (23.3%)
- Tasks localized: 75/228 (32.9%)
- Runner prompts localized: 68/227 (30.0%)
- Runner supports localized: 68/227 (30.0%)
- Runner questions localized: 61/227 (26.9%)

## World Packs
| World | EN title | Lessons | Tasks | Runner prompts | Runner supports | Runner questions | Pack |
| --- | --- | --- | --- | --- | --- | --- | --- |
| world_1 | Poker from Zero | 8/8 | 57/57 | 50/57 | 50/57 | 43/57 | [W01_world_1_RU_PACK_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/W01_world_1_RU_PACK_v1.md) |
| world_2 | Hand Discipline | 2/2 | 12/12 | 12/12 | 12/12 | 12/12 | [W02_world_2_RU_PACK_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/W02_world_2_RU_PACK_v1.md) |
| world_3 | Position Thinking | 0/1 | 6/6 | 6/6 | 6/6 | 6/6 | [W03_world_3_RU_PACK_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/W03_world_3_RU_PACK_v1.md) |
| world_4 | Preflop Framework | 0/0 | 0/0 | 0/0 | 0/0 | 0/0 | [W04_world_4_RU_PACK_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/W04_world_4_RU_PACK_v1.md) |
| world_5 | Bet Purpose And Price | 0/7 | 0/29 | 0/29 | 0/29 | 0/29 | [W05_world_5_RU_PACK_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/W05_world_5_RU_PACK_v1.md) |
| world_6 | Board And Draws | 0/0 | 0/0 | 0/0 | 0/0 | 0/0 | [W06_world_6_RU_PACK_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/W06_world_6_RU_PACK_v1.md) |
| world_7 | Range Thinking Lite | 0/5 | 0/27 | 0/27 | 0/27 | 0/27 | [W07_world_7_RU_PACK_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/W07_world_7_RU_PACK_v1.md) |
| world_8 | Stack Depth And Risk | 0/4 | 0/21 | 0/21 | 0/21 | 0/21 | [W08_world_8_RU_PACK_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/W08_world_8_RU_PACK_v1.md) |
| world_9 | Tournament Pressure | 0/4 | 0/21 | 0/21 | 0/21 | 0/21 | [W09_world_9_RU_PACK_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/W09_world_9_RU_PACK_v1.md) |
| world_10 | Player Adjustment | 0/4 | 0/21 | 0/21 | 0/21 | 0/21 | [W10_world_10_RU_PACK_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/W10_world_10_RU_PACK_v1.md) |
| world_11 | Real Play Transfer | 0/4 | 0/17 | 0/17 | 0/17 | 0/17 | [W11_world_11_RU_PACK_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/W11_world_11_RU_PACK_v1.md) |
| world_12 | Mindset Bridge | 0/4 | 0/17 | 0/16 | 0/16 | 0/16 | [W12_world_12_RU_PACK_v1.md](/Users/elmarsalimzade/Sharky_1.0/docs/l10n/act0_world_packs/W12_world_12_RU_PACK_v1.md) |
