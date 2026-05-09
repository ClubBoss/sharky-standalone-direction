# Submission Metadata Truth v1

## Purpose

This file is the canonical owner for submission-only launch metadata fields that
are not yet resolved on current `main`.

It exists to prevent placeholder, sample, or invented submission values from
reappearing across store-package docs or adjacent release surfaces.

## Current Main Truth

- Support contact used by current runtime/help surfaces: `support@sharky.app`
- In-app legal surface owner: `lib/ui_v2/settings/legal_screen_v1.dart`
- In-app privacy/terms body owner: `lib/ui/settings/privacy_terms.dart`

## Submission-Only Fields

- Support URL: unresolved on current `main`
- Marketing URL: unresolved on current `main`
- Legal entity display name: unresolved on current `main`
- Copyright line for store submission: unresolved on current `main`

## Unresolved-State Policy

- Do not use `example.com`, sample domains, or fake production URLs.
- Do not use placeholder company names or sample legal entities.
- Do not invent final submission metadata values before release-owner approval
  via `docs/release/release_owner_review_v1.md`.
- If a submission-only field is still open, mark it `unresolved on current main`
  instead of filling a guessed value.

## Ownership Rule

- `docs/release/submission_metadata_truth_v1.md` is the canonical owner for
  unresolved submission-only metadata truth.
- `docs/release/store_package_v1.md` may summarize these fields, but it must
  point back to this file instead of restating ownerless placeholder values.
- Any stronger human decision that resolves these fields must use
  `docs/release/release_owner_decision_template_v1.md`.

## Current Bounded Proof On Main

- This owner records unresolved submission-only metadata truth on current
  `main`.
- It is bounded to support/legal/marketing submission metadata only.
- Current-main machine-readable anchors for this owner are:
  - `support@sharky.app`
  - `Support URL: unresolved on current main`
  - `Marketing URL: unresolved on current main`
  - `Legal entity display name: unresolved on current main`
  - `Copyright line for store submission: unresolved on current main`
- This owner does not claim store submission readiness.
- This owner does not claim final release completion.
- If any release surface implies these submission-only fields are finalized on
  current `main`, that surface is overstating repo truth and must be corrected.
