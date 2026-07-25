---
status: "small_10_10_polish_landed_with_watchlist"
status_source: "derived"
baseline: "27de3139513f"
generated_by: "docs_frontmatter_v1"
---

# Small 10/10 Visual Polish Follow-Up v1

## 1. Verdict

`small_10_10_polish_landed_with_watchlist`

The bounded SR-01 Welcome and SR-03 Profile polish is implemented. Fresh compact evidence shows a more intentional Welcome handoff and a concrete state-backed Profile achievement above the fold. This verdict does not make a 10/10, readiness, launch, or Human QA claim.

## 2. Stage 0 status

- Branch: `codex/apply-owner-patch-sequence-a-b-c-d-v1`.
- HEAD before changes: `27de3139513feb1a92642b98f948517792feb4ca`.
- Branch relation at entry: `origin/main...HEAD = 0 4`.
- Tracked worktree, index, and `output/` were clean at entry; no files were staged.
- Required senior audit artifact was present in the verified source workspace.
- `graphify hook-check`: pass.

## 3. Fix summary

### SR-01 — Welcome handoff composition

- Status: landed.
- Files touched: `lib/ui_v2/act0_shell/act0_welcome_shell_v1.dart`, `test/ui_v2/act0_shell_preview_screen_v1_test.dart`.
- Exact change: the final handoff now reuses the existing Answer / Quick check / First hand launch-path component. The progress bar remains top-anchored, the enlarged handoff stack occupies the flexible middle region, and the existing CTA remains bottom-anchored.
- Evidence: `output/screen_review/current/first_week_fast/compact.welcome_handoff.png`.
- Validation: focused Welcome handoff guard and first-week capture pass.
- Learner-facing outcome: the final step communicates completed setup, the immediate handoff, and the unchanged next action without adding a new flow or claim.
- Risk: low; presentation-only reuse of an existing component, with CTA callback and route behavior unchanged.

### SR-03 — Profile concrete proof

- Status: landed.
- Files touched: `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`, `test/ui_v2/act0_shell_preview_screen_v1_test.dart`.
- Exact change: the above-fold Earned tile now displays the first unlocked named achievement from `Act0ProfileStateV1`; if none is unlocked, the same tile honestly labels the first available state-backed item as `Next proof`. The generic tile tagline was removed.
- Evidence: `output/screen_review/current/core_fast/compact.profile.png` shows `Earned — First clear read` above the fold.
- Validation: focused Profile concrete-proof guard and core capture pass.
- Learner-facing outcome: Profile immediately shows a concrete earned proof instead of promise-only language.
- Risk: low; read-only presentation of existing achievement state, with progression and route logic unchanged.

## 4. Deferred items

| Item | Reason deferred | Future trigger |
| --- | --- | --- |
| SR-02 Review dead space | Explicitly outside this two-seam wave. | A dedicated Review polish wave with fresh evidence. |
| Motion evidence gap | No motion implementation or tooling change was authorized. | A dedicated motion-evidence refresh. |
| Blank CTA tooling artifact | Capture-harness repair was forbidden. | A focused screenshot-tooling wave. |
| GR-14 minor phrasing | Not incidental to the two changed lines. | A bounded copy-polish review. |
| G10 bridge visual coverage | No new visual coverage was authorized. | A dedicated bridge-evidence packet. |

## 5. Screenshot evidence

- Regenerated only `first_week_fast` and `core_fast` compact packets.
- Inspected `first_week_fast/compact.welcome_handoff.png` and `core_fast/compact.profile.png`.
- `profile_evidence_fast` and unrelated packets were not regenerated.
- All `output/**` evidence remains local-only and unstaged.

## 6. Validation results

- Focused red/green test: `Welcome completes one local micro win before Home handoff` — pass after implementation.
- Focused red/green test: `Profile Earned tile shows concrete unlocked proof above fold` — pass after implementation.
- Changed-file `flutter analyze` — pass, no issues.
- `graphify hook-check` — pass.
- `first_week` compact capture — pass.
- `core` compact capture — pass.
- Final `flutter analyze`, diff checks, focused guards, staged-scope checks, and commit result are recorded in the final handover after the commit gate.
- A broader name-filtered legacy test-file run also surfaced five unrelated brittle assertions: two Russian-locale expectations, one recent-gain display expectation, and two ambiguous `Practiced` text finders. The focused changed-seam guards pass; this wave does not modify locale, recent-gain, or Practiced-label behavior. These failures are validation watchlist only and are not repaired here.

## 7. Commit result

- Committed: yes, subject to the final clean gate below.
- Commit hash: reported in the final handover because the containing Git object ID is assigned only after this artifact is frozen.
- Commit message: `polish: tighten welcome and profile proof surfaces`.
- Push status: not pushed.

## 8. Claim safety

- No readiness score movement.
- No top-1/10/10 claim.
- No premium, public, or launch-readiness claim.
- No Human-QA-ready claim and no Human QA pass.
- No public learning-effect claim.
- No monetization-readiness claim.
- W13+ remains blocked.
- Mapper/Practice remains blocked.
- Modern Table remains maintenance-only.

## 9. Next Chat Handover

- Verdict: `small_10_10_polish_landed_with_watchlist`.
- Artifact: `docs/_reviews/small_10_10_visual_polish_followup_v1.md`.
- Commit hash: see final response.
- Validation: focused SR-01/SR-03 guards, analysis, graphify, and both required captures pass; unrelated legacy assertions remain on the validation watchlist.
- Screenshots regenerated: `first_week_fast` and `core_fast` compact only.
- Remaining watchlist: SR-02 Review dead space, motion evidence, blank CTA capture tooling, GR-14 phrasing, G10 bridge coverage, and the unrelated brittle test assertions listed above.
- Recommended next prompt: `Visual Polish Verification v1`.
- Recommended agent: Codex, for a short evidence-only verification against the fresh Flutter packets and focused guards.
- Forbidden next scope: Human QA execution, route expansion, W13+, mapper/Practice expansion, Modern Table redesign, monetization, public claims, and capture-harness repair unless separately authorized.
- Token/context notes: start from this artifact, the senior audit, the two changed owner seams, and the two regenerated compact screenshots; do not broad-read or regenerate unrelated packets.
