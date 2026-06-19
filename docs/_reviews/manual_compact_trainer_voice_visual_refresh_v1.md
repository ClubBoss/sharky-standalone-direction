# Manual Compact Visual Refresh - Trainer Voice Pass v1

## Purpose

Visual QA refresh for the compact first-week surfaces after Sharky Coach Presence + Trainer Voice Pass v1.

The goal was to verify whether the latest trainer-voice copy improved commercial readability without introducing density, overflow, truncation, or weaker hierarchy.

## Capture Method

Used the existing first-week debug URLs at compact portrait `393 x 852`:

- `?act0_capture=first_week_home`
- `?act0_capture=first_week_review`
- `?act0_capture=first_week_learn`
- `?act0_capture=first_week_profile`

The first attempt through `tools/act0_first_week_compact_capture_v1.sh` exited with the known local process-kill class `137`. No Playwright or screenshot tooling was modified or debugged.

Manual/in-app browser capture was then used against a fresh local Flutter web server at `http://127.0.0.1:7357/`. The already-running server on port `7357` was stale and showed pre-trainer-voice copy, so it was stopped and restarted before final capture.

Screenshots were saved under:

```text
output/playwright/manual_compact_trainer_voice_visual_refresh_v1/
```

Locale note: the refreshed screenshots still rendered RU-dominant mixed locale. They are valid for layout, density, hierarchy, and visible localized proof of the changed trainer-voice concepts. Final English commercial screenshot proof remains deferred.

## Screenshot Inventory

| Surface | Path | Status |
| --- | --- | --- |
| Home compact first-week | `output/playwright/manual_compact_trainer_voice_visual_refresh_v1/first_week_home_compact.png` | captured |
| Review compact open repair | `output/playwright/manual_compact_trainer_voice_visual_refresh_v1/first_week_review_open_repair_compact.png` | captured |
| Learn compact first-week path | `output/playwright/manual_compact_trainer_voice_visual_refresh_v1/first_week_learn_compact.png` | captured |
| Profile compact return rhythm | `output/playwright/manual_compact_trainer_voice_visual_refresh_v1/first_week_profile_compact.png` | captured |
| Manifest | `output/playwright/manual_compact_trainer_voice_visual_refresh_v1/capture_manifest.json` | captured |

## Surface-by-Surface Review Table

| surface/state | screenshot path or missing-proof status | user job | trainer voice clarity score | first-week clarity score | visual premium score | text density risk | blocker? | issue class | recommended action |
| --- | --- | --- | ---: | ---: | ---: | --- | --- | --- | --- |
| Home compact first-week | `first_week_home_compact.png` | Understand today's short trainer plan and continue | 8.2 | 8.4 | 8.2 | Medium | No | acceptable polish | Keep. The trainer line now feels more direct, but the checklist remains fairly dense on compact portrait. |
| Review compact open repair | `first_week_review_open_repair_compact.png` | See one repair target and start the fix | 7.8 | 7.6 | 7.7 | Medium-high | No route blocker | weak hierarchy / mixed language | Next focused wave should simplify the open repair card hierarchy and reduce operational feel without changing resolver logic. |
| Learn compact first-week path | `first_week_learn_compact.png` | See the current mission and Week 1 learning path | 8.4 | 8.3 | 8.3 | Low-medium | No | no issue | Keep. The shorter first-week line is readable and the mission/path structure is strong. |
| Profile compact return rhythm | `first_week_profile_compact.png` | Understand return rhythm and progress proof | 7.9 | 8.0 | 7.9 | Medium | No | low trainer identity | Defer unless Profile becomes the next commercial proof surface. It is viable but still reads more like stats than a coach. |

## Trainer Voice Verdict

The pass improved the compact surfaces.

Visible localized proof shows the new concepts landed:

- Home now frames Week 1 as one table read and gives a more direct Sharky handoff.
- Review now uses the shorter repair badge and more human repair CTA.
- Learn now uses a shorter first-week instruction.
- Profile now uses the shorter return-rhythm line.

The trainer voice is strongest on Home and Learn. Review improved, but the screen still feels partly operational because the repair card, mistake card, labels, and mixed-language task content compete for attention. Profile is coherent but still has weaker Sharky identity than Home.

## Commercial Readability Verdict

Commercial readability is acceptable for first-week continuation and trust building:

- No visible paywall pressure.
- No fake AI, solver, GTO, or overclaim framing.
- No visible overflow or truncation in the refreshed screenshots.
- CTAs are visible and tappable.
- The dark premium shell remains consistent.

The remaining issue is hierarchy, not product truth. Review especially needs the user's eye to land faster on "this is one calm repair" instead of parsing several cards and labels.

## Runout Comparison From Visible Evidence Only

Runout's visible benchmark advantage remains calm packaging and simpler bottom-surface hierarchy.

Sharky's visible advantage remains stronger learning proof: Home, Review, Learn, and Profile all connect to a table-reading and repair loop rather than only presenting content.

Current gap from these screenshots: Sharky now has better coach copy, but Review/Profile still do not match Runout-level calm hierarchy. The gap is narrow enough for a focused Review repair-card readability wave rather than a broad product-surface pack.

## Blockers vs Acceptable Polish

Blockers:

- None for route validity.
- None for compact overflow/truncation.
- None for commercial trust.

Proof limitations:

- English screenshot proof is deferred because the browser rendered RU/mixed locale.
- DOM body text was empty for Flutter semantics, so visual review used image inspection rather than text extraction.

Acceptable polish:

- Home checklist density.
- Profile trainer identity.
- Locale-stable English capture proof.

Needs targeted implementation before a broader product layer:

- Review open repair hierarchy/readability.

## Recommended Next Implementation Wave

**Review First-Week Repair Card Readability v1**

Reason: Review is the only surface below the 8.0 bar on first-week clarity and trainer hierarchy after the trainer-voice pass. It is not broken, but it is the most likely place where a learner still feels system state instead of a calm coach.

Suggested scope:

- reduce the perceived hierarchy conflict between the mistake card and the lower repair board;
- keep one clear repair target and one CTA;
- preserve repair resolver, telemetry, route order, and content;
- do not touch table geometry, Home/Profile/Learn, commerce, or dashboards.

## Deferred List

- English-locale compact recapture.
- Automated targeted capture reliability.
- Product Surface Premium Implementation Pack.
- Profile Return Rhythm Surface Repair.
- Session Result / Progress Anchor.
- Broad controlled-demo sweep.
- Localization cleanup.

## Direction Score

**8.2 / 10**

The direction is commercially credible. The trainer voice pass improved the first-week loop, and the current best next move is a narrow Review readability wave rather than a broad redesign.
