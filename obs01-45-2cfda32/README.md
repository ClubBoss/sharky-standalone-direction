# OBS-01 affected set 45/45 — evidence package

Evidence only. Not product code, not a merge candidate, not an acceptance verdict or score.

| Field | Value |
|---|---|
| Source commit (main) | `2cfda326acfcd6d70661de1ceb3ff829ff6fa677` |
| Source TREE | `eed99b6b88c758dd16dcecbab556e7c9213d910a` |
| Tracked changes at run | 0 before and after |
| Inspector | `tools/act0_obs03_trace_inspector_v1.dart` blob `097c0214e762f48e15191eedcaad4581743ff941`, sha256 `a593a94ba6ca559b9c974582b4b84a08863ccb67d786e01a1a86622d8a584b11` |
| Toolchain | Flutter 3.35.0 stable, Dart 3.9.0, linux_x64 (cloud container) |
| Command | `flutter test --no-pub test/ui_v2/act0_obs01_incident_fields_v1_test.dart test/ui_v2/act0_obs01_pending_capture_v1_test.dart test/ui_v2/act0_obs03_privacy_lineage_v1_test.dart test/ui_v2/act0_obs03_source_lineage_v1_test.dart -r expanded` |
| Started / finished (UTC) | 2026-11-07T19:11:02Z / 2026-11-07T19:11:29Z |
| Exit code | `0` |
| Result line | `+45: All tests passed!` (45 distinct tests) |

Files: `raw.log` (stdout+stderr), `COMMAND.txt`, `SOURCE_IDENTITY.txt` (commit, TREE, blob + sha256 of the inspector and the 4 test files), `SHA256SUMS` (published files), `SHA256SUMS.original` (pre-sanitization), `SANITIZE.md` (reversible rule and verification).

Scope limits: MACHINE run of the 4 OBS-01/OBS-03 test files on the merged inspector. It does not re-run the historical 182-event native trace and is not a new native build.
