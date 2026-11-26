# Owner device day — T2

Use one merged, CI-green candidate with the final skin on the iPhone 14 Pro.
Budget ~2–3 hours of prep plus 20–30 min per participant; Apple processing,
access and recruitment waits are extra. Stop at the first failed gate.

**Before signing (~15–30 min):** from the repo root, run the unsigned
[dry run](../../tools/release/ios_release_dryrun_v1.sh), then preflight only
if the build passes:

```sh
tools/release/ios_release_dryrun_v1.sh && python3 tools/release/owner_day_preflight_v1.py
```

[Preflight](../../tools/release/owner_day_preflight_v1.py) checks the linked
files and [B89 profile](../../tools/release/check_release_profile_v1.py) of
that fresh unsigned build. **PASS:** READY. **FAIL:** dry run fails or NOT READY — stop and
send the failing lines to the lead. Run before changing the placeholder ID;
this is not signed-candidate verification.

| Step / estimate | Owner action and stop gate | Send to lead |
| --- | --- | --- |
| 1. Sign · 30–60 min | [Signing checklist](SIGNING_CHECKLIST_v1.md) and [release instructions](../RELEASE.md). Use Personal Team for the local phone or O4-approved TestFlight; verify the intended signed release candidate. **PASS:** correct identity, build and signing. **FAIL:** missing access, signing or candidate checks. | Commit, bundle ID, version/build, signing/check status (no credentials). |
| 2. Install · 10–15 min | [iPhone install instructions](../RELEASE.md). Install the same signed English build on a test-only device/install; do not erase personal progress. **PASS:** app launches and test progress is isolated. **FAIL:** install/launch or isolation failure. | Build, device/iOS, install and launch result. |
| 3. V9 · 30 min on phone | [V9 checklist](V9_CHECKLIST_v1.md); first rerun the [walkthrough](../../tools/capture_act0_screens_v1.sh) with `v9 walkthrough` and resolve FAIL rows. **PASS:** walkthrough and all physical checks pass. **FAIL:** any unresolved row/check. | Walkthrough result, device checklist, issue and screen if failed. |
| 4. GRO · ~20 min | [GRO phone checklist](GRO_PHONE_CHECKLIST_v1.md) and [entry inventory](GRO_ENTRIES_v1.md) (B113 / PR #884; must be merged). **PASS:** all required phone checks pass per checklist. **FAIL:** missing checklist, failed or unverified required check. | Per-check result and reproduction for failures. |
| 5. Start quiet test · 15 min setup + 20–30 min/person | Only once owner opens human testing. Follow [owner run](quiet_test/OWNER_RUN_v1.md), [tester guide](quiet_test/TESTER_GUIDE_v1.md), [feedback](quiet_test/FEEDBACK_QUESTIONS_v1.md), [F1M contract](quiet_test/F1M_EVENTS_v1.md) and [report tool](../../tools/f1m_report_v1.py). **PASS (start):** 3–5 recruited, clean test progress and consent process ready. **FAIL:** admission/setup missing — do not start; after sessions, material blockers or missing evidence keep O2/F1M open. | Start status; then coded results, F1M k/n, W1 completions and blockers. Keep raw evidence private. |

Send one ordered PASS/FAIL summary with the candidate identity and first stop
reason (later steps not run). Prep alone does not close V9, GRO, O2, F1M or release.
