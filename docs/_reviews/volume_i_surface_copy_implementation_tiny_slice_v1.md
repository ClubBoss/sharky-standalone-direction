# Volume I Surface Copy Implementation Tiny Slice v1

## 1. Verdict

`implemented_copy_only`

## 2. What changed

Files changed:

- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `docs/_reviews/volume_i_surface_copy_implementation_tiny_slice_v1.md`

| Future-volume field | Old copy | New copy |
| --- | --- | --- |
| Volume II subtitle | `Strategy` | `Later strategic depth` |
| Volume II badge | `Locked` | `Later frontier` |
| Volume II support line | `Unlocks after Volume I.` | `This is a future landmark, not a lesson you can open today.` |
| Volume II preview | `Preview: position, preflop structure, bet purpose, and board reading.` | `More strategic study follows the shared foundation.` |
| Volume III subtitle | `Mastery` | `Advanced frontier` |
| Volume III badge | `Locked` | `Advanced frontier` |
| Volume III support line | `Unlocks after Volume II.` | `This is a future landmark, not a lesson you can open today.` |
| Volume III preview | `Preview: pressure spots, adjustments, and review loops.` | `Later advanced specialist study.` |

The equivalent local Russian strings changed with the same status meaning; no
localization storage, API, or architecture changed.

## 3. Scope proof

- Route unchanged: future-volume taps still open the existing informational
  preview, and the existing current-route CTA still dismisses that preview.
- Access unchanged: no access state, availability condition, or gateway was
  added or removed.
- Clickability unchanged: Volume II and III retain their existing preview taps;
  no future lesson or world destination was made available.
- Entitlement unchanged: no premium, trial, purchase, restore, or paywall
  behavior or copy was added.
- UI structure unchanged: the existing volume strip, sheet, keys, and widgets
  are unchanged; only supplied strings changed.
- Content unchanged: no world, session, drill, or curriculum source changed.
- Localization architecture unchanged: the existing `_learnCopyV1` calls and
  bilingual inline-copy model remain intact.
- Modern Table untouched.

## 4. Copy contract compliance

The updated Volume II surface uses the approved `Later strategic depth` and
`Later frontier` language. The updated Volume III surface uses the approved
`Advanced frontier` and `Later advanced specialist study.` language. Their
shared support line explicitly says the landmark is not a lesson available
today.

Focused assertions confirm the touched Volume II/III preview surfaces do not
show `Locked`, `Unlocks after Volume I.`, `Unlocks after Volume II.`,
`Premium preview`, `See what premium adds`, or `Mastery` in the relevant
future-volume preview panel.

## 5. Tests / guards

Updated focused assertions in
`test/ui_v2/act0_shell_preview_screen_v1_test.dart`:

- `Volume strip shows active and future frontier states`
- `Future volumes open compact frontier previews without commercial copy`

Both pass in isolation. The latter also confirms the existing Volume II
continue-current CTA still dismisses the informational preview and that the
Volume III preview retains its existing panel behavior.

No unrelated baseline suite was changed. The known archived map-key mismatch
was not exercised or repaired in this copy-only slice.

## 6. Residuals

- The archived map-key harness mismatch remains separate.
- W11-W12 remains planned foundation work, not learner-route content.
- W13+ remains frontier-only, not playable or unlockable.
- External/App Store packaging remains deferred.

## 7. Next recommended wave

`Content Depth / Term Introduction / Drill Coverage Audit v1`

The stale surface wording is corrected. The next material truth risk before
broader surface work is whether current route-backed worlds carry enough
beginner-safe term introduction and drill depth to support the now-honest
route horizon. That audit requires no route, commerce, or surface expansion.
