# English Commercial Proof Lane Guard v1

## Purpose

Document the Act0 proof-lane locale guard for commercial screenshot review.

English is the commercial product-quality source of truth. Mixed RU/EN screenshots remain useful for layout proof, but final commercial copy proof should use an explicit English capture URL.

## Locale Root Cause

Act0 shell copy follows `Localizations.localeOf(context)`.

`AppRoot` sets `MaterialApp.locale` from `AppLanguageController.currentLocale`. That controller persists `app_language_code` and defaults to Russian when no saved language exists. The Act0 debug capture URLs selected a direct state, but did not override `MaterialApp.locale`, so captures inherited persisted/default Russian.

## Guard Behavior

Commercial proof captures can now force English by adding:

```text
locale=en
```

Example:

```text
http://127.0.0.1:7357/?act0_capture=first_week_review&locale=en
```

The override is explicit and narrow:

- requires a valid `act0_capture` URL;
- only supports `locale=en`;
- does not change normal user locale behavior;
- does not remove RU/localization support;
- does not persist language selection.

## Screenshot Proof

Captured compact Review proof at `393 x 852`:

```text
output/playwright/english_commercial_proof_lane_guard_v1/first_week_review_english_compact.png
```

Visible English proof:

- `Today 0/3`
- `What to fix next`
- `Sharky repair`
- `Repair one clue before it sticks`
- `One calm reread makes this clue easier tomorrow.`
- `You chose`
- `Better`
- `Repair this clue`

## Deferred

- Full Home/Review/Learn/Profile English commercial recapture.
- Automated screenshot lane reliability.
- RU/non-English QA and localization polish.
