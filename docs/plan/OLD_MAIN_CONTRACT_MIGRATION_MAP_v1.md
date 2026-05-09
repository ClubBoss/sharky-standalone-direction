# Old Main Contract Migration Map v1

Status: ACTIVE REFERENCE
Last updated: 2026-05-06

## Purpose

Preserve the strongest old-main learning contracts without reviving the old
host complexity inside current `Sharky`.

This document is not a route SSOT and not a runtime registry.
It exists to answer one narrow question:

- which old-main ideas are worth preserving
- how they map into current `Sharky`
- whether they are already landed, still partial, intentionally deferred, or
  rejected

## Rule

Keep the contract.
Do not resurrect the old architecture.

Preferred direction:

1. one compact learner runner
2. typed families and typed format seams
3. later expansion through bounded world packets
4. no mode zoo and no branch-heavy early UX

## Migration Map

| Old-main contract | Current `Sharky` equivalent | Status | Earliest owner / world | Decision |
| --- | --- | --- | --- | --- |
| Curated drill families instead of random one-off modes | `docs/plan/MODE_FAMILY_STRATEGY_v1.md`, `docs/content/DRILL_CONTRACT_v1.md`, typed `Act0TaskFamilyV1` seam in active shell | `partial -> active` | cross-world system | Keep and continue through typed task families, not string mode proliferation |
| Core drill semantics: seat tap, action choice, bet sizing choice, showdown, outs, board texture, range bucket, hand chain | `DRILL_CONTRACT_v1.md` already covers a narrow deterministic base; content route and coverage docs preserve the wider family universe | `partial` | W1-W12 plus future drill packets | Keep. Expand through family packets, not new standalone screens |
| `cash / tournament / mixed` track taxonomy | shared early ladder in `MASTER_PLAN_v3.0.md`; tournament already enters visible route in W9; later specialization worlds remain planned | `partial` | W9 onward, late specialization worlds | Keep, but defer explicit branching until the shared spine is deeper |
| `online / live` environment axis | later-world and live content families remain in route planning; no need for early learner split | `deferred but preserved` | later worlds / live layer | Keep as future metadata and world content axis, not as early UX fork |
| Checkpoint / recap chain discipline | current seam audits, checkpoints, review loop, and recap surfaces already preserve this direction | `landed` | cross-world system, W1-W11 | Keep as a permanent course rhythm |
| String runner modes like `campaign_spine`, `review_queue`, `daily_run`, `table_practice`, `foundations_check` | current `Sharky` keeps one compact shell and route system rather than many runtime modes | `rejected as runtime truth` | runtime architecture | Reject the old string-mode host shape; preserve only the cognitive jobs |
| MicroTaskStep-style world packs as a rigid host pattern | current world ladder, coverage matrix, per-world content plan, and active shell previews | `replaced intentionally` | route/content control plane | Do not restore. Keep only the idea of bounded world packets and explicit progression |
| Track handoff after shared core (`cash` vs `tournament`) | early route stays shared; later track divergence remains valid | `deferred` | after visible shared spine proves deeper continuity | Keep the idea, but not before the route earns it |
| Rich drill surface for quick taps, compares, and short decisions | current `Sharky` runner is narrower but now has typed `tableFormat` and `taskFamily` seams to absorb richer families safely | `active foundation landed` | active shell + future drill packets | Keep and extend inside the current runner |
| Math/comparison micro-drills: outs, showdown compare, pot-price feel, range counting | `MODE_FAMILY_STRATEGY_v1.md` already preserves them as near-future / later families; W7 added combo counting and W5-W6 preserve early price/draw intuition | `partial but protected` | W5-W8 now, later dedicated packets | Keep. High-EV future packet, but not a separate app mode |
| Full-ring / larger table formats | active shell now has typed `Act0TableFormatV1` and canonical seat-order helpers | `foundation landed` | active shell, later format-aware worlds | Keep and expand later. Do not ship learner-facing 9-max/10-max mode yet |

## Keep / Defer / Reject Summary

### Keep now

1. curated drill-family discipline
2. typed family expansion inside one runner
3. checkpoint / recap chain rhythm
4. future math / compare / transfer families
5. format-aware seams for larger table sizes

### Defer until the shared route is deeper

1. explicit `cash / tournament / mixed` user-facing branching
2. `online / live` learner-facing branching
3. learner-visible 9-max / 10-max modes

### Reject

1. restoring old string-based mode sprawl as runtime truth
2. restoring host-by-host architecture from old main
3. splitting early learner UX into too many forks before the shared spine is complete

## Practical Product Implication

If future work asks "should we add a whole new mode?", first ask:

1. does the idea belong to an existing drill family?
2. can it live inside the current runner through typed family support?
3. is it a later track or environment axis rather than a current UX branch?

If yes, do not create a new standalone product mode yet.

## Current Recommendation

Use this map to avoid losing strong old-main ideas while keeping current
`Sharky` compact.

Near-term high-EV preservation targets remain:

1. richer drill-family expansion inside the current runner
2. later honest `cash / tournament` branching only after the shared route is deeper
3. preserving full-ring readiness at the model/helper layer, not in early UI
