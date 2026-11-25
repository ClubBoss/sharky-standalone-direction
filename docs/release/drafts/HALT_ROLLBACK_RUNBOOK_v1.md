# Halt and rollback runbook — owner approval draft

Current decision: HOLD. This draft does not replace
[release decision truth](../go_hold_rollback_truth_v1.md) or
[rollback ownership truth](../rollback_ownership_truth_v1.md). No live
rollback or remote control has been tested.

## Roles and release record

- Release owner: [[OWNER: name and App Store Connect access]]. Approves GO,
  halt, availability changes, recovery base and restart. All Apple-account
  operations below are owner-only, including when delegated to the named
  authorized backup operator [[OWNER: name and role]].
- Engineering lead: [[OWNER: named engineer]]. Reproduces, assesses impact,
  selects compatible fix, builds candidate and runs affected checks. Does
  not perform owner-only Apple actions.
- Support lead: [[OWNER: named contact]]. Receives reports and communicates
  verified mitigation; does not ask users to erase progress.
- Before release, record [[OWNER: signed RC source commit, Bundle ID, Team
  ID, version/build, archive location, App Store Connect record, flag values,
  available regions, known-good compatible commit/build and operator]] in
  the [release owner decision template](../release_owner_decision_template_v1.md).

## Triggers and initial response

Halt for confirmed or credible critical launch failures, progress corruption
or loss, wrong poker grading or legal actions, unexpected data transmission
or privacy mismatch, serious rights/safety issues, or a failed mandatory
release condition. Any team member reports the issue immediately.

1. Engineering captures time, version/build, affected scenario, severity,
   reproduction and whether learner data is at risk. Use the minimum
   diagnostic information; no raw histories in public incident notes.
2. Owner records HOLD and tells engineering/support which build and audience
   are affected. Freeze rollout and do not approve further distribution.
3. Support acknowledges the issue, gives only verified workarounds and tells
   learners to keep the app installed if progress could be affected.

## Apple distribution halt (owner-only)

| Situation | Action | Verify |
|---|---|---|
| Before first public release | Keep manual release on hold. In App Store Connect, do not release the approved version. If still in review and eligible, remove the submission from review; if cancellation of a pending release is offered, cancel it. | Confirm status and no new distribution; select a corrected build with a new build number. |
| Phased update | In Apps, select the app and its distributed version; under Phased Release for Automatic Updates choose Pause Phased Release and save. | Confirm paused status. The pause budget is 30 days total; manual downloads remain possible. This is for updates, not the initial 1.0 launch. |
| Bad TestFlight build | Apps → app → TestFlight → Builds → platform → affected build → Expire Build. Stop assigning it to groups. | Verify the build is expired and no longer installable through TestFlight. Notify testers already on it; do not treat expiration as remote uninstall. |
| Serious public defect | In app availability settings remove affected countries/regions, or remove the app from sale if necessary. Record prior regions and the action time. | Confirm availability in console and storefront after propagation. Existing installs remain; this is not a recall or downgrade. Never delete the app record. |

Apple instructions: [withdraw a submission](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/remove-a-submission-from-review/),
[pause phased release](https://developer.apple.com/help/app-store-connect/update-your-app/release-a-version-update-in-phases/),
[expire TestFlight build](https://developer.apple.com/help/app-store-connect/test-a-beta-version/stop-testing-a-build/),
[manage availability](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/manage-availability-for-your-app-on-the-app-store).

## Remote-off status and beta flags

There is no remote flag service on the active route at `origin/main`
a85177b9c2e79ede5d879e74f6db17e4c449c0a7. Do not claim a server-side toggle
or remotely disable installed copies. The remote-off portion is **not
available**; stop distribution as above, then replace the build with flags
off. Engineering checks the actual recorded defines, removes any enabled
optional flag or sets it false, and verifies the new artifact.

| Existing switch | Replacement-build action/source |
|---|---|
| `SHARKY_BETA_METRICS` | Omit or set false (default off); `lib/ui_v2/act0_shell/act0_beta_metrics_v1.dart`. No automatic upload; existing local records are not erased by toggling. |
| `HNP_TELEMETRY` | Omit or set false; `lib/ui_v2/app_root.dart`, `act0_telemetry_sink_v1.dart` (non-release only). |
| `numberEntryV1`, `goalRouteV1`, `warmupV1`, `returnRefreshV1`, `liveRoomV1` | Omit or set false to turn experimental paths off; `act0_shell_preview_screen_v1.dart`, `act0_shell_state_v1.dart`. |
| Debug pilots `SHARKY_W13_PLUS_PILOT`, `actionReasonV1`, `SHARKY_LEAK_DASHBOARD_V1`, `tableNineSeatV1`, `SHARKY_STREET_SUMMARY_PREVIEW` | Keep off; debug/non-release gated in their Act0 source. Do not enable audit/capture flags in release. |

These are compile-time Dart defines, not a remotely applied action. Default
release settings and support address must be checked before signing.
[[OWNER: if remote-off is required as a release condition, decide whether
a separately approved mechanism is necessary; until then use distribution halt]].

## Recover with a forward update

1. Engineering selects the smallest fix or compatible known-good source
   from the release record. Check persisted schema and any newer data written
   by the broken build; never overwrite with incompatible old readers.
2. Build a replacement using the same permanent Bundle ID and a valid next
   version/build number, flags as above, following `docs/RELEASE.md`.
   Owner-only: sign/upload and choose the new build in App Store Connect.
   If urgent, request expedited review with clear reproduction.
3. Engineering runs affected CI, the candidate guard and an upgrade test on
   a physical iPhone: install/update **over** the affected build without
   uninstalling. Verify startup, existing XP, completed lessons, attempt
   history, resume position, practice/review, original failing case and
   deletion/privacy behavior if affected. Check clean-install too. Record
   results against the actual candidate.
4. Owner reviews these results and records a fresh GO or continued HOLD.
   Owner-only: restore the intended countries after approval, release the
   corrected build and verify availability. If removal ended a phased
   rollout, do not assume it can resume; use a new eligible phased update.
5. Support communicates the corrected version and safe upgrade path.
   Owner/backup and engineering monitor support and available Apple reports
   on release day and the following day; repeat halt if the trigger recurs.

App Store does not permit an in-place downgrade to an old distributed
version. Restoration for existing users requires a tested forward update.
No Apple-account operation or signed-device rollback rehearsal has occurred
as part of this draft.
