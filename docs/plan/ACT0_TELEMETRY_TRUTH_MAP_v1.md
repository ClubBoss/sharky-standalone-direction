# ACT0_TELEMETRY_TRUTH_MAP_v1

Status: ACTIVE CONTRACT MAP
Purpose: define the minimum W1-W12 learning-event contract before any broad
telemetry implementation.
Last updated: 2026-05-21

## Authority

Use this file beneath:

- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/EXECUTION_POLICY_SSOT_v1.md`
- `docs/plan/FULL_PRODUCT_READINESS_LEDGER_v1.md`
- `docs/l10n/TRANSLATION_SSOT_v1.md`

This file owns the active Act0 telemetry truth map.

Use it for:

- W1-W12 learning-event names
- owner seams
- payload principles
- privacy boundaries
- future proof strategy

Do not use it for:

- analytics vendor selection
- network instrumentation
- monetization telemetry
- broad persistence or schema changes
- user identity tracking
- resurrecting dormant telemetry systems as active truth

## Current Inventory

| Candidate | Status | Verdict |
| --- | --- | --- |
| `lib/ui_v2/act0_shell/*` | ACTIVE route owner | Owns the current learner route state and can supply stable world, lesson, task, answer, repair, practice, resume, and completion facts. |
| `lib/ui_v2/act0_shell/act0_telemetry_sink_v1.dart` | ACTIVE local proof seam | Defines the Act0-local event and in-memory sink used for deterministic non-network tests. |
| `lib/infra/telemetry.dart` | ACTIVE support, not Act0 contract | Minimal Sentry wrapper with an override hook. It is not the Act0 learning-event SSOT. |
| `lib/infra/telemetry_builder.dart` | LEGACY / reference helper | Contains older module / spot payload helpers. It does not match the Act0 W1-W12 route contract. |
| `lib/constants/telemetry_events.dart` | MIXED registry | Contains many older app-wide event names. It is not sufficient for Act0 learning-loop validation. |
| `lib/constants/telemetry_schema.dart` | MIXED registry | Classifies older events, but does not define the Act0 learning-event payload contract. |
| `lib/telemetry/telemetry_service.dart` | DORMANT / non-Act0 | Persona/theme-oriented helper; not an active Act0 route owner. |
| `lib/services/*analytics*`, `lib/services/*telemetry*` | DORMANT / previous systems unless proven otherwise | Useful as historical references only. Do not wire Act0 through them without a separate admitted architecture wave. |
| `pubspec.yaml` Firebase analytics dependency | INACTIVE | `firebase_analytics` is commented out. No analytics vendor is active for this contract. |

Current verdict:

- Act0 has enough local state to define a learning-event map.
- Act0 now has a small local proof seam for `task_shown` and `task_result`.
- Existing telemetry code is fragmented and partly historical.
- Broad runtime instrumentation remains unsafe until a privacy posture is
  attached to release policy.

## Event Payload Principles

Required principles for every future Act0 learning event:

- use stable IDs instead of visible copy:
  - `worldId`
  - `worldNumber`
  - `lessonId`
  - `taskId`
  - `taskFamily`
  - `phase`
- use learner-action categories instead of raw prose:
  - `choiceId`
  - `result`
  - `errorType`
  - `repairStatus`
  - `source`
- use bounded timing categories by default:
  - `under_3s`
  - `3_to_10s`
  - `10_to_30s`
  - `over_30s`
  - `unknown`
- use attempt counters and route-relative sequence numbers only when needed
- keep locale separate from copy and never log localized strings
- keep event version explicit with `schemaVersion: 1`

Forbidden by default:

- player name, email, phone, account ID, device advertising ID, IP address, or
  precise location
- raw card strings, full hand histories, or complete board runouts unless a
  later privacy review explicitly admits a sanitized hand-state schema
- raw lesson text, feedback copy, option labels, localized strings, or free
  text
- exact timestamps when a session-relative sequence or bucket is enough
- monetization / paywall state in W1-W12 learning events
- any external network call before release privacy posture is approved

## Minimal W1-W12 Event Contract

| Event | Owner seam | Trigger | Required fields | Forbidden fields | Privacy notes | Validation / proof strategy | Dependency gate relevance |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `lesson_started` | `Act0ShellPreviewScreenV1` task launch path | learner starts or resumes a lesson task from Learn, Home, Practice, or Review | `schemaVersion`, `worldId`, `worldNumber`, `lessonId`, `taskId`, `source`, `resumeState` | visible title, localized copy, user ID | source should be an enum such as `learn`, `home`, `practice`, `review`, `resume` | fake sink test asserts one event at start and stable IDs only | validates route start / resume funnel |
| `task_shown` | `Act0LessonRunnerShellV1` / runner presentation owner | task prompt becomes visible for action | `schemaVersion`, `worldId`, `lessonId`, `taskId`, `taskFamily`, `phase`, `attemptOrdinal` | prompt text, option labels, cards | no raw table state; task ID is the content reference | widget/contract test asserts event occurs before choice result | validates exposure denominator |
| `user_choice` | runner answer handler | learner selects an answer or sizing preset | `schemaVersion`, `worldId`, `lessonId`, `taskId`, `choiceId`, `decisionTimeBucket`, `attemptOrdinal` | option label, raw action copy, exact timestamp | bucket timing; no exact card/action prose | fake sink test checks choice event contains no copy fields | validates choice behavior and hesitation |
| `task_result` | `_recordAnswer` / completion handler | result is known after a choice | `schemaVersion`, `worldId`, `lessonId`, `taskId`, `result`, `errorType`, `attemptOrdinal`, `repairStatus` | feedback reason, better answer label | `errorType` must be a controlled enum or `unknown` | tests assert correct / incorrect paths and forbidden fields | validates learning outcomes |
| `feedback_viewed` | runner review / feedback phase | feedback panel is shown after a result | `schemaVersion`, `worldId`, `lessonId`, `taskId`, `result`, `feedbackType` | feedback text, Sharky line | records that feedback appeared, not what it said | widget test moves to feedback phase and inspects event | validates feedback exposure |
| `repair_started` | Review quick-fix / in-lesson repair launch | learner starts a repair task | `schemaVersion`, `sourceTaskId`, `repairTaskId`, `worldId`, `lessonId`, `source` | mistake reason, option labels | IDs only; do not log learner-facing mistake text | test starts repair from Review and verifies source mapping | validates repair uptake |
| `repair_completed` | repair answer / resolution path | repair attempt finishes | `schemaVersion`, `sourceTaskId`, `repairTaskId`, `result`, `attemptOrdinal`, `repairStatus` | scar language, free text, feedback copy | no permanent failure identity | test verifies fixed/open states emit controlled result | validates repair effectiveness |
| `recheck_completed` | Review recheck owner | aged recheck spot completes | `schemaVersion`, `taskId`, `worldId`, `lessonId`, `result`, `successfulRecheckCount` | internal retention object names, visible copy | do not log `agedRecheck` as user-facing language; enum is internal payload only if documented | fake sink test runs a recheck path | validates retention loop |
| `prove_completed` | Review prove owner | prove-it spot completes | `schemaVersion`, `taskId`, `worldId`, `lessonId`, `result`, `proveCount` | mastery claims, visible copy | result is a proof event, not permanent mastery | test asserts prove candidate completion event | validates ownership confidence |
| `practice_started` | Practice / Play launch path | learner opens a practice group or featured recommendation | `schemaVersion`, `practiceGroupId`, `source`, `recommended`, `lessonId` if available | copy labels, paywall state | group ID only; no monetization fields | Play test starts daily / topic practice with fake sink | validates Practice uptake |
| `practice_completed` | rapid practice completion path | practice rep or daily set ends | `schemaVersion`, `practiceGroupId`, `completedRepCount`, `cleanRepCount`, `resultSummary` | exact accuracy percentage unless explicitly approved, visible completion copy | summary should be enum-like, not marketing text | test completes daily reps and verifies payload | validates keep-sharp loop |
| `world_completed` | world completion summary owner | final task completion makes the world complete | `schemaVersion`, `worldId`, `worldNumber`, `completedTaskCount`, `perfectClearCount`, `openRepairCount`, `futureRecheckCount`, `futureProveCount`, `nextWorldId` if available | celebration copy, mastery claim, fake percentage | counts are okay; do not claim permanent mastery | world completion test checks event after summary creation | validates milestone payoff and next unlock |
| `session_resumed` | persisted progress restore path | stored Act0 progress is loaded and route resumes | `schemaVersion`, `resumeInRunner`, `resumePhase`, `worldId`, `lessonId`, `taskId`, `source` | exact saved option label, raw JSON blob | only log route-level resume facts | boot/resume test with fake sink | validates re-entry health |
| `route_dropoff_point` | future app lifecycle / route persistence owner | learner leaves or app pauses while an active route point is known | `schemaVersion`, `worldId`, `lessonId`, `taskId`, `phase`, `lastVisibleSurface`, `progressState` | reason inference, device identifiers, raw app lifecycle logs | safe only as a local route marker; no guessed intent | future lifecycle test; not required for first local sink spike | validates drop-off and recovery points |

## Owner Seams

Telemetry ownership should follow product ownership:

- `Act0ShellPreviewScreenV1`
  - route orchestration
  - launch source
  - resume / drop-off point
  - world completion state assembly
- `Act0LessonRunnerShellV1`
  - visible task / feedback presentation
  - choice timing boundary if implemented locally
- `_recordAnswer` and nearby answer handlers
  - choice result
  - error / repair state transitions
- Review owner seam
  - repair, recheck, and prove outcomes
- Practice / Play owner seam
  - practice start and completion
- future telemetry sink seam
  - event validation
  - local buffering
  - vendor isolation

Do not let a vendor SDK, legacy analytics service, or dormant AI/persona system
own Act0 learning-event meaning.

## Privacy And Data Constraints

Telemetry v1 must be local-first until release policy admits external export.

Before any vendor or network integration:

- legal/privacy docs must describe what is collected and why
- opt-out / data deletion posture must be decided
- event payload tests must prove forbidden fields are absent
- telemetry must be non-blocking and never change route behavior
- failure to emit telemetry must not block learning, progress, review, or
  completion

The first implementation wave, if admitted, should use a fake or local in-memory
sink only. That keeps proof deterministic while the product decides privacy and
release posture.

## Future Implementation DoD

The next implementation wave is not broad analytics.

Current local proof:

- `Act0LessonRunnerShellV1` can emit `task_shown` and `task_result`.
- `Act0InMemoryTelemetrySinkV1` proves event order and payload shape in tests.
- The implementation is local-only and has no vendor, network, or external
  storage path.

Minimum safe path for any future expansion:

1. Admit one owner seam explicitly.
2. Wire at most the event(s) in that seam.
3. Prove event order and payload shape.
4. Prove forbidden fields are absent.
5. Keep external network export disabled.

Stop before:

- vendor SDK work
- dashboards
- monetization telemetry
- broad event wiring
- privacy-sensitive identifiers

## Gate Impact

This truth map moves the telemetry gate from:

- no reliable event map
- no payload rules
- no privacy boundary

to:

- event names defined
- owner seams identified
- payload and forbidden fields documented
- validation strategy defined

The gate remains closed for public beta until:

- runtime instrumentation exists
- privacy / legal posture is approved
- release docs describe telemetry behavior
- validation proves events are emitted and safe
