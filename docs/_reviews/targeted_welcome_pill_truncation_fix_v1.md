# Targeted Welcome Pill Truncation Fix v1

## 1. Verdict

`welcome_pill_truncation_fixed`

The Welcome handoff launch-proof row no longer clips the middle `Quick check` pill in the compact first-week screenshot. This packet makes no readiness, Human QA, public, top-1, or 10/10 claim.

## 2. Before Evidence

- Source verification: `Visual Polish Verification v1` rerun on branch `codex/apply-owner-patch-sequence-a-b-c-d-v1` at `941c2e7f667c2a61208c77ae788891f01f371388`.
- Before screenshot: `output/screen_review/current/first_week_fast/compact.welcome_handoff.png`.
- Finding: the middle launch-proof pill rendered as `Quick che`, while `Answer` and `First hand` remained readable.
- Guard proof before fix: the focused Welcome test failed because `Quick check` rendered at width `64.66666666666669` against measured label width `111.31999969482422`.

## 3. Fix Summary

- Owner file: `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`.
- The launch-proof row now uses an intrinsic `Wrap` instead of forcing three equal-width `Expanded` slots.
- Each launch-proof pill keeps its icon, label, tone, and state.
- The chip label no longer uses fade overflow inside a constrained slot.
- Route logic, CTA behavior, Profile, Review, motion tooling, mapper/Practice, W13+, monetization, and Modern Table were not changed.

## 4. After Evidence

- Regenerated only: `./tools/screen_review_fast_v1.sh first_week compact`.
- After screenshot: `output/screen_review/current/first_week_fast/compact.welcome_handoff.png`.
- Result: `Answer`, `Quick check`, and `First hand` are all readable.
- CTA remains clear and bottom anchored as `Open first lesson`.
- `output/**` stayed local-only and unstaged.

## 5. Validation

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name "Welcome completes one local micro win before Home handoff"`: pass after fix.
- `flutter analyze`: pass, no issues.
- `graphify hook-check`: pass.
- `git diff --check`: pass.
- `git diff --cached --check`: pass.
- Screenshot regeneration command: pass.

## 6. Commit Hash

- Commit hash: reported in the final handover because the containing commit cannot embed its own final hash.
- Commit message: `polish: prevent welcome proof pill truncation`.

## 7. Remaining Watchlist

- SR-02 Review dead space remains outside this targeted fix.
- Motion evidence gap remains outside this targeted fix.
- Blank CTA capture artifact remains outside this targeted fix.
- GR-14 minor phrasing remains outside this targeted fix.
- G10 bridge visual coverage remains outside this targeted fix.
- The unrelated brittle assertions previously listed in `small_10_10_visual_polish_followup_v1.md` remain outside this targeted fix.

## 8. Next Prompt Recommendation

`Visual Polish Verification v1b`

Use `Whole-Product UX/UI Coherence + Redesign EV Audit v1` only after the targeted verification pass is clean and if a broader product-design audit is intentionally reopened.
