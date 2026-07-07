# W1-W6 Canonical Ownership Map v1

Date: 2026-07-08

Branch: `codex/w1-w6-canonical-ownership-map-v1`

Base HEAD: `1a7548a82bc0b01dae8e17c4bdc5fde378b9ddcb`

Status: docs-only canonical ownership and evidence-admission review. No
product, content, test, tooling, Modern Table, legacy-flow, or repair changes
were made.

Final verdict:

`w1_w6_canonical_ownership_map_closed_ready_for_deep_audit`

Score handling for every W1-W6 world:

`FROZEN_PENDING_CANONICAL_DEEP_AUDIT`

## 1. Authority Stack Used

1. `docs/plan/MASTER_PLAN_v3.0.md`
2. `docs/context/CONTEXT_ROUTER_v1.md`
3. `docs/context/ACTIVE_ROUTE_CAPSULE_v1.md`
4. `docs/context/LEARNING_REPAIR_CAPSULE_v1.md`
5. `docs/context/WORKTREE_EVIDENCE_CAPSULE_v1.md`
6. `docs/plan/W1_W6_LEARNING_CLOSURE_LEDGER_v1.md`
7. `AGENTS.md`
8. Live Act0 source and focused route-admission reviews

Graphify query used for scoped navigation:

`graphify query "W1 W6 Act0 canonical route ownership progression completion telemetry repair payoff"`

## 2. Global Canonical Route

Canonical learner route for W1-W6 scoring:

`App launch -> AppRoot -> Act0ShellPreviewScreenV1 -> Home/Learn -> Act0 world selection -> Act0 required lesson -> Act0 required task -> teaching -> guided practice -> independent assessment -> feedback -> repair -> targeted recheck -> completion -> payoff -> next task/lesson/world`

Source proof:

- App entry owner: `lib/ui_v2/app_root.dart`, `_EntryGate.build`, returns
  `Act0ShellPreviewScreenV1`.
- Canonical path root owner:
  `lib/ui_v2/act0_shell/act0_canonical_path_root_v1.dart`,
  `buildCanonicalPathRootV1`, returns `Act0ShellPreviewScreenV1`.
- Beta shell canonical tab owner: `lib/ui_v2/ui_v2_beta_shell.dart`,
  `_buildNavigator(0, buildCanonicalPathRootV1())`.
- World/lesson/task content owner:
  `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`, `_act0PreviewWorlds`.
- Runtime route/progression/completion/repair/payoff owner:
  `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`.

Noncanonical scoring rule:

Flow-B JSON Session Drills, hardcoded campaign packs, archived runners,
Audit Hub summaries, generic module completion, and screenshots can support
navigation or regression proof, but they do not raise W1-W6 canonical learning
scores unless they are proved required by the normal Act0 Home/Learn route.

## 3. Shared Owner Map

| Seam | Owner | Flow class | Canonical role |
| --- | --- | --- | --- |
| App-entry owner | `AppRoot` / `_EntryGate.build` | `CANONICAL_REQUIRED` | Boots directly to `Act0ShellPreviewScreenV1`. |
| Home/Learn routing owner | `Act0ShellPreviewScreenV1`, `Act0HomeShellV1`, `Act0LearnPathShellV1` | `CANONICAL_REQUIRED` | Home selects the current job; Learn shows selectable worlds, lessons, and tasks. |
| World definition owner | `_act0PreviewWorlds` in `act0_shell_state_v1.dart` | `CANONICAL_REQUIRED` | Defines W1-W6 world ids, titles, unlock copy, and lesson lists. |
| Lesson/task content owner | W1-W6 Act0 lesson lists in `act0_shell_state_v1.dart` | `CANONICAL_REQUIRED` | Defines required task order, `phase`, `stepKind`, runner, reward, and family. |
| Progression owner | `_progressWorld`, `_progressLesson`, `_taskAvailable`, `_firstIncompleteTask` | `CANONICAL_REQUIRED` | Sequential world, lesson, and task admission. |
| Completion owner | `_completeCurrentTask`, `_lessonCompleteWithTaskIds`, `_completedTaskIds`, `_completedLessonIds` | `CANONICAL_REQUIRED` | Task ids close lessons; complete lessons close worlds. |
| Persistence owner | `_Act0PersistedProgressV1` plus `_persistProgress` / restore path | `CANONICAL_REQUIRED` | Stores completed ids, selection, XP, retention, open repairs, evidence, review, session identity, and repair projection. |
| Telemetry owner | `Act0LessonRunnerShellV1`, `Act0TelemetrySinkV1`, shell telemetry emitters | `CANONICAL_REQUIRED` | Emits committed decision, session, repair, recheck, prove, and world-complete events. |
| Repair owner | `_recordAnswer`, `buildAct0RepairIntentV1`, `_startMistakeRepair`, Review/Home repair CTAs | `CANONICAL_REQUIRED` | Wrong/suboptimal answers create Act0 task-centric repair intent and retention memory. |
| Targeted-recheck owner | `_refreshRetentionMemoryStatusesV1`, `_topRetentionReplayCardV1`, Home/Review recheck launch | `CANONICAL_REQUIRED` | `fixedRecent -> agedRecheck -> ownedCandidate` task replay chain. |
| Payoff/summary owner | `_maybeShowBlockCompletionSummary`, `Act0BlockCompletionSummaryV1`, `_advanceAfterTask` | `CANONICAL_REQUIRED` | Lesson/world payoff, skill gains, future recheck counts, next lesson/world route. |

## 4. W1 - Poker from Zero

Canonical route:

`AppRoot -> Act0 shell -> Learn/Home -> world_1 -> _pokerFromZeroLessons -> ordered task runner -> Act0 completion/progress -> world_2 unlock`

Canonical lesson/task source:

`_pokerFromZeroLessons` in `act0_shell_state_v1.dart`.

Route-required lessons:

1. `what_poker_is` - 6 tasks
2. `what_poker_is_content` - 7 tasks
3. `cards_ranks_suits` - 7 tasks
4. `your_first_hand` - 8 tasks
5. `fold_check_call_raise` - 7 tasks
6. `blinds_action_order` - 7 tasks
7. `positions` - 7 tasks
8. `hand_rankings_table` - 14 tasks
9. `showdown_winning` - 7 tasks

Total canonical task surface inspected: 70 tasks.

Progression and lock behavior:

W1 is initially current/selectable. Within W1, only the first incomplete
lesson is current, and only the first incomplete task is startable unless it
has already been completed or explicitly skipped by Act0 policy.

Completion persistence:

`_completeCurrentTask` adds the task id to `_completedTaskIds`; when all tasks
inside the lesson are complete, the lesson id enters `_completedLessonIds`;
`_Act0PersistedProgressV1` stores both sets.

Error-to-repair-to-recheck chain:

Wrong/suboptimal Act0 choices create mistake records, `Act0RepairIntentV1`,
open repair state, retention memory, Home/Review repair launch, fixed-recent
state after a correct repair, aged recheck after the sequence threshold, then
owned-candidate after a correct recheck.

Payoff and next-step chain:

Task completion advances to the next task; final lesson task opens
`Act0BlockCompletionSummaryV1`; world completion seeds retention targets,
emits `world_complete`, and `_advanceAfterTask` selects W2 when it becomes
selectable.

Parallel/noncanonical flows:

- Flow-B JSON/session-drill showdown evidence: `LEGACY_BLOCKED` for W1 scoring.
- Optional `w1.s11` session-drill work: `HISTORICAL_ONLY`.
- Campaign/legacy runner surfaces: `DEBUG_SUPPORT` or `LEGACY_BLOCKED`.

Previously used evidence admitted:

- Act0 `hand_rankings_table` and `showdown_winning` source and route order:
  `ADMISSIBLE_CANONICAL`.
- Act0 completion ids, repair intents, Act0 telemetry, and retention memory:
  `ADMISSIBLE_CANONICAL`.
- Prior `canonical_act0_w1_showdown_learning_truth_v1.md`:
  `ADMISSIBLE_SUPPORTING_ONLY` after live-source reconciliation.

Previously used evidence excluded:

- `showdown_winner_choice_v1` Flow-B / JSON drill kind:
  `NONCANONICAL_DO_NOT_SCORE`.
- Optional `w1.s11` session-drill coverage: `HISTORICAL_ONLY`.

Unresolved ownership ambiguity:

None for owner map. Deep audit should still inspect P2 template-leak and
repair-breadth questions against W1's canonical Act0 tasks.

World verdict:

`CANONICAL_MAP_CLOSED_READY_FOR_DEEP_AUDIT`

## 5. W2 - Hand Discipline

Canonical route:

`AppRoot -> Act0 shell -> Learn/Home -> W1 complete -> world_2 -> _handDisciplineLessons -> ordered task runner -> Act0 completion/progress -> world_3 unlock`

Canonical lesson/task source:

`_handDisciplineLessons` in `act0_shell_state_v1.dart`.

Route-required lessons:

1. `hand_discipline_buckets`
2. `fold_discipline`
3. `weak_ace_warning`
4. `continue_or_let_go`
5. `hand_discipline_apply`
6. `discipline_checkpoint`

Source-shape note:

Some W2 lessons use Act0-owned `_lessonFromTasksV1` source-task reuse from
earlier Act0 task lists plus W2-specific extra drills. This is canonical Act0
source because it is directly referenced by `world_2.lessons`; it is not a
separate legacy owner. The learning-quality adequacy of the reused tasks is a
deep-audit question, not an ownership conflict.

Progression and lock behavior:

W2 is locked until all W1 lessons are complete. Once available, the first
incomplete W2 lesson becomes current and subsequent W2 lessons remain locked.

Completion persistence:

Act0 `_completedTaskIds` / `_completedLessonIds` own completion. No generic
module completion or campaign-pack progress controls W2 advancement.

Error-to-repair-to-recheck chain:

Same Act0 task-centric chain as W1. W2 mistakes are stored under W2 world,
lesson, and task ids when the source task belongs to the canonical W2 route.

Payoff and next-step chain:

Lesson summary routes to the next W2 lesson; final W2 completion routes to W3
through `_progressWorlds` and `_advanceAfterTask`.

Parallel/noncanonical flows:

- Hardcoded campaign packs: `DEBUG_SUPPORT` / `NONCANONICAL_DO_NOT_SCORE`.
- JSON session drills: `NONCANONICAL_DO_NOT_SCORE`.
- Old table-first module progress: `LEGACY_BLOCKED` for canonical W2 score.

Previously used evidence admitted:

- Act0 W2 lesson/task definitions and completion ids:
  `ADMISSIBLE_CANONICAL`.
- Runtime-bundle and feedback-completeness guards:
  `ADMISSIBLE_SUPPORTING_ONLY`.

Previously used evidence excluded:

- JSON showdown/session-drill ownership imported as canonical W2/W1 score:
  `NONCANONICAL_DO_NOT_SCORE` unless the inspected path is proved required by
  Act0 Home/Learn.

Unresolved ownership ambiguity:

None. Deep audit should inspect whether reused source tasks and added W2
drills fully support the W2 learning standard.

World verdict:

`CANONICAL_MAP_CLOSED_READY_FOR_DEEP_AUDIT`

## 6. W3 - Position Thinking

Canonical route:

`AppRoot -> Act0 shell -> Learn/Home -> W1/W2 complete -> world_3 -> _positionThinkingLessons -> ordered task runner -> Act0 completion/progress -> world_4 unlock`

Canonical lesson/task source:

`_positionThinkingLessons` in `act0_shell_state_v1.dart`.

Route-required lessons:

1. `position_six_seats`
2. `button_advantage`
3. `early_vs_late`
4. `same_hand_different_seat`
5. `position_apply`
6. `position_checkpoint`

Source-shape note:

W3 uses `_lessonFromTasksV1` in several places. Live source shows
`position_six_seats` reusing `_pokerFromZeroLessons[5].taskList` plus
position-specific extra repair drills, while other W3 lessons reuse Act0
position/preflop source lists. Because these lists are directly included in
`world_3.lessons`, they are canonical Act0 content for owner-map purposes.
Whether the reused source is pedagogically exact enough belongs to the next
canonical deep-learning audit.

Progression and lock behavior:

W3 remains locked until W2 is complete. W3 lesson/task sequencing is owned by
the same `_progressWorld`, `_progressLesson`, and `_taskAvailable` path.

Completion persistence:

Only Act0 completed task/lesson ids control W3 closure.

Error-to-repair-to-recheck chain:

Act0 repair mapping includes W3 position-specific repair targets for seat id,
BTN-last, UTG pressure, early/late order, same-hand/different-seat, and
checkpoint table-position rechecks. Unmapped mistakes fall back to exact task
replay.

Payoff and next-step chain:

Final W3 lesson completion opens W4 through the same world-completion and
next-world selection path.

Parallel/noncanonical flows:

- Campaign pack W3 runtime tests: `ADMISSIBLE_SUPPORTING_ONLY`.
- Session-drill/campaign ownership: `NONCANONICAL_DO_NOT_SCORE` unless it is
  specifically the Act0-launched task path.

Previously used evidence admitted:

- Act0 W3 source, Act0 repair intent mapping, Act0 telemetry:
  `ADMISSIBLE_CANONICAL`.
- W3 runtime truth guards: `ADMISSIBLE_SUPPORTING_ONLY`.

Previously used evidence excluded:

- Any score movement based only on campaign pack presence or raw authored
  content outside Act0 progression: `NONCANONICAL_DO_NOT_SCORE`.

Unresolved ownership ambiguity:

No route owner conflict. Source-task reuse should be inspected in the next
deep audit as a learning-quality issue.

World verdict:

`CANONICAL_MAP_CLOSED_READY_FOR_DEEP_AUDIT`

## 7. W4 - Bet Purpose / Price

Canonical route:

`AppRoot -> Act0 shell -> Learn/Home -> W1-W3 complete -> world_4 -> _betPurposePriceLessons -> ordered task runner -> Act0 completion/progress -> world_5 unlock`

Canonical lesson/task source:

`_betPurposePriceLessons` in `act0_shell_state_v1.dart`.

Route-required lessons:

1. `why_bets_happen`
2. `value_bets`
3. `bluff_pressure`
4. `protection_and_denial`
5. `call_price`
6. `small_half_pot`
7. `price_checkpoint`

Total canonical task surface inspected: 33 tasks.

Progression and lock behavior:

W4 remains locked until W3 is complete; W4 tasks are sequentially admitted by
the same Act0 task gate.

Completion persistence:

Act0 completed task/lesson ids own completion. No bridge fixture, campaign
pack, or old route label controls W4 advancement.

Error-to-repair-to-recheck chain:

Wrong/suboptimal W4 decisions enter Act0 mistake records, repair intents,
retention memory, Home/Review repair launch, aged recheck, and owned-candidate
states. W4 denial/price families previously admitted to deterministic repair
proof are supporting evidence, but Act0 source remains the canonical owner.

Payoff and next-step chain:

Final W4 completion produces the Act0 summary/payoff and unlocks W5.

Parallel/noncanonical flows:

- Old W4 label families such as `Preflop Framework`: `HISTORICAL_ONLY` for
  route identity.
- Bridge fixtures and hardcoded packs: `ADMISSIBLE_SUPPORTING_ONLY` for
  regression, not canonical scoring.

Previously used evidence admitted:

- Act0 W4 lesson/task source and Act0 progress/repair/telemetry:
  `ADMISSIBLE_CANONICAL`.
- W4 canonical fixtures and validators:
  `ADMISSIBLE_SUPPORTING_ONLY`.

Previously used evidence excluded:

- W4/W5 bridge evidence as canonical score basis:
  `NONCANONICAL_DO_NOT_SCORE`.

Unresolved ownership ambiguity:

None for owner map. Solver-light/copy precision and P2 template-leak checks
remain deep-audit items, not ownership blockers.

World verdict:

`CANONICAL_MAP_CLOSED_READY_FOR_DEEP_AUDIT`

## 8. W5 - Board Awareness

Canonical route:

`AppRoot -> Act0 shell -> Learn/Home -> W1-W4 complete -> world_5 -> _boardDrawsLessons -> ordered task runner -> Act0 completion/progress -> world_6 unlock`

Canonical lesson/task source:

`_boardDrawsLessons` in `act0_shell_state_v1.dart`.

Route-required lessons:

1. `board_texture_basics`
2. `connected_boards`
3. `flush_draws`
4. `straight_draws`
5. `outs_improvement`
6. `turn_river_changes`

Total canonical task surface inspected: 34 tasks.

Progression and lock behavior:

W5 is locked until W4 is complete. W5 task order is controlled by the same
first-incomplete-task rule.

Completion persistence:

Only Act0 completed task/lesson ids close W5. Manifest inclusion and authored
content presence do not close W5 by themselves.

Error-to-repair-to-recheck chain:

W5 board/draw misses use the same Act0 repair and retention chain. Existing
same-signal proof for dry-board and board-shift families is supporting proof;
canonical launch and repair ownership remain in Act0.

Payoff and next-step chain:

Final W5 completion opens the W6 world card through sequential world progress.

Parallel/noncanonical flows:

- Runtime bundle and W5 structured context guards:
  `ADMISSIBLE_SUPPORTING_ONLY`.
- Session-drill receipts or manifests alone:
  `NONCANONICAL_DO_NOT_SCORE`.

Previously used evidence admitted:

- Act0 W5 source, Act0 telemetry, Act0 repair intents, Act0 completion:
  `ADMISSIBLE_CANONICAL`.
- W5 structured context tests and runtime-bundle parity:
  `ADMISSIBLE_SUPPORTING_ONLY`.

Previously used evidence excluded:

- Non-Act0 draw/board evidence not progression-required:
  `NONCANONICAL_DO_NOT_SCORE`.

Unresolved ownership ambiguity:

None for owner map. Draw nuance, outs nuance, and template-leak questions stay
for canonical deep audit.

World verdict:

`CANONICAL_MAP_CLOSED_READY_FOR_DEEP_AUDIT`

## 9. W6 - Range Thinking

Canonical route:

`AppRoot -> Act0 shell -> Learn/Home -> W1-W5 complete -> world_6 -> _rangeThinkingFoundationLessons -> ordered task runner -> Act0 completion/progress -> W7 locked/preview boundary`

Canonical lesson/task source:

`world_6.lessons` points to `_rangeThinkingFoundationLessons`, which contains:

1. `_rangeThinkingLiteLessons[0]` -> `range_bucket_basics` - 5 tasks
2. `_rangeThinkingLiteLessons[1]` -> `range_board_fit` - 5 tasks
3. `_rangeThinkingLiteLessons[2]` -> `range_pressure_lines` - 8 tasks

Total canonical W6 task surface inspected: 18 tasks.

Explicitly not canonical W6 scoring evidence in this map:

- `_rangeThinkingLiteLessons[3]` -> `range_combo_counts`
- `_rangeThinkingLiteLessons[4]` -> `range_thinking_checkpoint`

Those lessons exist in source but are not included in `world_6.lessons` at the
current HEAD. They must not be counted for canonical W6 scoring unless a future
route/content update admits them.

Progression and lock behavior:

W6 is locked until W5 is complete. W6's three foundation lessons are
sequentially unlocked through Act0 progress.

Completion persistence:

Act0 completed task/lesson ids and persisted progress own W6 closure. The old
session-drill receipt/queue family does not own canonical W6 completion.

Error-to-repair-to-recheck chain:

Canonical W6 answer handling creates Act0 task-centric repair intent and
retention memory. The prior W6 session-drill dead-end finding was misscoped for
canonical W6; the current Act0 chain has exact replay, mapped transfer for key
pressure-line tasks, `recheck_completed`, and owned-candidate promotion.

Payoff and next-step chain:

Final W6 completion produces Act0 summary/payoff and retention seeding. W7+
route expansion is not activated by this map.

Parallel/noncanonical flows:

- Session-drill receipt/recheck queue: `ACTIVE_OPTIONAL` support surface when a
  session-drill receipt exists; `NONCANONICAL_DO_NOT_SCORE` for W6 canonical
  Act0 scoring.
- Extra W6-like source lessons not in `world_6.lessons`:
  `NONCANONICAL_DO_NOT_SCORE` for current canonical W6 scoring.
- W7 visible-card continuation: outside this W1-W6 map.

Previously used evidence admitted:

- Act0 W6 foundation lessons, Act0 telemetry, Act0 repair intents, Act0
  retention/recheck state: `ADMISSIBLE_CANONICAL`.
- `w6_repair_recheck_canonical_admission_gate_v1.md`:
  `ADMISSIBLE_SUPPORTING_ONLY` after live-source reconciliation.

Previously used evidence excluded:

- Old `content/worlds/world6/v1/sessions/w6.s01` or session-drill receipt path
  as canonical Act0 W6 closure evidence: `NONCANONICAL_DO_NOT_SCORE`.

Unresolved ownership ambiguity:

None for owner map. Deep audit must inspect whether the canonical three-lesson
W6 foundation route is sufficient for later score movement and must not import
the excluded combo/checkpoint lessons unless a route owner admits them.

World verdict:

`CANONICAL_MAP_CLOSED_READY_FOR_DEEP_AUDIT`

## 10. Cross-World Seam Proof

| Seam | Completion owner | Unlock owner | Next-world routing | Persistence | Payoff | Legacy/optional control? | Result |
| --- | --- | --- | --- | --- | --- | --- | --- |
| W1 -> W2 | `_completeCurrentTask` / `_lessonCompleteWithTaskIds` | `_progressWorlds` with `previousWorldComplete` | `_advanceAfterTask` selects next selectable world | `_Act0PersistedProgressV1` | `Act0BlockCompletionSummaryV1` + `world_complete` | No | PASS |
| W2 -> W3 | Same Act0 owner | Same Act0 owner | Same Act0 owner | Same Act0 owner | Same Act0 owner | No | PASS |
| W3 -> W4 | Same Act0 owner | Same Act0 owner | Same Act0 owner | Same Act0 owner | Same Act0 owner | No | PASS |
| W4 -> W5 | Same Act0 owner | Same Act0 owner | Same Act0 owner | Same Act0 owner | Same Act0 owner | No | PASS |
| W5 -> W6 | Same Act0 owner | Same Act0 owner | Same Act0 owner | Same Act0 owner | Same Act0 owner | No | PASS |

No campaign pack, JSON Session Drill, generic module progress, Audit Hub row,
or screenshot controls canonical world advancement.

## 11. Evidence Admission Map

| Evidence source | Classification | Reason |
| --- | --- | --- |
| Act0 lesson/task definitions | `ADMISSIBLE_CANONICAL` | Direct source for W1-W6 normal route. |
| Act0 world cards / `_act0PreviewWorlds` | `ADMISSIBLE_CANONICAL` | Direct source for world order, titles, lock state, lesson list. |
| Act0 completedTaskIds/completedLessonIds | `ADMISSIBLE_CANONICAL` | Canonical completion/progression persistence. |
| Act0 telemetry from active runner decisions | `ADMISSIBLE_CANONICAL` | Active route telemetry owner after Wave 5 proof. |
| Act0 repair intents | `ADMISSIBLE_CANONICAL` | Canonical task-centric repair owner. |
| Act0 retention memory / aged recheck / owned candidate | `ADMISSIBLE_CANONICAL` | Canonical targeted recheck owner. |
| Act0 repair outcome projection and Review resolution receipts | `ADMISSIBLE_CANONICAL` when launched from Act0 source tasks | Canonical repair proof state; must preserve source task/world attribution. |
| Hardcoded campaign packs | `ADMISSIBLE_SUPPORTING_ONLY` | Useful for parity/regression support, not normal Home/Learn scoring. |
| JSON Session Drills | `NONCANONICAL_DO_NOT_SCORE` | Flow-B/legacy for canonical W1-W6 scoring unless separately proved Act0-required. |
| Content manifests | `ADMISSIBLE_SUPPORTING_ONLY` | Prove bundle/source availability; source existence alone is insufficient. |
| Runtime-bundle tests | `ADMISSIBLE_SUPPORTING_ONLY` | Prove parity and no runtime drop; do not score learning quality by themselves. |
| Audit Hub evidence | `ADMISSIBLE_SUPPORTING_ONLY` when fresh; otherwise `HISTORICAL_ONLY` | Routing and evidence log only. |
| Session-drill telemetry | `NONCANONICAL_DO_NOT_SCORE` | Optional/legacy owner for this gate. |
| Session-drill repair receipts | `NONCANONICAL_DO_NOT_SCORE` for canonical Act0 scoring | Valid for session-drill owner only. |
| Generic module completion | `NONCANONICAL_DO_NOT_SCORE` | Does not own Act0 progression. |
| Screenshots and deterministic captures | `ADMISSIBLE_SUPPORTING_ONLY` | Visual/reachability proof, not content-quality scoring by itself. |
| Prior W1-W6 audit artifacts | `HISTORICAL_ONLY` unless reconciled to live Act0 source | Useful provenance; live source and active SSOT win conflicts. |

## 12. Systemic Defect Scan

| Defect class | Finding |
| --- | --- |
| Parallel route owners | Present as support/legacy systems, but none controls canonical Act0 W1-W6 progression. |
| Content present but not progression-required | Present: W6 combo/checkpoint lessons exist but are not in `world_6.lessons`; do not score them. |
| Teaching and assessment split across flows | Not found as an owner conflict. Deep audit must inspect task ordering quality within Act0 only. |
| Completion written outside canonical progress | Generic/module/session completion exists but is noncanonical for this gate. |
| Telemetry owned by another flow | Session-drill telemetry exists but does not own canonical Act0 telemetry. |
| Repair receipts without canonical recheck | Session-drill receipts are optional/noncanonical for W1-W6 scoring; Act0 task repair has aged recheck. |
| Canonical UI using different source than audited content | Historical risk confirmed; this map admits only Act0 source used by `_act0PreviewWorlds`. |
| Duplicate progression owners | Not found for canonical route. |
| Learner-reachable optional paths mistaken for curriculum | Historical risk confirmed; optional Flow-B/campaign evidence excluded. |
| Score/closure claims based on noncanonical evidence | Historical W1/W6 precedents corrected; this map freezes all scores pending canonical deep audit. |

## 13. P2 Handling

Do not automatically confirm or close:

- `W1W6-DLR-003`
- `W1W6-DLR-004`
- `W1W6-DLR-005`

Next-phase inspection owners:

| ID | Canonical owner to inspect | Evidence required next |
| --- | --- | --- |
| `W1W6-DLR-003` | Act0 Home/Learn shell owner: `act0_home_shell_v1.dart`, `act0_learn_path_shell_v1.dart`, and `Act0ShellPreviewScreenV1` composition | Compact portrait visual/widget proof that mission CTA dominates `Now` / current lesson / current step / progress labels. |
| `W1W6-DLR-004` | Act0 repair owner plus Act0/source task families; session-drill repair receipts only as noncanonical support | Canonical Act0 miss -> repair intent -> persistence -> Review/Home repair -> aged recheck -> result proof for the next admitted family. |
| `W1W6-DLR-005` | Act0 prompt/option source in `act0_shell_state_v1.dart` and `Act0LessonRunnerShellV1` display behavior | Canonical-only prompt/option anti-leak sample across W1-W6, excluding JSON/session-drill-only rows. |

## 14. Ownership Conflicts

Blocking owner conflicts: none.

Reachability gaps: none found in the owner chain.

Supporting-only ambiguities to carry into deep audit:

1. W2 and W3 use Act0-owned source-task reuse in several lessons. This is
   canonical because it is referenced by `world_2.lessons` / `world_3.lessons`,
   but the pedagogical exactness of the reused source belongs to the next
   canonical deep-learning audit.
2. W6 current canonical scope is the three-lesson foundation route. Extra
   range-thinking source lessons must not be scored unless admitted by a
   future route/content update.

## 15. Final Readiness For Deep Audit

All W1-W6 worlds have a closed canonical owner map for:

- app entry;
- Home/Learn routing;
- world definition;
- lesson/task source;
- progression;
- completion;
- persistence;
- telemetry;
- repair;
- targeted recheck;
- payoff/summary;
- next task/lesson/world routing.

The next phase may begin canonical-only deep learning audit with all W1-W6
scores still frozen:

`FROZEN_PENDING_CANONICAL_DEEP_AUDIT`
