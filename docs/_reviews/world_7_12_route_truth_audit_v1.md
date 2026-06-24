# World 7-12 Route Truth Audit v1

## 1. Verdict

`accepted_with_route_gaps`

W7-W10 have active-root authored shelves, canonical campaign/session
registrations, learner-route entries, and focused route tests. W11-W12 have
curriculum and historical-calibration definitions but no active-root content
shelves, canonical campaign/session registrations, or route tests. They are
not current learner-route worlds.

## 2. Source truth map

| Source | W7-W10 evidence | W11-W12 evidence | Authority for this audit |
| --- | --- | --- | --- |
| Active runtime route | `ProgressService` deterministically advances campaign packs through W7-W10; map keys `world_campaign_open_7` through `_10` exist | none found | current route evidence |
| Canonical map | `canonical_truth_map_v1.dart` declares W7-W9 session lists and W7-W10 campaign packs | none found | current campaign/session ownership |
| Content shelves | `content/worlds/world7` through `world10` exist with session/drill files | directories absent | authored-source evidence only |
| Route tests | W7-W10 campaign-routing contracts exercise an actionable entry and deterministic next pack; their current small-portrait assertions share a Home-shell overflow failure | none found | learner-route proof, with baseline UI residue |
| Content root policy | authored route on disk is `world0` through `world10` | explicitly no later standalone top-level family | active-root boundary |
| Historical calibration | labels W7-W12 release-strong and visible | same | quality/calibration evidence, not runtime authority |
| Current planning | Volume I is W1-W12; later route must stay honest | W11-W12 planned definitions; W13+ locked | curriculum/representation policy |
| Surface docs | Learn should show locked states honestly and retain one forward route | same | future-surface constraint |

## 3. World-by-world truth table

| World | Theme | Shelf | Authored lessons/drills | Runtime route entry | Learner-visible access | Tests | Historical calibration | Current route truth | Safe representation | Risk |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| W7 | Range Thinking Lite | yes | yes; `w7.s01`-`.s10` session family | yes; canonical campaign/session map | yes; map entry/next-pack contract | yes; deterministic routing passes, portrait assertion currently fails on shared Home overflow | release-strong | campaign-routed, but public release claim is not independently revalidated here | playable | do not imply full mastery or W12 completion |
| W8 | Stack Depth And Risk | yes | yes; `w8.s01`-`.s10` session family | yes; canonical campaign/session map | yes; map entry/next-pack contract | yes; deterministic routing passes, portrait assertion currently fails on shared Home overflow | release-strong | campaign-routed, but public release claim is not independently revalidated here | playable | do not present SPR/sizing as solver-level depth |
| W9 | Tournament Pressure | yes | yes; `w9.s01`-`.s10` session family | yes; canonical campaign/session map | yes; map entry/next-pack contract | yes; deterministic routing passes, portrait assertion currently fails on shared Home overflow | release-strong | campaign-routed, with ICM still intentionally light | playable | no ICM-mastery or specialization claim |
| W10 | Player Adjustment | yes | yes; campaign and Cash/MTT/Mixed track sessions | yes; campaign plus track routing | yes; map entry/next-pack contract | yes; campaign run passes, portrait assertion currently fails on shared Home overflow | release-strong | campaign-routed | playable | tracks do not prove a completed specialization program |
| W11 | Real Play Transfer / Capstone | no | no active-root shelf found | no | no | no | release-strong | planned curriculum only | planned-only | historical quality row cannot substitute for a route |
| W12 | Variance, Decisions, And Mindset | no | no active-root shelf found | no | no | no | release-strong | planned curriculum only | planned-only | cannot claim Volume I completion or W13 readiness |

## 4. Conflict reconciliation

The conflict resolves by source role, not by averaging evidence:

1. The historical Volume I calibration is useful quality evidence. It asserts a
   release-strong W1-W12 ladder, but it does not identify current runtime pack
   IDs, active-root shelves, or current learner-visible entries for W11/W12.
2. The active content-root policy is explicit: authored world route on disk
   ends at `world10`.
3. Current runtime evidence proves W7-W10 rather than merely authored shelves:
   canonical campaign packs, canonical session lists, ProgressService routing,
   map keys, and focused routing tests align.
4. No corresponding active evidence was found for W11/W12. Their long-term
   themes remain valid curriculum definitions, but their safe product state is
   planned-only.

Accordingly, the correct current statement is not "W7-W12 are unverified" and
not "W1-W12 are all current playable worlds." It is: **W7-W10 are
campaign-routed; W11-W12 are planned-only; the old W1-W12 release-strength
claim is not a current-route claim for W11/W12.**

## 5. Safe claims policy

Sharky may say W7-W10 are current course continuation worlds with playable
campaign access. It may describe W11-W12 as planned foundation topics, not as
current learner-route content. It may describe Volume I as the intended shared
W1-W12 foundation only when its current route state is separately qualified:
the active-root routable portion ends at W10. W12 -> W13 is not an available
gateway; W13+ remains a locked later frontier.

Forbidden claims:

- W11/W12 are playable, release-grade, unlocked, or completed.
- W1-W12 completion is currently achievable in the active route.
- W13+ is available through premium access, an unlock, or specialization.
- W7-W10 prove AI/adaptive coaching, mastery, leaks resurfacing, or a complete
  Cash/MTT program.
- Historical calibration alone proves current user-visible access.

## 6. Surface implication

A future Volume I surface may show W7-W10 as playable current continuation,
provided the exact campaign route is retained and no broad completion claim is
made. It must show W11-W12 as planned foundation / coming later, not locked
premium content. It may show W13+ only as a compact later frontier. It must not
render a W12 -> W13 gateway until W11/W12 have authored, routable, tested
evidence and a separately admitted readiness contract.

## 7. Missing proof ledger

| World(s) | Severity | Missing proof | Why it matters | Smallest future proof action | Implementation required |
| --- | --- | --- | --- | --- | --- |
| W11-W12 | P0 for completion claims | shelf, canonical pack/session, learner entry, and route test | prevents false Volume I completion | document/decide whether these are deferred or admit one bounded route-proof slice | yes, if they are to become playable |
| W7-W10 | P1 | current external/human route proof and term/drill-density audit | routing does not prove content quality at public promise level | audit active sessions and terminology without changing content | no |
| W7-W10 | P1 | small-portrait entry presentation | all four focused route suites currently fail the same 6.2px Home metadata-pill overflow before/around entry visibility | separately diagnose the shared Home shell; no fix in this docs-only audit | yes, in a separately admitted UI wave |
| W7-W10 | P1 | explicit public access/entitlement policy | campaign reach is not a commercial access claim | document access state before surface/package work | no |
| W10 | P1 | track semantics versus long-term specialization policy | Cash/MTT/Mixed route is not the W12 specialization gateway | record boundary and naming contract | no |
| W10-W13 | P1 | transition contract | prevents a false frontier handoff | create W12 -> W13 readiness contract after W11/W12 truth is resolved | no initially |
| W7-W12 | P2 | screenshots/proof packet | useful for external review, not source truth | defer until a real recipient exists | no |

## 8. Next recommended wave

`36-World Curriculum SSOT Contract v1`

The audit has enough evidence to classify W7-W10 and W11-W12, but it exposed a
cross-document terminology conflict: historical calibration uses a visible
W1-W12 release claim while active-root route truth ends at W10. A small SSOT
contract should define canonical status vocabulary and precedence before any
new W11/W12 route proof or Volume I surface work is admitted.
