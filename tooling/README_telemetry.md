# Telemetry (local)

## Schema
- Source schema: `build/ui_assets/telemetry_schema.json` (exported with UI assets).

## Events
- Types: `view` (module selection, tab switch), `hint` (See also click).
- Required fields: `ts_iso`, `module`, `stage`, `client_id`, `locale`, `app_ver`.
- Optional fields allowed by schema are ignored if missing.
- Emission is local-only; no network requests.

## Validate
- Run: `make ui-telemetry-validate IN=path/to/events.jsonl`
- Behavior: prints summary `TLMT-VALID total=<N> ok=<K> fail=<M>` and emits one line per failure (`line=<i> err=<code> msg=<short>`). Exits non-zero on errors.

## Snapshots
- If present, `build/ui_telemetry.jsonl` is copied into `ci/snapshots/ui_telemetry.jsonl` by `make snapshots`.
