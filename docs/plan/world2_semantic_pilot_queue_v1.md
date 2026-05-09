# World 2 Semantic Pilot Queue v1

Purpose:

- record the next bounded semantic validator-family candidates after the visible-card showdown pilot reached saturation
- keep candidate status explicit
- identify whether one clean next family is honestly ready now

## Candidate Summary

| Family | Current authored pressure | Deterministic truth source | Current coverage status | Suitability | Why |
| --- | --- | --- | --- | --- | --- |
| `showdown_winner_choice_v1` visible-card micro-family | strong explicit hand/category/winner wording in 3 authored visible-card drills | visible hero cards + visible villain cards + full board | semantically saturated for the current pilot | not next | Current authored contradiction pressure is already covered; remaining uncovered categories are not authored in the current pilot corpus |
| `showdown_winner_choice_v1` review bridge residue | resolved | visible review drill now carries the same deterministic card payload as the bridge drills | covered by current validator | closed | No remaining authored review residue exists inside the current showdown family |
| `outs_count_choice_v1` core outs family | explicit authored outs labels and fixed counts already present | visible board/hole cards + authored expected count | onboarded with bounded validator | possible later family | A future bounded extension is possible only if new authored pressure appears for combo draws, overcards, or richer outs language; current authored family is already adequately covered |
| `board_texture_classifier_v1` dry residue | prose pressure exists, but current `dry` meaning still leans heuristic-policy rather than stable semantic truth | board cards are visible, but current authored source/copy does not yet form a clean canonical truth seam for `dry` | partial; dry residue intentionally deferred | not suitable yet | Still documented as heuristic-policy coupled, not an honest deterministic semantic family for the next pilot |
| `initiative_aggressor_choice_v1` pressure residue | pressure wording exists in authored copy | seat/action context is partly present, but current pressure meaning is still prose-coupled | partial; pressure residue intentionally deferred | not suitable yet | This is still a heuristic policy seam, not a clean poker-semantics validator family |
| `action_choice` family | strong authored pressure exists, but it is policy/decision semantics rather than poker-truth semantics | local action context + source policy metadata | already covered through trainer-policy lane | not next | Important family, but it is not the next semantic validator pilot; it belongs to policy validation, not poker semantics hardening |
| `hand_chain_v1` mixed families | strong authored pressure exists, but across multi-step policy/reasoning chains | structured chain state + step-local truth/policy seams | already covered for current family scope | not next | Mixed-chain validation is already onboarded and is not the next bounded semantic-family expansion |

## Selection Result

- current best result:
  - STOP
- reason:
  - no next World 2 family is both:
    - already pressured strongly enough by authored semantic copy
    - deterministic from current source truth
    - not already covered/saturated
    - bounded enough to avoid broadening into a generic poker engine or heuristic-policy rewrite

## Why No Family Wins Now

### Showdown

- the current visible-card showdown pilot is semantically saturated
- the remaining hand-category terms in `POKER_SEMANTICS_TRUTH_v1` such as `trips`, `set`, `flush`, and higher made-hand wording do not yet appear in the authored visible-card pilot corpus

### Outs

- the current authored outs family already has a bounded validator seam
- a next semantic expansion would require new authored pressure, not just speculative taxonomy growth

### Texture / Initiative Residues

- both remaining residues are still documented as heuristic-policy coupled rather than clean semantic truth
- pushing them into “semantic pilot” status now would hide that boundary instead of preserving it

## Canonical Next Trigger For Reopening Selection

Reopen this queue only when one of these becomes true:

- new World 2 authored visible-showdown copy introduces explicit additional made-hand categories inside a visible-card deterministic boundary
- new World 2 outs content introduces explicit richer semantic pressure such as combo-draw or multi-source outs wording
- a currently deferred heuristic residue is upgraded into a clean structured truth seam rather than prose-derived policy wording

## Operational Rule

Do not force another semantic pilot family just because the showdown pilot is saturated.

The next family should be selected only when authored pressure, deterministic source truth, and bounded validator scope all align honestly.
