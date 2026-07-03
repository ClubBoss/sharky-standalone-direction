# Mascot Production Feasibility & Migration Audit v1

Date: 2026-07-03

Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`

Starting HEAD: `08bb7bad`

Mode: docs-only technical feasibility audit; no production code, test, asset,
runtime mapping, screenshot, motion, or design-direction change

Primary inputs:

- live Act0 Sharky source, tests, asset manifest, and screenshot-lane owner;
- `docs/_reviews/sharky_character_growth_evidence_pack_v1.md`;
- local Claude Design PDF, `Sharky Mascot Strategy Review.pdf`;
- context capsules `ACTIVE_ROUTE_CAPSULE_v1` and `VISUAL_PROOF_CAPSULE_v1`.

## 1. Verdict

`mascot_feasibility_audit_complete`

The current mascot runtime is technically migratable without deciding the final
visual route in this wave. Runtime ownership, fallback behavior, direction-
neutral asset constraints, renderer-normalization options, route-specific
migration effort, evidence gates, rollback checkpoints, and P1-P4 feasibility
gaps are documented below.

This audit does not lock Route B, Route C, or a B/C hybrid. Claude Design's PDF
provisionally recommends Route B, but this artifact intentionally treats that
as design-review evidence rather than production authorization. The only
implementation-safe conclusion is that all future routes need a single on-
identity runtime mascot system, fallback parity, renderer normalization, and
fresh deterministic evidence before Sharky micro-animation can resume.

## 2. Decision status

- Mascot remains strategically valuable.
- Shark remains the leading metaphor.
- Superseded strategic-direction note: `Sharky Mascot Direction Correction v2`
  selects `DUAL_REGISTER_ICONIC_COMPANION_SELECTED`.
- Claude Design's earlier major-evolution recommendation remains
  historical/reference evidence, not production authorization.
- Final visual execution has not happened in repo authority.
- The serious-premium shark trajectory is classified as
  `superseded_visual_exploration_serious_premium_shark_v1`.
- Current PNG art must not be preserved by implementation convenience.
- Current art must not be discarded by implementation convenience.
- Sharky Micro-Animations remain `BLOCKED`.
- This audit is technical preparation only.

## 3. Runtime ownership inventory

### Assets and registry

| Owner | File / symbol | Runtime role | Status | Size / mapping | Production/test | Tests/evidence |
| --- | --- | --- | --- | --- | --- | --- |
| Flutter asset manifest | `pubspec.yaml` | Includes active PNG folder plus legacy SVG assets | production bundle | `assets/images/mascot/`, `assets/mascot/poker_shark_*.svg`, `assets/brand/mascot.svg` | production | `act0_sharky_identity_contract_v1_test.dart`, evidence pack |
| Active PNG set | `assets/images/mascot/sharky_neutral.png` | `neutral` mood asset | active primary | 298x461 source | production | asset existence/state tests |
| Active PNG set | `assets/images/mascot/sharky_thinking.png` | `coach` / thinking mood asset | active primary | 357x487 source | production | asset existence/state tests |
| Active PNG set | `assets/images/mascot/sharky_repair.png` | `repair` mood asset | active primary | 373x462 source | production | asset existence/state tests; wrong-feedback caveat |
| Active PNG set | `assets/images/mascot/sharky_happy.png` | `confirm` and `improve` mood asset | active primary | 414x477 source | production | companion-state tests |
| Active PNG set | `assets/images/mascot/sharky_celebrate.png` | `milestone` mood asset | active primary | 451x489 source | production | companion-state tests |
| Inactive PNG | `assets/images/mascot/sharky_sleeping.png` | no active semantic state | unused/future-only | 371x389 source | bundled, not active | evidence pack exclusion |
| Limited-active SVG | `assets/mascot/poker_shark_idle.svg` | Welcome idle/neutral/happy/repair SVG; PNG fallback for neutral/happy/repair | legacy direction / limited production usage / do not extend | 320x200 source; Welcome renders at 64/80dp tile | production primary in Welcome; degraded fallback elsewhere | source trace |
| Limited-active SVG | `assets/mascot/poker_shark_thinking.svg` | Welcome coach SVG; PNG fallback for thinking | legacy direction / limited production usage / do not extend | 320x200 source; Welcome renders at 64/80dp tile | production primary in Welcome; degraded fallback elsewhere | source trace |
| Limited-active SVG | `assets/mascot/poker_shark_celebrate.svg` | Welcome celebrate SVG; PNG fallback for celebrate | legacy direction / limited production usage / do not extend | 320x200 source; Welcome renders at 64/80dp tile | production primary in Welcome; degraded fallback elsewhere | source trace |
| Brand SVG | `assets/brand/mascot.svg` | brand inventory only | production-inactive runtime | 64x64 source | bundled, not active runtime | evidence pack |

### Resolver and renderer owners

| Owner | File / symbol | Responsibility | Runtime dependency | Production/test |
| --- | --- | --- | --- | --- |
| State vocabulary | `Act0SharkyCompanionStateV1` in `act0_sharky_coach_phrase_contract_v1.dart` | Six semantic states: `neutral`, `coach`, `repair`, `confirm`, `improve`, `milestone` | phrase context evidence | production |
| State resolver | `act0ResolveSharkyCompanionStateV1` | Maps structured evidence to semantic state; never parses copy | `Act0SharkyCoachPhraseContextV1` | production |
| Tier resolver | `act0SharkyCoachTierForWorldNumberV1` | Foundation W1-W4, Developing W5+ | world number | production |
| Growth resolver | `Act0SharkyGrowthStageV1`, `act0SharkyGrowthStageForWorldNumberV1` | Foundation/Developing visual axis | tier resolver | production |
| Mood resolver | `act0SharkyMoodForCompanionStateV1` in `act0_sharky_presence_v1.dart` | Maps six states onto five PNG moods | state resolver | production |
| Asset registry | `act0SharkyCompanionAssetForMoodV1` | Maps mood to PNG path | mood resolver | production |
| Tone resolver | `act0SharkyToneForMoodV1` | Maps mood to frame/tone color | mood | production |
| Accent resolver | `act0SharkyCompanionStateHasAccentRingV1` | Adds accent ring for `improve` and `milestone` | semantic state | production |
| Shared frame | `_SharkyMascotFrameV1` | Container, padding, frame/ring/growth ring | mood, tone, size, ring, growth stage | production |
| Primary renderer | `Act0SharkyPresenceMascotV1` | PNG loading and one-shot mascot presence motion | mood/tone/size | production |
| Fallback renderer | `_SharkyMascotAssetFallbackV1` | SVG fallback on pending/failed PNG frame | mood/tone/size | production fallback |
| Last-resort fallback | `_SharkyMascotLetterFallbackV1` | Letter `S` while SVG placeholder renders | tone/size | production degraded placeholder |
| Small cue renderer | `Act0SharkyMascotV1` in `act0_lesson_runner_shell_v1.dart` | Feedback/runner small mascot wrapper with scale/tilt tween | mood/tone/size | production |

### Consumer inventory

| Consumer | File / symbol | Sharky surface | Rendered size | State/growth | Primary/fallback | Callback/route dependency | Tests/evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Welcome orientation | `Act0WelcomeShellV1` | `Act0SharkyGuideCardV1` and `_WelcomeSharkyPresenterTileV1` | Guide 72/92dp; presenter 64/80dp | neutral/coach, Foundation | Guide uses PNG primary; presenter uses legacy SVG primary | Welcome placement/handoff route | Welcome tests/screens |
| Welcome presenter | `_welcomePresenterAssetForMoodV1` | mood-to-SVG map | 64/80dp tile | thinking/celebrate/idle fallback grouping | SVG primary | no callback | source trace |
| Home identity row | `_HomeHeroHeaderV1` / `_HomeIdentityRowV1` | compact mascot beside course identity | 38dp frame, 26dp art size | authored `Act0SharkyCueV1` mood; no growth/state resolver | PNG primary with SVG fallback | Home route state | semantic consistency test confirms Home not migrated to companion-state/growth |
| Learning rail / Learn guide | `_LearnCoachLineV1` and `Act0LearningPathShellV1` | text coach line and guide-card support | icon-like 34dp area for line owner; GuideCard admitted 72/92dp | explicit mood, no persistent growth unless GuideCard caller passes it | mostly text/icon; GuideCard uses PNG primary | Learn path | focused UI tests |
| Feedback result | `Act0FeedbackShellV1` | small mascot in result header | 30/34/40dp depending compact/refined mode | authored mood from runner feedback | PNG primary via `Act0SharkyMascotV1`, SVG fallback possible | Continue/back callbacks | feedback rhythm and visual consistency tests |
| Session Summary | `_BlockSummaryScreenV1` in `act0_lesson_runner_shell_v1.dart` | companion bubble and payoff hero Sharky | 64/68dp mascot | state priority milestone > improve > confirm > repair > neutral; growth from world number | PNG primary, SVG fallback possible | next-action/summary route | companion state/growth/summary tests |
| Repair outcome consumer | `Act0RepairOutcomeConsumerV1` | supplies proof/receipt flags and improvement line | non-visual data owner | improvement/confirm flags | production data | repair projection inputs | repair outcome tests |
| Improvement observation | `Act0SharkyImprovementObservationProjectionV1` | source-backed later-transfer observation | non-visual data owner | `laterImprovementObserved` -> `improve` | production data | fix-proof projection | improvement tests |
| Review shell | `act0_review_shell_v1.dart` | repair coach text line | text only | review repair phrase | no mascot renderer | Review callback | review tests |
| Play shell | `act0_play_shell_v1.dart` | practice current-fix coach text | text only | repair phrase | no mascot renderer | Practice callback | play/review tests |
| Profile shell | `act0_profile_shell_v1.dart` | neutral mascot in proof identity card | 56dp art area | neutral mood only; no growth/state resolver | PNG primary, SVG fallback possible | Profile route | semantic consistency guard |
| Milestone/completion | `worldCompletionPayoffLabel`, `bandTransitionIdentityLabel`, `_SessionSummaryPayoffHeroV1` | completion copy plus Session Summary companion | 64dp when shown in payoff hero | `milestone`, growth by world number | PNG primary, SVG fallback possible | completion route state | motion/payoff tests; natural screenshot gap |
| Screenshot capture | `tools/act0_real_text_surface_capture_v1.dart` | deterministic runtime evidence lanes | compact phone lane | authored `Act0SharkyCueV1`; no invented states | existing capture lanes only | CLI lane scripts | `screen_review_fast_v1.sh` lanes |
| Test-only fixtures | focused `test/ui_v2/act0_sharky_*` files | state/growth/consumer proof | widget/test sizes | all semantic states and Foundation/Developing | structural/test-only | no runtime route | accepted tests |

## 4. Fallback truth

### Why Welcome uses legacy SVG

Welcome has a separate presenter tile, `_WelcomeSharkyPresenterTileV1`, whose
child is `SvgPicture.asset(_welcomePresenterAssetForMoodV1(mood))`. This is not
the shared PNG primary renderer. It directly maps:

- `thinking` -> `assets/mascot/poker_shark_thinking.svg`;
- `celebrate` -> `assets/mascot/poker_shark_celebrate.svg`;
- `happy`, `neutral`, `repair` -> `assets/mascot/poker_shark_idle.svg`.

Classification: `stale legacy dependency` and `normal production primary` for
that specific Welcome presenter surface. It is limited active production usage,
not test-only and not unused.

### PNG load failure path

`Act0SharkyPresenceMascotV1` normally renders `Image.asset` from
`act0SharkyCompanionAssetForMoodV1`. If the image is pending in `frameBuilder`
or fails in `errorBuilder`, it returns `_SharkyMascotAssetFallbackV1`, which
renders `SvgPicture.asset(_mascotVectorFallbackForMood(mood))`. That fallback
uses the same SVG grouping as Welcome:

- `thinking` -> `poker_shark_thinking.svg`;
- `celebrate` -> `poker_shark_celebrate.svg`;
- `neutral`, `happy`, `repair` -> `poker_shark_idle.svg`.

If the SVG is still loading, the SVG placeholder is `_SharkyMascotLetterFallbackV1`
with a letter `S`. There is no custom error handler after the SVG placeholder;
therefore complete SVG failure is a degraded visual risk that should be tested
before migration, but this audit does not reproduce or repair it.

Classification:

- primary PNG path: `normal production primary`;
- SVG on PNG pending/error: `degraded production fallback`;
- letter `S` placeholder: `degraded loading fallback`;
- Welcome SVG direct use: `stale legacy dependency` plus `normal production primary`
  for that one surface;
- wrong-feedback screenshot exposing SVG: `deterministic-test artifact` /
  `screenshot-tooling artifact` until later reproduction proves otherwise.

### Wrong-feedback evidence caveat

The prior evidence pack reports that wrong-feedback capture reproducibly shows
the SVG fallback rather than the repair PNG. Source confirms that this can
happen when the PNG frame is not synchronously available or errors during a
deterministic capture. The fallback is real production code, so it is possible
in production under asset-load failure, but the repeated screenshot appearance
is best classified as capture/test-environment exposure of the degraded path,
not proof that production normally chooses the legacy asset.

### Layout and semantic parity

The fallback stays within the same widget size, but it changes visual direction,
shape grammar, and perceived character identity. Semantic state does not change:
the same mood/state/tone remains active in the widget tree. Layout risk is
bounded by the same container, but visual identity parity is not satisfied.

## 5. Direction-neutral asset contract

Any winning direction must satisfy this technical contract without encoding a
style decision:

- Semantic coverage:
  - `neutral`;
  - `coach`;
  - `repair`;
  - `confirm`;
  - `improve`;
  - `milestone`;
  - one on-identity fallback.
- Allowed architecture:
  - five or six primary expressions is acceptable;
  - `confirm` and `improve` may share an asset only if the final design
    explicitly accepts frame/copy as the distinction;
  - growth must remain an axis separate from current semantic state.
- Supported UI tiers:
  - 16dp brand-presence tier;
  - 30/34/40dp feedback tier;
  - 38/56dp compact identity tier;
  - 64/68dp Session Summary tier;
  - 72/92dp GuideCard / Welcome tier;
  - marketing/export sizes if supplied outside runtime.
- Source resolution:
  - raster sources must exceed the largest runtime display size by at least 3x;
  - vector fallback must remain sharp at 16-92dp;
  - assets must support transparent backgrounds.
- Safe bounds:
  - stable alpha padding on all sides;
  - no crop-dependent expression;
  - no meaningful pose element outside the safe box;
  - safe silhouette width must cover the widest admitted state.
- Metadata:
  - optical anchor point;
  - baseline or groundline;
  - visual center;
  - apparent-scale target / intended occupancy;
  - max silhouette width;
  - fallback equivalence group.
- Runtime requirements:
  - one canonical asset registry;
  - versioned names that can coexist during migration;
  - forced-fallback test path;
  - reduced-motion final static state contains all information;
  - no information conveyed only by animation.
- Accessibility:
  - semantic label remains generic (`Sharky mascot`) unless product copy needs
    more specificity;
  - color/frame/copy carry state precision at small sizes;
  - reduced-motion must bypass or settle all mascot motion.

This contract deliberately does not specify art style, proportions, expression,
palette, silhouette design, or brand DNA. Its active strategic-direction input
is now `DUAL_REGISTER_ICONIC_COMPANION_SELECTED`; exact visual execution still
requires the controlled Claude Design board described in
`docs/_reviews/sharky_mascot_direction_correction_v2.md`.

## 6. Renderer normalization options

| Option | Description | Complexity | Testability | Regression risk | Asset burden | Route B | Route C/hybrid |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A. Renderer metadata per asset | Keep source canvases as delivered; add per-asset scale, anchor, baseline, and safe-bounds metadata in a registry | medium | high; pure resolver tests plus widget geometry tests | medium, because runtime math changes all mascot surfaces | low-medium; art can stay varied if metadata is accurate | strong | strong |
| B. Normalized source canvases | Require all final assets to ship on the same canvas, anchor, baseline, and apparent scale | low runtime / medium asset ops | medium; existence/dimension checks catch most issues | low runtime, medium asset-production drift risk | high; requires disciplined asset export | strong if evolution is controlled | strong if refresh pipeline is clean |
| C. Canonical container with per-asset optical corrections | Keep one runtime box and add small per-asset optical corrections only where needed | medium-low | high; correction table is small and reviewable | low-medium; minimizes broad renderer churn | medium; assets still need approximate discipline | strong | strong |
| D. Existing-compatible wrapper seam | Introduce a `MascotRenderSpec` seam behind existing `Act0SharkyPresenceMascotV1`/frame callers without changing callers first | medium | high; seam can be tested before visual migration | low if default specs match current behavior | low initially, rises after final assets | strong pre-lock prep after design approval | strong pre-lock prep after design approval |

Smallest reusable seam: a direction-neutral render spec that resolves, per
semantic asset, `{assetPath, fallbackPath, scale, opticalCenter, baseline,
maxSilhouetteWidth, reducedMotionFinal}`. It can sit behind the current asset
registry and support either normalized source canvases or metadata-corrected
canvases after design lock.

This audit does not recommend a final implementation option. The safe technical
finding is that motion should not start until apparent scale, optical anchor,
baseline, and fallback parity are explicit and testable.

## 7. Route B feasibility

Assumption: current identity DNA is partly retained, with approximately 5-6
evolved expressions, one on-identity fallback, bounded Developing treatment,
and renderer normalization.

- Affected files:
  - `assets/images/mascot/**` or new versioned mascot folder;
  - `assets/mascot/**` fallback folder;
  - `pubspec.yaml`;
  - `act0_sharky_presence_v1.dart`;
  - `act0_welcome_shell_v1.dart`;
  - focused tests under `test/ui_v2/act0_sharky_*`;
  - screenshot lane evidence references.
- New/replaced assets:
  - 5-6 evolved expressions;
  - one stable on-identity vector fallback;
  - optional Developing base treatment only if design lock requires it.
- Mapping changes:
  - preserve state contract unless Claude explicitly changes state architecture;
  - likely distinguish `improve` from `confirm`;
  - retire legacy SVG mappings only after fallback replacement proves safe.
- Renderer work:
  - add normalization metadata or enforce normalized export canvas;
  - verify 30/34/40/64/68/72/92dp surfaces.
- Fixture/test changes:
  - asset existence/mapping tests;
  - forced fallback test;
  - Welcome migration tests;
  - state/growth consumer tests;
  - screenshot-lane refresh.
- Migration complexity:
  - medium; existing product contracts can remain mostly intact.
- Rollback:
  - keep current PNGs and SVG fallback in bundle until new primary and fallback
    are both proven;
  - version paths so registry can revert without deleting assets.
- Main risks:
  - accidental preservation of weak current silhouette;
  - conflicting old/new identity during partial migration;
  - per-asset scale/anchor drift.
- Likely waves:
  - 4-6 implementation waves after design lock.

## 8. Route C feasibility

Assumption: full shark-character refresh; product semantic contracts mostly
remain, but state architecture may use fewer or different asset variants.

- Affected files:
  - same runtime owners as Route B;
  - stronger likelihood of changing state-to-asset mapping tests;
  - possible new asset namespace and migration aliases.
- New/replaced assets:
  - full primary mascot family;
  - one on-identity vector fallback;
  - final reduced-motion static assets if animation introduces non-static
    source states later.
- Mapping changes:
  - state contract may stay while expression count changes;
  - Welcome and fallback still must migrate before motion;
  - legacy SVG removal sequence unchanged.
- Renderer work:
  - normalization likely mandatory because old source geometry is irrelevant;
  - route should not rely on current PNG dimensions.
- Fixture/test changes:
  - broader visual evidence regeneration;
  - asset contract tests from scratch;
  - Human QA likely has higher recognition-risk weight.
- Migration complexity:
  - high; larger brand-recognition and QA exposure.
- Rollback:
  - require feature-branch/versioned registry fallback to previous system;
  - keep previous primary/fallback assets until new system passes all gates.
- Main risks:
  - resetting user recognition;
  - new art not matching existing warm/proof-safe tone;
  - larger screenshot churn across first impressions and feedback.
- Likely waves:
  - 6-8 implementation waves after design lock.

## 9. B/C hybrid feasibility

Assumption: retain shark/name/emotional role and only explicitly approved DNA;
redesign character system from first principles while preserving runtime product
contracts where valuable.

- Affected files:
  - same as B/C;
  - likely adds a compatibility matrix documenting which DNA is retained.
- New/replaced assets:
  - new primary family;
  - one on-identity vector fallback;
  - optional retained-DNA references for side-by-side recognition tests.
- Mapping changes:
  - keep semantic state names unless design lock proves they should collapse;
  - may change asset count while preserving resolver outputs.
- Renderer work:
  - same as Route C: final system needs explicit scale/anchor/baseline contract.
- Fixture/test changes:
  - same as C plus recognition continuity evidence.
- Migration complexity:
  - medium-high; less risky than full refresh only if retained DNA is explicit.
- Rollback:
  - versioned registry and old-system retention until post-migration evidence
    passes.
- Main risks:
  - ambiguous design lock causing implementation to preserve or discard DNA
    inconsistently;
  - two partial identities shipping at once.
- Likely waves:
  - 5-7 implementation waves after design lock.

## 10. Shared versus direction-dependent work

| Classification | Work item | Rationale |
| --- | --- | --- |
| `safe_to_prepare_before_design_lock` | Runtime owner inventory | purely factual, no art direction |
| `safe_to_prepare_before_design_lock` | Acceptance-test plan | contract-level, not art-specific |
| `safe_to_prepare_before_design_lock` | Migration/rollback order | prevents mixed identities in any route |
| `safe_to_prepare_before_design_lock` | Forced-fallback proof requirements | same for all routes |
| `must_wait_for_design_lock` | final asset names and folder structure | tied to final asset family/version |
| `must_wait_for_design_lock` | per-asset anchor/scale/baseline values | depends on delivered art |
| `must_wait_for_design_lock` | improve/confirm asset distinction | design choice |
| `must_wait_for_design_lock` | Developing visual treatment | design choice |
| `must_wait_for_design_lock` | fallback art | final identity choice |
| `shared_after_design_lock` | canonical registry migration | needed by all routes after assets exist |
| `shared_after_design_lock` | Welcome migration | needed by all routes |
| `shared_after_design_lock` | screenshot regeneration | needed by all routes |
| `route_b_only` | continuity guard against over-refresh | only relevant if evolving current DNA |
| `route_c_or_hybrid_only` | recognition/continuity validation against old Sharky | higher-risk full/hybrid redesign |
| `obsolete_after_migration` | `poker_shark_*.svg` runtime fallback | should not remain runtime fallback after on-identity replacement |
| `obsolete_after_migration` | Welcome direct SVG presenter | should be replaced by the canonical renderer |
| `obsolete_after_migration` | `sharky_sleeping.png` as candidate runtime state | inactive/outlier unless explicitly redesigned |

## 11. Safe migration sequence

1. Final art-direction lock.
   - Rollback checkpoint: no code/assets change before this point.
2. Asset delivery and validation.
   - Verify source dimensions, transparency, safe bounds, metadata, and fallback
     coverage.
   - Rollback: reject asset packet without touching runtime.
3. Renderer contract.
   - Add tested direction-neutral normalization seam or normalized canvas
     contract.
   - Rollback: default specs render current behavior.
4. Primary asset registration.
   - Add versioned registry entries without deleting old assets.
   - Rollback: flip registry back to previous primary family.
5. Fallback replacement.
   - Add on-identity fallback vector and forced-fallback tests.
   - Rollback: keep old SVG fallback until new fallback passes.
6. Welcome migration.
   - Replace direct legacy SVG presenter with canonical identity renderer.
   - Rollback: retain old presenter until screenshot evidence passes.
7. State mapping.
   - Apply final semantic-state-to-asset map.
   - Rollback: revert registry map, not callers.
8. Growth mapping.
   - Apply final Foundation/Developing treatment if changed.
   - Rollback: return to frame-only growth.
9. Legacy reference removal.
   - Remove `poker_shark_*.svg` runtime references only after primary and forced
     fallback tests pass.
   - Rollback: do not delete old assets until one release/stabilization gate is
     accepted.
10. Screenshot/evidence regeneration.
    - Refresh supported deterministic lanes; use limitation notes for
      uncapturable states.
    - Rollback: keep previous evidence labeled stale, not current.
11. Reduced-motion verification.
    - Confirm static final state is complete and no motion-only meaning exists.
    - Rollback: disable mascot motion while keeping static identity.
12. Micro-animation admission.
    - Only after final assets, renderer normalization, fallback parity, Welcome
      migration, and reduced-motion proof pass.

No legacy asset may be removed before replacement and fallback coverage are
proven.

## 12. Test/evidence plan

| Target | Proof type |
| --- | --- |
| every semantic state | resolver tests, asset mapping tests, companion avatar widget tests |
| every admitted size tier | widget geometry tests and deterministic screenshots where supported |
| Foundation/Developing | resolver tests, frame/ring widget tests, supported W5+ capture only after route fixture admission |
| primary asset loading | asset existence tests and golden/screenshot evidence after asset lock |
| forced fallback loading | widget test that intentionally drives primary failure or injected loader seam after explicit admission |
| Welcome | widget test plus `first_week compact`/Welcome capture |
| wrong feedback | existing feedback widget tests plus deterministic lane; note if fallback is exposed |
| correct feedback | feedback widget tests plus deterministic lane |
| repair result | repair outcome consumer tests plus Session Summary/feedback evidence |
| Session Summary | state priority tests, growth tests, deterministic lane |
| milestone | resolver/widget tests now; natural capture only after supported completion fixture is admitted |
| compact overflow | widget tests for 30/34/40dp feedback and compact screenshots |
| optical scale/baseline | registry/spec tests plus screenshot comparison after final assets |
| asset swap stability | widget tests over every state and reduced-motion state |
| reduced motion | widget tests using `MediaQuery.disableAnimations`; screenshots only if lane supports it |
| screenshot determinism | existing `screen_review_fast_v1.sh` lanes; new fixture only after explicit admission |
| no route/callback/telemetry regression | focused route tests and no telemetry/persistence changes in mascot-only waves |
| Human QA | final external recognition/tone/readability judgment after deterministic evidence |

New tests are not created in this audit.

## 13. P1-P4 ledger

| ID | Severity | Owner | Factual finding | Impact on B/C/hybrid | Pre/post lock | Minimum action | Dependency | Disposition |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| MPF-01 | P1 | design/product | Micro-animation lacks required preconditions: final direction, normalized renderer, fallback parity, reduced-motion proof | all routes blocked from Sharky micro-motion | pre-lock | keep micro-animation blocked | design lock | blocked by design lock |
| MPF-02 | P2 | runtime | Welcome direct presenter uses legacy SVG as primary | all routes risk first-impression identity split | post-lock | migrate Welcome to canonical identity renderer | fallback ready | documented for later implementation |
| MPF-03 | P2 | runtime | PNG fallback uses legacy SVG family | all routes risk degraded identity split | post-lock | replace with on-identity fallback | final fallback art | documented for later implementation |
| MPF-04 | P2 | renderer | No explicit apparent-scale/anchor/baseline metadata exists | all routes risk jumps/clipping during swaps/motion | post-lock | add normalization seam or normalized source contract | final assets | documented for later implementation |
| MPF-05 | P2 | design/runtime | `confirm` and `improve` share `sharky_happy.png` | B/C/hybrid must decide whether art distinction is required | design lock | final state architecture decision | Claude/owner lock | blocked by design lock |
| MPF-06 | P2 | evidence | Developing/improve/milestone lack natural deterministic captures | all routes need evidence refresh plan | post-lock | add only admitted fixture/capture or limitation note | route fixture admission | documented for later implementation |
| MPF-07 | P2 | accessibility/motion | Current Sharky presence motion is separate 2400ms one-shot and not yet part of motion-token/reduced-motion contract | all routes need motion admission gate | post-lock | verify or refactor only in admitted motion wave | MPF-01 | blocked by design lock |
| MPF-08 | P3 | asset | `sharky_sleeping.png` is inactive/outlier | all routes should avoid accidental admission | pre-lock | keep excluded unless explicitly redesigned | design lock | intentional acceptance |
| MPF-09 | P3 | fallback | If SVG fallback also fails, only placeholder path is proven; complete SVG failure behavior is not deeply audited | all routes need fallback failure test before removal | post-lock | add forced-fallback/failure proof | test seam admission | documented for later implementation |
| MPF-10 | P3 | evidence | Wrong-feedback screenshot exposes fallback, not primary repair PNG | all routes need clearer primary/fallback evidence | post-lock | disclose until captured honestly | screenshot lane | documented for later implementation |
| MPF-11 | P4 | registry | `brand/mascot.svg` remains bundled but production-inactive | no direct route impact | post-lock cleanup | remove/archive only if bundle cleanup is admitted | asset inventory owner | unrelated deferred debt |

## 14. Pre-lock forbidden work

- No art generation, art editing, or asset replacement.
- No SVG-to-PNG migration.
- No renderer implementation.
- No motion implementation.
- No new package.
- No new route or screen.
- No Home/Profile migration.
- No Modern Table, telemetry, persistence, content, or W13+ change.
- No tests changed only to make screenshots easier.
- No design recommendation based on implementation convenience.
- No removal of legacy fallback before replacement and forced-fallback proof.

## 15. Validation

Required validation for this docs-only wave:

- `graphify hook-check`;
- `git diff --check`;
- `git diff --cached --check`;
- no source/test/asset/runtime/motion changes;
- `output/**` remains untracked;
- no push.

Execution results are recorded after validation in the final response and git
history for this wave.

## 16. Capsule update

Capsules should record:

- `Sharky Mascot Direction Correction v2` selects
  `DUAL_REGISTER_ICONIC_COMPANION_SELECTED` as active strategic direction;
- exact final visual execution remains pending controlled board evidence;
- Sharky Micro-Animations remain BLOCKED;
- this audit is technical preparation only;
- implementation is not activated;
- Claude Design PDF is design evidence, not a production lock by itself.

## 17. Scope safety

This artifact is direction-neutral and implementation-neutral. It maps the
technical work needed to support Route B, Route C, or a B/C hybrid, but it does
not pick an aesthetic winner, preserve current art by default, or authorize a
full refresh. The only committed changes in this wave should be this review
artifact and capsule updates.

## 18. Next recommendation

Use this audit as the engineering handoff once the owner locks the visual
direction. The next implementation wave should not start until the owner states
which route is locked and which exact asset architecture is admitted. Until
then, the only safe work is review, decision capture, and acceptance-test
planning that does not alter source, tests, assets, or runtime behavior.
