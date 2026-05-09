# Developer CLI Usage and Jam/Fold Analysis

# Developer Notes

## Jam/Fold EV Enrichment

Tools to enrich reports with jam/fold EV, summarize results, and rank impactful spots.

Exactly one of `--in`, `--dir`, or `--glob` must be provided. `--out` can only be used with `--in`.

Run only the enrichment tests:

```sh
dart test test/ev/jam_fold_evaluator_test.dart
```

Generate jam vs fold EV for existing reports:

```sh
dart run bin/ev_enrich_jam_fold.dart --in report.json --out report.json
```

Batch enrich an entire directory:

```sh
dart run bin/ev_enrich_jam_fold.dart --dir reports/
```

Use a glob pattern:

```sh
dart run bin/ev_enrich_jam_fold.dart --glob "reports/**/*.json"
```

Preview changes without writing:

```sh
dart run bin/ev_enrich_jam_fold.dart --dir reports/ --dry-run
```

## Jam/Fold Report Summary

Aggregate jam/fold data from enriched reports. Exactly one of `--in`, `--dir`, or `--glob` must be provided. Use `--validate` to ensure every spot has `jamFold` with a `bestAction` of `jam` or `fold`.

Summarize a directory:

```sh
dart run bin/ev_report_jam_fold.dart --dir reports/
```

Validate a single report:

```sh
dart run bin/ev_report_jam_fold.dart --in report.json --validate
```

Fail if jam rate drops below a threshold:

```sh
dart run bin/ev_report_jam_fold.dart --dir reports/ --fail-under 0.95
```

## Jam/Fold Pack Summary

Summarize jam/fold decisions across reports:

```sh
dart run bin/ev_summary_jam_fold.dart --dir reports/
```

## Jam/Fold Delta Ranking

Surface the most impactful jam/fold spots:

```sh
# top 10 hottest spots across a tree
dart run bin/ev_rank_jam_fold_deltas.dart --dir reports/ --limit 10

# rank by absolute impact
dart run bin/ev_rank_jam_fold_deltas.dart --glob "reports/**/*.json" --abs-delta

# top 50, only positive jams with delta >= 0.5
dart run bin/ev_rank_jam_fold_deltas.dart --dir reports/ --limit 50 --action jam --min-delta 0.5

# absolute impact >= 1.0 regardless of action
dart run bin/ev_rank_jam_fold_deltas.dart --glob "reports/**/*.json" --abs-delta --min-delta 1.0

# Only consider reports under "packs/hot/**"
dart run bin/ev_rank_jam_fold_deltas.dart --dir reports/ --include "packs/hot/**"

# Broad include, then exclude archived packs
dart run bin/ev_rank_jam_fold_deltas.dart \
  --glob "reports/**/*.json" \
  --include "reports/**" --exclude "reports/**/archive/**"

# Combine with other filters and CSV
dart run bin/ev_rank_jam_fold_deltas.dart \
  --dir reports/ \
  --include "packs/**" --exclude "packs/**/old/**" \
  --abs-delta --min-delta 1.0 --format csv --fields path,delta,bestAction

> **Shell globbing:** quote patterns to avoid your shell expanding them. Use single quotes on macOS/Linux/PowerShell. On cmd.exe, the shell doesn't expand globs; just quote patterns with spaces, e.g. `--include "* *"`.
> Examples:
> * **bash/zsh:** `--include '* *'`
> * **PowerShell:** `--include '* *'`
> * **cmd.exe:** `--include "* *"`
> If you see `Unknown or incomplete argument: A*s`, wrap the pattern in quotes.

# Only AK combos anywhere
dart run bin/ev_rank_jam_fold_deltas.dart --dir reports/ --include-hand "A*s K*s,A*h K*h"

# Include broad, then exclude suited broadways
dart run bin/ev_rank_jam_fold_deltas.dart \
  --glob "reports/**/*.json" \
  --include-hand "A* K*,Q* J*" --exclude-hand "*s *s"

# Compose with other filters & CSV
dart run bin/ev_rank_jam_fold_deltas.dart \
  --dir reports/ \
  --include-hand "A* A*" \
  --spr mid --action jam --abs-delta --min-delta 0.5 \
  --format csv --fields path,hand,delta

> **Note:** Hand and path glob matching is **case-sensitive** (same as `_globToRegExp`).
> The examples assume uppercase ranks and lowercase suits (e.g., `As Ks`, `*s *s`).
> **Shell globbing:** quote patterns to avoid your shell expanding them. Use single quotes on macOS/Linux/PowerShell. On cmd.exe, the shell doesn't expand globs; just quote patterns with spaces, e.g. `--include-hand "* *"`.
> Examples:
> * **bash/zsh:** `--include-hand '* *'`
> * **PowerShell:** `--include-hand '* *'`
> * **cmd.exe:** `--include-hand "* *"`
> If you see `Unknown or incomplete argument: A*s`, wrap the pattern in quotes.

# Only low-SPR (<1) jams, ranked by delta
dart run bin/ev_rank_jam_fold_deltas.dart --dir reports/ --spr low --action jam

# Absolute impact on high-SPR (>=2) spots only
dart run bin/ev_rank_jam_fold_deltas.dart --glob "reports/**/*.json" --spr high --abs-delta --min-delta 1.0

# Only 'wet' boards (per classifier)
dart run bin/ev_rank_jam_fold_deltas.dart --dir reports/ --texture wet

# Multiple tags: either 'wet' or 'paired'
dart run bin/ev_rank_jam_fold_deltas.dart --glob "reports/**/*.json" --texture wet,paired --limit 50

# Only flop spots, ranked by delta
dart run bin/ev_rank_jam_fold_deltas.dart --dir reports/ --street flop

# Turn-only with absolute impact and CSV fields
dart run bin/ev_rank_jam_fold_deltas.dart \
  --glob "reports/**/*.json" \
  --street turn --abs-delta --min-delta 0.5 \
  --format csv --fields path,board,delta

# One hottest spot per file
dart run bin/ev_rank_jam_fold_deltas.dart --dir reports/ --unique-by path

# One hottest per board across the tree (by absolute impact)
dart run bin/ev_rank_jam_fold_deltas.dart --glob "reports/**/*.json" --abs-delta --unique-by board

# Combine with filters & CSV
dart run bin/ev_rank_jam_fold_deltas.dart \
  --dir reports/ --spr mid --action jam --min-delta 0.5 \
  --unique-by hand --format csv --fields path,hand,delta

# Keep at most 2 hottest spots per file
dart run bin/ev_rank_jam_fold_deltas.dart --dir reports/ --per path --per-limit 2

# Top-3 per hand across the whole tree (by absolute impact)
dart run bin/ev_rank_jam_fold_deltas.dart --glob "reports/**/*.json" --abs-delta --per hand --per-limit 3

# Compose with filters & CSV
dart run bin/ev_rank_jam_fold_deltas.dart \
  --dir reports/ --spr mid --action jam --min-delta 0.5 \
  --per board --per-limit 2 \
  --format csv --fields path,board,delta
```

Alternate output formats:

```sh
# JSONL for easy piping
dart run bin/ev_rank_jam_fold_deltas.dart --dir reports/ --format jsonl

# CSV with selected columns and filters
dart run bin/ev_rank_jam_fold_deltas.dart \
  --glob "reports/**/*.json" \
  --abs-delta --min-delta 1.0 --action any \
  --format csv --fields path,spotIndex,delta,bestAction
```


## See Also

- [PROJECT_INSTRUCTIONS.txt](./docs/_archive/misc/PROJECT_INSTRUCTIONS.txt) for full system context.
- [CI_INSTRUCTIONS.md](./CI_INSTRUCTIONS.md) for test and export commands.
- [TRAINING_ARCHITECTURE.md](./TRAINING_ARCHITECTURE.md) for planner/loop/review engine design.

## Test Runner Matrix

- Use `flutter test` for any Flutter/widget/contract test under `test/guards`, `test/ui`, or `test/ui_v2`.
- Use `dart test` for pure Dart tests only (no `dart:ui` dependency).
- Do not run Flutter widget tests via `dart test`; this is not supported and can fail with `dart:ui` errors.

## Release Gate (World1)

Run one canonical gate:

```sh
./tools/release_gate_world1.sh
```

Guarantees:
- formatting gate is clean (`dart format --set-exit-if-changed .`)
- analyzer is clean (`dart analyze`)
- World1 readiness smoke contract passes
- Scenario Replayer integration contract passes
- content validation runs when `content/` changed
- l10n generation runs when `l10n.yaml` or `lib/l10n/*.arb` changed

Note: never run Flutter widget/contract tests via `dart test`; always use `flutter test`.

## Demo World1

Run one command:

```sh
./tools/demo_world1.sh
```

Expected duration:
- About 2-4 minutes on a warm local environment.

What it verifies:
- release gate passes first (format/analyze/contracts/content/l10n checks)
- deterministic first-path flow is demo-ready: Act0 -> Spine -> Result
- share artifacts actions are visible in the scripted flow:
  - Copy Skill Card
  - Copy Duel Code
  - Apply Duel Code in Today Plan

Telemetry digest:
- Script prints a `TELEMETRY DIGEST (copy/paste)` block after the feedback packet.
- Includes commit hash, UTC timestamp, and expected campaign telemetry events.
- Uses the routing matrix guard as primary campaign routing coverage:
  `flutter test test/guards/world_campaign_routing_matrix_contract_test.dart`
- Includes telemetry verification command:
  `flutter test test/guards/world1_campaign_telemetry_contract_test.dart`

How to collect feedback:
- Run `./tools/demo_world1.sh` and copy the printed FEEDBACK PACKET block.
- Paste Skill Card and Duel Code into the packet placeholders.
- Fill the 5 one-line questions and send the packet as plain text.

Demo troubleshooting:
- InkSparkle shader pre-clean is already handled by the release gate; re-run `./tools/release_gate_world1.sh` first.
- If a CTA appears offscreen on compact windows, scroll and ensure it is visible before tapping.
- If the scripted path diverges, run `flutter test test/guards/world1_act0_to_spine_transition_contract_test.dart`.
