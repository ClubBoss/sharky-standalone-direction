---
status: "REVIEW ARTIFACT"
status_source: "derived"
baseline: "4a0fdf847259"
generated_by: "docs_frontmatter_v1"
---

# W1 Showdown Canonical Route Admission Gate v1

Status: REVIEW ARTIFACT.
Task: Sharky Poker - W1 Showdown Wave, Canonical Route Ownership and Admission Gate v1.
Source branch: `claude/w1-showdown-hand-ranking-source-closure-v1`.
Source base: `4a0fdf8472594c4a7235abc414aeaa4820de9066`.
Source HEAD: `8bec6cea58d95c3aa81ddd497d178180285b039d`.
Local review base: `4a0fdf8472594c4a7235abc414aeaa4820de9066`.

## Verdict

Final verdict: `w1_showdown_finding_misscoped`.

Finding-validity decision: `FINDING_MISSCOPED_NO_CANONICAL_ASSESSMENT`.

W1 score-impact decision: `NO_CANONICAL_SCORE_CHANGE`.

Integration disposition: `CORRECT_ARTIFACT_BEFORE_INTEGRATION`.

## Scope Guard

This review does not re-evaluate the quality of the new `w1.s11` content. It
only evaluates canonical route ownership, learner reachability, progression
ownership, and whether the source artifact can claim canonical closure of
`W1W6-DLR-001`.

Inspected evidence stayed inside:

- AppRoot and Act0 shell entry.
- Home/Learn CTA routing.
- W1 campaign routing and completion.
- ModuleLauncher Session Drills exposure.
- DrillRuntimeAdapter launch and completion.
- progression persistence.
- canonical World truth map.
- Wave A diff and review artifact.

## A. Canonical Learner Entry

Normal app launch enters `AppRoot`, whose `MaterialApp` home is `_EntryGate`.
Legacy surface routes such as `/modules` are redirected to
`buildCanonicalPathRootV1()` when `_allowLegacySurfaces` is false. `_EntryGate`
then returns `Act0ShellPreviewScreenV1` after onboarding/placement bootstrap,
with debug harness entry disabled in release mode.

Evidence:

- `lib/ui_v2/app_root.dart:202-210` blocks legacy surface routes.
- `lib/ui_v2/app_root.dart:299-302` sets `_EntryGate` as app home.
- `lib/ui_v2/app_root.dart:585-622` builds `Act0ShellPreviewScreenV1`.
- `docs/plan/ACTIVE_APP_BOUNDARY_AND_DORMANT_SYSTEMS_v1.md` defines the active
  launch path as `Placement -> Home -> Learn -> Table -> Result -> Home`.

Home and Learn do not open `ModuleLauncherScreen` or the JSON session list.
Home's primary CTA calls `_startHomeNextAction`, which resolves an Act0
recommendation and starts an Act0 task. Learn receives `selectedWorld.lessons`,
`completedTaskIds`, `pathClosedTaskIds`, and `onStartTask`, and starts the
selected Act0 task through `_startTaskByIds`.

Evidence:

- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart:3961-4104` wires Home,
  including Learn context and `onContinue`.
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart:4105-4165` wires Learn
  from Act0 world/lesson state.
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart:6390-6405` starts
  Home's next action.
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart:8187-8233` starts an
  Act0 task and persists Act0 progress state.

Flow classifications:

| Flow | Classification | Reason |
| --- | --- | --- |
| Flow A: `kWorld1CanonicalModuleOrder` / campaign packs / `world1_foundations_microtask_runner` | `DEBUG_SUPPORT` | The campaign spine is still registered and can be launched by non-primary/debug-support surfaces, but app launch/Home/Learn do not route the normal learner into it. `UiV2BetaShell` exposes a Drills tab only when `kDebugMode` is true, and that tab opens the next campaign pack through `pushWorld1FoundationsRunnerV1`. |
| Flow B: JSON-backed Session Drills / `ModuleLauncherScreen` / `DrillRuntimeAdapterV1` | `LEGACY_BLOCKED` | `ModuleLauncherScreen` can list session drills, but normal AppRoot legacy `/modules` routing is blocked, and Home/Learn do not navigate to this screen. |

## B. Flow B Reachability

`w1.s11` is not reachable by a normal learner from app launch, Home, Learn,
W1 start/continue CTA, lesson completion, or W1 progression.

Exact normal learner route:

`AppRoot -> _EntryGate -> Act0ShellPreviewScreenV1 -> Home/Learn -> Act0 lesson task -> Act0LessonRunnerShellV1 -> Act0 completion summary -> Home/Learn`.

Flow B route if the legacy launcher screen is opened by non-normal means:

`ModuleLauncherScreen -> Session Drills -> session_drill_player_entry_w1.s11_v1 -> canonicalSessionDrillRouteV1(sessionId: "w1.s11") -> CanonicalLauncherV1.sessionDrill -> CanonicalTerminalRunnerSurfaceV1 -> CanonicalTerminalSessionDrillSurfacedRunnerV1`.

Reachability findings:

| Question | Answer |
| --- | --- |
| Required screen/CTA | `ModuleLauncherScreen` `Session Drills` tile for `w1.s11`. |
| Debug flag involved | The Session Drills section itself is not inside `kDebugMode`, but the active app route does not expose `ModuleLauncherScreen`; `UiV2BetaShell`'s Drills tab is `kDebugMode` only. |
| Visible in release mode | Not in the normal AppRoot/Home/Learn route. If `ModuleLauncherScreen` were forcibly opened, its Session Drills list is not debug-gated, but AppRoot blocks legacy `/modules` routing. |
| Progression unlocks/requires it | No. Act0 progression depends on Act0 completed task ids. Campaign progression depends on campaign pack completion. `w1.s11` is not in either owner set. |
| Can learner skip directly to it | Not through normal learner navigation. If the legacy ModuleLauncher screen is reached, the list is direct-entry and does not enforce prior W1 sessions. |
| Completion persisted into canonical W1 progress | No. Session-drill completion persists `ProgressService.markModuleCompleted("w1.s11")`; canonical Act0 W1 progress persists Act0 `completedTaskIds` / `completedLessonIds`. |

Evidence:

- `lib/ui_v2/screens/module_launcher_screen.dart:904-945` lists session ids from
  `DrillRuntimeAdapterV1` and opens `canonicalSessionDrillRouteV1`.
- `lib/ui_v2/screens/module_launcher_screen.dart:946-955` shows only Developer
  Tools are `kDebugMode`; the Session Drills list itself is above that gate.
- `lib/services/drill_runtime_adapter_v1.dart:20-33` reads
  `world_drills_manifest_v1.json`.
- `lib/services/drill_runtime_adapter_v1.dart:233-257` maps `wN.sNN` ids to
  `content/worlds/worldN/v1/sessions/<sessionId>`.
- `lib/ui_v2/runner/canonical_launcher_api_v1.dart:26-52` defines
  `canonicalSessionDrillRouteV1`.
- `lib/ui_v2/runner/canonical_terminal_runner_surface_v1.dart:44-60` dispatches
  surfaced session drills.
- `lib/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart:498-515`
  loads drills for the given session id.
- `lib/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart:549-585`
  marks a normal completed session drill by `widget.sessionId`.
- `lib/services/progress_service.dart:462-475` stores generic module completion
  as `module_completed<moduleId>`.

## C. Flow A Ownership

Flow A is not the current app launch/Home/Learn owner. It remains campaign
spine infrastructure and debug/support launch infrastructure.

Ownership findings:

| Question | Answer |
| --- | --- |
| Owns W1 completion | No for current Act0 Home/Learn W1. Act0 W1 completion is derived from Act0 world lessons and completed task ids. Campaign completion is separate and derived from completed campaign pack ids. |
| Owns next-session routing | No for Act0 Home/Learn. Act0 routing uses `_firstPlayableLesson`, `_firstIncompleteTask`, `_nextTask`, and `_nextLessonId`. Campaign support routing uses `ProgressService.getNextSpinePackToRunV1`. |
| Owns progress/payoff | No for Act0. Act0 persists `_Act0PersistedProgressV1`. Campaign support progress persists campaign active pack, hand index, and completed pack ids. |
| Used by Home/Learn CTA | No. Home/Learn CTA starts Act0 tasks. |
| Flow B completion affects Flow A | No. Flow B stores generic `module_completedw1.s11`; Flow A campaign completion uses campaign pack ids and `spine_campaign_completed_packs_v1`. |

Evidence:

- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart:6026-6040` defines W1 as
  `Poker from Zero` with `_pokerFromZeroLessons`.
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart:1971-2099` defines the Act0
  `hand_rankings_table` lesson and its task list.
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart:2100-2148` defines the Act0
  `showdown_winning` lesson and its task list.
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart:10115-10208` derives
  world and lesson state from Act0 completed task ids.
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart:10211-10228` records
  completed Act0 tasks and lessons.
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart:3157-3219` persists
  Act0 progress to `_Act0PersistedProgressV1`.
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart:10404-10443`
  advances to the next Act0 task, lesson, or world.
- `lib/canonical/world1_canonical_module_order_v1.dart:1-9` lists W1 campaign
  packs, not `w1.s11`.
- `lib/services/progress_service.dart:2736-2758` marks completed campaign packs.
- `lib/services/progress_service.dart:2797-2808` decides campaign world done by
  completed campaign pack ids.
- `lib/services/progress_service.dart:3203-3343` chooses the next campaign
  spine pack; it does not route through `w1.s11`.

## D. Finding Validity

Decision: `FINDING_MISSCOPED_NO_CANONICAL_ASSESSMENT`.

Reason:

- The Wave A source branch adds `w1.s11` only to Flow B by appending manifest,
  session, pubspec, term-contract, guard, and review-artifact changes.
- Flow B is not the canonical normal learner route from app launch/Home/Learn.
- Flow A campaign packs are not the normal AppRoot/Home/Learn route, and they do
  not use `w1.s11`.
- The live canonical AppRoot/Home/Learn route is Act0 shell state, which already
  owns separate Act0 `hand_rankings_table` and `showdown_winning` lessons. This
  review does not score those lessons or reopen content quality.
- Therefore Wave A can be a valid JSON/session-drill content addition, but it
  does not close a canonical active-route `W1W6-DLR-001` defect.

The source branch review artifact currently overclaims canonical closure:

- It says `Closes: W1W6-DLR-001`.
- It sets `Verdict: w1_showdown_hand_ranking_source_closure_closed`.
- It says "This wave closes the defect inside Flow B".
- It says the readiness impact closes the remaining P1 hidden-prerequisite
  defect.

Those claims are not admissible under this route gate.

## E. 9/10 Score Impact

Decision: `NO_CANONICAL_SCORE_CHANGE`.

This wave cannot raise W1's evidence-backed learning score because it does not
change the normal AppRoot/Home/Learn canonical learner path, Act0 progression
state, Act0 lesson completion, campaign progression, or canonical W1 score
evidence. Do not assign a new numerical score from this wave.

## F. Integration Disposition

Decision: `CORRECT_ARTIFACT_BEFORE_INTEGRATION`.

The code/content branch can be treated as an optional or legacy session-drill
content improvement only after its review artifact is corrected. Minimum
docs-only correction required on the source branch:

1. Replace `Closes: W1W6-DLR-001` with wording such as:
   `Does not close W1W6-DLR-001 for the canonical AppRoot/Home/Learn route; records optional JSON Session Drills coverage only.`
2. Replace `Verdict: w1_showdown_hand_ranking_source_closure_closed` with:
   `Verdict: w1_showdown_optional_flow_improvement_only`.
3. Replace readiness-impact wording that says the remaining P1 hidden
   prerequisite defect is closed with:
   `No canonical W1 score/readiness improvement is admitted by this wave.`
4. Add a route-disposition section stating:
   `w1.s11 is not reachable from normal app launch/Home/Learn/W1 progression and completion persists only as generic module completion, not Act0 W1 progress.`

## Final Report Values

1. verdict: `w1_showdown_finding_misscoped`
2. branch: `main` review artifact against source branch `claude/w1-showdown-hand-ranking-source-closure-v1`
3. base/source HEAD: `4a0fdf8472594c4a7235abc414aeaa4820de9066` / `8bec6cea58d95c3aa81ddd497d178180285b039d`
4. Flow A classification: `DEBUG_SUPPORT`
5. Flow B classification: `LEGACY_BLOCKED`
6. canonical Home/Learn route: `AppRoot -> _EntryGate -> Act0ShellPreviewScreenV1 -> Act0 Home/Learn -> Act0 task runner -> Act0 completion/progress`
7. `w1.s11` learner reachability: not reachable from normal learner route; reachable only through legacy/support Session Drills entry if that screen is externally opened
8. completion/progress ownership: Act0 owns canonical W1 completion/progress; campaign spine owns campaign-support progress; Flow B owns only generic module completion for `w1.s11`
9. finding-validity decision: `FINDING_MISSCOPED_NO_CANONICAL_ASSESSMENT`
10. W1 score-impact decision: `NO_CANONICAL_SCORE_CHANGE`
11. integration disposition: `CORRECT_ARTIFACT_BEFORE_INTEGRATION`
12. minimum follow-up: source-branch docs-only artifact correction before any integration claim
