# Executable Test Lanes

Tier A runs the active product/release commands in `run_lane_v1.py`.
Tier B runs the files in `manifests/tier_b_maintained_support.txt`.
Both lanes block on failures, timeouts, missing commands and incomplete runs.

PR CI splits Tier A across three jobs and Tier B across two jobs. The daily
scheduled job runs maintained Tier B. A0b retired the legacy Tier C quarantine
and Tier D tombstones; their old measurement reports remain historical records.

| Check | Command |
|---|---|
| Manifest integrity | `./tools/test_authority_validate_v1.sh` |
| Tier A | `./tools/test_authority_tier_a_v1.sh` |
| Tier B | `./tools/test_authority_tier_b_v1.sh` |
| Both active lanes | `./tools/test_authority_canonical_lane_v1.sh` |
| Compatibility command for both lanes | `./tools/test_authority_all_diagnostic_v1.sh` |

Promote a useful passing regression by adding its path to Tier B. Validation
requires valid existing test paths, no duplicates or A/B overlap, and continued
coverage of the pre-A0b PR contracts. New additions need no second registration
list. Validator fixtures cover missing files, path escapes, duplicates, overlap
and lost required contracts.

Each lane prints a result and writes its summary to `build/test_authority/`.
The default per-command/file timeout is 120 seconds; override it with
`TEST_AUTHORITY_TIMEOUT_SECONDS` or `--timeout-seconds`. `--smoke` is a limited
diagnostic, not proof that the complete lane passed.

Tier B summary durations are batch averages, not measured file durations. For
optional local profiling, preserve the Dart test JSON event stream and inspect
its observed per-file windows without changing the blocking lane:

```sh
flutter test --no-pub --reporter json test/path_a_test.dart test/path_b_test.dart > /tmp/test-events.jsonl
python3 tools/test_authority/json_file_timings_v1.py /tmp/test-events.jsonl
```

The diagnostic includes load/scheduling time, marks incomplete data, and calls
out concurrent file windows. Overlapping windows must not be summed as batch
wall time. The tool accepts Dart test JSON protocol 0.1.1; a different protocol
fails closed until its semantics are reviewed.

The opt-in unpartitioned full suite remains available through the existing
checkpoint policy, separately from a successful active A/B result.
