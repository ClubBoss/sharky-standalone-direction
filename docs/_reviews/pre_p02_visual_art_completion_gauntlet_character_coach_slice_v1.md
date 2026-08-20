# Pre-P02 Visual Art Completion Gauntlet — Character + Coach Premium Slice v1

Status: PROPOSED FINDINGS — PENDING OWNER REVIEW (not authority)
Freshness date: 2026-08-20
Repository: `ClubBoss/sharky-standalone-direction`
Branch: `visual/pre-p02-character-coach-premium-slice-v1`
Executor: Claude, isolated worktree at `/private/tmp/sharky-b7-char-coach-premium-slice-v1`

## Purpose

Executes `PRE_P02_VISUAL_ART_COMPLETION_GAUNTLET_V1` /
`LEARNING_SCENE_CHARACTER_AND_COACH_VISUAL_COMPLETION` per
`docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md`. This record does not close the
family, does not admit `FULL_CHARACTER_PACK`, does not claim
`PREMIUM_CHARACTER_ART = PROVEN`, does not reopen B1-B7, and does not run P02.
It is a findings/evidence record for owner review, in the same spirit as
`docs/_reviews/b7_character_vertical_slice_art_direction_v1.md`
("IMPLEMENTATION RECORD (not authority)").

## Re-resolved baseline

`origin/main` at authoring: `e9101ae0b558f49ee8fefc61bb3e181347299341`
(merge of PR #209, `docs/pre-p02-north-star-convergence-rebaseline-v1`) —
matches the mission's canonical baseline exactly. Read in full or targeted
before any mutation: `AGENTS.md`,
`docs/plan/MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md`,
`docs/context/PRE_HUMAN_CAMPAIGN_STATE_v1.md`,
`docs/_reviews/owner_pre_p02_north_star_convergence_rebaseline_v1.md`, and all
three prior B7 admission/closure authorities. Confirmed unchanged: active
family, exact next action, all frozen boundaries (`PR203` geometry, `PR205`
commitment ownership, `CAMERA_RETUNE_AGAIN = NO`,
`TEXT_SCALE_POLICY_V1 = SINGLE_CANONICAL_PRODUCT_SCALE`, `B8 = NOT_ADMITTED`).

## Current visual baseline actually inspected

Captured fresh (not reused stale evidence) via
`tools/act0_b7_cohesion_capture_v1.dart --label baseline_main_e9101ae0`, the
real canonical route, real taps, settled endpoints, at `375x812`, `402x874`,
`430x932`, across `decision / correct_feedback / wrong_feedback /
targeted_repair / targeted_recheck`. Output:
`output/visual_gauntlet_b7/baseline_main_e9101ae0/` (local-only, uncommitted
per that tool's own convention).

### Material current gaps found

1. **Character ceiling unchanged since B7 closure.** Every non-hero seat still
   renders the B3 procedural silhouette only — a faint, near-monochrome
   humanoid shadow with no facial construction, hair, or clothing detail. The
   B7 character vertical slice (authored PNG opponent + hero) proved a
   class-level lift over this baseline, but its prototype art was never
   admitted to main (correctly — it is PIL-procedural, not premium), so
   production still ships the pre-slice ceiling. This is the primary
   "premium-ish table with simplified game avatars" gap the mission names.
2. **Sharky mood art does not exist.** `act0SharkyCompanionAssetForMoodV1`
   deliberately maps every mood (`neutral, happy, thinking, repair,
   celebrate`) to one shared `sharky_neutral_fallback_v1.png`. Sharky's face
   never reacts to a correct read, a miss, or a repair — a real, honest,
   currently-shipping cohesion gap, distinct from the opponent/hero gap and
   requiring its own asset admission.
3. **Coach-surface mascot could show a broken-looking letter avatar on first
   appearance.** Confirmed and fixed in this PR — see §Part C.

Everything else audited (table furniture, felt, chip/pot chrome, card
rendering, dock/CTA layout, HUD, rail occlusion) already reads as premium and
is explicitly frozen (`PR203`/`PR205`); no material gap found there and none
is in scope.

## Part A — production-path comparison

| Criterion | A. Authored/generated 2D-2.5D | B. Blender-rendered 2.5D | C. Hybrid |
| --- | --- | --- | --- |
| Achievable visual quality | Already proven premium in this exact project — `sharky_neutral_fallback_v1.png` (1254x1254, soft 3D-toy shading, clean alpha, owner-approved) | Unproven here; no existing Blender asset, rig, or render pipeline in this repo | Unproven; adds process without a demonstrated quality delta over A |
| Character consistency across seats/states | Reference-image-conditioned generation already demonstrated (the character package's canonical + 3 reconstruction references keep one identity consistent across views) | Strong in principle (one rig, many renders) but requires building the rig from zero | Same strength as B, same zero-rig starting point |
| Perspective/lighting match to the frozen camera | Directly controllable via prompt + reference (already matched B2's `Act0SceneLightV1.canonical` direction in the accepted A-candidate treatment) | Fully controllable but only after camera/lighting is rebuilt in a 3D scene to mirror the Flutter camera | Same rebuild cost as B for the 3D portion |
| Transparent asset quality | Confirmed alpha (0-255 extrema, clean cutout) in the existing package | Native to Blender render passes | Native for the 3D-authored portion only |
| Repeatability for a future full pack | High — same reference-conditioned prompt pattern scales to 4 more opponents | High once the rig exists, but the rig does not exist yet | Medium — still needs the rig for the "authored geometry" half |
| Deterministic runtime integration | Already proven end-to-end by the closed B7 vertical slice using this exact art *style* target (only the source method changes) | Same proven runtime path (still ends as a transparent PNG) — no advantage over A at the integration layer | Same |
| Production cost / iteration speed | Low; no new pipeline, no rig, no render farm; iterate by re-prompting | High; requires modeling, rigging, lighting setup, and a render step before any iteration | Highest; pays both A's and B's setup costs |
| Maintainability | Low ongoing cost — swap a PNG | Requires maintaining a Blender project file, scene, and render settings alongside the app | Requires maintaining both a 3D asset and a compositing/cleanup step |
| This environment's actual tool access | No Blender and no image-generation tool are available in this execution environment for *either* path | Same unavailability | Same unavailability |

**Selected direction**: `A — Authored/generated 2D-2.5D asset pipeline`, for
next production (not executed in this PR — see Part B). It wins on every
criterion except the two where it ties B/C, and it is the only one with an
existing owner-approved quality proof point inside this exact project. This
does not reopen or contradict the prior gauntlet's PIL rejection — that
gauntlet judged *art direction* (A/B/C treatment) using a fixed low-grade
*production method* (PIL primitives); this comparison judges *production
method* using the already-accepted *direction* (the "stylized premium
illustration" treatment). They are orthogonal axes, and the earlier
direction-selection reasoning (`docs/_reviews/b7_character_vertical_slice_art_direction_v1.md`)
still applies to whichever method eventually renders it.

## Part B — first premium production slice

**Outcome**: `BLOCKED_ON_IMAGE_GENERATION_TOOL_ACCESS`. This execution
environment has no Blender and no image-generation tool, exactly the
condition the mission's "IMPORTANT TOOL RULE" anticipates as a valid stop.
Per that rule: finalized the production direction (above), and produced the
exact asset production spec —
`docs/reference/visual_benchmarks/PRE_P02_CHARACTER_AND_SHARKY_ASSET_PRODUCTION_SPEC_v1.md`
— covering dimensions, transparency, viewpoint, lighting, pose, crop, safe
margins, state variants, file naming, and exact generation prompts for the
opponent, the hero foreground, and the four missing Sharky mood renders.

**Why no scaffolding code was re-added in this PR**: the character-asset
resolver architecture (`Act0SceneCharacterAssetV1`,
`Act0SceneCharacterAssetStoreV1`, `Act0SceneCharacterAssetPainterV1`,
`act0SceneAuthoredOpponentSeatIdV1`) is already fully proven and closed —
`CHARACTER_ASSET_ARCHITECTURE = PROVEN`,
`B7_CHARACTER_VERTICAL_SLICE_V1 = CLOSED_PASS_PROOF` — as an uncommitted local
prototype that exists outside this canonical worktree. Re-landing that exact
scaffold in this PR with no production art behind it would not create new
evidence (the architecture question is already closed) and would risk
"canoniz[ing] placeholder art" if anyone later pointed it at the still-present
prototype PNGs. The mission's own boundary — "implement only safe integration
scaffolding if it creates real EV" — is not met by re-deriving already-proven
code with nothing to render. The spec document explicitly hands the future
implementer the exact landing instructions (file paths, resolver names) so
scaffold and art land together in one admission instead of drifting apart.

## Part C — Sharky + speech-surface cohesion audit

Audited the merged Coach Surface (`SHARKY_COACH_SURFACE_V1 = CLOSED_PASS`,
shipped via PR #207) against its own accepted semantics
(`SHARKY = VOICE OF THE SCENE`, `TABLE = STABLE PHYSICAL WORLD`,
`BOTTOM SHELF = CONTROLS`) using the fresh baseline capture.

**Findings**:

- Sharky's avatar-plus-card pairing (with a small connecting speech-tail
  accent) is present and legible in `UNDERSTAND` (correct/wrong),
  `REPAIR`, and `RECHECK`. Sharky is correctly restrained (no avatar shown)
  in `DECIDE`, matching the accepted product direction — not a defect.
- The card never competes with the table for visual weight, and the bottom
  shelf remains CTA-first in every captured state — cohesion hypothesis
  holds structurally.
- **Real defect found, and now correctly fixed**: on `correct_feedback` —
  Sharky's *first* appearance in the captured route — the mascot rendered as
  a bare circular "S" letter (`_SharkyMascotLetterFallbackV1`) instead of the
  actual mascot artwork. Root cause: `Act0SharkyPresenceMascotV1`'s
  `Image.asset` used a `frameBuilder` that substituted the letter fallback
  for *any* frame not yet available — including a normal, still-in-progress
  decode, which is not an error condition.

  An earlier version of this PR attempted to close the gap by precaching the
  asset from `didChangeDependencies` with `unawaited(precacheImage(...))`.
  Mastermind review correctly rejected that: the precache `Future` was
  unawaited, so the very first `build`/paint could still land before decode
  completed, and no lifecycle-timing trick can *deterministically* win that
  race — it can only make the window smaller. The `frameBuilder` was the
  actual causal owner of the defect, not the absence of a precache, so this
  revision fixes it there directly instead: the `frameBuilder` no longer
  exists. `Image.asset` now simply paints nothing (the outer sized frame
  already stays in place; `RawImage` with no frame paints empty) until its
  real first frame arrives, then repaints itself automatically, exactly like
  every other `Image.asset` in this codebase. `errorBuilder` is untouched —
  a genuine decode failure still reaches the graceful lettered fallback.
  This is now correct by construction for any asset, any cache state, any
  entry route — not merely less likely to race.
- No other material cohesion gap found; the remaining honest gap (Sharky's
  fixed neutral expression regardless of mood) is an asset-production
  dependency, not a cohesion-implementation defect, and is captured in the
  spec doc instead of implemented here per the "do not redesign
  copy/learning semantics, do not fake final art" boundary.

**Implemented repair** (does not touch Coach Surface copy, layout, position,
or dock semantics — purely removes the incorrect loading-state substitution):

- `lib/ui_v2/act0_shell/act0_sharky_presence_v1.dart`: removed
  `_Act0SharkyPresenceMascotV1State`'s `frameBuilder` entirely from its
  `Image.asset`. `errorBuilder` (the genuine-failure path) is unchanged,
  byte-for-byte. Net diff vs. `e9101ae0`: one file, `+7/-10`.
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`: **reverted to
  byte-identical with `e9101ae0`**. The precache field, the
  `didChangeDependencies` override, and the precache helper it called are
  all removed — per the review's own instruction to prefer smaller causal
  ownership over keeping now-redundant machinery once the frameBuilder fix
  makes them unnecessary. `act0SharkyCompanionAssetPathsV1()` and
  `act0PrecacheSharkyCompanionAssetsV1()` are also removed from
  `act0_sharky_presence_v1.dart` for the same reason.

## Deterministic decode-contract proof

Reproduced the cold-cache first-appearance route directly rather than relying
on the capture tool's incidental timing: a throwaway widget test (not
committed — this repo's own guidance is not to add a meta-test family) wraps
`Act0SharkyCompanionAvatarV1` in a `DefaultAssetBundle` whose `load()` is
artificially delayed 300ms, then asserts, across five 50ms pumps *before* the
delay resolves, that `Key('act0_shell_sharky_presence_asset_fallback')` is
never found — i.e. the letter never paints during a decode that is
deliberately kept in-flight far longer than any real asset load — and that
after `pumpAndSettle()` the real mascot (`Key('act0_shell_sharky_presence_mascot_happy')`)
is present. Result: passed. This is a proof of the contract, not a
timing-dependent observation.

The genuine-error path (`errorBuilder`) was not independently re-proven,
because it was not touched by this revision — it is byte-identical to the
already-shipping implementation.

## Evidence — baseline vs candidate

Re-captured after the corrected fix:
`output/visual_gauntlet_b7/candidate_frameBuilder_fix_v1/` (same tool, same
route, same three viewports, same five endpoints).

- `canonical_402x874/endpoint_correct_feedback.png`: the mascot chip is empty
  (no letter, no image yet) rather than showing "S" — this specific capture
  tool does not await asset decode before snapshotting, so on a cold
  `ImageCache` its very first Sharky frame can still be captured mid-decode;
  the deterministic proof above is what establishes the actual guarantee
  ("never wrong," not "always fully loaded within one arbitrary test frame").
  `endpoint_targeted_repair.png` (a later state, asset already decoded by
  then) shows the real mascot correctly.
- All other endpoints/viewports: table, felt, seats, board, pot, and dock are
  unchanged from baseline. One pre-existing, unrelated rendering artifact was
  found and ruled out: at `large_430x932` / `endpoint_targeted_recheck`, the
  Fold/Check/Call button labels render as blank white bars instead of text —
  confirmed present identically in the very first `baseline_main_e9101ae0`
  capture (taken before any change in this PR), so it is pre-existing
  font/glyph-timing behavior of this specific headless capture tool, not a
  regression.
- No viewport regression found at `375x812` or `430x932`.

## Geometry / ownership preservation proof

The final change touches only `_Act0SharkyPresenceMascotV1State`'s
`Image.asset` builder configuration. It does not touch
`act0_lesson_runner_shell_v1.dart` at all (byte-identical to `e9101ae0`), nor
`act0_scene_player_v1.dart`, `act0_scene_depth_v1.dart`, any geometry
constant, any commitment-anchor code, or any Coach Surface copy/layout code.
`flutter analyze` on the one changed file: clean, 0 issues.

## Tests / validation

- `flutter analyze lib/ui_v2/act0_shell/act0_sharky_presence_v1.dart
  lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` — 0 issues.
- `dart format --set-exit-if-changed` on both files — 0 changes needed.
- `flutter test test/ui_v2/act0_sharky_presence_v1_test.dart` (direct
  coverage of the changed code path) — all 7 cases pass unchanged; no
  existing assertion encoded the old decode-placeholder behavior, so no test
  needed updating.
- Deterministic decode-contract proof (throwaway, not committed) — see above
  — passed.
- Broad `flutter test test/ui_v2 test/guards` regression sweep from the prior
  revision of this PR (`+1824 -160`, all failures traced to pre-existing,
  unrelated debt — 40 compile failures confined to dormant
  `test/guards/*world1_*`/`*campaign*`/`*map*`/`*bankroll*` legacy surfaces
  that don't import either file this PR touches, plus a stale test/key
  mismatch confirmed via `git stash` against unmodified `e9101ae0`) is not
  re-run in full for this revision: the net change shrank to a single-file,
  `+7/-10` diff with no new logic paths beyond what
  `act0_sharky_presence_v1_test.dart` and the decode-contract proof already
  exercise, and `act0_lesson_runner_shell_v1.dart` — the file that motivated
  the original broad sweep — is no longer touched at all.

## Disposition

`B. DIRECTION_PROVEN_ASSET_DEPENDENCY`

- Production route selected: `A — authored/generated 2D-2.5D asset pipeline`.
- This execution environment cannot create final-quality character or Sharky
  mood art (no Blender, no image-generation tool).
- Exact external asset spec is ready:
  `docs/reference/visual_benchmarks/PRE_P02_CHARACTER_AND_SHARKY_ASSET_PRODUCTION_SPEC_v1.md`.
- One real, bounded, implementable cohesion defect was found and fixed inside
  this PR (Sharky first-appearance decode placeholder) — this is real
  in-scope EV delivered even though the headline character/mood art remains
  externally blocked.
- Nothing here fakes final art, canonizes prototype PNGs, or expands scope
  beyond `LEARNING_SCENE_CHARACTER_AND_COACH_VISUAL_COMPLETION`.

## Next recommended bounded visual family

Once premium opponent, hero, and Sharky-mood assets exist (produced against
the spec by an owner-directed image-generation pass, outside this execution
environment), the next bounded family is landing them: wire the existing
proven resolver scaffold, extend `act0SharkyCompanionAssetForMoodV1` to the
four-mood switch, re-run the deterministic geometry guard, and re-capture
this same evidence set for a same-route before/after comparison. That family
should stay scoped to exactly that landing — it should not grow into a full
five-seat character pack without a separate explicit admission.

`READY_FOR_MASTERMIND_PRE_P02_VISUAL_ART_GAUNTLET_REVIEW`
