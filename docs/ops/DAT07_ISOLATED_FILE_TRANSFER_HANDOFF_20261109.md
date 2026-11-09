# DAT-07 isolated file transfer — integration handoff (2026-11-09)

**Status:** SOURCE CANDIDATE ONLY / NOT IN ACTIVE APP / NOT TESTED / NOT ACCEPTED.

**Repository:** ClubBoss/sharky-standalone-direction
**Base:** main `2b547f031d5aef8ca0a8772e750f6d4ea53e82cb`
**Branch:** `feature/dat07-isolated-file-backup-20261109`
**DoD:** `ТРИ_ВОЛНЫ!A329:K329`, DAT-07, W03, 0.94, **НЕ ПРИНЯТО**.
Do not merge or award score for this handoff.

## Source-only candidate

- `lib/ui_v2/act0_shell/act0_dat07_transfer_v1.dart`: V1 JSON envelope; explicit format revision; exact progress schema; SHA-256 and payload-byte-length integrity; UTC export time validation; incomplete-file/schema rejection; source payload validator injection; revision+payload fenced preview; compare-and-swap store port; no XP merge or re-grading.
- `lib/ui_v2/act0_shell/act0_dat07_file_screen_v1.dart`: native Files JSON picker, temporary share file, user-facing format/data version, timestamp and integrity preview, explicit Confirm/Cancel and clear conflict/incompatible/corruption errors; required awaited onRestored callback.
- `test/ui_v2/act0_dat07_transfer_v1_test.dart`: pure controller/codec cases; mock transactional port.
- `test/ui_v2/act0_dat07_file_screen_v1_test.dart`: UI interaction cases with injected fake file selection.
- **No existing runtime/storage/settings, Runner, tasks, fingerprints, Table Truth, CI/workflows, scorecard or dependency lock edited.**

Current code assumes exact **progress schema 19** for new exports. The accepted runtime validator must be supplied by the actual shell integration owner. Legacy 18, future 20 and incompatible envelopes fail closed: migration is not inferred or silently applied.

## Critical ownership / safety seam

`Act0ProgressStoreV1` in `lib/ui_v2/act0_shell/act0_progress_store_v1.dart` owns serialized dual-checkpoint durable writes. The new port contract MUST NOT be implemented as `await store.load(); await store.save(payload)`: that is not atomic and can overwrite an intervening decision. Before integration, get exclusive ownership of BOTH the storage file and shell/Settings callbacks.

Minimal bounded storage-owner change required:

1. Add a single atomic `restoreIfUnchanged` entry point INSIDE `Act0ProgressStoreV1` using its existing private `_serial`, `_resolve`, `_commit`, write lease and recovery-intent guard. No new storage engine or preference keys. Add a canonical read method returning `Act0Dat07DurableStateV1 = ({int revision, String? payload})` from `_resolve` (not a second resolver).
2. Under the SAME serialized queue and after fresh preference reload, compare both `current.revision == expected.revision` and `current.payload == expected.payload`. Compare revision even when both payloads are null, to reject empty -> reset -> empty or A -> B -> A. In this first version, refuse if canonical current payload is non-null and different from incoming bytes; do not merge or overwrite. Explicit recovery tombstones must not be bypassed.
3. Validate incoming bytes with the exact current shell source validator and supported schema before queuing the durable write. On a valid empty current state, reserve the revision and use existing `_commit` checkpoint protocol, not direct `setString`. Fence old shell writer instances before accepting the imported state, and recreate the store on shell remount.
4. Map `_commit` to `committed` ONLY if the store's own durable readback succeeds with `revision > expected.revision` and the exact imported payload. A false/throw is **indeterminate**, not evidence of rollback. Return `unverified` and require normal startup recovery/read; failed or interrupted head writes may have been applied.
5. Bind `Act0Dat07TransferV1(port: ownedAdapter, codec: acceptedValidator)` to a reachable EN iPhone 14 Pro Settings → Backup/Restore route. Use `Act0Dat07NativeFileBridgeV1` for native Files input and share sheet. The **required `Future<void> Function() onRestored`** must complete the Act0 state disposal/remount and fence pending old writers BEFORE it completes. A fire-and-forget callback is not sufficient.
6. Verify a first-launch app does NOT persist a nonempty default snapshot before the user can restore. If it does, require a source-owned, non-destructive fresh-state classification plus atomic CAS; **never** define "empty" merely as XP=0 or app-open count. An existing meaningful local state remains a hard conflict until an independently accepted non-destructive policy exists.

**Important:** The new pure/controller port is a contractual seam and the widget is an isolated callable screen. It is not already wired to Settings and the current canonical store does not yet implement this revision-aware CAS method. Therefore **DAT-07 full DoD remains HOLD**. Do not claim that the app can restore files before these six points are implemented and tested. Source progress snapshot bytes are carried exactly; local checkpoint revision belongs to the destination and is intentionally NOT copied from the backup.

## Acceptance probes (test data only; no real learner data)

1. Export an authentic synthetic saved schema-19 snapshot from device A, choose via Files on a fresh install B, inspect source task/choice/attempt IDs, choice correctness/error, assistance, run/session, repair history and original XP; confirm; kill/relaunch; compare canonical serialized data and visible Home/Review/You.
2. Import the exact same file twice; second time `alreadyPresent`, zero new XP, no duplicate attempt or once-only award.
3. Present a different backup over nonempty local state; `conflict`, no mutation; changing current state after preview also rejects at atomic commit. Resetting an empty state between preview and confirm must also reject by revision, even if payload remains null.
4. Unknown format revision and future/legacy progress schema refuse with plain English.
5. Truncated file, modified checksum, valid checksum but missing required payload fields, huge file, malformed UTF-8: fail closed without changing current progress.
6. Inject interruption at each canonical checkpoint write, not just after acknowledgement. Restart through the existing resolver and show either verified current or verified restored state; never silently show a mixed/partial state. **Do not repeat the prior blocked offline-recovery campaign or run it in a new environment without permission.** Arrange a newly admitted bounded in-situ test later.
7. Cancel OS file selection, cancel preview, cancel native share sheet; show no claim of saved backup and never restore.
8. Independent non-author source review, then exact-HEAD allowed static/targeted tests and actual supported EN iPhone 14 Pro native file path/reinstall evidence; score decision only after owner-admitted gate.

## Focused commands — NOT RUN in this handoff

```sh
dart format --output=none --set-exit-if-changed lib/ui_v2/act0_shell/act0_dat07_transfer_v1.dart lib/ui_v2/act0_shell/act0_dat07_file_screen_v1.dart test/ui_v2/act0_dat07_transfer_v1_test.dart test/ui_v2/act0_dat07_file_screen_v1_test.dart
flutter analyze lib/ui_v2/act0_shell/act0_dat07_transfer_v1.dart lib/ui_v2/act0_shell/act0_dat07_file_screen_v1.dart test/ui_v2/act0_dat07_transfer_v1_test.dart test/ui_v2/act0_dat07_file_screen_v1_test.dart
flutter test test/ui_v2/act0_dat07_transfer_v1_test.dart test/ui_v2/act0_dat07_file_screen_v1_test.dart
```

The local Mac connector was confirmed OFFLINE during continuation. No SDK installation, Flutter preparation, offline-recovery rerun, protected workflow changes, CI gate, or native simulator claim was authorized or performed here. The new isolated source defines 12 controller and 6 widget test cases; **18 authored, 0 executed**. No PASS is inferred. Newly authored tests are unexecuted hypotheses until an authorized runner executes them. One blocked previous campaign may not be repackaged as a new pass.

## Rollback

Reject or delete the isolated branch. No main, app user data, preferences keys or scorecard have changed. Future integration must remain a separate bounded, lease-held patch with its own exact HEAD and review.
