# Value-Before-Paywall Copy Guard v1

## 1. Verdict

`copy_guard_ready_with_legacy_allowlist`

## 2. Active surface scan

The guard scans these canonical Act0 learner-facing copy owners:

- `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_premium_preview_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`

It checks exact active-packaging claims and pressure phrases: W13 unlock,
upgrade-to-continue, premium specialization, trial start, subscribe, purchase,
restore purchase, paid-depth-now, full Cash/MTT tracks, AI/leak claims, mastery
path, become-pro, Volume I completion, and scarcity/countdown variants.

Result: no forbidden active learner-facing packaging phrase was found. No
learner copy was changed.

## 3. Legacy/dormant classification

The repository retains premium/trial/entitlement vocabulary in historical or
dormant families, including `lib/payments/`, premium/trial/subscription
services, `ui_v2_premium_hub.dart`, and dormant persona/AI-coach families.
Those families are outside the canonical Act0 route and outside this guard's
owner list.

The explicit exclusion is narrow: an exclusion root must not overlap an active
Act0 copy owner. It becomes unsafe if that family is routed into Act0, supplies
learner-visible copy to an active shell, or becomes the owner of an active
commerce action.

`premium`, `price`, and `locked` are intentionally not banned as individual
tokens: they have non-commerce poker and progression meanings. The guard fails
on specific packaging claims instead.

## 4. Guard behavior

`test/tools/value_before_paywall_copy_guard_v1_test.dart` reads the approved
active owner list and fails closed when any exact forbidden packaging or
pressure phrase appears. It also proves the matcher catches a synthetic
`Unlock W13` / `Upgrade to continue` / `ends today` example.

It intentionally ignores review/plan documentation and dormant code roots so
policy discussion and legacy isolation remain possible. It does not grant an
exception to active Act0 copy. This preserves value-before-paywall trust by
catching concrete learner-facing commerce drift without confusing poker terms
or ordinary progression locks with payment claims.

## 5. Files changed

- `test/tools/value_before_paywall_copy_guard_v1.dart`
- `test/tools/value_before_paywall_copy_guard_v1_test.dart`
- `docs/_reviews/value_before_paywall_copy_guard_v1.md`

No product runtime, learner copy, content, route, or commerce behavior changed.

## 6. Scope proof

- No paywall, trial, pricing, subscription, purchase, restore, entitlement, or
  access change.
- No route or UI change.
- No content expansion.
- No W11-W12 or W13+ work.
- Modern Table untouched.
- External/App Store packaging remains deferred.

## 7. Next recommended wave

`Accepted Local Work Commit Batch v1`

The packaging contract and copy guard are a coherent local docs/test batch.
They should be reviewed and consolidated before any premium-boundary decision
or commerce implementation work.
