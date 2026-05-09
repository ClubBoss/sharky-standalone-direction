# Phase 2 Log Summary Tool

## Purpose
`phase2_summarize_logs.dart` is the SSOT for distilling Value/Aha runs into deterministic metrics. It runs after Phase 2 practice, merges `PHASE2_SESSION_START`, `PHASE2_AHA`, and `PHASE2_FLOW_END` markers, and emits analytics without touching UI behavior.

## Invocation
```bash
dart run tools/phase2_summarize_logs.dart --input /tmp/phase_logs_1.txt
dart run tools/phase2_summarize_logs.dart --input /tmp/phase_logs_1.txt /tmp/phase_logs_2.txt
dart run tools/phase2_summarize_logs.dart --input /tmp/phase_logs_*.txt --fail_on_missing
dart run tools/phase2_summarize_logs.dart --input /tmp/phase_logs.txt --min_runs 3
```

The CLI accepts arbitrary `phaser analyzer` log files, handles the `flutter:` prefix, and aggregates across all `--input` paths. Flags:

- `--fail_on_missing`: exit `2` when any run lacks start/flow-end markers but still prints the summary.
- `--min_runs N`: exit `3` if fewer than `N` runs are counted.

## Output Schema (stable `phase2_summary_v1`)
The CLI emits a single JSON object (one line) with keys written in this order:

1. `schema`: `"phase2_summary_v1"` (immutable).
2. `generated_at_utc`: ISO-8601 UTC instant when the summary was produced.
3. `event`: `PHASE2_LOG_SUMMARY`.
4. `total_runs`: number of unique `run_id`s seen.
5. `aha_signaled_count`: how often `PHASE2_AHA` fired.
6. `aha_rate`: `aha_signaled_count / total_runs` (0 when total is zero).
7. `feedback_view_duration_ms`: object `{min,p50,p90,max,mean}` using nearest-rank percentiles tied to array position; `null` when no durations exist.
8. `missing_start_count`: runs with zero `PHASE2_SESSION_START`.
9. `missing_flow_end_count`: runs missing `PHASE2_FLOW_END`.
10. `missing_runs`: list of `run_id`s lacking either start or flow-end markers.

Percentiles use the nearest index approach (`round(percentile*(n-1))`), so small samples remain deterministic.

## Sample output
```json
{"schema":"phase2_summary_v1","generated_at_utc":"2025-12-31T12:00:00Z","event":"PHASE2_LOG_SUMMARY","total_runs":2,"aha_signaled_count":2,"aha_rate":1.0,"feedback_view_duration_ms":{"min":120,"p50":120,"p90":120,"max":120,"mean":120},"missing_start_count":0,"missing_flow_end_count":1,"missing_runs":["r2"]}
```

## Documentation contract
The README and CLI schema are frozen under the Phase 2 stop rule; any schema change requires updating both spots and the regression guard contract/state before shipping.

## Usage snapshot
- Typical run (multi logs):  
  ```bash
  dart run tools/phase2_summarize_logs.dart --input /tmp/phase_logs_*.txt
  ```
- Strict gating example:  
  ```bash
  dart run tools/phase2_summarize_logs.dart --input /tmp/phase_logs.txt --fail_on_missing --min_runs 2
  ```
- Exit codes:  
  * `0` – summary emitted (default).  
  * `2` – missing markers found while `--fail_on_missing` was active.  
  * `3` – fewer runs than `--min_runs`.  
  All exit paths still emit the single `PHASE2_LOG_SUMMARY` JSON line for downstream automation.
