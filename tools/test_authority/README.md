# Executable Test Authority Lanes v1

These commands implement the post-shim authority split from
`docs/_reviews/post_shim_global_suite_remeasurement_v1.md`.

The frozen post-shim artifact separates observed measurement truth from
executable authority truth. The accepted raw suite observed `304` Tier C
non-green files, but the executable Tier C quarantine set is `307`: the observed
`304` plus three already confirmed Tier C residuals that were not reached after
the raw suite stopped at the timeout family:

- `test/services/skill_gap_booster_service_test.dart`
- `test/widgets/export_csv_button_test.dart`
- `test/widgets/review_path_card_test.dart`

Tier C remains non-blocking. Do not report the executable `307` count as an
observed non-green measurement count.

## Commands

| Lane | Command | Exit policy |
| --- | --- | --- |
| Tier A active/release | `./tools/test_authority_tier_a_v1.sh` | Blocks on failure or timeout |
| Tier B maintained support | `./tools/test_authority_tier_b_v1.sh` | Blocks only when explicitly run |
| Tier C quarantine | `./tools/test_authority_tier_c_v1.sh` | Reports failures/timeouts and exits non-blocking |
| Tier D retired | `./tools/test_authority_tier_d_v1.sh` | Excluded by default |
| All diagnostic lanes | `./tools/test_authority_all_diagnostic_v1.sh` | Runs all lanes; exits nonzero only for validator, Tier A, Tier B, or Tier D blocking signals |
| Manifest validation | `./tools/test_authority_validate_v1.sh` | Blocks on authority drift |

Each lane prints the lane, attempted file/command count, pass/fail/error/timeout
counts, duration, final blocking verdict, and writes a JSON summary under
`build/test_authority/`.

## Timeout

The default per-command/file timeout is `30` seconds. Override it with either:

```bash
TEST_AUTHORITY_TIMEOUT_SECONDS=60 ./tools/test_authority_tier_c_v1.sh
./tools/test_authority_tier_c_v1.sh --timeout-seconds 60
```

Use `--smoke` for a bounded proof run. Tier C smoke always includes
`test/services/booster_pack_launcher_test.dart` when present, so the quarantine
lane proves it can continue after the known unfinished residual.
