# Volume I Surface Contract Implementation v1

## 1. Verdict

`implemented_surface_contract`

## 2. What changed

Exact files changed:

- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `docs/_reviews/volume_i_surface_contract_implementation_v1.md`

The existing Learn levels-menu sticky header now represents the Volume I
horizon. Its historic dynamic active-world status was replaced with
`W1-W6 available · W7-W10 current campaign`. The same informational header
adds `W11-W12 planned foundation chapters, coming later.` and
`W13+ is later strategic depth.` Its Volume I summary is now `Current
foundation`.

No new card, route, CTA, or tap target was introduced. The existing Volume II
and III preview behavior remains unchanged.

## 3. Scope proof

- Route unchanged: the existing world selection and continuation callbacks are
  untouched.
- Access unchanged: no world state, eligibility, or availability changed.
- Clickability unchanged: the new W11-W12 and W13+ lines are plain text; the
  existing current-route behavior is unchanged.
- Entitlement unchanged: no entitlement or commerce seam was touched.
- Content unchanged: no world/session content changed.
- W11-W12 remain planned and informational only.
- W13+ remains frontier-only and informational only.
- Modern Table is untouched.
- No paywall, trial, upgrade, purchase, or premium copy was added.

## 4. Status contract compliance

| World range | Surface representation |
| --- | --- |
| W1-W6 | `available` in the Learn header. |
| W7-W10 | `current campaign` in the Learn header. |
| W11-W12 | `planned foundation chapters, coming later`; no action. |
| W13-W24 | `later strategic depth`; no action. |
| W25-W36 | Continues to use the existing `Advanced frontier` Volume III preview; no action. |

## 5. Copy contract compliance

The touched Learn seam contains none of: `Finish Volume I now`, `Complete
W1-W12`, `Unlock W13`, upgrade, premium-specialization, AI/leak, mastery, or
Cash/MTT availability claims. The existing future-volume copy remains a
future-landmark explanation and does not imply access.

## 6. Tests / guards

Focused tests added or updated:

- `Learn status header states the truthful Volume I horizon`
- existing compact header and future-volume preview tests

Commands run:

```bash
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name 'Learn status header states the truthful Volume I horizon'
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name 'Levels sticky selected-world meta keeps compact headroom without hard truncation'
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name 'Volume strip shows active and future frontier states'
flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name 'Future volumes open compact frontier previews without commercial copy'
dart run tools/term_coverage_scanner.dart
graphify hook-check
flutter analyze
git diff --check
git status --short
```

The focused header, compact-header, and future-volume tests passed during this
implementation. Final command results are recorded with the wave handoff.

## 7. Residuals

- The archived map-key/actionability route-harness mismatch remains separate
  and untouched.
- W11-W12 route proof remains separate.
- External/App Store packaging remains deferred.
- No mastery, leak, AI, or specialization claim is introduced.

## 8. Next recommended wave

`Archived Map Key Harness Triage v1`

The surface is truthful, but the known W7-W10 route-harness residue still
blocks clean route-proof reporting and should be triaged separately.
