---
status: "undeclared"
status_source: "absent"
baseline: "b6d2ec67c258"
generated_by: "docs_frontmatter_v1"
---

# Compact Decision Lower-Slot Rebalance v1

Terminal verdict: `compact_decision_lower_slot_rebalance_v1_accepted`

## Scope and result

- Branch / baseline HEAD: `claude/hub-surface-coherence-audit-plan-v1` /
  `b6d2ec67c2583c6b290029b9e33e2a0b086e4b37`.
- This implements Option A from
  `table_decision_compact_layout_contract_audit_v1.md`.
- Files changed:
  - `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
  - `test/ui_v2/compact_decision_lower_slot_rebalance_v1_test.dart`
  - this review artifact

## Option decision

Option A was safe enough because the source already has one ordinary compact
answer-list envelope owner and can classify an answer list before allocating
that envelope. The implemented rule is one deterministic content profile, not
a per-world treatment:

```text
four options exactly
AND every localized option label is 36 characters or fewer
AND no option has an amount label
```

Option B (a measured shared table/question vertical contract) is deferred. It
would replace the mature fixed-envelope model and requires a broad matrix of
intrinsic-height, localization, text-scale, and device testing. Option A
addresses the observed dead band without that rewrite.

## Exact allocation rule

Before, every ordinary compact answer-list decision used the same lower-slot
policy: target 50% of usable height, clamped to 365--405 px, with a 54% maximum
share.

After, only the flat four-option profile above uses a 320 px target, a 300 px
minimum, and a 47% maximum share. The reclaimed upper-slot height is passed to
the existing table max-height cap. All other ordinary compact answer lists keep
the old policy.

The rule reads only rendered option content and amount metadata. It does not
read world number, W11/W12 wording, route id, terminal state, capture filename,
or screenshot lane.

## Protected cases

- Long, three-option decision lists remain outside the new profile.
- Priced four-option lists remain outside the new profile and retain the old
  lower-slot table bound in the focused test.
- Review protection and repair-fill continue through their existing branches;
  neither uses the ordinary short-answer override.
- Table-tap decisions do not use the answer-list envelope.
- W1/W2--W10 semantics, scoring, route/progression, and telemetry are
  unchanged.
- W11/W12 retain their accepted centre-lane `Transfer` / `Reset` signal; the
  W12 terminal payoff and W13 lock are untouched.

## Validation

Passed:

- `flutter test test/ui_v2/compact_decision_lower_slot_rebalance_v1_test.dart test/ui_v2/act0_w11_w12_late_route_table_signal_differentiation_v1_test.dart` — 6 tests.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_legacy_backlog.dart --plain-name 'Placement diagnostic keeps Hero cards above dock with simulator safe area'` — passed.
- `flutter analyze` — no issues.
- `git diff --check` — passed.
- `graphify hook-check` — passed.

Known baseline-only result:

- The nearby long-three-option test (`Compact drill stacks long 3-option answer
  labels when the row budget is exceeded`) reports an 8.8 px horizontal
  `RenderFlex` overflow both with this rule enabled and with the predicate
  temporarily disabled. It is pre-existing, unrelated to lower-slot
  allocation, and was not repaired in this wave.

## Raw compact evidence

Evidence is local only and uncommitted:

- Root: `output/compact_decision_lower_slot_rebalance_v1/`
- W1 baseline (unchanged table-tap reference):
  - before: `before/w1_runner_decision.png`
  - after: `after/w1_runner_decision.png`
- W11 active table:
  - before: `before/w11_table.png`
  - after: `after/w11_table.png`
- W12 active table:
  - before: `before/w12_table.png`
  - after: `after/w12_table.png`

The source capture commands were:

```bash
dart run tools/act0_real_text_surface_capture_v1.dart runner compact
dart run tools/act0_real_text_surface_capture_v1.dart active_route_w7_w12 compact
```

## Before / after assessment

- **Table breathing room:** W11 and W12 tables are visibly taller, with more
  room around their centre board/status lane and hero-seat region.
- **Lower dead band:** the substantial empty region below the four-option
  decision card is materially reduced; it is no longer the dominant lower-half
  visual feature.
- **Table-to-dock connection:** preserved. The card still begins directly
  below the table rather than becoming a detached footer.
- **Options and bottom clearance:** all four choices remain visible and
  readable. The focused compact test preserves 44 px targets and verifies that
  the final option stays inside the 812 px viewport.
- **W1 baseline:** the captured W1 table-tap reference is unchanged, as it is
  not an answer-list decision.
- **Capture caveat:** these are raw real-text widget-test captures. No
  post-capture text repair was changed or used to justify layout behavior.

## Debt ledger / return queue

| ID | Item | Disposition |
| --- | --- | --- |
| CDL-001 | Flat four-option compact decisions over-reserved the lower slot. | Closed by this bounded rule. |
| CDL-002 | Other short answer-list geometries may need intrinsic shared allocation rather than another profile rule. | Defer to Option B only if new evidence shows a remaining material dead band. |
| CDL-003 | Long-three-option legacy fixture has an 8.8 px horizontal overflow independent of this change. | Separate compact-row rendering debt; do not mix into lower-slot work. |
| CDL-004 | W12 capture post-processing can alter valid raw evidence. | Separate evidence-pipeline debt. |

No 10/10 assessment, public readiness, Human QA readiness, Human QA result,
mastery claim, W13 admission, or terminal-route change is made by this wave.
