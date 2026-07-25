---
status: "COMPLETE \u2014 bounded implementation evidence recorded"
status_source: "derived"
baseline: "21ee575b8431"
generated_by: "docs_frontmatter_v1"
---

# Home Proof / Momentum Pass v1

Status: COMPLETE — bounded implementation evidence recorded.

Terminal verdict: `home_proof_momentum_pass_v1_complete`

## Scope and source state

- Branch / HEAD before commit: `claude/hub-surface-coherence-audit-plan-v1` @ `21ee575b843173abe64caea2a9c439200a5e0218`
- Files changed:
  - `lib/ui_v2/act0_shell/act0_home_shell_v1.dart`
  - `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
  - this review artifact

## Home role after this pass

Before this pass, Home had a clear current action and a useful three-step
checklist, but the default return viewport did not turn its existing route
progress into a clear reason to return. The compact progress pill was present,
but it read as supporting metadata rather than a learner-facing receipt.

After this pass, the existing mission card adds one integrated momentum line
between its route metadata and primary CTA. When the provided progress label
confirms completed lessons, it says `Route proof: N lessons complete. Next
proof starts with one clean read.` When no compatible progress value is
available, it says `Your route is ready. Next proof starts with one clean
read.` The fallback invents no completion, streak, mastery, or personalized
statistic.

Home remains the quick re-entry surface: the unchanged primary CTA answers
where to continue, the route-proof line explains why returning matters, and
the checklist remains secondary. No map or curriculum-path UI was added, so
Learn still owns the sequential course and Worlds still owns the broader path.

## Validation

- PASS — `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart`
  - proves the default verified-progress receipt;
  - proves the no-progress fallback does not claim completed lessons.
- PASS — `flutter analyze`
- PASS — `graphify hook-check`
- PASS — `git diff --check`
- PASS — `git diff --cached --check` before staging (no staged changes existed).

## Compact evidence

- Evidence folder: `/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast`
- Home image: `/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/compact.home.png`
- Contact sheet: `/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/contact_sheet.png`
- ZIP: `/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/screen_review_core_fast.zip`
- Capture command: `./tools/screen_review_fast_v1.sh core compact`

The capture tool has no Home-only packet; `core compact` is the smallest
available lane that contains Home. The contact sheet was visually inspected:
the compact Home viewport renders the route-proof line, keeps the Continue CTA
obvious, and shows no text masking or black-rectangle artifact. The additional
core surfaces are tooling overhead only. Output remains local-only and
unstaged.

## Return queue / debt ledger

| Item | Owner layer | Intended timing | Disposition |
| --- | --- | --- | --- |
| Profile generic stat-tile execution / MB-024 | Profile surface | Dedicated Profile differentiation wave | Deferred; not touched. |
| Shared card grammar repetition / MB-015 | Shared visual language | Cross-hub visual-system pass | Deferred; not touched. |
| Practice / Review minor sparseness and dead-space | Practice and Review surfaces | Bounded hub refinement | Deferred; not touched. |
| W11/W12 table differentiation | W11/W12 lesson and table owners | Separate late-world differentiation wave | Deferred; not touched. |
| Screenshot evidence masking/tooling artifact | Evidence tooling | Capture-tooling maintenance wave | Deferred; no product defect inferred. |
| Sharky placeholder | Mascot/art-direction layer | After direction lock | Deferred; not touched. |
| Motion, touch, and ceremony | Motion system and surface owners | Dedicated interaction/motion wave | Deferred; not touched. |
| Tablet | Surface responsiveness | Explicit tablet wave | Deferred; not touched. |

Profile, Practice, Review, W11/W12, Sharky, motion, and tablet were not part
of this wave. This artifact does not claim 10/10, public readiness, or Human
QA readiness; Human QA has not been run.
