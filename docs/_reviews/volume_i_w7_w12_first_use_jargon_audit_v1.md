# Volume I W7-W12 First-Use Jargon Audit v1

Status: accepted local audit artifact for the pre-Human-QA repair pack.
Date: 2026-07-01
HEAD audited: 05bd3fa4da7360d45e6cbf6f72e5804c3a840e40
Scope: W7-W12 route-visible campaign and followup copy only.

## Verdict

first_use_jargon_audit_completed_with_bounded_fixes

The W7-W12 first-use vocabulary pass found bounded machine-actionable gaps in
the W8, W9, W10, W11, and W12 route-visible copy. The fixes were limited to
existing campaign-pack copy and focused copy guards. No glossary system, new
dependency, mapper allowlist, Practice CTA, W13+, or broad rewrite was added.

## Term Audit

| Term | First route-visible owner | Status | Action taken | Remaining watchlist |
| --- | --- | --- | --- | --- |
| visible cards | `world7_spine_campaign_v1` | verified_safe | Already tied to visible board cards narrowing possible ranges. | Human QA should still watch whether community-card framing lands. |
| range / range narrowing | `world7_spine_campaign_v1` | verified_safe | Already connected to W6 and possible hands. | W6-to-W7 pivot remains human-observable. |
| possible hands | `world7_spine_campaign_v1` | verified_safe | Already paired with visible-card narrowing and exact-hand caution. | Watch for over-removal confusion. |
| draw | `world8_spine_campaign_v1` | fixed | Added W5 outs/draw reconnect in first W8 route-visible context. | Watch whether W5 recall is enough for beginners. |
| flush draw | `world8_spine_campaign_v1` | fixed | Kept first flush-draw use tied to future-card improvement and removed "already complete" wording. | Watch whether suit path is clear. |
| open-ended straight draw | `world8_spine_campaign_v1` | verified_safe | Already defined as either end completing the straight. | Human QA should inspect terminology burden. |
| one-gap / gutshot-style draw | `world8_spine_campaign_v1` | verified_safe | Already introduces gutshot as non-required jargon and defines narrower path. | Watch whether "one-gap" is intuitive. |
| pot | `world9_spine_campaign_v1` | fixed | W9 first route-visible context now connects draw spotting to call price and pot reward. | Watch whether pot reward remains beginner-safe. |
| call price | `world9_spine_campaign_v1` | fixed | W9 first context now asks whether the call price is worth paying. | Watch quasi-math load. |
| odds | `world9_spine_campaign_v1` | verified_safe | Pot odds remain framed as price/risk/reward, not math proof. | Watch whether odds wording intimidates beginners. |
| risk / reward | `world9_spine_campaign_v1` | verified_safe | Already beginner-contextualized by price versus pot reward. | Watch for arithmetic confusion. |
| value bet / value | `world10_spine_campaign_v1` | fixed | W10 first route-visible context now distinguishes W4 and W9 before value wording. | Watch whether "value" feels intuitive. |
| worse hands call | `world10_spine_campaign_v1` | fixed | Guard now requires W10 first-use context and worse-hands target. | Watch whether target-hand framing lands. |
| stronger hands fold | `world10_spine_campaign_v1` | fixed | Guard now requires W10 first-use context and stronger-hands target. | Watch whether pressure target is understood. |
| dry board | `world11_spine_campaign_v1` | verified_safe | Already defined as fewer clear links and fewer straight/flush paths. | Watch "dry" vocabulary. |
| connected board | `world11_spine_campaign_v1` | verified_safe | Already defined as close ranks creating more paths. | Watch danger intensity. |
| suited texture | `world11_spine_campaign_v1` | fixed | Soft-claim cleanup changed "suits never matter" to "ignore suits completely." | Watch suit-pressure clarity. |
| danger | `world11_spine_campaign_v1` | fixed | Soft-claim cleanup removed "always safe" and "guarantee" phrasing around danger. | Human QA should observe W11 danger framing. |
| board texture | `world11_spine_campaign_v1` | verified_safe | Already tied to dry, connected, suited, and danger clues. | Watch whether texture feels abstract. |
| missed cue | `world12_spine_campaign_v1` | fixed | W12 payoff copy now explicitly names Volume I cue families and missed-cue explanation. | Watch payoff feel versus quiz feel. |

## Guard Coverage

Added `test/guards/w7_w12_first_use_jargon_contract_test.dart`.

Updated focused guards:

- `test/guards/w8_route_admission_depth_gate_contract_test.dart`
- `test/guards/w9_route_admission_depth_gate_contract_test.dart`
- `test/guards/w10_route_admission_depth_gate_contract_test.dart`
- `test/guards/w12_route_admission_review_payoff_gate_contract_test.dart`

The guards prove W8 reconnects to W5 outs/draw vocabulary, W9 bridges draw to
call price, W10 distinguishes W4 and W9 before bet-purpose work, W12 names the
Volume I payoff, and W12 terminal copy explains the terminal state.

## Claim Safety

No solver, GTO, mastery, public readiness, launch readiness, top-1, 10/10,
Human QA pass, public learning-effect, monetization, mapper, Practice CTA, or
W13+ opening claim was added.
