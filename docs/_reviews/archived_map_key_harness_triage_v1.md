# Archived Map Key Harness Triage v1

## 1. Verdict

`diagnosed_with_tiny_harness_fix`

## 2. Failure summary

The failing tests were the small-portrait entry guards in:

- `test/guards/world7_campaign_routing_contract_test.dart`
- `test/guards/world8_campaign_routing_contract_test.dart`
- `test/guards/world9_campaign_routing_contract_test.dart`
- `test/guards/world10_campaign_routing_contract_test.dart`

Each booted `AppRoot` and waited for one of `world_campaign_open_N`,
`world_campaign_next_pack_cta`, or `map_render_fallback_v1`. None is rendered
by the current canonical boot surface, so the common disjunction evaluated to
false. The independent deterministic campaign-routing subtests pass for W7,
W8, W9, and W10.

The prior 6.2px Home metadata-pill overflow is absent after the accepted Home
fix; the W7 guard's post-boot `tester.takeException()` assertion remains
clean. The old failure reproduces on clean `origin/main` before this local
harness correction.

## 3. Root cause

This is a stale archived map-key assertion, not a route regression. `AppRoot`
routes through `_EntryGate` to `Act0ShellPreviewScreenV1`, whose canonical
initial surface is Act0 Home. The old tests asserted map-only keys despite
booting the canonical Act0 path. Their deterministic `ProgressService` and
Today Plan subtests separately prove that each selected campaign pack remains
W7, W8, W9, or W10 respectively.

## 4. Scope proof

- Route unchanged.
- Access unchanged.
- Clickability unchanged.
- Entitlement unchanged.
- Content unchanged.
- Learn status remains the accepted local Volume I surface implementation.
- Home behavior unchanged.
- Modern Table untouched.

## 5. Test/harness changes

For each W7-W10 small-portrait guard:

- Old assertion: wait for archived map keys (`world_campaign_open_N`,
  `world_campaign_next_pack_cta`, or `map_render_fallback_v1`) and require one
  to exist.
- New assertion: wait for `act0_shell_home_screen` and the existing
  `act0_shell_main_cta`, verify both exist, verify the CTA remains visible in
  the portrait viewport, and verify its existing callback is non-null.

This matches current runtime truth without weakening route proof: the separate
deterministic tests remain unchanged and continue to assert the exact next
campaign pack for each world.

## 6. Validation

Commands run:

```bash
flutter test test/guards/world7_campaign_routing_contract_test.dart test/guards/world8_campaign_routing_contract_test.dart test/guards/world9_campaign_routing_contract_test.dart test/guards/world10_campaign_routing_contract_test.dart
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name 'Learn status header states the truthful Volume I horizon'
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name 'Levels sticky selected-world meta keeps compact headroom without hard truncation'
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name 'Future volumes open compact frontier previews without commercial copy'
dart run tools/term_coverage_scanner.dart
graphify hook-check
flutter analyze
git diff --check
git status --short
```

The W7-W10 combined focused suite passed: 8 tests, including each canonical
portrait guard and deterministic route assertion. Final command results are
recorded with the local-wave handoff.

## 7. Residuals

- `output/claude_review/` and `output/screen_review/` remain uncommitted.
- The accepted Volume I surface implementation remains local and uncommitted.
- No commit or push was performed.
- The archived map-key/actionability mismatch is resolved in the focused W7-W10
  harnesses; no product-route or UI behavior changed.

## 8. Next recommended wave

`Volume I Surface Screenshot Proof v1`

The route harness now proves the actual canonical entry and retains exact
campaign selection proof. The truthful local Volume I Learn surface is ready
for a bounded internal screenshot-proof pass.
