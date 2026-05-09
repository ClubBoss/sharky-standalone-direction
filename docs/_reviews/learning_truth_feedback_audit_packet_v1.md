# Learning Truth & Feedback Audit Packet v1

## 1) Purpose
Enable an external reviewer to audit learning-truth integrity and feedback usefulness on a representative, bounded content sample without loading the full repository.

## 2) Project constraints
- Deterministic only.
- No ML.
- No pseudo-solver behavior.
- No broad rewrite; keep fixes bounded.
- Audit focus: learning truth and feedback usefulness.

## 3) Current relevant guardrails/tools
- `tools/why_v1_ssot_v1.dart`: shared deterministic guards for `why_v1` validity, prompt-answer leakage patterns, and feedback label mismatch.
- `tools/validate_world_content_v1.dart`: deterministic content validator (structure, pacing, role coverage, mixed-checkpoint markers, drill/session integrity, `why_v1` and leakage checks).
- `tools/run_content_qa_r2_v1.dart`: deterministic QA runner that executes validator + worlds 0-4 scoreboard/progression/telemetry/session-chain audits.
- `test/tools/why_v1_ssot_v1_test.dart`: targeted deterministic tests for placeholder rejection, feedback-label mismatch, and leakage fences.

## 4) Curated sample set (22 files)

### Early worlds
- `content/worlds/world0/v1/sessions/w0.s10/drills/d.find_btn_focus.json`
  Reason: baseline deterministic seat-anchor drill with concise `why_v1`.
- `content/worlds/world0/v1/sessions/w0.s10/drills/d.choose_raise_focus.json`
  Reason: minimal action-only prompt useful for checking feedback/learning-EV thinness.
- `content/worlds/world1/v1/sessions/w1.s02/drills/d.find_sb.json`
  Reason: early-world seat drill with explicit `intent_v1` and non-placeholder `why_v1`.
- `content/worlds/world1/v1/sessions/w1.s05/drills/d.choose_call_repeat.json`
  Reason: repeated action pattern helps assess over-template risk in prompt phrasing.
- `content/worlds/world2/v1/sessions/w2.s02/drills/d.choose_raise_btn_open.json`
  Reason: comparatively strong action rationale and explicit expected-action feedback.
- `content/worlds/world2/v1/sessions/w2.s02/drills/d.choose_call_btn_defend.json`
  Reason: good control example with action-specific incorrect feedback text.
- `content/worlds/world2/v1/sessions/w2.s10/session.md`
  Reason: checkpoint session-level wording includes “expected legal branch” framing to audit pedagogical clarity.

### Mid worlds
- `content/worlds/world3/v1/sessions/w3.s02/session.md`
  Reason: session instructions use “expected action” phrasing that may feel answer-led.
- `content/worlds/world3/v1/sessions/w3.s10/session.md`
  Reason: checkpoint language repeatedly references expected action, useful for leakage-style wording review.
- `content/worlds/world3/v1/sessions/w3.s02/drills/d.find_btn_turn_chain.json`
  Reason: chain-adjacent sequencing drill for order/truth integrity checks.
- `content/worlds/world5/v1/sessions/w5.s05/drills/d.choose_raise_completed_closure.json`
  Reason: comparatively strong example where explanation/feedback explicitly justify the target action.
- `content/worlds/world5/v1/sessions/w5.s10/drills/d.choose_raise_checkpoint.json`
  Reason: direct “choose raise” cue sits near prior leakage-cleanup boundary classes.
- `content/worlds/world6/v1/sessions/w6.s03/session.md`
  Reason: full `TODO` session scaffold is likely pedagogically weak and should be classified by severity.
- `content/worlds/world6/v1/sessions/w6.s03/drills/d.chain_flop_turn_pressure.json`
  Reason: multi-step `hand_chain_v1` (2-step) with mixed step schema (`range_bucket_v1` then action) for truth-consistency review.
- `content/worlds/world6/v1/sessions/w6.s03/drills/d.chain_flop_turn_river_v1.json`
  Reason: multi-step `hand_chain_v1` (3-step) covering action + preset + acceptable variants; strong target for feedback quality audit.

### Late worlds
- `content/worlds/world7/v1/sessions/w7.s04/session.md`
  Reason: `TODO`-only session text in late world is a high-value trust/learning-EV audit candidate.
- `content/worlds/world8/v1/sessions/w8.s06/drills/d.choose_raise_short_push.json`
  Reason: late-world action drill with richer risk-premium rationale provides a stronger comparison point.
- `content/worlds/world8/v1/sessions/w8.s10/session.md`
  Reason: `TODO`-only checkpoint session text tests result/review integrity in later progression.
- `content/worlds/world9/v1/sessions/w9.s07/drills/d.choose_raise_blocker_exploit.json`
  Reason: exploit-focused action item where reviewer can test whether explanation is specific enough to action.
- `content/worlds/world9/v1/sessions/w9.s07/drills/d.choose_call_blocker_exploit.json`
  Reason: paired with the raise variant to detect truth/feedback differentiation quality.
- `content/worlds/world10/v1/sessions/w10.s01/drills/d.choose_raise_track_baseline.json`
  Reason: explicit ordinal-cue template (“When the second cue appears…”) directly relevant to prior leakage guard family.
- `content/worlds/world10/v1/sessions/w10.s01/drills/d.choose_call_track_baseline.json`
  Reason: explicit template phrasing (“In this spot, choose the best action…”) is a key leakage-style audit sample.

## 5) Suggested audit questions
- Prompt leakage: does wording leak the target action (directly or by template cues) instead of testing reasoning?
- Truth integrity: do `prompt`, `expected`, `why_v1`, and feedback lines agree without contradiction?
- Feedback usefulness: does incorrect feedback explain what was wrong in a learning-useful way, not just restate failure?
- Learning EV: does each item train transferable decision skill versus rote template response?
- Result/review integrity: do session/drill artifacts support trustworthy review outcomes (especially checkpoint and chain flows)?

## 6) Minimal reviewer instructions
- Classify every finding as:
  - `P0` trust/logic,
  - `P1` learning-EV,
  - `P2` wording/polish.
- Prefer smallest bounded fixes over broad rewrites.
- Tag each issue by fix locus:
  - tooling guard,
  - content cleanup,
  - runtime presentation.
