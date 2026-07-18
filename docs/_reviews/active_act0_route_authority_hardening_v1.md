# Active Act0 Route Authority Hardening v1

Status: PUBLISHED FOR ADMISSION — draft PR #27; CI baseline repair is tracked
separately in draft PR #28.

## Scope and baseline

- Repository: `/Users/elmarsalimzade/Sharky_1.0`
- Immutable audit tag object: `act0-final-deterministic-candidate-v1` ->
  `c73a2371a9351d10f085bbb8fd70298cb6d6913e`, dereferencing to candidate
  commit `5b95cee0493cbb2057f471bad48fa2a73677a3ae`
- Preflight: `HEAD` and `origin/main` were both that SHA; the tag was not moved.
- Working branch: `codex/act0-route-authority-hardening-v1` in an isolated
  worktree. Pre-existing untracked evidence remains only in the canonical
  checkout and was not touched.

The tag remains an immutable historical audit baseline. This release-boundary
fix is a later candidate change and must not be represented as part of that
tag.

## Production entry proof

| Step | Live owner and proof |
| --- | --- |
| Process entry | `lib/main.dart:main` calls `runApp(AppRoot())`. |
| App root | `lib/ui_v2/app_root.dart:_AppRootState.build` creates `MaterialApp(home: _EntryGate(...))`. |
| Entry gate | `_EntryGateState._bootstrapEntrySurface` reads `OnboardingPreferencesService.hasCompletedOnboarding`; placement is shown only while onboarding is incomplete. `_EntryGateState.build` always returns `Act0ShellPreviewScreenV1`. |
| Learner shell | `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart` owns the placement, Home, Learn, runner, Review, Play, and Profile branches. `Act0LessonRunnerShellV1` is its lesson/decision renderer. |
| Legacy named routes | `buildLegacySurfaceRedirectRoute` blocks every name in `_legacySurfaceRoutes` and returns `buildCanonicalPathRootV1()`, which itself returns `Act0ShellPreviewScreenV1`; no listed route returns a campaign or Map screen. |

Release and capture behavior is equally explicit:

- In `_bootstrapEntrySurface`, `kReleaseMode` makes `_debugHarnessEntry` null;
  controlled demo and native capture parsing is therefore debug/test only.
- `DEEPLINK_TARGET` is parsed but `_maybeHandleDeepLink` logs and ignores every
  target during the campaign-surface lock. It cannot route a production learner
  to campaign/Map/Today Plan.
- `_EntryGateState.build` injects `act0CanonicalTelemetrySinkV1` with the
  `HNP_TELEMETRY` setting and `isReleaseMode: kReleaseMode`; the active shell,
  not a campaign screen, owns the entry telemetry seam.

## Route-family classification

| Family | Classification | Consumer proof and disposition |
| --- | --- | --- |
| `AppRoot -> _EntryGate -> Act0ShellPreviewScreenV1 -> lib/ui_v2/act0_shell/*` | ACTIVE_ACT0_PRODUCTION_ROUTE | The sole `main()` entry and `_EntryGate.build` route. |
| `buildCanonicalPathRootV1` legacy-name redirect | ACTIVE_ACT0_PRODUCTION_ROUTE | Compatibility route names land back on `Act0ShellPreviewScreenV1`, not a second product surface. |
| Controlled demo/native capture query entry and `debugHarnessEntry` | DEBUG_OR_CAPTURE_ONLY | Parsed only when `!kReleaseMode`; widget tests pass entries directly. |
| `UniversalIntakePlanScreen` and Today Plan CTAs | LIVE_NON_ACT0_COMPATIBILITY_ROUTE | `SessionResultScreen` can push it, and legacy runner/session-result families consume that continuation; it is not imported by the production entry chain. |
| `UiV2ProgressMapScreenV2` | HISTORICAL_OR_ARCHIVED | No live source file remains under `lib/`; current references are stale guard/history text and archived material. |
| `UiV2BetaShell` | DORMANT_FUTURE_CAPABILITY | It has no production consumer; its own Path tab points to the canonical Act0 root. |
| `campaign_pack_registry_v1`, `canonical_truth_map_v1`, campaign `ProgressService` routing | LIVE_NON_ACT0_COMPATIBILITY_ROUTE | Archive/legacy runner, module launcher, session-result, and campaign-spine services retain real imports and tests. They are not reachable from `AppRoot`. |
| `world_campaign_*` keys and old Map contract families | TEST_ONLY | Remaining current occurrences are guards/fixtures or stale compatibility evidence; no active Map source consumer exists. |
| Campaign deep-link target | HISTORICAL_OR_ARCHIVED | The only production handler is the explicit ignore path in `_EntryGateState._maybeHandleDeepLink`. |
| W7-W12 hidden runtime-session owners | DORMANT_FUTURE_CAPABILITY | `Act0ShellStateV1` uses their specs to construct locked W7+ preview lessons. They are not an unlocked entry, placement bypass, persistence owner, or telemetry sink. |
| W7-W12 hidden evidence harnesses | INTERNAL_EVIDENCE_ONLY | Each holds its corresponding owner and exposes `practiceLaunchRequest => null`; consumers are internal harness/guard tests. |
| Historical review packets and old campaign/map assertions | HISTORICAL_OR_ARCHIVED | Evidence may describe a former surface but cannot establish a current learner entry over live source. |

No `UNRESOLVED_LIVE_CONSUMER` remains. The inventory found one real non-Act0
compatibility continuation (legacy runner -> session result -> Today Plan), but
no alternate production entry from `main.dart` or `AppRoot`.

## Release dev-menu verdict

**Fixed.** Before this mission, the Home header received `_openDevMenu`
unconditionally. The reachable sheet contained Reset app progress, Open
placement, Open Today, Open Learn map (skips placement), Play, Review, and
direct runner actions. That was a real release-mode bypass because neither the
header nor the owner had a release gate.

`act0DevMenuEnabledV1(isReleaseMode: kReleaseMode)` now gates the only Home
`onOpenDevMenu` owner. In release it passes null, so the overflow control and
all of its actions are absent. In debug/test it remains enabled. The independent
capture entry remains separately release-gated in `_EntryGateState`.

## Hidden owners and placement score

W7-W12 owner specs are source inputs for locked preview lessons, not duplicate
visible learner lessons. They provide no canonical persistence or telemetry;
the active shell's persisted state and injected `Act0TelemetrySinkV1` remain
the canonical owners. The evidence harnesses are deliberately non-launchable.
No hidden content was wired into Act0.

`profileScore` in `_buildPlacementResult` folded the placement-question bank
and was never read. Its only helper, `_placementQuestionScore`, had no other
consumer. Both were removed as trivially safe dead implementation residue;
placement outcome selection still depends only on the existing diagnostic hit,
miss, foundation, and advanced signal calculations.

## Reconciliation and supersession map

| Lower-authority material | Current disposition |
| --- | --- |
| Stale `_EntryGateState` campaign/Map entry matrix | Removed. It described unavailable Map files and implied a parallel production matrix. |
| `test/guards/app_boot_release_smoke_test.dart` legacy Map/Today Plan expectation | Rewritten as the focused `AppRoot` canonical-Act0 entry regression. |
| `CANDIDATE_FREEZE_MANIFEST_V1.md`, `CANONICAL_ACT0_CLOSURE_PACKET_v1.md`, and `FINAL_DETERMINISTIC_CONVERGENCE_PACKET_V1.md` | Remain baseline/evidence records. Their canonical-route statement is compatible, but this artifact owns the fresh consumer and release-menu classification. |
| `VOLUME_I_WORLD_READINESS_LEDGER_v1.md`, `VOLUME_I_WORLD_CALIBRATION_2026_05_06_v1.md`, `world_7_12_route_truth_audit_v1.md`, and W10-W12 admission/closure packets | Historical/content-route evidence only. They do not establish a production entry or authorize W7-W12 visibility. |
| `ACTIVE_APP_BOUNDARY_AND_DORMANT_SYSTEMS_v1.md` | Updated with the sole navigation pointer to this hardening record. |

## Product-code changes

- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`: add the single
  release dev-menu owner gate; remove the unconsumed placement score/helper.
- `lib/ui_v2/app_root.dart`: replace a stale campaign/Map entry comment with
  the live authority pointer; no routing behavior changed.
- `test/guards/app_boot_release_smoke_test.dart`: assert the real AppRoot entry.
- `test/ui_v2/act0_release_dev_menu_boundary_v1_test.dart`: cover release vs
  debug/test dev-menu admission.

## Validation and end state

Passed:

- focused release-dev-menu policy, AppRoot entry, and active-route guard tests;
- `test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart` (including both
  placement completion paths);
- `./tools/fast_loop_world1_v1.sh --force` (tool lint, analyzer, and selected
  Act0 route/copy guards);
- `flutter analyze`;
- `graphify hook-check`;
- `git diff --check` and `git diff --cached --check`.

No Computer Use, visual suite, content expansion, or campaign rewiring was
run or authorized.

## CI admission reconciliation

- Draft PR #27 is `https://github.com/ClubBoss/sharky-standalone-direction/pull/27`
  at head `1b5d4895fc1d8c50a09f28ec7393b675b42ec43d`, based on
  `5b95cee0493cbb2057f471bad48fa2a73677a3ae`.
- Clean worktrees reproduced the same R5 World 3 validator failure on both
  base and head: `w3.s10` has an admitted four-drill checkpoint while the
  stale guard allowed at most three, and its three existing transfer intents
  were absent from the validator allowlist. This is baseline CI debt, not a
  PR #27 regression.
- Tier A also used a universal 30-second command timeout, which timed out
  analysis and nested gates in GitHub Actions. The focused repair-intent test
  was the only deterministic functional failure and is caused by the same
  stale intent allowlist.
- `TestSprite Pre-Check` reported the external status `No tests detected` with
  no target URL. It has no PR #27 code-level failure log.
- The independent remediation is draft PR #28:
  `https://github.com/ClubBoss/sharky-standalone-direction/pull/28`, head
  `288390d6`. It changes only the validator cap, World 3 intent allowlist, and
  Tier A timeout. Its CI result remains the admission authority.

Repository end state: this isolated branch was committed and pushed as
`1b5d4895fc1d8c50a09f28ec7393b675b42ec43d` for draft PR #27. It contains only
this artifact, the active-boundary pointer, the AppRoot comment/test
reconciliation, and the two bounded shell changes/tests. PR #27 is not merged,
no green CI claim is made here, and neither the immutable baseline tag nor the
canonical-checkout untracked evidence was modified.

Recommended next product layer: first publish a new immutable candidate for
this release-behavior change, then follow the current Master Plan's admitted
post-baseline gate. Do not reopen campaign/Map, W7-W12 visibility, or hidden
owner wiring without a separate live-consumer admission.
