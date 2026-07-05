# Volume I Content Depth / Term Introduction / Drill Coverage Audit v1

## 1. Verdict

volume1_content_audit_bounded_p1_wave_recommended

## 2. Scope and authority

Scope: evidence audit only for the canonical Act0 learner-facing W1-W12 route and directly owned active content sources. No runtime code, route, tests, screenshots, mascot assets, Modern Table, W13+, or broad backlog work was changed.

Authority read:

- `AGENTS.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/content/ACTIVE_CONTENT_SSOT_INDEX_v1.md`
- `docs/content/CONTENT_EXCELLENCE_CANON_v1.md`
- `docs/plan/CURRICULUM_DENSITY_WORLD_VOLUME_CANON_v1.md`
- `docs/plan/WORLD_PROGRESSION_PACING_SSOT_v1.md`
- `docs/learning/UNIFIED_LEARNING_ARCHITECTURE_v4.4.md`
- `docs/plan/CONCEPT_TO_WORLD_COVERAGE_MATRIX_v1.md`
- Active Act0 route/content source: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- Active authored content roots proven by the active index: `content/world1_act0_*/v1/` and `content/worlds/world*/v1/`

Validation limitation: `docs/plan/SEAM_TRANSITION_AUDIT_TEMPLATE_v1.md` is referenced by the master plan, but the file is not present at that path in the current checkout. `rg --files | rg 'SEAM_TRANSITION|seam.*audit|TRANSITION_AUDIT|AUDIT_TEMPLATE'` found only investigation audits, not the required template.

## 3. Active content ownership proof

The active content index defines `content/world1_act0_*/v1/` and `content/worlds/world*/v1/` as active authored content and excludes historical archives from runtime ownership (`docs/content/ACTIVE_CONTENT_SSOT_INDEX_v1.md:128-147`).

The active learner-facing route is the Act0 shell. `Act0ShellStateV1.sample` uses `_act0PreviewWorlds` as the world list and `_pokerFromZeroLessons` as the selected current lesson set (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:185-197`). `_act0PreviewWorlds` exposes `world_1` through `world_12` and binds each world card to a lesson list (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:5909-6078`).

The master plan states the Volume I bar: every release-visible playable world needs Intro, Practice, Apply, Review, suboptimal-option literacy, repair, transfer, and smooth transition evidence (`docs/plan/MASTER_PLAN_v3.0.md:1040-1125`).

## 4. Executive findings

1. P1: The live Act0 route currently has a lesson-owner binding offset from W4 through W6 against the current normalized W4-W7 contract. `world_4` correctly displays `Bet Purpose / Price` but binds `_preflopFrameworkLessons`; `world_5` correctly displays `Board Awareness` but binds `_betPurposePriceLessons`; `world_6` correctly displays `Range Thinking` but binds `_boardDrawsLessons` (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:5952-5992`). `world_7` correctly displays `Visible Cards Change Ranges` and binds `_rangeThinkingLiteLessons` for the accepted visible-card range continuation preview (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:5994-6007`). This weakens term introduction, handoff trust, and world-to-world vocabulary truth even though the displayed W4-W7 titles are already aligned.
2. P1: W11 and W12 have live Act0 lessons, but their file-backed active content roots are shells with no JSON drill files. The live Dart route has 4 lessons / 21 explicit tasks for W11 and 4 lessons / 20 explicit tasks for W12, while `content/worlds/world11/v1/` and `content/worlds/world12/v1/` contain only `index.md` and `world.md`. This creates source-of-truth fragility for repair, transfer, and future validators.
3. P2: Advanced abbreviations and labels mostly appear safely in context, but `SPR` and `ICM` are exposed as compact labels before expansion in some active/supporting content (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:4811-4815`, `content/worlds/world8/v1/index.md:3-12`). This is not a blocker because the relevant worlds are locked and nearby copy explains the behavior, but it should be smoothed during the next content copy pass.
4. No P0 was found. Active learner content exists for W1-W12 in Act0, and the most serious issue is presentation/ownership mismatch rather than missing route content.

Current W4-W7 alignment matrix:

| World | Current canonical job | Displayed job | Bound lesson owner | First two lessons | Aligned? |
| --- | --- | --- | --- | --- | --- |
| W4 | Bet Purpose / Price. | Bet Purpose / Price. | `_preflopFrameworkLessons`. | `First-in open`; `Facing an open`. | No: lesson-owner mismatch only; displayed copy is correct. |
| W5 | Board Awareness. | Board Awareness. | `_betPurposePriceLessons`. | `Why bets happen`; `Value bets`. | No: lesson-owner mismatch only; displayed copy is correct. |
| W6 | Range Thinking. | Range Thinking. | `_boardDrawsLessons`. | `Dry or wet board`; `Connected boards`. | No: lesson-owner mismatch only; displayed copy is correct. |
| W7 | Visible Cards Change Ranges / visible-card range continuation. | Visible Cards Change Ranges. | `_rangeThinkingLiteLessons`. | `Range buckets`; `Range meets board`. | Yes for the current locked route-card contract and accepted W7 preview tests. |

## 5. World-by-world matrix

| World | Core job | Terms introduced safely | Explanation depth | True decision reps | Suboptimal literacy | Transfer coverage | Repair coverage | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| W1 | Table literacy and first action confidence. | Mostly safe; seat abbreviations appear in seat-order constants and W1 teaches seats/blinds/pot. | Strong: 11 live lessons and 71 explicit Act0 tasks. | Strong: 50 file `action_choice` drills plus table/card taps. | Present: 22 bounded markers in W1 JSON, plus suboptimal feedback in runner options. | Present: 5 Act0 transfer tasks. | Strongest explicit repair root: 6 showdown source-repair drills. | Green. |
| W2 | Hand discipline bridge plus early table-reading pressure. | OOP is explained at first MD use (`content/worlds/world2/v1/sessions/w2.s03/session.md:10`). | Strong but concept mix is broad. | Strong: 76 action-choice JSON drills. | Present: 62 bounded markers. | Present but modest: 1 Act0 transfer task and 3 file transfer markers. | Cross-world Review exists; file source has no dedicated repair folder. | Green with minor breadth risk. |
| W3 | Position thinking / preflop framework bridge. | Position terms are active route-owned; IP not found as active term, OOP explained. | Adequate in Act0: 6 lessons / 29 explicit tasks plus source refs. File JSON is thin. | Adequate: 4 file action choices plus sourced Act0 tasks. | Present: 8 bounded markers. | Present: 1 Act0 transfer task. | Review tasks exist; no dedicated file repair folder. | Green but file density is thin. |
| W4 | Bet purpose and price. | Pot-odds appears in docs authority; live Act0 title is safe but lesson owner currently preflop. | Underlying W4 content is strong, but active Act0 binding is wrong. | Underlying file content has 123 drills / 33 action choices / 40 sizing choices. Live world card binds `_preflopFrameworkLessons`. | Underlying W4 has 43 markers. | Underlying W4 has 5 transfer markers; live W4 binding has only 1 transfer task. | Review exists; source-route mismatch weakens repair ownership. | P1 ownership mismatch. |
| W5 | Board awareness, draws, outs, street changes. | `draw`, `texture`, and `outs` are introduced with nearby beginner copy (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:3974-4225`). | Underlying board content is adequate, but active Act0 binding points to bet-purpose lessons. | Underlying W5 has 44 drills, including 33 texture classifiers and 3 outs classifiers. | Underlying W5 has 33 markers. | Strong in Act0 board lesson owner: 8 transfer tasks, but bound to W6 card. | Review exists; source-route mismatch weakens repair ownership. | P1 ownership mismatch. |
| W6 | Range thinking. | Range labels are introduced in simple bucket language, but `compression` and `polarization` appear in file index before learner expansion. | Underlying W6 content is solid: 10 sessions / 92 drills. Live W6 card points to board/draw lessons. | Good in source: 20 action choices plus classifiers. | Weakest in source markers: 2 bounded markers. | Present: 5 file transfer markers; range Act0 owner has 4 transfer tasks but is bound to W7. | Review exists; suboptimal literacy should be strengthened later. | P1 ownership mismatch; P2 suboptimal depth. |
| W7 | Visible-card range continuation. | Range bucket labels are learner-safe in the Act0 owner. | Act0 range-continuation lesson owner has 5 lessons / 35 tasks. File-source naming remains historical support evidence, but the accepted route-card contract is visible-card range continuation. | Adequate: 25 Act0 practice tasks in the W7 owner. | Present but modest in older stack source markers. | Present: 4 Act0 transfer tasks. | Review exists. | Green for current route alignment; preserve distinct W7 ownership during W6 repair. |
| W8 | Stack depth and risk. | Effective stack is explained; `SPR` is not expanded at first label. | Adequate: 4 Act0 lessons / 26 tasks; file source has 86 drills. | Adequate: 23 file action choices. | Present in file markers: 8. | Strong: 8 Act0 transfer tasks. | Review exists. | Green with P2 SPR copy risk. |
| W9 | Tournament pressure. | Risk premium is introduced in title/subtitle form; `ICM` appears in source index before expansion. | Adequate: 4 Act0 lessons / 23 tasks; file source has 86 drills. | Adequate: 23 file action choices. | Weak in file marker scan: 0 bounded markers. | Present: 6 Act0 transfer tasks. | Review exists. | Green/P2 suboptimal and abbreviation smoothing. |
| W10 | Player adjustment. | Player-type terms are understandable and supported by feedback. | Strong in file/source: 40 sessions / 325 drills; Act0 has 4 lessons / 22 tasks. | Strong: 80 file action choices. | Present but low versus size: 7 markers. | Present: 5 Act0 transfer tasks and 9 file markers. | Review exists. | Green; no blocker. |
| W11 | Real play transfer / capstone. | Variance appears in answer options with feedback; mental framing is beginner-safe. | Live Act0 content exists, but file source is shell-only. | Adequate in live Act0: 13 drills among 21 tasks. | Present in runner options, but no JSON source ledger. | Present: 5 Act0 transfer tasks. | Review exists in live tasks; file repair proof absent. | P1 source-proof fragility. |
| W12 | Mindset bridge. | Tilt is introduced as reset protocol with clear subtitle. | Live Act0 content exists, but file source is shell-only. | Adequate in live Act0: 12 drills among 20 tasks. | Present in runner options, but no JSON source ledger. | Strong: 7 Act0 transfer tasks. | Review exists in live tasks; file repair proof absent. | P1 source-proof fragility. |

## 6. Term introduction ledger

| Term | First active use | First explanation | Safe before use? | Affected worlds | Severity | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| SB / BB / BTN | Seat-order constants | W1 table/blinds route and visual seat labels | Mostly yes | W1-W3 | P2 | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart:43-55`, W1 route card `:5911-5922` |
| OOP | W2 session copy | Same line expands "out of position" | Yes | W2-W3 | None | `content/worlds/world2/v1/sessions/w2.s03/session.md:10` |
| IP | Not found as standalone active term in the scanned active content | N/A | Yes | W3 | None | Term scan over Act0 and active content found no standalone `IP`. |
| pot odds | Master-plan target, not found as live Act0 learner-facing phrase | Not active live term in scan | Not currently a learner risk | W4 | None | `docs/plan/MASTER_PLAN_v3.0.md:1015`, `:1034` |
| outs | Act0 board/draw lesson title | Subtitle says "Outs are cards that can improve a hand." | Yes | W5 | None | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart:4178-4182` |
| draw | Act0 flush/straight lesson labels | Nearby lessons show same-suit / rank-ladder pressure | Mostly yes | W5 | P2 | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart:4057-4177` |
| texture | Act0 board-reading copy and board-texture lesson | Board-texture intro and dry/wet contrast follow | Yes | W5 | None | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart:3974-4014` |
| range | Profile/skill copy and W6 bucket lessons | W6 range intro uses value/bluff/missed buckets | Mostly yes | W6-W7 | P2 | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart:4320-4373` |
| initiative | W2 lesson title | Subtitle ties it to last aggressive action | Yes | W2 | None | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart:2479-2489` |
| sizing | Internal enum and W4 sizing drills | Learner-facing W4 purpose/price content explains size intent | Yes | W4 | None | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart:35`, W4 file sample has `bet_sizing_choice_v1` |
| SPR | Act0 W8 lesson label | Subtitle explains low/high room, but abbreviation is not expanded | No, minor | W8 | P2 | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart:4811-4815` |
| ICM | `content/worlds/world8/v1/index.md` session titles | No expansion in index; Act0 route says Tournament Pressure without equations | No, minor because locked/supporting source | W9 | P2 | `content/worlds/world8/v1/index.md:3-12` |
| risk premium | W9 Act0 title | Subtitle explains medium/big stack pressure | Mostly yes | W9 | P2 | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart:5078-5089` |
| variance | W10/W11 answer option | Feedback explains short samples can mislead | Yes | W10-W11 | None | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart:18961-18970` |
| tilt | W12 lesson title | Subtitle frames one-hand reset | Yes | W12 | None | `lib/ui_v2/act0_shell/act0_shell_state_v1.dart:5729-5742` |

## 7. Rep-density ledger

Counts are evidence-backed from two sources:

- File source scan: `content/worlds/worldN/v1/**/drills/*.json`.
- Live Act0 scan: lesson/task blocks in `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`.

| World | Intro examples | Guided reps | True decisions | Suboptimal options | Contrast pairs | Transfer reps | Repair reps | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| W1 | 9 Act0 theory tasks | 48 Act0 practice tasks; 104 JSON drills | 50 JSON action choices | 22 bounded markers | 10 chains | 5 Act0 transfer tasks | 6 source-repair drills | Act0 W1: 11 lessons / 71 tasks; JSON scan W1. |
| W2 | 5 Act0 theory tasks | 18 Act0 practice tasks; 135 JSON drills | 76 JSON action choices | 62 bounded markers | 8 chains | 1 Act0 transfer; 3 file markers | Bounded review, no dedicated source-repair folder | Act0 W2: 6 lessons / 31 explicit tasks plus refs; JSON scan W2. |
| W3 | 3 Act0 theory tasks | 15 Act0 practice tasks; 18 JSON drills | 4 JSON action choices plus sourced preflop tasks | 8 bounded markers | 14 chains | 1 Act0 transfer | Review tasks, no dedicated source-repair folder | Act0 W3: 6 lessons / 29 tasks plus refs; JSON scan W3. |
| W4 | 7 underlying bet-purpose theory tasks | 19 underlying Act0 practice tasks; 123 JSON drills | 33 action + 40 sizing choices | 43 bounded markers | 3 chains | 5 file markers | Review tasks | Active W4 card binds `_preflopFrameworkLessons`, so density is not presented under correct owner. |
| W5 | 6 board/draw theory tasks | 22 board/draw Act0 practice tasks; 44 JSON drills | 33 texture + 3 outs classifiers | 33 bounded markers | 8 chains | 8 Act0 transfer tasks | Review tasks | Active W5 card binds `_betPurposePriceLessons`, so board density is offset. |
| W6 | 5 range theory tasks | 20 range Act0 practice tasks; 92 JSON drills | 20 action + 12 range classifiers | 2 bounded markers | 6 chains | 4 Act0 transfer; 5 file markers | Review tasks | Active W6 card binds `_boardDrawsLessons`, so range density is offset. |
| W7 | 5 visible-card/range-continuation Act0 theory tasks; older stack-depth file-source evidence remains historical support | 25 range-continuation Act0 practice tasks; older file drills are not the current W7 route-owner proof | Route-card drills are adequate for locked preview; older file source has 23 action choices under historical naming | Older file-source markers are not the current route-owner proof | 4 older file-source chains | 4 Act0 transfer | Review tasks | Active W7 card binds `_rangeThinkingLiteLessons` and is coherent with accepted visible-card range-continuation tests; do not duplicate this owner onto W6 without a distinct W6 owner decision. |
| W8 | 4 Act0 theory tasks | 16 Act0 practice tasks; 86 JSON drills | 23 JSON action choices | 0 marker scan in tournament source if mapped by old offset; 8 in stack source | 4 chains | 8 Act0 transfer | Review tasks | Act0 W8: 4 lessons / 26 tasks; JSON scan world7/world8. |
| W9 | 4 Act0 theory tasks | 13 Act0 practice tasks; 86 JSON drills | 23 JSON action choices | 0 bounded markers in tournament source scan | 4 chains | 6 Act0 transfer | Review tasks | Act0 W9: 4 lessons / 23 tasks; JSON scan world8. |
| W10 | 4 Act0 theory tasks | 13 Act0 practice tasks; 325 JSON drills | 80 JSON action choices | 7 bounded markers | 3 chains | 5 Act0 transfer; 9 file markers | Review tasks | Act0 W10: 4 lessons / 22 tasks; JSON scan world10/tracks. |
| W11 | 4 Act0 theory tasks | 12 Act0 practice tasks | 13 Act0 drill-phase tasks | Bounded estimates only; no JSON ledger | Runner option contrasts exist | 5 Act0 transfer tasks | 4 review tasks | Act0 W11: 4 lessons / 21 tasks; file source has no JSON drills. |
| W12 | 4 Act0 theory tasks | 12 Act0 practice tasks | 12 Act0 drill-phase tasks | Bounded estimates only; no JSON ledger | Runner option contrasts exist | 7 Act0 transfer tasks | 4 review tasks | Act0 W12: 4 lessons / 20 tasks; file source has no JSON drills. |

## 8. Seam findings

| Seam | Finding |
| --- | --- |
| W1->W2 | No blocker. W1 table/action foundation and W2 hand discipline/table-reading bridge are dense. Watch breadth: W2 currently carries showdown, position, initiative, texture, outs, price, and chains. |
| W2->W3 | No blocker. OOP is explained at first file use, and W3 position/preflop material has transfer exposure. |
| W3->W4 | P1. W4 route title is Bet Purpose / Price, but active W4 lesson owner is preflop framework. Learner expects bet purpose and receives preflop frame material. |
| W4->W5 | P1. W5 route title is Board Awareness, but active W5 lesson owner is bet purpose/price. This delays board vocabulary after the route claims it. |
| W5->W6 | P1. W6 route title is Range Thinking, but active W6 lesson owner is board/draws. This makes range vocabulary handoff unreliable. |
| W6->W7 | No W7 route-card mismatch in the current normalized contract. W6 currently displays Range Thinking but binds board/draw lessons, while W7 correctly displays Visible Cards Change Ranges and binds the visible-card range-continuation owner. The next repair must preserve W6/W7 as distinct range-related steps rather than duplicating one lesson list across both worlds. |
| W7->W8 | No P0. W8 Stack Depth live lessons exist and include transfer tasks. Existing master-plan notes say W7-W8 lift added stronger density and decision floors (`docs/plan/MASTER_PLAN_v3.0.md:1275-1286`). |
| W8->W9 | No P0. Master plan records W8->W9 as release-playable after W9 density and seam locks (`docs/plan/MASTER_PLAN_v3.0.md:1242-1245`). Minor term risk remains around ICM/SPR abbreviation smoothing. |
| W9->W10 | No P0. Master plan records W9->W10 as release-playable (`docs/plan/MASTER_PLAN_v3.0.md:1246-1247`). W10 content is dense. |
| W10->W11 | No P0. Master plan records W10->W11 as release-playable (`docs/plan/MASTER_PLAN_v3.0.md:1248-1249`). W11 live Act0 tasks exist, but file-source drill proof is weak. |
| W11->W12 | No P0. Master plan records W11->W12 as release-playable (`docs/plan/MASTER_PLAN_v3.0.md:1250-1251`). W12 live Act0 tasks exist, but file-source drill proof is weak. |

## 9. P0 findings

None.

## 10. P1 findings

### P1-1: Act0 W4-W6 lesson-owner binding offset

- Root-cause class: active route/content ownership mismatch; vocabulary handoff risk.
- Affected worlds: W4, W5, and W6. W7 is a preservation boundary, not part of the mismatch.
- Learner impact: each affected world card already displays the current canonical normalized job, but the lesson list teaches the previous/source-offset job. This can make term introduction and world-to-world vocabulary handoff feel arbitrary even when the underlying content is good.
- Exact evidence:
  - `world_4` title `Bet Purpose / Price` binds `_preflopFrameworkLessons` (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:5952-5964`).
  - `world_5` title `Board Awareness` binds `_betPurposePriceLessons` (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:5966-5978`).
  - `world_6` title `Range Thinking` binds `_boardDrawsLessons` (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:5980-5992`).
  - `world_7` title `Visible Cards Change Ranges` binds `_rangeThinkingLiteLessons` and is coherent with accepted W7 visible-card range-continuation tests (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:5994-6007`).
  - Master-plan W4-W6 route jobs require Bet Purpose / Price, Board Awareness, and Range Thinking respectively, and mark the old W4 Preflop Framework / W5 Bet Purpose / W6 Board Awareness wording as deprecated (`docs/plan/MASTER_PLAN_v3.0.md:1015-1017`, `:1034-1036`, `:1288-1314`).
- Smallest safe bounded repair wave: Act0 W4-W6 lesson-owner binding alignment repair. Keep the displayed W4-W6 titles/subtitles/unlock promises aligned to the current normalized jobs; move W4 to the bet-purpose owner, W5 to the board/draw owner, and W6 to the intended primary Range Thinking owner without duplicating or emptying W7's visible-card range-continuation owner. Preserve lock state, preserve monetization boundary, preserve W13+ closure, and update only focused route-title/lesson-owner tests.
- Files likely involved:
  - `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
  - focused Act0 route/title tests under `test/ui_v2/`
  - possibly `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart` only if localized title-bound copy is touched.
- Tests that should later lock the fix:
  - focused Act0 world-card lesson-owner mapping test for W4-W7 that proves W4-W6 move to the right owners and W7 remains distinct;
  - focused W6/W7 lock-state negative control;
  - title-to-first-lesson semantic assertion for W4-W7;
  - `flutter analyze`;
  - `./tools/fast_loop_world1_v1.sh` if admitted by implementation prompt.
- What must not be changed:
  - Do not author new content.
  - Do not open W13+.
  - Do not unlock W7-W12.
  - Do not touch Modern Table, screenshots, mascot assets, or monetization behavior.

### P1-2: W11/W12 live content lacks file-backed drill/source proof

- Root-cause class: source-proof fragility; validator/readiness evidence gap.
- Affected worlds: W11 and W12.
- Learner impact: the live Act0 route has real W11/W12 lessons, but active file roots do not carry the same drill-level evidence as W1-W10. Future audits, validators, and repairs can undercount or misclassify W11/W12, and repair/transfer claims are harder to lock outside Dart.
- Exact evidence:
  - Act0 W11 binds `_realPlayTransferLessons` (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:6050-6062`) and W12 binds `_mindsetBridgeLessons` (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:6064-6077`).
  - Live Dart scan: W11 has 4 lessons / 21 explicit tasks / 5 transfer tasks; W12 has 4 lessons / 20 explicit tasks / 7 transfer tasks.
  - Active file scan: `content/worlds/world11/v1/` and `content/worlds/world12/v1/` have no `sessions/**/drills/*.json` files.
- Smallest safe bounded repair wave: source-proof ledger only or source-alignment audit for W11/W12 that maps live Act0 task IDs to the active content root without authoring new content. If implementation is later admitted, add validator-readable metadata or source index entries rather than expanding lesson count.
- Files likely involved:
  - `content/worlds/world11/v1/index.md`
  - `content/worlds/world12/v1/index.md`
  - possible content source metadata/index only, not runtime.
- Tests that should later lock the fix:
  - content-source reachability guard for W11/W12 task IDs;
  - source proof validator or lightweight grep-based check;
  - `git diff --check`.
- What must not be changed:
  - Do not author new W11/W12 lessons in this wave.
  - Do not change Act0 runtime routes.
  - Do not make launch/10-out-of-10 claims from metadata-only proof.

## 11. P2 / deferred findings

1. Expand `SPR` on first learner-facing use or retitle the phase label to `Room / commitment` while keeping the abbreviation as secondary later (`lib/ui_v2/act0_shell/act0_shell_state_v1.dart:4811-4815`).
2. Smooth `ICM` in supporting file indices; prefer `Tournament pressure / ICM` only after the first plain-English explanation (`content/worlds/world8/v1/index.md:3-12`).
3. W6/W9/W10 suboptimal-option marker density is lower than decision density in file scans. This is useful future reinforcement, but not a launch blocker while live runner options already include suboptimal feedback quality in places.
4. W2 is broad for a Hand Discipline world. It is not a blocker because current route content is dense, but future cleanup could split table-reading support from hand-discipline core if route complexity rises.

## 12. Recommended next implementation wave

Recommend exactly one wave:

`Act0 W4-W6 lesson-owner binding alignment repair`

Bounded DoD:

1. `world_4` keeps its current displayed Bet Purpose / Price job and receives the bet-purpose lesson owner.
2. `world_5` keeps its current displayed Board Awareness job and receives the board/draw lesson owner.
3. `world_6` keeps its current displayed Range Thinking job and receives the intended primary Range Thinking owner.
4. `world_7` remains coherent as Visible Cards Change Ranges / visible-card range continuation and is not duplicated, emptied, unlocked, or retitled by the W4-W6 repair.
5. W7-W12 lock state remains unchanged.
6. Preflop Framework remains reachable only through its intended canonical bridge/route, not as W4 ownership.
7. No new content, no screenshots, no W13+, no visual work, no monetization behavior change.
8. Focused tests lock title-to-lesson-owner mapping, W6/W7 distinct ownership, and lock-state negative controls.

This wave has the clearest learner-visible EV because it prevents existing good content from being introduced under the wrong world promise.

## 13. Explicit non-goals

- No content authoring.
- No runtime route expansion.
- No W13+ opening.
- No Modern Table work.
- No mascot or asset work.
- No screenshots.
- No monetization or paywall changes.
- No broad speculative backlog.
- No attempt to re-score all readiness ledgers.
- No archive/donor-root sourcing.

## 14. Validation

Performed:

- Initial artifact git state check: branch `main`, `HEAD` and `origin/main` both `7aa217e132743fdd867f548ad3727db52909316f`, ahead/behind `0 0`, clean worktree before artifact creation.
- Correction git state check: branch `codex/volume1-content-depth-audit-v1`, `HEAD` and `origin/main` both `7aa217e132743fdd867f548ad3727db52909316f`, ahead/behind `0 0`, with only this audit artifact changed before commit.
- Missing-template check: `docs/plan/SEAM_TRANSITION_AUDIT_TEMPLATE_v1.md` absent.
- Scoped Graphify query for active Volume I content sources.
- Active source scans over `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`, `content/world1_act0_*/v1/`, and `content/worlds/world1..world12/v1/`.
- Structured JSON drill counts for W1-W10 and live Act0 task counts for W1-W12.
- Current normalized W4-W7 correction pass: confirmed W4 = Bet Purpose / Price, W5 = Board Awareness, W6 = Range Thinking, and W7 = Visible Cards Change Ranges / visible-card range continuation.
- Current correction validation: no remaining recommendation to change correct W4-W6 displayed titles; no remaining recommendation to duplicate W6/W7 lesson ownership; W11/W12 source-proof fragility remains a separate P1.

Not run:

- Flutter tests, release gates, visual tests, or screenshot capture. This was an audit-only docs artifact, not an implementation or runtime change.

## 15. Final route recommendation

Do not open W13+ and do not start broad content expansion. Run the bounded Act0 W4-W6 lesson-owner binding alignment repair first. After that, reassess whether W11/W12 need a source-proof metadata wave; do not mix that with the W4-W6 binding repair.
