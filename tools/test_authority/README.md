# Executable Test Authority Lanes v1

These commands implement the post-shim authority split from
`docs/_reviews/post_shim_global_suite_remeasurement_v1.md`.

The frozen post-shim artifact separates observed measurement truth from
executable authority truth. Historical observations remain frozen at 117 Tier
B, 304 Tier C, and 421 unique non-green files. A current executable manifest
may be smaller only when every retired historical path is recorded in the Tier-D
tombstone registry with a PHP-2 disposition in the cumulative PHP-2 review
artifact.

The executable Tier C quarantine set includes the observed 304 plus three
already confirmed residuals that were not reached after the raw suite stopped at
the timeout family:

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
| Tier D retired | `tools/test_authority/manifests/tier_d_retired.txt` | Tombstone registry; excluded from Tier A/B/C |
| All diagnostic lanes | `./tools/test_authority_all_diagnostic_v1.sh` | Runs all lanes; exits nonzero only for validator, Tier A, Tier B, or Tier D blocking signals |
| Manifest validation | `./tools/test_authority_validate_v1.sh` | Blocks on authority drift |

Each lane prints the lane, attempted file/command count, pass/fail/error/timeout
counts, duration, final blocking verdict, and writes a JSON summary under
`build/test_authority/`.

The manifest validator requires every executable Tier B/C entry to exist, no
Tier B/C overlap, every Tier-D tombstone to be deleted and ledger-backed, and
complete frozen-historical-to-current accounting. It also checks the frozen
historical artifact SHA-256; never edit that artifact to satisfy current
manifest validation.

## Timeout

The default per-command/file timeout is `30` seconds. Override it with either:

```bash
TEST_AUTHORITY_TIMEOUT_SECONDS=60 ./tools/test_authority_tier_c_v1.sh
./tools/test_authority_tier_c_v1.sh --timeout-seconds 60
```

Use `--smoke` for a bounded proof run. Tier C smoke always includes
`test/services/booster_pack_launcher_test.dart` when present, so the quarantine
lane proves it can continue after the known unfinished residual.
