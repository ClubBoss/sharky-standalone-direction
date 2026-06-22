# Commercial Screenshot / Renderer Acceptance v1

## Scope

Audit / evidence acceptance plus one narrow renderer-tooling fix. No product
UI, copy, routes, telemetry, Modern Table visuals, content, monetization,
Sharky/persona, AI, dashboard, XP, or economy behavior changed.

Generated screenshot, manifest, contact-sheet, and zip artifacts remain
local-only and must not be committed.

## Evidence used

Commands run:

```bash
./tools/screen_review_fast_v1.sh first_week compact
./tools/screen_review_fast_v1.sh day2_return compact
```

Artifacts inspected:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/manifest.json`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/manifest.json`
- `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`

Supporting docs:

- `docs/_reviews/screenshot_tooling_inventory_v1.md`
- `docs/_reviews/first_return_day2_proof_packet_capture_lane_v1.md`
- `docs/_reviews/top1_route_recalibration_after_day2_v1.md`

## first_week packet verdict

Accepted for internal product/design/AI review and near-term commercial proof
discussion.

The packet shows the intended chain:

- placement;
- Welcome micro-win decision;
- Welcome feedback;
- Welcome handoff;
- W1 decision;
- correct feedback;
- wrong feedback;
- Repair focus;
- Repair result;
- Session repair;
- Review handoff;
- Profile return proof.

After the text-repair fix, primary CTA/button labels are readable. The proof
beats are understandable without internal explanation.

Not store-grade yet: the contact sheet is dense and long tile labels can crowd
filenames.

## day2_return packet verdict

Accepted for internal product/design/AI review and Day 2 commercial proof
discussion.

The packet shows the intended return chain:

- first-session open repair source;
- Day 2 Home repair priority;
- Practice same repair target;
- Review active repair continuation;
- Profile active repair proof / not falsely clear.

After the text-repair fix, the key CTA labels are readable:

- `Fix this now`
- `Repair this clue`

The packet clearly proves return value: the missed signal persists into the
next useful action instead of disappearing into generic practice.

Not store-grade yet: the contact sheet still has cramped long labels.

## Artifact / readability issues

### Fixed in this pass

The fast-renderer text repair helper was scoped only to core surfaces:

```text
home, learn, practice, review, profile
```

That meant first-week and Day 2 packet-specific overlay metadata was generated
but never applied, leaving several primary button labels as white bars.

The helper now processes every `compact.*.png.text_overlays.json` file in the
packet directory. This keeps the fix local to screenshot evidence tooling and
does not alter product rendering.

### Remaining accepted limitation

Contact-sheet labels can crowd with filenames on long state names, especially:

- `First-session open repair`
- `Practice same repair target`
- `Profile active repair proof`

This does not block current packet use because the underlying screen content is
readable and the original per-screen PNGs remain available.

## CTA / button renderer verdict

Accepted after narrow tooling fix.

Before the fix, white bars materially lowered commercial readiness because
primary actions looked broken. After the fix, first_week and day2_return CTAs
are readable enough for internal and near-term external review.

This was a tooling/renderer post-processing issue, not a product UI issue.

## Contact-sheet label / layout verdict

Accepted with limitation.

The current contact-sheet composition is usable for fast review, but not ideal
as a polished sales/store asset. It is acceptable for product/design/commercial
evidence review because:

- screen content is readable;
- original PNGs are included;
- manifest and zip preserve per-screen inspection;
- label crowding does not obscure the actual app state.

If a future packet is meant for external decks or store-style presentation,
make a separate contact-sheet layout pass with shorter labels or larger header
space.

## Architecture score vs commercial proof score

- Architecture / Product Logic: high. The first-week and Day 2 repair/return
  chains are deterministic, packet-capturable, and reviewable.
- Commercial Proof / External Readiness: improved after the CTA text repair,
  but still below store-grade. Current packets are good enough for internal
  product/design/AI review and near-term commercial proof discussion, not final
  App Store / paid acquisition screenshots.

Do not collapse these into one blended score.

## Accepted limitations

- Fast Flutter-rendered packets are proof packets, not native device marketing
  screenshots.
- Contact-sheet labels are functional, not polished.
- First_week and Day 2 packets prove the proof chain; they do not prove full
  content depth.
- Store-grade screenshot composition remains a later packaging task.

## Blockers

No blocker remains for using the current packets in product/design/AI review.

Commercial/store-grade screenshot proof is still pending and should not be
claimed from these packets alone.

## Implementation candidates ranked

1. **Content Depth / Term Introduction / Drill Coverage Audit** - highest next
   EV because packets now prove the route, while W5-W36 depth still determines
   whether premium is structurally credible.
2. **Contact-sheet label/layout polish** - useful if evidence packets need to
   be shared externally in decks; not required for current review.
3. **Native/slow screenshot lane for final marketing proof** - defer until
   store-grade screenshot needs are explicit.
4. **Product UI / CTA refinement** - not indicated by this pass; the issue was
   renderer/tooling, not unclear product action.
5. **No immediate renderer work** - current white-bar blocker is fixed.

## Final recommendation

Use the current `first_week compact` and `day2_return compact` packets for
internal product/design/AI review and near-term commercial proof discussion.

Do not start monetization, store screenshot packaging, or broad UI redesign
from this pass.

## Exact recommended next prompt title

`Content Depth / Term Introduction / Drill Coverage Audit v1 — Local Only`

Optional later prompt if deck/store proof becomes urgent:

`Screen Review Contact Sheet Label Polish v1 — Local Only`

## Validation

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name 'Fast screen review text repair covers packet-specific surfaces'`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `python3 -m py_compile tools/screen_review_fast_text_repair_v1.py`

Pending for commit packaging:

- `bash -n` on touched shell scripts if any.
- `flutter analyze` if Dart touched.
- `dart format --set-exit-if-changed` on touched Dart/test files.
- `git diff --check`.
- `git status --short`.
