# Manual First-Week Compact Screenshot QA Packet v1

## Purpose

Fallback visual QA for the first-week progression surfaces after the targeted Playwright capture lane remained blocked by local process exit `137`.

The goal was to get enough compact portrait visual evidence to choose the next product implementation wave without broad screenshot tooling drift.

## Capture Method

Used the existing Act0 first-week debug URLs in the in-app browser with a `393 x 852` viewport:

- `?act0_capture=first_week_home`
- `?act0_capture=first_week_review`
- `?act0_capture=first_week_learn`
- `?act0_capture=first_week_profile`

The screenshots were saved under:

```text
output/playwright/manual_first_week_compact_screenshot_qa_packet_v1/
```

No broad controlled-demo sweep was run. No product code, routes, copy, telemetry, table geometry, Playwright tooling, or screenshot tooling was changed.

Locale note: the browser rendered a Russian-dominant mixed locale despite an English recapture attempt. The screenshots are still useful for compact layout, hierarchy, premium feel, and first-week concept visibility, but English copy QA remains deferred.

## Screenshot Inventory

| Surface | Path | Status |
| --- | --- | --- |
| Home compact first-week | `output/playwright/manual_first_week_compact_screenshot_qa_packet_v1/first_week_home_compact.png` | captured |
| Review compact open repair | `output/playwright/manual_first_week_compact_screenshot_qa_packet_v1/first_week_review_open_repair_compact.png` | captured |
| Learn compact first-week path | `output/playwright/manual_first_week_compact_screenshot_qa_packet_v1/first_week_learn_compact.png` | captured |
| Profile compact return rhythm | `output/playwright/manual_first_week_compact_screenshot_qa_packet_v1/first_week_profile_compact.png` | captured |
| Manifest | `output/playwright/manual_first_week_compact_screenshot_qa_packet_v1/capture_manifest.json` | captured |

## Surface-by-Surface Review Table

| surface/state | screenshot path or missing-proof status | user job | first-week clarity score | visual premium score | text density risk | blocker? | issue class | recommended action |
| --- | --- | --- | ---: | ---: | --- | --- | --- | --- |
| Home first-week trainer | `first_week_home_compact.png` | Understand today's short trainer plan and continue | 8.3 | 8.1 | Medium | No | text density | Keep direction; consider small readability pass on checklist density and locale consistency. |
| Review open repair | `first_week_review_open_repair_compact.png` | See one mistake and start the repair rep | 7.2 | 7.7 | Medium-high | No commercial blocker | weak hierarchy | Repair card is clear, but first-week frame is partially below/around the repair state and feels more operational than coach-like. |
| Learn first-week path | `first_week_learn_compact.png` | See current mission and understand Week 1 path | 8.0 | 8.2 | Low-medium | No | no issue | Strong path packaging; first-week sentence is visible and the mission card feels polished. |
| Profile return rhythm | `first_week_profile_compact.png` | Understand return rhythm and progress proof | 7.4 | 7.6 | Medium | No commercial blocker | unclear first-week journey | Rhythm proof is visible, but Profile reads as stats/account surface more than trainer identity. |

## First-Week Journey Coherence Verdict

The first-week loop is visually present across all four surfaces:

- Home frames the day as a short table-practice plan.
- Review shows a repair route rather than a generic mistake list.
- Learn gives the strongest path framing: first week is about seeing the table before choosing.
- Profile shows return rhythm and progress, but the connection back to the trainer loop is weaker than Home/Learn.

Overall coherence: **7.7 / 10**.

The journey exists and is understandable, but Review/Profile still feel more operational than a market-leading coach loop.

## Commercial Readability Verdict

Commercial readability is acceptable for a pre-paywall trust surface:

- No visible paywall pressure.
- No fake AI/GTO/solver claims.
- Clear action CTAs.
- Premium dark table-trainer style is consistent.

Main risk is not trust; it is density and trainer personality. Some cards still look like system state rather than a calm coach guiding the week.

Commercial readiness for this compact packet: **7.8 / 10**.

## Runout Comparison From Visible Evidence Only

Runout's visible advantage remains packaging calm: table-forward composition, simpler action surfaces, and less perceived dashboard density.

Sharky's visible advantage remains deterministic learning proof: repair route, first-week plan, progress, and return rhythm all connect to a learning loop instead of only presenting content.

Current gap from visible evidence: Sharky has stronger learning proof, but less calm visual hierarchy in Review/Profile.

## Blockers vs Acceptable Polish

Blockers:

- None for product route validity.
- None for commercial trust.
- English copy screenshot proof remains incomplete because browser locale persisted Russian/mixed strings.

Acceptable polish:

- Home checklist density.
- Review repair hierarchy.
- Profile trainer identity.
- Better visual connection between first-week rhythm and the coach persona.

## Recommended Next Implementation Wave

**Sharky Coach Presence + Trainer Voice Pass v1**

Reason: all four surfaces are viable enough that a narrow readability-only repair would under-shoot the bigger gap. The next EV is making Home/Review/Profile feel like the same premium trainer, while preserving the deterministic proof loop.

Scope should be bounded to visible hierarchy/copy surfaces only:

- strengthen coach identity across Home, Review, Profile;
- reduce operational/system feel in Review/Profile;
- keep table-signal proof, repair loop, and first-week progress intact;
- no new dashboard, paywall, route changes, or table geometry.

## Deferred List

- English-locale screenshot recapture.
- Automated targeted screenshot lane reliability.
- Broad controlled-demo sweep.
- Product Surface Premium Implementation Pack.
- Session Result / Progress Anchor.
- Learn/Profile deeper IA work.

## Direction Score

**8.0 / 10**

The first-week progression direction is sound and commercially credible. It is not yet Runout-level calm in Review/Profile, but it has a stronger learning-proof spine than a generic premium trainer.
