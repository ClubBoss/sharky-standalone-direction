---
status: "COMPLETE \u2014 bounded implementation evidence recorded"
status_source: "derived"
baseline: "5029fcc8f3b9"
generated_by: "docs_frontmatter_v1"
---

# Learn / Worlds Coherence Pass v1

Status: COMPLETE — bounded implementation evidence recorded.

Terminal verdict: `learn_worlds_coherence_pass_v1_complete`

## Scope and source state

- Branch / HEAD: `claude/hub-surface-coherence-audit-plan-v1` @ `5029fcc8f3b9dcf03e7fcd443420dd7a72c61bf8`
- Source audit verdict: `hub_surface_coherence_audit_complete_ready_for_learn_worlds_coherence_pass`
- Files changed:
  - `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`
  - `test/ui_v2/wave4_4_premium_first_open_foundation_proof_v1_test.dart`
  - `test/ui_v2/act0_shell_preview_screen_v1_legacy_backlog.dart`
  - this review artifact

## Product role split

Before this pass, Learn contained a current-mission card plus three additional
path-shaped cues: a Foundation map card with W1-W4 chips, a Worlds map control,
and a Journey preview / View path control. Those elements competed to answer
where the learner is in the curriculum.

After this pass, Learn answers **what to do now**: the current-world context,
current mission, why it matters, and the visible Start/Continue action lead.
The lower section is a bounded lesson-browsing aid, labelled **Up next** with
an **All lessons** expansion. It no longer presents itself as a curriculum
path. Worlds continues to own **where am I in the big path?** through the
existing compact Worlds control and its unchanged overlay behavior.

## Exact Learn changes

| Disposition | Element | Result |
| --- | --- | --- |
| Removed | `Foundation map` card | Removed from Learn. |
| Removed | W1-W4 Foundation world chips and support copy | Removed with the duplicate map card. |
| Demoted | `Journey preview` | Renamed `Up next`; it remains below the mission as a small lesson preview. |
| Demoted | `View path` / `Full journey` | Renamed `All lessons` / `Show less`; it expands lessons in the current Learn slice, not a world map. |
| Retained | Compact current-world progress context | Retained as context, above the mission. |
| Retained | `Worlds` map-icon control and overlay route | Retained unchanged as the canonical curriculum/path map entry. |
| Retained | Current mission and Start/Continue CTA | Retained as the dominant first-viewport action. |

No routes, progression rules, lesson/table/completion semantics, W13+ state,
dependencies, or app-wide architecture changed.

## Validation

- PASS — `flutter test test/ui_v2/wave4_4_premium_first_open_foundation_proof_v1_test.dart`
- PASS — focused legacy-backlog Learn test: `Learn v5 premium depth stays mission-first and keeps lesson browsing manual`
- PASS — focused legacy-backlog Learn test: `Learn v6 all-lessons view enters collapsed and expands only after manual row tap`
- PASS — `flutter analyze`
- PASS — `graphify hook-check`
- PASS — `git diff --check`
- PASS — `git diff --cached --check`
- OUT-OF-SCOPE FAILURE SET — the full `act0_shell_preview_screen_v1_legacy_backlog.dart` run still reports failures in feedback, Home, capture-script, localization, and runner-fixture assertions outside the touched Learn behavior. The Learn cases changed by this pass were rerun in isolation and pass.

## Compact evidence

- Evidence folder: `/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast`
- Learn image: `/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/compact.learn.png`
- Learn-detail image: `/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/compact.learn_detail.png`
- Contact sheet: `/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/contact_sheet.png`
- ZIP: `/Users/elmarsalimzade/Sharky_1.0/output/screen_review/current/core_fast/screen_review_core_fast.zip`
- Capture command: `./tools/screen_review_fast_v1.sh core compact`

The available capture tool has no Learn/Worlds-only packet and no dedicated
Worlds-overlay surface, so the smallest lane containing Learn was used. The
contact sheet was visually inspected: the compact Learn viewport shows the
Worlds control, mission card, Start CTA, and Up next lesson list without the
Foundation map card. The packet includes unrelated core screens solely because
of this tooling limitation. Output remains local-only and unstaged.

## Return queue / debt ledger

| Item | Owner layer | Intended timing | Disposition |
| --- | --- | --- | --- |
| Home backward-looking proof / momentum gap | Home surface + proof presentation | Dedicated Home proof wave | Deferred; not touched. |
| Profile generic stat tiles / MB-024 | Profile surface | Profile differentiation wave | Deferred; not touched. |
| Practice / Review minor sparseness and dead space | Practice and Review surfaces | Bounded hub refinement | Deferred; not touched. |
| Shared card grammar repetition / MB-015 | Shared visual language | Cross-hub visual-system pass | Deferred; not touched. |
| W11/W12 table differentiation | W11/W12 lesson/table owners | Separate late-world differentiation wave | Deferred; not touched. |
| Screenshot evidence masking/tooling artifact | Evidence tooling | Capture-tooling maintenance wave | Deferred; no product defect inferred. |
| Sharky placeholder | Mascot/art-direction layer | After direction lock | Deferred; not touched. |
| Motion, touch, and ceremony | Motion system + surface owners | Dedicated interaction/motion wave | Deferred; not touched. |

Home, Profile, Practice, Review, W11/W12 differentiation, Sharky, and motion
were not part of this wave. This artifact does not claim 10/10, public
readiness, or Human QA readiness; Human QA has not been run.
