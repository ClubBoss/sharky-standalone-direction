# World 2 Dense Shape Audit v1

Purpose:

- audit the gap between the current surfaced World 2 bridge and a denser, more self-sustaining World 2 world shape
- identify bounded next blocks only where the live repo already has enough structure to support them
- avoid broad World 2 rewrite planning

## Candidate Summary

| Gap / block | SSOT truths that apply | Current state | Why it is a gap | Suitability | Why |
| --- | --- | --- | --- | --- | --- |
| surfaced World 2 followup density / branch visibility | pacing, prerequisite/difficulty, release-gate, retention, session energy, long-horizon mastery | World 2 already has `world2_spine_campaign_v1` plus `world2_spine_followup_v1_b0`, `b1`, and `b2`, but the surfaced world-shape truth and main route behavior still read like a thin bridge anchored mostly on campaign + one chosen followup | existing authored followup depth is real, but the learner-visible world shape still underrepresents it; this keeps World 2 looking thinner than the repo’s actual bounded content base | now | bounded, high EV, low rewrite risk, and grounded in already-authored packs and existing routing surfaces |
| world-scale recap / checkpoint structure across all surfaced World 2 packs | pacing, retention, session energy | local pack-level rhythm improved, but world-level recap/checkpoint identity is still mostly borrowed from generic map rhythm instead of a World 2-specific structure | dense worlds usually need a more explicit recap/checkpoint cadence than a bridge | later | real gap, but cleaner after the surfaced followup shape is made more honest first |
| broader World 2 density expansion beyond current authored bridge packs | pacing, prerequisite/difficulty, long-horizon mastery, release-gate | current bridge is still intentionally small relative to a dense world | true dense-world status would require more families, more recap structure, and broader coverage | too broad | broadens immediately into world-building rather than a bounded governance/application block |
| world-scale variation cadence across all World 2 content | retention, session energy | current local campaign stretch is improved, but broader World 2 cadence still depends on a thin surfaced path | hard to evaluate honestly while the surfaced shape still underexposes authored followups | later | should be revisited after surfaced density/branch visibility is corrected |
| world-scale prerequisite ladder completeness | prerequisite/difficulty, pacing | current bridge is order-safe, but it is not yet a complete world ladder | remaining ladder questions collapse into “what full World 2 should become” rather than one bounded block | too broad | not honest to solve before the surfaced bridge shape is made denser and more explicit |

## Selection Result

- selected next bounded block:
  - surfaced World 2 followup density / branch visibility audit-and-alignment block

## Why This Block Wins

It dominates on the requested criteria:

- boundedness
  - uses existing World 2 authored followup packs already present in repo
- direct product EV
  - improves the learner-visible shape of World 2 without inventing a new world
- low rewrite risk
  - likely truth/routing/surfacing alignment rather than new curriculum authoring
- compatibility with current implemented surfaces
  - the map, truth map, and progress routing already know about World 2 spine/followup pack ids

## Operational Boundary

This next block should stay bounded to:

- how the current surfaced World 2 shape represents and routes existing followup depth
- whether one chosen followup is underrepresenting a denser bounded bridge
- truth / topology / surfacing alignment for existing World 2 packs

It should not broaden into:

- authoring a full new World 2 curriculum
- adding new worlds
- redefining the entire cross-world map shape

## Post-R319 Re-audit

- bounded surfacing/alignment fixes now landed:
  - `world2_streets_demo_v1` anchors after the first available surfaced World 2 followup branch, not only `b2`
  - World 2 completion semantics treat any surfaced followup branch (`b0`, `b1`, `b2`) as completion
- current block status:
  - effectively saturated for the bounded followup density / branch visibility scope
- remaining `b2`-shaped residue:
  - broader progress/rank semantics still include `b2`-oriented assumptions in generic completion-count helpers and downstream tests
  - that residue no longer fits this bounded World 2 surfacing block
  - it should be handled, if needed, as a later broader progress semantics audit rather than forced here

## Post-R321 Re-audit

- bounded generic semantics fix landed:
  - campaign rank/progress world counting now delegates to canonical world-completion semantics instead of `_b2`-only counting
- current status after the generic audit:
  - no further honest bounded generic progress/rank semantics gap remains
- remaining `_b2` references now split into:
  - intentional band/routing semantics
  - test seed shapes
  - broader progression-system policy questions
- those residues should not be treated as another local World 2 surfacing or generic rank-count fix

## Post-R323 Re-audit

- broader campaign-complete / cross-world completion policy was audited next
- result:
  - no single additional policy gap is honestly bounded enough for a local fix
- reason:
  - the remaining completion-policy residue splits across:
    - intentional World 1 campaign-complete gating
    - intentional band/routing semantics
    - broader cross-world progression policy
- boundary:
  - this is no longer a World 2 surfacing or local generic progress-semantics issue
  - any future change here should be treated as a broader progression-policy block, not forced as another bounded cleanup
