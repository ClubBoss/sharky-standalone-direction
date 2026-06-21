# Global English Copy Inventory Audit v1

- Branch: `codex/act0-learn-route-clarity-v1`
- Mode: local-only audit.
- Purpose: inventory user-facing copy across active first-week UI, learning content, feedback/result copy, and dormant/future content so English cleanup can move from screenshot symptoms to systematic waves.
- Command: `./tools/audit_english_copy_v1.sh`

## Scope

- Scanned: `lib/`, `assets/`, `content/`, selected docs copy/content contract areas, and `test/` preview strings.
- Excluded: `build/`, `.dart_tool/`, `output/`, `external_competitors/`, generated screenshots/zips, archive/history docs.
- Product code/copy was not modified.

## Outputs

- `output/copy_audit/current/english_copy_inventory.md`
- `output/copy_audit/current/english_copy_findings.md`
- `output/copy_audit/current/english_copy_inventory.json`
- `output/copy_audit/current/english_copy_summary.json`

Generated audit outputs are local-only evidence and are not intended to be committed.

## Inventory counts

- Total inventory strings: `97533`

Visibility counts:

- `active_feedback_result`: `268`
- `active_first_week_learning_content`: `637`
- `active_first_week_ui`: `7041`
- `dormant_future_content`: `48001`
- `internal_dev_test`: `16703`
- `unknown`: `24883`

Source counts:

- `dart_string`: `31992`
- `json_content`: `7165`
- `markdown_content`: `37609`
- `test_preview`: `16684`
- `yaml_content`: `4083`

## Findings counts by category

- `awkward_english`: `6`
- `copy_not_centralized`: `355`
- `cta_clarity`: `24`
- `cyrillic_in_active_english`: `2130`
- `dormant_copy_debt`: `4000`
- `duplicate_or_near_duplicate`: `311`
- `feedback_not_actionable`: `20`
- `forbidden_claim`: `2231`
- `learning_content_clarity`: `4`
- `poker_term_unintroduced`: `58`
- `term_inconsistency`: `15`
- `too_long_for_mobile`: `160`
- `visible_internal_jargon`: `97`

Confidence counts:

- `high`: `1993`
- `medium`: `7001`
- `low`: `417`

## Top high-confidence issues

1. `forbidden_claim` — `lib/ui_v2/act0_shell/act0_play_shell_v1.dart:980` — `See what premium adds`
2. `cyrillic_in_active_english` — `lib/ui_v2/act0_shell/act0_play_shell_v1.dart:1262` — `)}. Выбери одну и сделай несколько повторов.`
3. `cyrillic_in_active_english` — `lib/ui_v2/act0_shell/act0_play_shell_v1.dart:1265` — `)} по теме $selectedTopic.`
4. `cyrillic_in_active_english` — `lib/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart:153` — `Проверь историю раздачи`
5. `cyrillic_in_active_english` — `lib/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart:174` — `Повторить идею`
6. `cyrillic_in_active_english` — `lib/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart:274` — `История раздачи`
7. `cyrillic_in_active_english` — `lib/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart:297` — `Сейчас на столе: $currentStreet · В истории: $trailStreet`
8. `cyrillic_in_active_english` — `lib/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart:300` — `Смотри историю раздачи.`
9. `cyrillic_in_active_english` — `lib/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart:314` — `Проверка группы`
10. `cyrillic_in_active_english` — `lib/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart:321` — `Чтение руки`

## Recommended next cleanup wave

Fix now:

1. Active runtime-surface Cyrillic leakage in `lib/ui_v2/act0_shell/act0_runtime_surface_copy_v1.dart`.
2. Active Practice/Play Cyrillic snippets in `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`.
3. Active premium/deferred-commerce visible copy hits, starting with `See what premium adds`.
4. Active internal-jargon candidates and generic CTAs only after verifying visibility against `core_fast`.

Defer:

- Dormant/future content under non-first-week assets and docs.
- Broad content-quality pass for advanced poker terms, long mobile text, and feedback actionability after active UI leakage is closed.
- Centralization cleanup unless a string is proven visible and unstable.

## Guard/test ideas

- Add a focused active Act0 copy guard that fails on Cyrillic in English-first rendered surfaces.
- Add a forbidden/deferred-commerce term guard for active first-week UI copy.
- Add a focused copy inventory check that reports new active strings without blocking dormant content.
- Use `./tools/screen_review_fast_v1.sh core compact` after each active copy cleanup to validate actual visible output.

## Deferred limitations

- Static extraction is conservative and can over-count Dart constants, docs prose, test previews, and localization alternatives.
- Some findings require runtime visibility confirmation before editing.
- Generated output under `output/copy_audit/current/` is local-only and should be regenerated as needed.
