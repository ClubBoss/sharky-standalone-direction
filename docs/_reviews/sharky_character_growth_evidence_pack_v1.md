# Sharky Character & Growth Evidence Pack v1

Date: 2026-07-03

Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`

Starting HEAD: `b36bd33a`

Mode: evidence preparation; no redesign, new art, or motion implementation; no push

## 1. Verdict

`sharky_character_evidence_pack_ready_with_gaps`

The active PNG family, six semantic states, two growth stages, admitted sizes,
consumer contexts, legacy usage, small-size behavior, state differentiation,
and motion-readiness risks are documented in a self-contained Claude Design
handoff. The pack is ready for independent direction review, but it does not
claim natural runtime screenshot proof for Developing, improve, or milestone.

## 2. Source inventory

### Active primary PNG family

| Asset | Source dimensions | State use | Production status |
| --- | ---: | --- | --- |
| `sharky_neutral.png` | 298x461 | neutral | primary active |
| `sharky_thinking.png` | 357x487 | coach | primary active |
| `sharky_repair.png` | 373x462 | repair | primary active |
| `sharky_happy.png` | 414x477 | confirm, improve | primary active |
| `sharky_celebrate.png` | 451x489 | milestone | primary active |

`sharky_sleeping.png` (371x389) is unused/future-only, excluded from the
six-state system, and inventoried as an inactive candidate.

### Legacy assets

`brand/mascot.svg` is production-inactive. The three 320x200
`poker_shark_*.svg` assets are not production-inactive: canonical source proves
limited active use in `_WelcomeSharkyPresenterTileV1` at 64/80dp and as runtime
fallbacks for PNG load failures. They are classified:

`LEGACY DIRECTION / LIMITED PRODUCTION USAGE / DO NOT EXTEND`

The pack records exact primary/fallback roles separately and asks Claude Design
whether this limited use should migrate before Sharky motion work.

## 3. State mapping

| Evidence trigger | State | Asset | Visible treatment | Consumer/fallback | Readable without text |
| --- | --- | --- | --- | --- | --- |
| no/missing evidence | neutral | neutral PNG | muted plain frame | Welcome/companion; SVG idle on error | medium/large only |
| open repair target | coach | thinking PNG | info plain frame | prompt/guide; SVG thinking on error | medium/large |
| incorrect/failed repair/pattern | repair | repair PNG | gold plain frame | feedback/Summary; SVG idle on error | worried pose; supportive meaning uncertain |
| correct/completed repair/local proof | confirm | happy PNG | primary plain frame | feedback/Summary; SVG idle on error | positive, not distinct from improve |
| reinforced later-correct evidence | improve | happy PNG | accent ring plus copy | Summary; test-only visual evidence | no, shares confirm asset |
| completed world/W4-to-W5 | milestone | celebrate PNG | accent ring plus completion context | Summary; test-only visual evidence | celebration yes, milestone level no |

End-to-end truth remains:

`learning evidence -> phrase context -> companion state -> mood asset -> growth stage -> frame -> consumer`

No accepted semantic truth was changed.

## 4. Capture matrix

| Target | Status | Evidence |
| --- | --- | --- |
| neutral | structurally supported; early Welcome capture | `welcome_decision`; neutral resolver/tests |
| coach | active capture | Welcome handoff, using limited-active thinking SVG |
| repair | active capture with caveat | wrong feedback reproduces SVG fallback; Session Summary shows repair PNG |
| confirm | active capture | correct feedback and repair result |
| improve | test-only evidence | observation/resolver/consumer/ring tests; no natural fixture |
| milestone | test-only evidence | completion/motion tests; no natural fixture |
| Foundation | active captures | every current first-week/core fixture |
| Developing | structurally supported only | resolver and frame/ring widget tests; no W5+ fixture |
| 16dp | structurally admitted | learning-rail owner; isolated-size sheet |
| 30/34/40dp | active captures | feedback contexts |
| 64/68dp | active capture | Session Summary |
| 72/92dp | structurally admitted/current Welcome guide | shared GuideCard owner and Welcome capture |
| Home / Welcome / feedback / Summary | active captures | current core/first-week lanes |
| completion/milestone | impossible in existing lanes | limitation note plus structural tests |

Selective `first_week compact` and `core compact` recaptures passed at the
current checkout. No unsupported state was fabricated.

## 5. Asset consistency

- The five active PNG moods are coherent in palette, outline, face
  construction, lighting, and overall render style.
- Neutral, thinking, happy, and celebrate have the clearest upright
  silhouettes.
- Repair is structurally coherent but has a more inward/anxious posture.
- Sleeping is the main PNG-family silhouette/baseline outlier and is inactive.
- The flat horizontal SVG family does not match the active PNG direction.
- No visible static clipping or destructive crop was found in admitted
  consumers.
- Source dimensions, alpha bounds, width, and visual centers differ enough to
  require renderer-level apparent-scale/anchor review before asset-swap motion.

## 6. Small-size readability

- 16dp: brand presence only; state is not reliable.
- 30-40dp: major valence and some pose are readable; adjacent concerned or
  positive states can compress.
- 53.8/57.1dp art inside 64/68dp Summary frames: face and pose are readable;
  this is the strongest emotional consumer context.
- 60.5/77.3dp art inside 72/92dp GuideCard frames: strongest isolated
  character readability.
- Confirm and improve cannot become asset-distinct at any size because both
  use `sharky_happy.png`.

## 7. State differentiation

| Pair | Primary distinction | Verdict |
| --- | --- | --- |
| neutral vs coach | asset/pose | clearly distinct at medium size; weaker at 16dp |
| coach vs repair | asset/pose | ambiguous at small size; both can read concerned |
| repair vs confirm | asset and emotional valence | clearly distinct |
| confirm vs improve | same asset; ring/copy | frame/copy-dependent |
| improve vs milestone | happy vs celebrate; ring/context | distinct at medium size; context-dependent small |

The current system is not six independently distinct character drawings.
Frame, copy, and context intentionally carry part of the semantic load.

## 8. Growth readiness

Foundation and Developing preserve the same character asset, expression,
crop, and scale. Developing adds a persistent outer growth ring, 1.3dp versus
1.0dp base-frame border, and modestly stronger border alpha and shadow.

The progression is restrained and avoids rank/rarity/costume language, but its
real-size visibility is unproven in a natural W5+ screenshot. The W4-to-W5
transition correctly remains Foundation; Developing starts in W5. The handoff
contains four options for Claude Design: retain frame-only growth, bounded
presence evolution, meaningful active asset-set upgrade, or full refresh only
if strongly justified.

## 9. Motion readiness

- Active source canvases and alpha bounding boxes are usable but not normalized
  enough to assume swap-safe scale/center behavior.
- Celebrate has the widest active silhouette.
- Sleeping is a high-risk horizontal/baseline outlier.
- Repair motion risks amplifying an anxious/punitive reading.
- Confirm/improve motion cannot supply static semantic distinction that the
  shared asset lacks.
- Existing one-shot Sharky presence motion is 2400ms and does not yet honor the
  broader accepted motion-token/reduced-motion contract; this task does not
  change it.

Claude should define any renderer-level anchor/apparent-scale repair before
micro-animation implementation.

## 10. P1-P4 ledger

No P1 blocker was found.

| ID | Severity | Classification | Exact finding | Impact | Minimum repair / decision | Disposition |
| --- | --- | --- | --- | --- | --- | --- |
| SCG-01 | P2 | mapping/evidence truth | limited-active SVG and primary PNG systems coexist | inconsistent character direction | decide and safely migrate Welcome/fallback if approved | `send_to_claude_design` |
| SCG-02 | P2 | evidence gap | wrong-feedback capture reproduces SVG fallback | not primary repair-PNG proof | retain disclosure; investigate only in later admitted work | `send_to_claude_design` |
| SCG-03 | P2 | mapping question | confirm and improve share happy asset | improve depends on ring/copy | decide if acceptable or needs differentiated pose | `send_to_claude_design` |
| SCG-04 | P2 | evidence/growth gap | Developing is frame-only and lacks natural W5+ capture | progression strength unproven | Claude verdict before motion | `send_to_claude_design` |
| SCG-05 | P2 | motion-readiness risk | source sizes/centers/silhouettes vary | apparent jump on motion | define renderer normalization | `send_to_claude_design` |
| SCG-06 | P3 | subjective design question | repair may read anxious/guilty | correction may feel punitive | Claude evaluates tone | `send_to_claude_design` |
| SCG-07 | P3 | objective asset outlier | sleeping has horizontal silhouette/baseline | inconsistent if admitted | keep inactive unless explicitly admitted | `defer_with_structural_reason` |
| SCG-08 | P3 | small-size ambiguity | 16dp is brand-only; adjacent states compress at 34dp | character cannot carry all semantics | decide acceptable copy/frame reliance | `send_to_claude_design` |
| SCG-09 | P3 | evidence gap | improve/milestone natural captures unavailable | context balance unproven | retain test-only evidence/notes | `defer_with_structural_reason` |
| SCG-10 | P4 | safe-as-is | dimensions differ but static crops do not clip | no current static defect | none before review | `safe_as_is` |

## 11. Evidence coverage

The local pack contains active/complete source inventories, six-state and
confusion sheets, Foundation versus Developing, real contexts, actual-size
readability, without/with-copy comparisons, motion geometry, CSV traceability,
and limitation notes. Derived sheets disclose normalization and never outrank
source/runtime truth.

## 12. Claude Design brief

`handoff/11_DESIGN_BRIEF/claude_design_brief.md` and `review_checklist.md`
are complete. They require one final direction and exact implementation scope.

## 13. Objective repairs made

No production or test repair was made. Evidence repairs only:

- current first-week/core lanes selectively recaptured;
- misleading legacy classification corrected against live source;
- wrong-feedback fallback retained and explicitly labeled;
- unavailable states received substitute evidence and blocker impact;
- comparison sheets disclose normalization and actual/inspection size.

## 14. Explicit gaps

- no natural Developing, improve, or world-complete/W4-to-W5 screenshot;
- wrong-feedback capture exposes fallback rather than primary repair PNG;
- no Human QA or final design claim.

## 15. Validation

- focused state/growth/consumer suite: 79 tests passed;
- `first_week compact`: passed and refreshed (12 text overlays repaired);
- `core compact`: passed and refreshed (6 text overlays repaired);
- ZIP integrity: `unzip -t` reports no errors;
- ZIP size: 3.3 MB;
- ZIP SHA-256:
  `09f36fd759281fd3be1c0135f9d8817cd800e846f0fd5e06bbc197a251aa668b`;
- `graphify hook-check`: passed (exit 0);
- `git diff --check` / `git diff --cached --check`: passed;
- pack verification: 17 required files present, 11 PNGs decode, 34 ZIP entries;
- `output/**`: local-only and uncommitted.

ZIP content listing (folders omitted):

- `README_FIRST.md`
- `00_PACK_INDEX.png`
- `01_ACTIVE_ASSETS/all_active_png_assets.png`
- `02_LEGACY_ASSETS/all_legacy_svg_assets.png`
- `02_LEGACY_ASSETS/asset_usage_notes.md`
- `03_STATE_COMPARISONS/six_states_same_size.png`
- `03_STATE_COMPARISONS/state_confusion_matrix.png`
- `04_GROWTH_PROGRESSION/foundation_vs_developing.png`
- `04_GROWTH_PROGRESSION/growth_direction_options.md`
- `04_GROWTH_PROGRESSION/developing_runtime_capture_limitation.md`
- `05_REAL_PRODUCT_CONTEXTS/consumer_contexts.png`
- `05_REAL_PRODUCT_CONTEXTS/milestone_completion_capture_limitation.md`
- `06_SMALL_SIZE_READABILITY/small_size_readability.png`
- `07_WITHOUT_COPY/state_without_copy.png`
- `08_WITH_COPY/state_with_copy.png`
- `08_WITH_COPY/improve_milestone_capture_limitation.md`
- `09_MOTION_READINESS/motion_readiness.png`
- `09_MOTION_READINESS/motion_readiness_notes.md`
- `10_SOURCE_TRUTH/source_truth_matrix.csv`
- `10_SOURCE_TRUTH/capture_manifest.csv`
- `10_SOURCE_TRUTH/source_truth_notes.md`
- `11_DESIGN_BRIEF/claude_design_brief.md`
- `11_DESIGN_BRIEF/review_checklist.md`

## 16. Route decision

`activate_sharky_character_growth_design_review_keep_micro_animation_blocked`

`Sharky Micro-Animations v1` must not start until Claude Design selects the
character/growth direction and any required pre-motion normalization or
asset/fallback repair.

## 17. Capsule update

- Active task advances to `Sharky Character & Growth Design Review v1`.
- `Sharky Micro-Animations v1` remains BLOCKED.
- Visual capsule records pack location, capture gaps, dual SVG/PNG truth, and
  design-review dependency.

## 18. Scope safety

No art edit, new asset, generated character art, semantic-state expansion,
growth expansion, Home/Profile migration, motion implementation, custom
capture harness, route, telemetry, persistence, Modern Table, W13+, or push.
Generated images, CSVs, prompt input, and ZIP remain local under `output/**`.

## 19. Next recommendation

Send `sharky_character_growth_design_handoff_v1.zip` and
`CLAUDE_DESIGN_PROMPT_INPUT.md` to Claude Design. Resume implementation only
from Claude's explicit final direction and bounded scope.
