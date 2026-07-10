# Table identity policy — Wave C marker completion

Wave C is green. `_resolveSeatMarkerDisplayV1` now accepts the transported `Act0TableIdentityPolicyV1` and gates only the dealer marker. `currentProduction` preserves its existing marker list; `learnerOnly` and `learnerPosition` omit the dealer marker; `learnerPositionAndDealerOrder` retains exactly one dealer marker. Poker-state `isDealerButton`, labels, seats, and geometry are unchanged.

Focused widget coverage verifies the four policies against the production scene key, including `You · BTN` plus exactly one dealer marker for dealer-order. Wave B label, semantic metadata, and W7–W12 table-context guards also pass. Evidence remains local-only under `output/evidence/table_identity_policy_phase_a_v1/wave_c_markers/` pending the production pilot capture pass.
