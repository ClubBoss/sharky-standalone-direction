# Active vs Legacy Ownership Audit v1

Date: 2026-06-23

Origin main: `319be6a7ddd6ad41d1f799b73ac3fc6ed2ba26b7`

Status: advisory ownership audit, not cleanup authority.

## Scope and non-scope

This audit classifies ambiguous runtime, compatibility, demo, and dormant
areas that can mislead future work around the active Act0 route and the W6
session-drill recheck boundary. It does not authorize deletion, archival,
movement, refactoring, product behavior, route, telemetry, content, or UI
changes. No area is classified as safe-to-delete.

## Method

- Read the current agent/process context, Graphify distillation, W6 route
  prerequisite audit, repository instructions, topology truth map, and Master
  Plan.
- Ran `graphify hook-check` and five scoped Graphify queries for `lib/screens`,
  `main_demo.dart`, `AutoTheoryReviewEngine`, engine ownership, and the
  canonical session-drill runner path.
- Confirmed every conclusion below with imports, callers, route signatures,
  runner code, and focused contract-test references. Source evidence overrides
  Graphify heuristics and path names.

## Classification table

| Area/path | Classification | Evidence | Agent guidance | Cleanup eligibility |
| --- | --- | --- | --- | --- |
| `lib/main.dart`, `lib/ui_v2/app_root.dart`, `lib/ui_v2/act0_shell/*` | active_runtime | `main.dart` runs `AppRoot`; `_EntryGate` and `buildCanonicalPathRootV1` build `Act0ShellPreviewScreenV1`. | Start learner-facing work here unless scope proves another owner. Preserve the canonical Act0 entry. | no |
| `lib/screens/*` as a directory | mixed_requires_scoped_followup | The production canonical root does not import it directly, but many non-Act0 services/widgets/onboarding paths import it. `lib/main_demo.dart` and `lib/screens/main_menu_screen.dart` also retain direct links. | Do not treat this directory as the active Act0 owner or as removable legacy. Open only the named screen/launcher with an explicit scope and inbound-reference check. | unknown |
| `lib/ui_v2/screens/*` | mixed_requires_scoped_followup | It is a distinct namespace from `lib/screens`. The canonical runner imports theory/session presentation screens from it, while topology marks some table/pack paths as legacy-only. | Do not collapse `lib/screens` and `lib/ui_v2/screens` into one ownership claim. Inspect the exact screen and its canonical/legacy boundary test before editing. | unknown |
| `lib/main_demo.dart` | demo_only | It creates `PokerAnalyzerDemoApp`, sets `demoMode = true`, and renders `Demo Mode Active`. Its only source-level caller found is `lib/screens/main_menu_screen.dart`; `main.dart` remains the configured production entry. | Do not use as Act0 architecture authority. Touch only for explicit demo work; keep it because the legacy main-menu path still references it. | no |
| `lib/engine/*` | mixed_requires_scoped_followup | Active runner files still import `engine/scenario_replayer/scenario_models.dart` and `engine/scenario_replayer_fsm_v1.dart`; the directory also contains broad historical simulation/motion families. | Do not call the whole directory dormant or active. Treat the directly imported scenario seams as compatibility dependencies; require exact-owner proof for any other engine file. | unknown |
| `lib/engine_v2/*` | mixed_requires_scoped_followup | Active runner files import EngineV2 action, money, decision-bar, and execution contracts. `legacy_vs_engine_v2_parity_audit_v1.dart` still compares legacy campaign outcomes with EngineV2. | EngineV2 has active runtime use, but parity/migration is not proven complete. Do not remove or rewrite EngineV1 compatibility seams as a consequence of EngineV2 use. | unknown |
| `lib/services/auto_theory_review_engine.dart` | compatibility_runtime | `LearningPathEngine.initialize()` invokes `runAutoReviewIfNeeded`; `SmartReinjectionFlow` also owns an instance. No direct import reaches the canonical Act0 entry or Act0 shell. | Do not use it as current Act0 repair architecture authority. Preserve it for its legacy/adaptive learning-path callers unless a separately scoped ownership audit proves otherwise. | unknown |
| `lib/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart` | archive_but_referenced | `CanonicalTerminalRunnerSurfaceV1` imports and instantiates it; `session_drill_player_v1_screen.dart` delegates to its canonical route; many canonical session-drill tests instantiate it. | Do not move, delete, or treat as dormant. Its archive location does not remove its compatibility-runtime role. | no |
| `lib/archive/legacy_runners/*` as a directory | mixed_requires_scoped_followup | The topology identifies archived runner families, while current canonical terminal dispatch still imports specific archived runner surfaces. Other files were not individually proven active in this audit. | Inspect the exact file and its importers. Archive placement alone is not a cleanup verdict. | unknown |
| W6 receipt -> candidate -> launch queue seam | mixed_requires_scoped_followup | The queue preserves W6 session/drill identity, but no consumer can safely turn it into an Act0 task intent or exact target-drill launch. | Keep the queue internal and invisible until a dedicated route-contract wave owns target launch, completion/progress, telemetry, and dependent tests. | no |

## Detailed findings

### 1. `lib/screens`

`lib/screens` is not the current canonical learner-facing route. The production
entry is `lib/main.dart` -> `AppRoot` -> `_EntryGate` ->
`Act0ShellPreviewScreenV1`. There is no direct import from the Act0 entry or
Act0 shell to `lib/screens`.

It is nevertheless not dormant. Non-Act0 services, widgets, onboarding, and
legacy launchers import many of its screens. `main_demo.dart` also imports
multiple screens, and `main_menu_screen.dart` can launch the demo app. The
directory therefore has mixed ownership and is dangerous to change by broad
path-based rules.

Important namespace distinction: `lib/ui_v2/screens/*` is separate from
`lib/screens/*`. Canonical runner code imports selected `ui_v2/screens`
theory/session presentation files. Agents must not use a broad `screens`
search result to claim that either namespace is wholly legacy.

### 2. `engine` versus `engine_v2`

The active runner has a hybrid dependency boundary. Its files import EngineV2
for execution, actions, decision-bar state, and money state, while still
importing EngineV1 scenario-model and scenario-FSM seams. The parity audit
explicitly runs legacy campaign scenarios beside EngineV2 and compares
normalized outcomes. That is evidence of an incomplete coexistence/migration
boundary, not a completed replacement.

Consequently, neither root can be classified wholesale as dormant residue.
The active direct imports are compatibility/runtime dependencies; unreferenced
subfamilies require a separate owner/dependent audit before any cleanup.

### 3. `main_demo.dart`

`main_demo.dart` is a demo entrypoint, not the production entrypoint. It
defines `PokerAnalyzerDemoApp`, defaults to demo mode, and visibly labels the
surface `Demo Mode Active`. The current configured application entry is
`main.dart`, and the project configuration points the demo target to
`main.dart`, not `main_demo.dart`.

It is still referenced by `lib/screens/main_menu_screen.dart`. It is therefore
demo-only, not unused; future agents should ignore it for Act0 decisions but
must not delete or repurpose it incidentally.

### 4. `AutoTheoryReviewEngine`

`AutoTheoryReviewEngine` is a real service for the older adaptive learning-path
family: `LearningPathEngine.initialize()` runs auto review and
`SmartReinjectionFlow` uses it to rank/inject theory boosters. It has focused
tests. The active Act0 app root and Act0 shell do not import it directly.

It is compatibility runtime for a non-Act0 learning-path family, not the
current learner-facing repair owner. Future Act0/W6 work must not derive
architecture or behavior from this service without an explicit cross-family
decision.

### 5. Archive runners and session-drill runner ownership

The session-drill surfaced runner is located under
`lib/archive/legacy_runners`, but source evidence makes it a live compatibility
dependency:

1. `canonicalSessionDrillRouteV1` builds `CanonicalLauncherV1.sessionDrill`.
2. The canonical terminal host resolves a session-drill payload.
3. `CanonicalTerminalRunnerSurfaceV1` imports and instantiates
   `CanonicalTerminalSessionDrillSurfacedRunnerV1`.
4. The runner loads drills through `DrillRuntimeAdapterV1`; canonical and
   rendered session-drill tests instantiate this same class.

The topology document correctly treats Act0 as the active product route and
archived runners as non-primary surfaces. Source adds the narrower but crucial
qualification: this named archived file is still referenced inside canonical
terminal dispatch. That makes it `archive_but_referenced`, not dormant.

The rest of `archive/legacy_runners` is not proven uniformly historical or
uniformly live; it remains `mixed_requires_scoped_followup` at directory level.

### 6. Active Act0/runtime boundary and W6 danger seams

The active product boundary is `main.dart` -> `AppRoot` -> `_EntryGate` ->
`Act0ShellPreviewScreenV1`; `buildCanonicalPathRootV1` independently returns
the same Act0 root. This remains the starting point for learner-facing work.

The W6 chain stops intentionally at
`SessionDrillRecheckLaunchQueueItemV1`. The canonical session route accepts a
`sessionId` plus World1/handoff fields, and neither it nor the terminal payload
or surfaced runner accepts `initialDrillId` or equivalent. The runner starts at
`_currentIndex = 0`, loads the full session, and normal completion marks the
module complete and emits `session_drills_complete_v1`.

Act0 repair intents own world/lesson/task identity. The W6 queue owns
session/drill identity. Converting between them now would fabricate task
identity; launching a session alone would drop the exact target drill. The
dangerous future owners are therefore the canonical route/launcher, terminal
payload/dispatch, surfaced runner completion policy, progress/telemetry policy,
and a later explicit user-initiated Act0 launch seam. They must be opened
together only in a dedicated route-contract wave.

## Dangerous assumptions rejected

- A file under `archive/` is not automatically dormant.
- A file outside `act0_shell` is not automatically safe to remove.
- Graphify relationships are navigation hints, not runtime proof.
- EngineV2 use does not prove EngineV1 migration/parity is complete.
- A session id is not an adequate substitute for a target session-drill id.
- An Act0 repair intent cannot be invented from a session-drill receipt.
- The absence of a direct Act0 import does not make a compatibility family
  deletable.

## What agents should avoid by default

- Do not edit `lib/screens/*`, `lib/archive/legacy_runners/*`, `lib/engine/*`,
  or `lib/engine_v2/*` based only on their directory names.
- Do not use `main_demo.dart` or `AutoTheoryReviewEngine` as product-route
  authority for Act0 work.
- Do not add `initialDrillId`, target-drill launch, or a visible W6 queue
  consumer as a small isolated change.
- Do not move archive runners to make the tree look cleaner.

## Follow-up candidates

1. If W6 visible recheck continuation remains prioritized, open one explicit
   cross-family route-contract wave for validated target-drill launch,
   recheck-specific completion/progress policy, recheck-specific telemetry
   policy, and focused owner/dependent tests.
2. If repository simplification becomes a goal, audit one exact legacy family
   at a time with importers, runtime route proof, and guard tests. Do not start
   with a directory-wide archive-removal effort.
3. Run a separate engine ownership/parity audit before treating either engine
   root as migration-complete or removable.

## Validation run

- `graphify hook-check`
- `flutter analyze`
- `git diff --check`
- `git status --short`

No product tests or screenshot commands are required because this audit changes
only this review note.
