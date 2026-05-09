# World 2 Truth Family Queue v1

Purpose:

- compact ranked onboarding queue for remaining World 2 families
- protocol-shaped ranking without turning into a broad roadmap
- one-family-at-a-time prioritization
- runtime-anchor seam details live in `world2_runtime_anchor_source_contract_v1.md`
- semantic-boundary split lives in `world2_semantic_boundary_v1.md`
- trainer-policy seam details live in `world2_trainer_policy_contract_v1.md`
- mixed multi-step seam details live in `world2_mixed_multistep_contract_v1.md`
- hand-chain seam-gap ranking lives in `world2_hand_chain_seam_gap_audit_v1.md`
- chain-policy source normalization gap lives in `world2_chain_policy_source_gap_v1.md`

## Ranked Queue

| Family | Truth shape type | Suitability | Main blocker or reason it is suitable | Priority | Recommended next action |
| --- | --- | --- | --- | --- | --- |
| `action_choice` | trainer-policy / heuristic semantics | onboarded | first trainer-policy lane pilot is now bounded by authored `expected.actionId`, tolerated `acceptable_actions`, and current `intent_v1` buckets | high | keep compact as policy-consistency only; do not widen into solver or prose-derived strategy |
| `board_texture_classifier_v1` | bounded contract truth with exact dry-policy seam | onboarded | paired, exact connected, and authored dry rainbow calmer-board nodes now share one bounded validator seam | medium | keep compact; only extend if a genuinely new texture-policy shape appears |
| `initiative_aggressor_choice_v1` | exact-answer truth plus bounded policy-owner truth | onboarded | exact initiative questions and the authored `pressure_owner_v1` subset now resolve through one bounded validator seam | medium | keep compact; only extend if a genuinely new initiative question shape appears |
| `hand_chain_v1` | mixed multi-step semantics | bounded / covered | R258-R267 removed the tracked step-local blockers, R268-R271 onboarded the bounded pilot clusters, and R272 closes the final current capstone chain shape without adding any chain-specific engine behavior | medium | keep the family validator compact and source-driven; only reopen if a genuinely new authored hand-chain shape appears |

## Post-R247 Decision

- R249 defines the next lane as deterministic runtime-anchor truth.
- `board_tap` was the smallest safe pilot in that lane and is now onboarded.
- R250 confirms the source-symbolic seam and onboards `seat_tap` as the second family in that lane.
- R251 formalizes the canonical runtime-anchor source contract and STOPs further runtime-anchor onboarding because no remaining World 2 family fits that contract cleanly.
- R252 defines the semantic boundary: the honest next lane is trainer-policy semantics, with `action_choice` as the next pilot recommendation only after a policy contract is defined.
- R253 defines the trainer-policy contract and upgrades `action_choice` to a clean pilot candidate for future policy-consistency onboarding.
- R254 onboards `action_choice` as the first trainer-policy lane pilot with canonical policy-source validation and no current family exclusions.
- R255 re-audits the remaining policy-like residues and STOPs additional onboarding because neither the `dry` texture residue nor the initiative pressure residue currently exposes a strong enough canonical authored policy seam without prose-derived inference.
- R256 defines the mixed multi-step contract lane and audits `hand_chain_v1` as a future pilot candidate with explicit exclusions, but STOPs full-family onboarding because most current chains still contain unresolved embedded policy steps.
- R257 attempts the first bounded mixed multi-step pilot extraction and STOPs onboarding because no current `hand_chain_v1` subset is non-trivially clean under exact reuse of already-onboarded step-local contracts.
- R258 audits the step-local seam gaps, ranks the mismatch classes, and extends the highest-EV reusable seam by admitting preflop `in position` / `out of position` questions into the existing position-truth contract.
- R259 re-ranks the remaining seam gaps and extends the existing outs-truth contract to accept the same canonical cards-plus-numeric-choice shape at step level, removing the outs mismatch without introducing chain-specific logic.
- R260 re-audits the remaining action-policy mismatch and STOPs policy seam extension because the current chain steps still lack the published `action_choice` policy seam and remain dependent on prose-carried policy meaning.
- R261 defines the missing chain-policy source seam and recommends a minimal source-normalization path: keep `expected_action`, add step-local `intent_v1`, and allow step-local `acceptable_actions` when authored.
- R264 extends that same trainer-policy seam to the next bounded strong-draw assertive subset inside `hand_chain_v1`, reusing the existing action_choice policy validator without adding tolerance or chain-local rules.
- R265 re-audits the mixed draw-price pair, extracts only the manageable-price continue step as a clean singleton subset, and leaves the poor-price fold step explicitly blocked rather than forcing mixed `call` / `fold` meanings into one bucket.
- R266 confirms the remaining poor-price fold step is also a clean standalone policy subset, normalizes it with step-local intent metadata, and reuses the existing action_choice validator path without chain-specific rules.
- R267 confirms the remaining pressure-board follow-up singleton reuses the already-authored `texture_pressure_building` bucket cleanly, normalizes that step with step-local intent metadata, and clears the visible hand-chain action-policy residue without introducing any new chain-specific rule path.
- R268 onboards the first bounded mixed multi-step pilot subset for `hand_chain_v1`, limited to `chain_position_then_initiative_v1`, by validating authored two-step order and reusing the existing position and initiative truth seams without any generic chain engine.
- R269 extends that same bounded mixed-subset path to the next clean cluster, limited to `chain_position_initiative_texture_v1` and `chain_position_initiative_action_v1`, by reusing the existing position, initiative, and action-policy seams in authored three-step order.
- R270 extends the bounded mixed-subset path again to the next highest-EV clean cluster, limited to `chain_texture_outs_action_v1`, `chain_texture_outs_continue_v1`, and `chain_texture_outs_fold_v1`, by reusing the existing action-policy and outs truth seams in the same authored three-step order.
- R271 closes the remaining non-capstone singleton chain shape, limited to `chain_texture_then_outs_v1`, by reusing the same bounded mixed-subset validator pattern for authored two-step flop order without adding any chain-local handling.
- R272 onboards the final current capstone chain, limited to `chain_world2_capstone_v1`, by reusing the same bounded mixed-subset validator pattern for authored four-step order without adding any chain-specific or generic engine behavior.
- R273 performs the lane-by-lane closeout audit and records a clean World 2 truth/validation checkpoint: active validator work is closed, while the remaining `dry` texture and initiative-pressure residues stay explicitly deferred as the next highest-EV follow-up block.
- R274 re-audits those two deferred heuristic-policy residues against the trainer-policy contract and confirms that neither now exposes a strong enough canonical non-prose seam for bounded onboarding, so both remain explicitly deferred.
- R276 closes the remaining `initiative_aggressor_choice_v1` pressure-owner residue by reusing the same family validator for authored `pressure_owner_v1` / `initiative_policy_shape_v1 == pressure_owner` nodes, without widening into generic strategy inference.
- R277 closes the remaining `board_texture_classifier_v1` dry residue by reusing the same family validator for authored `board_texture_v1 == dry` nodes with `pressure_level -> calmer`, explicit board cards, and the same calmer-board action contract, without widening into generic texture strategy inference.
