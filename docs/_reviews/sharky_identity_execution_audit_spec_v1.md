---
status: "undeclared"
status_source: "absent"
baseline: "c5ae81bffc0a"
generated_by: "docs_frontmatter_v1"
---

# Sharky Identity Execution Audit / Spec v1

Terminal verdict: `sharky_identity_execution_blocked_on_production_art_direction_and_on_identity_fallback_pack`

## Branch and audit scope

- Branch / audited HEAD: `claude/hub-surface-coherence-audit-plan-v1` /
  `c5ae81bffc0ad45f8f45db92380412b94d3d7a84`.
- Mode: docs/source audit only. No source, asset, generated-image, motion,
  telemetry, route, progression, or capture change was made.
- Sources/docs inspected:
  - `docs/_reviews/sharky_three_register_system_lock_v3.md`
  - `docs/_reviews/mascot_production_feasibility_migration_audit_v1.md`
  - `lib/ui_v2/act0_shell/act0_sharky_presence_v1.dart`
  - `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`
  - active consumer references in Home, Placement, Profile, Lesson Runner,
    and the Act0 preview shell
  - `pubspec.yaml`, active mascot assets, and focused Sharky test inventory

## Current Sharky usage inventory

| Surface / owner | Active use | Rendering contract | State or size | Status |
| --- | --- | --- | --- | --- |
| Shared presence owner: `act0_sharky_presence_v1.dart` | Primary renderer for Act0 companion consumers. | `Image.asset` from the five-PNG mood registry. | neutral, happy, thinking, repair, celebrate; callers range from 30 to 92dp. | Active runtime. |
| Home identity row | Compact companion beside course identity and mission support. | Shared PNG presence renderer. | 38dp frame / compact art; authored runner mood. | Active runtime; do not migrate state/growth ownership in first art wave. |
| Placement | Brand/start companion. | Shared PNG presence renderer. | happy mood. | Active runtime. |
| Welcome guide card | Orientation and handoff guidance. | Shared guide frame / PNG renderer. | neutral or coach; 72/92dp. | Active runtime. |
| Welcome presenter tile | Separate visual tile. | Direct legacy SVG map, not shared PNG owner. | neutral/happy/repair -> idle SVG; thinking / celebrate have separate SVG; 64/80dp. | Active runtime; stale legacy dependency. |
| Lesson Runner / feedback | Small coach and feedback cue. | `Act0SharkyMascotV1` wrapping shared presence renderer. | 30/32/34/40dp. | Active runtime. |
| Session Summary / payoff | Companion bubble and payoff hero. | Shared companion avatar/presence frame. | 64/68dp; semantic state plus structured growth stage. | Active runtime. |
| Profile | Proof identity card. | Shared PNG presence renderer. | 56dp, neutral only. | Active runtime. |
| Learn, Practice, Review | Sharky copy/support appears in active flows; some are text-only. | No new visual consumer should be inferred from copy. | Existing phrase/state owners. | Do not expand in first art wave. |

The active semantic contract has six states (`neutral`, `coach`, `repair`,
`confirm`, `improve`, `milestone`) mapped onto five current asset moods;
`confirm` and `improve` intentionally share happy art but differ through
structured state and accent framing. Growth is a separate Foundation / Developing
axis. Those facts must remain unchanged in the first asset execution wave.

## Assets and fallback behavior

| Asset family | Current role | Technical note |
| --- | --- | --- |
| `assets/images/mascot/sharky_{neutral,happy,thinking,repair,celebrate}.png` | Shared primary runtime art. | 298x461 to 451x489 px. The smallest current source is insufficient for a clean 3x 92dp target, so production replacement art must be supplied at materially higher resolution. |
| `assets/images/mascot/sharky_sleeping.png` | Bundled but not mapped to an active semantic state. | Do not adopt it by convenience. |
| `assets/mascot/poker_shark_{idle,thinking,celebrate}.svg` | Welcome presenter primary and shared-PNG pending/error fallback. | Limited-active legacy direction. This creates the P1 dual-identity risk. |
| `assets/brand/mascot.svg` | Bundled inventory asset. | Not an active runtime Sharky consumer. |

`Act0SharkyPresenceMascotV1` uses the PNG registry first. While a PNG is
pending or fails, it renders the legacy SVG family; while the SVG is loading it
renders a letter `S`. There is no further SVG-error visual treatment. The
container size remains stable, but visual identity does not: Welcome can show a
legacy primary character while other surfaces show the PNG character, and a
PNG failure exposes the legacy character elsewhere.

## Product identity requirements

The active lock is `THREE_REGISTER_ICONIC_COMPANION_SELECTED` and is
Product-first / one-character only.

| Register | Required now | Later allowance |
| --- | --- | --- |
| Product | Canonical resting anatomy, sharp table-reading eye, warm adult-safe expression, wedge-like rostrum, proprietary dorsal signature, no legs/hands, pectoral fins remain fins, no costume or comedy after mistakes. Product Neutral and Supportive Repair are mandatory first proof. | Restrained semantic micro-motion only after art migration is proven. |
| Progress | Same base identity at completion, summary, proof, and milestone surfaces. | Joy, contained expressive celebration, and props only when they resolve to the same calm base; no RPG framing. |
| Marketing | Same silhouette and personality recognisable outside the app. | Wider animation, staging, stories, props, and costumes. Not part of runtime asset migration. |

The compact-adult guard remains active: explore roughly 1:2 to 1:2.5
head-to-body only through design review; do not turn warmth into preschool
proportions, oversized pupils, or a dolphin/manatee snout. A 16dp mark, 34dp
valence, 68-92dp expression, and repair-first continuity proof are required.

## Execution constraints

- Supply transparent-background master art with stable alpha padding, optical
  anchor, visual centre, apparent-scale target, and max silhouette width for
  every expression.
- Prefer production raster sources at least 3x the 92dp largest active tier
  (minimum 276 px useful art after alpha padding); 512 px square-or-larger
  source masters are safer for consistent crops. Provide an on-identity vector
  fallback sharp at 16-92dp.
- Deliver coverage for the existing mood registry: neutral, thinking/coach,
  repair, happy/confirm/improve, and celebrate/milestone. Do not add a semantic
  state merely to fit an illustration.
- Preserve the existing asset registry path/semantic mapping at first unless a
  separately admitted compatibility layer is required. Versioned new assets
  may coexist during migration; remove no legacy fallback before forced-fallback
  proof passes.
- The shared frame, tone resolver, accent-ring rules, structured state resolver,
  growth axis, localization/copy contract, and reduced-motion semantics remain
  source truth. Art must not encode state meaning that frame/copy cannot still
  communicate at small sizes.
- Welcome must converge onto the same on-identity asset family or a visually
  equivalent fallback before the migration closes; direct legacy-SVG primary
  use must not survive as a second base character.

## Risk map

| Risk | Severity | Evidence / mitigation |
| --- | --- | --- |
| PNG and SVG families read as different Sharkys. | P1 dual identity | One Product-first base plus on-identity Welcome/fallback replacement; compare Welcome, Home, feedback, Summary, and Profile. |
| New art crops or scales differently across 30-92dp consumers. | P1 | Metadata and a consumer-size matrix; transparent safe box; 16/34/68-92dp proof. |
| Repair expression becomes playful, shaming, or childlike. | P1 | Repair-first design review blocks the direction before implementation. |
| Art replacement changes semantic state, growth, or route behavior. | P1 | Reuse existing registry/state/growth APIs; focused structural guards. |
| SVG/letter fallback exposes an off-identity degraded state. | P1 | Forced PNG-failure and SVG-load/error tests with one on-identity vector fallback. |
| Screenshot tooling misrenders a valid mascot/copy state. | P2 | Raw compact captures plus widget assertions; repair the evidence pipeline separately if capture artifacts recur. |

## Execution-route decision

| Option | Decision |
| --- | --- |
| A. Docs/design spec, then controlled Claude visual direction | **Recommended.** Production-ready, approved Sharky art and an on-identity fallback pack are not currently available. The active three-register lock requires repair-first cross-register proof before implementation. |
| B. Bounded asset swap using existing art | Rejected now. Existing PNG art is placeholder, legacy SVG remains a different direct Welcome identity, and current files do not constitute an accepted production pack. |
| C. Fallback/consumer cleanup before art replacement | Deferred immediately after A's visual lock. Cleanup without approved art would only hide or reframe the unresolved identity; it cannot close the dual-family problem. |
| D. Defer | Rejected as final disposition. The identity is P1 before Human QA/public-quality consideration, but implementation correctly waits for visual/spec approval. |

## Recommended next wave

**Executor / model / intensity:** Claude Design (or equivalent controlled visual
review), medium. Codex follows only after the selected production pack exists.

**Exact scope:** a three-direction Product-first board—Warm Compact Companion,
Balanced Three-Register Sharky, and Premium Iconic Shark—using the same
neutral base, then the required Product Neutral, Supportive Repair, Progress
Milestone, Marketing Story pose, same-character continuity, 16dp, 34dp, and
68-92dp proofs. It must include an on-identity SVG/vector fallback and an
asset handoff sheet with expressions, anchors, safe boxes, and occupancy.

**Non-scope:** generated production assets, runtime asset replacement, motion
implementation, Home/Learn/Profile redesign, route/progression, telemetry,
W13+, tablet, Human QA, and public/store work.

**Expected handoff files:** a design decision packet plus production-source
exports for the five mapped moods, one fallback vector, an asset manifest, and
a consumer-size/anchor matrix. No Dart changes belong in the design wave.

**Codex implementation after approval:** bounded asset-family migration in
`assets/images/mascot/`, `assets/mascot/`, `pubspec.yaml`, the shared presence
owner, and Welcome presenter only; focused presence, Welcome, companion-state,
semantic-consistency, and forced-fallback tests; compact evidence for Welcome,
Home, feedback, Session Summary, and Profile. No route or phrase changes.

## Debt ledger / return queue

| ID | Item | Return condition |
| --- | --- | --- |
| SHK-001 | Production art direction and canonical Product base. | Controlled visual board decision. |
| SHK-002 | Legacy Welcome SVG primary / shared SVG fallback dual identity. | After SHK-001 approved assets exist. |
| SHK-003 | Raster masters below robust 3x largest-display target. | Production export handoff. |
| SHK-004 | Forced fallback parity and SVG-error behavior. | First Codex asset migration wave. |
| SHK-005 | Motion/touch/ceremony depth. | After one on-identity runtime base is proven. |
| SHK-006 | Capture pipeline artifacts. | Before final visual gate; separate from identity migration. |

No 10/10 claim, public-readiness claim, or Human-QA-readiness claim is made.
No asset implementation was performed.
